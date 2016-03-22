/obj/effect/blob/shield
	name = "strong blob"
	icon = 'icons/mob/blob.dmi'
	icon_state = "blob_idle"
	desc = "A solid wall of slightly twitching tendrils."
	health = 150
	maxhealth = 150
	brute_resist = 0.1
	explosion_block = 3
	point_return = 2
	atmosblock = 1


/obj/effect/blob/shield/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	return
