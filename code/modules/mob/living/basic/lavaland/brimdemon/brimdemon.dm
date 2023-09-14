/// Lavaland mob which tries to line up with its target and fire a laser
/mob/living/basic/mining/brimdemon
	name = "brimdemon"
	desc = "An unstable creature resembling an enormous horned skull. Its response to almost any stimulus is to unleash a beam of infernal energy."
	icon = 'icons/mob/simple/lavaland/lavaland_monsters.dmi'
	icon_state = "brimdemon"
	icon_living = "brimdemon"
	icon_dead = "brimdemon_dead"
	speed = 5
	maxHealth = 250
	health = 250
	friendly_verb_continuous = "scratches at"
	friendly_verb_simple = "scratch at"
	speak_emote = list("cackles")
	melee_damage_lower = 7.5
	melee_damage_upper = 7.5
	attack_sound = 'sound/weapons/bite.ogg'
	melee_attack_cooldown = 14 SECONDS
	attack_vis_effect = ATTACK_EFFECT_BITE
	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"
	light_color = LIGHT_COLOR_BLOOD_MAGIC
	light_power = 5
	light_range = 1.4

	ai_controller = /datum/ai_controller/basic_controller

	crusher_loot = /obj/item/crusher_trophy/brimdemon_fang
	butcher_results = list(
		/obj/item/food/meat/slab = 2,
		/obj/effect/decal/cleanable/brimdust = 1,
		/obj/item/organ/internal/monster_core/brimdust_sac = 1,
	)
	/// How we get blasting
	var/datum/action/cooldown/mob_cooldown/brimbeam/beam

/mob/living/basic/mining/brimdemon/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/footstep, FOOTSTEP_MOB_CLAW)
	beam = new(src)
	beam.Grant(src)

/mob/living/basic/mining/brimdemon/Destroy()
	QDEL_NULL(beam)
	return ..()

/mob/living/basic/mining/brimdemon/RangedAttack(atom/target, modifiers)
	beam.Trigger(target = target)
