/datum/disease/advance/sentient_virus
	var/mob/camera/virus/my_virus

	//Flags
	visibility_flags = 0
	disease_flags = CURABLE|CAN_CARRY|CAN_RESIST
	spread_flags = VIRUS_SPREAD_AIRBORNE | VIRUS_SPREAD_CONTACT_FLUIDS | VIRUS_SPREAD_CONTACT_SKIN

	//Fluff
	form = "Virus"
	name = "Sentient Virus"
	desc = ""
	agent = "some microbes"
	spread_text = ""
	cure_text = ""

	//Stages
	stage = 1
	max_stages = 1
	stage_prob = 0

	//Other
	viable_mobtypes = list(/mob/living/carbon/human)
	cures = list()
	infectivity = 65
	cure_chance = 8
	carrier = FALSE
	bypasses_immunity = FALSE
	permeability_mod = 1
	severity = VIRUS_SEVERITY_NONTHREAT
	needs_all_cures = TRUE
	infectable_hosts = list(SPECIES_ORGANIC)
	process_dead = FALSE
	mutable = FALSE

/datum/disease/advance/sentient_virus/New(process = 1, datum/disease/advance/D, master_virus)
	..()
	my_virus = master_virus

/datum/disease/advance/sentient_virus/generate_from(datum/disease/advance/D)
	if(istype(D, /datum/disease/advance/sentient_virus))
		for(var/datum/symptom/S in D.symptoms)
			var/datum/symptom/new_symp = S.Copy()
			symptoms += new_symp

/datum/disease/advance/sentient_virus/Destroy()
	return ..()

/datum/disease/advance/sentient_virus/stage_act()
	return

/datum/disease/advance/sentient_virus/cure(add_resistance = TRUE)
	..()
	if(my_virus)
		my_virus.remove_infection(src)

/datum/disease/advance/sentient_virus/IsSame(datum/disease/D)
	if(istype(src, D.type))
		var/datum/disease/advance/sentient_virus/V = D
		if(V.my_virus == my_virus)
			return TRUE
	return FALSE


/datum/disease/advance/sentient_virus/Copy()
	var/datum/disease/advance/sentient_virus/D = new type()
	D.strain_data = strain_data.Copy()
	D.my_virus = my_virus
	return D

/datum/disease/advance/sentient_virus/after_add()
	if(my_virus)
		my_virus.add_infection(src)


/datum/disease/advance/sentient_virus/GetDiseaseID()
	return "[type]|[my_virus ? my_virus.tag : null]"
