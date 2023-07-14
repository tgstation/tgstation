#define KILLS_FOR_BLOOD_HUNGER 3 //how many do we need to kill for our bloody sprite/forced blood hunger
#define EXECUTE_TIME 10 SECONDS //how long it takes to execute someone using the animatronic
#define PHRASES_TO_ADD_ON_HUNGER list("GIVE ME CHILD TO EAT" = 2, "FEED ME SOULS" = 2, "I HUNGER FOR FLESH" = 2)
#define SOUNDS_TO_ADD_ON_HUNGER list('sound/voice/ghost_whisper.ogg', 'sound/hallucinations/radio_static.ogg')
//very similar to living statues however we cant make it a subtype due to needing to handle a few things differently, mainly say()
/mob/living/basic/monkey_animatronic
	name = "Monke"
	desc = "A lovable and legally distinct mascot!"
	icon = 'monkestation/icons/mob/basic/monkey_animatronic.dmi'
	icon_state = "monkey_animatronic_1"
	icon_living = "monkey_animatronic_1"
	icon_dead = "monkey_animatronic_1"
	gender = NEUTER
	istate = ISTATE_HARM|ISTATE_BLOCKING
	mob_biotypes = MOB_ROBOTIC
	gold_core_spawnable = NO_SPAWN

	response_help_continuous = "touches"
	response_help_simple = "touch"
	response_disarm_continuous = "pushes"
	response_disarm_simple = "push"

	maxHealth = 50000
	health = 50000
	obj_damage = 100
	melee_damage_lower = 68
	melee_damage_upper = 83
	speed = -1
	attack_verb_continuous = "spooks"
	attack_verb_simple = "spook"
	attack_vis_effect = ATTACK_EFFECT_SMASH

	faction = list(FACTION_STATUE)
	speak_emote = list("makes a sound from its voicebox resembling")
	death_message = "falls apart into a large pile of servos."
	unsuitable_atmos_damage = 0
	unsuitable_cold_damage = 0
	unsuitable_heat_damage = 0

	hud_possible = list(ANTAG_HUD)

	sight = SEE_SELF|SEE_MOBS|SEE_OBJS|SEE_TURFS

	move_force = MOVE_FORCE_OVERPOWERING
	move_resist = MOVE_FORCE_EXTREMELY_STRONG
	pull_force = MOVE_FORCE_OVERPOWERING

	lighting_cutoff_red = 15
	lighting_cutoff_green = 10
	lighting_cutoff_blue = 25

	ai_controller = /datum/ai_controller/basic_controller/animatronic

	///list of players we have killed/bitten
	var/list/killed_list = list()
	///have we become hostile(pretty much just a living statue), set to TRUE if we have bitten 3 people or been emagged
	var/blood_hunger = FALSE
	///phrase list
	var/list/phrase_list = list("Hey kids, buy more bananas!" = 5,
							    "Go down to the bar and get a drink, Banana Honk is my favorite." = 5,
							    "All employees are treated to unlimited free arcade usage." = 4,
							    "All new piss free ballpit!" = 3,
							    "I have never once crushed a skull.(This is not a guarantee Monke has never crushed a skull.)" = 2,
							    "The other performers died. IN THE WAR." = 1)
	///list of sounds we can play
	var/list/sound_list = list('sound/machines/copier.ogg',
							   'sound/mecha/hydraulic.ogg',
							   'sound/mecha/mechmove01.ogg',
							   'sound/mecha/mechmove04.ogg',
							   'sound/machines/destructive_scanner/ScanSafe.ogg')

/mob/living/basic/monkey_animatronic/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSprocessing, src) //SSmobs does not work for processing so I guess ill use this
	ADD_TRAIT(src, TRAIT_UNOBSERVANT, INNATE_TRAIT)

/mob/living/basic/monkey_animatronic/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/mob/living/basic/monkey_animatronic/process(seconds_per_tick)
	if(prob(2))
		SpinAnimation(7, 3)
		return
	if(prob(2))
		spin(2 SECONDS, 1)
		return
	if(prob(2))
		say(pick_weight(phrase_list))
		return
	if(prob(2))
		playsound(src, pick(sound_list), 50)
		return

/mob/living/basic/monkey_animatronic/emp_act(severity)
	. = ..()
	apply_damage(50, BRUTE)
	apply_damage((200 * severity), BURN)

/mob/living/basic/monkey_animatronic/emag_act(mob/user, obj/item/card/emag/emag_card)
	. = ..()
	if(!blood_hunger)
		icon_state = "monkey_animatronic_2"
		become_blood_hungry()

/mob/living/basic/monkey_animatronic/attack_hand(mob/living/carbon/human/user, list/modifiers)
	. = ..()
	if(.)
		return

	if(user.pulling && isliving(user.pulling))
		var/mob/living/pulled = user.pulling
		if(do_after(user, EXECUTE_TIME))
			if(iscarbon(pulled))
				var/mob/living/carbon/carbon_pulled = pulled
				carbon_pulled.adjustOrganLoss(ORGAN_SLOT_BRAIN, 150, 150) //large amount of brain damage but it will never give you brain death
				carbon_pulled.apply_damage(150, BRUTE, HEAD)
			else
				pulled.apply_damage_type(150, BRUTE)

			if(pulled.client && !killed_list[pulled])
				killed_list[pulled] = TRUE
			check_blood_hunger()

/mob/living/basic/monkey_animatronic/examine(mob/user)
	. = ..()
	if(isobserver(user))
		. += "It has killed [killed_list.len] so far."

	if(blood_hunger)
		. += "It's glaring at you."

/mob/living/basic/monkey_animatronic/melee_attack(atom/target, list/modifiers)
	. = ..()
	var/mob/living/living_target = target
	if(!istype(living_target))
		return

	if(living_target.stat != CONSCIOUS && living_target.client && !killed_list[living_target])
		killed_list[living_target] = TRUE
		check_blood_hunger()

/mob/living/basic/monkey_animatronic/proc/check_blood_hunger()
	if(killed_list.len >= KILLS_FOR_BLOOD_HUNGER)
		icon_state = "monkey_animatronic_3"
		desc = "WAS THAT THE BITE OF 2187?!" //no im not sorry
		if(!blood_hunger)
			become_blood_hungry()

/mob/living/basic/monkey_animatronic/proc/become_blood_hungry()
	blood_hunger = TRUE
	animate_movement = NO_STEPS
	AddComponent(/datum/component/unobserved_actor, unobserved_flags = NO_OBSERVED_MOVEMENT | NO_OBSERVED_ATTACKS)

	var/datum/action/cooldown/spell/aoe/flicker_lights/flicker = new(src)
	flicker.Grant(src)
	var/datum/action/cooldown/spell/aoe/blindness/blind = new(src)
	blind.Grant(src)

	phrase_list += PHRASES_TO_ADD_ON_HUNGER
	sound_list += SOUNDS_TO_ADD_ON_HUNGER

/datum/ai_controller/basic_controller/animatronic
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic(),
		BB_LOW_PRIORITY_HUNTING_TARGET = null,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target/animatronic,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/animatronic,
		/datum/ai_planning_subtree/find_and_hunt_target/look_for_light_fixtures,
	)

//gonna need review on this, I have no idea how to do AIs
/datum/ai_planning_subtree/simple_find_target/animatronic/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if(istype(controller.pawn, /mob/living/basic/monkey_animatronic))
		var/mob/living/basic/monkey_animatronic/animatronic_pawn = controller.pawn
		if(!animatronic_pawn.blood_hunger) //if they are not blood hungry then dont do anything(hopefully), only way I can think of doing this
			return SUBTREE_RETURN_FINISH_PLANNING //no idea if this is the correct thing to use
	. = ..()

/datum/ai_planning_subtree/basic_melee_attack_subtree/animatronic
	melee_attack_behavior = /datum/ai_behavior/basic_melee_attack/animatronic

/datum/ai_behavior/basic_melee_attack/animatronic
	action_cooldown = 1 SECONDS

#undef KILLS_FOR_BLOOD_HUNGER
#undef EXECUTE_TIME
#undef PHRASES_TO_ADD_ON_HUNGER
#undef SOUNDS_TO_ADD_ON_HUNGER
