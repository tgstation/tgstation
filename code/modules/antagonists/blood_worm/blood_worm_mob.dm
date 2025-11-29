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

	AddElement(/datum/element/anti_self_harm)

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
	return host ? 0 : ..() // Prevents damage from adjust_x_loss while in a host, because that damage would be nullified by the next [proc/sync_health] call. Adjust host blood volume instead.

/mob/living/basic/blood_worm/set_stat(new_stat)
	. = ..()

	if (host && stat != CONSCIOUS)
		leave_host()

/mob/living/basic/blood_worm/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()

	if (host && loc != host)
		unregister_host()

/// Gets the current health of the worm, regardless of if its in a host or not.
/mob/living/basic/blood_worm/proc/get_worm_health()
	return host ? min(host.get_blood_volume() * BLOOD_WORM_BLOOD_TO_HEALTH, maxHealth) : health

/// Adjusts the current health of the worm, regardless of if its in a host or not.
/mob/living/basic/blood_worm/proc/adjust_worm_health(amount)
	return host ? host.adjust_blood_volume(amount * BLOOD_WORM_HEALTH_TO_BLOOD) * BLOOD_WORM_BLOOD_TO_HEALTH : adjust_brute_loss(-amount)

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
	set_brute_loss(maxHealth * (1 - cached_blood_volume / host_max_blood))

	// Checks if we still have a host since setBruteLoss() can kill us, causing us to leave our host.
	if (!already_ejecting && cached_blood_volume <= get_eject_volume_threshold())
		// Sent before leave_host() for the correct message order in chat
		to_chat_self(span_userdanger("You run out of blood to control your host with!"))

		leave_host()

		// Has to be sent after the forceMove() in leave_host()
		balloon_alert_self("out_of_blood!")

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

	guaranteed_butcher_results = list(/obj/item/food/meat/slab/blood_worm = 1)

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

	AddComponent(/datum/component/slide_under_doors, slide_in_delay = 3 SECONDS)

/mob/living/basic/blood_worm/juvenile
	name = "juvenile blood worm"
	desc = "A mid-sized blood worm. It looks bloodthirsty and has numerous long and extremely sharp teeth."

	icon_state = "juvenile"
	icon_living = "juvenile"
	icon_dead = "juvenile-dead"

	mob_size = MOB_SIZE_SMALL

	guaranteed_butcher_results = list(/obj/item/food/meat/slab/blood_worm = 2)

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

/mob/living/basic/blood_worm/juvenile/Initialize(mapload)
	. = ..()

	AddComponent(/datum/component/slide_under_doors, slide_in_delay = 5 SECONDS)

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

	guaranteed_butcher_results = list(/obj/item/food/meat/slab/blood_worm = 3)

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
