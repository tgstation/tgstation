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
	///list of tracked reality smashes
	var/list/smashes = list()
	///List of mobs with ability to see the smashes
	var/list/targets = list()

/datum/reality_smash_tracker/Destroy(force, ...)
	if(GLOB.reality_smash_track == src)
		stack_trace("/datum/reality_smash_tracker was deleted. Heretics may no longer access any influences. Fix it or call coder support.")
	QDEL_LIST(smashes)
	targets.Cut()
	smashes.Cut()
	return ..()

/**
 * Automatically fixes the target and smash network
 *
 * Fixes any bugs that are caused by late Generate() or exchanging clients
 */
/datum/reality_smash_tracker/proc/ReworkNetwork()
	SIGNAL_HANDLER

	list_clear_nulls(smashes)
	for(var/mind in targets)
		if(isnull(mind))
			stack_trace("A null somehow landed in a list of minds")
			continue
		for(var/obj/effect/heretic_influence/reality_smash as anything in smashes)
			reality_smash.add_mind(mind)

/**
 * Generates a set amount of reality smashes based on the N value
 *
 * Automatically creates more reality smashes
 */
/datum/reality_smash_tracker/proc/Generate(mob/caller)
	if(istype(caller))
		targets += caller
	var/targ_len = length(targets)
	var/smash_len = length(smashes)
	var/number = max(targ_len * (4-(targ_len-1)) - smash_len,1)

	for(var/i in 0 to number)
		var/turf/chosen_location = get_safe_random_station_turf()

		//we also dont want them close to each other, at least 1 tile of seperation
		var/obj/effect/heretic_influence/what_if_i_have_one = locate() in range(1, chosen_location)
		var/obj/effect/visible_heretic_influence/what_if_i_had_one_but_got_used = locate() in range(1, chosen_location)
		if(what_if_i_have_one || what_if_i_had_one_but_got_used) //we dont want to spawn
			continue
		new /obj/effect/heretic_influence(chosen_location)
	ReworkNetwork()

/**
 * Adds a mind to the list of people that can see the reality smashes
 *
 * Use this whenever you want to add someone to the list
 */
/datum/reality_smash_tracker/proc/AddMind(datum/mind/heretic)
	RegisterSignal(heretic.current, COMSIG_MOB_LOGIN, .proc/ReworkNetwork)
	targets |= heretic
	Generate()
	for(var/obj/effect/heretic_influence/reality_smash as anything in smashes)
		reality_smash.add_mind(heretic)


/**
 * Removes a mind from the list of people that can see the reality smashes
 *
 * Use this whenever you want to remove someone from the list
 */
/datum/reality_smash_tracker/proc/RemoveMind(datum/mind/heretic)
	UnregisterSignal(heretic.current, COMSIG_MOB_LOGIN)
	targets -= heretic
	for(var/obj/effect/heretic_influence/reality_smash as anything in smashes)
		reality_smash.remove_mind(heretic)

/obj/effect/visible_heretic_influence
	name = "pierced reality"
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "pierced_illusion"
	anchored = TRUE
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	alpha = 0

/obj/effect/visible_heretic_influence/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src,.proc/show_presence),15 SECONDS)

	var/image/silicon_image = image('icons/effects/eldritch.dmi', src, null, OBJ_LAYER)
	silicon_image.override = TRUE
	add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/silicons, "pierced_reality", silicon_image)

/*
 * Makes the influence fade in after 15 seconds.
 */
/obj/effect/visible_heretic_influence/proc/show_presence()
	animate(src, alpha = 255, time = 15 SECONDS)

/obj/effect/visible_heretic_influence/attack_hand(mob/living/user, list/modifiers)
	if(!ishuman(user))
		return ..()

	if(IS_HERETIC(user))
		to_chat(user, span_boldwarning("You know better than to tempt forces out of your control!"))
		return

	var/mob/living/carbon/human/human_user = user
	var/obj/item/bodypart/their_poor_arm = human_user.get_active_hand()
	if(prob(25))
		to_chat(human_user, span_userdanger("An otherwordly presence tears and atomizes your [their_poor_arm.name] as you try to touch the hole in the very fabric of reality!"))
		their_poor_arm.dismember()
		qdel(their_poor_arm)
	else
		to_chat(human_user,span_danger("You pull your hand away from the hole as the eldritch energy flails, trying to latch onto existance itself!"))


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
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	invisibility = INVISIBILITY_OBSERVER
	/// The icon state of the generated image for this influence.
	var/image_state = "reality_smash"
	/// A list of all minds that can see us.
	var/list/minds = list()
	/// The image shown to heretics
	var/image/heretic_image

/obj/effect/heretic_influence/Initialize(mapload)
	. = ..()
	GLOB.reality_smash_track.smashes += src
	heretic_image = image(icon, src, image_state, OBJ_LAYER)
	generate_name()

/obj/effect/heretic_influence/Destroy()
	GLOB.reality_smash_track.smashes -= src
	for(var/datum/mind/heretic in minds)
		remove_mind(heretic)

	heretic_image = null
	return ..()

/obj/effect/heretic_influence/proc/drain_influence()
	var/obj/effect/visible_heretic_influence/illusion = new /obj/effect/visible_heretic_influence(drop_location())
	illusion.name = pick("Researched", "Siphoned", "Analyzed", "Emptied", "Drained") + " " + name
	qdel(src)

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
	var/static/list/prefix = list(
		"Omniscient",
		"Thundering",
		"Enlightening",
		"Intrusive",
		"Rejectful",
		"Atomized",
		"Subtle",
		"Rising",
		"Lowering",
		"Fleeting",
		"Towering",
		"Blissful",
		"Arrogant",
		"Threatening",
		"Peaceful",
		"Aggressive",
	)
	var/static/list/postfix = list(
		"Flaw",
		"Presence",
		"Crack",
		"Heat",
		"Cold",
		"Memory",
		"Reminder",
		"Breeze",
		"Grasp",
		"Sight",
		"Whisper",
		"Flow",
		"Touch",
		"Veil",
		"Thought",
		"Imperfection",
		"Blemish",
		"Blush",
	)

	name = "\improper" + pick(prefix) + " " + pick(postfix)
