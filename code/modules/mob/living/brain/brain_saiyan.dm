#define GOKU_FILTER "goku_filter"

/// The Saiyan brain contains knowledge of powerful martial arts
/obj/item/organ/internal/brain/saiyan
	name = "saiyan brain"
	desc = "The brain of a mighty saiyan warrior. Guess they don't work out at the library..."
	brain_size = 0.5
	/// What buttons did we give out
	var/list/granted_abilities = list()

/obj/item/organ/internal/brain/saiyan/on_mob_insert(mob/living/carbon/organ_owner, special, movement_flags)
	. = ..()
	var/datum/action/cooldown/mob_cooldown/ki_blast/blast = new(organ_owner)
	blast.Grant(organ_owner)
	granted_abilities += blast

	var/datum/action/cooldown/mob_cooldown/saiyan_flight/flight = new(organ_owner)
	flight.Grant(organ_owner)
	granted_abilities += flight

/obj/item/organ/internal/brain/saiyan/on_mob_remove(mob/living/carbon/organ_owner, special)
	. = ..()
	QDEL_LIST(granted_abilities)

/// Shoot power from your hands, wow
/datum/action/cooldown/mob_cooldown/ki_blast
	name = "Ki Blast"
	desc = "Channel your ki into your hands and out into the world as rapid projectiles. Drains your fighting spirit."
	button_icon = 'icons/obj/weapons/guns/projectiles.dmi'
	button_icon_state = "pulse1"
	background_icon_state = "bg_demon"
	click_to_activate = FALSE
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_INCAPACITATED|AB_CHECK_HANDS_BLOCKED
	shared_cooldown = NONE
	melee_cooldown_time = 0 SECONDS
	/// Extra damage to do
	var/damage_modifier = 1

/datum/action/cooldown/mob_cooldown/ki_blast/Activate(atom/target)
	var/mob/living/mob_caster = target
	if (!istype(mob_caster))
		return FALSE
	var/obj/item/gun/ki_blast/ki_gun = new(mob_caster.loc)
	ki_gun.projectile_damage_multiplier = damage_modifier
	if (!mob_caster.put_in_hands(ki_gun, del_on_fail = TRUE))
		mob_caster.balloon_alert(mob_caster, "no free hands!")
	return TRUE

/obj/item/gun/ki_blast
	name = "concentrated ki"
	desc = "The power of your lifeforce converted into a deadly weapon. Fire it at someone."
	fire_sound = 'sound/magic/wand_teleport.ogg'
	icon = 'icons/obj/weapons/guns/projectiles.dmi'
	icon_state = "pulse1"
	inhand_icon_state = "arcane_barrage"
	base_icon_state = "arcane_barrage"
	lefthand_file = 'icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/guns_righthand.dmi'
	slot_flags = null
	item_flags = NEEDS_PERMIT | DROPDEL | ABSTRACT | NOBLUDGEON
	flags_1 = NONE
	trigger_guard = TRIGGER_GUARD_ALLOW_ALL

/obj/item/gun/ki_blast/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/automatic_fire, 0.15 SECONDS)
	chambered = new /obj/item/ammo_casing/ki(src)

/obj/item/gun/ki_blast/process_fire(atom/target, mob/living/user, message, params, zone_override, bonus_spread)
	. = ..()
	if (!.)
		return FALSE
	user.apply_damage(3, STAMINA)
	return TRUE

/obj/item/gun/ki_blast/handle_chamber(empty_chamber, from_firing, chamber_next_round)
	chambered.newshot()

/obj/item/ammo_casing/ki
	slot_flags = null
	projectile_type = /obj/projectile/ki
	firing_effect_type = /obj/effect/temp_visual/dir_setting/firing_effect/blue

/obj/projectile/ki
	name = "ki blast"
	icon_state = "pulse1_bl"
	damage = 3
	damage_type = BRUTE
	hitsound = 'sound/weapons/sear_disabler.ogg'
	hitsound_wall = 'sound/weapons/sear_disabler.ogg'

/// Saiyans can fly
/datum/action/cooldown/mob_cooldown/saiyan_flight
	name = "Flight"
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "flight"
	background_icon_state = "bg_demon"
	desc = "Focus your energy and lift into the air, or alternately stop doing that if you are doing it already."
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_IMMOBILE|AB_CHECK_INCAPACITATED|AB_CHECK_LYING
	click_to_activate = FALSE
	cooldown_time = 3 SECONDS
	shared_cooldown = NONE
	melee_cooldown_time = 0 SECONDS

/datum/action/cooldown/mob_cooldown/saiyan_flight/Activate(atom/target)
	var/mob/living/mob_caster = target
	if (!istype(mob_caster))
		return FALSE

	StartCooldown()
	if(!HAS_TRAIT_FROM(mob_caster, TRAIT_MOVE_FLYING, REF(src)))
		mob_caster.balloon_alert(mob_caster, "flying")
		ADD_TRAIT(mob_caster, TRAIT_MOVE_FLYING, REF(src))
		passtable_on(mob_caster, REF(src))
		return TRUE

	mob_caster.balloon_alert(mob_caster, "landed")
	REMOVE_TRAIT(mob_caster, TRAIT_MOVE_FLYING, REF(src))
	passtable_off(mob_caster, REF(src))
	return TRUE


/// Charge up a big beam
/datum/action/cooldown/mob_cooldown/brimbeam/kamehameha
	name = "Kamehameha"
	desc = "The signature technique of the turtle school, a devastating charged beam attack!"
	button_icon = 'icons/effects/saiyan_effects.dmi'
	button_icon_state = "kamehameha_start"
	created_type = /obj/effect/brimbeam/kamehameha
	charge_duration = 5 SECONDS
	beam_duration = 12 SECONDS
	cooldown_time = 90 SECONDS
	shared_cooldown = NONE
	melee_cooldown_time = 0 SECONDS
	/// Things we still need to say, before it's too late
	var/speech_timers = list()

/datum/action/cooldown/mob_cooldown/brimbeam/kamehameha/Activate(atom/target)
	owner.add_filter(GOKU_FILTER, 2, list("type" = "outline", "color" = COLOR_CYAN, "alpha" = 0, "size" = 1))
	var/filter = owner.get_filter(GOKU_FILTER)
	animate(filter, alpha = 200, time = 0.5 SECONDS, loop = -1)
	animate(alpha = 0, time = 0.5 SECONDS)
	owner.say("Ka...")
	var/queued_speech = list("...me...", "...ha...", "...me...")
	var/speech_interval = charge_duration/4
	var/current_interval = speech_interval
	while(length(queued_speech))
		var/timer = addtimer(CALLBACK(owner, TYPE_PROC_REF(/atom/movable, say), pop(queued_speech)), current_interval, TIMER_STOPPABLE | TIMER_DELETE_ME)
		current_interval += speech_interval
		speech_timers += timer
	playsound(owner, 'sound/items/modsuit/loader_charge.ogg', 75, TRUE)
	return ..()

/datum/action/cooldown/mob_cooldown/brimbeam/kamehameha/fire_laser()
	. = ..()
	if (.)
		owner.say("...HA!!!!!")

/datum/action/cooldown/mob_cooldown/brimbeam/kamehameha/StartCooldown(override_cooldown_time, override_melee_cooldown_time)
	. = ..()
	if (override_cooldown_time == 360 SECONDS) // Ignore the one we set while the ability is processing
		return
	for (var/timer as anything in speech_timers)
		deltimer(timer)
	speech_timers = list()
	var/filter = owner.get_filter(GOKU_FILTER)
	animate(filter)
	owner.remove_filter(GOKU_FILTER)

/datum/action/cooldown/mob_cooldown/brimbeam/kamehameha/on_fail()
	owner.visible_message(span_notice("...and launches it straight into a wall, wasting their energy."))

/// It's blue now!
/obj/effect/brimbeam/kamehameha
	name = "kamehameha"
	light_color = LIGHT_COLOR_CYAN
	icon = 'icons/effects/saiyan_effects.dmi'
	icon_state = "kamehameha"
	base_icon_state = "kamehameha"

/// Blinds people
/datum/action/cooldown/mob_cooldown/watcher_gaze/solar_flare
	name = "Solar Flare"
	desc = "A surprising move of the Crane school, creating a blinding flash that can overpower even shaded glasses. Useful on opponents regardless of power level."
	wait_delay = 1 SECONDS
	report_started = "holds their hands to their forehead!"
	blinded_source = "flash of light!"

/datum/action/cooldown/mob_cooldown/watcher_gaze/solar_flare/trigger_effect()
	. = ..()
	owner.say("Solar flare!!")

/// Makes you stronger and stacks too. But watch out!
/datum/action/cooldown/mob_cooldown/kaioken
	name = "Kaio-ken Technique"
	desc = "A technique taught by the powerful Kais of Otherworld, allows the user to multiply their ki at great personal risk. The effects can be stacked multiplicatively to greatly increase fighting strength, however overuse may cause immediate disintegration."
	button_icon = 'icons/mob/actions/actions_cult.dmi'
	button_icon_state = "tele"
	background_icon_state = "bg_demon"
	cooldown_time = 3 SECONDS
	shared_cooldown = NONE
	melee_cooldown_time = NONE
	click_to_activate = FALSE

// This is basically handled entirely by the status effect
/datum/action/cooldown/mob_cooldown/kaioken/Activate(mob/living/target)
	target.apply_status_effect(/datum/status_effect/stacking/kaioken, 1)
	StartCooldown()
	return TRUE

/datum/status_effect/stacking/kaioken
	id = "kaioken"
	stacks = 0
	max_stacks = INFINITY // but good luck
	consumed_on_threshold = FALSE
	alert_type = null
	status_type = STATUS_EFFECT_REFRESH // Allows us to add one stack at a time by just applying the effect
	duration = 10 SECONDS
	stack_decay = 0
	/// How much strength to add every time?
	var/power_multiplier = 3
	/// Percentage chance to die instantly, will be multiplied by current stacks
	var/death_chance = 5

/datum/status_effect/stacking/kaioken/on_apply()
	. = ..()
	owner.add_filter(GOKU_FILTER, 2, list("type" = "outline", "color" = COLOR_RED, "alpha" = 0, "size" = 1))
	var/filter = owner.get_filter(GOKU_FILTER)
	animate(filter, alpha = 200, time = 0.5 SECONDS, loop = -1)
	animate(alpha = 0, time = 0.5 SECONDS)

/datum/status_effect/stacking/kaioken/on_remove()
	var/filter = owner.get_filter(GOKU_FILTER)
	animate(filter)
	owner.remove_filter(GOKU_FILTER)
	owner.saiyan_boost(-power_multiplier * stacks)
	return ..()

/datum/status_effect/stacking/kaioken/refresh(effect, stacks_to_add)
	. = ..()
	add_stacks(stacks_to_add)

/datum/status_effect/stacking/kaioken/add_stacks(stacks_added)
	if (stacks_added == 0)
		return
	. = ..()
	if (stacks == 0)
		return
	if (prob((stacks - 1) * death_chance))
		owner.say("Kaio-AARGH!!")
		owner.visible_message(span_boldwarning("[owner] vanishes in an intense flash of light!"))
		owner.ghostize(can_reenter_corpse = FALSE)
		owner.dust()
		return
	owner.saiyan_boost(power_multiplier)
	if (stacks == 1)
		owner.say("Kaio-ken!")
		return
	var/exclamations = ""
	for (var/i in 1 to stacks)
		exclamations += "!"
	owner.say("Kaio-ken... times [convert_integer_to_words(stacks)][exclamations]")

/// Achieve the legend
/datum/action/cooldown/mob_cooldown/super_saiyan
	name = "Power Up"
	desc = "Concentrate your energy, surpass your limits, and go even further beyond!"
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "sacredflame"
	background_icon_state = "bg_demon"
	cooldown_time = 4 MINUTES
	cooldown_rounding = 0
	shared_cooldown = NONE
	melee_cooldown_time = NONE
	click_to_activate = FALSE
	/// How long does it take to assume your next form?
	var/charge_time = 30 SECONDS
	/// Storage for our scream timer
	var/yell_timer

/datum/action/cooldown/mob_cooldown/super_saiyan/Activate(mob/living/target)
	StartCooldown(360 SECONDS)

	target.add_filter(GOKU_FILTER, 2, list("type" = "outline", "color" = COLOR_VIVID_YELLOW, "alpha" = 0, "size" = 1))
	var/filter = target.get_filter(GOKU_FILTER)
	animate(filter, alpha = 200, time = 0.5 SECONDS, loop = -1)
	animate(alpha = 0, time = 0.5 SECONDS)
	yell()

	owner.balloon_alert(owner, "charging...")
	var/succeeded = do_after(target, delay = charge_time, target = target)

	deltimer(yell_timer)
	animate(filter)
	target.remove_filter(GOKU_FILTER)

	if (succeeded)
		charge_time = max(6 SECONDS, charge_time - 2 SECONDS)
		target.apply_status_effect(/datum/status_effect/super_saiyan)
		StartCooldown()
		return TRUE
	StartCooldown(10 SECONDS)
	return TRUE

/// Aaaaaaa Aaaaaaaa aaaaaa AAAAAAAa a AaAAAAAA aAAAAAAAAAAAAAAAAAAAAAAA!!!!
/datum/action/cooldown/mob_cooldown/super_saiyan/proc/yell()
	owner.emote("scream")
	yell_timer = addtimer(CALLBACK(src, PROC_REF(yell)), rand(1 SECONDS, 3 SECONDS), TIMER_DELETE_ME | TIMER_STOPPABLE)

/datum/status_effect/super_saiyan
	id = "super_saiyan"
	alert_type = null
	duration = 45 SECONDS
	/// How much strength do we gain?
	var/power_multiplier = 8

/datum/status_effect/super_saiyan/on_apply()
	. = ..()
	to_chat(owner, span_notice("Your power surges!"))

	new /obj/effect/temp_visual/explosion/fast(get_turf(owner))

	owner.add_filter(GOKU_FILTER, 2, list("type" = "outline", "color" = COLOR_VIVID_YELLOW, "alpha" = 0, "size" = 2.5))
	var/filter = owner.get_filter(GOKU_FILTER)
	animate(filter, alpha = 200, time = 0.25 SECONDS, loop = -1)
	animate(alpha = 0, time = 0.25 SECONDS)
	owner.saiyan_boost(multiplier = power_multiplier)

	playsound(owner, 'sound/magic/charge.ogg', vol = 80)

	var/list/destroy_turfs = circle_range_turfs(center = owner, radius = 2)
	for (var/turf/check_turf as anything in destroy_turfs)
		if (!isfloorturf(check_turf) || isindestructiblefloor(check_turf))
			continue
		if (prob(75))
			continue
		check_turf.break_tile()

	var/transform_area = get_area(owner)
	for(var/mob/living/player as anything in GLOB.alive_player_list)
		if (player == owner || !HAS_TRAIT(player, TRAIT_MARTIAL_VISION))
			continue
		to_chat(player, span_warning("You sense an incredible power level coming from the direction of the [transform_area]!"))

/datum/status_effect/super_saiyan/on_remove()
	. = ..()
	var/filter = owner.get_filter(GOKU_FILTER)
	animate(filter)
	owner.remove_filter(GOKU_FILTER)
	owner.saiyan_boost(multiplier = -power_multiplier)

#undef GOKU_FILTER
