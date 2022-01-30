
/**
 * #Reality smash tracker
 *
 * Stupid fucking list holder, DONT create new ones, it will break the game
 * this is automatically created whenever eldritch cultists are created.
 *
 * Tracks relevant data, generates relevant data, useful tool
 */
/datum/reality_smash_tracker
	/// List of tracked influences (reality smashes)
	var/list/obj/effect/heretic_influence/smashes = list()
	/// List of minds with the ability to see influences
	var/list/datum/mind/tracked_heretics = list()

/datum/reality_smash_tracker/Destroy(force, ...)
	if(GLOB.reality_smash_track == src)
		stack_trace("[type] was deleted. Heretics may no longer access any influences. Fix it, or call coder support.")
		message_admins("The [type] was deleted. Heretics may no longer access any influences. Fix it, or call coder support.")
	QDEL_LIST(smashes)
	tracked_heretics.Cut()
	return ..()

/**
 * Automatically fixes the target and smash network
 *
 * Fixes any bugs that are caused by late Generate() or exchanging clients
 */
/datum/reality_smash_tracker/proc/rework_network()
	SIGNAL_HANDLER

	list_clear_nulls(smashes)
	for(var/mind in tracked_heretics)
		if(isnull(mind))
			stack_trace("A null somehow landed in the [type] list of minds. How?")
			tracked_heretics -= mind
			continue

		add_to_smashes(mind)

/**
 * Allow [to_add] to see all tracked reality smashes.
 */
/datum/reality_smash_tracker/proc/add_to_smashes(datum/mind/to_add)
	for(var/obj/effect/heretic_influence/reality_smash as anything in smashes)
		if(QDELETED(reality_smash))
			smashes -= reality_smash
			continue

		reality_smash.add_mind(to_add)

/**
 * Stop [to_remove] from seeing any tracked reality smashes.
 */
/datum/reality_smash_tracker/proc/remove_from_smashes(datum/mind/to_remove)
	for(var/obj/effect/heretic_influence/reality_smash as anything in smashes)
		if(QDELETED(reality_smash))
			smashes -= reality_smash
			continue

		reality_smash.remove_mind(to_remove)


/**
 * Generates a set amount of reality smashes
 * based on the number of already existing smashes
 * and the number of minds we're tracking.
 */
/datum/reality_smash_tracker/proc/generate_new_influences()
	var/number_of_heretics = length(tracked_heretics)
	var/number_of_smashes = length(smashes)
	var/how_many_should_we_make = max(number_of_heretics * (4 - (number_of_heretics - 1)) - number_of_smashes, 1)

	for(var/i in 0 to how_many_should_we_make)
		var/turf/chosen_location = get_safe_random_station_turf()

		// We don't want them close to each other - at least 1 tile of seperation
		var/obj/effect/heretic_influence/what_if_i_have_one = locate() in range(1, chosen_location)
		var/obj/effect/visible_heretic_influence/what_if_i_had_one_but_got_used = locate() in range(1, chosen_location)
		if(what_if_i_have_one || what_if_i_had_one_but_got_used)
			continue

		new /obj/effect/heretic_influence(chosen_location)

	rework_network()

/**
 * Adds a mind to the list of people that can see the reality smashes
 *
 * Use this whenever you want to add someone to the list
 */
/datum/reality_smash_tracker/proc/add_tracked_mind(datum/mind/heretic)
	tracked_heretics |= heretic

	// If our heretic's on station, generate some new influences
	if(ishuman(heretic.current) && is_station_level(heretic.current.z))
		generate_new_influences()

	add_to_smashes(heretic)


/**
 * Removes a mind from the list of people that can see the reality smashes
 *
 * Use this whenever you want to remove someone from the list
 */
/datum/reality_smash_tracker/proc/remove_tracked_mind(datum/mind/heretic)
	UnregisterSignal(heretic.current, COMSIG_MOB_LOGIN)
	tracked_heretics -= heretic

	remove_from_smashes(heretic)

/obj/effect/visible_heretic_influence
	name = "pierced reality"
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "pierced_illusion"
	anchored = TRUE
	interaction_flags_atom = INTERACT_ATOM_NO_FINGERPRINT_ATTACK_HAND
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	alpha = 0

/obj/effect/visible_heretic_influence/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, .proc/show_presence), 15 SECONDS)

	var/image/silicon_image = image('icons/effects/eldritch.dmi', src, null, OBJ_LAYER)
	silicon_image.override = TRUE
	add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/silicons, "pierced_reality", silicon_image)

/*
 * Makes the influence fade in after 15 seconds.
 */
/obj/effect/visible_heretic_influence/proc/show_presence()
	animate(src, alpha = 255, time = 15 SECONDS)

/obj/effect/visible_heretic_influence/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(!ishuman(user))
		return

	if(IS_HERETIC(user))
		to_chat(user, span_boldwarning("You know better than to tempt forces out of your control!"))
		return TRUE

	var/mob/living/carbon/human/human_user = user
	var/obj/item/bodypart/their_poor_arm = human_user.get_active_hand()
	if(prob(25))
		to_chat(human_user, span_userdanger("An otherwordly presence tears and atomizes your [their_poor_arm.name] as you try to touch the hole in the very fabric of reality!"))
		their_poor_arm.dismember()
		qdel(their_poor_arm)
	else
		to_chat(human_user,span_danger("You pull your hand away from the hole as the eldritch energy flails, trying to latch onto existance itself!"))
	return TRUE

/obj/effect/visible_heretic_influence/attack_tk(mob/user)
	if(!ishuman(user))
		return

	. = COMPONENT_CANCEL_ATTACK_CHAIN

	if(IS_HERETIC(user))
		to_chat(user, span_boldwarning("You know better than to tempt forces out of your control!"))
		return

	var/mob/living/carbon/human/human_user = user

	// A very elaborate way to suicide
	to_chat(human_user, span_userdanger("Eldritch energy lashes out, piercing your fragile mind, tearing it to pieces!"))
	human_user.ghostize()
	var/obj/item/bodypart/head/head = locate() in human_user.bodyparts
	if(head)
		head.dismember()
		qdel(head)
	else
		human_user.gib()

	var/datum/effect_system/reagents_explosion/explosion = new()
	explosion.set_up(1, get_turf(human_user), TRUE, 0)
	explosion.start(src)

/obj/effect/visible_heretic_influence/examine(mob/user)
	. = ..()
	if(IS_HERETIC(user) || !ishuman(user))
		return

	var/mob/living/carbon/human/human_user = user
	to_chat(human_user, span_userdanger("Your mind burns as you stare at the tear!"))
	human_user.adjustOrganLoss(ORGAN_SLOT_BRAIN, 10, 190)
	SEND_SIGNAL(human_user, COMSIG_ADD_MOOD_EVENT, "gates_of_mansus", /datum/mood_event/gates_of_mansus)

/obj/effect/heretic_influence
	name = "reality smash"
	icon = 'icons/effects/eldritch.dmi'
	anchored = TRUE
	interaction_flags_atom = INTERACT_ATOM_NO_FINGERPRINT_ATTACK_HAND
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	invisibility = INVISIBILITY_OBSERVER
	/// Whether we're currently being drained or not.
	var/being_drained = FALSE
	/// The icon state applied to the image created for this influence.
	var/real_icon_state = "reality_smash"
	/// A list of all minds that can see us.
	var/list/minds = list()
	/// The image shown to heretics
	var/image/heretic_image

/obj/effect/heretic_influence/Initialize(mapload)
	. = ..()
	GLOB.reality_smash_track.smashes += src
	heretic_image = image(icon, src, real_icon_state, OBJ_LAYER)
	generate_name()

/obj/effect/heretic_influence/Destroy()
	GLOB.reality_smash_track.smashes -= src
	for(var/datum/mind/heretic in minds)
		remove_mind(heretic)

	heretic_image = null
	return ..()

/obj/effect/heretic_influence/attack_hand_secondary(mob/user, list/modifiers)
	if(!IS_HERETIC(user)) // Shouldn't be able to do this, but just in case
		return SECONDARY_ATTACK_CALL_NORMAL

	if(being_drained)
		balloon_alert(user, "already being drained!")
	else
		INVOKE_ASYNC(src, .proc/drain_influence, user)

	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/**
 * Begin to drain the influence, setting being_drained,
 * registering an examine signal, and beginning a do_after.
 *
 * If successful, the influence is drained and deleted.
 */
/obj/effect/heretic_influence/proc/drain_influence(mob/living/user)

	being_drained = TRUE
	balloon_alert(user, "draining influence...")
	RegisterSignal(user, COMSIG_PARENT_EXAMINE, .proc/on_examine)

	if(!do_after(user, 10 SECONDS, src))
		being_drained = FALSE
		balloon_alert(user, "interrupted!")
		UnregisterSignal(user, COMSIG_PARENT_EXAMINE)
		return

	// We don't need to set being_drained back since we delete after anyways
	UnregisterSignal(user, COMSIG_PARENT_EXAMINE)
	balloon_alert(user, "influence drained")

	var/datum/antagonist/heretic/heretic_datum = IS_HERETIC(user)
	heretic_datum.knowledge_points++

	// Aaand now we delete it
	after_drain(user)

/*
 * Handle the effects of the drain.
 */
/obj/effect/heretic_influence/proc/after_drain(mob/living/user)
	if(user)
		to_chat(user, span_hypnophrase(pick(strings(HERETIC_INFLUENCE_FILE, "drain_message"))))
		to_chat(user, span_warning("[src] begins to fade into reality!"))

	var/obj/effect/visible_heretic_influence/illusion = new /obj/effect/visible_heretic_influence(drop_location())
	illusion.name = "\improper" + pick(strings(HERETIC_INFLUENCE_FILE, "drained")) + " " + format_text(name)

	qdel(src)

/*
 * Signal proc for [COMSIG_PARENT_EXAMINE], registered on the user draining the influence.
 *
 * Gives a chance for examiners to see that the heretic is interacting with an infuence.
 */
/obj/effect/heretic_influence/proc/on_examine(atom/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	if(prob(50))
		return

	examine_list += span_warning("[source]'s hand seems to be glowing a [span_hypnophrase("strange purple")]...")

/*
 * Add a mind to the list of tracked minds,
 * making another person able to see us.
 */
/obj/effect/heretic_influence/proc/add_mind(datum/mind/heretic)
	minds |= heretic
	heretic.current?.client?.images |= heretic_image

/*
 * Remove a mind present in our list
 * from being able to see us.
 */
/obj/effect/heretic_influence/proc/remove_mind(datum/mind/heretic)
	if(!(heretic in minds))
		CRASH("[type] - remove_mind called with a mind not present in the minds list!")

	minds -= heretic
	heretic.current?.client?.images -= heretic_image

/*
 * Generates a random name for the influence.
 */
/obj/effect/heretic_influence/proc/generate_name()
	name = "\improper" + pick(strings(HERETIC_INFLUENCE_FILE, "prefix")) + " " + pick(strings(HERETIC_INFLUENCE_FILE, "postfix"))
