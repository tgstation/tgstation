//Stores several modifiers in a way that isn't cleared by changing species

/datum/physiology
	var/list/physio_mods = list()

	var/brute_mod = 1   	// % of brute damage taken from all sources
	var/burn_mod = 1    	// % of burn damage taken from all sources
	var/tox_mod = 1     	// % of toxin damage taken from all sources
	var/oxy_mod = 1     	// % of oxygen damage taken from all sources
	var/clone_mod = 1   	// % of clone damage taken from all sources
	var/stamina_mod = 1 	// % of stamina damage taken from all sources
	var/brain_mod = 1   	// % of brain damage taken from all sources

	var/pressure_mod = 1	// % of brute damage taken from low or high pressure (stacks with brute_mod)
	var/heat_mod = 1    	// % of burn damage taken from heat (stacks with burn_mod)
	var/cold_mod = 1    	// % of burn damage taken from cold (stacks with burn_mod)

	var/damage_resistance = 0 // %damage reduction from all sources

	var/siemens_coeff = 1 	// resistance to shocks

	var/stun_mod = 1      	// % stun modifier
	var/bleed_mod = 1     	// % bleeding modifier
	var/datum/armor/armor 	// internal armor datum

	var/speed_mod = 0     	//tick modifier for each step. Positive is slower, negative is faster.

	var/hunger_mod = 1		//% of hunger rate taken per tick.

	var/do_after_speed = 1 //Speed mod for do_after. Lower is better. If temporarily adjusting, please only modify using *= and /=, so you don't interrupt other calculations.

/datum/physiology/New()
	armor = new
	
/datum/physiology/Destroy()
	QDEL_LIST(physio_mods)
	return ..()
	
/datum/physiology/proc/apply_mod(datum/physio_mod/mod_type)
	for(var/i in physio_mods)
		var/datum/physio_mod/P = i
		if(P.id == initial(mod_type.id))
			if(P.priority <= initial(mod_type.priority))
				remove_mod_id(P.id)
			else
				return
	var/new_mod = new mod_type
	physio_mods += new_mod
	new_mod.physiology = src
	new_mod.apply()
	
/datum/physiology/proc/remove_mod_id(id)
	for(var/i in physio_mods)
		var/datum/physio_mod/P = i
		if(P.id == id)
			P.remove()
			
/datum/physiology/proc/remove_mod(datum/physio_mod/mod_type)
	for(var/i in physio_mods)
		var/datum/physio_mod/P = i
		if(P.type == mod_type)
			P.remove()

/datum/physio_mod
	var/name = "Physiology Mod"
	var/id = "" //Physiology can only have one mod per id
	var/priority = 10 //Higher priority overrides lower, if same latest applies
	var/datum/physiology/physiology
	
/datum/physio_mod/proc/apply()
	return

/datum/physio_mod/proc/remove()
	qdel(src)
	
///////////////////////////////////PHYSIO MODS/////////////////////////////////////////////////

/datum/physio_mod/spliced_nerves
	name = "Spliced Nerves"
	id = "nerve_stun"

/datum/physio_mod/spliced_nerves/apply()
	physiology.stun_mod *= 0.5

/datum/physio_mod/spliced_nerves/remove()
	physiology.stun_mod /= 0.5
	. = ..()

/datum/physio_mod/threaded_veins
	name = "Threaded Veins"
	id = "vein_bleed"

/datum/physio_mod/threaded_veins/apply()
	physiology.bleed_mod *= 0.25

/datum/physio_mod/threaded_veins/remove()
	physiology.bleed_mod /= 0.25
	. = ..()

/datum/physio_mod/slimeskin
	name = "Slimeskin"
	id = "skin_coating"

/datum/physio_mod/slimeskin/apply()
	physiology.damage_resistance += 10

/datum/physio_mod/slimeskin/remove()
	physiology.damage_resistance -= 10
	. = ..()
	
/datum/physio_mod/metal_cookie
	name = "Metal Cookie"
	id = "metal_cookie"

/datum/physio_mod/metal_cookie/apply()
	physiology.brute_mod *= 0.9

/datum/physio_mod/metal_cookie/remove()
	physiology.brute_mod /= 0.9
	. = ..()
	
/datum/physio_mod/adamantine_cookie
	name = "Adamantine Cookie"
	id = "adamantine_cookie"

/datum/physio_mod/adamantine_cookie/apply()
	physiology.burn_mod *= 0.9

/datum/physio_mod/adamantine_cookie/remove()
	physiology.burn_mod /= 0.9
	. = ..()
	
/datum/physio_mod/stab_silver
	name = "Stabilized Silver"
	id = "stab_silver"

/datum/physio_mod/stab_silver/apply()
	physiology.hunger_mod *= 0.8

/datum/physio_mod/stab_silver/remove()
	physiology.hunger_mod /= 0.8
	. = ..()
	
/datum/physio_mod/time_cookie
	name = "Time Cookie"
	id = "time_cookie"

/datum/physio_mod/time_cookie/apply()
	physiology.do_after_speed *= 0.9

/datum/physio_mod/time_cookie/remove()
	physiology.do_after_speed /= 0.9
	. = ..()
	
/datum/physio_mod/tar_foot
	name = "Tar Foot"
	id = "tar_foot"

/datum/physio_mod/tar_foot/apply()
	physiology.speed_mod += 0.5

/datum/physio_mod/tar_foot/remove()
	physiology.speed_mod -= 0.5
	. = ..()
	
/datum/physio_mod/sepia
	name = "Sepia"
	id = "sepia"
	var/modifier = 0

/datum/physio_mod/sepia/apply()	
	modifier = pick(-1, 0, 1)
	physiology.speed_mod += modifier

/datum/physio_mod/sepia/remove()
	physiology.speed_mod -= modifier
	. = ..()
	
/datum/physio_mod/adamantine_skin
	name = "Adamantine Skin"
	id = "adamantine_skin"

/datum/physio_mod/adamantine_skin/apply()
	physiology.damage_resistance += 5

/datum/physio_mod/adamantine_skin/remove()
	physiology.damage_resistance -= 5
	. = ..()




