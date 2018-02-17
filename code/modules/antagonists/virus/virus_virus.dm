/datum/disease/sentient_virus
	var/mob/camera/virus/my_virus
	/*
	//Flags
	var/visibility_flags = 0
	var/disease_flags = CURABLE|CAN_CARRY|CAN_RESIST
	var/spread_flags = VIRUS_SPREAD_AIRBORNE | VIRUS_SPREAD_CONTACT_FLUIDS | VIRUS_SPREAD_CONTACT_SKIN

	//Fluff
	var/form = "Virus"
	var/name = "No disease"
	var/desc = ""
	var/agent = "some microbes"
	var/spread_text = ""
	var/cure_text = ""

	//Stages
	var/stage = 1
	var/max_stages = 0
	var/stage_prob = 4

	//Other
	var/list/viable_mobtypes = list() //typepaths of viable mobs
	var/mob/living/carbon/affected_mob = null
	var/list/cures = list() //list of cures if the disease has the CURABLE flag, these are reagent ids
	var/infectivity = 65
	var/cure_chance = 8
	var/carrier = FALSE //If our host is only a carrier
	var/bypasses_immunity = FALSE //Does it skip species virus immunity check? Some things may diseases and not viruses
	var/permeability_mod = 1
	var/severity = VIRUS_SEVERITY_POSITIVE
	var/list/required_organs = list()
	var/needs_all_cures = TRUE
	var/list/strain_data = list() //dna_spread special bullshit
	var/list/infectable_hosts = list(SPECIES_ORGANIC) //if the disease can spread on organics, synthetics, or undead
	var/process_dead = FALSE //if this ticks while the host is dead
	*/

/datum/disease/sentient_virus/Destroy()
	return ..()

/datum/disease/sentient_virus/stage_act()
	return


/datum/disease/sentient_virus/has_cure()
	if(!(disease_flags & CURABLE))
		return FALSE

	. = cures.len
	for(var/C_id in cures)
		if(!affected_mob.reagents.has_reagent(C_id))
			.--
	if(!. || (needs_all_cures && . < cures.len))
		return FALSE

//Airborne spreading
/datum/disease/sentient_virus/spread(force_spread = 0)
	. = ..()
	/*
	if(!affected_mob)
		return

	if(!(spread_flags & VIRUS_SPREAD_AIRBORNE) && !force_spread)
		return

	if(affected_mob.reagents.has_reagent("spaceacillin") || (affected_mob.satiety > 0 && prob(affected_mob.satiety/10)))
		return

	var/spread_range = 2

	if(force_spread)
		spread_range = force_spread

	var/turf/T = affected_mob.loc
	if(istype(T))
		for(var/mob/living/carbon/C in oview(spread_range, affected_mob))
			var/turf/V = get_turf(C)
			if(V)
				while(TRUE)
					if(V == T)
						C.AirborneContractDisease(src)
						break
					var/turf/Temp = get_step_towards(V, T)
					if(!CANATMOSPASS(V, Temp))
						break
					V = Temp
	*/

/datum/disease/sentient_virus/cure(add_resistance = TRUE)
	..()
	if(my_virus)
		my_virus.remove_infection(src)

/datum/disease/sentient_virus/IsSame(datum/disease/D)
	if(istype(src, D.type))
		var/datum/disease/sentient_virus/V = D
		if(V.my_virus == my_virus)
			return TRUE
	return FALSE


/datum/disease/sentient_virus/Copy()
	var/datum/disease/D = new type()
	D.strain_data = strain_data.Copy()
	return D

/datum/disease/sentient_virus/after_add()
	if(my_virus)
		my_virus.add_infection(src)
	return


/datum/disease/sentient_virus/GetDiseaseID()
	return "[type]|[my_virus ? my_virus.tag : null]"
