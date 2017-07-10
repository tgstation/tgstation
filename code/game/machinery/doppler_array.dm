GLOBAL_LIST_EMPTY(doppler_arrays)

/obj/machinery/doppler_array
	name = "tachyon-doppler array"
	desc = "A highly precise directional sensor array which measures the release of quants from decaying tachyons. The doppler shifting of the mirror-image formed by these quants can reveal the size, location and temporal affects of energetic disturbances within a large radius ahead of the array.\n<span class='notice'>Alt-click to rotate it clockwise.</span>"
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "tdoppler"
	density = TRUE
	anchored = TRUE
	var/integrated = 0
	var/max_dist = 100
	verb_say = "states coldly"

/obj/machinery/doppler_array/New()
	..()
	GLOB.doppler_arrays += src

/obj/machinery/doppler_array/Destroy()
	GLOB.doppler_arrays -= src
	return ..()

/obj/machinery/doppler_array/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>Its dish is facing to the [dir2text(dir)].</span>")

/obj/machinery/doppler_array/process()
	return PROCESS_KILL

/obj/machinery/doppler_array/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/weapon/wrench))
		if(!anchored && !isinspace())
			anchored = TRUE
			power_change()
			to_chat(user, "<span class='notice'>You fasten [src].</span>")
		else if(anchored)
			anchored = FALSE
			power_change()
			to_chat(user, "<span class='notice'>You unfasten [src].</span>")
		playsound(loc, O.usesound, 50, 1)
	else
		return ..()

/obj/machinery/doppler_array/verb/rotate()
	set name = "Rotate Tachyon-doppler Dish"
	set category = "Object"
	set src in oview(1)

	if(!usr || !isturf(usr.loc))
		return
	if(usr.stat || usr.restrained() || !usr.canmove)
		return
	setDir(turn(src.dir, 90))
	to_chat(usr, "<span class='notice'>You adjust [src]'s dish to face to the [dir2text(dir)].</span>")
	playsound(src, 'sound/items/screwdriver2.ogg', 50, 1)
	return

/obj/machinery/doppler_array/AltClick(mob/living/user)
	if(!istype(user) || user.incapacitated())
		to_chat(user, "<span class='warning'>You can't do that right now!</span>")
		return
	if(!in_range(src, user))
		return
	else
		rotate()

/obj/machinery/doppler_array/proc/sense_explosion(turf/epicenter,devastation_range,heavy_impact_range,light_impact_range,
												  took,orig_dev_range,orig_heavy_range,orig_light_range)
	if(stat & NOPOWER)
		return
	var/turf/zone = get_turf(src)

	if(zone.z != epicenter.z)
		return

	var/distance = get_dist(epicenter, zone)
	var/direct = get_dir(zone, epicenter)

	if(distance > max_dist)
		return
	if(!(direct & dir) && !integrated)
		return


	var/list/messages = list("Explosive disturbance detected.", \
							 "Epicenter at: grid ([epicenter.x],[epicenter.y]). Temporal displacement of tachyons: [took] seconds.", \
							 "Factual: Epicenter radius: [devastation_range]. Outer radius: [heavy_impact_range]. Shockwave radius: [light_impact_range].")

	// If the bomb was capped, say it's theoretical size.
	if(devastation_range < orig_dev_range || heavy_impact_range < orig_heavy_range || light_impact_range < orig_light_range)
		messages += "Theoretical: Epicenter radius: [orig_dev_range]. Outer radius: [orig_heavy_range]. Shockwave radius: [orig_light_range]."

	if(integrated)
		var/obj/item/clothing/head/helmet/space/hardsuit/helm = loc
		if(!helm || !istype(helm, /obj/item/clothing/head/helmet/space/hardsuit))
			return
		helm.display_visor_message("Explosion detected! Epicenter: [devastation_range], Outer: [heavy_impact_range], Shock: [light_impact_range]")
	else
		for(var/message in messages)
			say(message)

/obj/machinery/doppler_array/power_change()
	if(stat & BROKEN)
		icon_state = "[initial(icon_state)]-broken"
	else
		if(powered() && anchored)
			icon_state = initial(icon_state)
			stat &= ~NOPOWER
		else
			icon_state = "[initial(icon_state)]-off"
			stat |= NOPOWER

//Portable version, built into EOD equipment. It simply provides an explosion's three damage levels.
/obj/machinery/doppler_array/integrated
	name = "integrated tachyon-doppler module"
	integrated = 1
	max_dist = 21 //Should detect most explosions in hearing range.
	use_power = NO_POWER_USE
