#define CHOICE_RANDOM_APPEARANCE "Random"
#define CHOICE_PREFS_APPEARANCE "Look-a-like"
#define CHOICE_POLL_GHOSTS "Offer to ghosts"
#define CHOICE_CANCEL "Cancel"

/**
 * Custom imaginary friend.
 *
 * Allows the admin to select the ckey to put into the imaginary friend and whether the imaginary friend looks like the
 * ckey's character.
 *
 * Is not tied to the brain trauma and can be used on all mobs, technically. Including cyborgs and simple/basic mobs.
 *
 * Warranty void if used on AI eyes or other imaginary friends. Please smite responsibly.
 **/
/datum/smite/custom_imaginary_friend
	name = "Imaginary Friend (Special)"
	/// Who are we going to add to your head today?
	var/list/friend_candidates
	/// Do we randomise friend appearances or not?
	var/random_appearance

/datum/smite/custom_imaginary_friend/configure(client/user)
	var/appearance_choice = tgui_alert(user,
		"Do you want the imaginary friend(s) to share name and appearance with their currently selected character preferences?",
		"Imaginary Friend Appearance?",
		list(CHOICE_PREFS_APPEARANCE, CHOICE_RANDOM_APPEARANCE, CHOICE_CANCEL))
	if (isnull(appearance_choice) || appearance_choice == CHOICE_CANCEL)
		return FALSE
	random_appearance = appearance_choice == CHOICE_RANDOM_APPEARANCE

	var/picked_client = tgui_input_list(user, "Pick the player to put in control", "New Imaginary Friend", list(CHOICE_POLL_GHOSTS) + sort_list(GLOB.clients))
	if(isnull(picked_client))
		return FALSE

	if(picked_client == CHOICE_POLL_GHOSTS)
		return poll_ghosts(user)

	var/client/friend_candidate_client = picked_client
	if(QDELETED(friend_candidate_client))
		to_chat(user, span_warning("Selected player no longer has a client, aborting."))
		return FALSE

	if(isliving(friend_candidate_client.mob) && (tgui_alert(user, "This player already has a living mob ([friend_candidate_client.mob]). Do you still want to turn them into an Imaginary Friend?", "Remove player from mob?", list("Do it!", "Cancel")) != "Do it!"))
		return FALSE

	if(QDELETED(friend_candidate_client))
		to_chat(user, span_warning("Selected player no longer has a client, aborting."))
		return FALSE

	friend_candidates = list(friend_candidate_client)
	return TRUE

/// Try to offer the role to ghosts
/datum/smite/custom_imaginary_friend/proc/poll_ghosts(client/user)
	var/how_many = tgui_input_number(user, "How many imaginary friends should be added?", "Imaginary friend count", default = 1, min_value = 1)
	if (isnull(how_many) || how_many < 1)
		return FALSE

	var/list/volunteers = poll_ghost_candidates(
		question = "Do you want to play as an imaginary friend?",
		jobban_type = ROLE_PAI,
		poll_time = 10 SECONDS,
		ignore_category = POLL_IGNORE_IMAGINARYFRIEND,
	)
	var/volunteer_count = length(volunteers)
	if (volunteer_count == 0)
		to_chat(user, span_warning("No candidates volunteered, aborting."))
		return FALSE

	shuffle_inplace(volunteers)
	friend_candidates = list()
	while (how_many > 0 && length(volunteers) > 0)
		var/mob/dead/observer/lucky_ghost = pop(volunteers)
		if (!lucky_ghost.client)
			continue
		how_many--
		friend_candidates += lucky_ghost.client
	return TRUE

/datum/smite/custom_imaginary_friend/effect(client/user, mob/living/target)
	. = ..()

	if(QDELETED(target))
		to_chat(user, span_warning("The target mob no longer exists, aborting."))
		return

	if(!length(friend_candidates))
		to_chat(user, span_warning("No provided imaginary friend candidates, aborting."))
		return

	var/list/final_clients = list()
	for (var/client/client as anything in friend_candidates)
		if (QDELETED(client))
			continue
		final_clients += client

	if(!length(final_clients))
		to_chat(user, span_warning("No provided imaginary friend candidates had clients, aborting."))
		return

	for (var/client/friend_candidate_client as anything in final_clients)
		var/mob/client_mob = friend_candidate_client.mob
		if(isliving(client_mob))
			client_mob.ghostize()

		var/mob/camera/imaginary_friend/friend_mob = client_mob.change_mob_type(
			new_type = /mob/camera/imaginary_friend,
			location = get_turf(client_mob),
			delete_old_mob = TRUE,
		)
		friend_mob.attach_to_owner(target)
		friend_mob.setup_appearance(random_appearance ? null : friend_candidate_client.prefs)

#undef CHOICE_RANDOM_APPEARANCE
#undef CHOICE_PREFS_APPEARANCE
#undef CHOICE_POLL_GHOSTS
#undef CHOICE_CANCEL
