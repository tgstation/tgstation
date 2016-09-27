/obj/structure/blob/shield
	name = "strong blob"
	icon = 'icons/mob/blob.dmi'
	icon_state = "blob_shield"
	desc = "A solid wall of slightly twitching tendrils."
	health = 150
	maxhealth = 150
	brute_resist = 0.25
	explosion_block = 3
	point_return = 4
	atmosblock = 1


/obj/structure/blob/shield/scannerreport()
	if(atmosblock)
		return "Will prevent the spread of atmospheric changes."
	return "N/A"

/obj/structure/blob/shield/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	return

/obj/structure/blob/shield/core
	point_return = 0

/obj/structure/blob/shield/update_icon()
	..()
	if(health <= 75)
		icon_state = "blob_shield_damaged"
		name = "weakened strong blob"
		desc = "A wall of twitching tendrils."
		atmosblock = 0
	else
		icon_state = initial(icon_state)
		name = initial(name)
		desc = initial(desc)
		atmosblock = 1
	air_update_turf(1)
