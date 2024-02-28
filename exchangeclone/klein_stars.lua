local S = minetest.get_translator()

local names = {
    "Klein Star Ein",
    "Klein Star Zwei",
    "Klein Star Drei",
    "Klein Star Vier",
    "Klein Star Sphere",
    "Klein Star Omega",
    "Magnum Star Ein",
    "Magnum Star Zwei",
    "Magnum Star Drei",
    "Magnum Star Vier",
    "Magnum Star Sphere",
    "Magnum Star Omega",
}

minetest.register_alias("exchangeclone:exchange_orb", "exchangeclone:klein_star_omega")

for i, name in ipairs(names) do
    local codified_name = name:lower():gsub(" ", "_")
    local capacity = 50000*math.pow(4,i-1)
    minetest.register_tool("exchangeclone:"..codified_name, {
        description = S(name).."\n"..S("Current Charge: @1/@2", 0, exchangeclone.format_number(capacity)),
        inventory_image = "exchangeclone_"..codified_name..".png",
        wield_image = "exchangeclone_"..codified_name..".png",
        groups = {klein_star = i, disable_repair = 1, fire_immune = 1},
        max_capacity = capacity,
        _mcl_generate_description = function(itemstack)
            return name.."\n"..S(
                "Current Charge: @1/@2",
                exchangeclone.format_number(exchangeclone.get_star_itemstack_emc(itemstack)),
                exchangeclone.format_number(capacity)
            )
        end
    })

    if i > 1 then
        local previous_codified_name = names[i-1]:lower():gsub(" ", "_")
        minetest.register_craft({
            output = "exchangeclone:"..codified_name,
            type = "shapeless",
            recipe = {
                "exchangeclone:"..previous_codified_name,
                "exchangeclone:"..previous_codified_name,
                "exchangeclone:"..previous_codified_name,
                "exchangeclone:"..previous_codified_name,
            }
        })
    end
end

minetest.register_craft({
    output = "exchangeclone:klein_star_ein",
    recipe = {
        {"exchangeclone:mobius_fuel", "exchangeclone:mobius_fuel", "exchangeclone:mobius_fuel"},
        {"exchangeclone:mobius_fuel", exchangeclone.itemstrings.diamond, "exchangeclone:mobius_fuel"},
        {"exchangeclone:mobius_fuel", "exchangeclone:mobius_fuel", "exchangeclone:mobius_fuel"},
    }
})