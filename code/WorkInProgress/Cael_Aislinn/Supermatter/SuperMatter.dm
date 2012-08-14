#define NITROGEN_RETARDATION_FACTOR 12	//Higher == N2 slows reaction more
#define THERMAL_RELEASE_MODIFIER 20		//Higher == less heat released during reaction
#define PLASMA_RELEASE_MODIFIER 200	//Higher == less plasma released by reaction
#define OXYGEN_RELEASE_MODIFIER 150	//Higher == less oxygen released at high temperature/power
#define REACTION_POWER_MODIFIER 1.1		//Higher == more overall power

#define WARNING_DELAY 30 //30 seconds between warnings.

/obj/machinery/power/supermatter
	name = "Supermatter"
	desc = "A strangely translucent and iridescent crystal.  \red You get headaches just from looking at it."
	icon = 'engine.dmi'
	icon_state = "darkmatter"
	density = 1
	anchored = 0

	LuminosityRed = 4
	LuminosityGreen = 6

	var/gasefficency = 0.25

	var/damage = 0
	var/damage_archived = 0
	var/safe_alert = "Crystaline hyperstructure returning to safe operating levels."
	var/warning_point = 300
	var/warning_alert = "Danger! Crystal hyperstructure instability!"
	var/emergency_point = 3000
	var/emergency_alert = "CRYSTAL DELAMINATION IMMINENT"
	var/explosion_point = 4500

	var/explosion_power = 8

	var/lastwarning = 0			// Time in 1/10th of seconds since the last sent warning

	var/power = 0

	var/halucination_range = 8
	var/rad_range = 4


	shard //Small subtype, less efficient and more sensitive, but less boom.
		name = "Supermatter Shard"
		desc = "A strangely translucent and iridescent crystal. Looks like it used to be part of a larger structure. \red You get headaches just from looking at it."
		warning_point = 200
		emergency_point = 2500
		explosion_point = 3500

		gasefficency = 12.5
		halucination_range = 5
		rad_range = 2

		explosion_power = 2 //2,4,6,8?  Or is that too small?


	process()

		var/turf/simulated/L = loc

		if(!istype(L)) //If we are not on a turf, uh oh.
			del src

		//Ok, get the air from the turf
		var/datum/gas_mixture/env = L.return_air()

		//Remove gas from surrounding area
		var/transfer_moles = gasefficency * env.total_moles
		var/datum/gas_mixture/removed = env.remove(transfer_moles)

		if (!removed)
			return 1

		damage_archived = damage
		damage = max( damage + ( (removed.temperature - 1000) / 150 ) , 0 )

		if(damage > warning_point) // while the core is still damaged and it's still worth noting its status
			if((world.timeofday - lastwarning) / 10 >= WARNING_DELAY)

				if(damage > emergency_point)
					radioalert("states, \"[emergency_alert]\"","Supermatter Monitor")
				else if(damage >= damage_archived)   // The damage is still going up
					radioalert("states, \"[warning_alert]\"","Supermatter Monitor")
				else						  // Phew, we're safe
					radioalert("states, \"[safe_alert]\"","Supermatter Monitor")

				lastwarning = world.timeofday

			if(damage > explosion_point)
				explosion(loc,explosion_power,explosion_power*2,explosion_power*3,explosion_power*4,1)
				del src

		var/nitrogen_mod = abs((removed.nitrogen / removed.total_moles)) * NITROGEN_RETARDATION_FACTOR
		var/oxygen = max(min(removed.oxygen / removed.total_moles - nitrogen_mod, 1), 0)

		var/temp_factor = 0
		if(oxygen > 0.8)
			// with a perfect gas mix, make the power less based on heat
			temp_factor = 100
			icon_state = "darkmatter_glow"
		else
			// in normal mode, base the produced energy around the heat
			temp_factor = 20
			icon_state = "darkmatter"

		//Calculate power released as heat and gas, in as the sqrt of the power.
		var/power_factor = (power/100) ** 3
		var/device_energy = oxygen * power_factor
		power = max(round((removed.temperature - T0C) / temp_factor) + power - power_factor, 0) //Total laser power plus an overload factor

		//Final energy calcs.
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
		removed.toxins += max(device_energy / PLASMA_RELEASE_MODIFIER, 0)

		removed.oxygen += max((device_energy + removed.temperature - T0C) / OXYGEN_RELEASE_MODIFIER, 0)

		removed.update_values()

		env.merge(removed)

		for(var/mob/living/carbon/human/l in range(src, halucination_range)) // you have to be seeing the core to get hallucinations
			if(prob(10) && !istype(l.glasses, /obj/item/clothing/glasses/meson))
				l.hallucination = 50

		for(var/mob/living/l in range(src,rad_range))
			l.apply_effect(rand(20,60)/(get_dist(src, l)+1), IRRADIATE)

		return 1


	bullet_act(var/obj/item/projectile/Proj)
		if(Proj.flag != "bullet")
			power += Proj.damage
		return 0