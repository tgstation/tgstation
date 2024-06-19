/datum/quirk/item_quirk/allergic
	name = "Extreme Medicine Allergy"
	desc = "Ever since you were a kid, you've been allergic to certain chemicals..."
	icon = FA_ICON_PRESCRIPTION_BOTTLE
	value = -6
	gain_text = span_danger("You feel your immune system shift.")
	lose_text = span_notice("You feel your immune system phase back into perfect shape.")
	medical_record_text = "Patient's immune system responds violently to certain chemicals."
	hardcore_value = 3
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_PROCESSES
	mail_goodies = list(/obj/item/reagent_containers/hypospray/medipen) // epinephrine medipen stops allergic reactions
	var/list/allergies = list()
	var/list/blacklist = list(
		/datum/reagent/medicine/c2,
		/datum/reagent/medicine/epinephrine,
		/datum/reagent/medicine/adminordrazine,
		/datum/reagent/medicine/adminordrazine/quantum_heal,
		/datum/reagent/medicine/omnizine/godblood,
		/datum/reagent/medicine/cordiolis_hepatico,
		/datum/reagent/medicine/synaphydramine,
		/datum/reagent/medicine/diphenhydramine,
		/datum/reagent/medicine/sansufentanyl
		)
	var/allergy_string

/datum/quirk/item_quirk/allergic/add_unique(client/client_source)
	var/list/chem_list = subtypesof(/datum/reagent/medicine) - blacklist
	var/list/allergy_chem_names = list()
	for(var/i in 0 to 5)
		var/datum/reagent/medicine/chem_type = pick_n_take(chem_list)
		allergies += chem_type
		allergy_chem_names += initial(chem_type.name)

	allergy_string = allergy_chem_names.Join(", ")
	name = "Extreme [allergy_string] Allergies"
	medical_record_text = "Patient's immune system responds violently to [allergy_string]"

	var/mob/living/carbon/human/human_holder = quirk_holder
	var/obj/item/clothing/accessory/dogtag/allergy/dogtag = new(get_turf(human_holder), allergy_string)

	give_item_to_holder(dogtag, list(LOCATION_BACKPACK = ITEM_SLOT_BACKPACK, LOCATION_HANDS = ITEM_SLOT_HANDS), flavour_text = "Make sure medical staff can see this...")

/datum/quirk/item_quirk/allergic/post_add()
	quirk_holder.add_mob_memory(/datum/memory/key/quirk_allergy, allergy_string = allergy_string)
	to_chat(quirk_holder, span_boldnotice("You are allergic to [allergy_string], make sure not to consume any of these!"))

/datum/quirk/item_quirk/allergic/process(seconds_per_tick)
	if(!iscarbon(quirk_holder))
		return

	if(HAS_TRAIT(quirk_holder, TRAIT_STASIS))
		return

	if(quirk_holder.stat == DEAD)
		return

	var/mob/living/carbon/carbon_quirk_holder = quirk_holder
	//Just halts the progression, I'd suggest you run to medbay asap to get it fixed
	if(carbon_quirk_holder.reagents.has_reagent(/datum/reagent/medicine/epinephrine))
		for(var/allergy in allergies)
			var/datum/reagent/instantiated_med = carbon_quirk_holder.reagents.has_reagent(allergy)
			if(!instantiated_med)
				continue
			instantiated_med.reagent_removal_skip_list |= ALLERGIC_REMOVAL_SKIP
		return //block damage so long as epinephrine exists

	for(var/allergy in allergies)
		var/datum/reagent/instantiated_med = carbon_quirk_holder.reagents.has_reagent(allergy)
		if(!instantiated_med)
			continue
		instantiated_med.reagent_removal_skip_list -= ALLERGIC_REMOVAL_SKIP
		carbon_quirk_holder.adjustToxLoss(3 * seconds_per_tick)
		carbon_quirk_holder.reagents.add_reagent(/datum/reagent/toxin/histamine, 3 * seconds_per_tick)
		if(SPT_PROB(10, seconds_per_tick))
			carbon_quirk_holder.vomit(VOMIT_CATEGORY_DEFAULT)
			carbon_quirk_holder.adjustOrganLoss(pick(ORGAN_SLOT_BRAIN,ORGAN_SLOT_APPENDIX,ORGAN_SLOT_LUNGS,ORGAN_SLOT_HEART,ORGAN_SLOT_LIVER,ORGAN_SLOT_STOMACH),10)
