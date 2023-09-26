
/mob/living/basic/snake
	name = "snake"
	desc = "A slithery snake. These legless reptiles are the bane of mice and adventurers alike."
	icon_state = "snake"
	icon_living = "snake"
	icon_dead = "snake_dead"
	speak_emote = list("hisses")

	health = 20
	maxHealth = 20
	melee_damage_lower = 5
	melee_damage_upper = 6
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE

	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"
	attack_sound = 'sound/weapons/bite.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE

	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "shoos"
	response_disarm_simple = "shoo"
	response_harm_continuous = "steps on"
	response_harm_simple = "step on"

	density = FALSE
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_SMALL

	faction = list(FACTION_HOSTILE)
	mob_biotypes = MOB_ORGANIC|MOB_BEAST|MOB_REPTILE
	gold_core_spawnable = FRIENDLY_SPAWN

	ai_controller = /datum/ai_controller/basic_controller/snake

/mob/living/basic/snake/Initialize(mapload, special_reagent)
	. = ..()
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)
	RegisterSignal(src, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, PROC_REF(on_attack))

	AddElement(/datum/element/swabable, CELL_LINE_TABLE_SNAKE, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)

	if(isnull(special_reagent))
		special_reagent = /datum/reagent/toxin

	AddElement(/datum/element/venomous, special_reagent, 4)

/mob/living/basic/snake/proc/on_attack(mob/living/basic/source, atom/target)
	if(!ismouse(target))
		return

	visible_message(
		span_notice("[name] consumes [target] in a single gulp!"),
		span_notice("You consume [target] in a single gulp!"),
		span_hear("You hear a small scuffling followed by a silent gulp.")
	)

	QDEL_NULL(target)
	adjustBruteLoss(-2)
	return COMPONENT_HOSTILE_NO_ATTACK

/mob/living/basic/snake/ListTargets(atom/the_target)
	var/atom/target_from = GET_TARGETS_FROM(src)
	. = oview(vision_range, target_from) //get list of things in vision range
	var/list/living_mobs = list()
	var/list/mice = list()
	for (var/HM in .)
		//Yum a tasty mouse
		if(ismouse(HM))
			mice += HM
		if(isliving(HM))
			living_mobs += HM

	// if no tasty mice to chase, lets chase any living mob enemies in our vision range
	if(length(mice))
		return mice

	var/list/actual_enemies = list()
	for(var/datum/weakref/enemy as anything in enemies)
		var/mob/flesh_and_blood = enemy.resolve()
		if(!flesh_and_blood)
			enemies -= enemy
			continue
		actual_enemies += flesh_and_blood

	//Filter living mobs (in range mobs) by those we consider enemies (retaliate behaviour)
	return  living_mobs & actual_enemies


/datum/ai_controller/basic_controller/snake
