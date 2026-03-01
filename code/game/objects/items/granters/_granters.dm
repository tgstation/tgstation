/**
 * Books that teach things.
 *
 * (Intrinsic actions like bar flinging, spells like fireball or smoke, or martial arts)
 */
/obj/item/book/granter
	due_date = 0
	unique = TRUE
	/// Flavor messages displayed to mobs reading the granter
	var/list/remarks = list()
	/// Controls how long a mob must keep the book in his hand to actually successfully learn
	var/pages_to_mastery = 3
	/// Sanity, whether it's currently being read
	var/reading = FALSE
	/// The amount of uses on the granter.
	var/uses = 1
	/// The time it takes to read the book
	var/reading_time = 5 SECONDS
	/// The sounds played as the user's reading the book.
	var/list/book_sounds = list(
		'sound/effects/page_turn/pageturn1.ogg',
		'sound/effects/page_turn/pageturn2.ogg',
		'sound/effects/page_turn/pageturn3.ogg',
	)

/obj/item/book/granter/attack_self(mob/living/user)
	if(reading)
		to_chat(user, span_warning("You're already reading this!"))
		return FALSE
	if(user.is_blind())
		to_chat(user, span_warning("You are blind and can't read anything!"))
		return FALSE
	if(!isliving(user) || !user.can_read(src))
		return FALSE
	if(!can_learn(user))
		return FALSE

	if(uses <= 0)
		recoil(user)
		return FALSE

	if(!on_reading_start(user))
		return
	reading = TRUE
	for(var/i in 1 to pages_to_mastery)
		if(!turn_page(user))
			on_reading_stopped()
			reading = FALSE
			return
	if(do_after(user, reading_time, src))
		uses--
		on_reading_finished(user)
	reading = FALSE

	return TRUE

/// Called when the user starts to read the granter.
/obj/item/book/granter/proc/on_reading_start(mob/living/user)
	to_chat(user, span_notice("You start reading [name]..."))
	return TRUE

/// Called when the reading is interrupted without finishing.
/obj/item/book/granter/proc/on_reading_stopped(mob/living/user)
	to_chat(user, span_notice("You stop reading..."))

/// Called when the reading is completely finished. This is where the actual granting should happen.
/obj/item/book/granter/proc/on_reading_finished(mob/living/user)
	to_chat(user, span_notice("You finish reading [name]!"))

/// The actual "turning over of the page" flavor bit that happens while someone is reading the granter.
/obj/item/book/granter/proc/turn_page(mob/living/user)
	playsound(user, pick(book_sounds), 30, TRUE)

	if(!do_after(user, reading_time, src))
		return FALSE

	to_chat(user, span_notice("[length(remarks) ? pick(remarks) : "You keep reading..."]"))
	return TRUE

/// Effects that occur whenever the book is read when it has no uses left.
/obj/item/book/granter/proc/recoil(mob/living/user)

/// Checks if the user can learn whatever this granter... grants
/obj/item/book/granter/proc/can_learn(mob/living/user)
	return TRUE

// Generic action giver
/obj/item/book/granter/action
	/// The typepath of action that is given
	var/datum/action/granted_action
	/// The name of the action, formatted in a more text-friendly way.
	var/action_name = ""

/obj/item/book/granter/action/can_learn(mob/living/user)
	if(!granted_action)
		CRASH("Someone attempted to learn [type], which did not have an action set.")
	if(locate(granted_action) in user.actions)
		to_chat(user, span_warning("You already know all about [action_name]!"))
		return FALSE
	return TRUE

/obj/item/book/granter/action/on_reading_start(mob/living/user)
	to_chat(user, span_notice("You start reading about [action_name]..."))
	return TRUE

/obj/item/book/granter/action/on_reading_finished(mob/living/user)
	to_chat(user, span_notice("You feel like you've got a good handle on [action_name]!"))
	// Action goes on the mind as the user actually learns the thing in your brain
	var/datum/action/new_action = new granted_action(user.mind || user)
	new_action.Grant(user)
