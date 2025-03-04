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
	no_process_traits = list(TRAIT_STASIS)

	/// Weak reference to the component handling our allergies
	var/datum/weakref/added_allergies
	/// Reagents we are blacklisted from rolling
	var/static/list/blacklist = list(
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
	var/list/allergies = list()
	var/list/allergy_chem_names = list()
	for(var/i in 0 to 5)
		var/datum/reagent/medicine/chem_type = pick_n_take(chem_list)
		allergies += chem_type
		allergy_chem_names += initial(chem_type.name)
	added_allergies = WEAKREF(quirk_holder.AddComponent(/datum/component/reagent_allergies, allergy_types = allergies))

	allergy_string = english_list(allergy_chem_names)
	name = "Extreme [allergy_string] Allergies"
	medical_record_text = "Patient's immune system responds violently to [allergy_string]."

	var/mob/living/carbon/human/human_holder = quirk_holder
	var/obj/item/clothing/accessory/dogtag/allergy/dogtag = new(get_turf(human_holder), allergy_string)

	give_item_to_holder(dogtag, list(LOCATION_BACKPACK = ITEM_SLOT_BACKPACK, LOCATION_HANDS = ITEM_SLOT_HANDS), flavour_text = "Make sure medical staff can see this...")

/datum/quirk/item_quirk/allergic/post_add()
	quirk_holder.add_mob_memory(/datum/memory/key/quirk_allergy, allergy_string = allergy_string)
	to_chat(quirk_holder, span_boldnotice("You are allergic to [allergy_string], make sure not to consume any of these!"))

/datum/quirk/item_quirk/allergic/remove()
	QDEL_NULL(added_allergies)
