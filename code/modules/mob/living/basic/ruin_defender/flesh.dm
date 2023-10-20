/datum/ai_controller/basic_controller/living_limb_flesh
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic/attack_until_dead,
	)

	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree
	)

/mob/living/basic/living_limb_flesh
	name = "living flesh"
	desc = "A vaguely leg or arm shaped flesh abomination. It pulses, like a heart."
	icon = 'icons/mob/simple/animal.dmi'
	icon_state = "limb"
	icon_living = "limb"
	mob_size = MOB_SIZE_SMALL
	basic_mob_flags = DEL_ON_DEATH
	faction = list(FACTION_HOSTILE)
	melee_damage_lower = 10
	melee_damage_upper = 10
	health = 20
	maxHealth = 20
	attack_sound = 'sound/weapons/bite.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE
	attack_verb_continuous = "tries desperatedly to attach to"
	attack_verb_simple = "try to attach to"
	ai_controller = /datum/ai_controller/basic_controller/living_limb_flesh

/mob/living/basic/living_limb_flesh/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/swarming, 8, 8) //max_x, max_y
	AddElement(/datum/element/death_drops, string_list(list(/obj/effect/gibspawner/generic)))

/mob/living/basic/living_limb_flesh/melee_attack(mob/living/carbon/human/target, list/modifiers, ignore_cooldown)
	. = ..()
	if (!ishuman(target) || target.stat == DEAD || HAS_TRAIT(target, TRAIT_NODISMEMBER))
		return
	
	var/list/zone_candidates = target.get_missing_limbs()
	for(var/obj/item/bodypart/bodypart in target.bodyparts)
		if(bodypart.body_zone == BODY_ZONE_HEAD || bodypart.body_zone == BODY_ZONE_CHEST)
			continue
		if(HAS_TRAIT(bodypart, TRAIT_IGNORED_BY_LIVING_FLESH))
			continue
		if(bodypart.bodypart_flags & BODYPART_UNREMOVABLE)
			continue
		if(bodypart.brute_dam < 20)
			continue
		zone_candidates += bodypart.body_zone
	
	if(!length(zone_candidates))
		return
	
	var/target_zone = pick(zone_candidates)
	var/obj/item/bodypart/target_part = target.get_bodypart(target_zone)
	if(target_part)
		target_part.dismember()
	var/part_type
	switch(target_zone)
		if(BODY_ZONE_L_ARM)
			part_type = /obj/item/bodypart/arm/left/flesh
		if(BODY_ZONE_R_ARM)
			part_type = /obj/item/bodypart/arm/right/flesh
		if(BODY_ZONE_L_LEG)
			part_type = /obj/item/bodypart/leg/left/flesh
		if(BODY_ZONE_R_LEG)
			part_type = /obj/item/bodypart/leg/right/flesh
	
	target.visible_message(span_danger("[src] [target_part ? "attaches itself" : "tears off and attaches itself"] to where [target]s limb used to be!"))
	var/obj/item/bodypart/new_part = new part_type()
	ADD_TRAIT(new_part, TRAIT_IGNORED_BY_LIVING_FLESH, BODYPART_TRAIT)
	new_part.replace_limb(target, TRUE)
	forceMove(new_part)
	ai_controller.set_ai_status(AI_STATUS_OFF) //todo some sideeffect to these limbs?
	RegisterSignal(new_part, COMSIG_BODYPART_REMOVED, PROC_REF(on_limb_lost))

/mob/living/basic/living_limb_flesh/proc/on_limb_lost(atom/movable/source, mob/living/carbon/old_owner, dismembered)
	SIGNAL_HANDLER
	to_chat(world, "[old_owner], [source]")
	forceMove(old_owner.drop_location())
	qdel(source)
	addtimer(CALLBACK(src, PROC_REF(wake_up)), 2 SECONDS)

/mob/living/basic/living_limb_flesh/proc/wake_up()
	ai_controller.set_ai_status(AI_STATUS_ON)
	visible_message(span_warning("[src] begins flailing around!"))
	Shake(6, 6, 0.5 SECONDS)
