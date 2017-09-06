//Gremlins
//Small monsters that don't attack humans or other animals. Instead they mess with electronics, computers and machinery

//List of objects that gremlins can't tamper with (because nobody coded an interaction for it)
//List starts out empty. Whenever a gremlin finds a machine that it couldn't tamper with, the machine's type is added here, and all machines of such type are ignored from then on (NOT SUBTYPES)
var/list/bad_gremlin_items = list()

/mob/living/simple_animal/hostile/gremlin
	name = "gremlin"
	desc = "This tiny creature finds great joy in discovering and using technology. Nothing excites it more than pushing random buttons on a computer to see what it might do."
	icon = 'hippiestation/icons/mob/mob.dmi'
	icon_state = "gremlin"
	icon_living = "gremlin"
	icon_dead = "gremlin_dead"

	health = 18
	maxHealth = 18
	search_objects = 3 //Completely ignore mobs

	//Tampering is handled by the 'npc_tamper()' obj proc
	wanted_objects = list(
		/obj/machinery,
		/obj/item/reagent_containers/food
	)

	dextrous = TRUE
	possible_a_intents = list(INTENT_HELP, INTENT_GRAB, INTENT_DISARM, INTENT_HARM)
	faction = list("meme", "gremlin")
	speed = 0.5
	gold_core_spawnable = 2
	unique_name = TRUE

	//Ensure gremlins don't attack other mobs
	melee_damage_upper = 0
	melee_damage_lower = 0
	attack_sound = null
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE

	//List of objects that we don't even want to try to tamper with
	//Subtypes of these are calculated too
	var/list/unwanted_objects = list(/obj/machinery/atmospherics/pipe, /turf, /obj/structure) //ensure gremlins dont try to fuck with walls / normal pipes / glass / etc

	//Amount of ticks spent pathing to the target. If it gets above a certain amount, assume that the target is unreachable and stop
	var/time_chasing_target = 0

	//If you're going to make gremlins slower, increase this value - otherwise gremlins will abandon their targets too early
	var/max_time_chasing_target = 2

	var/next_eat = 0

	//Last 20 heard messages are remembered by gremlins, and will be used to generate messages for comms console tampering, etc...
	var/list/hear_memory = list()
	var/const/max_hear_memory = 20

/mob/living/simple_animal/hostile/gremlin/AttackingTarget()
	var/is_hungry = world.time >= next_eat || prob(25)
	if(istype(target, /obj/item/reagent_containers/food) && is_hungry) //eat food if we're hungry or bored
		visible_message("<span class='danger'>[src] hungrily devours [target]!</span>")
		playsound(src, "sound/items/eatfood.ogg", 50, 1)
		qdel(target)
		LoseTarget()
		next_eat = world.time + rand(700, 3000) //anywhere from 70 seconds to 5 minutes until the gremlin is hungry again
		return
	if(istype(target, /obj))
		var/obj/M = target
		tamper(M)
		if(prob(50)) //50% chance to move to the next machine
			LoseTarget()

/mob/living/simple_animal/hostile/gremlin/Hear(message, atom/movable/speaker, message_langs, raw_message, radio_freq, list/spans, message_mode)
	. = ..()
	if(message)
		hear_memory.Insert(1, raw_message)
		if(hear_memory.len > max_hear_memory)
			hear_memory.Cut(hear_memory.len)

/mob/living/simple_animal/hostile/gremlin/proc/generate_markov_input()
	var/result = ""

	for(var/memory in hear_memory)
		result += memory + " "

	return result

/mob/living/simple_animal/hostile/gremlin/proc/generate_markov_chain()
	return markov_chain(generate_markov_input(), rand(2,5), rand(100,700)) //The numbers are chosen arbitarily

/mob/living/simple_animal/hostile/gremlin/proc/tamper(obj/M)
	switch(M.npc_tamper_act(src))
		if(NPC_TAMPER_ACT_FORGET)
			visible_message(pick(
			"<span class='notice'>\The [src] plays around with \the [M], but finds it rather boring.</span>",
			"<span class='notice'>\The [src] tries to think of some more ways to screw \the [M] up, but fails miserably.</span>",
			"<span class='notice'>\The [src] decides to ignore \the [M], and starts looking for something more fun.</span>"))

			bad_gremlin_items.Add(M.type)
			return FALSE
		if(NPC_TAMPER_ACT_NOMSG)
			//Don't create a visible message
			M.suit_fibers += "Hairs from a gremlin."
			return TRUE

		else
			visible_message(pick(
			"<span class='danger'>\The [src]'s eyes light up as \he tampers with \the [M].</span>",
			"<span class='danger'>\The [src] twists some knobs around on \the [M] and bursts into laughter!</span>",
			"<span class='danger'>\The [src] presses a few buttons on \the [M] and giggles mischievously.</span>",
			"<span class='danger'>\The [src] rubs its hands devilishly and starts messing with \the [M].</span>",
			"<span class='danger'>\The [src] turns a small valve on \the [M].</span>"))

	//Add a clue for detectives to find. The clue is only added if no such clue already existed on that machine
	M.suit_fibers += "Hairs from a gremlin."
	return TRUE

/mob/living/simple_animal/hostile/gremlin/CanAttack(atom/new_target)
	if(bad_gremlin_items.Find(new_target.type))
		return FALSE
	if(is_type_in_list(new_target, unwanted_objects))
		return FALSE
	if(istype(new_target, /obj/machinery))
		var/obj/machinery/M = new_target
		if(M.stat) //Unpowered or broken
			return FALSE
		else if(istype(new_target, /obj/machinery/door/firedoor))
			var/obj/machinery/door/firedoor/F = new_target
			//Only tamper with firelocks that are closed, opening them!
			if(!F.density)
				return FALSE

	return ..()

/mob/living/simple_animal/hostile/gremlin/Life()
	//Don't try to path to one target for too long. If it takes longer than a certain amount of time, assume it can't be reached and find a new one
	if(!target)
		time_chasing_target = 0
	else
		if(++time_chasing_target > max_time_chasing_target)
			LoseTarget()
			time_chasing_target = 0

	. = ..()

/mob/living/simple_animal/hostile/gremlin/EscapeConfinement()
	if(istype(loc, /obj) && CanAttack(loc)) //If we're inside a machine, screw with it
		var/obj/M = loc
		tamper(M)

	return ..()

//This allows player-controlled gremlins to tamper with machinery
/mob/living/simple_animal/hostile/gremlin/UnarmedAttack(var/atom/A)
	if(istype(A, /obj/machinery) || istype(A, /obj/structure))
		tamper(A)
	if(istype(target, /obj/item/reagent_containers/food)) //eat food
		visible_message("<span class='danger'>[src] hungrily devours [target]!</span>", "<span class='danger'>You hungrily devour [target]!</span>")
		playsound(src, "sound/items/eatfood.ogg", 50, 1)
		qdel(target)
		LoseTarget()
		next_eat = world.time + rand(700, 3000) //anywhere from 70 seconds to 5 minutes until the gremlin is hungry again

	return ..()

/mob/living/simple_animal/hostile/gremlin/IsAdvancedToolUser()
	return 1