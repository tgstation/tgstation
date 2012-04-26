#define NITROGEN_RETARDATION_FACTOR 4	//Higher == N2 slows reaction more
#define THERMAL_RELEASE_MODIFIER 50		//Higher == less heat released during reaction
#define PLASMA_RELEASE_MODIFIER 750		//Higher == less plasma released by reaction
#define OXYGEN_RELEASE_MODIFIER 1500	//Higher == less oxygen released at high temperature/power
#define REACTION_POWER_MODIFIER 1.1		//Higher == more overall power

/obj/machinery/engine/supermatter
	name = "Supermatter"
	desc = "A strangely translucent and iridescent crystal.  \red You get headaches just from looking at it."
	icon = 'engine.dmi'
	icon_state = "darkmatter"
	density = 1
	anchored = 1

	var/gasefficency = 0.25

	var/det = 0
	var/previousdet = 0
	var/const/explosiondet = 3500

	var/const/warningtime = 50 	// Make the CORE OVERLOAD message repeat only every aprox. ?? seconds
	var/lastwarning = 0			// Time in 1/10th of seconds since the last sent warning

/obj/machinery/engine/klaxon
	name = "Emergency Klaxon"
	icon = 'engine.dmi'
	icon_state = "darkmatter"
	density = 1
	anchored = 1
	var/obj/machinery/engine/supermatter/sup

/obj/machinery/engine/klaxon/process()
	if(!sup)
		for(var/obj/machinery/engine/supermatter/T in world)
			sup = T
			break
	if(sup.det >= 1)
		return

/obj/machinery/engine/supermatter/process()

	var/turf/simulated/L = loc

	//Ok, get the air from the turf
	var/datum/gas_mixture/env = L.return_air()

	//Remove gas from surrounding area
	var/transfer_moles = gasefficency * env.total_moles
	var/datum/gas_mixture/removed = env.remove(transfer_moles)

	previousdet = det
	det += (removed.temperature - 1000) / 150
	det = max(det, 0)

	if(det > 0 && removed.temperature > 1000) // while the core is still damaged and it's still worth noting its status
		if((world.realtime - lastwarning) / 10 >= warningtime)
			lastwarning = world.realtime
			if(explosiondet - det <= 300)
				radioalert("CORE EXPLOSION IMMINENT","Core control computer")
			else if(det >= previousdet)   // The damage is still going up
				radioalert("CORE OVERLOAD","Core control computer")
			else						  // Phew, we're safe
				radioalert("Core returning to safe operating levels.","Core control computer")

	if(det > explosiondet)
		roundinfo.core = 1
		//proc/explosion(turf/epicenter, devastation_range, heavy_impact_range, light_impact_range, flash_range, force = 0)
		explosion(src.loc,8,15,20,30,1)
		det = 0

	if (!removed)
		return 1

	var/power = max(round((removed.temperature - T0C) / 20), 0) //Total laser power plus an overload factor

	//Get the collective laser power
	for(var/dir in cardinal)
		var/turf/T = get_step(L, dir)
		for(var/obj/effect/beam/e_beam/item in T)
			power += item.power

	//Ok, 100% oxygen atmosphere = best reaction
	//Maxes out at 100% oxygen pressure
	var/oxygen = max(min((removed.oxygen - (removed.nitrogen * NITROGEN_RETARDATION_FACTOR)) / MOLES_CELLSTANDARD, 1), 0)

	var/device_energy = oxygen * power

	device_energy *= removed.temperature / T0C

	device_energy = round(device_energy * REACTION_POWER_MODIFIER)

	//To figure out how much temperature to add each tick, consider that at one atmosphere's worth
	//of pure oxygen, with all four lasers firing at standard energy and no N2 present, at room temperature
	//that the device energy is around 2140.  At that stage, we don't want too much heat to be put out
	//Since the core is effectively "cold"

	//Also keep in mind we are only adding this temperature to (efficiency)% of the one tile the rock
	//is on.  An increase of 4*C @ 25% efficiency here results in an increase of 1*C / (#tilesincore) overall.
	removed.temperature += max((device_energy / THERMAL_RELEASE_MODIFIER), 0)

	removed.temperature = min(removed.temperature, 1500)

	//Calculate how much gas to release
	removed.toxins += max(round(device_energy / PLASMA_RELEASE_MODIFIER), 0)

	removed.oxygen += max(round((device_energy + removed.temperature - T0C) / OXYGEN_RELEASE_MODIFIER), 0)

	env.merge(removed)

//Not functional currently. -- SkyMarshal
/*
	for(var/mob/living/carbon/l in view(src, 6)) // you have to be seeing the core to get hallucinations
		if(prob(10) && !(l.glasses && istype(l.glasses, /obj/item/clothing/glasses/meson)))
			l.hallucination = 50
*/
	for(var/mob/living/l in view(src,3))
		l.bruteloss += 50
		l.updatehealth()

	return 1