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
	var/client/friend_candidate_client
	var/random_appearance

/datum/smite/custom_imaginary_friend/configure(client/user)
	friend_candidate_client = tgui_input_list(user, "Pick the player to put in control", "New Imaginary Friend", sort_list(GLOB.clients))
	if(isnull(friend_candidate_client))
		return FALSE

	if(QDELETED(friend_candidate_client))
		to_chat(user, span_notice("Selected player no longer has a client, aborting."))
		return FALSE

	if(isliving(friend_candidate_client.mob) && (tgui_alert(user, "This player already has a living mob ([friend_candidate_client.mob]). Do you still want to turn them into an Imaginary Friend?", "Remove player from mob?", list("Do it!", "Cancel")) != "Do it!"))
		return FALSE

	if(QDELETED(friend_candidate_client))
		to_chat(user, span_notice("Selected player no longer has a client, aborting."))
		return FALSE

	if(friend_candidate_client.prefs)
		var/choice = tgui_alert(user, "Do you want the imaginary friend to look like and be named after [friend_candidate_client]'s current preferences ([friend_candidate_client.prefs.read_preference(/datum/preference/name/real_name)])?", "Imaginary Friend Appearance?", list("Look-a-like", "Random", "Cancel"))
		if(choice != "Look-a-like" && choice != "Random")
			return FALSE
		random_appearance = choice == "Random"
	else
		if(tgui_alert(user, "The preferences for the friend could not be loaded, defaulting to random appearance. Is that okay?", "Preference error", list("Yes", "No")) != "Yes")
			return FALSE
		random_appearance = TRUE
	return TRUE

/datum/smite/custom_imaginary_friend/effect(client/user, mob/living/target)
	. = ..()

	if(QDELETED(target))
		to_chat(user, span_warning("The target mob no longer exists, aborting."))
		return

	if(QDELETED(friend_candidate_client))
		to_chat(user, span_warning("Imaginary friend candidate no longer has a client, aborting."))
		return

	if(isliving(friend_candidate_client.mob))
		friend_candidate_client.mob.ghostize(can_reenter_corpse = TRUE)

	var/mob/camera/imaginary_friend/friend_mob

	if(random_appearance)
		friend_mob = new /mob/camera/imaginary_friend(get_turf(target), target)
	else
		friend_mob = new /mob/camera/imaginary_friend(get_turf(target), target, friend_candidate_client.prefs)

	friend_mob.key = friend_candidate_client.key
