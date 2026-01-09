if not exchangeclone then
	error("The 'zzzz_exchangeclone_init' mod failed to load correctly. Try disabling and re-enabling the modpack.")
end

-- Decides what mod to use for sounds
exchangeclone.sound_mod = exchangeclone.mcl and mcl_sounds or default

local modpath = core.get_modpath("exchangeclone")

exchangeclone.colors = {}

if exchangeclone.mcl2 then
    for unicolor, data in pairs(mcl_banners.colors) do
        if not exchangeclone.colors[data[1]] then
            exchangeclone.colors[data[1]] = {
                name = data[6],
                hex = data[4],
                dye = data[5],
            }
        end
    end
elseif exchangeclone.mcla then
    for unicolor, data in pairs(mcl_banners.colors) do
        if not exchangeclone.colors[data.color_key] then
            exchangeclone.colors[data.color_key] = {
                name = data.color_name,
                hex = data.rgb,
                dye = data.color_key,
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
	exchangeclone.colors.purple = exchangeclone.colors.violet
	exchangeclone.colors.lime = exchangeclone.colors.green
end

if exchangeclone.mcl2 then
	mcl_item_id.set_mod_namespace("exchangeclone")
end


local modpath = core.get_modpath(core.get_current_modname())

local files = {
	"deprecated_stuff",
	"craftitems",
	"commands",
	"hud",
	-- used to be a lot more here before I split it into separate mods
}

if core.get_modpath("hopper") then
	dofile(modpath.."/hopper_compat.lua")
end

if core.get_modpath("awards") then
	dofile(modpath.."/awards.lua")
end

for _, file in ipairs(files) do
	dofile(modpath.."/"..file..".lua")
end

core.register_on_mods_loaded(function()
	local emc_start_time = core.get_us_time()
	core.log("action", "[ExchangeClone] Registering EMC values")
	dofile(modpath.."/register_emc.lua")
	core.log("action", "[ExchangeClone] Done registering EMC values ("..((core.get_us_time() - emc_start_time)/1000000).." seconds)")
end)