/*
 * Put plane masters that are just a simple type def in here, anything more complex should get its own file
 */

/atom/movable/screen/plane_master/gravpulse
	name = "Gravpulse"
	documentation = "Ok so this one's fun. Basically, we want to be able to distort the game plane when a grav annom is around.\
		<br>So we draw the pattern we want to use to this plane, and it's then used as a render target by a distortion filter on the game plane.\
		<br>Note the blend mode and lack of relay targets. This plane exists only to distort, it's never rendered anywhere."
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	plane = GRAVITY_PULSE_PLANE
	appearance_flags = PLANE_MASTER|NO_CLIENT_COLOR
	blend_mode = BLEND_ADD
	render_target = GRAVITY_PULSE_RENDER_TARGET
	render_relay_planes = list()

/atom/movable/screen/plane_master/seethrough
	name = "Seethrough"
	documentation = "Holds the seethrough versions (done using image overrides) of large objects. Mouse transparent, so you can click through them."
	plane = SEETHROUGH_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	render_relay_planes = list(RENDER_PLANE_GAME_WORLD)
	start_hidden = TRUE

/atom/movable/screen/plane_master/massive_obj
	name = "Massive object"
	documentation = "Huge objects need to render above everything else on the game plane, otherwise they'd well, get clipped and look not that huge. This does that."
	plane = MASSIVE_OBJ_PLANE

/atom/movable/screen/plane_master/point
	name = "Point"
	documentation = "I mean like, what do you want me to say? Points draw over pretty much everything else, so they get their own plane. Remember we layer render relays to draw planes in their proper order on render plates."
	plane = POINT_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/atom/movable/screen/plane_master/ghost
	name = "Ghost"
	documentation = "Ghosts draw here, so they don't get mixed up in the visuals of the game world. Note, this is not not how we HIDE ghosts from people, that's done with invisible and see_invisible."
	plane = GHOST_PLANE
	render_relay_planes = list(RENDER_PLANE_NON_GAME)

/atom/movable/screen/plane_master/fullscreen
	name = "Fullscreen"
	documentation = "Holds anything that applies to or above the full screen. \
		<br>Note, it's still rendered underneath hud objects, but this lets us control the order that things like death/damage effects render in."
	plane = FULLSCREEN_PLANE
	appearance_flags = PLANE_MASTER|NO_CLIENT_COLOR
	render_relay_planes = list(RENDER_PLANE_NON_GAME)
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	allows_offsetting = FALSE

/atom/movable/screen/plane_master/hud
	name = "HUD"
	documentation = "Contains anything that want to be rendered on the hud. Typically is just screen elements."
	plane = HUD_PLANE
	appearance_flags = PLANE_MASTER|NO_CLIENT_COLOR
	render_relay_planes = list(RENDER_PLANE_NON_GAME)
	allows_offsetting = FALSE

/atom/movable/screen/plane_master/above_hud
	name = "Above HUD"
	documentation = "Anything that wants to be drawn ABOVE the rest of the hud. Typically close buttons and other elements that need to be always visible. Think preventing draggable action button memes."
	plane = ABOVE_HUD_PLANE
	appearance_flags = PLANE_MASTER|NO_CLIENT_COLOR
	render_relay_planes = list(RENDER_PLANE_NON_GAME)
	allows_offsetting = FALSE

/atom/movable/screen/plane_master/splashscreen
	name = "Splashscreen"
	documentation = "Cinematics and the splash screen."
	plane = SPLASHSCREEN_PLANE
	appearance_flags = PLANE_MASTER|NO_CLIENT_COLOR
	render_relay_planes = list(RENDER_PLANE_NON_GAME)
	allows_offsetting = FALSE

/atom/movable/screen/plane_master/escape_menu
	name = "Escape Menu"
	documentation = "Anything relating to the escape menu."
	plane = ESCAPE_MENU_PLANE
	appearance_flags = PLANE_MASTER|NO_CLIENT_COLOR
	render_relay_planes = list(RENDER_PLANE_MASTER)
	allows_offsetting = FALSE
