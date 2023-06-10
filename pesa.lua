--Personal Energy Storage Accessor (PESA)

local formspec
if not exchangeclone.mineclone then
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

local function on_rightclick(itemstack, user, pointed_thing)
    if pointed_thing.type == "node" then
        -- Use pointed node's on_rightclick function first, if present
        local node = minetest.get_node(pointed_thing.under)
        if user and not user:get_player_control().sneak then
            if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
                return minetest.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, user, itemstack) or itemstack
            end
        end
    end
    minetest.show_formspec(user:get_player_name(), "exchangeclone_pesa", formspec)
end

minetest.register_tool("exchangeclone:pesa", {
    description = "Personal Energy Storage Accessor (PESA)",
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
			local stack = player:get_inventory():get_stack(info.from_list, info.from_index)
            if action == "take" then
                return stack:get_count()
            end
            if stack:get_name() == "exchangeclone:exchange_orb" then
                return stack:get_count()
            else
                return 0
            end
        end
	end
end)

function exchangeclone.get_player_energy(player)
    return exchangeclone.get_orb_energy(player:get_inventory(), "exchangeclone_pesa", 1)
end

function exchangeclone.set_player_energy(player, amount)
    exchangeclone.set_orb_energy(player:get_inventory(), "exchangeclone_pesa", 1, amount)
end