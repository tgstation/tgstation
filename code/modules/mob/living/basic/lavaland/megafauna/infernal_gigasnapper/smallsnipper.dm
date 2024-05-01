///crab minions! how crustaceous of you 😊. they only move on the y-axis, and drop nothing when killed.
/// not a /mining subtype because i have to choose between crab and mining, that's OK though.
/// while I have to readd things like weather immunity
/mob/living/basic/crab/smallsnipper
	name = "infernal smallsnipper"
	desc = "A smallsnipper, the smaller and thinner ancestor of the gigasnapper. The subservience to the larger species is a fascinating and dramatic case of symbiotic relationships in nature."
	death_message = "retreats underground!"

	icon = 'icons/mob/simple/lavaland/gigasnapper/32x32.dmi'
	icon_state = "smallsnipper"

	health = 50
	maxHealth = 50
	//not a boss but part of a boss fight so please dont. they fully work with player possession for admins
	sentience_type = SENTIENCE_BOSS
	faction = list(FACTION_MINING, FACTION_GIGASNAPPER)
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = 0
	maximum_survivable_temperature = INFINITY
	basic_mob_flags = DEL_ON_DEATH
	ai_controller = /datum/ai_controller/basic_controller/smallsnipper

/mob/living/basic/crab/smallsnipper/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/dir_restricted_movement, (NORTH | SOUTH))
	add_traits(list(TRAIT_LAVA_IMMUNE, TRAIT_ASHSTORM_IMMUNE, TRAIT_SNOWSTORM_IMMUNE), INNATE_TRAIT)

	var/static/list/innate_actions = list(
		/datum/action/cooldown/mob_cooldown/projectile_attack/smallsnipper_bubble = BB_SMALLSNIPPER_BUBBLE,
	)
	grant_actions_by_list(innate_actions)

/datum/ai_controller/basic_controller/smallsnipper
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/smallsnipper_attack,
	)

/datum/ai_planning_subtree/smallsnipper_attack

/datum/ai_planning_subtree/smallsnipper_attack/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if (!controller.blackboard_key_exists(BB_BASIC_MOB_CURRENT_TARGET))
		return

	//always move towards target to try lining up an attack, restricted movement will naturally keep movement vertical
	controller.queue_behavior(/datum/ai_behavior/travel_towards, BB_BASIC_MOB_CURRENT_TARGET)

	var/datum/action/cooldown/mob_cooldown/projectile_attack/smallsnipper_bubble/bubble = controller.blackboard[BB_SMALLSNIPPER_BUBBLE]

	//always try to do this attack if off cooldown, just always be spamming that to pollute the arena with projectiles
	if(bubble?.IsAvailable())
		controller.queue_behavior(/datum/ai_behavior/targeted_mob_ability/and_plan_execute, BB_SMALLSNIPPER_BUBBLE, BB_BASIC_MOB_CURRENT_TARGET)
		return SUBTREE_RETURN_FINISH_PLANNING

/datum/action/cooldown/mob_cooldown/projectile_attack/smallsnipper_bubble
	name = "Blow Bubble"
	desc = "Blow a slow moving bubble to your left or right. Empowered if hovering over a special tile."
	projectile_type = /obj/projectile/smallsnipper_bubble

/datum/action/cooldown/mob_cooldown/projectile_attack/smallsnipper_bubble/Activate(atom/target)
	if(!isliving(target))
		owner.balloon_alert(owner, "needs living target!")
		return
	if(target == owner)
		owner.balloon_alert(owner, "not yourself!")
		return
	var/direction = target.x < owner.x ? WEST \
		: target.x == owner.x ? NONE : EAST
	if(!direction)
		owner.balloon_alert(owner, "out of in attack angle!")
		return
	shoot_projectile(owner, target, dir2angle(direction), owner)
	StartCooldown()

/obj/projectile/smallsnipper_bubble
	name = "bubble"
	icon_state = "gumball"
	color = "#03c6fc"
	hitsound = 'sound/effects/splat.ogg'
	ignored_factions = list(FACTION_GIGASNAPPER)
	damage = 10
	speed = 10
	range = 20
	jitter = 3 SECONDS
	stutter = 3 SECONDS
	damage_type = BRUTE
	pass_flags = PASSTABLE

/obj/effect/temp_visual/telegraphing/create_type/smallsnipper
	icon = 'icons/mob/telegraphing/telegraph.dmi'
	icon_state = "crab_summon"
	duration = 2 SECONDS

	created_type = /mob/living/basic/crab/smallsnipper
	creation_message = span_warning("%TYPE unburrows!")
