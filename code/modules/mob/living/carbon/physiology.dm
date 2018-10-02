//Modifier priorities
#define MODIFIER_TEMPLATE 0 		//The initial set of mod values, usually set by the mob itself on creation
#define MODIFIER_SUBTEMPLATE 1		//A set of values that overrides the base template, usually set by subcategories like species
#define MODIFIER_HARDSET 2			//Hard replacements of values pre-modifiers due to other factors. Use sparingly, if ever.
#define MODIFIER_ADDITION 3			//Basic addition (or subtraction) before multipliers are applied
#define MODIFIER_ADD_MULTIPLIER 4	//Additive multipliers (i.e. 50% bonus + 50% bonus = 200%)
#define MODIFIER_MULT_MULTIPLIER 5	//Multiplicative multipliers (i.e. 50% bonus + 50% bonus = 225%)
#define MODIFIER_POST_ADDITION 6	//Basic addition (or subtraction) after multipliers are applied
#define MODIFIER_POST_HARDSET 7		//Hardset that overrides everything else. For example, mods that set siemens_coeff to 0.



//Stores several modifiers in a way that isn't cleared by changing species

/datum/modifiers
	var/list/mod_list = list()

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

	var/damage_mod = 1 // % damage taken from all sources

	var/siemens_coeff = 1 	// conductivity, lower means less damage from shocks

	var/stun_mod = 1      	// % stun modifier
	var/bleed_mod = 1     	// % bleeding modifier
	var/datum/armor/armor 	// internal armor datum

	var/speed_mod = 0     	//tick modifier for each step. Positive is slower, negative is faster.

	var/hunger_mod = 1		//% of hunger rate taken per tick.

	var/do_after_speed = 1 //Speed mod for do_after. Lower is better. If temporarily adjusting, please only modify using *= and /=, so you don't interrupt other calculations.

/datum/modifiers/New()
	armor = new

/datum/modifiers/Destroy()
	QDEL_LIST(mod_list)
	return ..()

/datum/modifiers/proc/refresh_mods()
	mod_list = sortList(mod_list, /proc/cmp_modifier_priority) //From lowest priority to highest
	for(var/I in mod_list)
		var/datum/stat_mod/mod = I
		var/add_mult
		new_mod.apply()


/datum/modifiers/proc/apply_mod(datum/stat_mod/mod_type)
	for(var/i in mod_list)
		var/datum/stat_mod/P = i
		if(P.id == initial(mod_type.id))
			if(P.priority <= initial(mod_type.priority))
				remove_mod_id(P.id)
			else
				return
	var/datum/stat_mod/new_mod = new mod_type
	mod_list += new_mod
	new_mod.modifiers = src
	refresh_mods()

/datum/modifiers/proc/remove_mod_id(id)
	for(var/i in stat_mods)
		var/datum/stat_mod/P = i
		if(P.id == id)
			P.remove()

/datum/modifiers/proc/remove_mod(datum/stat_mod/mod_type)
	for(var/i in stat_mods)
		var/datum/stat_mod/P = i
		if(P.type == mod_type)
			P.remove()

/datum/stat_mod
	var/name = "Physiology Mod"
	var/id = "" //Physiology can only have one mod per id
	var/priority = MODIFIER_ADDITION //Order in which these are applied
	var/datum/modifiers/modifiers

/datum/stat_mod/proc/apply()
	return

/datum/stat_mod/proc/remove()
	qdel(src)

/datum/stat_mod/template
	priority = MODIFIER_TEMPLATE

/datum/stat_mod/subtemplate
	priority = MODIFIER_SUBTEMPLATE

/datum/stat_mod/hardset
	priority = MODIFIER_HARDSET

/datum/stat_mod/addition
	priority = MODIFIER_ADDITION

/datum/stat_mod/add_mult
	priority = MODIFIER_ADD_MULTIPLIER
	var/

/datum/stat_mod/mult_mult
	priority = MODIFIER_MULT_MULTIPLIER

/datum/stat_mod/post_addition
	priority = MODIFIER_POST_ADDITION

/datum/stat_mod/post_hardset
	priority = MODIFIER_POST_HARDSET

///////////////////////////////////PHYSIO MODS/////////////////////////////////////////////////

/datum/stat_mod/spliced_nerves
	name = "Spliced Nerves"
	id = "nerve_stun"

/datum/stat_mod/spliced_nerves/apply()
	physiology.stun_mod *= 0.5

/datum/stat_mod/spliced_nerves/remove()
	physiology.stun_mod /= 0.5
	. = ..()

/datum/stat_mod/threaded_veins
	name = "Threaded Veins"
	id = "vein_bleed"

/datum/stat_mod/threaded_veins/apply()
	physiology.bleed_mod *= 0.25

/datum/stat_mod/threaded_veins/remove()
	physiology.bleed_mod /= 0.25
	. = ..()

/datum/stat_mod/slimeskin
	name = "Slimeskin"
	id = "skin_coating"

/datum/stat_mod/slimeskin/apply()
	physiology.damage_resistance += 10

/datum/stat_mod/slimeskin/remove()
	physiology.damage_resistance -= 10
	. = ..()

/datum/stat_mod/metal_cookie
	name = "Metal Cookie"
	id = "metal_cookie"

/datum/stat_mod/metal_cookie/apply()
	physiology.brute_mod *= 0.9

/datum/stat_mod/metal_cookie/remove()
	physiology.brute_mod /= 0.9
	. = ..()

/datum/stat_mod/adamantine_cookie
	name = "Adamantine Cookie"
	id = "adamantine_cookie"

/datum/stat_mod/adamantine_cookie/apply()
	physiology.burn_mod *= 0.9

/datum/stat_mod/adamantine_cookie/remove()
	physiology.burn_mod /= 0.9
	. = ..()

/datum/stat_mod/stab_silver
	name = "Stabilized Silver"
	id = "stab_silver"

/datum/stat_mod/stab_silver/apply()
	physiology.hunger_mod *= 0.8

/datum/stat_mod/stab_silver/remove()
	physiology.hunger_mod /= 0.8
	. = ..()

/datum/stat_mod/time_cookie
	name = "Time Cookie"
	id = "time_cookie"

/datum/stat_mod/time_cookie/apply()
	physiology.do_after_speed *= 0.9

/datum/stat_mod/time_cookie/remove()
	physiology.do_after_speed /= 0.9
	. = ..()

/datum/stat_mod/tar_foot
	name = "Tar Foot"
	id = "tar_foot"

/datum/stat_mod/tar_foot/apply()
	physiology.speed_mod += 0.5

/datum/stat_mod/tar_foot/remove()
	physiology.speed_mod -= 0.5
	. = ..()

/datum/stat_mod/sepia
	name = "Sepia"
	id = "sepia"
	var/modifier = 0

/datum/stat_mod/sepia/apply()
	modifier = pick(-1, 0, 1)
	physiology.speed_mod += modifier

/datum/stat_mod/sepia/remove()
	physiology.speed_mod -= modifier
	. = ..()

/datum/stat_mod/adamantine_skin
	name = "Adamantine Skin"
	id = "adamantine_skin"

/datum/stat_mod/adamantine_skin/apply()
	physiology.damage_resistance += 5

/datum/stat_mod/adamantine_skin/remove()
	physiology.damage_resistance -= 5
	. = ..()




