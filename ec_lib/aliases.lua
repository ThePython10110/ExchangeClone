exchangeclone.emc_aliases = {}

---<itemstring> will be treated as <alias> in EMC Links and Transmutation Table(t)s.
---When you put <itemstring> into a TT, you will learn <alias> instead.
---Maybe it should be reversed, but this is how I made it.
---@param alias string
---@param itemstring string
function exchangeclone.register_alias_force(alias, itemstring)
    if alias == itemstring then return end
    exchangeclone.emc_aliases[itemstring] = alias
end

---Like register_alias_force but only registers the alias if it doesn't already exist.
---@see exchangeclone.register_alias_force
---@param alias string
---@param itemstring string
function exchangeclone.register_alias(alias, itemstring)
    if not exchangeclone.emc_aliases[alias] then
        exchangeclone.register_alias_force(alias, itemstring)
    end
end

---Returns the correct itemstring, handling both Minetest and Exchangeclone aliases.
---@param item core.ItemStack|string
---@return string?
function exchangeclone.handle_alias(item)
    item = ItemStack(item)
    if not item:is_empty() then
        local de_aliased = exchangeclone.emc_aliases[item:get_name()] or item:get_name() -- Resolve ExchangeClone aliases
        return ItemStack(de_aliased):get_name() or item:get_name() -- Resolve MT aliases
    end
end