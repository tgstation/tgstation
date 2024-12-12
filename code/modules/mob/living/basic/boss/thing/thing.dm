/mob/living/basic/boss/thing
	name = "\improper Thing"
	icon = 'icons/obj/mafia.dmi'
	icon_state = "changeling"
	maxHealth = 1800 //nicely divisible by three
	health = 1800
	armour_penetration = 40
	melee_damage_lower = 30
	melee_damage_upper = 30
	sharpness = SHARP_EDGED
	melee_attack_cooldown = CLICK_CD_MELEE
	attack_verb_continuous = "eviscerates"
	attack_verb_simple = "eviscerate"
	attack_sound = 'sound/items/weapons/bladeslice.ogg'
	attack_vis_effect = ATTACK_EFFECT_SLASH
	var/phase = 1
	var/phase_invul_time = 10 SECONDS
	var/phase_invulnerability_timer
	var/ruin_spawned = TRUE

/mob/living/basic/boss/thing/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/wall_tearer)
	var/static/list/innate_actions = list(
		/datum/action/cooldown/mob_cooldown/the_thing/decimate = BB_VIBEBOT_PARTY_ABILITY,
		/datum/action/cooldown/mob_cooldown/charge/the_thing = "sigma",
		/datum/action/cooldown/mob_cooldown/the_thing/big_tendrils = "balls",
	)
	grant_actions_by_list(innate_actions)

/mob/living/basic/boss/thing/adjust_health(amount, updating_health = TRUE, forced = FALSE)
	if(!ruin_spawned || phase_invulnerability_timer || phase == 3 || stat || amount <= 0)
		return ..()
	var/potential_excess = bruteloss + amount - (maxHealth/3)*phase
	if(potential_excess > 0)
		amount -= potential_excess
	. = ..()
	if(bruteloss >= (maxHealth/3)*phase)
		phase_health_depleted()

/mob/living/basic/boss/thing/proc/phase_health_depleted()
	if(phase_invulnerability_timer)
		return //wtf?
	if(!ruin_spawned)
		phase_successfully_depleted()
		return
	ADD_TRAIT(src, TRAIT_GODMODE, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_IMMOBILIZED, TRAIT_GENERIC)
	update_appearance()
	balloon_alert_to_viewers("weakened! use the cannons!")
	visible_message(span_danger("[src] drops to the ground staggered, unable to keep up with injuries!"))
	phase_invulnerability_timer = addtimer(CALLBACK(src, PROC_REF(phase_too_slow)), phase_invul_time, TIMER_STOPPABLE|TIMER_UNIQUE)

/// The Thing is successfully hit by incendiary fire while downed by damage (alternatively takes too much damage if not ruin spawned)
/mob/living/basic/boss/thing/proc/phase_successfully_depleted()
	REMOVE_TRAIT(src, TRAIT_GODMODE, TRAIT_GENERIC)
	REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, TRAIT_GENERIC)
	deltimer(phase_invulnerability_timer)
	phase_invulnerability_timer = null
	if(phase < 3) //after phase 3 we literally just die
		phase++
		emote("scream")

/mob/living/basic/boss/thing/proc/phase_too_slow()
	phase_invulnerability_timer = null
	REMOVE_TRAIT(src, TRAIT_GODMODE, TRAIT_GENERIC)
	REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, TRAIT_GENERIC)
	balloon_alert_to_viewers("recovers!")
	visible_message(span_danger("[src] recovers from the damage! Too slow!"))
	adjust_health(-(maxHealth/3) * 0.5) //half of a phase (which is a third of maxhealth)
	update_appearance()
	emote("roar")
