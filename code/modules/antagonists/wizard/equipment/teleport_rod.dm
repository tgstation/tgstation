/// Totally NOT a Rod of Discord
/// Teleports you to where you click!
/obj/item/teleport_rod
	name = "Telegram Scepter"
	desc = "A magical rod that teleports you to the location you point it. \
		Using it puts you in a state of flux, removing some of your reagents and \
		causing you to take damage from further uses until you stabilize once more."
	icon_state = "tele_wand_er"
	inhand_icon_state = "tele_wand_er"
	icon = 'icons/obj/weapons/guns/magic.dmi'
	lefthand_file = 'icons/mob/inhands/weapons/staves_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/staves_righthand.dmi'
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF | UNACIDABLE
	item_flags = NOBLUDGEON
	light_system = OVERLAY_LIGHT
	light_color = COLOR_FADED_PINK
	light_power = 1
	light_range = 2
	light_on = TRUE
	/// Whether we apply the teleport flux debuff, damaging people who teleport
	var/apply_debuffs = TRUE
	/// Max range at which we can teleport, because it operates in view TECHNICALLY can click very very far
	var/max_tp_range = 8

/obj/item/teleport_rod/Initialize(mapload)
	. = ..()
	particles = new /particles/teleport_flux/small()

// Admin only version which just teleports you, so spam it all you want
/obj/item/teleport_rod/admin
	name = "Harmonious " + parent_type::name
	desc = "A magical rod that teleports you anywhere, no questions asked."
	apply_debuffs = FALSE
	max_tp_range = INFINITY

/obj/item/teleport_rod/equipped(mob/living/user, slot, initial)
	. = ..()
	if(!isliving(user))
		return
	if(HAS_MIND_TRAIT(user, TRAIT_MAGICALLY_GIFTED))
		return
	if(!(slot & ITEM_SLOT_HANDS))
		return
	if(!apply_debuffs)
		return
	user.apply_status_effect(/datum/status_effect/teleport_flux/perma)

/obj/item/teleport_rod/dropped(mob/living/user, silent)
	. = ..()
	if(!isliving(user))
		return
	if(HAS_MIND_TRAIT(user, TRAIT_MAGICALLY_GIFTED))
		return

	var/datum/status_effect/teleport_flux/perma/permaflux = user.has_status_effect(/datum/status_effect/teleport_flux/perma)
	permaflux?.delayed_remove(src)

/obj/item/teleport_rod/ranged_interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	. = ITEM_INTERACT_BLOCKING
	var/turf/start_turf = get_turf(user)
	var/turf/target_turf = get_turf(interacting_with)
	if(get_dist(start_turf, target_turf) > max_tp_range)
		user.balloon_alert(user, "too far!")
		return .

	if(!(target_turf in view(user, user.client?.view || world.view)))
		user.balloon_alert(user, "out of view!")
		return .

	if(target_turf.is_blocked_turf(exclude_mobs = TRUE, source_atom = user))
		user.balloon_alert(user, "obstructed!")
		return .

	var/tp_result = do_teleport(
		teleatom = user,
		destination = target_turf,
		precision = (HAS_MIND_TRAIT(user, TRAIT_MAGICALLY_GIFTED) || !apply_debuffs) ? 0 : 2,
		no_effects = TRUE,
		channel = TELEPORT_CHANNEL_MAGIC,
	)

	if(!tp_result)
		user.balloon_alert(user, "teleport failed!")
		return .

	. = ITEM_INTERACT_SUCCESS

	var/sound/teleport_sound = sound('sound/effects/magic/summonitems_generic.ogg')
	teleport_sound.pitch = 0.5
	// Handle our own pizzaz rather than doing it in do_teleport
	new /obj/effect/temp_visual/teleport_flux(start_turf, user.dir)
	new /obj/effect/temp_visual/teleport_flux(get_turf(user), user.dir)
	playsound(start_turf, teleport_sound, 90, extrarange = MEDIUM_RANGE_SOUND_EXTRARANGE)
	playsound(user, teleport_sound, 90, extrarange = MEDIUM_RANGE_SOUND_EXTRARANGE)
	// Some extra delay to prevent accidental double clicks
	user.changeNext_move(CLICK_CD_SLOW * 1.2)

	if(!apply_debuffs)
		return .

	// Teleporting leaves some of your reagents behind!
	// (Primarily a way to prevent cheese with damage healing chem mixes,
	// but also serves as a counter-counter to stuff like mute toxin.)
	var/obj/item/organ/user_stomach = user.get_organ_slot(ORGAN_SLOT_STOMACH)
	user.reagents?.remove_all(0.33, relative = TRUE)
	user_stomach?.reagents?.remove_all(0.33, relative = TRUE)
	if(user.has_status_effect(/datum/status_effect/teleport_flux/perma))
		return .

	if(user.has_status_effect(/datum/status_effect/teleport_flux))
		// The status effect handles the damage, but we'll add a special pop up for rod usage specifically
		user.balloon_alert(user, "too soon!")

	user.apply_status_effect(/datum/status_effect/teleport_flux)
	return .

/// Temp visual displayed on both sides of a teleport rod teleport
/obj/effect/temp_visual/teleport_flux
	icon_state = "blank_white"
	color = COLOR_MAGENTA
	alpha = 255
	duration = 2 SECONDS
	light_color = COLOR_MAGENTA
	light_power = 2
	light_range = 1
	light_on = TRUE
	randomdir = FALSE

/obj/effect/temp_visual/teleport_flux/Initialize(mapload, copy_dir = SOUTH)
	. = ..()
	setDir(copy_dir)
	particles = new /particles/teleport_flux()
	apply_wibbly_filters(src)
	animate(src, alpha = 0, time = duration, flags = ANIMATION_PARALLEL)

/// Status effect applied to users of a Teleport Rod, damages them when they teleport
/datum/status_effect/teleport_flux
	id = "teleport_flux"
	status_type = STATUS_EFFECT_REFRESH
	duration = 6 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/teleport_flux
	remove_on_fullheal = TRUE // staff of healing ~synergy~
	show_duration = TRUE

	/// Amount of damage to deal when teleporting in flux
	var/tp_damage = 15
	/// Damage type to deal when teleporting in flux
	var/tp_damage_type = BRUTE

/datum/status_effect/teleport_flux/on_apply()
	RegisterSignal(owner, COMSIG_MOVABLE_POST_TELEPORT, PROC_REF(teleported))
	return TRUE

/datum/status_effect/teleport_flux/on_remove()
	UnregisterSignal(owner, COMSIG_MOVABLE_POST_TELEPORT)

/datum/status_effect/teleport_flux/proc/teleported(mob/living/source, turf/destination, channel)
	SIGNAL_HANDLER

	if(channel != TELEPORT_CHANNEL_MAGIC)
		return

	owner.apply_damage(
		damage = tp_damage,
		damagetype = tp_damage_type,
		spread_damage = TRUE,
		forced = TRUE,
	)
	log_combat(owner, owner, "teleported too soon")

/datum/status_effect/teleport_flux/update_particles()
	if(isnull(particle_effect))
		particle_effect = new(owner, /particles/teleport_flux)

	particle_effect.alpha = 200
	var/original_duration = initial(duration)
	if(original_duration == -1)
		return
	animate(particle_effect, alpha = 50, time = original_duration)

/datum/status_effect/teleport_flux/refresh(effect, ...)
	. = ..()
	update_particles()

/datum/status_effect/teleport_flux/perma
	id = "perma_teleport_flux"
	status_type = STATUS_EFFECT_REPLACE
	duration = -1
	alert_type = /atom/movable/screen/alert/status_effect/teleport_flux/perma
	remove_on_fullheal = FALSE

/datum/status_effect/teleport_flux/perma/on_apply()
	. = ..()
	RegisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_MAGICALLY_GIFTED), PROC_REF(gained_gift))

/datum/status_effect/teleport_flux/perma/on_remove()
	. = ..()
	UnregisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_MAGICALLY_GIFTED))

/datum/status_effect/teleport_flux/perma/proc/gained_gift(mob/living/source, trait)
	SIGNAL_HANDLER

	delayed_remove()

/// Used to fade out the effect and remove it after a delay
/// This cannot be interrupted, but if a new permaflux effect is applied,
/// this one will be deleted instantly anyways, making it moot
/datum/status_effect/teleport_flux/perma/proc/delayed_remove()
	var/del_duration = /datum/status_effect/teleport_flux::duration
	QDEL_IN(src, del_duration)
	animate(particle_effect, alpha = 50, del_duration)

/// Alert for the Teleport Flux status effect
/atom/movable/screen/alert/status_effect/teleport_flux
	name = "Teleport Flux"
	desc = "Your body exists in a state of flux, making further teleportation dangerous."
	icon_state = "flux"

/atom/movable/screen/alert/status_effect/teleport_flux/perma
	name = "Permanent " + parent_type::name
	desc = "Your lack of magical talent has left you in a state of flux, making further teleportation dangerous."

/// Particles for Teleport Flux and other similar effects
/particles/teleport_flux
	icon = 'icons/effects/particles/echo.dmi'
	icon_state = list("echo1" = 3, "echo2" = 1, "echo3" = 1)
	width = 40
	height = 80
	count = 1000
	spawning = 3
	lifespan = 1 SECONDS
	fade = 1 SECONDS
	friction = 0.5
	position = generator(GEN_SPHERE, 12, 12, NORMAL_RAND)
	drift = generator(GEN_VECTOR, list(-1, 1), list(1, 1), NORMAL_RAND)
	color = COLOR_MAGENTA

/particles/teleport_flux/small
	spawning = 1.5
	scale = 0.75
	lifespan = 0.5 SECONDS
	position = generator(GEN_SPHERE, 4, 12, NORMAL_RAND)
	drift = generator(GEN_VECTOR, list(-1, 1), list(1, 2), NORMAL_RAND)
