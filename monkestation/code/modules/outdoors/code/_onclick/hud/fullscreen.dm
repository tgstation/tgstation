
/* Our sunlight planemaster mashes all of our sunlight overlays together into one             */
/* The fullscreen then grabs the plane_master with a layer filter, and colours it             */
/* We do this so the sunlight fullscreen acts as a big lighting object, in our lighting plane */
/atom/movable/screen/fullscreen/lighting_backdrop/sunlight
	icon_state  = ""
	screen_loc = "CENTER"
	transform = null
	plane = LIGHTING_PLANE
	blend_mode = BLEND_ADD
	show_when_dead = TRUE
	needs_offsetting = FALSE

/atom/movable/screen/fullscreen/lighting_backdrop/sunlight/Initialize()
	. = ..()
	SSoutdoor_effects.sunlighting_planes |= src
	color = SSoutdoor_effects.last_color
	SSoutdoor_effects.transition_sunlight_color(src)

/atom/movable/screen/fullscreen/lighting_backdrop/sunlight/Destroy()
	. = ..()
	SSoutdoor_effects.sunlighting_planes -= src
