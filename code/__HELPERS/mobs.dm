/proc/random_blood_type()
	return pick(4;"O-", 36;"O+", 3;"A-", 28;"A+", 1;"B-", 20;"B+", 1;"AB-", 5;"AB+")

/proc/random_eye_color()
	switch(pick(20;"brown",20;"hazel",20;"grey",15;"blue",15;"green",1;"amber",1;"albino"))
		if("brown")
			return "630"
		if("hazel")
			return "542"
		if("grey")
			return pick("666","777","888","999","aaa","bbb","ccc")
		if("blue")
			return "36c"
		if("green")
			return "060"
		if("amber")
			return "fc0"
		if("albino")
			return pick("c","d","e","f") + pick("0","1","2","3","4","5","6","7","8","9") + pick("0","1","2","3","4","5","6","7","8","9")
		else
			return "000"

/proc/random_underwear(gender)
	if(!SLOTH.underwear_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/underwear, SLOTH.underwear_list, SLOTH.underwear_m, SLOTH.underwear_f)
	switch(gender)
		if(MALE)
			return pick(SLOTH.underwear_m)
		if(FEMALE)
			return pick(SLOTH.underwear_f)
		else
			return pick(SLOTH.underwear_list)

/proc/random_undershirt(gender)
	if(!SLOTH.undershirt_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/undershirt, SLOTH.undershirt_list, SLOTH.undershirt_m, SLOTH.undershirt_f)
	switch(gender)
		if(MALE)
			return pick(SLOTH.undershirt_m)
		if(FEMALE)
			return pick(SLOTH.undershirt_f)
		else
			return pick(SLOTH.undershirt_list)

/proc/random_socks()
	if(!SLOTH.socks_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/socks, SLOTH.socks_list)
	return pick(SLOTH.socks_list)

/proc/random_features()
	if(!SLOTH.tails_list_human.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/tails/human, SLOTH.tails_list_human)
	if(!SLOTH.tails_list_lizard.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/tails/lizard, SLOTH.tails_list_lizard)
	if(!SLOTH.snouts_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/snouts, SLOTH.snouts_list)
	if(!SLOTH.horns_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/horns, SLOTH.horns_list)
	if(!SLOTH.ears_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/ears, SLOTH.horns_list)
	if(!SLOTH.frills_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/frills, SLOTH.frills_list)
	if(!SLOTH.spines_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/spines, SLOTH.spines_list)
	if(!SLOTH.legs_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/legs, SLOTH.legs_list)
	if(!SLOTH.body_markings_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/body_markings, SLOTH.body_markings_list)
	if(!SLOTH.wings_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/wings, SLOTH.wings_list)

	//For now we will always return none for tail_human and ears.
	return(list("mcolor" = pick("FFFFFF","7F7F7F", "7FFF7F", "7F7FFF", "FF7F7F", "7FFFFF", "FF7FFF", "FFFF7F"), "tail_lizard" = pick(SLOTH.tails_list_lizard), "tail_human" = "None", "wings" = "None", "snout" = pick(SLOTH.snouts_list), "horns" = pick(SLOTH.horns_list), "ears" = "None", "frills" = pick(SLOTH.frills_list), "spines" = pick(SLOTH.spines_list), "body_markings" = pick(SLOTH.body_markings_list), "legs" = "Normal Legs"))

/proc/random_hair_style(gender)
	switch(gender)
		if(MALE)
			return pick(SLOTH.hair_styles_male_list)
		if(FEMALE)
			return pick(SLOTH.hair_styles_female_list)
		else
			return pick(SLOTH.hair_styles_list)

/proc/random_facial_hair_style(gender)
	switch(gender)
		if(MALE)
			return pick(SLOTH.facial_hair_styles_male_list)
		if(FEMALE)
			return pick(SLOTH.facial_hair_styles_female_list)
		else
			return pick(SLOTH.facial_hair_styles_list)

/proc/random_unique_name(gender, attempts_to_find_unique_name=10)
	for(var/i=1, i<=attempts_to_find_unique_name, i++)
		if(gender==FEMALE)
			. = capitalize(pick(SLOTH.first_names_female)) + " " + capitalize(pick(SLOTH.last_names))
		else
			. = capitalize(pick(SLOTH.first_names_male)) + " " + capitalize(pick(SLOTH.last_names))

		if(i != attempts_to_find_unique_name && !findname(.))
			break

/proc/random_unique_lizard_name(gender, attempts_to_find_unique_name=10)
	for(var/i=1, i<=attempts_to_find_unique_name, i++)
		. = capitalize(lizard_name(gender))

		if(i != attempts_to_find_unique_name && !findname(.))
			break

/proc/random_unique_plasmaman_name(attempts_to_find_unique_name=10)
	for(var/i=1, i<=attempts_to_find_unique_name, i++)
		. = capitalize(plasmaman_name())

		if(i != attempts_to_find_unique_name && !findname(.))
			break

/proc/random_skin_tone()
	return pick(SLOTH.skin_tones)

GLOBAL_LIST_INIT(skin_tones, list(
	"albino",
	"caucasian1",
	"caucasian2",
	"caucasian3",
	"latino",
	"mediterranean",
	"asian1",
	"asian2",
	"arab",
	"indian",
	"african1",
	"african2"
	))

GLOBAL_LIST_INIT(species_list, list())
GLOBAL_LIST_INIT(roundstart_species, list())

/proc/age2agedescription(age)
	switch(age)
		if(0 to 1)
			return "infant"
		if(1 to 3)
			return "toddler"
		if(3 to 13)
			return "child"
		if(13 to 19)
			return "teenager"
		if(19 to 30)
			return "young adult"
		if(30 to 45)
			return "adult"
		if(45 to 60)
			return "middle-aged"
		if(60 to 70)
			return "aging"
		if(70 to INFINITY)
			return "elderly"
		else
			return "unknown"

/*
Proc for attack log creation, because really why not
1 argument is the actor
2 argument is the target of action
3 is the description of action(like punched, throwed, or any other verb)
4 should it make adminlog note or not
5 is the tool with which the action was made(usually item)					5 and 6 are very similar(5 have "by " before it, that it) and are separated just to keep things in a bit more in order
6 is additional information, anything that needs to be added
*/

/proc/add_logs(mob/user, mob/target, what_done, object=null, addition=null)
	var/turf/attack_location = get_turf(target)

	var/is_mob_user = user && SLOTH.typecache_mob[user.type]
	var/is_mob_target = target && SLOTH.typecache_mob[target.type]

	var/mob/living/living_target


	if(target && isliving(target))
		living_target = target

	if(is_mob_user)
		var/message = "<font color='red'>has [what_done] [target ? "[target.name][(is_mob_target && target.ckey) ? "([target.ckey])" : ""]" : "NON-EXISTANT SUBJECT"][object ? " with [object]" : " "][addition][(living_target) ? " (NEWHP: [living_target.health])" : ""][(attack_location) ? "([attack_location.x],[attack_location.y],[attack_location.z])" : ""]</font>"
		user.log_message(message, INDIVIDUAL_ATTACK_LOG)

	if(is_mob_target)
		var/message = "<font color='orange'>has been [what_done] by [user ? "[user.name][(is_mob_user && user.ckey) ? "([user.ckey])" : ""]" : "NON-EXISTANT SUBJECT"][object ? " with [object]" : " "][addition][(living_target) ? " (NEWHP: [living_target.health])" : ""][(attack_location) ? "([attack_location.x],[attack_location.y],[attack_location.z])" : ""]</font>"
		target.log_message(message, INDIVIDUAL_ATTACK_LOG)

	log_attack("[user ? "[user.name][(is_mob_user && user.ckey) ? "([user.ckey])" : ""]" : "NON-EXISTANT SUBJECT"] [what_done] [target ? "[target.name][(is_mob_target && target.ckey)? "([target.ckey])" : ""]" : "NON-EXISTANT SUBJECT"][object ? " with [object]" : " "][addition][(living_target) ? " (NEWHP: [living_target.health])" : ""][(attack_location) ? "([attack_location.x],[attack_location.y],[attack_location.z])" : ""]")


/proc/do_mob(mob/user , mob/target, time = 30, uninterruptible = 0, progress = 1, datum/callback/extra_checks = null)
	if(!user || !target)
		return 0
	var/user_loc = user.loc

	var/drifting = 0
	if(!user.Process_Spacemove(0) && user.inertia_dir)
		drifting = 1

	var/target_loc = target.loc

	var/holding = user.get_active_held_item()
	var/datum/progressbar/progbar
	if (progress)
		progbar = new(user, time, target)

	var/endtime = world.time+time
	var/starttime = world.time
	. = 1
	while (world.time < endtime)
		stoplag()
		if (progress)
			progbar.update(world.time - starttime)
		if(!user || !target)
			. = 0
			break
		if(uninterruptible)
			continue

		if(drifting && !user.inertia_dir)
			drifting = 0
			user_loc = user.loc

		if((!drifting && user.loc != user_loc) || target.loc != target_loc || user.get_active_held_item() != holding || user.incapacitated() || user.lying || (extra_checks && !extra_checks.Invoke()))
			. = 0
			break
	if (progress)
		qdel(progbar)


/proc/do_after(mob/user, delay, needhand = 1, atom/target = null, progress = 1, datum/callback/extra_checks = null)
	if(!user)
		return 0
	var/atom/Tloc = null
	if(target)
		Tloc = target.loc

	var/atom/Uloc = user.loc

	var/drifting = 0
	if(!user.Process_Spacemove(0) && user.inertia_dir)
		drifting = 1

	var/holding = user.get_active_held_item()

	var/holdingnull = 1 //User's hand started out empty, check for an empty hand
	if(holding)
		holdingnull = 0 //Users hand started holding something, check to see if it's still holding that

	var/datum/progressbar/progbar
	if (progress)
		progbar = new(user, delay, target)

	var/endtime = world.time + delay
	var/starttime = world.time
	. = 1
	while (world.time < endtime)
		stoplag()
		if (progress)
			progbar.update(world.time - starttime)

		if(drifting && !user.inertia_dir)
			drifting = 0
			Uloc = user.loc

		if(!user || user.stat || user.weakened || user.stunned  || (!drifting && user.loc != Uloc) || (extra_checks && !extra_checks.Invoke()))
			. = 0
			break

		if(Tloc && (!target || Tloc != target.loc))
			if((Uloc != Tloc || Tloc != user) && !drifting)
				. = 0
				break

		if(needhand)
			//This might seem like an odd check, but you can still need a hand even when it's empty
			//i.e the hand is used to pull some item/tool out of the construction
			if(!holdingnull)
				if(!holding)
					. = 0
					break
			if(user.get_active_held_item() != holding)
				. = 0
				break
	if (progress)
		qdel(progbar)

/proc/do_after_mob(mob/user, var/list/targets, time = 30, uninterruptible = 0, progress = 1, datum/callback/extra_checks)
	if(!user || !targets)
		return 0
	if(!islist(targets))
		targets = list(targets)
	var/user_loc = user.loc

	var/drifting = 0
	if(!user.Process_Spacemove(0) && user.inertia_dir)
		drifting = 1

	var/list/originalloc = list()
	for(var/atom/target in targets)
		originalloc[target] = target.loc

	var/holding = user.get_active_held_item()
	var/datum/progressbar/progbar
	if(progress)
		progbar = new(user, time, targets[1])

	var/endtime = world.time + time
	var/starttime = world.time
	. = 1
	mainloop:
		while(world.time < endtime)
			sleep(1)
			if(progress)
				progbar.update(world.time - starttime)
			if(!user || !targets)
				. = 0
				break
			if(uninterruptible)
				continue

			if(drifting && !user.inertia_dir)
				drifting = 0
				user_loc = user.loc

			for(var/atom/target in targets)
				if((!drifting && user_loc != user.loc) || originalloc[target] != target.loc || user.get_active_held_item() != holding || user.incapacitated() || user.lying || (extra_checks && !extra_checks.Invoke()))
					. = 0
					break mainloop
	if(progbar)
		qdel(progbar)

/proc/is_species(A, species_datum)
	. = FALSE
	if(ishuman(A))
		var/mob/living/carbon/human/H = A
		if(H.dna && istype(H.dna.species, species_datum))
			. = TRUE

/proc/spawn_atom_to_turf(spawn_type, target, amount, admin_spawn=FALSE)
	var/turf/T = get_turf(target)
	if(!T)
		CRASH("attempt to spawn atom type: [spawn_type] in nullspace")

	for(var/j in 1 to amount)
		var/atom/X = new spawn_type(T)
		X.admin_spawned = admin_spawn

/proc/spawn_and_random_walk(spawn_type, target, amount, walk_chance=100, max_walk=3, always_max_walk=FALSE, admin_spawn=FALSE)
	var/turf/T = get_turf(target)
	var/step_count = 0
	if(!T)
		CRASH("attempt to spawn atom type: [spawn_type] in nullspace")

	for(var/j in 1 to amount)
		var/atom/movable/X = new spawn_type(T)
		X.admin_spawned = admin_spawn

		if(always_max_walk || prob(walk_chance))
			if(always_max_walk)
				step_count = max_walk
			else
				step_count = rand(1, max_walk)

			for(var/i in 1 to step_count)
				step(X, pick(NORTH, SOUTH, EAST, WEST))

/proc/deadchat_broadcast(message, mob/follow_target=null, turf/turf_target=null, speaker_key=null, message_type=DEADCHAT_REGULAR)
	for(var/mob/M in SLOTH.player_list)
		var/datum/preferences/prefs
		if(M.client && M.client.prefs)
			prefs = M.client.prefs
		else
			prefs = new

		var/adminoverride = 0
		if(M.client && M.client.holder && (prefs.chat_toggles & CHAT_DEAD))
			adminoverride = 1
		if(isnewplayer(M) && !adminoverride)
			continue
		if(M.stat != DEAD && !adminoverride)
			continue
		if(speaker_key && speaker_key in prefs.ignoring)
			continue

		switch(message_type)
			if(DEADCHAT_DEATHRATTLE)
				if(prefs.toggles & DISABLE_DEATHRATTLE)
					continue
			if(DEADCHAT_ARRIVALRATTLE)
				if(prefs.toggles & DISABLE_ARRIVALRATTLE)
					continue

		if(isobserver(M))
			var/rendered_message = message

			if(follow_target)
				var/F
				if(turf_target)
					F = FOLLOW_OR_TURF_LINK(M, follow_target, turf_target)
				else
					F = FOLLOW_LINK(M, follow_target)
				rendered_message = "[F] [message]"
			else if(turf_target)
				var/turf_link = TURF_LINK(M, turf_target)
				rendered_message = "[turf_link] [message]"

			to_chat(M, rendered_message)
		else
			to_chat(M, message)
