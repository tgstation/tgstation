/datum/quirk/item_quirk/addict
	name = "Addict"
	desc = "You are addicted to something that doesn't exist. Suffer."
	gain_text = span_danger("You suddenly feel the craving for... something? You're not sure what it is.")
	medical_record_text = "Patient has a history with SOMETHING but he refuses to tell us what it is."
	abstract_parent_type = /datum/quirk/item_quirk/addict
	var/datum/reagent/reagent_type //!If this is defined, reagent_id will be unused and the defined reagent type will be instead.
	var/datum/reagent/reagent_instance //! actual instanced version of the reagent
	var/where_drug //! Where the drug spawned
	var/obj/item/drug_container_type //! If this is defined before pill generation, pill generation will be skipped. This is the type of the pill bottle.
	var/where_accessory //! where the accessory spawned
	var/obj/item/accessory_type //! If this is null, an accessory won't be spawned.
	var/process_interval = 30 SECONDS //! how frequently the quirk processes
	var/next_process = 0 //! ticker for processing
	var/drug_flavour_text = "Better hope you don't run out... of what, exactly? You don't know."

/datum/quirk/item_quirk/addict/add_unique(client/client_source)
	var/mob/living/carbon/human/human_holder = quirk_holder

	if(!reagent_type)
		reagent_type = GLOB.possible_junkie_addictions[pick(GLOB.possible_junkie_addictions)]

	reagent_instance = new reagent_type()

	for(var/addiction in reagent_instance.addiction_types)
		human_holder.last_mind?.add_addiction_points(addiction, 1000)

	var/current_turf = get_turf(quirk_holder)

	if(!drug_container_type)
		drug_container_type = /obj/item/storage/pill_bottle

	var/obj/item/drug_instance = new drug_container_type(current_turf)
	if(istype(drug_instance, /obj/item/storage/pill_bottle))
		var/pill_state = "pill[rand(1,20)]"
		for(var/i in 1 to 7)
			var/obj/item/reagent_containers/pill/pill = new(drug_instance)
			pill.icon_state = pill_state
			pill.reagents.add_reagent(reagent_type, 3)

	give_item_to_holder(
		drug_instance,
		list(
			LOCATION_LPOCKET = ITEM_SLOT_LPOCKET,
			LOCATION_RPOCKET = ITEM_SLOT_RPOCKET,
			LOCATION_BACKPACK = ITEM_SLOT_BACKPACK,
			LOCATION_HANDS = ITEM_SLOT_HANDS,
		),
		flavour_text = drug_flavour_text,
	)

	if(accessory_type)
		give_item_to_holder(
		accessory_type,
		list(
			LOCATION_LPOCKET = ITEM_SLOT_LPOCKET,
			LOCATION_RPOCKET = ITEM_SLOT_RPOCKET,
			LOCATION_BACKPACK = ITEM_SLOT_BACKPACK,
			LOCATION_HANDS = ITEM_SLOT_HANDS,
		)
	)

/datum/quirk/item_quirk/addict/process(seconds_per_tick)
	if(HAS_TRAIT(quirk_holder, TRAIT_LIVERLESS_METABOLISM))
		return
	var/mob/living/carbon/human/human_holder = quirk_holder
	if(world.time > next_process)
		next_process = world.time + process_interval
		var/deleted = QDELETED(reagent_instance)
		var/missing_addiction = FALSE
		for(var/addiction_type in reagent_instance.addiction_types)
			if(!LAZYACCESS(human_holder.last_mind?.active_addictions, addiction_type))
				missing_addiction = TRUE
		if(deleted || missing_addiction)
			if(deleted)
				reagent_instance = new reagent_type()
			to_chat(quirk_holder, span_danger("You thought you kicked it, but you feel like you're falling back onto bad habits.."))
			for(var/addiction in reagent_instance.addiction_types)
				human_holder.last_mind?.add_addiction_points(addiction, 1000) ///Max that shit out

/datum/quirk/item_quirk/addict/junkie
	name = "Junkie"
	desc = "You can't get enough of hard drugs."
	icon = FA_ICON_PILLS
	value = -6
	gain_text = span_danger("You suddenly feel the craving for drugs.")
	medical_record_text = "Patient has a history of hard drugs."
	hardcore_value = 4
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_PROCESSES
	mail_goodies = list(/obj/effect/spawner/random/contraband/narcotics)
	drug_flavour_text = "Better hope you don't run out..."

/datum/quirk_constant_data/junkie
	associated_typepath = /datum/quirk/item_quirk/addict/junkie
	customization_options = list(/datum/preference/choiced/junkie)

/datum/quirk/item_quirk/addict/junkie/add_unique(client/client_source)

	var/addiction = client_source?.prefs.read_preference(/datum/preference/choiced/junkie)
	if(addiction && (addiction != "Random"))
		reagent_type = GLOB.possible_junkie_addictions[addiction]
	return ..()

/datum/quirk/item_quirk/addict/remove()
	if(quirk_holder && reagent_instance)
		for(var/addiction_type in subtypesof(/datum/addiction))
			quirk_holder.mind.remove_addiction_points(addiction_type, MAX_ADDICTION_POINTS)

/datum/quirk/item_quirk/addict/smoker
	name = "Smoker"
	desc = "Sometimes you just really want a smoke. Probably not great for your lungs."
	icon = FA_ICON_SMOKING
	value = -4
	gain_text = span_danger("You could really go for a smoke right about now.")
	lose_text = span_notice("You don't feel nearly as hooked to nicotine anymore.")
	medical_record_text = "Patient is a current smoker."
	reagent_type = /datum/reagent/drug/nicotine
	accessory_type = /obj/item/lighter/greyscale
	mob_trait = TRAIT_SMOKER
	hardcore_value = 1
	drug_flavour_text = "Make sure you get your favorite brand when you run out."
	mail_goodies = list(
		/obj/effect/spawner/random/entertainment/cigarette_pack,
		/obj/effect/spawner/random/entertainment/cigar,
		/obj/effect/spawner/random/entertainment/lighter,
		/obj/item/cigarette/pipe,
	)

/datum/quirk_constant_data/smoker
	associated_typepath = /datum/quirk/item_quirk/addict/smoker
	customization_options = list(/datum/preference/choiced/smoker)

/datum/quirk/item_quirk/addict/smoker/New()
	drug_container_type = GLOB.possible_smoker_addictions[pick(GLOB.possible_smoker_addictions)]
	return ..()

/datum/quirk/item_quirk/addict/smoker/add_unique(client/client_source)
	var/addiction = client_source?.prefs.read_preference(/datum/preference/choiced/smoker)
	if(addiction && (addiction != "Random"))
		drug_container_type = GLOB.possible_smoker_addictions[addiction]
	return ..()

/datum/quirk/item_quirk/addict/smoker/post_add()
	. = ..()
	quirk_holder.add_mob_memory(/datum/memory/key/quirk_smoker, protagonist = quirk_holder, preferred_brand = initial(drug_container_type.name))
	// smoker lungs have 25% less health and healing
	var/mob/living/carbon/carbon_holder = quirk_holder
	var/obj/item/organ/lungs/smoker_lungs = null
	var/obj/item/organ/lungs/old_lungs = carbon_holder.get_organ_slot(ORGAN_SLOT_LUNGS)
	if(old_lungs && IS_ORGANIC_ORGAN(old_lungs))
		if(isplasmaman(carbon_holder))
			smoker_lungs = /obj/item/organ/lungs/plasmaman/plasmaman_smoker
		else if(isethereal(carbon_holder))
			smoker_lungs = /obj/item/organ/lungs/ethereal/ethereal_smoker
		else
			smoker_lungs = /obj/item/organ/lungs/smoker_lungs
	if(!isnull(smoker_lungs))
		smoker_lungs = new smoker_lungs
		smoker_lungs.Insert(carbon_holder, special = TRUE, movement_flags = DELETE_IF_REPLACED)

/datum/quirk/item_quirk/addict/smoker/process(seconds_per_tick)
	. = ..()
	var/mob/living/carbon/human/human_holder = quirk_holder
	var/obj/item/mask_item = human_holder.get_item_by_slot(ITEM_SLOT_MASK)
	if(istype(mask_item, /obj/item/cigarette))
		var/obj/item/storage/fancy/cigarettes/cigarettes = drug_container_type
		if(istype(mask_item, initial(cigarettes.spawn_type)))
			quirk_holder.clear_mood_event("wrong_cigs")
		else
			quirk_holder.add_mood_event("wrong_cigs", /datum/mood_event/wrong_brand)

/datum/quirk/item_quirk/addict/alcoholic
	name = "Alcoholic"
	desc = "You just can't live without alcohol. Your liver is a machine that turns ethanol into acetaldehyde."
	icon = FA_ICON_WINE_GLASS
	value = -4
	gain_text = span_danger("You really need a drink.")
	lose_text = span_notice("Alcohol doesn't seem nearly as enticing anymore.")
	medical_record_text = "Patient is an alcoholic."
	reagent_type = /datum/reagent/consumable/ethanol
	drug_container_type = /obj/item/reagent_containers/cup/glass/bottle/whiskey
	mob_trait = TRAIT_HEAVY_DRINKER
	hardcore_value = 1
	drug_flavour_text = "Make sure you get your favorite type of drink when you run out."
	mail_goodies = list(
		/obj/effect/spawner/random/food_or_drink/booze,
		/obj/item/book/bible/booze,
	)
	/// Cached typepath of the owner's favorite alcohol reagent
	var/datum/reagent/consumable/ethanol/favorite_alcohol

/datum/quirk_constant_data/alcoholic
	associated_typepath = /datum/quirk/item_quirk/addict/alcoholic
	customization_options = list(/datum/preference/choiced/alcoholic)

/datum/quirk/item_quirk/addict/alcoholic/New()
	var/random_alcohol = pick(GLOB.possible_alcoholic_addictions)
	drug_container_type = GLOB.possible_alcoholic_addictions[random_alcohol]["bottlepath"]
	favorite_alcohol = GLOB.possible_alcoholic_addictions[random_alcohol]["reagent"]
	return ..()

/datum/quirk/item_quirk/addict/alcoholic/add_unique(client/client_source)
	var/addiction = client_source?.prefs.read_preference(/datum/preference/choiced/alcoholic)
	if(addiction && (addiction != "Random"))
		drug_container_type = GLOB.possible_alcoholic_addictions[addiction]["bottlepath"]
		favorite_alcohol = GLOB.possible_alcoholic_addictions[addiction]["reagent"]
	return ..()

/datum/quirk/item_quirk/addict/alcoholic/post_add()
	. = ..()
	RegisterSignal(quirk_holder, COMSIG_MOB_REAGENT_CHECK, PROC_REF(check_brandy))
	var/obj/item/reagent_containers/brandy_container = drug_container_type
	if(isnull(brandy_container))
		stack_trace("Alcoholic quirk added while the GLOB.possible_alcoholic_addictions is (somehow) not initialized!")
		brandy_container = new drug_container_type
		qdel(brandy_container)

	quirk_holder.add_mob_memory(/datum/memory/key/quirk_alcoholic, protagonist = quirk_holder, preferred_brandy = initial(favorite_alcohol.name))
	// alcoholic livers have 25% less health and healing
	var/obj/item/organ/liver/alcohol_liver = quirk_holder.get_organ_slot(ORGAN_SLOT_LIVER)
	if(alcohol_liver && IS_ORGANIC_ORGAN(alcohol_liver)) // robotic livers aren't affected
		alcohol_liver.maxHealth = alcohol_liver.maxHealth * 0.75
		alcohol_liver.healing_factor = alcohol_liver.healing_factor * 0.75

/datum/quirk/item_quirk/addict/alcoholic/remove()
	UnregisterSignal(quirk_holder, COMSIG_MOB_REAGENT_CHECK)

/datum/quirk/item_quirk/addict/alcoholic/proc/check_brandy(mob/source, datum/reagent/booze)
	SIGNAL_HANDLER

	//we don't care if it is not alcohol
	if(!istype(booze, /datum/reagent/consumable/ethanol))
		return

	if(istype(booze, favorite_alcohol))
		quirk_holder.clear_mood_event("wrong_alcohol")
	else
		quirk_holder.add_mood_event("wrong_alcohol", /datum/mood_event/wrong_brandy)
