//cow
/mob/living/basic/cow
	name = "cow"
	desc = "Known for their milk, just don't tip them over."
	icon_state = "cow"
	icon_living = "cow"
	icon_dead = "cow_dead"
	icon_gib = "cow_gib"
	gender = FEMALE
	mob_biotypes = MOB_ORGANIC | MOB_BEAST
	speak_emote = list("moos","moos hauntingly")
	speed = 1.1
	see_in_dark = 6
	butcher_results = list(/obj/item/food/meat/slab = 6)
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	attack_verb_continuous = "kicks"
	attack_verb_simple = "kick"
	attack_sound = 'sound/weapons/punch1.ogg'
	attack_vis_effect = ATTACK_EFFECT_KICK
	health = 50
	maxHealth = 50
	gold_core_spawnable = FRIENDLY_SPAWN
	blood_volume = BLOOD_VOLUME_NORMAL

/mob/living/basic/cow/Initialize()
	AddComponent(/datum/component/tippable, \
		tip_time = 0.5 SECONDS, \
		untip_time = 0.5 SECONDS, \
		self_right_time = rand(25 SECONDS, 50 SECONDS), \
		post_tipped_callback = CALLBACK(src, .proc/after_cow_tipped))
	AddElement(/datum/element/pet_bonus, "moos happily!")
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_COW, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)
	udder_component()
	make_tameable()
	. = ..()

///wrapper for the udder component addition so you can have uniquely uddered cow subtypes
/mob/living/basic/cow/proc/udder_component()
	AddComponent(/datum/component/udder)

///wrapper for the tameable component addition so you can have non tamable cow subtypes
/mob/living/basic/cow/proc/make_tameable()
	AddComponent(/datum/component/tameable, food_types = list(/obj/item/food/grown/wheat), tame_chance = 25, bonus_tame_chance = 15, after_tame = CALLBACK(src, .proc/tamed))

/mob/living/basic/cow/proc/tamed(mob/living/tamer)
	can_buckle = TRUE
	buckle_lying = 0
	AddElement(/datum/element/ridable, /datum/component/riding/creature/cow)

/*
 * Proc called via callback after the cow is tipped by the tippable component.
 * Begins a timer for us pleading for help.
 *
 * tipper - the mob who tipped us
 */
/mob/living/basic/cow/proc/after_cow_tipped(mob/living/carbon/tipper)
	addtimer(CALLBACK(src, .proc/look_for_help, tipper), rand(10 SECONDS, 20 SECONDS))

/*
 * Find a mob in a short radius around us (prioritizing the person who originally tipped us)
 * and either look at them for help, or give up. No actual mechanical difference between the two.
 *
 * tipper - the mob who originally tipped us
 */
/mob/living/basic/cow/proc/look_for_help(mob/living/carbon/tipper)
	// visible part of the visible message
	var/seen_message = ""
	// self part of the visible message
	var/self_message = ""
	// the mob we're looking to for aid
	var/mob/living/carbon/savior
	// look for someone in a radius around us for help. If our original tipper is in range, prioritize them
	for(var/mob/living/carbon/potential_aid in oview(3, get_turf(src)))
		if(potential_aid == tipper)
			savior = tipper
			break
		savior = potential_aid

	if(prob(75) && savior)
		var/text = pick("imploringly", "pleadingly", "with a resigned expression")
		seen_message = "[src] looks at [savior] [text]."
		self_message = "You look at [savior] [text]."
	else
		seen_message = "[src] seems resigned to its fate."
		self_message = "You resign yourself to your fate."
	visible_message(span_notice("[seen_message]"), span_notice("[self_message]"))

/datum/ai_controller/basic_controller/cow

	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	planning_subtrees = list(
		/datum/ai_planning_subtree/random_speech/cow,
	)

/datum/ai_controller/basic_controller/cow/PerformIdleBehavior(delta_time)
	. = ..()
	var/mob/living/living_pawn = pawn

	if(DT_PROB(25, delta_time) && (living_pawn.mobility_flags & MOBILITY_MOVE) && isturf(living_pawn.loc) && !living_pawn.pulledby)
		var/move_dir = pick(GLOB.alldirs)
		living_pawn.Move(get_step(living_pawn, move_dir), move_dir)

///Wisdom cow, gives XP to a random skill and speaks wisdoms
/mob/living/basic/cow/wisdom
	name = "wisdom cow"
	desc = "Known for its wisdom, shares it with all."
	gold_core_spawnable = FALSE

/mob/living/basic/cow/wisdom/make_tameable()
	return //cannot tame me!

/datum/ai_controller/basic_controller/cow/wisdom
	planning_subtrees = list(
		/datum/ai_planning_subtree/random_speech/cow/wisdom,
	)

///Give intense wisdom to the attacker if they're being friendly about it
/mob/living/basic/cow/wisdom/attack_hand(mob/living/carbon/user, list/modifiers)
	if(!stat && !user.combat_mode)
		to_chat(user, span_nicegreen("[src] whispers you some intense wisdoms and then disappears!"))
		user.mind?.adjust_experience(pick(GLOB.skill_types), 500)
		do_smoke(1, get_turf(src))
		qdel(src)
		return
	return ..()

/mob/living/basic/cow/moonicorn
	name = "moonicorn"
	desc = "Magical cow of legend. Its horn will pacify anything it touches, rendering victims mostly helpless. \
		Victims, yes, because despite the enimatic and wonderous appearance, the moonicorn is incredibly aggressive."
	icon_state = "cow"
	icon_living = "cow"
	icon_dead = "cow_dead"
	icon_gib = "cow_gib"
	speed = 1.4
	melee_damage_lower = 25
	melee_damage_upper = 25

/mob/living/basic/cow/moonicorn/Initialize()
	. = ..()
	AddElement(/datum/element/venomous, /datum/reagent/pax, 5)
	AddElement(/datum/element/movement_turf_changer, /turf/open/floor/grass/fairy)

/mob/living/basic/cow/moonicorn/udder_component()
	AddComponent(/datum/component/udder, /obj/item/udder, null, null, /datum/reagent/drug/mushroomhallucinogen)

/mob/living/basic/cow/moonicorn/make_tameable()
	AddComponent(/datum/component/tameable, food_types = list(/obj/item/food/grown/galaxythistle), tame_chance = 25, bonus_tame_chance = 15, after_tame = CALLBACK(src, .proc/tamed))

/mob/living/basic/cow/moonicorn/tamed(mob/living/tamer)
	. = ..()
	///stop killing my FRIENDS
	faction |= tamer.faction

/datum/ai_controller/basic_controller/cow/moonicorn
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic/moonicorn()
	)

	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	planning_subtrees = list(
		/datum/ai_planning_subtree/random_speech/cow,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/moonicorn,
	)

/datum/ai_planning_subtree/basic_melee_attack_subtree/moonicorn
	melee_attack_behavior = /datum/ai_behavior/basic_melee_attack/moonicorn

/datum/ai_behavior/basic_melee_attack/moonicorn
	//it's a fairly strong attack and it applies pax, so they do not attack often
	action_cooldown = 2 SECONDS

///moonicorns will not attack people holding something that could tame them.
/datum/targetting_datum/basic/moonicorn

/datum/targetting_datum/basic/moonicorn/can_attack(mob/living/living_mob, atom/the_target)
	. = ..()
	if(!.)
		return FALSE

	if(isliving(the_target)) //Targetting vs living mobs
		var/mob/living/living_target = the_target
		for(var/obj/item/food/grown/galaxythistle/tame_food in living_target.held_items)
			return FALSE //heyyy this can tame me! let's NOT fight
