#define SLIME_EXTRA_SHOCK_COST 3
#define SLIME_EXTRA_SHOCK_THRESHOLD 8
#define SLIME_BASE_SHOCK_PERCENTAGE 10
#define SLIME_SHOCK_PERCENTAGE_PER_LEVEL 7

/mob/living/simple_animal/slime
	name = "grey baby slime (123)"
	icon = 'icons/mob/simple/slimes.dmi'
	icon_state = "grey baby slime"
	pass_flags = PASSTABLE | PASSGRILLE
	gender = NEUTER
	faction = list(FACTION_SLIME, FACTION_NEUTRAL)

	harm_intent_damage = 5
	icon_living = "grey baby slime"
	icon_dead = "grey baby slime dead"
	attack_verb_simple = "glomp"
	attack_verb_continuous = "glomps"
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "shoos"
	response_disarm_simple = "shoo"
	response_harm_continuous = "stomps on"
	response_harm_simple = "stomp on"
	emote_see = list("jiggles", "bounces in place")
	speak_emote = list("blorbles")
	bubble_icon = "slime"
	initial_language_holder = /datum/language_holder/slime

	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)

	maxHealth = 150
	health = 150
	mob_biotypes = MOB_SLIME
	melee_damage_lower = 5
	melee_damage_upper = 25
	wound_bonus = -45

	verb_say = "blorbles"
	verb_ask = "inquisitively blorbles"
	verb_exclaim = "loudly blorbles"
	verb_yell = "loudly blorbles"

	// canstun and canknockdown don't affect slimes because they ignore stun and knockdown variables
	// for the sake of cleanliness, though, here they are.
	status_flags = CANUNCONSCIOUS|CANPUSH

	footstep_type = FOOTSTEP_MOB_SLIME

	//Physiology

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

	///Determines if the AI loop is activated
	var/slime_ai_processing = FALSE
	///Attack cooldown
	var/is_attack_on_cooldown = FALSE
	///If a slime has been hit with a freeze gun, or wrestled/attacked off a human, they become disciplined and don't attack anymore for a while
	var/discipline_stacks = 0
	///Stored the world time when the slime's stun wears off
	var/stunned_until = 0

	///Is the slime docile?
	var/docile = FALSE

	///Used to understand when someone is talking to it
	var/slime_id = 0
	///AI variable - tells the slime to hunt this down
	var/mob/living/Target = null
	///AI variable - tells the slime to follow this person
	var/mob/living/Leader = null

	///Determines if it's been attacked recently. Can be any number, is a cooloff-ish variable
	var/attacked_stacks = 0
	///If set to 1, the slime will attack and eat anything it comes in contact with
	var/rabid = FALSE
	///AI variable, cooloff-ish for how long it's going to stay in one place
	var/holding_still = 0
	///AI variable, cooloff-ish for how long it's going to follow its target
	var/target_patience = 0
	///A list of friends; they are not considered targets for feeding; passed down after splitting
	var/list/Friends = list()
	///Last phrase said near it and person who said it
	var/list/speech_buffer = list()

/mob/living/simple_animal/slime/Initialize(mapload, new_type=/datum/slime_type/grey, new_life_stage=SLIME_LIFE_STAGE_BABY)
	var/datum/action/innate/slime/feed/feeding_action = new
	feeding_action.Grant(src)

	set_life_stage(new_life_stage)

	set_slime_type(new_type)
	. = ..()
	set_nutrition(700)

	AddElement(/datum/element/soft_landing)
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_SLIME, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)
	ADD_TRAIT(src, TRAIT_CANT_RIDE, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)

	RegisterSignal(src, COMSIG_LIVING_UNARMED_ATTACK, PROC_REF(slime_pre_attack))

/mob/living/simple_animal/slime/Destroy()
	for (var/A in actions)
		var/datum/action/AC = A
		AC.Remove(src)
	set_target(null)
	set_leader(null)
	clear_friends()
	return ..()

///Random slime subtype
/mob/living/simple_animal/slime/random/Initialize(mapload, new_colour, new_life_stage)
	. = ..(mapload, pick(subtypesof(/datum/slime_type)), prob(50) ? SLIME_LIFE_STAGE_ADULT : SLIME_LIFE_STAGE_BABY)

///Friendly docile subtype
/mob/living/simple_animal/slime/pet
	docile = TRUE

/mob/living/simple_animal/slime/update_name()
	///Checks if the slime has a generic name, in the format of baby/adult slime (123)
	var/static/regex/slime_name_regex = new("\\w+ (baby|adult) slime \\(\\d+\\)")
	if(slime_name_regex.Find(name))
		slime_id = rand(1, 1000)
		name = "[slime_type.colour] [life_stage] slime ([slime_id])"
		real_name = name
	return ..()

/mob/living/simple_animal/slime/regenerate_icons()
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

/mob/living/simple_animal/slime/updatehealth()
	. = ..()
	var/mod = 0
	if(!HAS_TRAIT(src, TRAIT_IGNOREDAMAGESLOWDOWN))
		var/health_deficiency = (maxHealth - health)
		if(health_deficiency >= 45)
			mod += (health_deficiency / 25)
		if(health <= 0)
			mod += 2
	add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/slime_healthmod, multiplicative_slowdown = mod)

/mob/living/simple_animal/slime/adjust_bodytemperature()
	. = ..()
	var/mod = 0
	if(bodytemperature >= 330.23) // 135 F or 57.08 C
		mod = -1 // slimes become supercharged at high temperatures
	else if(bodytemperature < 283.222)
		mod = ((283.222 - bodytemperature) / 10) * 1.75
	if(mod)
		add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/slime_tempmod, multiplicative_slowdown = mod)

/mob/living/simple_animal/slime/ObjBump(obj/bumped_object)
	if(client || powerlevel <= SLIME_MIN_POWER) // slimes with people in control can't accidentally attack
		return

	if (life_stage != SLIME_LIFE_STAGE_ADULT && !prob(5)) //its rare for baby slimes to actually damage windows
		return

	var/accidental_attack_probability = 10
	switch(powerlevel)
		if(1 to 2)
			accidental_attack_probability = 20
		if(3 to 4)
			accidental_attack_probability = 30
		if(5 to 6)
			accidental_attack_probability = 40
		if(7 to 8)
			accidental_attack_probability = 60
		if(9)
			accidental_attack_probability = 70
		if(10)
			accidental_attack_probability = 95
	if(!prob(accidental_attack_probability))
		return

	if(!istype(bumped_object, /obj/structure/window) && !istype(bumped_object, /obj/structure/grille))
		return

	if(nutrition > hunger_nutrition || is_attack_on_cooldown) //hungry slimes and slimes on cooldown will not attack
		return

	bumped_object.attack_animal(src)
	is_attack_on_cooldown = TRUE
	addtimer(VARSET_CALLBACK(src, is_attack_on_cooldown, FALSE), 4.5 SECONDS)

/mob/living/simple_animal/slime/get_status_tab_items()
	. = ..()
	if(!docile)
		. += "Nutrition: [nutrition]/[max_nutrition]"
	if(amount_grown >= SLIME_EVOLUTION_THRESHOLD)
		if(life_stage == SLIME_LIFE_STAGE_ADULT)
			. += "You can reproduce!"
		else
			. += "You can evolve!"

	switch(stat)
		if(HARD_CRIT, UNCONSCIOUS)
			. += "You are knocked out by high levels of BZ!"
		else
			. += "Power Level: [powerlevel]"


/mob/living/simple_animal/slime/MouseDrop(atom/movable/target_atom as mob|obj)
	if(isliving(target_atom) && target_atom != src && usr == src)
		var/mob/living/Food = target_atom
		if(can_feed_on(Food))
			start_feeding(Food)
	return ..()

/mob/living/simple_animal/slime/doUnEquip(obj/item/unequipped_item, force, newloc, no_move, invdrop = TRUE, silent = FALSE)
	return

/mob/living/simple_animal/slime/start_pulling(atom/movable/moveable_atom, state, force = move_force, supress_message = FALSE)
	return

/mob/living/simple_animal/slime/attack_ui(slot, params)
	return

/mob/living/simple_animal/slime/get_mob_buckling_height(mob/seat)
	if(..())
		return 3

/mob/living/simple_animal/slime/examine(mob/user)
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

/mob/living/simple_animal/slime/proc/apply_water()
	adjustBruteLoss(rand(15,20))
	if(client)
		return

	if(Target) // Like cats
		set_target(null)
		++discipline_stacks
	return

///Changes the slime's current life state
/mob/living/simple_animal/slime/proc/set_life_stage(new_life_stage = SLIME_LIFE_STAGE_BABY)
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

			max_nutrition = initial(max_nutrition)
			grow_nutrition = initial(grow_nutrition)
			hunger_nutrition = initial(hunger_nutrition)
			starve_nutrition = initial(starve_nutrition)

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

			max_nutrition += 200
			grow_nutrition += 200
			hunger_nutrition += 100
			starve_nutrition += 100

///Sets the slime's type, name and its icons
/mob/living/simple_animal/slime/proc/set_slime_type(new_type)
	slime_type = new new_type
	update_name()
	regenerate_icons()

///randomizes the colour of a slime
/mob/living/simple_animal/slime/proc/random_colour()
	set_slime_type(pick(subtypesof(/datum/slime_type)))

///Makes a slime not attack people for a while
/mob/living/simple_animal/slime/proc/discipline_slime(mob/user)
	if(stat)
		return

	if(prob(80) && !client)
		discipline_stacks++

		if(life_stage == SLIME_LIFE_STAGE_BABY && discipline_stacks == 1) //if the slime is a baby and has not been overly disciplined, it will give up its grudge
			attacked_stacks = 0

	set_target(null)
	if(buckled)
		stop_feeding(silent = TRUE) //we unbuckle the slime from the mob it latched onto.

	stunned_until = world.time + rand(2 SECONDS, 6 SECONDS)

	Stun(3)
	if(user)
		step_away(src,user,15)

	addtimer(CALLBACK(src, PROC_REF(slime_move), user), 0.3 SECONDS)

///Makes a slime move away, used for a timed callback
/mob/living/simple_animal/slime/proc/slime_move(mob/user)
	if(user)
		step_away(src,user,15)

///Spawns a crossed slimecore item
/mob/living/simple_animal/slime/proc/spawn_corecross()
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

///Handles slime attacking restrictions, and any extra effects that would trigger
/mob/living/simple_animal/slime/proc/slime_pre_attack(mob/living/simple_animal/slime/our_slime, atom/target, proximity, modifiers)
	SIGNAL_HANDLER
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
		var/mob/living/simple_animal/slime/target_slime = target
		if(target_slime.buckled)
			target_slime.stop_feeding(silent = TRUE)
			visible_message(span_danger("[our_slime] pulls [target_slime] off!"), \
				span_danger("You pull [target_slime] off!"))
			return NONE // normal attack
		target_slime.attacked_stacks += 5
		var/is_adult_slime = our_slime.life_stage == SLIME_LIFE_STAGE_ADULT
		if(target_slime.nutrition >= 100) //steal some nutrition. negval handled in life()
			var/stolen_nutrition = is_adult_slime ? 90 : 50
			target_slime.adjust_nutrition(-stolen_nutrition)
			our_slime.add_nutrition(stolen_nutrition)
		if(target_slime.health > 0)
			our_slime.adjustBruteLoss(is_adult_slime ? -20 : -10)

#undef SLIME_EXTRA_SHOCK_COST
#undef SLIME_EXTRA_SHOCK_THRESHOLD
#undef SLIME_BASE_SHOCK_PERCENTAGE
#undef SLIME_SHOCK_PERCENTAGE_PER_LEVEL
