/// Scout and assassin who can appear and disappear from glass surfaces. Damaged by being examined.
/mob/living/basic/heretic_summon/maid_in_the_mirror
	name = "\improper Maid in the Mirror"
	real_name = "Maid in the Mirror"
	desc = "A floating and flowing wisp of chilled air. Glancing at it causes it to shimmer slightly."
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
		/obj/item/organ/internal/lungs,
		/obj/item/shard,
	)
	AddElement(/datum/element/death_drops, loot)
	var/datum/action/cooldown/spell/jaunt/mirror_walk/jaunt = new (src)
	jaunt.Grant(src)

/mob/living/basic/heretic_summon/maid_in_the_mirror/death(gibbed)
	var/turf/death_turf = get_turf(src)
	death_turf.TakeTemperature(-40) // Spooky
	return ..()

// Examining them will harm them, on a cooldown.
/mob/living/basic/heretic_summon/maid_in_the_mirror/examine(mob/user)
	. = ..()
	if(!harmed_by_examine || user == src || user.stat == DEAD || !isliving(user) || IS_HERETIC_OR_MONSTER(user))
		return

	var/user_ref = REF(user)
	if(user_ref in recent_examiner_refs)
		return

	// If we have health, we take some damage
	if(health > (maxHealth * 0.125))
		visible_message(
				span_warning("[src] seems to fade in and out slightly."),
				span_userdanger("[user]'s gaze pierces your every being!"),
		)

		recent_examiner_refs += user_ref
		apply_damage(maxHealth * 0.1) // We take 10% of our health as damage upon being examined
		playsound(src, 'sound/effects/ghost2.ogg', 40, TRUE)
		addtimer(CALLBACK(src, PROC_REF(clear_recent_examiner), user_ref), recent_examine_damage_cooldown, TIMER_DELETE_ME)
		animate(src, alpha = 120, time = 0.5 SECONDS, easing = ELASTIC_EASING, loop = 2, flags = ANIMATION_PARALLEL)
		animate(alpha = 255, time = 0.5 SECONDS, easing = ELASTIC_EASING)

	// If we're examined on low enough health we die straight up
	else
		visible_message(
				span_danger("[src] vanishes from existence!"),
				span_userdanger("[user]'s gaze shatters your form, destroying you!"),
		)

		death()

/mob/living/basic/heretic_summon/maid_in_the_mirror/proc/clear_recent_examiner(mob_ref)
	if(!(mob_ref in recent_examiner_refs))
		return

	recent_examiner_refs -= mob_ref
	heal_overall_damage(5)
