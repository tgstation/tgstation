/obj/effect/temp_visual/telegraphing
	icon = 'icons/mob/telegraphing/telegraph_holographic.dmi'
	icon_state = "target_box"
	layer = BELOW_MOB_LAYER
	plane = GAME_PLANE
	light_range = 1
	duration = 2 SECONDS

/obj/effect/temp_visual/telegraphing/Initialize(mapload)
	. = ..()
	update_appearance(UPDATE_OVERLAYS)

/obj/effect/temp_visual/telegraphing/update_overlays()
	. = ..()
	. += emissive_appearance(icon, icon_state, src, alpha = 90)

/obj/effect/temp_visual/telegraphing/vending_machine_tilt
	duration = 1 SECONDS

/obj/effect/temp_visual/telegraphing/lift_travel

/obj/effect/temp_visual/telegraphing/lift_travel/Initialize(mapload, duration)
	src.duration = duration
	return ..()

/obj/effect/temp_visual/telegraphing/circle
	icon = 'icons/mob/telegraphing/telegraph.dmi'
	icon_state = "target_circle"
	duration = 2 SECONDS

/obj/effect/temp_visual/telegraphing/circle/short
	duration = 1 SECONDS

/obj/effect/temp_visual/telegraphing/line
	icon = 'icons/mob/telegraphing/telegraph.dmi'
	icon_state = "line"
	duration = 1.2 SECONDS

/obj/effect/temp_visual/telegraphing/line/short
	duration = 0.5 SECONDS
