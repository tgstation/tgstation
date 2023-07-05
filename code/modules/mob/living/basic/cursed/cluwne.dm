/// An abomination of a clown that has been cursed by the gods.
/mob/living/basic/cluwne
	name = "The Cluwne"
	real_name = "The Cluwne"
	desc = "A cluwne. A barely-human monstrosity that pissed off the gods."

	ai_controller = /datum/ai_controller/basic_controller/cluwne
	attack_sound = 'sound/items/bikehorn.ogg'
	attack_verb_continuous = "bonks"
	attack_verb_simple = "bonk"
	attack_vis_effect = ATTACK_EFFECT_KICK
	blood_volume = BLOOD_VOLUME_NORMAL
	faction = FACTION_CLOWN
	friendly_verb_continuous = "boops"
	friendly_verb_simple = "boop"
	gender = MALE
	gold_core_spawnable = HOSTILE_SPAWN
	health = 100
	icon_dead = "cluwne_dead"
	icon_gib = "clown_gib"
	icon_living = "cluwne"
	icon_state = "cluwne"
	maxHealth = 100
	mob_biotypes = MOB_ORGANIC
	response_disarm_continuous = "slips"
	response_disarm_simple = "slip"
	response_harm_continuous = "bonks"
	response_harm_simple = "bonk"
	response_help_continuous = "bops"
	response_help_simple = "bop"
	speak_emote = list("sadly honks", "womp-womps")
	verb_ask = "honks inquisitively"
	verb_exclaim = "honks loudly"
	verb_say = "honks"
	verb_yell = "honks loudly"

/mob/living/basic/cluwne/Initialize(mapload)
	. = ..()
	playsound(src, 'sound/misc/honk_echo_distant.ogg', 50, 2)
	var/newname = pick(GLOB.clown_names)
	name = newname
	real_name = newname
	AddElement(/datum/element/waddling)

/mob/living/basic/cluwne/Destroy()
	. = ..()
	UnregisterSignal(src, COMSIG_MOB_SAY)

/mob/living/basic/cluwne/attack_hand()
	. = ..()
	playsound(src, 'sound/items/bikehorn.ogg', 25, 2)

/mob/living/basic/cluwne/on_hit()
	. = ..()
	if(prob(50))
		playsound(src, 'sound/items/bikehorn.ogg', 25, 2)

/mob/living/basic/cluwne/death(gibbed)
	. = ..()
	playsound(src, 'sound/misc/sadtrombone.ogg', 50, 2)
	audible_message("[src] boops its last bop.")
	desc += "\nIt seems to have run out of tricks. Goodnight sweet prince."

/mob/living/basic/cluwne/say(message, bubble_type, list/spans)
	spans = list(SPAN_CLOWN)

	if(prob(5)) //the brain isn't fully gone yet...
		message = pick("AAAAAAA!!", "END MY SUFFERING", "I CANT TAKE THIS ANYMORE!!" ,"SOMEBODY STOP ME!!")
		return ..()

	if(prob(25))
		playsound(src, pick('sound/items/SitcomLaugh1.ogg', 'sound/items/SitcomLaugh2.ogg', 'sound/items/SitcomLaugh3.ogg'), 30, 2)

	message = pick(
		"HEEEENKKKKKK!!", \
		"HONK HONK HONK HONK!!",\
		"HONK HONK!!",\
		"HOOOOOONKKKK!!", \
		"HOOOOINKKKKKKK!!", \
		"HOINK HOINK HOINK HOINK!!", \
		"HOINK HOINK!!", \
		"HOOOOOOIIINKKKK!!"\
		)

	return ..()

/mob/living/basic/cluwne/emote(act, m_type = 1, message, intentional = FALSE)
	if(intentional)
		message = "makes a sad honk."
		act = "me"
		playsound(src, 'sound/items/bikehorn.ogg', 25, 2)
	..()

/datum/ai_controller/basic_controller/cluwne
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic/ignore_faction(),
	)

	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk

	planning_subtrees = list(
		/datum/ai_planning_subtree/find_nearest_thing_which_attacked_me_to_flee,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/random_speech/cluwne,
	)
