/obj/item/gang_induction_package
	name = "family signup package"
	icon = 'icons/obj/gang/signup_points.dmi'
	icon_state = "signup_book"
	/// References the active families gamemode handler (if one exists), for adding new family members to.
	var/datum/gang_handler/handler
	/// The typepath of the gang antagonist datum that the person who uses the package should have added to them -- remember that the distinction between e.g. Ballas and Grove Street is on the antag datum level, not the team datum level.
	var/gang_to_use
	/// The team datum that the person who uses this package should be added to.
	var/datum/team/gang/team_to_use


/obj/item/gang_induction_package/attack_self(mob/living/user)
	..()
	if(HAS_TRAIT(user, TRAIT_MINDSHIELD))
		to_chat(user, "You attended a seminar on not signing up for a gang and are not interested.")
		return
	if(user.mind.has_antag_datum(/datum/antagonist/ert/families))
		to_chat(user, "As a police officer, you can't join this family. However, you pretend to accept it to keep your cover up.")
		for(var/threads in team_to_use.free_clothes)
			new threads(get_turf(user))
		qdel(src)
		return
	var/datum/antagonist/gang/is_gangster = user.mind.has_antag_datum(/datum/antagonist/gang)
	if(is_gangster?.starter_gangster)
		if(is_gangster.my_gang == team_to_use)
			to_chat(user, "You started your family. You don't need to join it.")
			return
		to_chat(user, "You started your family. You can't turn your back on it now.")
		return
	attempt_join_gang(user)

/// Adds the user to the family that this package corresponds to, dispenses the free_clothes of that family, and adds them to the handler if it exists.
/obj/item/gang_induction_package/proc/add_to_gang(mob/living/user, original_name)
	var/datum/antagonist/gang/swappin_sides = new gang_to_use()
	swappin_sides.original_name = original_name
	swappin_sides.handler = handler
	user.mind.add_antag_datum(swappin_sides, team_to_use)
	var/policy = get_policy(ROLE_FAMILIES)
	if(policy)
		to_chat(user, policy)
	team_to_use.add_member(user.mind)
	for(var/threads in team_to_use.free_clothes)
		new threads(get_turf(user))
	for(var/threads in team_to_use.current_theme.bonus_items)
		new threads(get_turf(user))
	var/obj/item/gangster_cellphone/phone = new(get_turf(user))
	phone.gang_id = team_to_use.my_gang_datum.gang_name
	phone.name = "[team_to_use.my_gang_datum.gang_name] branded cell phone"
	if (!isnull(handler) && !handler.gangbangers.Find(user.mind)) // if we have a handler and they're not tracked by it
		handler.gangbangers += user.mind

/// Checks if the user is trying to use the package of the family they are in, and if not, adds them to the family, with some differing processing depending on whether the user is already a family member.
/obj/item/gang_induction_package/proc/attempt_join_gang(mob/living/user)
	if(user?.mind)
		var/datum/antagonist/gang/is_gangster = user.mind.has_antag_datum(/datum/antagonist/gang)
		if(is_gangster)
			if(is_gangster.my_gang == team_to_use)
				return
			else
				var/real_name_backup = is_gangster.original_name
				is_gangster.my_gang.remove_member(user.mind)
				user.mind.remove_antag_datum(/datum/antagonist/gang)
				add_to_gang(user, real_name_backup)
				qdel(src)
		else
			add_to_gang(user)
			qdel(src)
