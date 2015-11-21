/obj/effect/blob/shield
	name = "strong blob"
	icon = 'icons/mob/blob.dmi'
	icon_state = "blob_idle"
	desc = "A solid wall of slightly twitching tendrils."
	health = 150
	maxhealth = 150
	explosion_block = 3
	point_return = 2


/obj/effect/blob/shield/update_icon()
	if(health <= 0)
		qdel(src)
		return
	return

/obj/effect/blob/shield/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	return

/obj/effect/blob/shield/CanAtmosPass(turf/T)
	return 0

/obj/effect/blob/shield/BlockSuperconductivity()
	return 1

/obj/effect/blob/shield/CanPass(atom/movable/mover, turf/target, height=0)
	if(istype(mover) && mover.checkpass(PASSBLOB))	return 1
	return 0
