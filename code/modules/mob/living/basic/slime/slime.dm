/mob/living/basic/slime
	name = "grey baby slime (123)"
	icon = 'icons/mob/simple/slimes.dmi'
	icon_state = "grey baby slime"
	pass_flags = PASSTABLE | PASSGRILLE
	gender = NEUTER
	faction = list(FACTION_SLIME, FACTION_NEUTRAL)

	icon_living = "grey baby slime"
	icon_dead = "grey baby slime dead"

	//Base physiology

	maxHealth = 150
	health = 150
	mob_biotypes = MOB_SLIME
	melee_damage_lower = 5
	melee_damage_upper = 25
	wound_bonus = -45
	can_buckle_to = FALSE

	//Messages

	attack_verb_simple = "glomp"
	attack_verb_continuous = "glomps"

	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "shoos"
	response_disarm_simple = "shoo"
	response_harm_continuous = "stomps on"
	response_harm_simple = "stomp on"

	//Speech

	speak_emote = list("blorbles")
	bubble_icon = "slime"
	initial_language_holder = /datum/language_holder/slime

	verb_say = "blorbles"
	verb_ask = "inquisitively blorbles"
	verb_exclaim = "loudly blorbles"
	verb_yell = "loudly blorbles"

	//AI controller

	ai_controller = /datum/ai_controller/basic_controller/slime

	//Slime physiology
	///What is our current lifestage?
	var/life_stage = SLIME_LIFE_STAGE_BABY

	///The number of /obj/item/slime_extract's the slime has left inside
	var/cores = 1
	///Chance of mutating, should be between 25 and 35
	var/mutation_chance = 30
	///1-10 controls how much electricity they are generating
	var/powerlevel = SLIME_MIN_POWER
	///Controls how long the slime has been overfed, if 10, grows or reproduces
	var/amount_grown = 0
	///The maximum amount of nutrition a slime can contain
	var/max_nutrition = 1000
	/// Above it we grow our amount_grown and our power_level, below it we can eat
	var/grow_nutrition = 800
	/// Below this, we feel hungry
	var/hunger_nutrition = 500
	/// Below this, we feel starving
	var/starve_nutrition = 200

	///Has a mutator been used on the slime? Only one is allowed
	var/mutator_used = FALSE
	///Is the slime forced into being immobile, despite the gases present?
	var/force_stasis = FALSE

	//The datum that handles the slime colour's core and possible mutations
	var/datum/slime_type/slime_type

	//CORE-CROSSING CODE

	///What cross core modification is being used.
	var/crossbreed_modification
	///How many extracts of the modtype have been applied.
	var/applied_crossbreed_amount = 0

	//AI related traits

	///The current mood of the slime, set randomly or through emotes (if sentient).
	var/current_mood

/mob/living/basic/slime/Initialize(mapload, new_type=/datum/slime_type/grey, new_life_stage=SLIME_LIFE_STAGE_BABY)
	. = ..()

	set_life_stage(new_life_stage)
	set_slime_type(new_type)
	. = ..()
	set_nutrition(700)

	AddElement(/datum/element/footstep, footstep_type = FOOTSTEP_MOB_SLIME)
	AddElement(/datum/element/soft_landing)
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_SLIME, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)

	ADD_TRAIT(src, TRAIT_CANT_RIDE, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)

	RegisterSignal(src, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, PROC_REF(slime_pre_attack))

/mob/living/simple_animal/slime/Destroy()
	for (var/A in actions)
		var/datum/action/AC = A
		AC.Remove(src)
	set_target(null)
	set_leader(null)
	clear_friends()
	return ..()

///Random slime subtype
/mob/living/basic/slime/random/Initialize(mapload, new_colour, new_life_stage)
	. = ..(mapload, pick(subtypesof(/datum/slime_type)), prob(50) ? SLIME_LIFE_STAGE_ADULT : SLIME_LIFE_STAGE_BABY)

///Friendly docile subtype
/mob/living/basic/slime/pet
	ai_controller = /datum/ai_controller/basic_controller/slime/docile

/mob/living/basic/slime/update_name()
	///Checks if the slime has a generic name, in the format of baby/adult slime (123)
	var/static/regex/slime_name_regex = new("\\w+ (baby|adult) slime \\(\\d+\\)")
	if(slime_name_regex.Find(name))
		var/slime_id = rand(1, 1000)
		name = "[slime_type.colour] [life_stage] slime ([slime_id])"
		real_name = name
	return ..()

/mob/living/basic/slime/regenerate_icons()
	cut_overlays()
	var/icon_text = "[slime_type.colour] [life_stage] slime"
	icon_dead = "[icon_text] dead"
	if(stat != DEAD)
		icon_state = icon_text
		if(current_mood && !stat)
			add_overlay("aslime-[current_mood]")
	else
		icon_state = icon_dead
	..()

///Changes the slime's current life state
/mob/living/basic/slime/proc/set_life_stage(new_life_stage = SLIME_LIFE_STAGE_BABY)

	switch(life_stage)
		if(SLIME_LIFE_STAGE_BABY)
			//for(var/datum/action/innate/slime/reproduce/reproduce_action in actions)
			//	reproduce_action.Remove(src)

			GRANT_ACTION(/datum/action/innate/slime/evolve)

			health = initial(health)
			maxHealth = initial(maxHealth)

			obj_damage = initial(obj_damage)
			melee_damage_lower = initial(melee_damage_lower)
			melee_damage_upper = initial(melee_damage_upper)
			wound_bonus = initial(wound_bonus)

			max_nutrition = initial(max_nutrition)
			grow_nutrition = initial(grow_nutrition)
			hunger_nutrition = initial(hunger_nutrition)
			starve_nutrition = initial(starve_nutrition)

		if(SLIME_LIFE_STAGE_ADULT)

			//for(var/datum/action/innate/slime/evolve/evolve_action in actions)
			//	evolve_action.Remove(src)

			GRANT_ACTION(/datum/action/innate/slime/reproduce)

			health = 200
			maxHealth = 200

			obj_damage = 15
			melee_damage_lower += 10
			melee_damage_upper += 10
			wound_bonus = -90

			max_nutrition += 200
			grow_nutrition += 200
			hunger_nutrition += 100
			starve_nutrition += 100

///Sets the slime's type, name and its icons
/mob/living/basic/slime/proc/set_slime_type(new_type)
	slime_type = new new_type
	update_name()
	regenerate_icons()

///randomizes the colour of a slime
/mob/living/basic/slime/proc/random_colour()
	set_slime_type(pick(subtypesof(/datum/slime_type)))

///Handles slime attacking restrictions, and any extra effects that would trigger
/mob/living/basic/slime/proc/slime_pre_attack(mob/living/basic/slime/our_slime, atom/target, proximity, modifiers)
	SIGNAL_HANDLER
	if(isAI(target)) //The aI is not tasty!
		target.balloon_alert(our_slime, "not tasty!")
		return COMPONENT_CANCEL_ATTACK_CHAIN
