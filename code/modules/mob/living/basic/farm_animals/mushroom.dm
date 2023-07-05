/mob/living/basic/mushroom
	name = "walking mushroom"
	desc = "It's a massive mushroom... with legs?"
	icon_state = "mushroom_color"
	icon_living = "mushroom_color"
	icon_dead = "mushroom_dead"
	mob_biotypes = MOB_ORGANIC | MOB_PLANT
	butcher_results = list(/obj/item/food/hugemushroomslice = 1)

	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "whacks"
	response_harm_simple = "whack"

	speed = 1
	attack_verb_continuous = "chomps"
	attack_verb_simple = "chomp"
	attack_sound = 'sound/weapons/bite.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE

	faction = list(FACTION_MUSHROOM)
	speak_emote = list("squeakes")
	death_message = "fainted!"

	ai_controller = /datum/ai_controller/basic_controller/mushroom
	var/cap_color = "#ffffff"
	///Tracks our general strength level gained from eating other shrooms
	var/powerlevel = 0
	///If someone tries to cheat the system by attacking a shroom to lower its health, punish them so that it won't award levels to shrooms that eat it
	var/bruised = FALSE
	///If we hit three, another mushroom's gonna eat us
	var/faint_ticker = 0
	///Where we store our cap icons so we dont generate them constantly to update our icon
	var/static/mutable_appearance/cap_living
	///Where we store our cap icons so we dont generate them constantly to update our icon
	var/static/mutable_appearance/cap_dead
	///So you can't repeatedly revive it during a fight
	COOLDOWN_DECLARE(recovery_cooldown)

/mob/living/basic/mushroom/Initialize(mapload)
	melee_damage_lower = rand(4, 6)
	melee_damage_upper = rand(11,21)
	maxHealth = rand(50,70)
	cap_living = cap_living || mutable_appearance(icon, "mushroom_cap")
	cap_dead = cap_dead || mutable_appearance(icon, "mushroom_cap_dead")
	cap_color = rgb(rand(0, 255), rand(0, 255), rand(0, 255))
	UpdateMushroomCap()
	health = maxHealth
	. = ..()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_WALKING_MUSHROOM, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)

/datum/ai_controller/basic_controller/mushroom
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic/mushroom(),
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/mushroom,
		/datum/ai_planning_subtree/find_and_hunt_target/mushroom_food,
	)


/datum/targetting_datum/basic/mushroom
	stat_attack = DEAD

///we only attacked another mushrooms
/datum/targetting_datum/basic/mushroom/faction_check(mob/living/living_mob, mob/living/the_target)
	return !living_mob.faction_check_mob(the_target, exact_match = check_factions_exactly)


/datum/ai_planning_subtree/basic_melee_attack_subtree/mushroom
	melee_attack_behavior = /datum/ai_behavior/basic_melee_attack/mushroom

/datum/ai_behavior/basic_melee_attack/mushroom
	action_cooldown = 2 SECONDS

/datum/ai_planning_subtree/find_and_hunt_target/mushroom_food
	target_key = BB_LOW_PRIORITY_HUNTING_TARGET
	hunting_behavior = /datum/ai_behavior/hunt_target/unarmed_attack_target/mushroom_food
	hunt_targets = list(/obj/item/food/grown/mushroom)
	hunt_range = 6


/datum/ai_behavior/hunt_target/unarmed_attack_target/mushroom_food
	hunt_cooldown = 15 SECONDS
	always_reset_target = TRUE

/mob/living/basic/mushroom/UnarmedAttack(atom/attack_target, proximity_flag, list/modifiers)
	. = ..()
	if(!.)
		return

	if(!proximity_flag)
		return

	if(istype(attack_target, /obj/item/food/grown/mushroom))
		recover(attack_target)
		return TRUE

/mob/living/basic/mushroom/melee_attack(atom/target, list/modifiers)
	. = ..()

	if(!.)
		return

	if(!istype(target, /mob/living/basic/mushroom))
		return
	var/mob/living/basic/mushroom/victim = target
	if(victim.stat != DEAD)
		return
	if(victim.faint_ticker < 2)
		victim.faint_ticker++
		src.visible_message(span_notice("[src] chews a bit on [victim]."))
		return

	consume_mushroom(victim)

/mob/living/basic/mushroom/proc/consume_mushroom(mob/living/basic/mushroom/consumed)
	src.visible_message(span_warning("[src] devours [consumed]!"))
	var/level_gain = (consumed.powerlevel - powerlevel)
	if(level_gain >= 0 && !ckey && !consumed.bruised)//Player shrooms can't level up to become robust gods.
		consumed.LevelUp(level_gain)
	adjustBruteLoss(-consumed.maxHealth)
	qdel(consumed)

/mob/living/basic/mushroom/revive(full_heal_flags = NONE, excess_healing = 0, force_grab_ghost = FALSE)
	. = ..()
	if(!.)
		return

	icon_state = "mushroom_color"
	UpdateMushroomCap()

/mob/living/basic/mushroom/death(gibbed)
	. = ..()
	UpdateMushroomCap()

/mob/living/basic/mushroom/proc/UpdateMushroomCap()
	cut_overlays()
	cap_living.color = cap_color
	cap_dead.color = cap_color
	if(health == 0)
		add_overlay(cap_dead)
	else
		add_overlay(cap_living)

/mob/living/basic/mushroom/proc/recover(obj/item/mush_meal)
	visible_message(span_notice("[src] eats [mush_meal]!"))
	UpdateMushroomCap()
	qdel(mush_meal)
	if(!COOLDOWN_FINISHED(src, recovery_cooldown))
		return
	faint_ticker = 0
	if(stat == DEAD)
		revive(HEAL_ALL)
	else
		adjustBruteLoss(-5)
	COOLDOWN_START(src, recovery_cooldown, 300 SECONDS)

/mob/living/basic/mushroom/proc/LevelUp(level_gain)
	adjustBruteLoss(-maxHealth) //They'll always heal, even if they don't gain a level
	if(powerlevel > 9)
		return
	if(level_gain == 0)
		level_gain = 1
	powerlevel += level_gain
	if(prob(25))
		melee_damage_lower += (level_gain * rand(1,5))
	else
		melee_damage_upper += (level_gain * rand(1,5))
	maxHealth += (level_gain * rand(1,5))

/mob/living/basic/mushroom/attackby(obj/item/mush, mob/living/carbon/human/user, list/modifiers)
	if(istype(mush, /obj/item/food/grown/mushroom))
		recover(mush)
		return
	if(mush.force || user.combat_mode)
		bruised = TRUE
	return ..()
