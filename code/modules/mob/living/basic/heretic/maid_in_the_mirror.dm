/// Scout and assassin who can appear and disappear from glass surfaces. Damaged by being examined.
/mob/living/basic/heretic_summon/maid_in_the_mirror
	name = "\improper Maid in the Mirror"
	real_name = "Maid in the Mirror"
	desc = "A floating and flowing wisp of chilled air."
	icon = 'icons/mob/simple/mob.dmi'
	icon_state = "stand"
	icon_living = "stand" // Placeholder sprite... still
	speak_emote = list("whispers")
	movement_type = FLOATING
	status_flags = CANSTUN | CANPUSH
	attack_sound = SFX_SHATTER
	maxHealth = 80
	health = 80
	melee_damage_lower = 12
	melee_damage_upper = 16
	sight = SEE_MOBS | SEE_OBJS | SEE_TURFS
	death_message = "shatters and vanishes, releasing a gust of cold air."
	/// Whether we take damage when someone looks at us
	var/harmed_by_examine = TRUE
	/// How often being examined by a specific mob can hurt us
	var/recent_examine_damage_cooldown = 10 SECONDS
	/// A list of REFs to people who recently examined us
	var/list/recent_examiner_refs = list()

/mob/living/basic/heretic_summon/maid_in_the_mirror/Initialize(mapload)
	. = ..()
	var/static/list/loot = list(
		/obj/effect/decal/cleanable/ash,
		/obj/item/clothing/suit/armor/vest,
		/obj/item/organ/lungs,
		/obj/item/shard,
	)
	AddElement(/datum/element/death_drops, loot)
	GRANT_ACTION(/datum/action/cooldown/spell/jaunt/mirror_walk)
	ADD_TRAIT(src, TRAIT_UNHITTABLE_BY_LASERS, INNATE_TRAIT)

/mob/living/basic/heretic_summon/maid_in_the_mirror/death(gibbed)
	var/turf/death_turf = get_turf(src)
	death_turf.TakeTemperature(-40) // Spooky
	return ..()

/mob/living/basic/heretic_summon/maid_in_the_mirror/melee_attack(atom/target, list/modifiers, ignore_cooldown)
	. = ..()
	if(!. || !isliving(target))
		return
	var/mob/living/living_target = target
	living_target.apply_status_effect(/datum/status_effect/void_chill, 1)
