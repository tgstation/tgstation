/mob/living/basic/mining/deacon
	name = "deep sea deacon"
	desc = "If anyone does not love the Lord, let them be accursed at His coming... Amen!"
	icon = 'icons/mob/nonhuman-player/96x96eldritch_mobs.dmi'
	icon_state = "deep_sea_deacon"
	icon_living = "deep_sea_deacon"
	pixel_x = -32
	base_pixel_x = -32
	gender = MALE
	speed = 10
	basic_mob_flags = IMMUNE_TO_FISTS
	maxHealth = 3000
	health = 3000
	faction = list(FACTION_MINING, FACTION_BOSS)
	speak_emote = list("preaches")
	obj_damage = 100
	armour_penetration = 20
	melee_damage_lower = 40
	melee_damage_upper = 40
	sentience_type = SENTIENCE_BOSS
	attack_sound = 'sound/magic/magic_block_holy.ogg'
	attack_verb_continuous = "exorcizes"
	attack_verb_simple = "exorcize"
	throw_blocked_message = "does nothing to the tough hide of"
	move_force = MOVE_FORCE_VERY_STRONG
	move_resist = MOVE_FORCE_VERY_STRONG
	pull_force = MOVE_FORCE_VERY_STRONG
	ai_controller = /datum/ai_controller/basic_controller/deep_sea_deacon

/mob/living/basic/mining/deacon/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/simple_flying)
	AddComponent(/datum/component/ai_target_timer)
	AddComponent(/datum/component/basic_mob_attack_telegraph, telegraph_duration = 0.6 SECONDS,)
	var/static/list/other_innate_actions = list(
		/datum/action/cooldown/mob_cooldown/crystal_barrage = BB_DEACON_CRYSTAL_BARRAGE,
		/datum/action/cooldown/mob_cooldown/light_beam = BB_DEACON_LIGHTBEAM,
		/datum/action/cooldown/mob_cooldown/lightning_fissure = BB_DEACON_FISSURE,
		/datum/action/cooldown/mob_cooldown/holy_blades = BB_DEACON_BLADES,
		/datum/action/cooldown/mob_cooldown/black_n_white = BB_DEACON_BLACKNWHITE,
		/datum/action/cooldown/mob_cooldown/beam_crystal = BB_DEACON_BEAM_CRYSTAL,
		/datum/action/cooldown/mob_cooldown/healing_pylon = BB_DEACON_HEALING_PYLON,
		/datum/action/cooldown/mob_cooldown/beam_trial = BB_DEACON_ENTRAPPMENT,
		/datum/action/cooldown/mob_cooldown/domain_teleport/hell = BB_DEACON_HELL_DOMAIN,
		/datum/action/cooldown/mob_cooldown/domain_teleport/heaven = BB_DEACON_HEAVEN_DOMAIN,
		/datum/action/cooldown/mob_cooldown/bounce = BB_DEACON_BOUNCE,
	)
	grant_actions_by_list(other_innate_actions)
	var/static/list/idle_attacks = list(
		BB_DEACON_FISSURE,
		BB_DEACON_CRYSTAL_BARRAGE,
		BB_DEACON_BEAM_CRYSTAL,
	)
	var/static/list/normal_attacks = list(
		BB_DEACON_LIGHTBEAM,
		BB_DEACON_BLADES,
	)
	var/static/list/special_attacks = list(
		BB_DEACON_HEALING_PYLON,
		BB_DEACON_BLACKNWHITE,
		BB_DEACON_ENTRAPPMENT,
	)
	var/static/list/domain_attacks = list(
		BB_DEACON_HELL_DOMAIN,
		BB_DEACON_HEAVEN_DOMAIN,
	)

	var/static/list/cycle_count_reseters = list(
		/datum/action/cooldown/mob_cooldown/healing_pylon,
		/datum/action/cooldown/mob_cooldown/black_n_white,
		/datum/action/cooldown/mob_cooldown/beam_trial,
	)
	var/static/list/cycle_timers = list(
		/datum/action/cooldown/mob_cooldown/lightning_fissure = 13 SECONDS,
		/datum/action/cooldown/mob_cooldown/crystal_barrage = 18 SECONDS,
		/datum/action/cooldown/mob_cooldown/beam_crystal = 15 SECONDS,
	)

	ai_controller.set_blackboard_key(BB_DEACON_IDLE_ATTACKS, idle_attacks)
	ai_controller.set_blackboard_key(BB_DEACON_NORMAL_ATTACKS, normal_attacks)
	ai_controller.set_blackboard_key(BB_DEACON_SPECIAL_ATTACKS, special_attacks)
	ai_controller.set_blackboard_key(BB_DEACON_DOMAIN_ATTACKS, domain_attacks)
	ai_controller.set_blackboard_key(BB_DEACON_CYCLE_TIMERS, cycle_timers)
	ai_controller.set_blackboard_key(BB_DEACON_CYCLE_RESETERS, cycle_count_reseters)
