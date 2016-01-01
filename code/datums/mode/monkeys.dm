/datum/role/monkey_carrier	//Administrative note, except for the initial carrier, this role doesn't imply antag status!
	name = "monkey carrier"
	id = "monkeycarrier"
	antag_flag = ROLE_MONKEY
	threat = 20 //wip
	restricted_jobs = list("Cyborg")
	associated_group	= /datum/group/monkey_swarm
	var/time_to_monkey	= 30
	var/ape_timer		= 0

/datum/role/monkey_carrier/gain_role()
	if(ticker.current_state < GAME_STATE_PLAYING)
		owner.current << "<B><span class='notice'>You are the Jungle Fever patient zero!!</B>"
		owner.current << "<b>You have been planted onto this station by the Animal Rights Consortium.</b>"
		owner.current << "<b>Soon the disease will transform you into an ape. Afterwards, you will be able spread the infection to others with a bite.</b>"
		owner.current << "<b>While your infection strain is undetectable by scanners, any other infectees will show up on medical equipment.</b>"
		owner.current << "<b>Your mission will be deemed a success if any of the live infected monkeys reach Centcom.</b>"
	..()

/datum/role/monkey_carrier/antag_life()
	if(!iscarbon(owner))
		return
	if(owner.current.reagents.has_reagent("banana")) //The psudeo infection is staved off with bananas, but there's no lasting immunity
		lose_role()
	if(ape_timer >= time_to_monkey)
		var/mob/living/carbon/C = owner.current
		C.monkeyize(TR_KEEPITEMS | TR_KEEPIMPLANTS | TR_KEEPORGANS | TR_KEEPDAMAGE | TR_KEEPVIRUS | TR_KEEPSE)
	if(ismonkey(owner.current)) //No matter how you got here it counts
		trade_role(/datum/role/monkey)
	ape_timer++

/datum/role/monkey
	name = "infected monkey"
	id = "monkey"
	antag_flag = ROLE_MONKEY
	threat = 20 //wip
	restricted_jobs = list("Cyborg", "AI")

/datum/role/monkey_carrier/gain_role()

/datum/role/monkey/antag_life()
	if(!ismonkey(owner.current))
		trade_role(/datum/role/monkey_carrier)

/datum/group/monkey_swarm
	name			= "swarm of monkeys"
	universal_group	= 1