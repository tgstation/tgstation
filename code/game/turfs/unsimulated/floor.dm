/turf/unsimulated/floor
	name = "floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "Floor3"

/turf/unsimulated/floor/attack_paw(user as mob)
	return src.attack_hand(user)

/turf/unsimulated/floor/cultify()
	if((icon_state != "cult")&&(icon_state != "cult-narsie"))
		name = "engraved floor"
		icon_state = "cult"
		turf_animation('icons/effects/effects.dmi',"cultfloor",0,0,MOB_LAYER-1)
	return

/turf/unsimulated/floor/grass
	icon_state = "grass1"

/turf/unsimulated/floor/grass/New()
	..()
	icon_state = "grass[rand(1,4)]"