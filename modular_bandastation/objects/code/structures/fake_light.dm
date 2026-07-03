#define LIGHT_EMERGENCY 4
#define LIGHT_PURPLE 5

// MARK: Base
/obj/structure/light_fake
	name = "light fixture"
	desc = "A lighting fixture."
	icon = 'modular_bandastation/objects/icons/obj/structures/light.dmi'
	icon_state = "tube"
	anchored = TRUE
	layer = WALL_OBJ_LAYER
	light_color = "#FFF7F2"
	light_power = 0.8
	light_range = 8
	light_angle = 170
	/// Base icon_state for variants
	var/base_state = "tube"
	/// Current status (LIGHT_OK, LIGHT_BROKEN, LIGHT_BURNED, LIGHT_EMERGENCY, LIGHT_PURPLE)
	var/status = LIGHT_OK
	/// Overlay icon file
	var/overlay_icon = 'modular_bandastation/aesthetics/lights/icons/lighting_overlay.dmi'

/obj/structure/light_fake/broken
	icon_state = "tube-broken"
	light_on = FALSE
	status = LIGHT_BROKEN

/obj/structure/light_fake/burned
	icon_state = "tube-burned"
	light_on = FALSE
	status = LIGHT_BURNED

/obj/structure/light_fake/emergency
	icon_state = "tube_emergency"
	light_color = "#FF4E4E"
	light_range = 6
	status = LIGHT_EMERGENCY

/obj/structure/light_fake/purple
	icon_state = "tube2"
	light_color = "#A700FF"
	status = LIGHT_PURPLE

// MARK: Small
/obj/structure/light_fake/small
	name = "light fixture"
	desc = "A small lighting fixture."
	icon_state = "bulb"
	base_state = "bulb"
	light_color = "#FFD6AA"
	light_range = 4

/obj/structure/light_fake/small/broken
	icon_state = "bulb-broken"
	light_on = FALSE
	status = LIGHT_BROKEN

/obj/structure/light_fake/small/burned
	icon_state = "bulb-burned"
	light_on = FALSE
	status = LIGHT_BURNED

/obj/structure/light_fake/small/emergency
	icon_state = "bulb_emergency"
	light_color = "#FF4E4E"
	status = LIGHT_EMERGENCY

/obj/structure/light_fake/small/purple
	icon_state = "bulb2"
	light_color = "#A700FF"
	status = LIGHT_PURPLE

// MARK: Floor
/obj/structure/light_fake/floor
	icon_state = "floor"
	base_state = "floor"
	layer = ABOVE_OPEN_TURF_LAYER
	plane = FLOOR_PLANE
	light_power = 0.8
	light_range = 4
	light_angle = 360

/obj/structure/light_fake/floor/get_light_offset()
	return list(0, 0)

/obj/structure/light_fake/floor/broken
	icon_state = "floor-broken"
	light_on = FALSE
	status = LIGHT_BROKEN

/obj/structure/light_fake/floor/burned
	icon_state = "floor-burned"
	light_on = FALSE
	status = LIGHT_BURNED

/obj/structure/light_fake/floor/emergency
	icon_state = "floor_emergency"
	light_color = "#FF4E4E"
	light_range = 3
	status = LIGHT_EMERGENCY

/obj/structure/light_fake/floor/purple
	icon_state = "floor2"
	light_color = "#A700FF"
	status = LIGHT_PURPLE

// MARK: Spotlight
/obj/structure/light_fake/spot
	name = "spotlight"
	light_power = 2
	light_range = 10

/obj/structure/light_fake/spot/broken
	icon_state = "tube-broken"
	light_on = FALSE
	status = LIGHT_BROKEN

/obj/structure/light_fake/spot/burned
	icon_state = "tube-burned"
	light_on = FALSE
	status = LIGHT_BURNED

/obj/structure/light_fake/spot/emergency
	icon_state = "tube_emergency"
	light_color = "#FF4E4E"
	light_power = 1
	light_range = 6
	status = LIGHT_EMERGENCY

/obj/structure/light_fake/spot/purple
	icon_state = "tube2"
	light_color = "#A700FF"
	status = LIGHT_PURPLE

// MARK: Floodlight
/obj/structure/light_fake/floodlight
	name = "floodlight"
	icon_state = "floodlight"
	base_state = "floodlight"
	density = TRUE
	light_power = 2
	light_range = 10
	light_angle = 360

/obj/structure/light_fake/floodlight/get_light_offset()
	return list(0, 0)

/obj/structure/light_fake/floodlight/broken
	icon_state = "floodlight-broken"
	light_on = FALSE
	status = LIGHT_BROKEN

/obj/structure/light_fake/floodlight/burned
	icon_state = "floodlight-burned"
	light_on = FALSE
	status = LIGHT_BURNED

/obj/structure/light_fake/floodlight/emergency
	icon_state = "floodlight_emergency"
	light_color = "#FF4E4E"
	light_power = 1
	light_range = 6
	status = LIGHT_EMERGENCY

/obj/structure/light_fake/floodlight/purple
	icon_state = "floodlight2"
	light_color = "#A700FF"
	status = LIGHT_PURPLE

// MARK: Functionality
/// Break fake light and make sparks if was on
/obj/structure/light_fake/proc/break_light_tube(skip_sound_and_sparks = FALSE)
	if(status == LIGHT_BROKEN)
		return

	if(!skip_sound_and_sparks)
		playsound(loc, 'sound/effects/glass/glasshit.ogg', 75, TRUE)
		do_sparks(3, TRUE, src)

	status = LIGHT_BROKEN
	light_on = FALSE
	set_light(0)
	update_appearance()

/obj/structure/light_fake/update_overlays()
	. = ..()
	if(!light_on)
		cut_overlays()
		return
	. += emissive_appearance(overlay_icon, "[icon_state]", src, alpha = src.alpha)

/obj/structure/light_fake/get_light_offset()
	var/list/hand_back = ..()
	var/list/dir_offset = dir2offset(REVERSE_DIR(dir))
	hand_back[1] += dir_offset[1] * 0.5
	hand_back[2] += dir_offset[2] * 0.5
	return hand_back

/obj/structure/light_fake/Initialize(mapload)
	. = ..()
	set_light(l_dir = REVERSE_DIR(dir))
	update_appearance()

/obj/structure/light_fake/setDir(newdir)
	. = ..()
	set_light(l_dir = REVERSE_DIR(dir))
	update_appearance()

/obj/structure/light_fake/take_damage(damage_amount, damage_type = BRUTE, damage_flag = "", sound_effect = TRUE, attack_dir, armour_penetration = 0)
	. = ..()
	if(. && !QDELETED(src))
		if(prob(damage_amount * 5))
			break_light_tube()

/obj/structure/light_fake/attacked_by(obj/item/attacking_object, mob/living/user)
	..()
	if(!light_on || !(attacking_object.obj_flags & CONDUCTS_ELECTRICITY))
		return
	if(prob(12))
		electrocute_mob(user, get_area(src), src, 0.3, TRUE)

/obj/structure/light_fake/attackby(obj/item/tool, mob/living/user, list/modifiers)
	// Attempt to insert light
	if(istype(tool, /obj/item/light) && status == LIGHT_BROKEN)
		to_chat(user, span_warning("В этом осветительном приборе невозможно заменить лампу!"))
		return
	return ..()

/obj/structure/light_fake/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			playsound(loc, status == LIGHT_BROKEN ? 'sound/effects/hit_on_shattered_glass.ogg' : 'sound/effects/glass/glasshit.ogg', 90, TRUE)
		if(BURN)
			playsound(loc, 'sound/items/tools/welder.ogg', 100, TRUE)

/obj/structure/light_fake/examine(mob/user)
	. = ..()
	switch(status)
		if(LIGHT_BROKEN)
			. += span_danger("[capitalize(declent_ru(NOMINATIVE))] разбит[genderize_ru(gender, "", "а", "о", "ы")].")
		if(LIGHT_BURNED)
			. += span_danger("[capitalize(declent_ru(NOMINATIVE))] сгорел[genderize_ru(gender, "", "а", "о", "и")].")
		else
			. += span_notice("[capitalize(declent_ru(NOMINATIVE))] работает исправно.")

/obj/structure/light_fake/update_icon_state()
	switch(status)
		if(LIGHT_OK)
			icon_state = base_state
		if(LIGHT_BURNED)
			icon_state = "[base_state]-burned"
		if(LIGHT_BROKEN)
			icon_state = "[base_state]-broken"
		if(LIGHT_EMERGENCY)
			icon_state = "[base_state]_emergency"
		if(LIGHT_PURPLE)
			icon_state = "[base_state]2"
	return ..()

// MARK: Directional helpers
// Fake tube
MAPPING_DIRECTIONAL_HELPERS(/obj/structure/light_fake, 0)
MAPPING_DIRECTIONAL_HELPERS(/obj/structure/light_fake/broken, 0)
MAPPING_DIRECTIONAL_HELPERS(/obj/structure/light_fake/burned, 0)
MAPPING_DIRECTIONAL_HELPERS(/obj/structure/light_fake/emergency, 0)
MAPPING_DIRECTIONAL_HELPERS(/obj/structure/light_fake/purple, 0)

// Fake small
MAPPING_DIRECTIONAL_HELPERS(/obj/structure/light_fake/small, 0)
MAPPING_DIRECTIONAL_HELPERS(/obj/structure/light_fake/small/broken, 0)
MAPPING_DIRECTIONAL_HELPERS(/obj/structure/light_fake/small/burned, 0)
MAPPING_DIRECTIONAL_HELPERS(/obj/structure/light_fake/small/emergency, 0)
MAPPING_DIRECTIONAL_HELPERS(/obj/structure/light_fake/small/purple, 0)

// Fake spot
MAPPING_DIRECTIONAL_HELPERS(/obj/structure/light_fake/spot, 0)
MAPPING_DIRECTIONAL_HELPERS(/obj/structure/light_fake/spot/broken, 0)
MAPPING_DIRECTIONAL_HELPERS(/obj/structure/light_fake/spot/burned, 0)
MAPPING_DIRECTIONAL_HELPERS(/obj/structure/light_fake/spot/emergency, 0)
MAPPING_DIRECTIONAL_HELPERS(/obj/structure/light_fake/spot/purple, 0)

#undef LIGHT_EMERGENCY
#undef LIGHT_PURPLE
