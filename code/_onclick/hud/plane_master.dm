/obj/screen/plane_master
	screen_loc = "CENTER"
	icon_state = "blank"
	appearance_flags = PLANE_MASTER|NO_CLIENT_COLOR
	blend_mode = BLEND_OVERLAY

///obj/screen/plane_master/Initialize()
	// Yes because of course it's automatically implied that if a plane master uses blend multiply it ALWAYS needs a backdrop.
	// Jesus christ this is 2012 SVN tier retardedness get your shit together TG.
	/*
	if(blend_mode == BLEND_MULTIPLY)
		//What is this? Read http://www.byond.com/forum/?post=2141928
		var/image/backdrop = image('icons/mob/screen_gen.dmi', "black")
		backdrop.transform = matrix(200, 0, 0, 0, 200, 0)
		backdrop.layer = BACKGROUND_LAYER
		backdrop.blend_mode = BLEND_OVERLAY
		add_overlay(backdrop)
	*/
//	..()

//Why do plane masters need a backdrop sometimes? Read http://www.byond.com/forum/?post=2141928
//Trust me, you need one. Period. If you don't think you do, you're doing something extremely wrong.
/obj/screen/plane_master/proc/backdrop(mob/mymob)
  return

/obj/screen/plane_master/game_world
	name = "game world plane master"
	plane = GAME_PLANE
	blend_mode = BLEND_OVERLAY

/obj/screen/plane_master/lighting
	name = "lighting plane master"
	plane = LIGHTING_PLANE
	blend_mode = BLEND_MULTIPLY
	mouse_opacity = 0

/obj/screen/plane_master/lighting/proc/params2color(params)
	color = params2list(params)
/obj/screen/plane_master/lighting/proc/basecolor()
	color = LIGHTING_BASE_MATRIX

/obj/screen/plane_master/parallax
	name = "parallax plane master"
	plane = PLANE_SPACE_PARALLAX
	blend_mode = BLEND_MULTIPLY
	mouse_opacity = FALSE

/obj/screen/plane_master/parallax_white
	name = "parallax whitifier plane master"
	plane = PLANE_SPACE
	color = list(
		0, 0, 0, 0,
		0, 0, 0, 0,
		0, 0, 0, 0,
		1, 1, 1, 1,
		0, 0, 0, 0
		)

/obj/screen/plane_master/lighting/backdrop(mob/mymob)
	mymob.overlay_fullscreen("lighting_backdrop_lit", /obj/screen/fullscreen/lighting_backdrop/lit)
	mymob.overlay_fullscreen("lighting_backdrop_unlit", /obj/screen/fullscreen/lighting_backdrop/unlit)
