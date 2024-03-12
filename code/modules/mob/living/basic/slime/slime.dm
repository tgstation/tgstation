#define SLIME_EXTRA_SHOCK_COST 3
#define SLIME_EXTRA_SHOCK_THRESHOLD 8
#define SLIME_BASE_SHOCK_PERCENTAGE 10
#define SLIME_SHOCK_PERCENTAGE_PER_LEVEL 7

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

	damage_coeff = list(BRUTE = 1, BURN = -1, TOX = 1, STAMINA = 0, OXY = 1) //Healed by fire
	unsuitable_cold_damage = 15
	unsuitable_heat_damage = 0
	maximum_survivable_temperature = INFINITY

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
	/// No hunger
	var/hunger_disabled = FALSE

	///Has a mutator been used on the slime? Only one is allowed
	var/mutator_used = FALSE

	//The datum that handles the slime colour's core and possible mutations
	var/datum/slime_type/slime_type

	//CORE-CROSSING CODE

	///What cross core modification is being used.
	var/crossbreed_modification
	///How many extracts of the modtype have been applied.
	var/applied_crossbreed_amount = 0

	//AI related traits

	/// Instructions you can give to slimes
	var/static/list/pet_commands = list(
		/datum/pet_command/idle,
		/datum/pet_command/free,
		/datum/pet_command/follow,
		/datum/pet_command/point_targeting/attack,
	)

	///The current mood of the slime, set randomly or through emotes (if sentient).
	var/current_mood

/mob/living/basic/slime/Initialize(mapload, new_type=/datum/slime_type/grey, new_life_stage=SLIME_LIFE_STAGE_BABY)

	set_slime_type(new_type)
	set_life_stage(new_life_stage)
	update_name()
	regenerate_icons()

	. = ..()
	set_nutrition(700)

	AddComponent(/datum/component/buckle_mob_effect,  mob_effect_callback = CALLBACK(src, PROC_REF(feed_process)))
	AddComponent(/datum/component/health_scaling_effects, min_health_slowdown = 2)
	AddComponent(/datum/component/obeys_commands, pet_commands)

	AddElement(/datum/element/ai_retaliate)
	AddElement(/datum/element/footstep, footstep_type = FOOTSTEP_MOB_SLIME)
	AddElement(/datum/element/soft_landing)
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_SLIME, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)

	ADD_TRAIT(src, TRAIT_CANT_RIDE, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)

	RegisterSignal(src, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, PROC_REF(slime_pre_attack))

/mob/living/basic/slime/Destroy()

	UnregisterSignal(src, COMSIG_HOSTILE_PRE_ATTACKINGTARGET)

	for (var/action in actions)
		var/datum/action/action_to_remove = action
		action_to_remove.Remove(src)

	return ..()

///Random slime subtype
/mob/living/basic/slime/random/Initialize(mapload, new_colour, new_life_stage)
	. = ..(mapload, pick(subtypesof(/datum/slime_type)), prob(50) ? SLIME_LIFE_STAGE_ADULT : SLIME_LIFE_STAGE_BABY)

///Friendly docile subtype
/mob/living/basic/slime/pet
	hunger_disabled = TRUE

/mob/living/basic/slime/pet/Initialize(mapload, new_colour, new_life_stage)
	. = ..()
	set_pacified_behaviour()

///Hilbert subtype
/mob/living/basic/slime/hilbert/Initialize(mapload, new_colour, new_life_stage)
	. = ..(mapload, /datum/slime_type/bluespace)
	ai_controller?.set_blackboard_key(BB_RABID, TRUE)

//Overriden base procs

/mob/living/basic/slime/adjust_nutrition(change)
	..()
	nutrition = min(nutrition, max_nutrition)

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

/mob/living/basic/slime/get_status_tab_items()
	. = ..()
	if(!hunger_disabled)
		. += "Nutrition: [nutrition]/[max_nutrition]"

	switch(stat)
		if(HARD_CRIT, UNCONSCIOUS)
			. += "You are knocked out by high levels of BZ!"
		else
			. += "Power Level: [powerlevel]"

/mob/living/basic/slime/MouseDrop(atom/movable/target_atom as mob|obj)
	if(isliving(target_atom) && target_atom != src && usr == src)
		var/mob/living/food = target_atom
		if(can_feed_on(food))
			start_feeding(food)
	return ..()

///Slimes can hop off mobs they have latched onto
/mob/living/basic/slime/resist_buckle()
	if(isliving(buckled))
		buckled.unbuckle_mob(src,force=TRUE)

//slimes can not pull
/mob/living/basic/slime/start_pulling(atom/movable/moveable_atom, state, force = move_force, supress_message = FALSE)
	return

/mob/living/basic/slime/get_mob_buckling_height(mob/seat)
	if(..())
		return 3

/mob/living/basic/slime/examine(mob/user)
	. = list("<span class='info'>This is [icon2html(src, user)] \a <EM>[src]</EM>!")
	if (stat == DEAD)
		. += span_deadsay("It is limp and unresponsive.")
	else
		if (stat == UNCONSCIOUS || stat == HARD_CRIT) // Slime stasis
			. += span_deadsay("It appears to be alive but unresponsive.")
		if (getBruteLoss())
			. += "<span class='warning'>"
			if (getBruteLoss() < 40)
				. += "It has some punctures in its flesh!"
			else
				. += "<B>It has severe punctures and tears in its flesh!</B>"
			. += "</span>\n"

		switch(powerlevel)
			if(2 to 3)
				. += "It is flickering gently with a little electrical activity."

			if(4 to 5)
				. += "It is glowing gently with moderate levels of electrical activity."

			if(6 to 9)
				. += span_warning("It is glowing brightly with high levels of electrical activity.")

			if(10)
				. += span_warning("<B>It is radiating with massive levels of electrical activity!</B>")

	. += "</span>"


//New procs


///Handles the adverse effects of water on slimes
/mob/living/basic/slime/proc/apply_water()
	adjustBruteLoss(rand(15,20))
/*	if(client)
		return


	if(Target) // Like cats
		set_target(null)
		++discipline_stacks
	return
	*/

///Changes the slime's current life state
/mob/living/basic/slime/proc/set_life_stage(new_life_stage = SLIME_LIFE_STAGE_BABY)
	life_stage = new_life_stage

	switch(life_stage)
		if(SLIME_LIFE_STAGE_BABY)
			for(var/datum/action/innate/slime/reproduce/reproduce_action in actions)
				reproduce_action.Remove(src)

			GRANT_ACTION(/datum/action/innate/slime/evolve)

			health = initial(health)
			maxHealth = initial(maxHealth)

			obj_damage = initial(obj_damage)
			melee_damage_lower = initial(melee_damage_lower)
			melee_damage_upper = initial(melee_damage_upper)
			wound_bonus = initial(wound_bonus)

		if(SLIME_LIFE_STAGE_ADULT)

			for(var/datum/action/innate/slime/evolve/evolve_action in actions)
				evolve_action.Remove(src)

			GRANT_ACTION(/datum/action/innate/slime/reproduce)

			health = 200
			maxHealth = 200

			obj_damage = 15
			melee_damage_lower += 10
			melee_damage_upper += 10
			wound_bonus = -90

///Sets the slime's type, name and its icons
/mob/living/basic/slime/proc/set_slime_type(new_type)
	slime_type = new new_type

///randomizes the colour of a slime
/mob/living/basic/slime/proc/random_colour()
	set_slime_type(pick(subtypesof(/datum/slime_type)))
	update_name()
	regenerate_icons()

///Handles slime attacking restrictions, and any extra effects that would trigger
/mob/living/basic/slime/proc/slime_pre_attack(mob/living/basic/slime/our_slime, atom/target, proximity, modifiers)
	SIGNAL_HANDLER

	if(LAZYACCESS(modifiers, RIGHT_CLICK) && isliving(target) && target != src && usr == src)
		if(our_slime.can_feed_on(target))
			our_slime.start_feeding(target)
		return COMPONENT_CANCEL_ATTACK_CHAIN

	if(isAI(target)) //The aI is not tasty!
		target.balloon_alert(our_slime, "not tasty!")
		return COMPONENT_CANCEL_ATTACK_CHAIN

	if(our_slime.buckled == target) //If you try to attack the creature you are latched on, you instead cancel feeding
		our_slime.stop_feeding()
		return COMPONENT_CANCEL_ATTACK_CHAIN

	if(iscyborg(target))
		var/mob/living/silicon/robot/borg_target = target
		borg_target.flash_act()
		do_sparks(5, TRUE, borg_target)
		var/stunprob = our_slime.powerlevel * SLIME_SHOCK_PERCENTAGE_PER_LEVEL + SLIME_BASE_SHOCK_PERCENTAGE
		if(prob(stunprob) && our_slime.powerlevel >= SLIME_EXTRA_SHOCK_COST)
			our_slime.powerlevel = clamp(our_slime.powerlevel - SLIME_EXTRA_SHOCK_COST, SLIME_MIN_POWER, SLIME_MAX_POWER)
			borg_target.apply_damage(our_slime.powerlevel * rand(6, 10), BRUTE, spread_damage = TRUE, wound_bonus = CANT_WOUND)
			borg_target.visible_message(span_danger("The [our_slime.name] shocks [borg_target]!"), span_userdanger("The [our_slime.name] shocks you!"))
		else
			borg_target.visible_message(span_danger("The [our_slime.name] fails to hurt [borg_target]!"), span_userdanger("The [our_slime.name] failed to hurt you!"))

		return COMPONENT_CANCEL_ATTACK_CHAIN

	if(iscarbon(target) && our_slime.powerlevel > SLIME_MIN_POWER)
		var/mob/living/carbon/carbon_target = target
		var/stunprob = our_slime.powerlevel * SLIME_SHOCK_PERCENTAGE_PER_LEVEL + SLIME_BASE_SHOCK_PERCENTAGE  // 17 at level 1, 80 at level 10
		if(!prob(stunprob))
			return NONE // normal attack

		carbon_target.visible_message(span_danger("The [our_slime.name] shocks [carbon_target]!"), span_userdanger("The [our_slime.name] shocks you!"))

		do_sparks(5, TRUE, carbon_target)
		var/power = our_slime.powerlevel + rand(0,3)
		carbon_target.Paralyze(power * 2 SECONDS)
		carbon_target.set_stutter_if_lower(power * 2 SECONDS)
		if (prob(stunprob) && our_slime.powerlevel >= SLIME_EXTRA_SHOCK_COST)
			our_slime.powerlevel = clamp(our_slime.powerlevel - SLIME_EXTRA_SHOCK_COST, SLIME_MIN_POWER, SLIME_MAX_POWER)
			carbon_target.apply_damage(our_slime.powerlevel * rand(6, 10), BURN, spread_damage = TRUE, wound_bonus = CANT_WOUND)

	if(isslime(target))
		if(target == our_slime)
			return COMPONENT_CANCEL_ATTACK_CHAIN
		var/mob/living/basic/slime/target_slime = target
		if(target_slime.buckled)
			target_slime.stop_feeding(silent = TRUE)
			visible_message(span_danger("[our_slime] pulls [target_slime] off!"), \
				span_danger("You pull [target_slime] off!"))
			return NONE // normal attack
		//todo: make the targeted slime retaliate
		var/is_adult_slime = our_slime.life_stage == SLIME_LIFE_STAGE_ADULT
		if(target_slime.nutrition >= 100) //steal some nutrition. negval handled in life()
			var/stolen_nutrition = min(is_adult_slime ? 90 : 50, target_slime.nutrition)
			target_slime.adjust_nutrition(-stolen_nutrition)
			our_slime.adjust_nutrition(stolen_nutrition)
		if(target_slime.health > 0)
			our_slime.adjustBruteLoss(is_adult_slime ? -20 : -10)


///Spawns a crossed slimecore item
/mob/living/basic/slime/proc/spawn_corecross()
	var/static/list/crossbreeds = subtypesof(/obj/item/slimecross)
	visible_message(span_danger("[src] shudders, its mutated core consuming the rest of its body!"))
	playsound(src, 'sound/magic/smoke.ogg', 50, TRUE)
	var/selected_crossbreed_path
	for(var/crossbreed_path in crossbreeds)
		var/obj/item/slimecross/cross_item = crossbreed_path
		if(initial(cross_item.colour) == slime_type.colour && initial(cross_item.effect) == crossbreed_modification)
			selected_crossbreed_path = cross_item
			break
	if(selected_crossbreed_path)
		new selected_crossbreed_path(loc)
	else
		visible_message(span_warning("The mutated core shudders, and collapses into a puddle, unable to maintain its form."))
	qdel(src)


///Makes the slime peaceful and content
/mob/living/basic/slime/proc/set_pacified_behaviour()
	hunger_disabled = TRUE
	ai_controller?.set_blackboard_key(BB_RABID, FALSE)
	ai_controller?.set_blackboard_key(BB_HUNGER_DISABLED, TRUE)
	set_nutrition(700)

///Makes the slime angry and hungry
/mob/living/basic/slime/proc/set_enraged_behaviour()
	hunger_disabled = FALSE
	ai_controller?.set_blackboard_key(BB_HUNGER_DISABLED, FALSE)
	ai_controller?.set_blackboard_key(BB_RABID, TRUE)

///Makes the slime hungry but mostly friendly
/mob/living/basic/slime/proc/set_default_behaviour()
	hunger_disabled = FALSE
	ai_controller?.set_blackboard_key(BB_HUNGER_DISABLED, FALSE)
	ai_controller?.set_blackboard_key(BB_RABID, FALSE)

#undef SLIME_EXTRA_SHOCK_COST
#undef SLIME_EXTRA_SHOCK_THRESHOLD
#undef SLIME_BASE_SHOCK_PERCENTAGE
#undef SLIME_SHOCK_PERCENTAGE_PER_LEVEL
