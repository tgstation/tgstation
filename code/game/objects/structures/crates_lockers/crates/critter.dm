/obj/structure/closet/crate/critter
	name = "critter crate"
	desc = "A crate designed for safe transport of animals. It has an oxygen tank for safe transport in space."
	icon_state = "crittercrate"
	base_icon_state = "crittercrate"
	horizontal = FALSE
	allow_objects = FALSE
	breakout_time = 600
	material_drop = /obj/item/stack/sheet/mineral/wood
	material_drop_amount = 4
	delivery_icon = "deliverybox"
	open_sound = 'sound/machines/closet/wooden_closet_open.ogg'
	close_sound = 'sound/machines/closet/wooden_closet_close.ogg'
	open_sound_volume = 25
	close_sound_volume = 50
	contents_pressure_protection = 0.8
	can_install_electronics = FALSE
	elevation = 21
	elevation_open = 0
	can_weld_shut = FALSE

	var/obj/item/tank/internals/emergency_oxygen/tank

/obj/structure/closet/crate/critter/Initialize(mapload)
	. = ..()
	tank = new

/obj/structure/closet/crate/critter/Destroy()
	var/turf/T = get_turf(src)
	if(tank)
		tank.forceMove(T)
		tank = null

	return ..()

/obj/structure/closet/crate/critter/update_icon_state()
	SHOULD_CALL_PARENT(FALSE)
	return

/obj/structure/closet/crate/critter/update_overlays()
	. = ..()
	if(opened)
		. += "crittercrate_door_open"
		return

	. += "crittercrate_door"
	if(manifest)
		. += "manifest"

/obj/structure/closet/crate/critter/return_air()
	if(tank)
		return tank.return_air()
	else
		return loc.return_air()

/obj/structure/closet/crate/critter/return_analyzable_air()
	if(tank)
		return tank.return_analyzable_air()
	else
		return null

/obj/structure/closet/crate/critter/stasis
	name = "stasis critter crate"
	desc = "A crate designed for safe transport of specific animals in stasis to prevent them from aging or starving."
	var/stasis_sealed = TRUE

/obj/structure/closet/crate/critter/stasis/Exited(atom/movable/gone, direction)
	. = ..()
	if(HAS_TRAIT(gone, TRAIT_STASIS))
		remove_stasis(gone)

/obj/structure/closet/crate/critter/stasis/proc/remove_stasis(mob/living/target)
	target.remove_status_effect(/datum/status_effect/grouped/stasis, STASIS_CRATE_EFFECT)

/obj/structure/closet/crate/critter/stasis/after_open(mob/living/user, force)
	. = ..()
	if(!stasis_sealed)
		return
	stasis_sealed = FALSE
	do_sparks(3, FALSE, src)
	to_chat(user, span_warning("[src] one-use stasis mechanism has been triggered! It will not work again."))
