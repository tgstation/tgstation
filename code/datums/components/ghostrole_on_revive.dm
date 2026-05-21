/// Proc ghosts to enter the body when it get's revived
/datum/component/ghostrole_on_revive
	/// If revived and no ghosts, just die again?
	var/refuse_revival_if_failed
	/// Callback for when the mob is revived and has their body occupied by a ghost
	var/datum/callback/on_successful_revive
	/// The chance to twitch when orbiting the spawn
	var/twitch_chance = 30
	/// The title shown to ghosts when polled to enter the body
	var/revive_title

	// Text displayed in the spawners menu
	var/spawn_text
	var/you_are_text
	var/flavor_text
	var/important_text

/datum/component/ghostrole_on_revive/Initialize(
	refuse_revival_if_failed = FALSE,
	datum/callback/on_successful_revive,
	revive_title = "a recovered crewmember",
	spawn_text = "Recovered Crew",
	you_are_text = "You are a long dead crewmember, but are soon to be revived to rejoin the crew!",
	flavor_text = "Get a job and get back to work!",
	important_text = "Do your best to help the station. You still roll for midround antagonists."
)
	src.refuse_revival_if_failed = refuse_revival_if_failed
	src.on_successful_revive = on_successful_revive
	src.revive_title = revive_title
	src.spawn_text = spawn_text
	src.you_are_text = you_are_text
	src.flavor_text = flavor_text
	src.important_text = important_text

	if(ismob(parent))
		prepare_mob(parent)
		return

	if(!istype(parent, /obj/item/organ/brain))
		return COMPONENT_INCOMPATIBLE

	var/obj/item/organ/brain/brain_parent = parent
	if(brain_parent.owner)
		prepare_mob(brain_parent.owner)
	else
		prepare_brain(brain_parent)

/// Give the appropriate signals, and watch for organ removal
/datum/component/ghostrole_on_revive/proc/prepare_mob(mob/living/to_prepare)
	RegisterSignal(to_prepare, COMSIG_LIVING_REVIVE, PROC_REF(on_revive))
	RegisterSignal(to_prepare, COMSIG_MOB_REAGENT_TICK, PROC_REF(block_formaldehyde_metabolism))
	if(istype(parent, /obj/item/organ/brain))
		RegisterSignal(to_prepare, COMSIG_CARBON_LOSE_ORGAN, PROC_REF(on_remove))
	ADD_TRAIT(to_prepare, TRAIT_GHOSTROLE_ON_REVIVE, REF(src))

	add_orbit_twitching(to_prepare)
	to_prepare.med_hud_set_status()

/datum/component/ghostrole_on_revive/proc/unprepare_mob(mob/living/to_unprepare)
	REMOVE_TRAIT(to_unprepare, TRAIT_GHOSTROLE_ON_REVIVE, REF(src))
	UnregisterSignal(to_unprepare, list(
		COMSIG_LIVING_REVIVE,
		COMSIG_MOB_REAGENT_TICK,
		COMSIG_CARBON_LOSE_ORGAN,
	))

	to_unprepare.med_hud_set_status()
	remove_orbit_twitching(to_unprepare)

/datum/component/ghostrole_on_revive/proc/on_remove(mob/living/carbon/source, obj/item/organ/removed_brain)
	SIGNAL_HANDLER

	if(!istype(removed_brain, /obj/item/organ/brain))
		return

	unprepare_mob(source)

	// we might have some lingering blinking eyes
	var/obj/item/bodypart/head/head = source.get_bodypart(BODY_ZONE_HEAD)
	if(head)
		var/soul_eyes = locate(/datum/bodypart_overlay/simple/soul_pending_eyes) in head.bodypart_overlays
		if(soul_eyes)
			head.remove_bodypart_overlay(soul_eyes)

	prepare_brain(removed_brain)

/datum/component/ghostrole_on_revive/proc/prepare_brain(obj/item/organ/source)
	ADD_TRAIT(source, TRAIT_GHOSTROLE_ON_REVIVE, REF(src))
	RegisterSignal(source, COMSIG_ORGAN_IMPLANTED, PROC_REF(prepare_mob_from_brain))
	RegisterSignal(source, COMSIG_ATOM_EXAMINE, PROC_REF(brain_examine))
	UnregisterSignal(source, COMSIG_ORGAN_REMOVED)

/datum/component/ghostrole_on_revive/proc/unprepare_brain(obj/item/organ/source)
	REMOVE_TRAIT(source, TRAIT_GHOSTROLE_ON_REVIVE, REF(src))
	UnregisterSignal(source, COMSIG_ORGAN_IMPLANTED)
	UnregisterSignal(source, COMSIG_ATOM_EXAMINE)
	RegisterSignal(source, COMSIG_ORGAN_REMOVED, PROC_REF(prepare_brain))
	source.owner?.med_hud_set_status()

/datum/component/ghostrole_on_revive/proc/prepare_mob_from_brain(obj/item/organ/brain/source, mob/living/owner)
	SIGNAL_HANDLER

	REMOVE_TRAIT(source, TRAIT_GHOSTROLE_ON_REVIVE, REF(src))
	UnregisterSignal(source, COMSIG_ORGAN_IMPLANTED)
	prepare_mob(owner)

/datum/component/ghostrole_on_revive/proc/brain_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	examine_list += span_info("Another soul may take [source.p_their()] place if put in a body...")

/datum/component/ghostrole_on_revive/proc/on_revive(mob/living/source)
	SIGNAL_HANDLER

	INVOKE_ASYNC(src, PROC_REF(poll_ghosts), source)

/datum/component/ghostrole_on_revive/proc/poll_ghosts(mob/living/reviving)
	var/datum/bodypart_overlay/simple/soul_pending_eyes/soul_eyes
	// adds soulful SOUL PENDING eyes to indicate what's happening to observers
	var/obj/item/bodypart/head/head = reviving.get_bodypart(BODY_ZONE_HEAD)
	if(head)
		soul_eyes = new()
		head.add_bodypart_overlay(soul_eyes)

	var/list/jobbans = list(ROLE_RECOVERED_CREW)
	if(reviving.mind)
		jobbans |= reviving.mind.assigned_role.title
		for(var/datum/antagonist/antag as anything in reviving.mind.antag_datums)
			if(antag.jobban_flag)
				jobbans |= antag.jobban_flag
			if(antag.pref_flag)
				jobbans |= antag.pref_flag
			if(!(antag.antag_flags & ANTAG_FAKE))
				jobbans |= ROLE_SYNDICATE

	var/mob/dead/observer/chosen_one = SSpolling.poll_ghosts_for_target(
		question = "Would you like to play as [revive_title]?",
		check_jobban = jobbans,
		poll_time = 15 SECONDS,
		checked_target = reviving,
		ignore_category = POLL_IGNORE_RECOVERED_CREW,
		alert_pic = reviving,
		role_name_text = revive_title,
	)

	if(head)
		head.remove_bodypart_overlay(soul_eyes)
	if(soul_eyes)
		qdel(soul_eyes)

	if(isobserver(chosen_one))
		reviving.PossessByPlayer(chosen_one.ckey)
		on_successful_revive?.Invoke(reviving)
		qdel(src)

	else if(refuse_revival_if_failed)
		reviving.death()
		reviving.visible_message(span_deadsay("[reviving]'s soul is struggling to return!"))


/datum/component/ghostrole_on_revive/proc/add_orbit_twitching(mob/living/parent_mob)
	parent_mob.AddElement(/datum/element/orbit_twitcher, twitch_chance)
	// Add it to the ghostrole spawner menu. Note that we can't directly spawn from it, but we can make it twitch to alert bystanders to defib it
	LAZYADDASSOCLIST(GLOB.joinable_mobs, spawn_text, parent_mob)
	RegisterSignal(parent_mob, COMSIG_LIVING_GHOSTROLE_INFO, PROC_REF(set_spawner_info))

/datum/component/ghostrole_on_revive/proc/set_spawner_info(datum/spawners_menu/menu, list/string_info)
	SIGNAL_HANDLER

	string_info["you_are_text"] = src.you_are_text
	string_info["flavor_text"] = src.flavor_text
	string_info["important_text"] = src.important_text

/datum/component/ghostrole_on_revive/proc/remove_orbit_twitching(mob/living/parent_mob)
	parent_mob.RemoveElement(/datum/element/orbit_twitcher, twitch_chance)
	LAZYREMOVEASSOC(GLOB.joinable_mobs, spawn_text, parent_mob)
	UnregisterSignal(parent_mob, COMSIG_LIVING_GHOSTROLE_INFO)

// Block formaldehyde from being metabolized, Coroner QoL
/datum/component/ghostrole_on_revive/proc/block_formaldehyde_metabolism(mob/living/source, datum/reagent/chem)
	SIGNAL_HANDLER

	if(istype(chem, /datum/reagent/toxin/formaldehyde))
		return COMSIG_MOB_STOP_REAGENT_TICK

/datum/component/ghostrole_on_revive/Destroy(force)
	if(isliving(parent))
		unprepare_mob(parent)

	else if(istype(parent, /obj/item/organ/brain))
		var/obj/item/organ/brain/brain = parent
		if(brain.owner)
			unprepare_mob(brain.owner)
		else
			unprepare_brain(brain)

	return ..()
