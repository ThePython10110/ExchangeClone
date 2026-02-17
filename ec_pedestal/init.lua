local particle_positions = {
    {x = -0.2, y=-0.2, z=-0.2},
    {x = 0, y=-0.2, z=-0.2},
    {x = 0.2, y=-0.2, z=-0.2},
    {x = 0.2, y=-0.2, z=0},
    {x = 0.2, y=-0.2, z=0.2},
    {x = 0, y=-0.2, z=0.2},
    {x = -0.2, y=-0.2, z=0.2},
    {x = -0.2, y=-0.2, z=0},
}

local function add_particles(pos)
    for _, offset in pairs(particle_positions) do
        core.add_particle({
            pos = vector.add(pos, offset),
            scale = math.random(0.5,2),
            expirationtime = math.random()*5+1,
            texture = {
                name = "exchangeclone_flame_particle.png",
                scale_tween = {{x=1,y=1},{x=0.2,y=0.2}}
            },
            glow = 14,
            velocity = vector.new((math.random()-0.5)/10, (math.random()-0.5)/10, (math.random()-0.5)/10)
        })
    end
end

core.register_entity("ec_pedestal:item", {
    initial_properties = {
        hp_max = 1,
        pointable = false,
        visual = "wielditem",
        visual_size = {x=0.25,y=0.25,z=0.25},
        wield_item = "air",
        automatic_rotate = 1,
        static_save = false,
    },
    on_activate = function(self, staticdata)
        if staticdata and staticdata ~= "" then
            local split_data = staticdata:split(";")
            self._itemstring = split_data[1]
            if self._itemstring and core.registered_items[self._itemstring] then
                self.object:set_properties({wield_item = split_data[1], is_visible = true})
            else
                self.object:set_properties({is_visible = false})
            end
            self._pedestal_pos = core.string_to_pos(split_data[2])
        end
    end,
    get_staticdata = function(self)
        if self._itemstring and self._pedestal_pos then
            return self._itemstring..";"..core.pos_to_string(self._pedestal_pos)
        else
            return ""
        end
    end
})

exchangeclone.pedestal_offset = {x=0,y=0.4,z=0}

-- Copied from Mineclonia enchanting table book
local function spawn_pedestal_entity(pos, itemstring, respawn)
	if respawn then
		-- Check if we already have an entity
		local objs = core.get_objects_inside_radius(pos, 1)
		for o=1, #objs do
			local obj = objs[o]
			local lua = obj:get_luaentity()
			if lua and lua.name == "ec_pedestal:item" then
				if lua._pedestal_pos and vector.equals(pos, lua._pedestal_pos) then
                    return
				end
			end
		end
	end
	core.add_entity(vector.add(pos, exchangeclone.pedestal_offset), "ec_pedestal:item", (itemstring or "")..";"..core.pos_to_string(pos))
end

local function update_pedestal_entity(pos)
    local objs = core.get_objects_inside_radius(pos, 1)
    local stack = core.get_meta(pos):get_inventory():get_stack("main", 1)
    local itemstring
    if stack:is_known() then
        itemstring = stack:get_name()
    end
    if itemstring == "" then
        itemstring = nil
    end
    local found
    for o=1, #objs do
        local obj = objs[o]
        local lua = obj:get_luaentity()
        if lua and lua.name == "ec_pedestal:item" then
            if lua._pedestal_pos and vector.equals(pos, lua._pedestal_pos) then
                found = true
                if itemstring then
                    lua._itemstring = itemstring
                    obj:set_properties({wield_item = itemstring, is_visible = true})
                else
                    obj:set_properties({is_visible = false})
                end
                break
            end
        end
    end
    if not found then
        spawn_pedestal_entity(pos, itemstring)
    end
end

core.register_lbm({
	label = "(Re-)spawn item entity above DM pedestal",
	name = "ec_pedestal:spawn_pedestal_entity",
	nodenames = {"ec_pedestal:dark_matter_pedestal"},
	run_at_every_load = true,
	action = update_pedestal_entity
})

local function pedestal_action(pos)
    local meta = core.get_meta(pos)
    local inv = meta:get_inventory()
    local stack = inv:get_stack("main", 1)
    local def = stack:get_definition() --[[@as core.ItemDef]]
    local func = def._exchangeclone_pedestal
    add_particles(pos)
    if func then
        inv:set_stack("main", 1, func(pos, stack) or stack)
        update_pedestal_entity(pos)
        local new_stack = inv:get_stack("main", 1)
        if new_stack:is_known() and new_stack:get_definition()._exchangeclone_pedestal then
            return true
        end
    end
end

core.register_node("ec_pedestal:dark_matter_pedestal", {
    description = "Dark Matter Pedestal",
    drawtype = "nodebox",
    tiles = {"exchangeclone_dark_matter_block.png"},
    node_box = {
        type = "fixed",
        fixed = {
            {-0.3125, -0.5000, -0.3125, 0.3125, -0.3750, 0.3125},
            {-0.1250, -0.3750, -0.1250, 0.1250, 0.06250, 0.1250},
            {-0.1875, 0.06250, -0.1875, 0.1875, 0.1250, 0.1875}
        }
    },
    on_punch = function(pos, node, player, pointed_thing)
        if core.is_protected(pos, player:get_player_name()) then
            core.record_protection_violation(pos, player:get_player_name())
        end
        local wielded_item = player:get_wielded_item()
        local meta = core.get_meta(pos)
        local inv = meta:get_inventory()
        if not inv:is_empty("main") and wielded_item:is_empty() then
            core.add_item(vector.add(pos, exchangeclone.pedestal_offset), inv:get_stack("main", 1))
            inv:set_stack("main", 1, ItemStack(""))
            update_pedestal_entity(pos)
            if core.get_node_timer(pos):is_started() then
                core.sound_play("exchangeclone_charge_down", {pos = pos, max_hear_distance = 20})
                core.get_node_timer(pos):stop()
            end
        end
    end,
    on_rightclick = function(pos, node, player, pointed_thing)
        if core.is_protected(pos, player:get_player_name()) then
            core.record_protection_violation(pos, player:get_player_name())
        end
        local wielded_item = player:get_wielded_item()
        local meta = core.get_meta(pos)
        local inv = meta:get_inventory()
        if not inv:is_empty("main") then
            local stack = inv:get_stack("main", 1)
            local pedestal_data = stack:get_definition()._exchangeclone_pedestal
            if pedestal_data then
                if core.get_node_timer(pos):is_started() then
                    core.sound_play("exchangeclone_charge_down", {pos = pos, max_hear_distance = 20})
                    core.get_node_timer(pos):stop()
                else
                    core.sound_play("exchangeclone_enable", {pos = pos, max_hear_distance = 20})
                    core.get_node_timer(pos):start(1)
                    add_particles(pos)
                end
            end
        elseif inv:is_empty("main") and not wielded_item:is_empty() then
            inv:set_stack("main", 1, wielded_item:take_item())
            update_pedestal_entity(pos)
            if wielded_item:get_count() <= 0 then wielded_item = ItemStack("") end
        end
        return wielded_item
    end,
    on_construct = function(pos)
        local meta = core.get_meta(pos)
        local inv = meta:get_inventory()
        inv:set_size("main", 1)
    end,
    on_timer = pedestal_action,
	is_ground_content = false,
	sounds = exchangeclone.sound_mod.node_sound_stone_defaults(),
	groups = {pickaxey=5, material_stone=1, cracky = 3, building_block = 1, level = exchangeclone.mtg and 4 or 0},
	_mcl_blast_resistance = 1500,
	_mcl_hardness = 12,
    after_dig_node = exchangeclone.drop_after_dig({"main"}),
    on_blast = exchangeclone.on_blast({"main"}),
	after_destruct = function(pos)
		local objs = core.get_objects_inside_radius(pos, 1)
		for o=1, #objs do
			local obj = objs[o]
			local lua = obj:get_luaentity()
			if lua and lua.name == "ec_pedestal:item" then
				if lua._pedestal_pos and vector.equals(pos, lua._pedestal_pos) then
					obj:remove()
				end
			end
		end
	end,
})

core.register_craft({
    output = "ec_pedestal:dark_matter_pedestal",
    recipe = {
        {"ec_matter:red_matter", "ec_matter:dark_matter_block", "ec_matter:red_matter"},
        {"ec_matter:red_matter", "ec_matter:dark_matter_block", "ec_matter:red_matter"},
        {"ec_matter:dark_matter_block", "ec_matter:dark_matter_block", "ec_matter:dark_matter_block"},
    }
})