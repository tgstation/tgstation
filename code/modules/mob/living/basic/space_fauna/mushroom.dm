/mob/living/basic/mushroom
	name = "walking mushroom"
	desc = "It's a massive mushroom... with legs?"
	icon_state = "mushroom_color"
	icon_living = "mushroom_color"
	icon_dead = "mushroom_dead"
	mob_biotypes = MOB_ORGANIC | MOB_PLANT

	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "whacks"
	response_harm_simple = "whack"

	speed = 1
	melee_damage_lower = 4
	melee_damage_upper = 4
	maxHealth = 60
	attack_verb_continuous = "chomps"
	attack_verb_simple = "chomp"
	attack_sound = 'sound/items/weapons/bite.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE

	faction = list(FACTION_MUSHROOM)
	speak_emote = list("squeaks")
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
	///Cooldown that tracks how long its been since revival
	COOLDOWN_DECLARE(recovery_cooldown)

/mob/living/basic/mushroom/Initialize(mapload)
	. = ..()
	melee_damage_lower = rand(3, 5)
	melee_damage_upper = rand(10,20)
	maxHealth = rand(50,70)
	cap_living = cap_living || mutable_appearance(icon, "mushroom_cap")
	cap_dead = cap_dead || mutable_appearance(icon, "mushroom_cap_dead")
	cap_color = rgb(rand(0, 255), rand(0, 255), rand(0, 255))
	update_mushroomcap()
	health = maxHealth
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_WALKING_MUSHROOM, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)
	RegisterSignal(src, COMSIG_HOSTILE_POST_ATTACKINGTARGET, PROC_REF(on_attacked_target))

/datum/ai_controller/basic_controller/mushroom
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/mushroom,
		BB_TARGET_MINIMUM_STAT = DEAD,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/find_and_hunt_target/mushroom_food,
	)


/datum/targeting_strategy/basic/mushroom

///we only attacked another mushrooms
/datum/targeting_strategy/basic/mushroom/faction_check(datum/ai_controller/controller, mob/living/living_mob, mob/living/the_target)
	return !living_mob.faction_check_atom(the_target, exact_match = check_factions_exactly)

/datum/ai_planning_subtree/find_and_hunt_target/mushroom_food
	target_key = BB_LOW_PRIORITY_HUNTING_TARGET
	hunting_behavior = /datum/ai_behavior/hunt_target/interact_with_target/reset_target
	hunt_targets = list(/obj/item/food/grown/mushroom)
	hunt_range = 6

/mob/living/basic/mushroom/UnarmedAttack(atom/attack_target, proximity_flag, list/modifiers)
	. = ..()
	if(!.)
		return

	if(!proximity_flag)
		return

	if(istype(attack_target, /obj/item/food/grown/mushroom))
		recover(attack_target)
		return TRUE

/mob/living/basic/mushroom/proc/on_attacked_target(mob/living/basic/attacker, atom/target)
	SIGNAL_HANDLER

	if(!istype(target, /mob/living/basic/mushroom))
		return
	var/mob/living/basic/mushroom/victim = target
	if(victim.stat != DEAD)
		return
	if(victim.faint_ticker >= 3)
		consume_mushroom(victim)
		return

	victim.faint_ticker++
	visible_message(span_notice("[src] chews a bit on [victim]."))

/mob/living/basic/mushroom/proc/consume_mushroom(mob/living/basic/mushroom/consumed)
	visible_message(span_warning("[src] devours [consumed]!"))
	var/level_gain = (consumed.powerlevel - powerlevel)
	if(level_gain >= 0 && !ckey && !consumed.bruised)//Player shrooms can't level up to become robust gods.
		consumed.level_up(level_gain)
	adjustBruteLoss(-consumed.maxHealth)
	qdel(consumed)

/mob/living/basic/mushroom/revive(full_heal_flags = NONE, excess_healing = 0, force_grab_ghost = FALSE)
	. = ..()
	if(!.)
		return

	icon_state = "mushroom_color"
	update_mushroomcap()

/mob/living/basic/mushroom/death(gibbed)
	. = ..()
	update_mushroomcap()

/mob/living/basic/mushroom/proc/update_mushroomcap()
	cut_overlays()
	cap_living.color = cap_color
	cap_dead.color = cap_color
	if(stat == DEAD)
		add_overlay(cap_dead)
	else
		add_overlay(cap_living)

/mob/living/basic/mushroom/proc/recover(obj/item/mush_meal)
	visible_message(span_notice("[src] eats [mush_meal]!"))
	update_mushroomcap()
	qdel(mush_meal)
	if(!COOLDOWN_FINISHED(src, recovery_cooldown))
		return
	faint_ticker = 0
	if(stat == DEAD)
		revive(HEAL_ALL)
	else
		adjustBruteLoss(-5)
	COOLDOWN_START(src, recovery_cooldown, 5 MINUTES)

/mob/living/basic/mushroom/proc/level_up(level_gain)
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

/mob/living/basic/mushroom/harvest(mob/living/user)
	var/counter
	for(counter=0, counter <= powerlevel, counter++)
		var/obj/item/food/hugemushroomslice/shroomslice = new /obj/item/food/hugemushroomslice(src.loc)
		shroomslice.reagents.add_reagent(/datum/reagent/drug/mushroomhallucinogen, powerlevel)
		shroomslice.reagents.add_reagent(/datum/reagent/medicine/omnizine, powerlevel)
		shroomslice.reagents.add_reagent(/datum/reagent/medicine/synaptizine, powerlevel)
