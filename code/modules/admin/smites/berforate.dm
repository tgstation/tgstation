/// Fires an absurd amount of bullets at the target
/datum/smite/berforate
	name = ":B:erforate"

	/// Determines how fucked the target is
	var/hatred

/datum/smite/berforate/configure(client/user)
	var/static/list/how_fucked_is_this_dude = list("A little", "A lot", "So fucking much", "FUCK THIS DUDE")
	hatred = input(user, "How much do you hate this guy?") in how_fucked_is_this_dude

/datum/smite/berforate/effect(client/user, mob/living/target)
	. = ..()
	if (!iscarbon(target))
		to_chat(user, "<span class='warning'>This must be used on a carbon mob.</span>", confidential = TRUE)
		return

	var/repetitions
	var/shots_per_limb_per_rep = 2
	var/damage
	switch (hatred)
		if ("A little")
			repetitions = 1
			damage = 5
		if ("A lot")
			repetitions = 2
			damage = 8
		if ("So fucking much")
			repetitions = 3
			damage = 10
		if ("FUCK THIS DUDE")
			repetitions = 4
			damage = 10

	var/mob/living/carbon/dude = target
	var/list/open_adj_turfs = get_adjacent_open_turfs(dude)
	var/list/wound_bonuses = list(15, 70, 110, 250)

	var/delay_per_shot = 1
	var/delay_counter = 1

	dude.Immobilize(5 SECONDS)
	for (var/wound_bonus_rep in 1 to repetitions)
		for (var/_limb in dude.bodyparts)
			var/obj/item/bodypart/limb = _limb
			var/shots_this_limb = 0
			for (var/_iter_turf in shuffle(open_adj_turfs))
				var/turf/iter_turf = _iter_turf
				addtimer(CALLBACK(GLOBAL_PROC, .proc/firing_squad, dude, iter_turf, limb.body_zone, wound_bonuses[wound_bonus_rep], damage), delay_counter)
				delay_counter += delay_per_shot
				shots_this_limb += 1
				if (shots_this_limb > shots_per_limb_per_rep)
					break
