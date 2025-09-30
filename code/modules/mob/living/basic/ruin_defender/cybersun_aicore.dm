/// Boss for the hauntedtradingpost space ruin
/// It's a stationary AI core that casts spells
#define LIGHTNING_ABILITY_TYPEPATH /datum/action/cooldown/spell/pointed/lightning_strike
#define BARRAGE_ABILITY_TYPEPATH /datum/action/cooldown/spell/pointed/projectile/cybersun_barrage

/mob/living/basic/cybersun_ai_core
	name = "\improper Cybersun AI Core"
	desc = "An evil looking computer."
	icon = 'icons/mob/silicon/ai.dmi'
	icon_state = "ai-red"
	icon_living = "ai-red"
	gender = NEUTER
	status_flags = NONE
	basic_mob_flags = MOB_ROBOTIC
	mob_size = MOB_SIZE_HUGE
	basic_mob_flags = DEL_ON_DEATH
	health = 250
	maxHealth = 250
	faction = list(ROLE_SYNDICATE)
	ai_controller = /datum/ai_controller/basic_controller/cybersun_ai_core
	unsuitable_atmos_damage = 0
	combat_mode = TRUE
	move_resist = INFINITY
	damage_coeff = list(BRUTE = 1.5, BURN = 1, TOX = 0, STAMINA = 0, OXY = 0)
	light_system = OVERLAY_LIGHT
	light_range = 2
	light_power = 0.6
	light_color = "#eb1809"
	/// Ability which fires da lightning bolt
	var/datum/action/cooldown/mob_cooldown/lightning_strike
	/// Ability which fires da big laser
	var/datum/action/cooldown/mob_cooldown/targeted_mob_ability/donk_laser
	//is this being used as part of the haunted trading post ruin? if true, stuff there will self destruct when this mob dies
	var/donk_ai_master = FALSE
	/// the queue id for the stuff that selfdestructs when we die
	var/selfdestruct_queue_id = "hauntedtradingpost_sd"

/mob/living/basic/cybersun_ai_core/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_IMMOBILIZED, INNATE_TRAIT)
	AddElement(/datum/element/death_drops, /obj/effect/temp_visual/cybersun_ai_core_death)
	AddElement(/datum/element/relay_attackers)
	var/static/list/innate_actions = list(
		LIGHTNING_ABILITY_TYPEPATH = BB_CYBERSUN_CORE_LIGHTNING,
		BARRAGE_ABILITY_TYPEPATH = BB_CYBERSUN_CORE_BARRAGE,
	)
	grant_actions_by_list(innate_actions)
	if(mapload && donk_ai_master)
		return INITIALIZE_HINT_LATELOAD

/mob/living/basic/cybersun_ai_core/LateInitialize()
	SSqueuelinks.add_to_queue(src, selfdestruct_queue_id)
	SSqueuelinks.pop_link(selfdestruct_queue_id)

/mob/living/basic/cybersun_ai_core/MatchedLinks(id, list/partners) // id == queue id (for multiple queue objects)
	if(id != selfdestruct_queue_id)
		return
	for(var/datum/partner as anything in partners) // all our partners in the selfdestruct queue are now registered to qdel if I die
		partner.RegisterSignal(src, COMSIG_QDELETING, TYPE_PROC_REF(/datum, selfdelete))

/mob/living/basic/cybersun_ai_core/death(gibbed)
	do_sparks(number = 5, source = src)
	return ..()

/obj/effect/temp_visual/cybersun_ai_core_death
	icon = 'icons/mob/silicon/ai.dmi'
	icon_state = "ai-red_dead"
	duration = 2 SECONDS

/obj/effect/temp_visual/cybersun_ai_core_death/Initialize(mapload)
	. = ..()
	playsound(src, 'sound/misc/metal_creak.ogg', vol = 100, vary = TRUE, pressure_affected = FALSE)
	Shake(1, 0, 2 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(gib)), duration - 1, TIMER_DELETE_ME)

/obj/effect/temp_visual/cybersun_ai_core_death/proc/gib()
///dramatic death animations
	var/turf/my_turf = get_turf(src)
	new /obj/effect/gibspawner/robot(my_turf)
	playsound(loc, 'sound/effects/explosion/explosion2.ogg', vol = 75, vary = TRUE, pressure_affected = FALSE)
	for (var/mob/witness in range(10, src))
		if (!witness.client || !isliving(witness))
			continue
		shake_camera(witness, duration = 1.5 SECONDS - (0.7 * get_dist(src, witness)), strength = 1)

/// how the ai core thinks
/datum/ai_controller/basic_controller/cybersun_ai_core
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGETLESS_TIME = 0,
	)
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/targeted_mob_ability/lightning_strike,
		/datum/ai_planning_subtree/targeted_mob_ability/cybersun_barrage,
	)

/// DA SPELLS!
// spell #1: lightning strike
/datum/ai_planning_subtree/targeted_mob_ability/lightning_strike
	ability_key = BB_CYBERSUN_CORE_LIGHTNING
	finish_planning = FALSE

/datum/action/cooldown/spell/pointed/lightning_strike
	name = "lightning strike"
	desc = "Electrocutes a target with a big lightning bolt. Has a small delay."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "lightning"
	cooldown_time = 4 SECONDS
	click_to_activate = TRUE
	shared_cooldown = NONE
	sparks_amt = 1
	spell_requirements = null
	aim_assist = FALSE
	//how long after casting until the lightning strikes and damage is dealt
	var/lightning_delay = 1 SECONDS

/datum/action/cooldown/spell/pointed/lightning_strike/cast(atom/target)
	. = ..()
	//this is where the spell will hit. it will not move even if the target does, allowing the spell to be dodged.
	new/obj/effect/temp_visual/lightning_strike(get_turf(target))
	playsound(owner, 'sound/effects/sparks/sparks1.ogg', vol = 120, vary = TRUE)

/obj/effect/temp_visual/lightning_strike
	name = "lightning strike"
	desc = "A lightning bolt is about to hit this location. There's a handy hologram to warn people so they don't stand here."
	icon = 'icons/mob/telegraphing/telegraph_holographic.dmi'
	icon_state = "target_circle"
	duration = 1 SECONDS
	//  amount of damage a guy takes if they're on this tile
	var/zap_damage = 26
	/// don't hurt these guys capiche?
	var/list/damage_blacklist_typecache = list(
		/mob/living/basic/cybersun_ai_core,
		/mob/living/basic/viscerator,
		)

/obj/effect/temp_visual/lightning_strike/Initialize(mapload)
	. = ..()
	damage_blacklist_typecache = typecacheof(damage_blacklist_typecache)
	addtimer(CALLBACK(src, PROC_REF(zap)), duration, TIMER_DELETE_ME)

/obj/effect/temp_visual/lightning_strike/proc/zap()
	new/obj/effect/temp_visual/lightning_strike_zap(loc)
	playsound(src, 'sound/effects/magic/lightningbolt.ogg', vol = 70, vary = TRUE)
	if (!isturf(loc))
		return
	for(var/mob/living/victim in loc)
		if (is_type_in_typecache(victim, damage_blacklist_typecache))
			continue
		to_chat(victim, span_warning("You are struck by a large bolt of electricity!"))
		victim.electrocute_act(zap_damage, src, flags = SHOCK_NOGLOVES | SHOCK_NOSTUN)

/obj/effect/temp_visual/lightning_strike_zap
	name = "lightning bolt"
	desc = "Lightning bolt! Lightning bolt! Lightning bolt! Lightning bolt! Lightning bolt! Lightning bolt! Lightning bolt! Lightning bolt!"
	icon = 'icons/effects/32x96.dmi'
	icon_state = "thunderbolt"
	duration = 0.4 SECONDS

/obj/effect/temp_visual/lightning_strike_zap/Initialize(mapload)
	. = ..()
	do_sparks(number = rand(1,3), source = src)

// spell #2: cybersun laser barrage
/datum/ai_planning_subtree/targeted_mob_ability/cybersun_barrage
	ability_key = BB_CYBERSUN_CORE_BARRAGE
	finish_planning = FALSE

/datum/action/cooldown/spell/pointed/projectile/cybersun_barrage
	name = "plasma beam barrage"
	desc = "Charges up a cluster of lasers, then sends it towards a foe after a short delay."
	button_icon = 'icons/obj/weapons/transforming_energy.dmi'
	button_icon_state = "e_sword_on_red"
	cooldown_time = 5.5 SECONDS
	click_to_activate = TRUE
	shared_cooldown = NONE
	spell_requirements = null
	projectile_type = /obj/projectile/beam/laser/cybersun/weaker
	cast_range = 6
	projectiles_per_fire = 3
	var/barrage_delay = 0.8 SECONDS
	var/turf/lockon_zone

/datum/action/cooldown/spell/pointed/projectile/cybersun_barrage/cast(atom/target, atom/cast_on)
	var/turf/my_turf = get_turf(owner)
	lockon_zone = get_turf(target)
	if(lockon_zone == my_turf)
		return
	my_turf.Beam(lockon_zone, icon_state = "1-full", beam_color = COLOR_MEDIUM_DARK_RED, time = barrage_delay)
	playsound(lockon_zone, 'sound/machines/terminal/terminal_prompt_deny.ogg', vol = 60, vary = TRUE)
	StartCooldown(cooldown_time)
	return ..()

/datum/action/cooldown/spell/pointed/projectile/cybersun_barrage/fire_projectile(atom/target)
	target = lockon_zone
	if(do_after(owner, barrage_delay))
		return ..()

/obj/projectile/beam/laser/cybersun/weaker
	damage = 11

#undef LIGHTNING_ABILITY_TYPEPATH
#undef BARRAGE_ABILITY_TYPEPATH
