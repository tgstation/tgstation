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
	light_range = 6
	light_color = COLOR_PINK
	basic_mob_flags = IMMUNE_TO_FISTS
	maxHealth = 3500 //big health cause our attack window is gonna be always open
	health = 3500
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
	///how many bounties are completed
	var/bounty_counter = 0
	///how many bounties need to be completed for us to be active
	var/bounty_threshold = 3

/mob/living/basic/mining/deacon/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_AI_PAUSED, INNATE_TRAIT)
	status_flags |= GODMODE //invulnerable until enough contracts are complete
	RegisterSignal(SSdcs, COMSIG_BOUNTY_COMPLETE, PROC_REF(on_completed_bounty))
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
		/datum/action/cooldown/mob_cooldown/domain_teleport/surface = BB_DEACON_SURFACE_DOMAIN,
		/datum/action/cooldown/mob_cooldown/bounce = BB_DEACON_BOUNCE,
		/datum/action/cooldown/mob_cooldown/cast_phantom = BB_DEACON_PHANTOM,
		/datum/action/cooldown/mob_cooldown/crystal_mayhem = BB_DEACON_CRYSTAL_MAYHEM,
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
		BB_DEACON_PHANTOM,
	)
	var/static/list/special_attacks = list(
		BB_DEACON_HEALING_PYLON,
		BB_DEACON_BLACKNWHITE,
		BB_DEACON_ENTRAPPMENT,
		BB_DEACON_CRYSTAL_MAYHEM,
	)
	var/static/list/domain_attacks = list(
		BB_DEACON_HELL_DOMAIN = 0.75,
		BB_DEACON_HEAVEN_DOMAIN = 0.5,
		BB_DEACON_SURFACE_DOMAIN = 0.25,
	)

	var/static/list/cycle_count_reseters = list(
		/datum/action/cooldown/mob_cooldown/healing_pylon,
		/datum/action/cooldown/mob_cooldown/black_n_white,
		/datum/action/cooldown/mob_cooldown/beam_trial,
		/datum/action/cooldown/mob_cooldown/crystal_mayhem,
	)
	var/static/list/cycle_timers = list(
		/datum/action/cooldown/mob_cooldown/lightning_fissure = 16 SECONDS,
		/datum/action/cooldown/mob_cooldown/crystal_barrage = 18 SECONDS,
		/datum/action/cooldown/mob_cooldown/beam_crystal = 15 SECONDS,
	)
	ai_controller.set_blackboard_key(BB_DEACON_IDLE_ATTACKS, idle_attacks)
	ai_controller.set_blackboard_key(BB_DEACON_NORMAL_ATTACKS, normal_attacks)
	ai_controller.set_blackboard_key(BB_DEACON_SPECIAL_ATTACKS, special_attacks)
	ai_controller.set_blackboard_key(BB_DEACON_DOMAIN_ATTACKS, domain_attacks)
	ai_controller.set_blackboard_key(BB_DEACON_CYCLE_TIMERS, cycle_timers)
	ai_controller.set_blackboard_key(BB_DEACON_CYCLE_RESETERS, cycle_count_reseters)

/mob/living/basic/mining/deacon/proc/on_completed_bounty()
	SIGNAL_HANDLER
	bounty_counter++
	if(bounty_counter < bounty_threshold)
		return
	status_flags &= ~GODMODE
	REMOVE_TRAIT(src, TRAIT_AI_PAUSED, INNATE_TRAIT)

/mob/living/basic/mining/deacon_phantom
	name = "deep sea phantom"
	desc = "Spooky..."
	icon = 'icons/mob/nonhuman-player/96x96eldritch_mobs.dmi'
	icon_state = "deep_sea_deacon_phantom"
	icon_living = "deep_sea_deacon_phantom"
	pixel_x = -32
	base_pixel_x = -32
	gender = MALE
	speed = 10
	light_range = 2
	light_color = COLOR_PURPLE
	basic_mob_flags = IMMUNE_TO_FISTS
	light_range = 6
	light_color = COLOR_PURPLE
	maxHealth = 500
	health = 500
	faction = list(FACTION_MINING, FACTION_BOSS)
	sentience_type = SENTIENCE_BOSS
	move_force = MOVE_FORCE_VERY_STRONG
	move_resist = MOVE_FORCE_VERY_STRONG
	pull_force = MOVE_FORCE_VERY_STRONG
	density = FALSE
	ai_controller = /datum/ai_controller/basic_controller/deacon_phantom

/mob/living/basic/mining/deacon_phantom/Initialize(mapload)
	. = ..()
	var/static/list/other_innate_actions = list(
		/datum/action/cooldown/mob_cooldown/bounce/no_chasm = BB_DEACON_BOUNCE,
	)
	AddElement(/datum/element/temporary_atom, life_time = 15 SECONDS, fade_time = 1.5 SECONDS)
	grant_actions_by_list(other_innate_actions)


/mob/living/basic/mining/spirit_deacon
	name = "spirit deacon"
	desc = "Seems to lacks both mind and conscious..."
	icon = 'icons/mob/nonhuman-player/96x96eldritch_mobs.dmi'
	icon_state = "deep_sea_deacon"
	icon_living = "deep_sea_deacon"
	pixel_x = -32
	base_pixel_x = -32
	speed = 5
	alpha = 155
	light_range = 6
	light_color = COLOR_PINK
	basic_mob_flags = IMMUNE_TO_FISTS
	maxHealth = INFINITE
	health = INFINITE
	faction = list(FACTION_HOSTILE)
	speak_emote = list("preaches")
	melee_damage_lower = 10
	melee_damage_upper = 15
	sentience_type = SENTIENCE_BOSS
	attack_sound = 'sound/magic/magic_block_holy.ogg'
	attack_verb_continuous = "exorcizes"
	attack_verb_simple = "exorcize"
	density = FALSE
	ai_controller = /datum/ai_controller/basic_controller/spirit_deacon

/mob/living/basic/mining/spirit_deacon/proc/respond_to_sword(datum/source, atom/target, atom/user, list/modifiers)
	SIGNAL_HANDLER
	if(!isliving(target))
		return
	var/mob/living/living_target = target
	if(living_target.mob_size < MOB_SIZE_LARGE) //we only work on mining mobs
		return
	ai_controller.set_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET, target)
