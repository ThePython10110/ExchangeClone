--Personal Energy Storage Accessor (PESA)

local formspec
if not exchangeclone.mcl then
    formspec = {
        "size[8,9]",
        "label[0.5,0.5;Personal Energy Storage Accessor (PESA)]",
        "list[current_player;exchangeclone_pesa;4,2;1,1;]",
        "list[current_player;main;0,5;8,4;]",
        "listring[current_player;main]",
        "listring[current_player;exchangeclone_pesa]"
    }
else
    formspec = {
        "size[9,10]",
        "label[0.5,0.5;Personal Energy Storage Accessor (PESA)]",
        "list[current_player;exchangeclone_pesa;4,2;1,1;]",
        mcl_formspec.get_itemslot_bg(4,2,1,1),
        "list[current_player;main;0,5;9,3;9]",
        mcl_formspec.get_itemslot_bg(0,5,9,3),
        "list[current_player;main;0,8.5;9,1;]",
        mcl_formspec.get_itemslot_bg(0,8.5,9,1),
        "listring[current_player;main]",
        "listring[current_player;exchangeclone_pesa]"
    }
end
formspec = table.concat(formspec, "")

local function on_rightclick(itemstack, player, pointed_thing)
    local click_test = exchangeclone.check_on_rightclick(itemstack, player, pointed_thing)
    if click_test ~= false then
        return click_test
    end
    minetest.show_formspec(player:get_player_name(), "exchangeclone_pesa", formspec)
end

minetest.register_tool("exchangeclone:pesa", {
    description = "Personal Energy Storage Accessor (PESA)",
    wield_image = "exchangeclone_pesa.png",
    inventory_image = "exchangeclone_pesa.png",
    on_secondary_use = on_rightclick,
    on_place = on_rightclick,
})

minetest.register_on_joinplayer(function(player)
    player:get_inventory():set_size("exchangeclone_pesa", 1)
end)

minetest.register_allow_player_inventory_action(function(player, action, inv, info)
	if inv:get_location().type == "player" and (
		   action == "move" and (info.from_list == "exchangeclone_pesa" or info.to_list == "exchangeclone_pesa")
		or action == "put"  and  info.listname  == "exchangeclone_pesa"
		or action == "take" and  info.listname  == "exchangeclone_pesa"
	) then
		if player:get_wielded_item():get_name() == "exchangeclone:pesa" then
            local stack
			if info.listname or (info.from_list and info.from_list == "exchangeclone_pesa") then
                stack = player:get_inventory():get_stack("exchangeclone_pesa", info.from_index)
            else
                stack = player:get_inventory():get_stack("main", info.from_index)
            end
            if stack:get_name() == "exchangeclone:exchange_orb" or action == "take" then
                return stack:get_count()
            else
                return 0
            end
        end
	end
end)

local chest_itemstring = "default:chest"
if exchangeclone.mcl then
    chest_itemstring = "mcl_chests:chest"
end

minetest.register_craft({
    output = "exchangeclone:pesa",
    type = "shapeless",
    recipe = {
        "exchangeclone:philosophers_stone",
        chest_itemstring
    },
    replacements = {{"exchangeclone:philosophers_stone", "exchangeclone:philosophers_stone"}}
})