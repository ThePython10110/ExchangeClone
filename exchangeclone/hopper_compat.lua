-- Runs only if the hopper mod is detected. This pretty much makes it so that anything that works with
-- MineClone hoppers will automatically work with other hoppers.

hopper:add_container({
	{"top", "group:container=2", "main"},
	{"bottom", "group:container=2", "main"},
	{"side", "group:container=2", "main"},
})

-- Intentionally skipping 3, because I don't know if it would still block shulkers

-- If this doesn't start the node timer for the furnace, it won't work.
hopper:add_container({
	{"top", "group:container=4", "src"},
	{"side", "group:container=4", "fuel"},
	{"bottom", "group:container=4", "dst"},
})

-- Hoppers will only be able to insert into one side of a double chest (unless you have 1 hopper per side)
hopper:add_container({
	{"top", "group:container=5", "main"},
	{"bottom", "group:container=5", "main"},
	{"side", "group:container=5", "main"},
})
hopper:add_container({
	{"top", "group:container=6", "main"},
	{"bottom", "group:container=6", "main"},
	{"side", "group:container=6", "main"},
})