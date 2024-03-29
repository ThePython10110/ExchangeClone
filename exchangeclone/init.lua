if not exchangeclone then
	error("Disable and re-enable the ExchangeClone modpack.")
end

local start_time = minetest.get_us_time()
minetest.log("action", "[ExchangeClone] Registering own stuff")

-- Decides what mod to use for sounds
exchangeclone.sound_mod = exchangeclone.mcl and mcl_sounds or default

local modpath = minetest.get_modpath("exchangeclone")

exchangeclone.colors = {}

if exchangeclone.mcl then
    -- I finally found a good place to get color data in both games.
    for unicolor, data in pairs(mcl_banners.colors) do
        if not exchangeclone.colors[data[1]] then
            exchangeclone.colors[data[1]] = {
                name = data[6],
                hex = data[4],
                dye = data[5],
            }
        end
    end
else
	-- color hex values taken from MCLA
	exchangeclone.colors = {
		white = {
			name = "White",
			hex = "#d0d6d7",
			dye = "dye:white",
		},
		grey = {
			name = "Grey",
			hex = "#818177",
			dye = "dye:grey",
		},
		dark_grey = {
			name = "Dark Grey",
			hex = "#383c40",
			dye = "dye:dark_grey",
		},
		black = {
			name = "Black",
			hex = "#080a10",
			dye = "dye:black",
		},
		violet = {
			name = "Violet",
			hex = "#6821a0",
			dye = "dye:violet",
		},
		blue = {
			name = "Blue",
			hex = "#2e3094",
			dye = "dye:blue",
		},
		cyan = {
			name = "Cyan",
			hex = "#167b8c",
			dye = "dye:cyan",
		},
		dark_green = {
			name = "Dark Green",
			hex = "#4b5e25",
			dye = "dye:dark_green",
		},
		green = {
			name = "Green",
			hex = "#60ac19",
			dye = "dye:green",
		},
		yellow = {
			name = "Yellow",
			hex = "#f1b216",
			dye = "dye:yellow",
		},
		brown = {
			name = "Brown",
			hex = "#633d20",
			dye = "dye:brown",
		},
		orange = {
			name = "Orange",
			hex = "#e26501",
			dye = "dye:orange",
		},
		red = {
			name = "Red",
			hex = "#912222",
			dye = "dye:red",
		},
		magenta = {
			name = "Magenta",
			hex = "#ab31a2",
			dye = "dye:magenta",
		},
		pink = {
			name = "Pink",
			hex = "#d56791",
			dye = "dye:pink",
		},
	}
end

if exchangeclone.mcl2 then
	mcl_item_id.set_mod_namespace("exchangeclone")
end
local files = {
	"constructor",
	"deconstructor",
	"energy_collector",
	"klein_stars",
	"craftitems",
	"tool_upgrades",
	"swords",
	"pickaxes",
	"axes",
	"shovels",
	"hoes",
	"hammers",
	"red_matter_multitools",
	"covalence_dust",
	"philosophers_stone",
	"infinite_food",
	"alchemical_chests",
	"transmutation_table",
	"furnaces",
	"gem_of_eternal_density",
	"talisman_of_repair",
	"passive_stones",
}

if exchangeclone.mcl or minetest.get_modpath("3d_armor") then
	dofile(modpath.."/armor.lua")
end

if exchangeclone.mcl then
	dofile(modpath.."/shears.lua")
	dofile(modpath.."/tool_upgrades.lua")
end

if minetest.get_modpath("hopper") then
	dofile(modpath.."/hopper_compat.lua")
end

if minetest.get_modpath("awards") then
	dofile(modpath.."/awards.lua")
end

for _, file in ipairs(files) do
	dofile(modpath.."/"..file..".lua")
end

minetest.register_on_mods_loaded(function()
	local emc_start_time = minetest.get_us_time()
	minetest.log("action", "[ExchangeClone] Registering EMC values")
	dofile(modpath.."/register_emc.lua")
	minetest.log("action", "[ExchangeClone] Done registering EMC values ("..((minetest.get_us_time() - emc_start_time)/1000000).." seconds)")
end)

minetest.log("action", "[ExchangeClone] Done ("..((minetest.get_us_time() - start_time)/1000).." milliseconds)")