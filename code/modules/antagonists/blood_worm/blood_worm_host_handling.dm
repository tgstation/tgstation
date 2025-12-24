// Any proc that handles host logic and doesn't fit in a more specific file goes here.
// There are a ton of these and they are pretty tightly coupled to each other.

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

	host.physiology.bleed_mod *= BLOOD_WORM_BLEED_MOD

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

	log_blood_worm("[key_name(src)] entered their new host [key_name(host)]")

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

	to_chat_self(span_notice("You emerge from \the [host]."))

	log_blood_worm("[key_name(src)] left their host [key_name(host)]")

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
	host.physiology.bleed_mod /= BLOOD_WORM_BLEED_MOD
	host.RemoveElement(/datum/element/hand_organ_insertion)

	remove_actions(src, host_actions)
	grant_actions(src, innate_actions)

	host.remove_blood_volume_modifier(REF(src))
	sync_health(already_ejecting = TRUE)

	remove_host_hud()

	host.set_blood_volume(0)

	if (host.stat != DEAD)
		host.death() // I don't care if you have TRAIT_NODEATH, can't die from bloodloss normally, or whatever else. I just need you to die.

	log_blood_worm("[key_name(src)] unregistered their host [key_name(host)]")

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

	log_blood_worm("[key_name(src)] possessed their host [key_name(host)]")

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

	log_blood_worm("[key_name(src)] unpossessed their host [key_name(host)]")

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
	host.set_oxy_loss(0, forced = TRUE)

	if (!HAS_TRAIT(host, TRAIT_STASIS))
		handle_host_blood(seconds_per_tick, times_fired)
		handle_host_temperature(seconds_per_tick, times_fired)

/mob/living/basic/blood_worm/proc/handle_host_blood(seconds_per_tick, times_fired)
	if (host.stat == DEAD)
		host.handle_blood(seconds_per_tick, times_fired)

	// Ignored while possessing a host, as [carbon/proc/bleed_warn] handles it instead.
	if (!is_possessing_host && COOLDOWN_FINISHED(src, host_bleed_alert_cooldown) && host.get_bleed_rate() > 0)
		to_chat_self(span_userdanger("Your host is bleeding!"))
		COOLDOWN_START(src, host_bleed_alert_cooldown, 15 SECONDS)

/mob/living/basic/blood_worm/proc/handle_host_temperature(seconds_per_tick, times_fired)
	if (host.coretemperature <= maximum_survivable_temperature)
		return

	var/burn_coeff = damage_coeff[BURN]
	adjust_worm_health(-unsuitable_heat_damage * (burn_coeff ? burn_coeff : 1) * seconds_per_tick)

	if (COOLDOWN_FINISHED(src, host_heat_alert_cooldown))
		to_chat_self(span_userdanger("Your blood is burning up!"))
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
