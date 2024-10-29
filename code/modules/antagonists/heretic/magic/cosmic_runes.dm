/datum/action/cooldown/spell/cosmic_rune
	name = "Cosmic Rune"
	desc = "Creates a cosmic rune at your position, only two can exist at a time. Invoking one rune transports you to the other. \
		Anyone with a star mark gets transported along with you."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "cosmic_rune"

	sound = 'sound/effects/magic/forcewall.ogg'
	school = SCHOOL_FORBIDDEN
	cooldown_time = 15 SECONDS

	invocation = "ST'R R'N'"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	/// Storage for the first rune.
	var/datum/weakref/first_rune
	/// Storage for the second rune.
	var/datum/weakref/second_rune
	/// Rune removal effect.
	var/obj/effect/rune_remove_effect = /obj/effect/temp_visual/cosmic_rune_fade

/datum/action/cooldown/spell/cosmic_rune/cast(atom/cast_on)
	. = ..()
	var/obj/effect/cosmic_rune/first_rune_resolved = first_rune?.resolve()
	var/obj/effect/cosmic_rune/second_rune_resolved = second_rune?.resolve()
	if(first_rune_resolved && second_rune_resolved)
		var/obj/effect/cosmic_rune/new_rune = new /obj/effect/cosmic_rune(get_turf(cast_on))
		new rune_remove_effect(get_turf(first_rune_resolved))
		QDEL_NULL(first_rune_resolved)
		first_rune = WEAKREF(second_rune_resolved)
		second_rune = WEAKREF(new_rune)
		second_rune_resolved.link_rune(new_rune)
		new_rune.link_rune(second_rune_resolved)
		return
	if(!first_rune_resolved)
		first_rune = make_new_rune(get_turf(cast_on), second_rune_resolved)
		return
	if(!second_rune_resolved)
		second_rune = make_new_rune(get_turf(cast_on), first_rune_resolved)

/// Returns a weak reference to a new rune, linked to an existing rune if provided
/datum/action/cooldown/spell/cosmic_rune/proc/make_new_rune(turf/target_turf, obj/effect/cosmic_rune/other_rune)
	var/obj/effect/cosmic_rune/new_rune = new /obj/effect/cosmic_rune(target_turf)
	if(other_rune)
		other_rune.link_rune(new_rune)
		new_rune.link_rune(other_rune)
	return WEAKREF(new_rune)

/// A rune that allows you to teleport to the location of a linked rune.
/obj/effect/cosmic_rune
	name = "cosmic rune"
	desc = "A strange rune, that can instantly transport people to another location."
	anchored = TRUE
	icon = 'icons/obj/service/hand_of_god_structures.dmi'
	icon_state = "cosmic_rune"
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	plane = FLOOR_PLANE
	layer = RUNE_LAYER
	/// The other rune this rune is linked with
	var/datum/weakref/linked_rune
	/// Effect for when someone teleports
	var/obj/effect/rune_effect = /obj/effect/temp_visual/rune_light

/obj/effect/cosmic_rune/Initialize(mapload)
	. = ..()
	var/image/silicon_image = image(icon = 'icons/obj/service/hand_of_god_structures.dmi', icon_state = null, loc = src)
	silicon_image.override = TRUE
	add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/silicons, "cosmic", silicon_image)

/obj/effect/cosmic_rune/attack_paw(mob/living/user, list/modifiers)
	return attack_hand(user, modifiers)

/obj/effect/cosmic_rune/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(!linked_rune)
		balloon_alert(user, "no linked rune!")
		fail_invoke()
		return
	if(!(user in get_turf(src)))
		balloon_alert(user, "not close enough!")
		fail_invoke()
		return
	if(user.has_status_effect(/datum/status_effect/star_mark))
		balloon_alert(user, "blocked by star mark!")
		fail_invoke()
		return
	invoke(user)

/// For invoking the rune
/obj/effect/cosmic_rune/proc/invoke(mob/living/user)
	var/obj/effect/cosmic_rune/linked_rune_resolved = linked_rune?.resolve()
	new rune_effect(get_turf(src))
	do_teleport(
		user,
		get_turf(linked_rune_resolved),
		no_effects = TRUE,
		channel = TELEPORT_CHANNEL_MAGIC,
		asoundin = 'sound/effects/magic/cosmic_energy.ogg',
		asoundout = 'sound/effects/magic/cosmic_energy.ogg',
	)
	for(var/mob/living/person_on_rune in get_turf(src))
		if(person_on_rune.has_status_effect(/datum/status_effect/star_mark))
			do_teleport(person_on_rune, get_turf(linked_rune_resolved), no_effects = TRUE, channel = TELEPORT_CHANNEL_MAGIC)
	new rune_effect(get_turf(linked_rune_resolved))

/// For if someone failed to invoke the rune
/obj/effect/cosmic_rune/proc/fail_invoke()
	visible_message(span_warning("The rune pulses with a small flash of purple light, then returns to normal."))
	var/oldcolor = rgb(255, 255, 255)
	color = rgb(150, 50, 200)
	animate(src, color = oldcolor, time = 5)
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_atom_colour)), 0.5 SECONDS)

/// For linking a new rune
/obj/effect/cosmic_rune/proc/link_rune(datum/weakref/new_rune)
	linked_rune = WEAKREF(new_rune)

/obj/effect/cosmic_rune/Destroy()
	var/obj/effect/cosmic_rune/linked_rune_resolved = linked_rune?.resolve()
	if(linked_rune_resolved)
		linked_rune_resolved.unlink_rune()
	return ..()

/// Used for unlinking the other rune if this rune gets destroyed
/obj/effect/cosmic_rune/proc/unlink_rune()
	linked_rune = null

/obj/effect/temp_visual/cosmic_rune_fade
	name = "cosmic rune"
	icon = 'icons/obj/service/hand_of_god_structures.dmi'
	icon_state = "cosmic_rune_fade"
	plane = FLOOR_PLANE
	layer = RUNE_LAYER
	anchored = TRUE
	duration = 5

/obj/effect/temp_visual/cosmic_rune_fade/Initialize(mapload)
	. = ..()
	var/image/silicon_image = image(icon = 'icons/obj/service/hand_of_god_structures.dmi', icon_state = null, loc = src)
	silicon_image.override = TRUE
	add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/silicons, "cosmic", silicon_image)

/obj/effect/temp_visual/rune_light
	name = "cosmic rune"
	icon = 'icons/obj/service/hand_of_god_structures.dmi'
	icon_state = "cosmic_rune_light"
	plane = FLOOR_PLANE
	layer = RUNE_LAYER
	anchored = TRUE
	duration = 5

/obj/effect/temp_visual/rune_light/Initialize(mapload)
	. = ..()
	var/image/silicon_image = image(icon = 'icons/obj/service/hand_of_god_structures.dmi', icon_state = null, loc = src)
	silicon_image.override = TRUE
	add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/silicons, "cosmic", silicon_image)
