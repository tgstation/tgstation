/mob/living/basic/blood_worm
	icon = 'icons/mob/nonhuman-player/blood_worm_32x32.dmi'

	faction = list(FACTION_BLOOD_WORM)

	initial_language_holder = /datum/language_holder/blood_worm

	mob_biotypes = MOB_ORGANIC | MOB_BUG
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

	/// Effect name for stuff like "invade-[effect_name]".
	/// Should correspond to the growth stage, like "adult".
	var/effect_name = ""

	/// How long the leave host animation lasts for this type, in deciseconds.
	var/leave_host_duration = 0

	/// Associative list of how much of each blood type the blood worm has consumed.
	/// The format of this list is "list[blood_type.id] = amount_consumed"
	/// This carries across growth stages.
	var/list/consumed_blood = list()

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

/mob/living/basic/blood_worm/process(seconds_per_tick, times_fired)
	if (!host)
		return

	update_dilution()
	sync_health()

/mob/living/basic/blood_worm/Life(seconds_per_tick, times_fired)
	. = ..()

	if (!host)
		adjustBruteLoss(-regen_rate * seconds_per_tick)
	else
		bodytemperature = T20C

/mob/living/basic/blood_worm/handle_environment(datum/gas_mixture/environment, seconds_per_tick, times_fired)
	if (host)
		bodytemperature = T20C
	else
		return ..()

/mob/living/basic/blood_worm/adjust_health(amount, updating_health, forced)
	return host ? 0 : ..() // Prevents damage from adjustXLoss while in a host, because that damage would be nullified by the next [proc/sync_health] call. Adjust [var/host.blood_volume] instead.

/mob/living/basic/blood_worm/set_stat(new_stat)
	. = ..()

	if (host && stat != CONSCIOUS)
		leave_host()

/mob/living/basic/blood_worm/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()

	if (host && loc != host)
		unregister_host()

/mob/living/basic/blood_worm/examining(atom/target, list/result)
	if (!isliving(target))
		return

	var/mob/living/bloodbag = target

	if (bloodbag.blood_volume <= 0)
		return

	var/datum/blood_type/blood_type = bloodbag.get_bloodtype()

	if (!blood_type)
		return

	var/unscaled_blood = consumed_blood[blood_type.id]
	var/scaled_blood_right_now = get_blood_volume_after_curve(unscaled_blood)
	var/scaled_blood_after_consumption = get_blood_volume_after_curve(unscaled_blood + bloodbag.blood_volume)
	var/potential_gain = scaled_blood_after_consumption - scaled_blood_right_now

	var/rounded_volume = CEILING(bloodbag.blood_volume, 1)
	var/total_consumed_blood = get_scaled_total_consumed_blood()

	var/growth_string = ""
	if (total_consumed_blood < cocoon_action?.total_blood_required)
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

	result += span_notice("[target.p_They()] [target.p_have()] [rounded_volume] unit[rounded_volume == 1 ? "" : "s"] of [blood_type.id] blood[growth_string].")

/mob/living/basic/blood_worm/proc/ingest_blood(blood_amount, blood_type_id, should_heal = TRUE)
	if (!blood_type_id || !blood_amount)
		return

	consumed_blood[blood_type_id] += blood_amount

	if (should_heal)
		adjustBruteLoss(-blood_amount * BLOOD_WORM_BLOOD_TO_HEALTH)

/mob/living/basic/blood_worm/proc/enter_host(mob/living/carbon/human/new_host)
	if (!mind || !key)
		return

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

	START_PROCESSING(SSfastprocess, src)

	add_traits(list(TRAIT_INCAPACITATED, TRAIT_IMMOBILIZED, TRAIT_MUTE), BLOOD_WORM_HOST_TRAIT)

	// The worm handles basic blood oxygenation, circulation and filtration.
	// The controlled host still requires a liver to process chemicals and lungs to speak.
	host.add_traits(list(TRAIT_NOBREATH, TRAIT_STABLEHEART, TRAIT_STABLELIVER, TRAIT_NOCRITDAMAGE, TRAIT_BLOOD_HUD, TRAIT_BLOOD_WORM_HOST), BLOOD_WORM_HOST_TRAIT)
	host.AddElement(/datum/element/hand_organ_insertion)

	remove_actions(src, innate_actions)
	grant_actions(src, host_actions)

	if (host.mind)
		backseat = new(host)
		backseat.death(gibbed = TRUE) // Same thing that the corpse mob spawners do to stop deathgasps and such.

		// If the host is a changeling, then we forcibly move their client to the backseat so they can use Expel Worm if they wish to.
		host.mind.transfer_to(backseat, force_key_move = host.mind.has_antag_datum(/datum/antagonist/changeling))

	ingest_blood(host.blood_volume, host.get_bloodtype(), should_heal = FALSE)

	start_dilution()
	sync_health()

	if (host.hud_used)
		create_host_hud(host)
	else
		RegisterSignal(host, COMSIG_MOB_HUD_CREATED, PROC_REF(create_host_hud))

	forceMove(host)

/mob/living/basic/blood_worm/proc/leave_host()
	if (!host)
		return

	visible_message(
		message = span_bolddanger("\The [src] emerge[p_s()] from \the [host]!"),
		self_message = span_notice("You emerge from \the [host]."),
		blind_message = span_hear("You hear a squelch.")
	)

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

	if (backseat)
		backseat.mind?.transfer_to(host)
		QDEL_NULL(backseat)

	UnregisterSignal(host, list(COMSIG_QDELETING, COMSIG_MOB_STATCHANGE, COMSIG_HUMAN_ON_HANDLE_BLOOD, COMSIG_LIVING_LIFE, COMSIG_MOB_HUD_CREATED))

	STOP_PROCESSING(SSfastprocess, src)

	REMOVE_TRAITS_IN(src, BLOOD_WORM_HOST_TRAIT)
	REMOVE_TRAITS_IN(host, BLOOD_WORM_HOST_TRAIT)
	host.RemoveElement(/datum/element/hand_organ_insertion)

	remove_actions(src, host_actions)
	grant_actions(src, innate_actions)

	update_dilution()
	sync_health()

	remove_host_hud()

	host.blood_volume = 0
	host.death() // I don't care if you have TRAIT_NODEATH, can't die from bloodloss normally, or whatever else. I just need you to die.

	host = null

/mob/living/basic/blood_worm/proc/possess_host()
	if (!host || is_possessing_host)
		return

	is_possessing_host = TRUE

	mind?.transfer_to(host)

	remove_actions(src, host_actions)
	grant_actions(host, host_actions)

	host.grant_language(/datum/language/wormspeak, UNDERSTOOD_LANGUAGE, LANGUAGE_BLOOD_WORM)

/mob/living/basic/blood_worm/proc/possess_worm()
	if (!host || !is_possessing_host)
		return

	is_possessing_host = FALSE

	host.mind?.transfer_to(src)

	remove_actions(host, host_actions)
	grant_actions(src, host_actions)

	host.remove_language(/datum/language/wormspeak, UNDERSTOOD_LANGUAGE, LANGUAGE_BLOOD_WORM)

/mob/living/basic/blood_worm/proc/on_host_qdel(datum/source, force)
	SIGNAL_HANDLER
	qdel(src)

/mob/living/basic/blood_worm/proc/on_host_stat_changed(datum/source, new_stat, old_stat)
	if (old_stat == DEAD && new_stat != DEAD)
		possess_host()
	else if (old_stat != DEAD && new_stat == DEAD)
		possess_worm()

/mob/living/basic/blood_worm/proc/on_host_handle_blood(datum/source, seconds_per_tick, times_fired)
	return HANDLE_BLOOD_NO_OXYLOSS | HANDLE_BLOOD_NO_NUTRITION_DRAIN

/mob/living/basic/blood_worm/proc/on_host_life(datum/source, seconds_per_tick, times_fired)
	host.blood_volume += regen_rate * seconds_per_tick * BLOOD_WORM_HEALTH_TO_BLOOD // Regen beforehand, meaning we can still reach 0 exactly.

	if (!HAS_TRAIT(host, TRAIT_STASIS))
		host.handle_blood(seconds_per_tick, times_fired)
		handle_host_temperature(seconds_per_tick, times_fired)

/mob/living/basic/blood_worm/proc/handle_host_temperature(seconds_per_tick, times_fired)
	if (host.coretemperature <= maximum_survivable_temperature)
		return

	var/burn_coeff = damage_coeff[BURN]
	host.blood_volume = max(0, host.blood_volume - unsuitable_heat_damage * BLOOD_WORM_HEALTH_TO_BLOOD * (burn_coeff ? burn_coeff : 1) * seconds_per_tick)

	if (COOLDOWN_FINISHED(src, host_heat_alert_cooldown))
		to_chat(is_possessing_host ? host : src, span_userdanger("Your blood is burning up!"))
		COOLDOWN_START(src, host_heat_alert_cooldown, 10 SECONDS)

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

/mob/living/basic/blood_worm/get_status_tab_items()
	. = ..()

	var/unscaled = get_unscaled_total_consumed_blood()
	var/scaled = get_scaled_total_consumed_blood()

	var/unscaled_rounded = CEILING(unscaled, 1)
	var/scaled_rounded = CEILING(scaled, 1)

	. += ""
	. += "Blood Consumed: [unscaled_rounded]u[scaled_rounded == unscaled_rounded ? "" : " ([scaled_rounded]u)"]"

	if (cocoon_action?.total_blood_required > 0)
		. += "Growth: [FLOOR(scaled / cocoon_action.total_blood_required * 100, 1)]%"

	if (!length(consumed_blood))
		return

	var/list/efficiency_strings = list()

	for (var/blood_type_id in consumed_blood)
		var/base_amount = consumed_blood[blood_type_id]
		var/efficiency = CEILING(get_blood_volume_after_curve(base_amount) / base_amount * 100, 1)

		if (efficiency < 100)
			efficiency_strings += "[blood_type_id]: [efficiency]%"

	if (!length(efficiency_strings))
		return

	. += ""
	. += "Blood Efficiency"
	for (var/efficiency_string in efficiency_strings)
		. += efficiency_string

/mob/living/basic/blood_worm/proc/get_scaled_total_consumed_blood()
	. = 0
	for (var/blood_type_id in consumed_blood)
		. += get_blood_volume_after_curve(consumed_blood[blood_type_id])

/mob/living/basic/blood_worm/proc/get_unscaled_total_consumed_blood()
	. = 0
	for (var/blood_type_id in consumed_blood)
		. += consumed_blood[blood_type_id]

/// This is why you can't just drain the same dude to reach adulthood in 10 seconds flat.
/mob/living/basic/blood_worm/proc/get_blood_volume_after_curve(initial_volume)
	var/starting_point = BLOOD_VOLUME_NORMAL
	var/maximum_point = starting_point * 2
	var/clamped_volume = clamp(initial_volume, 0, maximum_point)
	var/volume_past_starting_point = max(0, clamped_volume - starting_point)

	// To put this in laymans terms, after you reach BLOOD_VOLUME_NORMAL, any further blood of the same type has a lower and lower effect.
	// This ends after you've consumed BLOOD_VOLUME_NORMAL * 2 of any blood type, after which consuming any more of that type is useless.
	return max(0, clamped_volume - (volume_past_starting_point * volume_past_starting_point) / maximum_point)

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

	mob_size = MOB_SIZE_HUGE

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
