/obj/gang_signup_point
	name = "Gang Signup Point"
	icon = 'icons/obj/gang/signup_points.dmi'
	max_integrity = INFINITY
	obj_integrity = INFINITY
	anchored = TRUE
	var/gang_to_use
	var/datum/team/gang/team_to_use

/obj/gang_signup_point/examine(mob/user)
	..()
	to_chat(user, "[team_to_use.name] currently has [team_to_use.points] points.")

/obj/gang_signup_point/attack_hand(mob/living/user)
	attempt_join_gang(user)

/obj/gang_signup_point/blob_act(obj/structure/blob/B)
	attempt_join_gang(B.overmind)

/obj/gang_signup_point/attack_tk(mob/user)
	attempt_join_gang(user)

/obj/gang_signup_point/attack_paw(mob/user)
	attempt_join_gang(user)

/obj/gang_signup_point/attack_alien(mob/user)
	attempt_join_gang(user)

/obj/gang_signup_point/attack_animal(mob/living/simple_animal/S)
	attempt_join_gang(S)

/obj/gang_signup_point/attack_robot(mob/user)
	attempt_join_gang(user)

/obj/gang_signup_point/attack_ai(mob/user)
	attempt_join_gang(user)

/obj/gang_signup_point/proc/add_to_gang(var/mob/living/user)
	var/datum/antagonist/gang/swappin_sides = new gang_to_use()
	user.mind.add_antag_datum(swappin_sides)
	swappin_sides.my_gang = team_to_use
	team_to_use.add_member(user.mind)
	for(var/threads in team_to_use.free_clothes)
		new threads(get_turf(user))
	team_to_use.adjust_points(30)

/obj/gang_signup_point/attackby(obj/item/W, mob/living/user, params)
	var/datum/antagonist/gang/is_gangster = user.mind.has_antag_datum(/datum/antagonist/gang)
	if(is_gangster && is_gangster.my_gang == team_to_use)
		var/datum/export_report/ex = export_item_and_contents(W, EXPORT_CARGO|EXPORT_CONTRABAND|EXPORT_EMAG, dry_run=TRUE)
		var/price = 0
		for(var/x in ex.total_amount)
			price += ex.total_value[x]
		if(price)
			team_to_use.adjust_points(price)
			to_chat(user, "You sell [W] on the black market for [price] points.")
			qdel(W)
		else
			return ..()
	else
		return ..()

/obj/gang_signup_point/proc/attempt_join_gang(mob/living/user)
	if(user && user.mind)
		var/datum/game_mode/gang/mode = SSticker.mode

		var/list/readable_gang_names = list()
		var/lowest_gang_count = team_to_use.members.len
		for(var/datum/team/gang/TT in mode.gangs)
			if(TT != team_to_use)
				var/area_with_spawner = mode.gang_locations[TT.name]
				readable_gang_names += "[TT.name] in the [area_with_spawner]"
				if(TT.members.len < lowest_gang_count)
					lowest_gang_count = TT.members.len
		var/finalized_gang_names = english_list(readable_gang_names, and_text = " or the ", comma_text = ", the ")
		if(team_to_use.members.len >= (lowest_gang_count + mode.gang_balance_cap))
			to_chat(user, "[team_to_use.name] is pretty packed. You should try the [finalized_gang_names] instead.")
			return

		var/datum/antagonist/gang/is_gangster = user.mind.has_antag_datum(/datum/antagonist/gang)
		if(is_gangster)
			if(is_gangster.my_gang == team_to_use)
				return
			else
				is_gangster.my_gang.remove_member(user.mind)
				user.mind.remove_antag_datum(/datum/antagonist/gang)
				add_to_gang(user)
		else
			add_to_gang(user)
