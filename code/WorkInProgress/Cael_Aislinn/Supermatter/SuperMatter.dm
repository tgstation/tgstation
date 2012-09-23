#define NITROGEN_RETARDATION_FACTOR 12	//Higher == N2 slows reaction more
#define THERMAL_RELEASE_MODIFIER 0.55		//Percentage of output power given to heat generation.

#define PLASMA_RELEASE_MODIFIER 0.24	//Percentage of output power given to plasma generation.
#define PLASMA_CONVERSION_FACTOR 50	//How much energy per mole of plasma
#define MAX_PLASMA_RELATIVE_INCREASE 0.3 //Percentage of current plasma amounts that can be added to preexisting plasma.

#define OXYGEN_RELEASE_MODIFIER 0.13	//Percentage of output power given to oxygen generation.
#define OXYGEN_CONVERSION_FACTOR 150	//How much energy per mole of oxygen.
#define MAX_OXYGEN_RELATIVE_INCREASE 0.2 //Percentage of current oxygen amounts that can be added to preexisting oxygen.

#define RADIATION_POWER_MODIFIER 0.03 //How much power goes to irradiating the area.
#define RADIATION_FACTOR		 10
#define HALLUCINATION_POWER_MODIFIER 0.05 //How much power goes to hallucinations.
#define HALLUCINATION_FACTOR	 20

#define REACTION_POWER_MODIFIER 4		//Higher == more overall power

#define WARNING_DELAY 45 //45 seconds between warnings.

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

	var/base_icon_state = "darkmatter"

	var/damage = 0
	var/damage_archived = 0
	var/safe_alert = "Crystaline hyperstructure returning to safe operating levels."
	var/warning_point = 100
	var/warning_alert = "Danger! Crystal hyperstructure instability!"
	var/emergency_point = 700
	var/emergency_alert = "CRYSTAL DELAMINATION IMMINENT"
	var/explosion_point = 1000

	var/emergency_issued = 0

	var/explosion_power = 8

	var/lastwarning = 0			// Time in 1/10th of seconds since the last sent warning

	var/power = 0


	shard //Small subtype, less efficient and more sensitive, but less boom.
		name = "Supermatter Shard"
		desc = "A strangely translucent and iridescent crystal. Looks like it used to be part of a larger structure. \red You get headaches just from looking at it."
		icon_state = "darkmatter_shard"
		base_icon_state = "darkmatter_shard"

		warning_point = 50
		emergency_point = 500
		explosion_point = 900

		gasefficency = 0.125

		explosion_power = 3 //3,6,9,12?  Or is that too small?


	process()

		var/turf/L = loc

		if(!istype(L)) //If we are not on a turf, uh oh.
			del src

		//Ok, get the air from the turf
		var/datum/gas_mixture/env = L.return_air()

		//Remove gas from surrounding area
		var/datum/gas_mixture/removed = env.remove(gasefficency * env.total_moles)

		if (!removed)
			return 1

		if(damage > warning_point) // while the core is still damaged and it's still worth noting its status
			if((world.timeofday - lastwarning) / 10 >= WARNING_DELAY)

				if(damage > emergency_point)
					radioalert("states, \"[emergency_alert]\"","Supermatter Monitor")
					lastwarning = world.timeofday
				else if(damage >= damage_archived)   // The damage is still going up
					radioalert("states, \"[warning_alert]\"","Supermatter Monitor")
					lastwarning = world.timeofday-150
				else						  // Phew, we're safe
					radioalert("states, \"[safe_alert]\"","Supermatter Monitor")
					lastwarning = world.timeofday

			if(damage > explosion_point)
				explosion(loc,explosion_power,explosion_power*2,explosion_power*3,explosion_power*4,1)
				del src

		damage_archived = damage
		damage = max( damage + ( (removed.temperature - 800) / 150 ) , 0 )

		if(!removed.total_moles)
			damage += max((power-1600)/10,0)
			power = max(power,1600)
			return 1

		var/nitrogen_mod = abs((removed.nitrogen / removed.total_moles)) * NITROGEN_RETARDATION_FACTOR
		var/oxygen = max(min(removed.oxygen / removed.total_moles - nitrogen_mod, 1), 0)

		var/temp_factor = 0
		if(oxygen > 0.8)
			// with a perfect gas mix, make the power less based on heat
			temp_factor = 100
			icon_state = "[base_icon_state]_glow"
		else
			// in normal mode, base the produced energy around the heat
			temp_factor = 60
			icon_state = base_icon_state

		//Calculate power released as heat and gas, in as the sqrt of the power.
		var/power_factor = (power/500) ** 3
		var/device_energy = oxygen * power_factor
		power = max(round((removed.temperature - T0C) / temp_factor) + power - power_factor, 0) //Total laser power plus an overload factor

		//Final energy calcs.
		device_energy = max(device_energy * REACTION_POWER_MODIFIER,0)

	//To figure out how much temperature to add each tick, consider that at one atmosphere's worth
	//of pure oxygen, with all four lasers firing at standard energy and no N2 present, at room temperature
	//that the device energy is around 2140.  At that stage, we don't want too much heat to be put out
	//Since the core is effectively "cold"

	//Also keep in mind we are only adding this temperature to (efficiency)% of the one tile the rock
	//is on.  An increase of 4*C @ 25% efficiency here results in an increase of 1*C / (#tilesincore) overall.

		var/plasma_energy = device_energy * PLASMA_RELEASE_MODIFIER
		var/oxygen_energy = device_energy * OXYGEN_RELEASE_MODIFIER
		var/other_energy = device_energy * (1- (OXYGEN_RELEASE_MODIFIER + PLASMA_RELEASE_MODIFIER))

		//Put as much plasma out as is permitted.
		if( plasma_energy > removed.total_moles * PLASMA_CONVERSION_FACTOR * MAX_PLASMA_RELATIVE_INCREASE / gasefficency)
			removed.toxins += (MAX_PLASMA_RELATIVE_INCREASE * removed.total_moles / gasefficency)
			other_energy += plasma_energy - (removed.total_moles * PLASMA_CONVERSION_FACTOR * MAX_PLASMA_RELATIVE_INCREASE / gasefficency)
		else
			removed.toxins += plasma_energy/PLASMA_CONVERSION_FACTOR

		//Put as much plasma out as is permitted.
		if( oxygen_energy > removed.total_moles * OXYGEN_CONVERSION_FACTOR * MAX_OXYGEN_RELATIVE_INCREASE / gasefficency)
			removed.oxygen += (MAX_OXYGEN_RELATIVE_INCREASE * removed.total_moles / gasefficency)
			other_energy += oxygen_energy - (removed.total_moles * OXYGEN_CONVERSION_FACTOR * MAX_OXYGEN_RELATIVE_INCREASE / gasefficency)
		else
			removed.oxygen += oxygen_energy/OXYGEN_CONVERSION_FACTOR


		var/heat_energy = (other_energy*THERMAL_RELEASE_MODIFIER)/(1-(OXYGEN_RELEASE_MODIFIER + PLASMA_RELEASE_MODIFIER))
		var/hallucination_energy = (other_energy*HALLUCINATION_POWER_MODIFIER*HALLUCINATION_FACTOR)/(1-(OXYGEN_RELEASE_MODIFIER + PLASMA_RELEASE_MODIFIER))
		var/rad_energy = (other_energy*RADIATION_POWER_MODIFIER*RADIATION_FACTOR)/(1-(OXYGEN_RELEASE_MODIFIER + PLASMA_RELEASE_MODIFIER))

		var/heat_applied = max(heat_energy,0)
		if(heat_applied + removed.temperature > 800)
			removed.temperature = 800
			var/energy_to_reconsider = (heat_applied + removed.temperature - 800)
			hallucination_energy += (energy_to_reconsider*HALLUCINATION_POWER_MODIFIER)/(HALLUCINATION_POWER_MODIFIER+RADIATION_POWER_MODIFIER)
			rad_energy += (energy_to_reconsider*RADIATION_POWER_MODIFIER)/(HALLUCINATION_POWER_MODIFIER+RADIATION_POWER_MODIFIER)
		else
			removed.temperature += heat_applied

		removed.update_values()

		env.merge(removed)

		for(var/mob/living/carbon/human/l in view(src, round(hallucination_energy**0.25))) // you have to be seeing the core to get hallucinations
			if(prob(10) && !istype(l.glasses, /obj/item/clothing/glasses/meson))
				l.hallucination += hallucination_energy/((get_dist(l,src)**2))

		for(var/mob/living/l in range(src,round(rad_energy**0.25)))
			var/rads = rad_energy/((get_dist(l,src)**2))
			l.apply_effect(rads, IRRADIATE)

		return 1


	bullet_act(var/obj/item/projectile/Proj)
		if(Proj.flag != "bullet")
			power += Proj.damage
		return 0