local shear_cube = function(player, center, distance)
    exchangeclone.play_ability_sound(player)
    local player_pos = player:get_pos()
    local pos = center
    local node_positions = {}
    local player_energy = exchangeclone.get_player_energy(player)
    local energy_cost = 0
    pos.x = exchangeclone.round(pos.x)
    pos.y = math.floor(pos.y) --make sure y is node BELOW player's feet
    pos.z = exchangeclone.round(pos.z)

    for x = pos.x-distance, pos.x+distance do
        if energy_cost + 8 > player_energy then
            break
        end
    for y = pos.y-distance, pos.y+distance do
        if energy_cost + 8 > player_energy then
            break
        end
    for z = pos.z-distance, pos.z+distance do
        if energy_cost + 8 > player_energy then
            break
        end
        local new_pos = {x=x,y=y,z=z}
        local node = minetest.get_node(new_pos) or "air"
        local node_def = minetest.registered_items[node.name]
        if (node_def.groups.shearsy or node_def.groups.shearsy_cobweb) and node.name ~= "mcl_flowers:double_grass_top" then
            if minetest.is_protected(new_pos, player:get_player_name()) then
                minetest.record_protection_violation(new_pos, player:get_player_name())
            else
                energy_cost = energy_cost + 8
                local drops = minetest.get_node_drops(node.name, "exchangeclone:red_matter_shears")
                exchangeclone.drop_items_on_player(new_pos, drops, player)
                minetest.set_node(new_pos, {name = "air"})
            end
        end
    end
    end
    end
    exchangeclone.set_player_energy(player, player_energy - energy_cost)
end

local shears_rightclick = function(itemstack, player, pointed_thing)
    -- Use pointed node's on_rightclick function first, if present
    local click_test = exchangeclone.check_on_rightclick(itemstack, player, pointed_thing)
    if click_test ~= false then
        return click_test
    end

    if player:get_player_control().aux1 then
        if itemstack:get_name():find("dark") then
            return exchangeclone.range_update(itemstack, player, 3)
        else
            return exchangeclone.range_update(itemstack, player, 4)
        end
    end

    if (pointed_thing.type == "node") and pointed_thing.above and not player:get_player_control().sneak  then
        local node = minetest.get_node(pointed_thing.under)
        if node.name == "mcl_farming:pumpkin" and (pointed_thing.above.y ~= pointed_thing.under.y) then
            minetest.sound_play({name="default_grass_footstep", gain=1}, {pos = pointed_thing.above}, true)
            local dir = vector.subtract(pointed_thing.under, pointed_thing.above)
            local param2 = minetest.dir_to_facedir(dir)
            minetest.set_node(pointed_thing.under, {name="mcl_farming:pumpkin_face", param2 = param2})
            minetest.add_item(pointed_thing.above, "mcl_farming:pumpkin_seeds 4")
        end
    end

    local center = player:get_pos()

    if (pointed_thing.type == "node") and pointed_thing.under then
        center = pointed_thing.under
    end
    local range = tonumber(itemstack:get_meta():get_int("exchangeclone_item_range"))
    shear_cube(player, center, range)
    return itemstack
end

minetest.register_tool("exchangeclone:dark_matter_shears", {
    description = "Dark Matter Shears",
    wield_image = "exchangeclone_dark_matter_shears.png",
    inventory_image = "exchangeclone_dark_matter_shears.png",
    stack_max = 1,
    groups = { tool=1, shears=1, dig_speed_class=7, },
    tool_capabilities = {
            full_punch_interval = 0.4,
            max_drop_level=1,
            damage_groups = { fleshy = 2, },
    },
    on_place = shears_rightclick,
    on_secondary_use = shears_rightclick,
    sound = { breaks = "default_tool_breaks" },
    _mcl_toollike_wield = true,
    _mcl_diggroups = {
        shearsy = { speed = 5, level = 2, uses = 0 },
        shearsy_wool = { speed = 10, level = 2, uses = 0 },
        shearsy_cobweb = { speed = 30, level = 2, uses = 0 }
    },
})

minetest.register_tool("exchangeclone:red_matter_shears", {
    description = "Red Matter Shears",
    wield_image = "exchangeclone_red_matter_shears.png",
    inventory_image = "exchangeclone_red_matter_shears.png",
    stack_max = 1,
    groups = { tool=1, shears=1, dig_speed_class=8, },
    tool_capabilities = {
            full_punch_interval = 0.3,
            max_drop_level=1,
            damage_groups = { fleshy = 4, },
    },
    on_place = shears_rightclick,
    on_secondary_use = shears_rightclick,
    sound = { breaks = "default_tool_breaks" },
    _mcl_toollike_wield = true,
    _mcl_diggroups = {
        shearsy = { speed = 8, level = 3, uses = 0 },
        shearsy_wool = { speed = 14, level = 3, uses = 0 },
        shearsy_cobweb = { speed = 34, level = 3, uses = 0 }
    },
})

local colors = {
    -- group = { wool, textures }
    unicolor_white = { "mcl_wool:white", "#FFFFFF00" },
    unicolor_dark_orange = { "mcl_wool:brown", "#502A00D0" },
    unicolor_grey = { "mcl_wool:silver", "#5B5B5BD0" },
    unicolor_darkgrey = { "mcl_wool:grey", "#303030D0" },
    unicolor_blue = { "mcl_wool:blue", "#0000CCD0" },
    unicolor_dark_green = { "mcl_wool:green", "#005000D0" },
    unicolor_green = { "mcl_wool:lime", "#50CC00D0" },
    unicolor_violet = { "mcl_wool:purple" , "#5000CCD0" },
    unicolor_light_red = { "mcl_wool:pink", "#FF5050D0" },
    unicolor_yellow = { "mcl_wool:yellow", "#CCCC00D0" },
    unicolor_orange = { "mcl_wool:orange", "#CC5000D0" },
    unicolor_red = { "mcl_wool:red", "#CC0000D0" },
    unicolor_cyan  = { "mcl_wool:cyan", "#00CCCCD0" },
    unicolor_red_violet = { "mcl_wool:magenta", "#CC0050D0" },
    unicolor_black = { "mcl_wool:black", "#000000D0" },
    unicolor_light_blue = { "mcl_wool:light_blue", "#5050FFD0" },
}
local gotten_texture = { "blank.png", "mobs_mc_sheep.png" }

local old_sheep_function = minetest.registered_entities["mobs_mc:sheep"].on_rightclick
minetest.registered_entities["mobs_mc:sheep"].on_rightclick = function(self, clicker)
    local item = clicker:get_wielded_item()
    if (item:get_name() == "exchangeclone:dark_matter_shears" or item:get_name() == "exchangeclone:red_matter_shears")
    and not self.gotten and not self.child then
        local pos = self.object:get_pos()

        local chance = 30 --percent
        if item:get_name() == "exchangeclone:red_matter_shears" then chance = 60 end
        if math.random(1, 100) <= chance then
            local new_sheep = minetest.add_entity(pos, "mobs_mc:sheep"):get_luaentity() --clone the sheep
            for attribute, value in pairs(self) do
                if attribute ~= "object" then
                    new_sheep[attribute] = value
                end
            end
            new_sheep.object:set_properties({
                nametag = self.nametag,
                textures = self.base_texture
            })
        end
        self.gotten = true
        minetest.sound_play("mcl_tools_shears_cut", {pos = pos}, true)
        pos = clicker:get_pos() --drop directly on player
        if not self.color then
            self.color = "unicolor_white"
        end
        local max_wool = 8
        if item:get_name() == "exchangeclone:red_matter_shears" then max_wool = 12 end
        minetest.add_item(pos, ItemStack(colors[self.color][1].." "..math.random(1,max_wool))) --normally 3

        self.base_texture = gotten_texture
        self.object:set_properties({
            textures = self.base_texture,
        })
        self.drops = {
            {name = "mcl_mobitems:mutton",
            chance = 1,
            min = 1,
            max = 2,},
        }

        return
    else
        old_sheep_function(self, clicker)
    end
end

local old_mooshroom_function = minetest.registered_entities["mobs_mc:mooshroom"].on_rightclick
minetest.registered_entities["mobs_mc:mooshroom"].on_rightclick = function(self, clicker)if self:feed_tame(clicker, 1, true, false) then return end
    if mcl_mobs:protect(self, clicker) then return end

    if self.child then
        return
    end
    local item = clicker:get_wielded_item()
    -- Use shears to get mushrooms and turn mooshroom into cow
    if item:get_name() == "exchangeclone:dark_matter_shears" or item:get_name() == "exchangeclone:red_matter_shears" then
        local pos = self.object:get_pos()
        local player_pos = clicker:get_pos()
        minetest.sound_play("mcl_tools_shears_cut", {pos = pos}, true)
        local amount = 8
        if item:get_name() == "exchangeclone:red_matter_shears" then
            amount = 12
        end
        if self.base_texture[1] == "mobs_mc_mooshroom_brown.png" then
            minetest.add_item(player_pos, "mcl_mushrooms:mushroom_brown "..amount)
        else
            minetest.add_item(player_pos, "mcl_mushrooms:mushroom_red "..amount)
        end

        local chance = 30 --percent
        if item:get_name() == "exchangeclone:red_matter_shears" then chance = 60 end
        if math.random(1, 100) <= chance then
            local new_mooshroom = minetest.add_entity(pos, "mobs_mc:mooshroom"):get_luaentity() --clone the mooshroom
            for attribute, value in pairs(self) do
                if attribute ~= "object" then
                    new_mooshroom[attribute] = value
                end
            end
            new_mooshroom.object:set_properties({
                nametag = self.nametag,
                textures = self.base_texture
            })
        end

        local oldyaw = self.object:get_yaw()
        self.object:remove()
        local cow = minetest.add_entity(pos, "mobs_mc:cow")
        cow:set_yaw(oldyaw)
    else
        old_mooshroom_function(self, clicker)
    end
end

local old_honey_harvest = minetest.registered_items["mcl_beehives:bee_nest_5"].on_rightclick
for _, itemstring in ipairs({"mcl_beehives:bee_nest_5", "mcl_beehives:beehive_5"}) do
    minetest.registered_items[itemstring].on_rightclick = function(pos, node, player, itemstack, pointed_thing)
        local inv = player:get_inventory()
        local shears = player:get_wielded_item():get_name() == "exchangeclone:dark_matter_shears" 
                    or player:get_wielded_item():get_name() == "exchangeclone:red_matter_shears"
        local beehive = "mcl_beehives:beehive"
        local campfire_area = vector.offset(pos, 0, -5, 0)
        local campfire = minetest.find_nodes_in_area(pos, campfire_area, "group:lit_campfire")

        if node.name == "mcl_beehives:beehive_5" then
            beehive = "mcl_beehives:beehive"
        elseif node.name == "mcl_beehives:bee_nest_5" then
            beehive = "mcl_beehives:bee_nest"
        end
        if shears then
            minetest.add_item(pos, "mcl_honey:honeycomb 3")
            node.name = beehive
            minetest.set_node(pos, node)
            if not campfire[1] then mcl_util.deal_damage(player, 3) end --significantly less damage
        else
            old_honey_harvest()
        end
    end

    local old_dispenser_function = minetest.registered_items["mcl_dispensers:dispenser"].mesecons.effector.action_on
    local new_dispenser_function = function(pos, node)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        local droppos, dropdir
        if node.name == "mcl_dispensers:dispenser" then
            dropdir = vector.multiply(minetest.facedir_to_dir(node.param2), -1)
            droppos = vector.add(pos, dropdir)
        elseif node.name == "mcl_dispensers:dispenser_up" then
            dropdir = {x=0, y=1, z=0}
            droppos  = {x=pos.x, y=pos.y+1, z=pos.z}
        elseif node.name == "mcl_dispensers:dispenser_down" then
            dropdir = {x=0, y=-1, z=0}
            droppos  = {x=pos.x, y=pos.y-1, z=pos.z}
        end
        local dropnode = minetest.get_node(droppos)
        local dropnodedef = minetest.registered_nodes[dropnode.name]
        local stacks = {}
        for i=1,inv:get_size("main") do
            local stack = inv:get_stack("main", i)
            if not stack:is_empty() then
                table.insert(stacks, {stack = stack, stackpos = i})
            end
        end
        if #stacks >= 1 then
            local r = math.random(1, #stacks)
            local stack = stacks[r].stack
            local dropitem = ItemStack(stack)
            dropitem:set_count(1)
            local stack_id = stacks[r].stackpos
            local stackdef = stack:get_definition()

            if not stackdef then
                return
            end

            local iname = stack:get_name()
            local igroups = stackdef.groups

            if iname == "exchangeclone:dark_matter_shears" or iname == "exchangeclone:red_matter_shears" then
                for _, obj in pairs(minetest.get_objects_inside_radius(droppos, 1)) do
                    local entity = obj:get_luaentity()
                    if entity and not entity.child and not entity.gotten then
                        local entname = entity.name
                        local pos = obj:get_pos()
                        local used = false
                        local texture
                        if entname == "mobs_mc:sheep" then
                            local max_wool = 8
                            if iname == "exchangeclone:red_matter_shears" then max_wool = 12 end
                            minetest.add_item(pos, entity.drops[2].name.." "..math.random(1,max_wool)) --normally 3
                            if not entity.color then
                                entity.color = "unicolor_white"
                            end
                            local chance = 30 --percent
                            if iname == "exchangeclone:red_matter_shears" then chance = 60 end
                            if math.random(1, 100) <= chance then
                                local new_sheep = minetest.add_entity(pos, "mobs_mc:sheep"):get_luaentity() --clone the sheep
                                for attribute, value in pairs(entity) do
                                    if attribute ~= "object" then
                                        new_sheep[attribute] = value
                                    end
                                end
                                new_sheep.object:set_properties({
                                    nametag = entity.nametag,
                                    textures = entity.base_texture
                                })
                            end
                            entity.base_texture = { "blank.png", "mobs_mc_sheep.png" }
                            texture = entity.base_texture
                            entity.drops = {
                                { name = "mcl_mobitems:mutton", chance = 1, min = 1, max = 2 },
                            }
                            used = true
                        elseif entname == "mobs_mc:snowman" then
                            texture = {
                                "mobs_mc_snowman.png",
                                "blank.png", "blank.png",
                                "blank.png", "blank.png",
                                "blank.png", "blank.png",
                            }
                            used = true
                        elseif entname == "mobs_mc:mooshroom" then
                            local amount = 8
                            if iname == "exchangeclone:red_matter_shears" then
                                amount = 12
                            end
                            if entity.base_texture[1] == "mobs_mc_mooshroom_brown.png" then
                                minetest.add_item(droppos, "mcl_mushrooms:mushroom_brown "..amount)
                            else
                                minetest.add_item(droppos, "mcl_mushrooms:mushroom_red "..amount)
                            end

                            local chance = 30 --percent
                            if iname == "exchangeclone:red_matter_shears" then chance = 60 end
                            if math.random(1, 100) <= chance then
                                local new_mooshroom = minetest.add_entity(pos, "mobs_mc:mooshroom"):get_luaentity() --clone the mooshroom
                                for attribute, value in pairs(entity) do
                                    if attribute ~= "object" then
                                        new_mooshroom[attribute] = value
                                    end
                                end
                                new_mooshroom.object:set_properties({
                                    nametag = entity.nametag,
                                    textures = entity.base_texture
                                })
                            end

                            obj = mcl_util.replace_mob(obj, "mobs_mc:cow")
                            entity = obj:get_luaentity()
                            used = true
                        end
                        if used then
                            obj:set_properties({ textures = texture })
                            entity.gotten = true
                            minetest.sound_play("mcl_tools_shears_cut", { pos = pos }, true)
                            inv:set_stack("main", stack_id, stack)
                            break
                        end
                    end
                end
            end
        else
            old_dispenser_function(pos, node)
        end
    end
    for _, itemstring in ipairs({"mcl_dispensers:dispenser", "mcl_dispensers:dispenser_up", "mcl_dispensers:dispenser_down"}) do
        minetest.registered_items[itemstring].mesecons.effector.action_on = new_dispenser_function
    end
end

local gotten_texture = {
    "mobs_mc_snowman.png",
    "blank.png",
    "blank.png",
    "blank.png",
    "blank.png",
    "blank.png",
    "blank.png",
}

local old_snowman_function = minetest.registered_entities["mobs_mc:snowman"].on_rightclick
minetest.registered_entities["mobs_mc:snowman"].on_rightclick = function(self, clicker)
    local item = clicker:get_wielded_item()
    if self.gotten ~= true and (item:get_name() == "exchangeclone:dark_matter_shears" or item:get_name() == "exchangeclone:red_matter_shears") then
        -- Remove pumpkin
        self.gotten = true
        self.object:set_properties({
            textures = gotten_texture,
        })

        local pos = self.object:get_pos()
        minetest.sound_play("mcl_tools_shears_cut", {pos = pos}, true)

        if minetest.registered_items["mcl_farming:pumpkin_face"] then
            minetest.add_item({x=pos.x, y=pos.y+1.4, z=pos.z}, "mcl_farming:pumpkin_face")
        end
    else
        old_snowman_function(self, clicker)
    end
end

minetest.register_craft({
    output = "exchangeclone:dark_matter_shears",
    recipe = {
        {"", "exchangeclone:dark_matter"},
        {exchangeclone.diamond_itemstring, ""},
    }
})

minetest.register_craft({
    output = "exchangeclone:red_matter_shears",
    recipe = {
        {"", "exchangeclone:red_matter"},
        {"exchangeclone:dark_matter_shears", ""},
    }
})