/obj/item/gang_induction_package
	name = "family signup package"
	icon = 'icons/obj/gang/signup_points.dmi'
	icon_state = "signup_book"
	var/gang_to_use
	var/datum/team/gang/team_to_use


/obj/item/gang_induction_package/attack_self(mob/living/user)
	..()
	if(HAS_TRAIT(user, TRAIT_MINDSHIELD))
		to_chat(user, "You attended a seminar on not signing up for a gang, and are not interested.")
		return
	if(user.mind.has_antag_datum(/datum/antagonist/ert/families))
		to_chat(user, "As a police officer, you can't join this family. However, you pretend to accept it to keep your cover up.")
		for(var/threads in team_to_use.free_clothes)
			new threads(get_turf(user))
		qdel(src)
		return
	var/datum/antagonist/gang/is_gangster = user.mind.has_antag_datum(/datum/antagonist/gang)
	if(is_gangster && is_gangster.starter_gangster)
		to_chat(user, "You started your family. You can't turn your back on it now.")
		return
	attempt_join_gang(user)

/obj/item/gang_induction_package/proc/add_to_gang(var/mob/living/user)
	var/datum/game_mode/gang/F = SSticker.mode
	var/datum/antagonist/gang/swappin_sides = new gang_to_use()
	user.mind.add_antag_datum(swappin_sides)
	swappin_sides.my_gang = team_to_use
	team_to_use.add_member(user.mind)
	for(var/threads in team_to_use.free_clothes)
		new threads(get_turf(user))
	if (!F.gangbangers.Find(user.mind))
		F.gangbangers += user.mind
	team_to_use.adjust_points(30)


/obj/item/gang_induction_package/proc/attempt_join_gang(mob/living/user)
	if(user && user.mind)
		var/datum/antagonist/gang/is_gangster = user.mind.has_antag_datum(/datum/antagonist/gang)
		if(is_gangster)
			if(is_gangster.my_gang == team_to_use)
				return
			else
				is_gangster.my_gang.adjust_points(-30)
				is_gangster.my_gang.remove_member(user.mind)
				user.mind.remove_antag_datum(/datum/antagonist/gang)
				add_to_gang(user)
				qdel(src)
		else
			add_to_gang(user)
			qdel(src)
