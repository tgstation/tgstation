//An ore-devouring but easily scared creature
/mob/living/simple_animal/hostile/asteroid/goldgrub
	name = "goldgrub"

/mob/living/basic/mining/goldgrub
	name = "goldgrub"
	desc = "A worm that grows fat from eating everything in its sight. Seems to enjoy precious metals and other shiny things, hence the name."
	icon = 'icons/mob/simple/lavaland/lavaland_monsters_wide.dmi'
	icon_state = "goldgrub"
	icon_living = "goldgrub"
	icon_dead = "goldgrub_dead"
	icon_gib = "syndicate_gib"
	pixel_x = -12
	base_pixel_x = -12
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	friendly_verb_continuous = "harmlessly rolls into"
	friendly_verb_simple = "harmlessly roll into"
	maxHealth = 45
	health = 45
	melee_damage_lower = 0
	melee_damage_upper = 0
	attack_verb_continuous = "barrels into"
	attack_verb_simple = "barrel into"
	attack_sound = 'sound/weapons/punch1.ogg'
	combat_mode = FALSE
	speak_emote = list("screeches")
	death_message = "stops moving as green liquid oozes from the carcass!"
	status_flags = CANPUSH
	gold_core_spawnable = HOSTILE_SPAWN
	ai_controller = /datum/ai_controller/basic_controller/goldgrub
	//pet commands when we tame the grub
	var/list/pet_commands = list(
		/datum/pet_command/idle,
		/datum/pet_command/free,
		///datum/pet_command/grub_spit,
		/datum/pet_command/follow,
		/datum/pet_command/point_targetting/fetch
	)

/datum/ai_controller/basic_controller/goldgrub
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic,
		BB_PET_TARGETTING_DATUM = new /datum/targetting_datum/not_friends,
		BB_BASIC_MOB_FLEEING = TRUE,
		BB_STORM_APPROACHING = FALSE,
		BB_CURRENTLY_UNDERGROUND = FALSE,
		BB_MINERAL_FILL = 0,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk/less_walking
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/pet_planning,
		/datum/ai_planning_subtree/targeted_mob_ability/burrow,
		/datum/ai_planning_subtree/grub_mine,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/random_speech/tree,
	)

//only use this if a storm is coming or if humans are around
/datum/ai_planning_subtree/targeted_mob_ability/burrow
	ability_key = BB_BURROW_ABILITY

/datum/ai_behavior/use_mob_ability/burrow

/datum/ai_behavior/use_mob_ability/burrow/finish_action(datum/ai_controller/controller, success, target_key)
	. = ..()
	if(!success)
		return
	var/underground_check = controller.blackboard[BB_CURRENTLY_UNDERGROUND]
	controller.set_blackboard_key(BB_CURRENTLY_UNDERGROUND, !underground_check)



/datum/ai_planning_subtree/grub_mine

/datum/ai_planning_subtree/grub_mine/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/grub_fill = controller.blackboard[BB_MINERAL_FILL]

	///i already ate too much minerals, im full!
	if(grub_fill > MAX_GRUB_FILL)
		return

	var/turf/target_wall = controller.blackboard[BB_TARGET_MINERAL_WALL]

	if(QDELETED(target_wall))
		controller.queue_behavior(/datum/ai_behavior/find_mineral_wall, BB_TARGET_MINERAL_WALL)
		return

	controller.queue_behavior(/datum/ai_behavior/mine_wall, BB_TARGET_MINERAL_WALL)
	return SUBTREE_RETURN_FINISH_PLANNING


/datum/ai_behavior/find_mineral_wall

/datum/ai_behavior/find_mineral_wall/perform(seconds_per_tick, datum/ai_controller/controller, found_wall_key)
	. = ..()

	var/mob/living_pawn = controller.pawn

	for(var/turf/closed/potential_wall in oview(9, living_pawn))
		if(!istype(potential_wall, /turf/closed/mineral))
			continue
		if(!check_if_mineable(living_pawn, potential_wall)) //check if its surrounded by walls
			continue
		controller.set_blackboard_key(found_wall_key, potential_wall) //closest wall first!
		finish_action(controller, TRUE)
		return

/datum/ai_behavior/find_mineral_wall/proc/check_if_mineable(mob/living/source, var/turf/target_wall)
	for(var/direction in GLOB.cardinals)
		var/turf/test_turf = get_step(target_wall, direction)
		if(!test_turf.is_blocked_turf(ignore_atoms = list(source)))
			return TRUE
	return FALSE

/datum/ai_behavior/mine_wall
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_REQUIRE_REACH | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/ai_behavior/mine_wall/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/turf/target = controller.blackboard[target_key]
	if(isnull(target))
		return FALSE
	set_movement_target(controller, target)

/datum/ai_behavior/mine_wall/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	. = ..()
	var/mob/living/basic/living_pawn = controller.pawn
	var/turf/closed/mineral/target = controller.blackboard[target_key]
	var/is_gibtonite_turf = istype(target, /turf/closed/mineral/gibtonite)
	if(QDELETED(target))
		finish_action(controller, FALSE, target_key)
		return
	living_pawn.melee_attack(target)
	if(is_gibtonite_turf)
		living_pawn.manual_emote("sighs...") //we are about to explode, accept our fate

	finish_action(controller, TRUE, target_key)
	return

/datum/ai_behavior/mine_wall/finish_action(datum/ai_controller/controller, success, target_key)
	. = ..()
	controller.clear_blackboard_key(target_key)

/mob/living/basic/mining/goldgrub/Initialize(mapload)
	. = ..()
	generate_loot()
	var/datum/action/cooldown/mob_cooldown/spit_ore/spit = new(src)
	var/datum/action/cooldown/mob_cooldown/burrow/burrow = new(src)
	AddElement(/datum/element/appearance_on_aggro, overlay_icon = icon, overlay_state = "[icon_state]_alert")
	AddElement(/datum/element/wall_smasher)
	AddComponent(/datum/component/tameable, food_types = list(/obj/item/stack/ore), tame_chance = 25, bonus_tame_chance = 5, after_tame = CALLBACK(src, PROC_REF(tame_grub)))
	AddElement(/datum/element/ai_listen_to_weather)
	spit.Grant(src)
	burrow.Grant(src)
	ai_controller.set_blackboard_key(BB_SPIT_ABILITY, spit)
	ai_controller.set_blackboard_key(BB_BURROW_ABILITY, burrow)

/mob/living/basic/mining/goldgrub/UnarmedAttack(atom/attack_target, proximity_flag, list/modifiers)
	. = ..()
	if(!.)
		return

	if(!proximity_flag)
		return

	if(istype(attack_target, /obj/item/stack/ore))
		var/obj/ore_target = attack_target
		ore_target.forceMove(src)
		return

/mob/living/basic/mining/goldgrub/bullet_act(obj/projectile/bullet)
	if(stat == DEAD)
		return BULLET_ACT_FORCE_PIERCE
	else
		visible_message(span_danger("The [bullet.name] is repelled by [src]'s girth!"))
		return BULLET_ACT_BLOCK

/mob/living/basic/mining/goldgrub/proc/barf_contents()
	visible_message(span_danger("[src] spits out its consumed ores!"))
	playsound(src, 'sound/effects/splat.ogg', 50, TRUE)
	for(var/obj/item/ore in src)
		ore.forceMove(loc)

/mob/living/basic/mining/goldgrub/proc/generate_loot()
	var/loot_amount = rand(1,3)
	var/list/weight_lootdrops = list(
		/obj/item/stack/ore/silver = 4,
		/obj/item/stack/ore/gold = 3,
		/obj/item/stack/ore/uranium = 3,
		/obj/item/stack/ore/diamond = 1,
	)
	var/list/death_loot = list()
	for(var/i in 1 to loot_amount)
		death_loot += pick_weight(weight_lootdrops)
	AddElement(/datum/element/death_drops, death_loot)

/mob/living/basic/mining/goldgrub/death(gibbed)
	barf_contents()
	return ..()

/mob/living/basic/mining/goldgrub/proc/tame_grub()
	AddElement(/datum/element/ridable, /datum/component/riding/creature/goldgrub)
	AddComponent(/datum/component/obeys_commands, pet_commands)


/datum/action/cooldown/mob_cooldown/spit_ore
	name = "Spit Ore"
	desc = "Vomit out all of your consumed ores."
	cooldown_time = 5 SECONDS

/datum/action/cooldown/mob_cooldown/spit_ore/Activate()
	if(owner.stat == DEAD)
		return
	var/mob/living/basic/mining/goldgrub/grub_owner = owner
	grub_owner.barf_contents()

/datum/action/cooldown/mob_cooldown/burrow
	name = "Burrow"
	desc = "Burrow under soft ground, evading predators and increasing your speed."
	cooldown_time = 5 SECONDS
	click_to_activate = FALSE
	/// are we currently burrowed
	var/burrowed = FALSE

/datum/action/cooldown/mob_cooldown/burrow/IsAvailable(feedback)
	. = ..()
	if (!.)
		return FALSE
	var/turf/location = get_turf(owner)
	if(!isasteroidturf(location))
		to_chat(owner, span_warning("You can only burrow in and out of mining turfs!"))
		return FALSE
	return TRUE

/datum/action/cooldown/mob_cooldown/burrow/Activate()
	var/obj/effect/dummy/phased_mob/holder = null
	var/turf/current_loc = get_turf(owner)
	if(!do_after(owner, 3 SECONDS, target = current_loc))
		to_chat(owner, span_warning("You must stay still!"))
		return
	if(get_turf(owner) != current_loc)
		to_chat(owner, span_warning("Action cancelled, as you moved while reappearing."))
		return
	if(!burrowed)
		owner.visible_message(span_danger("[owner] buries into the ground, vanishing from sight!"))
		playsound(get_turf(owner), 'sound/effects/break_stone.ogg', 50, TRUE, -1)
		holder = new /obj/effect/dummy/phased_mob(current_loc, owner)
		burrowed = TRUE
		return
	holder = owner.loc
	holder.eject_jaunter()
	holder = null
	burrowed = FALSE
	owner.visible_message(span_danger("[owner] emerges from the ground!"))
	playsound(get_turf(owner), 'sound/effects/break_stone.ogg', 50, TRUE, -1)
