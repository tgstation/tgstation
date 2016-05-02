
/datum/objective/build
	dangerrating = 15
	martyr_compatible = 1


/datum/objective/build/proc/gen_amount_goal(lower, upper)
	target_amount = rand(lower, upper)
	explanation_text = "Build [target_amount] shrines."
	return target_amount


/datum/objective/build/check_completion()
	if(!owner || !owner.current)
		return 0

	var/shrines = 0
	if(is_handofgod_god(owner.current))
		var/mob/camera/god/G = owner.current
		for(var/obj/structure/divine/shrine/S in G.structures)
			S++

	return (shrines >= target_amount)



/datum/objective/deicide
	dangerrating = 20
	martyr_compatible = 1

/datum/objective/deicide/check_completion()
	if(target)
		if(target.current) //Gods are deleted when they lose
			return 0
	return 1


/datum/objective/deicide/find_target()
	if(!owner || !owner.current)
		return

	if(is_handofgod_god(owner.current))
		var/mob/camera/god/G = owner.current
		if(G.side == "red")
			if(ticker.mode.blue_deities.len)
				target = ticker.mode.blue_deities[1]
		if(G.side == "blue")
			if(ticker.mode.red_deities.len)
				target = ticker.mode.red_deities[1]
		if(!target)
			return 0
	update_explanation_text()

/datum/objective/deicide/update_explanation_text()
	..()
	if(target && target.current)
		explanation_text = "Phase [target.name], the false god, out of this plane of existence.."
	else
		explanation_text = "Free Objective"



/datum/objective/follower_block
	explanation_text = "Do not allow any followers of the false god to escape on the station's shuttle alive."
	dangerrating = 25
	martyr_compatible = 1

/datum/objective/follower_block/check_completion()
	var/side = "ABORT"
	if(is_handofgod_redcultist(owner.current))
		side = "red"
	else if(is_handofgod_bluecultist(owner.current))
		side = "blue"
	if(side == "ABORT")
		return 0

	var/area/A = SSshuttle.emergency.areaInstance

	for(var/mob/living/player in player_list)
		if(player.mind && player.stat != DEAD && get_area(player) == A)
			if(side == "red")
				if(is_handofgod_bluecultist(player))
					return 0
			else if(side == "blue")
				if(is_handofgod_redcultist(player))
					return 0
	return 1



/datum/objective/escape_followers
	dangerrating = 5


/datum/objective/escape_followers/proc/gen_amount_goal(lower,upper)
	target_amount = rand(lower,upper)
	explanation_text = "Your will must surpass this station. Having [target_amount] followers escape on the shuttle or pods will allow that."
	return target_amount


/datum/objective/escape_followers/check_completion()
	var/escaped = 0
	if(is_handofgod_god(owner.current))
		var/mob/camera/god/G = owner.current
		if(G.side == "red")
			for(var/datum/mind/follower_mind in ticker.mode.red_deity_followers)
				if(follower_mind.current && follower_mind.current.stat != DEAD)
					if(follower_mind.current.onCentcom())
						escaped++

		if(G.side == "blue")
			for(var/datum/mind/follower_mind in ticker.mode.blue_deity_followers)
				if(follower_mind.current && follower_mind.current.stat != DEAD)
					if(follower_mind.current.onCentcom())
						escaped++

	return (escaped >= target_amount)


/datum/objective/sacrifice_prophet
	explanation_text = "A false prophet is preaching their god's faith on the station. Sacrificing them will show the mortals who the true god is."
	dangerrating = 10


/datum/objective/sacrifice_prophet/check_completion()
	var/mob/camera/god/G = owner.current
	if(istype(G))
		return G.prophets_sacrificed_in_name
	return 0
