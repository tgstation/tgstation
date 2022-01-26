
/// JSON string file for all of our heretic influence names.
#define HERETIC_INFLUENCE_FILE "heretic_influences.json"

/obj/effect/heretic_rune
	name = "Generic rune"
	desc = "A flowing circle of shapes and runes is etched into the floor, filled with a thick black tar-like fluid."
	anchored = TRUE
	icon_state = ""
	interaction_flags_atom = INTERACT_ATOM_ATTACK_HAND
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	layer = SIGIL_LAYER
	///Used mainly for summoning ritual to prevent spamming the rune to create millions of monsters.
	var/is_in_use = FALSE

/obj/effect/heretic_rune/Initialize(mapload)
	. = ..()
	var/image/I = image(icon = 'icons/effects/eldritch.dmi', icon_state = null, loc = src)
	I.override = TRUE
	add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/silicons, "heretic_rune", I)

/obj/effect/heretic_rune/can_interact(mob/living/user)
	. = ..()
	if(!.)
		return
	if(!IS_HERETIC(user))
		return FALSE
	if(is_in_use)
		return FALSE
	return TRUE

/obj/effect/heretic_rune/interact(mob/living/user)
	. = ..()
	INVOKE_ASYNC(src, .proc/try_rituals, user)
	return TRUE

/obj/effect/heretic_rune/proc/try_rituals(mob/living/user)
	is_in_use = TRUE
	do_rituals(user)
	is_in_use = FALSE

/obj/effect/heretic_rune/proc/do_rituals(mob/living/user)
	var/datum/antagonist/heretic/heretic_datum = user.mind.has_antag_datum(/datum/antagonist/heretic)
	var/list/knowledge = heretic_datum.get_all_knowledge()
	var/list/atoms_in_range = list()

	for(var/atom/close_atom as anything in range(1, src))
		if(isturf(close_atom) || iseffect(close_atom))
			continue
		if(close_atom.invisibility)
			continue
		if(close_atom == user)
			continue

		atoms_in_range += close_atom

	for(var/knowledge_key in knowledge)
		var/datum/heretic_knowledge/current_eldritch_knowledge = knowledge[knowledge_key]

		// It's not a ritual, we don't care.
		if(!LAZYLEN(current_eldritch_knowledge.required_atoms))
			continue

		// A copy of our requirements list.
		// We decrement the values of to determine if enough of each key is present.
		var/list/requirements_list = current_eldritch_knowledge.required_atoms.Copy()
		// A list of all atoms we've selected to use in this recipe.
		var/list/selected_atoms = list()

		// Do the snowflake check to see if we can continue or not.
		// selected_atoms is passed and can be modified by this proc.
		if(!current_eldritch_knowledge.recipe_snowflake_check(user, atoms_in_range, selected_atoms, loc))
			continue

		// Now go through all our nearby atoms and see which are good for our ritual.
		for(var/atom/nearby_atom as anything in atoms_in_range)
			// Go through all of our required atoms
			for(var/req_type in requirements_list)
				// We already have enough of this type, skip
				if(requirements_list[req_type] <= 0)
					continue
				if(!istype(nearby_atom, req_type))
					continue

				// This item is a valid type.
				// Add it to our selected atoms list
				// and decrement the value of our requirements list
				selected_atoms |= nearby_atom
				requirements_list[req_type]--

		// All of the atoms have been checked, let's see if the ritual was successful
		var/requirements_fulfilled = TRUE
		for(var/req_type in requirements_list)
			// One if our requirements wasn't entirely filled
			// This ritual failed, move on to the next one
			if(requirements_list[req_type] > 0)
				requirements_fulfilled = FALSE
				break

		if(!requirements_fulfilled)
			continue

		// If we made it here, the ritual succeeded
		// Do the animations and feedback
		flick("[icon_state]_active", src)
		playsound(user, 'sound/magic/castsummon.ogg', 75, TRUE, extrarange = SILENCED_SOUND_EXTRARANGE, falloff_exponent = 10)

		// We temporarily make all of our chosen atoms invisible,
		// as some rituals may sleep, and we don't want people to be able to run off with ritual items.
		var/list/atoms_to_disappear = selected_atoms.Copy()
		for(var/atom/to_disappear as anything in atoms_to_disappear)
			to_disappear.invisibility = INVISIBILITY_ABSTRACT

		// on_finished_recipe, in the case of some rituals like summons.
		if(current_eldritch_knowledge.on_finished_recipe(user, selected_atoms, loc))
			current_eldritch_knowledge.cleanup_atoms(selected_atoms)

		// Re-appear anything left in the list
		for(var/atom/to_appear as anything in atoms_to_disappear)
			to_appear.invisibility = initial(to_appear.invisibility)

		return

	to_chat(user, span_warning("Your ritual failed! You either used the wrong components or are missing something important."))

/obj/effect/heretic_rune/big
	name = "transmutation rune"
	icon = 'icons/effects/96x96.dmi'
	icon_state = "eldritch_rune1"
	pixel_x = -32 //So the big ol' 96x96 sprite shows up right
	pixel_y = -32

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
		var/static/list/drain_messages = strings(HERETIC_INFLUENCE_FILE, "drain_message")
		to_chat(user, span_hypnophrase(pick(drain_messages)))
		to_chat(user, span_warning("[src] begins to fade into reality!"))

	var/static/list/drained_prefixes = strings(HERETIC_INFLUENCE_FILE, "drained")
	var/obj/effect/visible_heretic_influence/illusion = new /obj/effect/visible_heretic_influence(drop_location())
	illusion.name = "\improper" + pick(drained_prefixes) + " " + format_text(name)

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

	examine_list += span_warning("[source]'s hand seems to be glowing a strange purple...")

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
	var/static/list/prefixes = strings(HERETIC_INFLUENCE_FILE, "prefix")
	var/static/list/postfixes = strings(HERETIC_INFLUENCE_FILE, "postfix")

	name = "\improper" + pick(prefixes) + " " + pick(postfixes)

#undef HERETIC_INFLUENCE_FILE
