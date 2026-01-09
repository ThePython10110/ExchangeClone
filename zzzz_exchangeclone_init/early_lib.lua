--Basically just functions that should be loaded early


---Adds a loop of transmutations
---@param itemstrings string[]
function exchangeclone.add_transmutation_loop(itemstrings)
    for i, itemstring in ipairs(itemstrings) do
        exchangeclone.node_transmutations[1][itemstring] = itemstrings[i+1] or itemstrings[1]
        exchangeclone.node_transmutations[2][itemstring] = itemstrings[i-1] or itemstrings[#itemstrings]
    end
end

--[[
Recipes are registered with the same format that they are in core.register_craft:
{
    type = <type>
    recipe = <recipe>
    output = <itemstring>
    replacements = {{<itemstring>, <replace_itemstring>}, {<itemstring>, <replace_itemstring>}}
}

You do NOT have to call exchangeclone.register_craft if you use core.register_craft.


name (string): The name of the crafting type.
recipe_type (string): One of the following:
    shaped (default): Recipe is given in an array of arrays of ingredients.
    shapeless: Recipe is given as a array of ingredients
    cooking: Recipe is a single item
reverse (bool): Only applies for "cooking" recipe_type. If set to true, all recipes of this
                type will be registered twice: once normally, and once with the recipe and output swapped.
]]

exchangeclone.craft_types = {}

---Registers a craft type
---@param name string
---@param recipe_type string
---@param reverse boolean?
function exchangeclone.register_craft_type(name, recipe_type, reverse)
    exchangeclone.craft_types[name] = {type = recipe_type, reverse = reverse}
end

---Registers a crafting recipe
---@param data table
function exchangeclone.register_craft(data)
    if not data.output then return end
    local itemstring = ItemStack(data.output):get_name()
    exchangeclone.recipes[itemstring] = exchangeclone.recipes[itemstring] or {}
    table.insert(exchangeclone.recipes[itemstring], table.copy(data))
    -- Should reversed recipe be registered too?
    if data.type then
        local type_data = exchangeclone.craft_types[data.type]
        if type_data.type == "cooking" and type_data.reverse then
            local flipped_data = table.copy(data)
            flipped_data.output, flipped_data.recipe = flipped_data.recipe, flipped_data.output
            local flipped_output = ItemStack(flipped_data.output):get_name()
            exchangeclone.recipes[flipped_output] = exchangeclone.recipes[flipped_output] or {}
            table.insert(exchangeclone.recipes[flipped_output], table.copy(flipped_data))
        end
    end
end