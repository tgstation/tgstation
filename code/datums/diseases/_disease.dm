
//Visibility Flags
#define HIDDEN_SCANNER	1
#define HIDDEN_PANDEMIC	2

//Disease Flags
#define CURABLE		1
#define CAN_CARRY	2
#define CAN_RESIST	4

//Spread Flags
#define SPECIAL 1
#define NON_CONTAGIOUS 2
#define BLOOD 4
#define CONTACT_FEET 8
#define CONTACT_HANDS 16
#define CONTACT_GENERAL 32
#define AIRBORNE 64


//Severity Defines
#define NONTHREAT	"No threat"
#define MINOR		"Minor"
#define MEDIUM		"Medium"
#define HARMFUL		"Harmful"
#define DANGEROUS 	"Dangerous!"
#define BIOHAZARD	"BIOHAZARD THREAT!"

/datum/disease
	//Flags
	var/visibility_flags = 0
	var/disease_flags = CURABLE|CAN_CARRY|CAN_RESIST
	var/spread_flags = AIRBORNE

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
	var/severity =	NONTHREAT
	var/list/required_organs = list()
	var/needs_all_cures = TRUE
	var/list/strain_data = list() //dna_spread special bullshit

/datum/disease/Destroy()
	affected_mob = null
	SSdisease.active_diseases.Remove(src)
	return ..()

/datum/disease/proc/stage_act()
	var/cure = has_cure()

	if(carrier && !cure)
		return

	stage = min(stage, max_stages)

	if(!cure)
		if(prob(stage_prob))
			stage = min(stage + 1,max_stages)
	else
		if(prob(cure_chance))
			stage = max(stage - 1, 1)

	if(disease_flags & CURABLE)
		if(cure && prob(cure_chance))
			cure()


/datum/disease/proc/has_cure()
	if(!(disease_flags & CURABLE))
		return 0

	. = cures.len
	for(var/C_id in cures)
		if(!affected_mob.reagents.has_reagent(C_id))
			.--
	if(!. || (needs_all_cures && . < cures.len))
		return 0


/datum/disease/proc/spread(force_spread = 0)
	if(!affected_mob)
		return

	if((spread_flags & SPECIAL || spread_flags & NON_CONTAGIOUS || spread_flags & BLOOD) && !force_spread)
		return

	if(affected_mob.reagents.has_reagent("spaceacillin") || (affected_mob.satiety > 0 && prob(affected_mob.satiety/10)))
		return

	var/spread_range = 1

	if(force_spread)
		spread_range = force_spread

	if(spread_flags & AIRBORNE)
		spread_range++

	var/turf/T = affected_mob.loc
	if(istype(T))
		for(var/mob/living/carbon/C in oview(spread_range, affected_mob))
			var/turf/V = get_turf(C)
			if(V)
				while(TRUE)
					if(V == T)
						C.ContractDisease(src)
						break
					var/turf/Temp = get_step_towards(V, T)
					if(!CANATMOSPASS(V, Temp))
						break
					V = Temp


/datum/disease/proc/cure()
	if(affected_mob)
		if(disease_flags & CAN_RESIST)
			if(!(type in affected_mob.resistances))
				affected_mob.resistances += type
		remove_virus()
	qdel(src)

/datum/disease/proc/IsSame(datum/disease/D)
	if(istype(src, D.type))
		return 1
	return 0


/datum/disease/proc/Copy()
	var/datum/disease/D = new type()
	D.strain_data = strain_data.Copy()
	return D


/datum/disease/proc/GetDiseaseID()
	return type


/datum/disease/proc/IsSpreadByTouch()
	if(spread_flags & CONTACT_FEET || spread_flags & CONTACT_HANDS || spread_flags & CONTACT_GENERAL)
		return 1
	return 0

//don't use this proc directly. this should only ever be called by cure()
/datum/disease/proc/remove_virus()
	affected_mob.viruses -= src		//remove the datum from the list
	affected_mob.med_hud_set_status()
