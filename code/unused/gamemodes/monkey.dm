#define MONKEY_MODE_RUNNING 0
#define MONKEY_MODE_NO_RABID_LEFT 1
#define MONKEY_MODE_SHUTTLE_CAPTURED 2
#define MONKEY_MODE_SHUTTLE_WITH_HUMANS 3


/datum/game_mode/monkey
	name = "monkey"
	config_tag = "monkey"
	var/state = MONKEY_MODE_RUNNING

/datum/game_mode/monkey/announce()
	world << "<B>The current game mode is - Monkey!</B>"
	world << "<B>Some of your crew members have been infected by a mutageous virus!</B>"
	world << "<B>Escape on the shuttle but the humans have precedence!</B>"

/datum/game_mode/monkey/post_setup()
	spawn (50)
		var/list/players = list()
		for (var/mob/living/carbon/human/player in world)
			if (player.client)
				players += player

		if (players.len >= 3)
			var/amount = round((players.len - 1) / 3) + 1
			amount = min(4, amount)

			while (amount > 0)
				var/mob/living/carbon/human/player = pick(players)
				var/mob/living/carbon/monkey/new_monkey = player.monkeyize()
				new_monkey << "<B>Your goal is to capture the entire human civilization and your first target is Centcom. Hijack the shuttle without humans aboard.</B>"

				players -= player
				amount--

		for (var/mob/living/carbon/monkey/rabid_monkey in world)
			if (!isturf(rabid_monkey.loc) || rabid_monkey.z!=1)
				continue
			rabid_monkey.contract_disease(new /datum/disease/jungle_fever,0,0)


/datum/game_mode/monkey/proc/is_important_monkey(var/mob/living/carbon/monkey/M as mob)
	var/turf/T = get_turf(M)
	return  M.stat!=2 && istype(M.virus, /datum/disease/jungle_fever) && ( T.z==1 || istype(T.loc, /area/shuttle/escape/centcom) || istype(T.loc, /area/centcom))
	
/datum/game_mode/monkey/check_win()
	if (state==MONKEY_MODE_SHUTTLE_CAPTURED || state==MONKEY_MODE_SHUTTLE_WITH_HUMANS)
		return
	var/infected_count = 0
	for (var/mob/living/carbon/monkey/rabid_monkey in world)
		if (is_important_monkey(rabid_monkey))
			infected_count++
	if (infected_count==0)
		state = MONKEY_MODE_NO_RABID_LEFT

/datum/game_mode/monkey/check_finished()
	return (emergency_shuttle.location==2) || (state>0)

/datum/game_mode/monkey/declare_completion()
	var/monkeywin = 0
	if (state != MONKEY_MODE_NO_RABID_LEFT)
		for(var/mob/living/carbon/monkey/monkey_player in world)
			if (is_important_monkey(monkey_player))
				var/turf/location = get_turf(monkey_player.loc)
				if (istype(location.loc, /area/shuttle/escape/centcom))
					monkeywin = 1
					break

		if(monkeywin)
			for(var/mob/living/carbon/human/human_player in world)
				if (human_player.stat != 2)
					var/turf/location = get_turf(human_player.loc)
					if (istype(location.loc, /area/shuttle/escape/centcom))
						monkeywin = 0
						break

	if (monkeywin)
		world << "<FONT size=3 color=red><B>The monkeys have won! Humanity is doomed!</B></FONT>"
		for (var/mob/living/carbon/human/player in world)
			if (player.client)
				spawn(0)
					player.monkeyize()
		for(var/mob/living/carbon/monkey/monkey_player in world)
			if (monkey_player.client)
				world << "<B>[monkey_player.key] was a monkey. [monkey_player.stat == 2 ? "(DEAD)" : ""]</B>"
		sleep(50)
	else
		world << "<FONT size=3 color=red><B>The Research Staff has stopped the monkey invasion!</B></FONT>"
		for(var/mob/living/carbon/monkey/monkey_player in world)
			if (monkey_player.client)
				world << "<B>[monkey_player.key] was a monkey. [monkey_player.stat == 2 ? "(DEAD)" : ""]</B>"

	return 1
	
#undef MONKEY_MODE_RUNNING
#undef MONKEY_MODE_NO_RABID_LEFT
#undef MONKEY_MODE_SHUTTLE_CAPTURED
#undef MONKEY_MODE_SHUTTLE_WITH_HUMANS
