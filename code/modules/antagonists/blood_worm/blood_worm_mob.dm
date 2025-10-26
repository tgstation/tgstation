/mob/living/basic/blood_worm
	mob_biotypes = MOB_ORGANIC | MOB_BUG
	basic_mob_flags = FLAMMABLE_MOB

	damage_coeff = list(BRUTE = 1, BURN = 1.5, TOX = 0, STAMINA = 0, OXY = 0)

	pressure_resistance = 200

	combat_mode = TRUE

	melee_attack_cooldown = CLICK_CD_MELEE

	attack_sound = 'sound/items/weapons/bite.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE
	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"

	minimum_survivable_temperature = 0
	maximum_survivable_temperature = T0C + 100

	habitable_atmos = null

	// TEMPORARY ICONS
	icon = 'icons/mob/simple/carp.dmi'
	icon_state = "base"
	icon_living = "base"
	icon_dead = "base_dead"
	// TEMPORARY ICONS

	var/list/consumed_blood = list()

	var/mob/living/carbon/human/host
	var/mob/living/blood_worm_host/backseat

	var/datum/action/cooldown/mob_cooldown/blood_worm_leech/leech_action
	var/datum/action/cooldown/mob_cooldown/blood_worm_spit/spit_action
	var/datum/action/cooldown/mob_cooldown/blood_worm_invade/invade_action

	var/datum/action/blood_worm_eject/eject_action

	var/list/innate_actions = list()
	var/list/host_actions = list()

	var/is_possessing_host = FALSE

	var/last_added_blood = 0

	var/regen_rate = 0.5

/mob/living/basic/blood_worm/Initialize(mapload)
	. = ..()

	leech_action = new leech_action(src)
	spit_action = new spit_action(src)
	invade_action = new invade_action(src)

	eject_action = new(src)

	innate_actions = list(leech_action, spit_action, invade_action)
	host_actions = list(spit_action, eject_action)

	grant_actions(src, innate_actions)

/mob/living/basic/blood_worm/Destroy()
	. = ..()

	unregister_host()

/mob/living/basic/blood_worm/process(seconds_per_tick, times_fired)
	if (!host)
		return

	update_dilution()
	sync_health()

/mob/living/basic/blood_worm/Life(seconds_per_tick, times_fired)
	. = ..()

	if (!host)
		adjustBruteLoss(-regen_rate * seconds_per_tick)

/mob/living/basic/blood_worm/proc/ingest_blood(blood_amount, datum/blood_type/blood_type)
	consumed_blood[blood_type.id] += blood_amount
	adjustBruteLoss(-blood_amount * BLOOD_WORM_BLOOD_TO_HEALTH)

/mob/living/basic/blood_worm/proc/enter_host(mob/living/carbon/human/new_host)
	if (!mind || !key)
		return

	host = new_host

	RegisterSignal(host, COMSIG_QDELETING, PROC_REF(on_host_qdel))
	RegisterSignal(host, COMSIG_MOB_STATCHANGE, PROC_REF(on_host_stat_changed))
	RegisterSignal(host, COMSIG_HUMAN_ON_HANDLE_BLOOD, PROC_REF(on_host_handle_blood))
	RegisterSignal(host, COMSIG_LIVING_LIFE, PROC_REF(on_host_life))

	START_PROCESSING(SSfastprocess, src)

	become_blind(BLOOD_WORM_HOST_TRAIT)
	add_traits(list(TRAIT_DEAF, TRAIT_IMMOBILIZED, TRAIT_INCAPACITATED, TRAIT_MUTE), BLOOD_WORM_HOST_TRAIT)

	// The worm handles basic blood oxygenation, circulation and filtration.
	// The controlled host still requires a liver to process chemicals and lungs to speak.
	host.add_traits(list(TRAIT_NOBREATH, TRAIT_STABLEHEART, TRAIT_STABLELIVER), BLOOD_WORM_HOST_TRAIT)

	remove_actions(src, innate_actions)
	grant_actions(src, host_actions)

	if (host.mind)
		backseat = new(host)
		backseat.death(gibbed = TRUE) // Same thing that the corpse mob spawners do to stop deathgasps and such.
		host.mind.transfer_to(backseat)

	start_dilution()
	sync_health()

	forceMove(host)

/mob/living/basic/blood_worm/proc/leave_host()
	if (!host)
		return

	forceMove(get_turf(host))

	unregister_host()

/mob/living/basic/blood_worm/proc/unregister_host()
	if (!host)
		return

	possess_worm()

	if (backseat)
		backseat.mind?.transfer_to(host)
		QDEL_NULL(backseat)

	UnregisterSignal(host, list(COMSIG_QDELETING, COMSIG_MOB_STATCHANGE, COMSIG_HUMAN_ON_HANDLE_BLOOD, COMSIG_LIVING_LIFE))

	STOP_PROCESSING(SSfastprocess, src)

	cure_blind(BLOOD_WORM_HOST_TRAIT)
	REMOVE_TRAITS_IN(src, BLOOD_WORM_HOST_TRAIT)
	REMOVE_TRAITS_IN(host, BLOOD_WORM_HOST_TRAIT)

	remove_actions(src, host_actions)
	grant_actions(src, innate_actions)

	update_dilution()
	sync_health()

	host.blood_volume = 0

	host = null

/mob/living/basic/blood_worm/proc/possess_host()
	if (!host || is_possessing_host)
		return

	is_possessing_host = TRUE

	mind?.transfer_to(host)

	remove_actions(src, host_actions)
	grant_actions(host, host_actions)

/mob/living/basic/blood_worm/proc/possess_worm()
	if (!host || !is_possessing_host)
		return

	is_possessing_host = FALSE

	host.mind?.transfer_to(src)

	remove_actions(host, host_actions)
	grant_actions(src, host_actions)

/mob/living/basic/blood_worm/proc/on_host_qdel(datum/source, force)
	SIGNAL_HANDLER
	qdel(src)

/mob/living/basic/blood_worm/proc/on_host_stat_changed(datum/source, new_stat, old_stat)
	if (old_stat == DEAD && new_stat != DEAD)
		possess_host()
	else if (old_stat != DEAD && new_stat == DEAD)
		possess_worm()

/mob/living/basic/blood_worm/proc/on_host_handle_blood(datum/source, seconds_per_tick, times_fired)
	host.blood_volume += regen_rate * seconds_per_tick * BLOOD_WORM_HEALTH_TO_BLOOD
	return HANDLE_BLOOD_NO_OXYLOSS | HANDLE_BLOOD_NO_NUTRITION_DRAIN

/mob/living/basic/blood_worm/proc/on_host_life(datum/source, seconds_per_tick, times_fired)
	if (!HAS_TRAIT(host, TRAIT_STASIS))
		host.handle_blood(seconds_per_tick, times_fired)

/mob/living/basic/blood_worm/proc/grant_actions(mob/target, list/actions)
	for (var/datum/action/action as anything in actions)
		action.Grant(target)

/mob/living/basic/blood_worm/proc/remove_actions(mob/target, list/actions)
	for (var/datum/action/action as anything in actions)
		action.Remove(target)

/mob/living/basic/blood_worm/proc/start_dilution()
	var/health_as_blood = health * BLOOD_WORM_HEALTH_TO_BLOOD
	var/dilution_multiplier = get_dilution_multiplier()

	var/base_blood_volume = clamp(host.blood_volume + health_as_blood, 0, BLOOD_VOLUME_NORMAL / dilution_multiplier)
	var/diluted_blood_volume = base_blood_volume * dilution_multiplier

	last_added_blood = diluted_blood_volume - base_blood_volume
	host.blood_volume = diluted_blood_volume

/mob/living/basic/blood_worm/proc/update_dilution()
	var/dilution_multiplier = get_dilution_multiplier()

	var/base_blood_volume = clamp(host.blood_volume - last_added_blood, 0, BLOOD_VOLUME_NORMAL / dilution_multiplier)
	var/diluted_blood_volume = base_blood_volume * dilution_multiplier

	last_added_blood = diluted_blood_volume - base_blood_volume
	host.blood_volume = diluted_blood_volume

/mob/living/basic/blood_worm/proc/sync_health()
	if (!host)
		return

	setBruteLoss(maxHealth * (1 - host.blood_volume / BLOOD_VOLUME_NORMAL))

/mob/living/basic/blood_worm/proc/get_dilution_multiplier()
	return BLOOD_VOLUME_NORMAL / (maxHealth * BLOOD_WORM_HEALTH_TO_BLOOD)

/mob/living/basic/blood_worm/hatchling
	name = "hatchling blood worm"
	desc = "A freshly hatched blood worm. It's small, hungry for blood and very deadly."

	maxHealth = 50
	health = 50

	obj_damage = 10
	melee_damage_lower = 8
	melee_damage_upper = 12

	speed = 0

	invade_action = /datum/action/cooldown/mob_cooldown/blood_worm_invade
	leech_action = /datum/action/cooldown/mob_cooldown/blood_worm_leech/hatchling
	spit_action = /datum/action/cooldown/mob_cooldown/blood_worm_spit/hatchling

	regen_rate = 0.4 // A little over 2 minutes to recover from 0 to 50.

/mob/living/basic/blood_worm/hatchling/Initialize(mapload)
	. = ..()

	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)
