-- Runs only if the hopper mod is detected. This pretty much makes it so that anything that works with
-- MineClone hoppers will automatically work with other hoppers.

hopper:add_container({
	{"top", "group:container=2", "main"},
	{"bottom", "group:container=2", "main"},
	{"side", "group:container=2", "main"},
})

hopper:add_container({
	{"top", "group:container=3", "main"},
	{"bottom", "group:container=3", "main"},
	{"side", "group:container=3", "main"},
})

-- I assumed "top" meant when it's on top of a node, not when there's a node on top of it. Whoops.
hopper:add_container({
	{"top", "group:container=4", "dst"},
	{"side", "group:container=4", "fuel"},
	{"bottom", "group:container=4", "src"},
})

-- Hoppers will only be able to insert into one side of a double chest, I think (unless you have 1 hopper per side)
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