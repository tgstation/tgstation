/// Proc ghosts to enter the body when it get's revived
/datum/component/ghostrole_on_revive
	/// If revived and no ghosts, just die again?
	var/refuse_revival_if_failed
	/// Callback for when the mob is revived and has their body occupied by a ghost
	var/datum/callback/on_successful_revive
	/// The chance to twitch when orbiting the spawn
	var/twitch_chance = 30

/datum/component/ghostrole_on_revive/Initialize(refuse_revival_if_failed, on_successful_revive)
	. = ..()

	src.refuse_revival_if_failed = refuse_revival_if_failed
	src.on_successful_revive = on_successful_revive

	ADD_TRAIT(parent, TRAIT_GHOSTROLE_ON_REVIVE, REF(src)) //for adding an alternate examination

	if(ismob(parent))
		prepare_mob(parent)
		return

	if(!istype(parent, /obj/item/organ/brain))
		return COMPONENT_INCOMPATIBLE

	var/obj/item/organ/brain/brein = parent
	if(brein.owner)
		prepare_mob(brein.owner)
	else
		prepare_brain(brein)

/// Give the appropriate signals, and watch for organ removal
/datum/component/ghostrole_on_revive/proc/prepare_mob(mob/living/liver)
	RegisterSignal(liver, COMSIG_LIVING_REVIVE, PROC_REF(on_revive))
	ADD_TRAIT(liver, TRAIT_GHOSTROLE_ON_REVIVE, REF(src))

	add_orbit_twitching(liver)

	liver.med_hud_set_status()

	if(iscarbon(liver))
		var/mob/living/carbon/carbon = liver
		var/obj/item/organ/brain = carbon.get_organ_by_type(/obj/item/organ/brain)
		if(brain)
			RegisterSignal(brain, COMSIG_ORGAN_REMOVED, PROC_REF(on_remove))

/datum/component/ghostrole_on_revive/proc/on_remove(obj/item/organ/brain, mob/living/old_owner)
	SIGNAL_HANDLER

	REMOVE_TRAIT(old_owner, TRAIT_GHOSTROLE_ON_REVIVE, REF(src))
	remove_orbit_twitching(old_owner)

	// we might have some lingering blinking eyes
	var/obj/item/bodypart/head/head = old_owner?.get_bodypart(BODY_ZONE_HEAD)
	if(head)
		var/soul_eyes = locate(/datum/bodypart_overlay/simple/soul_pending_eyes) in head.bodypart_overlays
		if(soul_eyes)
			head.remove_bodypart_overlay(soul_eyes)

	prepare_brain(brain)

/datum/component/ghostrole_on_revive/proc/prepare_brain(obj/item/organ/brein)
	SIGNAL_HANDLER

	RegisterSignal(brein, COMSIG_ORGAN_IMPLANTED, PROC_REF(prepare_mob_from_brain))
	UnregisterSignal(brein, COMSIG_ORGAN_REMOVED)

/datum/component/ghostrole_on_revive/proc/prepare_mob_from_brain(obj/item/organ/brain/brein, mob/living/owner)
	SIGNAL_HANDLER

	UnregisterSignal(brein, COMSIG_ORGAN_IMPLANTED)
	prepare_mob(owner)

/datum/component/ghostrole_on_revive/proc/on_revive(mob/living/aliver)
	SIGNAL_HANDLER

	INVOKE_ASYNC(src, PROC_REF(poll_ghosts), aliver)

/datum/component/ghostrole_on_revive/proc/poll_ghosts(mob/living/aliver)
	var/soul_eyes
	var/obj/item/bodypart/head
	// adds soulful SOUL PENDING eyes to indicate what's happening to observers

	var/mob/living/carbon/human/hewmon
	if(ishuman(aliver))
		hewmon = aliver
		head = hewmon.get_bodypart(BODY_ZONE_HEAD)
		if(head)
			soul_eyes = new /datum/bodypart_overlay/simple/soul_pending_eyes()
			head.add_bodypart_overlay(soul_eyes)

	// So during the potentially short period of time we're revived, we don't metabolize formaldehyde
	// Really just a QOL for coroners, so we dont suddenly start decaying
	ADD_TRAIT(aliver, TRAIT_BLOCK_FORMALDEHYDE_METABOLISM, type)

	var/mob/dead/observer/chosen_one = SSpolling.poll_ghosts_for_target(
		question = "Would you like to play as a recovered crewmember?",
		role = null,
		check_jobban = ROLE_RECOVERED_CREW,
		poll_time = 15 SECONDS,
		checked_target = aliver,
		ignore_category = POLL_IGNORE_RECOVERED_CREW,
		alert_pic = aliver,
		role_name_text = "recovered crew",
	)

	REMOVE_TRAIT(aliver, TRAIT_BLOCK_FORMALDEHYDE_METABOLISM, type)

	if(head)
		head.remove_bodypart_overlay(soul_eyes)

	if(!isobserver(chosen_one))
		if(refuse_revival_if_failed)
			aliver.death()
			aliver.visible_message(span_deadsay("[aliver.name]'s soul is struggling to return!"))
	else
		aliver.PossessByPlayer(chosen_one.ckey)
		on_successful_revive?.Invoke(aliver)
		qdel(src)

/datum/component/ghostrole_on_revive/proc/add_orbit_twitching(mob/living/liver)
	liver.AddElement(/datum/element/orbit_twitcher, twitch_chance)

	// Add it to the ghostrole spawner menu. Note that we can't directly spawn from it, but we can make it twitch to alert bystanders to defib it
	LAZYADD(GLOB.joinable_mobs[format_text("Recovered Crew")], liver)
	RegisterSignal(liver, COMSIG_LIVING_GHOSTROLE_INFO, PROC_REF(set_spawner_info))

/datum/component/ghostrole_on_revive/proc/set_spawner_info(datum/spawners_menu/menu, string_info)
	SIGNAL_HANDLER

	string_info["you_are_text"] = "You are a long dead crewmember, but are soon to be revived to rejoin the crew!"
	string_info["flavor_text"] = "Get a job and get back to work!"
	string_info["important_text"] = "Do your best to help the station. You still roll for midround antagonists."

/datum/component/ghostrole_on_revive/proc/remove_orbit_twitching(mob/living/living)
	living.RemoveElement(/datum/element/orbit_twitcher, twitch_chance)

	// Remove from the ghostrole spawning menu
	var/list/spawners = GLOB.joinable_mobs[format_text("Recovered Crew")]
	LAZYREMOVE(spawners, living)

	if(!LAZYLEN(spawners))
		GLOB.joinable_mobs -= format_text("Recovered Crew")

	UnregisterSignal(living, COMSIG_LIVING_GHOSTROLE_INFO)

/datum/component/ghostrole_on_revive/Destroy(force)
	REMOVE_TRAIT(parent, TRAIT_GHOSTROLE_ON_REVIVE, REF(src))

	var/mob/living/living
	if(isliving(parent))
		living = parent
	else if(istype(parent, /obj/item/organ/brain))
		var/obj/item/organ/brain/brain = parent
		living = brain.owner
	living?.med_hud_set_status()
	if(living)
		remove_orbit_twitching(living)

	return ..()
