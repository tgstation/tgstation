/mob/living/basic/blood_worm
	icon = 'icons/mob/nonhuman-player/blood_worm_32x32.dmi'

	faction = list(FACTION_BLOOD_WORM)

	initial_language_holder = /datum/language_holder/blood_worm

	// FIXME: This should use MOB_BUG, but it makes hunter boxing instakill juveniles.
	// I.e. blood worms should be susceptible to pest killer, but not hunter boxing.
	mob_biotypes = MOB_ORGANIC
	basic_mob_flags = FLAMMABLE_MOB
	status_flags = CANPUSH // No CANSTUN, blood worms are immune to stuns by design.

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
	unsuitable_cold_damage = 0

	habitable_atmos = null

	// A vivid red.
	lighting_cutoff_red = 40
	lighting_cutoff_green = 20
	lighting_cutoff_blue = 20

	/// Identification number, i.e. "hatchling blood worm (id)"
	/// Used for carrying the same number through growth stages.
	var/id_number = null

	/// Effect name for stuff like "invade-[effect_name]".
	/// Should correspond to the growth stage, like "adult".
	var/effect_name = ""

	/// How long the leave host animation lasts for this type, in deciseconds.
	var/leave_host_duration = 0

	/// How much regular (human, blood pack, etc.) blood the worm has consumed.
	var/consumed_normal_blood = 0
	/// How much synthetic (monkey, duplicated, etc.) blood the worm has consumed.
	var/consumed_synth_blood = 0
	/// The maximum amount of synthetic blood counted for growth.
	var/maximum_synth_blood = 1000
	/// How efficient ingesting synthetic blood is compared to normal blood. (ingested amount is multiplied by this)
	var/synth_blood_efficiency = 0.7

	/// The current host of the blood worm, if any.
	/// You can use this to check if the blood worm has a host.
	var/mob/living/carbon/human/host
	/// The backseat mob for the mind of the current host, if any.
	/// This mob is always dead as it's just a mind holder.
	var/mob/living/blood_worm_host/backseat

	/// The blood display on the left side of the screen, which is shown to the blood worm while in a host, if any.
	var/atom/movable/screen/blood_level/blood_display

	// Innate and shared actions

	/// Typed, please initialize with a proper action subtype. (empty = no action)
	var/datum/action/cooldown/mob_cooldown/blood_worm/spit/spit_action
	/// Typed, please initialize with a proper action subtype. (empty = no action)
	var/datum/action/cooldown/mob_cooldown/blood_worm/leech/leech_action
	/// Not typed, please leave empty.
	var/datum/action/cooldown/mob_cooldown/blood_worm/invade/invade_action
	/// Typed, please initialize with a proper action subtype. (empty = no action)
	var/datum/action/cooldown/mob_cooldown/blood_worm/cocoon/cocoon_action

	// Host actions

	/// Typed, please initialize with a proper action subtype. (empty = no action)
	var/datum/action/cooldown/mob_cooldown/blood_worm/inject/transfuse_action
	/// Not typed, please leave empty.
	var/datum/action/cooldown/mob_cooldown/blood_worm/eject/eject_action
	/// Not typed, please leave empty.
	var/datum/action/cooldown/mob_cooldown/blood_worm/revive/revive_action

	/// List of actions outside of a host.
	var/list/innate_actions = list()
	/// List of actions inside of a host.
	var/list/host_actions = list()

	/// Whether the blood worm has a host AND is currently in control of that host.
	var/is_possessing_host = FALSE

	/// The last amount of blood added to the host by blood dilution.
	var/last_added_blood = 0

	/// How quickly the blood worm regenerates, in health per second.
	var/regen_rate = 0

	COOLDOWN_DECLARE(host_heat_alert_cooldown)
	COOLDOWN_DECLARE(host_bleed_alert_cooldown)

/mob/living/basic/blood_worm/Initialize(mapload)
	. = ..()

	// Innate and shared actions

	if (ispath(spit_action, /datum/action/cooldown/mob_cooldown/blood_worm/spit))
		spit_action = new spit_action(src)
		innate_actions += spit_action
		host_actions += spit_action

	if (ispath(leech_action, /datum/action/cooldown/mob_cooldown/blood_worm/leech))
		leech_action = new leech_action(src)
		innate_actions += leech_action

	invade_action = new(src)
	innate_actions += invade_action

	if (ispath(cocoon_action, /datum/action/cooldown/mob_cooldown/blood_worm/cocoon))
		cocoon_action = new cocoon_action(src)
		innate_actions += cocoon_action

	// Host actions

	if (ispath(transfuse_action, /datum/action/cooldown/mob_cooldown/blood_worm/inject))
		transfuse_action = new transfuse_action(src)
		host_actions += transfuse_action

	eject_action = new(src)
	host_actions += eject_action

	revive_action = new(src)
	host_actions += revive_action

	grant_actions(src, innate_actions)

	ADD_TRAIT(src, TRAIT_BLOOD_HUD, INNATE_TRAIT)

	// Move speed delays at min health
	// Hatchling goes from 1.5 up to 2 deciseconds
	// Juvenile goes from 1.8 up to 2.3 deciseconds
	// Adult goes from 2 up to 2.5 deciseconds
	// For reference, a cyborg has a move speed delay of 1.5 deciseconds
	AddComponent(/datum/component/health_scaling_effects, min_health_slowdown = 0.5)

	id_number = rand(1, 999)
	update_name()

/mob/living/basic/blood_worm/Destroy()
	unregister_host()

	spit_action = null
	leech_action = null
	invade_action = null
	cocoon_action = null

	transfuse_action = null
	eject_action = null
	revive_action = null

	innate_actions = null
	host_actions = null

	return ..()

/mob/living/basic/blood_worm/Login()
	. = ..()
	if (!. || !client)
		return FALSE
	if (host)
		ADD_TRAIT(host, TRAIT_MIND_TEMPORARILY_GONE, BLOOD_WORM_HOST_TRAIT)

/mob/living/basic/blood_worm/Logout()
	. = ..()
	if (host)
		REMOVE_TRAIT(host, TRAIT_MIND_TEMPORARILY_GONE, BLOOD_WORM_HOST_TRAIT)

/mob/living/basic/blood_worm/process(seconds_per_tick, times_fired)
	if (!host)
		return

	sync_health()

/mob/living/basic/blood_worm/Life(seconds_per_tick, times_fired)
	. = ..()

	if (!host)
		// Moved to host life while in a host.
		adjust_worm_health(regen_rate * seconds_per_tick)
	else
		bodytemperature = T20C

/mob/living/basic/blood_worm/handle_environment(datum/gas_mixture/environment, seconds_per_tick, times_fired)
	if (host)
		bodytemperature = T20C
	else
		return ..()

/mob/living/basic/blood_worm/update_name(updates)
	. = ..()
	name = "[initial(name)] ([id_number])"
	real_name = name

/mob/living/basic/blood_worm/adjust_health(amount, updating_health, forced)
	return host ? 0 : ..() // Prevents damage from adjustXLoss while in a host, because that damage would be nullified by the next [proc/sync_health] call. Adjust host blood volume instead.

/mob/living/basic/blood_worm/set_stat(new_stat)
	. = ..()

	if (host && stat != CONSCIOUS)
		leave_host()

/mob/living/basic/blood_worm/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()

	if (host && loc != host)
		unregister_host()

/mob/living/basic/blood_worm/proc/consume_blood(blood_amount, synth_content = 0, should_heal = TRUE)
	if (blood_amount <= 0)
		return

	synth_content = clamp(synth_content, 0, 1)

	var/was_capped = consumed_synth_blood >= maximum_synth_blood

	consumed_synth_blood = min(consumed_synth_blood + blood_amount * synth_content * synth_blood_efficiency, maximum_synth_blood)
	consumed_normal_blood += blood_amount * (1 - synth_content)

	if (!was_capped && consumed_synth_blood >= maximum_synth_blood)
		if (host)
			host.balloon_alert(is_possessing_host ? host : src, "synthetic cap reached!")
		else
			balloon_alert(src, "synthetic cap reached!")

	if (should_heal)
		// Synthetic blood works just fine for healing.
		adjust_worm_health(blood_amount * BLOOD_WORM_BLOOD_TO_HEALTH)

	SEND_SIGNAL(src, COMSIG_BLOOD_WORM_CONSUME_BLOOD, blood_amount, synth_content, should_heal)

/mob/living/basic/blood_worm/proc/reset_consumed_blood()
	consumed_normal_blood = 0
	consumed_synth_blood = 0

/mob/living/basic/blood_worm/proc/get_consumed_blood()
	return consumed_normal_blood + consumed_synth_blood

/// Gets the current health of the worm, regardless of if its in a host or not.
/mob/living/basic/blood_worm/proc/get_worm_health()
	return host ? min(host.get_blood_volume() * BLOOD_WORM_BLOOD_TO_HEALTH, maxHealth) : health

/// Adjusts the current health of the worm, regardless of if its in a host or not.
/mob/living/basic/blood_worm/proc/adjust_worm_health(amount)
	return host ? host.adjust_blood_volume(amount * BLOOD_WORM_HEALTH_TO_BLOOD) * BLOOD_WORM_BLOOD_TO_HEALTH : adjustBruteLoss(-amount)

/mob/living/basic/blood_worm/proc/enter_host(mob/living/carbon/human/new_host, silent = FALSE, gain_progress = TRUE)
	if (!silent)
		playsound(src, 'sound/effects/magic/enter_blood.ogg', vol = 60, vary = TRUE, ignore_walls = FALSE)

		visible_message(
			message = span_bolddanger("\The [src] enter[p_s()] \the [new_host]!"),
			self_message = span_notice("You enter \the [new_host]."),
			blind_message = span_hear("You hear a squelch.")
		)

		new /obj/effect/temp_visual/blood_worm_invade_host(get_turf(new_host), effect_name)

	host = new_host

	RegisterSignal(host, COMSIG_QDELETING, PROC_REF(on_host_qdel))
	RegisterSignal(host, COMSIG_MOB_STATCHANGE, PROC_REF(on_host_stat_changed))
	RegisterSignal(host, COMSIG_HUMAN_ON_HANDLE_BLOOD, PROC_REF(on_host_handle_blood))
	RegisterSignal(host, COMSIG_LIVING_LIFE, PROC_REF(on_host_life))
	RegisterSignal(host, COMSIG_LIVING_ADJUST_OXY_DAMAGE, PROC_REF(on_host_adjust_oxy_damage))
	RegisterSignal(host, COMSIG_LIVING_PRE_UPDATE_BLOOD_STATUS, PROC_REF(on_host_pre_update_blood_status))
	RegisterSignal(host, COMSIG_MOB_GET_STATUS_TAB_ITEMS, PROC_REF(on_host_get_status_tab_items))
	RegisterSignal(host, COMSIG_MOB_EXAMINING, PROC_REF(on_host_examining))

	START_PROCESSING(SSfastprocess, src)

	add_traits(list(TRAIT_INCAPACITATED, TRAIT_IMMOBILIZED, TRAIT_MUTE, TRAIT_EMOTEMUTE), BLOOD_WORM_HOST_TRAIT)

	host.add_traits(list(
	TRAIT_NOBREATH, // Makes blood worms carry at least one of their atmos immunities to a host. Also allows them to take off masks to be able to spit, without risking suffocation.
	TRAIT_STABLEHEART, // Allows blood worms to take fucked up hosts. Especially useful if you accidentally gut your future host yourself. (very possible as an adult)
	TRAIT_STABLELIVER, // Ditto.
	TRAIT_NOCRITDAMAGE, // Prevents blood worms from noob trapping themselves by reviving a host "too early", since that shouldn't be a thing.
	TRAIT_NOHUNGER, // Every single long-deceased corpse is starved. Many people also just ignore hunger the whole shift. Starving with every new host gets old fast.
	TRAIT_NO_WITHDRAWALS, // Prevents OOC quirk choices from impacting blood worms as much. Stops withdrawals instead of addictions since the latter can be metagamed.
	TRAIT_NO_SPLIT_PERSONALITY, // How about no?
	TRAIT_BLOOD_HUD, // Self-explanatory, allows blood worms to seek prey even while in a host.
	TRAIT_BLOOD_WORM_HOST), // Used in code for recognizing blood worm hosts with a simple trait check.
	BLOOD_WORM_HOST_TRAIT)

	if (client)
		ADD_TRAIT(host, TRAIT_MIND_TEMPORARILY_GONE, BLOOD_WORM_HOST_TRAIT)

	host.AddElement(/datum/element/hand_organ_insertion)

	remove_actions(src, innate_actions)
	grant_actions(src, host_actions)

	var/cached_blood_volume = host.get_blood_volume()

	if (gain_progress)
		// Apply the host's blood volume to our growth.
		consume_blood(cached_blood_volume, host.get_blood_synth_content(), should_heal = FALSE)

	// Combine our health with the blood of our host.
	host.set_blood_volume(cached_blood_volume + health * BLOOD_WORM_HEALTH_TO_BLOOD)

	// Modify host blood such that it's BLOOD_VOLUME_NORMAL when we're at max health.
	host.set_blood_volume_modifier(REF(src), BLOOD_VOLUME_NORMAL / (maxHealth * BLOOD_WORM_HEALTH_TO_BLOOD))

	// Caps host blood volume to our custom maximum and syncs our bruteloss with host health.
	sync_health()

	if (host.hud_used)
		create_host_hud(host)
	else
		RegisterSignal(host, COMSIG_MOB_HUD_CREATED, PROC_REF(create_host_hud))

	forceMove(host)

	if (host.stat != DEAD)
		possess_host()

/mob/living/basic/blood_worm/proc/leave_host()
	if (!host)
		return

	visible_message(
		message = span_bolddanger("\The [src] emerge[p_s()] from \the [host]!"),
		blind_message = span_hear("You hear a squelch."),
		ignored_mobs = list(host, src)
	)

	to_chat(is_possessing_host ? host : src, span_notice("You emerge from \the [host]."))

	forceMove(host.drop_location()) // This will call unregister_host() via Moved()

	playsound(src, 'sound/effects/magic/exit_blood.ogg', vol = 60, vary = TRUE, ignore_walls = FALSE)

	Immobilize(leave_host_duration, ignore_canstun = TRUE)
	incapacitate(leave_host_duration, ignore_canstun = TRUE)

	// Uses the icon file of the current mob. This means the animation is 32x48 for the adults.
	flick("leave-[effect_name]", src)

/mob/living/basic/blood_worm/proc/unregister_host()
	if (!host)
		return

	possess_worm()

	UnregisterSignal(host, list(
		COMSIG_QDELETING,
		COMSIG_MOB_STATCHANGE,
		COMSIG_HUMAN_ON_HANDLE_BLOOD,
		COMSIG_LIVING_LIFE,
		COMSIG_LIVING_ADJUST_OXY_DAMAGE,
		COMSIG_LIVING_PRE_UPDATE_BLOOD_STATUS,
		COMSIG_MOB_GET_STATUS_TAB_ITEMS,
		COMSIG_MOB_EXAMINING,
		COMSIG_MOB_HUD_CREATED,
	))

	STOP_PROCESSING(SSfastprocess, src)

	REMOVE_TRAITS_IN(src, BLOOD_WORM_HOST_TRAIT)
	REMOVE_TRAITS_IN(host, BLOOD_WORM_HOST_TRAIT)
	host.RemoveElement(/datum/element/hand_organ_insertion)

	remove_actions(src, host_actions)
	grant_actions(src, innate_actions)

	host.remove_blood_volume_modifier(REF(src))
	sync_health(already_ejecting = TRUE)

	remove_host_hud()

	host.set_blood_volume(0)

	if (host.stat != DEAD)
		host.death() // I don't care if you have TRAIT_NODEATH, can't die from bloodloss normally, or whatever else. I just need you to die.

	host = null

/mob/living/basic/blood_worm/proc/possess_host()
	if (!host || is_possessing_host)
		return

	is_possessing_host = TRUE

	if (host.mind)
		backseat = new(host)
		backseat.death(gibbed = TRUE) // Same thing that the corpse mob spawners do to stop deathgasps and such.

		// If the host is a changeling, then we forcibly move their client to the backseat so they can use Expel Worm if they wish to.
		host.mind.transfer_to(backseat, force_key_move = host.mind.has_antag_datum(/datum/antagonist/changeling))

	mind?.transfer_to(host)

	remove_actions(src, host_actions)
	grant_actions(host, host_actions)

	host.grant_language(/datum/language/wormspeak, UNDERSTOOD_LANGUAGE, LANGUAGE_BLOOD_WORM)

/mob/living/basic/blood_worm/proc/possess_worm()
	if (!host || !is_possessing_host)
		return

	is_possessing_host = FALSE

	host.mind?.transfer_to(src)

	if (backseat)
		backseat.mind?.transfer_to(host)
		QDEL_NULL(backseat)

	remove_actions(host, host_actions)
	grant_actions(src, host_actions)

	host.remove_language(/datum/language/wormspeak, UNDERSTOOD_LANGUAGE, LANGUAGE_BLOOD_WORM)

/mob/living/basic/blood_worm/proc/on_host_qdel(datum/source, force)
	SIGNAL_HANDLER
	qdel(src)

/mob/living/basic/blood_worm/proc/on_host_stat_changed(datum/source, new_stat, old_stat)
	SIGNAL_HANDLER
	if (old_stat == DEAD && new_stat != DEAD)
		possess_host()
	else if (old_stat != DEAD && new_stat == DEAD)
		possess_worm()

/mob/living/basic/blood_worm/proc/on_host_handle_blood(datum/source, seconds_per_tick, times_fired)
	SIGNAL_HANDLER
	return HANDLE_BLOOD_NO_OXYLOSS | HANDLE_BLOOD_NO_NUTRITION_DRAIN

/mob/living/basic/blood_worm/proc/on_host_life(datum/source, seconds_per_tick, times_fired)
	// Moved to worm life when not in a host.
	adjust_worm_health(regen_rate * seconds_per_tick)

	// Required for now, because TRAIT_NOBREATH does not actually prevent oxygen damage.
	// This is really weird because it also sets oxygen damage to 0 when added to a mob.
	host.setOxyLoss(0, forced = TRUE)

	if (!HAS_TRAIT(host, TRAIT_STASIS))
		handle_host_blood(seconds_per_tick, times_fired)
		handle_host_temperature(seconds_per_tick, times_fired)

/mob/living/basic/blood_worm/proc/handle_host_blood(seconds_per_tick, times_fired)
	if (host.stat == DEAD)
		host.handle_blood(seconds_per_tick, times_fired)

	// Ignored while possessing a host, as [carbon/proc/bleed_warn] handles it instead.
	if (!is_possessing_host && COOLDOWN_FINISHED(src, host_bleed_alert_cooldown) && host.get_bleed_rate() > 0)
		to_chat(src, span_userdanger("Your host is bleeding!"))
		COOLDOWN_START(src, host_bleed_alert_cooldown, 15 SECONDS)

/mob/living/basic/blood_worm/proc/handle_host_temperature(seconds_per_tick, times_fired)
	if (host.coretemperature <= maximum_survivable_temperature)
		return

	var/burn_coeff = damage_coeff[BURN]
	adjust_worm_health(-unsuitable_heat_damage * (burn_coeff ? burn_coeff : 1) * seconds_per_tick)

	if (COOLDOWN_FINISHED(src, host_heat_alert_cooldown))
		to_chat(is_possessing_host ? host : src, span_userdanger("Your blood is burning up!"))
		COOLDOWN_START(src, host_heat_alert_cooldown, 15 SECONDS)

/mob/living/basic/blood_worm/proc/on_host_adjust_oxy_damage(datum/source, type, amount, forced)
	SIGNAL_HANDLER
	return COMPONENT_IGNORE_CHANGE // Functionally, this unimplements oxy damage from hosts altogether. Which is exactly what we want.

/mob/living/basic/blood_worm/proc/on_host_pre_update_blood_status(datum/source, had_blood, has_blood, old_blood_volume)
	SIGNAL_HANDLER
	if (!has_blood)
		leave_host()

/mob/living/basic/blood_worm/proc/create_host_hud(datum/source)
	SIGNAL_HANDLER
	UnregisterSignal(host, COMSIG_MOB_HUD_CREATED)

	var/datum/hud/hud = host.hud_used
	blood_display = new(null, hud)
	hud.infodisplay += blood_display
	hud.show_hud(hud.hud_version)

/mob/living/basic/blood_worm/proc/remove_host_hud()
	var/datum/hud/hud = host.hud_used

	if (!hud)
		QDEL_NULL(blood_display)
		return

	hud.infodisplay -= blood_display
	QDEL_NULL(blood_display)

/mob/living/basic/blood_worm/proc/grant_actions(mob/target, list/actions)
	for (var/datum/action/action as anything in actions)
		action.Grant(target)

/mob/living/basic/blood_worm/proc/remove_actions(mob/target, list/actions)
	for (var/datum/action/action as anything in actions)
		action.Remove(target)

/mob/living/basic/blood_worm/proc/sync_health(already_ejecting = FALSE)
	if (!host)
		return

	var/host_max_blood = maxHealth * BLOOD_WORM_HEALTH_TO_BLOOD

	// Cap host blood to maximum
	if (host.get_blood_volume() > host_max_blood)
		host.set_blood_volume(host_max_blood)

	var/cached_blood_volume = host.get_blood_volume()

	// Sync mob health to host blood
	setBruteLoss(maxHealth * (1 - cached_blood_volume / host_max_blood))

	// Checks if we still have a host since setBruteLoss() can kill us, causing us to leave our host.
	if (!already_ejecting && cached_blood_volume <= get_eject_volume_threshold())
		// Sent before leave_host() for the correct message order in chat
		to_chat(is_possessing_host ? host : src, span_userdanger("You run out of blood to control your host with!"))

		leave_host()

		// Has to be sent after the forceMove() in leave_host()
		balloon_alert(src, "out of blood!")

/mob/living/basic/blood_worm/examining(atom/target, list/result)
	add_special_examining_messages(target, result)

/mob/living/basic/blood_worm/proc/on_host_examining(datum/source, atom/target, list/examine_strings)
	SIGNAL_HANDLER
	add_special_examining_messages(target, examine_strings)

/mob/living/basic/blood_worm/proc/add_special_examining_messages(atom/target, list/result)
	if (!isliving(target) || target == host)
		return

	var/mob/living/bloodbag = target

	var/cached_blood_volume = bloodbag.get_blood_volume()

	if (cached_blood_volume <= 0)
		return

	var/list/blood_data = bloodbag.get_blood_data()

	var/synth_content = blood_data?[BLOOD_DATA_SYNTH_CONTENT]
	if (!isnum(synth_content))
		synth_content = 0 // Otherwise the switch statement breaks.

	var/normal_content = 1 - synth_content

	var/normal_blood_after = consumed_normal_blood + cached_blood_volume * normal_content
	var/synth_blood_after = min(consumed_synth_blood + cached_blood_volume * synth_content, maximum_synth_blood)

	var/total_blood_now = get_consumed_blood()
	var/total_blood_after = normal_blood_after + synth_blood_after

	var/potential_gain = total_blood_after - total_blood_now

	var/rounded_volume = CEILING(cached_blood_volume, 1)

	var/growth_string = ""
	if (HAS_TRAIT(bloodbag, TRAIT_BLOOD_WORM_HOST))
		growth_string = ", but consuming it is impossible, as they are a host"
	else if (total_blood_now < cocoon_action?.total_blood_required)
		var/rounded_growth = CEILING(potential_gain / cocoon_action.total_blood_required * 100, 1)
		if (rounded_growth > 0)
			growth_string = ", consuming it would contribute <b>[rounded_growth]%</b> to your growth"
		else
			growth_string = ", but consuming it wouldn't contribute to your growth"
	else
		if (!istype(src, /mob/living/basic/blood_worm/adult))
			growth_string = ". You are already ready to mature"
		else
			growth_string = ". You are already fully grown"

	var/synth_string = "[CEILING(synth_content * 100, 1)]%"
	switch(synth_content)
		if (-INFINITY to 0)
			synth_string = "not"
		if (1 to INFINITY)
			synth_string = "fully"
		if (0 to 1)
			synth_string = "[CEILING(synth_content * 100, 1)]%"

	result += span_notice("[target.p_They()] [target.p_have()] [rounded_volume] unit[rounded_volume == 1 ? "" : "s"] of blood[growth_string]. [target.p_Their()] blood is <b>[synth_string]</b> synthetic.")

/mob/living/basic/blood_worm/get_status_tab_items()
	return ..() + get_special_status_tab_items()

/mob/living/basic/blood_worm/proc/on_host_get_status_tab_items(datum/source, list/items)
	SIGNAL_HANDLER
	items += "Worm Health: [round((health / maxHealth) * 100)]%"
	items += get_special_status_tab_items()

/mob/living/basic/blood_worm/proc/get_special_status_tab_items()
	. = list()

	var/normal = consumed_normal_blood
	var/synth = consumed_synth_blood
	var/total = normal + synth

	var/total_required = cocoon_action?.total_blood_required

	if (total_required > 0)
		. += "Growth: [FLOOR(total / total_required * 100, 1)]%"
	. += "Blood Consumed"
	. += "- Normal: [CEILING(normal, 1)]u"
	. += "- Synthetic: [CEILING(synth, 1)]u (MAX: [maximum_synth_blood]u)"
	. += "- Total: [CEILING(total, 1)]u (REQ: [total_required]u)"

/// Gets BLOOD_WORM_EJECT_THRESHOLD as an actionable blood volume threshold.
/mob/living/basic/blood_worm/proc/get_eject_volume_threshold()
	return maxHealth * BLOOD_WORM_HEALTH_TO_BLOOD * BLOOD_WORM_EJECT_THRESHOLD

/obj/effect/temp_visual/blood_worm_invade_host
	icon = 'icons/mob/nonhuman-player/blood_worm_32x32.dmi'
	icon_state = "invade-hatchling" // Not actually used for anything, it's just a default because otherwise the unit tests scream about it.
	duration = 2 SECONDS

/obj/effect/temp_visual/blood_worm_invade_host/Initialize(mapload, effect_name)
	. = ..()
	icon_state = "invade-[effect_name]"

/mob/living/basic/blood_worm/hatchling
	name = "hatchling blood worm"
	desc = "A freshly hatched blood worm. It looks hungry and weak, requiring blood to grow further."

	icon_state = "hatchling"
	icon_living = "hatchling"
	icon_dead = "hatchling-dead"

	mob_size = MOB_SIZE_TINY
	pass_flags = PASSTABLE | PASSMOB // The benefits of being a tiny little bastard.

	maxHealth = 80 // In practice, escaping into a vent from someone who could 3 hit you with a basic bitch welder was really hard. This used to be 50, and was buffed to 80, but speed was slowed a bit.
	health = 80

	unsuitable_heat_damage = 1

	obj_damage = 15 // 10 -> 15, in testing 10 proved to be way too slow at breaking morgue trays and such. Make sure that this doesn't go above airlock damage deflection.
	melee_damage_lower = 12
	melee_damage_upper = 14
	armour_penetration = 10

	speed = 0

	effect_name = "hatchling"
	leave_host_duration = 0.6 SECONDS

	leech_action = /datum/action/cooldown/mob_cooldown/blood_worm/leech/hatchling
	cocoon_action = /datum/action/cooldown/mob_cooldown/blood_worm/cocoon/hatchling

	transfuse_action = /datum/action/cooldown/mob_cooldown/blood_worm/inject/hatchling

	regen_rate = 0.3 // 266 seconds to recover from 0 to 80, or almost 4 and a half minutes.

/mob/living/basic/blood_worm/hatchling/Initialize(mapload)
	. = ..()

	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)

/mob/living/basic/blood_worm/juvenile
	name = "juvenile blood worm"
	desc = "A mid-sized blood worm. It looks bloodthirsty and has numerous long and extremely sharp teeth."

	icon_state = "juvenile"
	icon_living = "juvenile"
	icon_dead = "juvenile-dead"

	mob_size = MOB_SIZE_SMALL

	maxHealth = 120 // Note that the juveniles are bigger and slower than hatchlings, making them far easier to hit by comparison.
	health = 120

	unsuitable_heat_damage = 1.5

	obj_damage = 35 // Able to break most obstacles, such as airlocks. This is mandatory since they can't ventcrawl anymore.
	melee_damage_lower = 18 // Juveniles can't run away nearly as easily, so they are expected to do direct combat against normal crew. (but lose hard to well-equipped sec)
	melee_damage_upper = 22
	armour_penetration = 30

	wound_bonus = 0 // Juveniles can afford to heal wounds on their hosts, unlike hatchlings. Note that this can't cause critical wounds. (at least it didn't in testing)
	sharpness = SHARP_POINTY

	speed = 0.3

	effect_name = "juvenile"
	leave_host_duration = 1 SECONDS

	spit_action = /datum/action/cooldown/mob_cooldown/blood_worm/spit/juvenile
	leech_action = /datum/action/cooldown/mob_cooldown/blood_worm/leech/juvenile
	cocoon_action = /datum/action/cooldown/mob_cooldown/blood_worm/cocoon/juvenile

	transfuse_action = /datum/action/cooldown/mob_cooldown/blood_worm/inject/juvenile

	regen_rate = 0.4 // 300 seconds to recover from 0 to 120, or exactly 5 minutes.

/mob/living/basic/blood_worm/adult
	name = "adult blood worm"
	desc = "A monstrosity of a blood worm. It'd probably be better to put your head in an industrial shredder rather than its maw."

	icon = 'icons/mob/nonhuman-player/blood_worm_32x48.dmi'

	icon_state = "adult"
	icon_living = "adult"
	icon_dead = "adult-dead"
	health_doll_icon = "adult_blood_worm"

	// We undershoot a tiny bit so that Proto-Kinetic Crushers don't work on adult blood worms.
	mob_size = MOB_SIZE_HUMAN

	maxHealth = 180 // Used to be 150, turns out their lack of armor and weakness to burn made them too squishy. People kited them using lasguns, leaving them with no way to fight back at all.
	health = 180

	unsuitable_heat_damage = 2

	obj_damage = 50 // You are not getting away.
	melee_damage_lower = 25
	melee_damage_upper = 30 // Turns out adults regularly end up encountering advanced weapons like cap's sabre, lasguns + armor, eswords, etc. They need a strong melee.
	armour_penetration = 50 // Adults will 100% encounter sec, they are shit out of luck without proper armor pen.

	wound_bonus = 0 // Able to cause critical wounds.
	sharpness = SHARP_POINTY

	attack_verb_simple = "gore"
	attack_verb_continuous = "gores"

	speed = 0.5

	effect_name = "adult"
	leave_host_duration = 1.4 SECONDS

	spit_action = /datum/action/cooldown/mob_cooldown/blood_worm/spit/adult
	leech_action = /datum/action/cooldown/mob_cooldown/blood_worm/leech/adult
	cocoon_action = /datum/action/cooldown/mob_cooldown/blood_worm/cocoon/adult

	transfuse_action = /datum/action/cooldown/mob_cooldown/blood_worm/inject/adult

	regen_rate = 0.5 // 360 seconds to recover from 0 to 180, or exactly 6 minutes.
