/// Become the official Captain of the station
/datum/grand_finale/usurp
	name = "Usurpation"
	desc = "The ultimate use of your gathered power! Rewrite time such that you have been Captain of this station the whole time."
	icon = 'icons/obj/card.dmi'
	icon_state = "card_gold"

/datum/grand_finale/usurp/trigger(mob/living/carbon/human/invoker)
	message_admins("[key_name(invoker)] has replaced the Captain")
	var/list/former_captains = list()
	var/list/other_crew = list()
	SEND_SOUND(world, sound('sound/effects/magic/timeparadox2.ogg'))

	for (var/mob/living/carbon/human/crewmate as anything in GLOB.human_list)
		if (!crewmate.mind)
			continue
		crewmate.Unconscious(3 SECONDS) // Everyone falls unconscious but not everyone gets told about a new captain
		if (crewmate == invoker || IS_HUMAN_INVADER(crewmate))
			continue
		to_chat(crewmate, span_notice("The world spins and dissolves. Your past flashes before your eyes, backwards.\n\
			Life strolls back into the ocean and shrinks into nothingness, planets explode into storms of solar dust, \
			the stars rush back to greet each other at the beginning of things and then... you snap back to the present. \n\
			Everything is just as it was and always has been. \n\n\
			A stray thought sticks in the forefront of your mind. \n\
			[span_hypnophrase("I'm so glad that [invoker.real_name] is our legally appointed Captain!")] \n\
			Is... that right?"))
		if (is_captain_job(crewmate.mind.assigned_role))
			former_captains += crewmate
			demote_to_assistant(crewmate)
			continue
		if (crewmate.stat != DEAD)
			other_crew += crewmate

	dress_candidate(invoker)
	GLOB.manifest.modify(invoker.real_name, JOB_CAPTAIN, JOB_CAPTAIN)
	minor_announce("Captain [invoker.real_name] on deck!")

	// Enlist some crew to try and restore the natural order
	for (var/mob/living/carbon/human/former_captain as anything in former_captains)
		create_vendetta(former_captain.mind, invoker.mind)
	for (var/mob/living/carbon/human/random_crewmate as anything in other_crew)
		if (prob(10))
			create_vendetta(random_crewmate.mind, invoker.mind)

/**
 * Anyone who thought they were Captain is in for a nasty surprise, and won't be very happy about it
 */
/datum/grand_finale/usurp/proc/demote_to_assistant(mob/living/carbon/human/former_captain)
	var/obj/effect/particle_effect/fluid/smoke/exit_poof = new(get_turf(former_captain))
	exit_poof.lifetime = 2 SECONDS

	former_captain.unequip_everything()
	if(isplasmaman(former_captain))
		former_captain.equipOutfit(/datum/outfit/plasmaman)
		former_captain.internal = former_captain.get_item_for_held_index(2)
	else
		former_captain.equipOutfit(/datum/outfit/job/assistant)

	GLOB.manifest.modify(former_captain.real_name, JOB_ASSISTANT, JOB_ASSISTANT)
	var/list/valid_turfs = list()
	// Used to be into prison but that felt a bit too mean
	for (var/turf/exile_turf as anything in get_area_turfs(/area/station/maintenance, subtypes = TRUE))
		if (isspaceturf(exile_turf) || exile_turf.is_blocked_turf())
			continue
		valid_turfs += exile_turf
	do_teleport(former_captain, pick(valid_turfs), no_effects = TRUE)
	var/obj/effect/particle_effect/fluid/smoke/enter_poof = new(get_turf(former_captain))
	enter_poof.lifetime = 2 SECONDS

/**
 * Does some item juggling to try to dress you as both a Wizard and Captain without deleting any items you have bought.
 * ID, headset, and uniform are forcibly replaced. Other slots are only filled if unoccupied.
 * We could forcibly replace shoes and gloves too but people might miss their insuls or... meown shoes?
 */
/datum/grand_finale/usurp/proc/dress_candidate(mob/living/carbon/human/invoker)
	// Won't be needing these
	var/obj/id = invoker.get_item_by_slot(ITEM_SLOT_ID)
	QDEL_NULL(id)
	var/obj/headset = invoker.get_item_by_slot(ITEM_SLOT_EARS)
	QDEL_NULL(headset)
	// We're about to take off your pants so those are going to fall out
	var/obj/item/pocket_L = invoker.get_item_by_slot(ITEM_SLOT_LPOCKET)
	var/obj/item/pocket_R = invoker.get_item_by_slot(ITEM_SLOT_RPOCKET)
	// In case we try to put a PDA there
	var/obj/item/belt = invoker.get_item_by_slot(ITEM_SLOT_BELT)
	belt?.moveToNullspace()

	var/obj/pants = invoker.get_item_by_slot(ITEM_SLOT_ICLOTHING)
	QDEL_NULL(pants)
	invoker.equipOutfit(/datum/outfit/job/wizard_captain)
	// And put everything back!
	equip_to_slot_then_hands(invoker, ITEM_SLOT_BELT, belt)
	equip_to_slot_then_hands(invoker, ITEM_SLOT_LPOCKET, pocket_L)
	equip_to_slot_then_hands(invoker, ITEM_SLOT_RPOCKET, pocket_R)

/// An outfit which replaces parts of a wizard's clothes with captain's clothes but keeps the robes
/datum/outfit/job/wizard_captain
	name = "Captain (Wizard Transformation)"
	jobtype = /datum/job/captain
	id = /obj/item/card/id/advanced/gold
	id_trim = /datum/id_trim/job/captain
	uniform = /obj/item/clothing/under/rank/captain/parade
	belt = /obj/item/modular_computer/pda/heads/captain
	ears = /obj/item/radio/headset/heads/captain/alt
	glasses = /obj/item/clothing/glasses/sunglasses
	gloves = /obj/item/clothing/gloves/captain
	shoes = /obj/item/clothing/shoes/laceup
	accessory = /obj/item/clothing/accessory/medal/gold/captain
	backpack_contents = list(
		/obj/item/melee/baton/telescopic = 1,
		/obj/item/station_charter = 1,
	)
	box = null
