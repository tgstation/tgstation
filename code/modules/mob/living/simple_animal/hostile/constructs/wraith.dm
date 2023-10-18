/mob/living/simple_animal/hostile/construct/wraith
	name = "Wraith"
	real_name = "Wraith"
	desc = "A wicked, clawed shell constructed to assassinate enemies and sow chaos behind enemy lines."
	icon_state = "wraith"
	icon_living = "wraith"
	maxHealth = 65
	health = 65
	melee_damage_lower = 20
	melee_damage_upper = 20
	retreat_distance = 2 //AI wraiths will move in and out of combat
	attack_verb_continuous = "slashes"
	attack_verb_simple = "slash"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	attack_vis_effect = ATTACK_EFFECT_SLASH
	construct_spells = list(
		/datum/action/cooldown/spell/jaunt/ethereal_jaunt/shift,
		/datum/action/innate/cult/create_rune/tele,
	)
	playstyle_string = "<b>You are a Wraith. Though relatively fragile, you are fast, deadly, \
		can phase through walls, and your attacks will lower the cooldown on phasing.</b>"

	// Accomplishing various things gives you a refund on jaunt, to jump in and out.
	/// The seconds refunded per attack
	var/attack_refund = 1 SECONDS
	/// The seconds refunded when putting a target into critical
	var/crit_refund = 5 SECONDS

/mob/living/simple_animal/hostile/construct/wraith/AttackingTarget(atom/attacked_target) //refund jaunt cooldown when attacking living targets
	var/prev_stat
	var/mob/living/living_target = target

	if(isliving(living_target) && !IS_CULTIST(living_target))
		prev_stat = living_target.stat

	. = ..()
	if(!. || !isnum(prev_stat))
		return

	var/datum/action/cooldown/spell/jaunt/ethereal_jaunt/shift/jaunt = locate() in actions
	if(!jaunt)
		return

	var/total_refund = 0 SECONDS
	// they're dead, and you killed them - full refund
	if(QDELETED(living_target) || (living_target.stat == DEAD && prev_stat != DEAD))
		total_refund += jaunt.cooldown_time
	// you knocked them into critical
	else if(HAS_TRAIT(living_target, TRAIT_CRITICAL_CONDITION) && prev_stat == CONSCIOUS)
		total_refund += crit_refund

	if(living_target.stat != DEAD && prev_stat != DEAD)
		total_refund += attack_refund

	jaunt.next_use_time -= total_refund
	jaunt.build_all_button_icons()

/mob/living/simple_animal/hostile/construct/wraith/hostile //actually hostile, will move around, hit things
	AIStatus = AI_ON

//////////////////////////Wraith-alts////////////////////////////
/mob/living/simple_animal/hostile/construct/wraith/angelic
	theme = THEME_HOLY
	construct_spells = list(
		/datum/action/cooldown/spell/jaunt/ethereal_jaunt/shift/angelic,
		/datum/action/innate/cult/create_rune/tele,
	)
	loot = list(/obj/item/ectoplasm/angelic)

/mob/living/simple_animal/hostile/construct/wraith/angelic/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_ANGELIC, INNATE_TRAIT)

/mob/living/simple_animal/hostile/construct/wraith/mystic
	theme = THEME_WIZARD
	construct_spells = list(
		/datum/action/cooldown/spell/jaunt/ethereal_jaunt/shift/mystic,
		/datum/action/innate/cult/create_rune/tele,
	)
	loot = list(/obj/item/ectoplasm/mystic)

/mob/living/simple_animal/hostile/construct/wraith/noncult
