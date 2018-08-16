/*				MEDICAL OBJECTIVES				*/

/datum/objective/crew/morgue //Ported from old Hippie
	explanation_text = "Ensure there are no corpses on the station outside of the morgue when the shift ends."
	jobs = "chiefmedicalofficer,geneticist,medicaldoctor"

/datum/objective/crew/morgue/check_completion()
	for(var/mob/living/carbon/human/H in GLOB.mob_list)
		if(H.stat == DEAD && H.z == SSmapping.station_start)
			if(get_area(H) != /area/medical/morgue)
				return FALSE
	return TRUE

/datum/objective/crew/chems //Ported from old Hippie
	var/targetchem = "none"
	var/datum/reagent/chempath
	explanation_text = "Have (yell about this in the development discussion channel of citadel's discord, something broke) in your bloodstream when the shift ends."
	jobs = "chiefmedicalofficer,chemist"

/datum/objective/crew/chems/New()
	. = ..()
	var/blacklist = list(/datum/reagent/drug, /datum/reagent/drug/nicotine, /datum/reagent/drug/menthol, /datum/reagent/medicine, /datum/reagent/medicine/adminordrazine, /datum/reagent/medicine/adminordrazine/nanites, /datum/reagent/medicine/mine_salve, /datum/reagent/medicine/omnizine, /datum/reagent/medicine/syndicate_nanites, /datum/reagent/medicine/earthsblood, /datum/reagent/medicine/strange_reagent, /datum/reagent/medicine/miningnanites, /datum/reagent/medicine/changelingadrenaline, /datum/reagent/medicine/changelinghaste)
	var/drugs = typesof(/datum/reagent/drug) - blacklist
	var/meds = typesof(/datum/reagent/medicine) - blacklist
	var/chemlist = drugs + meds
	chempath = pick(chemlist)
	targetchem = initial(chempath.id)
	update_explanation_text()

/datum/objective/crew/chems/update_explanation_text()
	. = ..()
	explanation_text = "Have [initial(chempath.name)] in your bloodstream when the shift ends."

/datum/objective/crew/chems/check_completion()
	if(owner.current)
		if(!owner.current.stat == DEAD && owner.current.reagents)
			if(owner.current.reagents.has_reagent(targetchem))
				return TRUE
	else
		return FALSE

/datum/objective/crew/druglordchem //ported from old Hippie with adjustments
	var/targetchem = "none"
	var/datum/reagent/chempath
	var/chemamount = 0
	explanation_text = "Have at least (somethin broke here) pills containing at least (like really broke) units of(report this on the development discussion channel of citadel's discord) when the shift ends."
	jobs = "chemist"

/datum/objective/crew/druglordchem/New()
	. = ..()
	target_amount = rand(5,50)
	chemamount = rand(1,20)
	var/blacklist = list(/datum/reagent/drug, /datum/reagent/drug/nicotine, /datum/reagent/drug/menthol)
	var/drugs = typesof(/datum/reagent/drug) - blacklist
	var/chemlist = drugs
	chempath = pick(chemlist)
	targetchem = initial(chempath.id)
	update_explanation_text()

/datum/objective/crew/druglordchem/update_explanation_text()
	. = ..()
	explanation_text = "Have at least [target_amount] pills containing at least [chemamount] units of [initial(chempath.name)] when the shift ends."

/datum/objective/crew/druglordchem/check_completion()
	var/pillcount = target_amount
	if(owner.current)
		if(owner.current.contents)
			for(var/obj/item/reagent_containers/pill/P in owner.current.get_contents())
				if(P.reagents.has_reagent(targetchem, chemamount))
					pillcount--
	if(pillcount <= 0)
		return TRUE
	else
		return FALSE

/datum/objective/crew/noinfections
	explanation_text = "Make sure there are no crew members with harmful diseases at the end of the shift."
	jobs = "virologist"

/datum/objective/crew/noinfections/check_completion()
	for(var/mob/living/carbon/human/H in GLOB.mob_list)
		if(!H.stat == DEAD)
			if(H.z == SSmapping.station_start || SSshuttle.emergency.shuttle_areas[get_area(H)])
				if(H.check_virus() == 2)
					return FALSE
	return TRUE
