-- Runs only if the hopper mod is detected. This pretty much makes it so that anything that works with
-- VL hoppers will automatically work with other hoppers.

hopper:add_container({
	{"top", "group:container=2", "main"},
	{"bottom", "group:container=2", "main"},
	{"side", "group:container=2", "main"},
})

hopper:add_container({
	{"top", "ec_upgrades:upgrader", "dst"},
	{"side", "ec_upgrades:upgrader", "fuel"},
	{"bottom", "ec_upgrades:upgrader", "src"},
})

hopper:add_container({
	{"top", "group:exchangeclone_furnace", "dst"},
	{"side", "group:exchangeclone_furnace", "fuel"},
	{"bottom", "group:exchangeclone_furnace", "src"},
})

hopper:add_container({
	{"top", "group:energy_collector", "main"},
	{"bottom", "group:energy_collector", "main"},
	{"side", "group:energy_collector", "main"},
})

hopper:add_container({
	{"top", "ec_emc_link:emc_link", "dst"},
	{"bottom", "ec_emc_link:emc_link", "src"},
	{"side", "ec_emc_link:emc_link", "fuel"},
})