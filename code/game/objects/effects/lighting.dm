/**
 * Basically, a fake object that emits light.
 *
 * Why is this used sometimes instead of giving atoms light values directly?
 * Because using these, you can have multiple light sources in a single object.
 */
/obj/effect/dummy/lighting_obj
	name = "lighting"
	desc = "Tell a coder if you're seeing this."
	icon_state = "nothing"
	light_system = OVERLAY_LIGHT
	light_range = MINIMUM_USEFUL_LIGHT_RANGE
	light_color = COLOR_WHITE
	blocks_emissive = EMISSIVE_BLOCK_NONE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/dummy/lighting_obj/Initialize(mapload, range, power, color, duration)
	. = ..()
	if(!isnull(range))
		set_light_range(range)
	if(!isnull(power))
		set_light_power(power)
	if(!isnull(color))
		set_light_color(color)
	if(duration)
		QDEL_IN(src, duration)

/obj/effect/dummy/lighting_obj/moblight
	name = "mob lighting"

/obj/effect/dummy/lighting_obj/moblight/Initialize(mapload, range, power, color, duration)
	. = ..()
	if(!ismob(loc))
		return INITIALIZE_HINT_QDEL

/obj/effect/dummy/lighting_obj/moblight/fire
	name = "mob fire lighting"
	light_color = LIGHT_COLOR_FIRE
	light_range = LIGHT_RANGE_FIRE
	light_power = 2

/obj/effect/dummy/lighting_obj/moblight/species
	name = "species lighting"
