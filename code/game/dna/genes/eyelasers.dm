
//**************************************************************
// Eye Lasers
//**************************************************************

/mob/proc/shootEyeLasers(atom/target)
	return

/mob/living/shootEyeLasers(atom/target)
	var/turf/T = get_turf(src)
	var/turf/U = get_turf(target)
	var/obj/item/projectile/beam/LE = getFromPool(/obj/item/projectile/beam, loc)
	LE.icon = 'icons/effects/genetics.dmi'
	LE.icon_state = "eyelasers"
	playsound(usr.loc, 'sound/weapons/taser2.ogg', 75, 1)
	LE.firer = src
	LE.def_zone = get_organ_target()
	LE.original = target
	LE.current = T
	LE.yo = U.y - T.y
	LE.xo = U.x - T.x
	spawn() LE.process()
	return

/mob/living/carbon/human/shootEyeLasers(atom/target)
	if(src.nutrition > 0)
		..()
		nutrition = max(nutrition - rand(1,5),0)
		handle_regular_hud_updates()
	else src << "<span class='warning'> You're out of energy!  You need food!</span>"
	return
