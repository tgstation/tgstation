/// Quick-moving mob which can teleport things to a beacon and heal its allies
/mob/living/basic/guardian/support
	guardian_type = GUARDIAN_SUPPORT
	speed = 0
	damage_coeff = list(BRUTE = 0.7, BURN = 0.7, TOX = 0.7, STAMINA = 0, OXY = 0.7)
	melee_damage_lower = 15
	melee_damage_upper = 15
	playstyle_string = span_holoparasite("As a <b>support</b> type, you may right-click to heal targets. In addition, alt-clicking on an adjacent object or mob will warp them to your bluespace beacon after a short delay.")
	creator_name = "Support"
	creator_desc = "Does medium damage, but can heal its targets and create beacons to teleport people and things to."
	creator_icon = "support"
	/// Amount of each damage type to heal per hit
	var/healing_amount = 5

/mob/living/basic/guardian/support/Initialize(mapload, datum/guardian_fluff/theme)
	. = ..()
	AddComponent(\
		/datum/component/healing_touch,\
		heal_brute = healing_amount,\
		heal_burn = healing_amount,\
		heal_tox = healing_amount,\
		heal_oxy = healing_amount,\
		heal_time = 0,\
		action_text = "",\
		complete_text = "",\
		required_modifier = RIGHT_CLICK,\
		after_healed = CALLBACK(src, PROC_REF(after_healed)),\
	)

	var/datum/atom_hud/medsensor = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	medsensor.show_to(src)

	var/datum/action/cooldown/mob_cooldown/guardian_bluespace_beacon/teleport = new(src)
	teleport.Grant(src)

/mob/living/basic/guardian/support/set_guardian_colour(colour)
	. = ..()
	AddComponent(/datum/component/healing_touch, heal_color = guardian_colour)

/// Called after we heal someone, show some visuals
/mob/living/basic/guardian/support/proc/after_healed(mob/living/healed)
	do_attack_animation(healed, ATTACK_EFFECT_PUNCH)
	healed.visible_message(
		message = span_notice("[src] heals [healed]!"),
		self_message = span_userdanger("[src] heals you!"),
		vision_distance = COMBAT_MESSAGE_RANGE,
		ignored_mobs = src,
	)
	to_chat(src, span_notice("You heal [healed]!"))
	playsound(healed, attack_sound, 50, TRUE, TRUE, frequency = -1) // play punch sound in REVERSE


/// Place a beacon and then listen for clicks to teleport people to it
/datum/action/cooldown/mob_cooldown/guardian_bluespace_beacon
	name = "Place Bluespace Beacon"
	desc = "Mark the ground under your feet as a teleportation point. Alt-click things to teleport them to your beacon."
	button_icon = 'icons/effects/effects.dmi'
	button_icon_state = "the_freezer"
	background_icon = 'icons/hud/guardian.dmi'
	background_icon_state = "base"
	cooldown_time = 5 MINUTES
	melee_cooldown_time = 0
	cooldown_rounding = 1
	click_to_activate = FALSE
	/// Our teleportation beacon.
	var/obj/structure/guardian_beacon/beacon
	/// Time it takes to teleport something.
	var/teleport_time = 6 SECONDS

/datum/action/cooldown/mob_cooldown/guardian_bluespace_beacon/Grant(mob/granted_to)
	. = ..()
	RegisterSignal(owner, COMSIG_MOB_ALTCLICKON, PROC_REF(try_teleporting))

/datum/action/cooldown/mob_cooldown/guardian_bluespace_beacon/Remove(mob/removed_from)
	UnregisterSignal(owner, COMSIG_MOB_ALTCLICKON)
	return ..()

/datum/action/cooldown/mob_cooldown/guardian_bluespace_beacon/Activate(atom/movable/target)
	var/turf/beacon_loc = owner.loc
	if(!isfloorturf(beacon_loc))
		owner.balloon_alert(owner, "no room!")
		return FALSE

	if (!isnull(beacon))
		beacon.visible_message("[beacon] vanishes!")
		new /obj/effect/temp_visual/guardian/phase/out(beacon.loc)
		qdel(beacon)

	beacon = new(beacon_loc, src)
	if (isguardian(owner))
		var/mob/living/basic/guardian/guardian_owner = owner
		beacon.add_atom_colour(guardian_owner.guardian_colour, FIXED_COLOUR_PRIORITY)
	RegisterSignal(beacon, COMSIG_QDELETING, PROC_REF(on_beacon_deleted))
	to_chat(src, span_bolddanger("Beacon placed! You may now warp targets and objects to it, including your user, via Alt+Click."))
	StartCooldown()
	return TRUE

/// Don't hold a reference to a deleted beacon
/datum/action/cooldown/mob_cooldown/guardian_bluespace_beacon/proc/on_beacon_deleted()
	SIGNAL_HANDLER
	beacon = null

/// Try and teleport something to our beacon
/datum/action/cooldown/mob_cooldown/guardian_bluespace_beacon/proc/try_teleporting(mob/living/source, atom/target)
	SIGNAL_HANDLER

	if (!can_teleport(source, target))
		return

	INVOKE_ASYNC(src, PROC_REF(perform_teleport), source, target)
	return COMSIG_MOB_CANCEL_CLICKON

/// Validate whether we can teleport this object
/datum/action/cooldown/mob_cooldown/guardian_bluespace_beacon/proc/can_teleport(mob/living/source, atom/movable/target)
	if (isnull(beacon))
		source.balloon_alert(source, "no beacon!")
		return FALSE
	if (isguardian(source))
		var/mob/living/basic/guardian/guardian_mob = source
		if (!guardian_mob.is_deployed())
			source.balloon_alert(source, "manifest yourself!")
			return FALSE
	if (!source.can_perform_action(target))
		target.balloon_alert(source, "too far!")
		return FALSE
	if (target.anchored)
		target.balloon_alert(source, "it won't budge!")
		return FALSE
	if(beacon.z != target.z)
		target.balloon_alert(source, "too far from beacon!")
		return FALSE
	return TRUE

/// Start teleporting
/datum/action/cooldown/mob_cooldown/guardian_bluespace_beacon/proc/perform_teleport(mob/living/source, atom/target)
	source.do_attack_animation(target)
	playsound(target, 'sound/items/weapons/punch1.ogg', 50, TRUE, TRUE, frequency = -1)
	source.balloon_alert(source, "teleporting...")
	target.visible_message(
		span_danger("[target] starts to glow faintly!"), \
		span_userdanger("You start to faintly glow, and you feel strangely weightless!"))
	if(!do_after(source, teleport_time, target))
		return
	new /obj/effect/temp_visual/guardian/phase/out(target.loc)
	if(isliving(target))
		var/mob/living/living_target = target
		living_target.flash_act()
	target.visible_message(
		span_danger("[target] disappears in a flash of light!"), \
		span_userdanger("Your vision is obscured by a flash of light!"), \
	)
	do_teleport(target, beacon, precision = 0, channel = TELEPORT_CHANNEL_BLUESPACE)
	new /obj/effect/temp_visual/guardian/phase(get_turf(target))


/// Structure which acts as the landing point for a support guardian's teleportation effects
/obj/structure/guardian_beacon
	name = "guardian beacon"
	icon = 'icons/turf/floors.dmi'
	desc = "A glowing zone which acts as a beacon for teleportation."
	icon_state = "light_on-8"
	light_range = MINIMUM_USEFUL_LIGHT_RANGE
	density = FALSE
	anchored = TRUE
	plane = FLOOR_PLANE
	layer = ABOVE_OPEN_TURF_LAYER
