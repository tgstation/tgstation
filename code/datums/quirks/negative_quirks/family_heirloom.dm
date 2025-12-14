/datum/quirk/item_quirk/family_heirloom
	name = "Family Heirloom"
	desc = "You are the current owner of an heirloom, passed down for generations. You have to keep it safe!"
	icon = FA_ICON_TOOLBOX
	value = -2
	medical_record_text = "Patient demonstrates an unnatural attachment to a family heirloom."
	hardcore_value = 1
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_PROCESSES|QUIRK_MOODLET_BASED
	/// A weak reference to our heirloom.
	var/datum/weakref/heirloom
	mail_goodies = list(/obj/item/storage/briefcase/secure)

/datum/quirk/item_quirk/family_heirloom/add_unique(client/client_source)
	var/mob/living/carbon/human/human_holder = quirk_holder
	var/obj/item/heirloom_type

	// The quirk holder's species - we have a 50% chance, if we have a species with a set heirloom, to choose a species heirloom.
	var/datum/species/holder_species = human_holder.dna?.species
	if(holder_species && LAZYLEN(holder_species.family_heirlooms) && prob(50))
		heirloom_type = pick(holder_species.family_heirlooms)
	else
		// Our quirk holder's job
		var/datum/job/holder_job = human_holder.last_mind?.assigned_role
		if(holder_job && LAZYLEN(holder_job.family_heirlooms))
			heirloom_type = pick(holder_job.family_heirlooms)

	// If we didn't find an heirloom somehow, throw them a generic one
	if(!heirloom_type)
		heirloom_type = pick(/obj/item/toy/cards/deck, /obj/item/lighter, /obj/item/dice/d20)

	var/obj/new_heirloom = new heirloom_type(get_turf(human_holder))
	heirloom = WEAKREF(new_heirloom)

	give_item_to_holder(
		new_heirloom,
		list(
			LOCATION_LPOCKET,
			LOCATION_RPOCKET,
			LOCATION_BACKPACK,
			LOCATION_HANDS,
		),
		flavour_text = "This is a precious family heirloom, passed down from generation to generation. Keep it safe!",
		notify_player = TRUE,
	)

/datum/quirk/item_quirk/family_heirloom/post_add()
	var/list/names = splittext(quirk_holder.real_name, " ")
	var/family_name = names[names.len]

	var/obj/family_heirloom = heirloom?.resolve()
	if(!family_heirloom)
		to_chat(quirk_holder, span_boldnotice("A wave of existential dread runs over you as you realize your precious family heirloom is missing. Perhaps the Gods will show mercy on your cursed soul?"))
		return
	family_heirloom.AddComponent(/datum/component/heirloom, quirk_holder.mind, family_name)

	return ..()

/datum/quirk/item_quirk/family_heirloom/process()
	var/obj/family_heirloom = heirloom?.resolve()

	if(family_heirloom && quirk_holder.contains(family_heirloom))
		quirk_holder.clear_mood_event("family_heirloom_missing")
		quirk_holder.add_mood_event("family_heirloom", /datum/mood_event/family_heirloom)
	else
		quirk_holder.clear_mood_event("family_heirloom")
		quirk_holder.add_mood_event("family_heirloom_missing", /datum/mood_event/family_heirloom_missing)

/datum/quirk/item_quirk/family_heirloom/remove()
	quirk_holder.clear_mood_event("family_heirloom_missing")
	quirk_holder.clear_mood_event("family_heirloom")
