/// Lavaland mob which tries to line up with its target and fire a laser
/mob/living/basic/mining/brimdemon
	name = "brimdemon"
	desc = "A volatile creature resembling an enormous horned skull. Its response to almost any stimulus is to unleash a beam of infernal energy."
	icon = 'icons/mob/simple/lavaland/lavaland_monsters.dmi'
	icon_state = "brimdemon"
	icon_living = "brimdemon"
	icon_dead = "brimdemon_dead"
	speed = 3
	maxHealth = 250
	health = 250
	friendly_verb_continuous = "scratches at"
	friendly_verb_simple = "scratch at"
	speak_emote = list("cackles")
	melee_damage_lower = 7.5
	melee_damage_upper = 7.5
	attack_sound = 'sound/items/weapons/bite.ogg'
	melee_attack_cooldown = 0.6 SECONDS
	attack_vis_effect = ATTACK_EFFECT_BITE
	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"
	death_message = "wails as infernal energy escapes from its wounds, leaving it an empty husk."
	death_sound = 'sound/effects/magic/demon_dies.ogg'
	light_color = LIGHT_COLOR_BLOOD_MAGIC
	light_power = 5
	light_range = 1.4

	ai_controller = /datum/ai_controller/basic_controller/brimdemon

	crusher_loot = /obj/item/crusher_trophy/brimdemon_fang
	butcher_results = list(
		/obj/item/food/meat/slab = 2,
		/obj/effect/decal/cleanable/brimdust = 1,
		/obj/item/organ/monster_core/brimdust_sac = 1,
	)
	/// How we get blasting
	var/datum/action/cooldown/mob_cooldown/brimbeam/beam

/mob/living/basic/mining/brimdemon/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/footstep, FOOTSTEP_MOB_CLAW)
	beam = new(src)
	beam.Grant(src)
	ai_controller.set_blackboard_key(BB_TARGETED_ACTION, beam)

/mob/living/basic/mining/brimdemon/RangedAttack(atom/target, modifiers)
	beam.Trigger(target = target)

/mob/living/basic/mining/brimdemon/death(gibbed)
	. = ..()
	if (gibbed)
		return
	var/obj/effect/temp_visual/brim_burst/bang = new(loc)
	forceMove(bang)

/// Show a funny animation before doing an explosion
/obj/effect/temp_visual/brim_burst
	name = "bursting brimdemon"
	icon = 'icons/mob/simple/lavaland/lavaland_monsters.dmi'
	icon_state = "brimdemon_dead"
	duration = 1.9 SECONDS

/obj/effect/temp_visual/brim_burst/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(bang)), duration - (1 DECISECONDS), TIMER_DELETE_ME)
	animate(src, color = "#ff8888", transform = matrix().Scale(1.1), time = 0.7 SECONDS)
	animate(color = "#ffffff", transform = matrix(), time = 0.2 SECONDS)
	animate(color = "#ff4444", transform = matrix().Scale(1.3), time = 0.5 SECONDS)
	animate(color = "#ffffff", transform = matrix(), time = 0.2 SECONDS)
	animate(color = "#ff0000", transform = matrix().Scale(1.5), time = 0.3 SECONDS)

/// Make an explosion
/obj/effect/temp_visual/brim_burst/proc/bang()
	var/turf/origin_turf = get_turf(src)
	playsound(origin_turf, 'sound/effects/pop_expl.ogg', 50)
	new /obj/effect/temp_visual/explosion/fast(origin_turf)
	var/list/possible_targets = range(1, origin_turf)
	for(var/mob/living/target in possible_targets)
		var/armor = target.run_armor_check(attack_flag = BOMB)
		target.apply_damage(20, damagetype = BURN, blocked = armor, spread_damage = TRUE)

	for (var/atom/movable/thing as anything in contents)
		thing.forceMove(loc)
