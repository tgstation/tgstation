/obj/item/gang_induction_package
	name = "Family Signup Package"
	icon = 'icons/obj/gang/signup_points.dmi'
	icon_state = "signup_book"
	var/gang_to_use
	var/datum/team/gang/team_to_use


/obj/item/gang_induction_package/attack_self(mob/living/user)
	..()
	attempt_join_gang(user)

/obj/item/gang_induction_package/proc/add_to_gang(var/mob/living/user)
	var/datum/antagonist/gang/swappin_sides = new gang_to_use()
	user.mind.add_antag_datum(swappin_sides)
	swappin_sides.my_gang = team_to_use
	team_to_use.add_member(user.mind)
	for(var/threads in team_to_use.free_clothes)
		new threads(get_turf(user))
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
