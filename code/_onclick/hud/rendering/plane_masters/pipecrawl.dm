/atom/movable/screen/plane_master/pipecrawl
	name = "Pipecrawl"
	documentation = "Holds pipecrawl images generated during well, pipecrawling.\
		<br>Has a few effects and a funky color matrix designed to make things a bit more visually readable."
	plane = PIPECRAWL_IMAGES_PLANE
	start_hidden = TRUE

/atom/movable/screen/plane_master/pipecrawl/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	// Makes everything on this plane slightly brighter
	// Has a nice effect, makes thing stand out
	color = list(1.2,0,0,0, 0,1.2,0,0, 0,0,1.2,0, 0,0,0,1, 0,0,0,0)
	// This serves a similar purpose, I want the pipes to pop
	add_filter("pipe_dropshadow", 1, drop_shadow_filter(x = -1, y= -1, size = 1, color = "#0000007A"))
	mirror_parent_hidden()
