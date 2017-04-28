/datum/game_mode
	var/list/ape_infectees = list()

/datum/game_mode/monkey
	name = "monkey"
	config_tag = "monkey"
	antag_flag = ROLE_MONKEY

	required_players = 20
	required_enemies = 1
	recommended_enemies = 1

	restricted_jobs = list("Cyborg", "AI")

	var/carriers_to_make = 1
	var/list/carriers = list()

	var/monkeys_to_win = 1
	var/escaped_monkeys = 0

	var/players_per_carrier = 30


/datum/game_mode/monkey/pre_setup()
	carriers_to_make = max(round(num_players()/players_per_carrier, 1), 1)

	for(var/j = 0, j < carriers_to_make, j++)
		if (!antag_candidates.len)
			break
		var/datum/mind/carrier = pick(antag_candidates)
		carriers += carrier
		carrier.special_role = "monkey"
		carrier.restricted_roles = restricted_jobs
		log_game("[carrier.key] (ckey) has been selected as a Jungle Fever carrier")
		antag_candidates -= carrier

	if(!carriers.len)
		return 0
	return 1


/datum/game_mode/monkey/announce()
	to_chat(world, "<B>The current game mode is - Monkey!</B>")
	to_chat(world, "<B>One or more crewmembers have been infected with Jungle Fever! Crew: Contain the outbreak. None of the infected monkeys may escape alive to Centcom. \
				Monkeys: Ensure that your kind lives on! Rise up against your captors!</B>")


/datum/game_mode/monkey/proc/greet_carrier(datum/mind/carrier)
	to_chat(carrier.current, "<B><span class='notice'>You are the Jungle Fever patient zero!!</B>")
	to_chat(carrier.current, "<b>You have been planted onto this station by the Animal Rights Consortium.</b>")
	to_chat(carrier.current, "<b>Soon the disease will transform you into an ape. Afterwards, you will be able spread the infection to others with a bite.</b>")
	to_chat(carrier.current, "<b>While your infection strain is undetectable by scanners, any other infectees will show up on medical equipment.</b>")
	to_chat(carrier.current, "<b>Your mission will be deemed a success if any of the live infected monkeys reach Centcom.</b>")
	return

/datum/game_mode/monkey/post_setup()
	for(var/datum/mind/carriermind in carriers)
		greet_carrier(carriermind)
		ape_infectees += carriermind

		var/datum/disease/D = new /datum/disease/transformation/jungle_fever
		D.visibility_flags = HIDDEN_SCANNER|HIDDEN_PANDEMIC
		D.holder = carriermind.current
		D.affected_mob = carriermind.current
		carriermind.current.viruses += D
	..()

/datum/game_mode/monkey/check_finished()
	if((SSshuttle.emergency.mode == SHUTTLE_ENDGAME) || station_was_nuked)
		return 1

	if(!round_converted)
		for(var/datum/mind/monkey_mind in ape_infectees)
			continuous_sanity_checked = 1
			if(monkey_mind.current && monkey_mind.current.stat != DEAD)
				return 0

		var/datum/disease/D = new /datum/disease/transformation/jungle_fever() //ugly but unfortunately needed
		for(var/mob/living/carbon/human/H in GLOB.living_mob_list)
			if(H.mind && H.stat != DEAD)
				if(H.HasDisease(D))
					return 0

	..()

/datum/game_mode/monkey/proc/check_monkey_victory()
	if(SSshuttle.emergency.mode != SHUTTLE_ENDGAME)
		return 0
	var/datum/disease/D = new /datum/disease/transformation/jungle_fever()
	for(var/mob/living/carbon/monkey/M in GLOB.living_mob_list)
		if (M.HasDisease(D))
			if(M.onCentcom() || M.onSyndieBase())
				escaped_monkeys++
	if(escaped_monkeys >= monkeys_to_win)
		return 1
	else
		return 0

/datum/game_mode/proc/add_monkey(datum/mind/monkey_mind)
	ape_infectees |= monkey_mind
	monkey_mind.special_role = "Infected Monkey"

/datum/game_mode/proc/remove_monkey(datum/mind/monkey_mind)
	ape_infectees.Remove(monkey_mind)
	monkey_mind.special_role = null


/datum/game_mode/monkey/declare_completion()
	if(check_monkey_victory())
		SSblackbox.set_details("round_end_result","win - monkey win")
		SSblackbox.set_val("round_end_result",escaped_monkeys)
		to_chat(world, "<span class='userdanger'>The monkeys have overthrown their captors! Eeek eeeek!!</span>")
	else
		SSblackbox.set_details("round_end_result","loss - staff stopped the monkeys")
		SSblackbox.set_val("round_end_result",escaped_monkeys)
		to_chat(world, "<span class='userdanger'>The staff managed to contain the monkey infestation!</span>")
