#define MONKEY_MODE_RUNNING 0
#define MONKEY_MODE_NO_RABID_LEFT 1
#define MONKEY_MODE_SHUTTLE_CAPTURED 2
#define MONKEY_MODE_SHUTTLE_WITH_HUMANS 3

#define MONKEY_MODE_MONKEYS 4

/datum/game_mode/monkey
	name = "monkey"
	config_tag = "monkey"
	var/state = MONKEY_MODE_RUNNING
	var/list/datum/mind/initial_monkeys = new

/datum/game_mode/monkey/announce()
	world << "<B>The current game mode is - Monkey!</B>"
	world << "<B>Some of your crew members have been infected by a mutageous virus!</B>"
	world << "<B>Escape on the shuttle but the humans have precedence!</B>"

/datum/game_mode/monkey/can_start()
	if (num_players()<2)
		return 0
	for(var/mob/new_player/P in player_list)
		if(P.client && P.ready && !jobban_isbanned(P, "Syndicate"))
			return 1
	return 0

/datum/game_mode/monkey/pre_setup()
	var/list/possible_monkeys = get_players_for_role(BE_MONKEY)

	// stop setup if no possible monkeys
	if(!possible_monkeys.len)
		return 0

	var/num_monkeys = MONKEY_MODE_MONKEYS
	var/num_players = num_players()

	if (num_players<=num_monkeys)
		num_monkeys = round(num_players/2)

	for(var/j = 1 to num_monkeys)
		if (!possible_monkeys.len)
			break
		var/datum/mind/monkey = pick(possible_monkeys)
		possible_monkeys-=monkey
		initial_monkeys += monkey
		monkey.special_role = "monkey"

	if(!initial_monkeys.len)
		return 0
	return 1

/datum/game_mode/monkey/post_setup()
	spawn (50)
		for (var/datum/mind/monkey in initial_monkeys)
			var/mob/living/carbon/human/H = monkey.current
			var/mob/living/carbon/monkey/new_monkey = H.monkeyize()
			new_monkey << "<B>Your goal is to capture the entire human civilization and your first target is Centcom. Hijack the shuttle without humans aboard!</B>"

		for (var/mob/living/carbon/monkey/rabid_monkey in mob_list)
			if (!(rabid_monkey.mind in initial_monkeys) && (!isturf(rabid_monkey.loc) || rabid_monkey.z!=1))
				continue
			rabid_monkey.contract_disease(new /datum/disease/jungle_fever,1,0)
		del(initial_monkeys)
	..()

/datum/game_mode/monkey/proc/is_important_monkey(var/mob/living/carbon/monkey/M as mob)
	var/turf/T = get_turf(M)
	var/area/A = get_area(M)
	if(M.stat!=2)

		for(var/datum/disease/D in M.viruses)
			if(istype(D, /datum/disease/jungle_fever) && ( T.z==1 || is_type_in_list(A, centcom_areas)))
				return 1


/datum/game_mode/monkey/check_win()
	if (state==MONKEY_MODE_SHUTTLE_CAPTURED || state==MONKEY_MODE_SHUTTLE_WITH_HUMANS)
		return
	var/infected_count = 0
	for (var/mob/living/carbon/monkey/rabid_monkey in mob_list)
		if (is_important_monkey(rabid_monkey))
			infected_count++
	if (infected_count==0)
		state = MONKEY_MODE_NO_RABID_LEFT

/datum/game_mode/monkey/check_finished()
	return (emergency_shuttle.location==2) || (state>0)

/datum/game_mode/monkey/declare_completion()
	var/monkeywin = 0
	if (state != MONKEY_MODE_NO_RABID_LEFT)
		for(var/mob/living/carbon/monkey/monkey_player in mob_list)
			if (is_important_monkey(monkey_player))
				var/area/A = get_area(monkey_player)
				if ( is_type_in_list(A, centcom_areas))
					monkeywin = 1
					break

		if(monkeywin)
			for(var/mob/living/carbon/human/human_player in mob_list)
				if (human_player.stat != 2)
					var/area/A = get_area(human_player)
					if (istype(A, /area/shuttle/escape/centcom))
						monkeywin = 0
						break

	if (monkeywin)
		feedback_set_details("round_end_result","win - monkey win")
		world << "<FONT size=3 color=red><B>The monkeys have won! Humanity is doomed!</B></FONT>"
		for (var/mob/living/carbon/human/player in player_list)
			spawn(rand(0,150))
				player.monkeyize()
		sleep(200)
	else
		feedback_set_details("round_end_result","loss - crew win")
		world << "<FONT size=3 color=red><B>The Research Staff has stopped the monkey invasion!</B></FONT>"
	..()
	return 1


/datum/game_mode/proc/auto_declare_completion_monkey()
	for(var/mob/living/carbon/monkey/monkey_player in mob_list)
		for(var/datum/disease/D in monkey_player.viruses)
			if (istype(D, /datum/disease/jungle_fever) && monkey_player.ckey)
				world << "<B>[monkey_player.ckey] was played infested [monkey_player]. [monkey_player.stat == 2 ? "(DEAD)" : ""]</B>"
	return 1

#undef MONKEY_MODE_RUNNING
#undef MONKEY_MODE_NO_RABID_LEFT
#undef MONKEY_MODE_SHUTTLE_CAPTURED
#undef MONKEY_MODE_SHUTTLE_WITH_HUMANS
