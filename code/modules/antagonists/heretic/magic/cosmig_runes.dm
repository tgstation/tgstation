/datum/action/cooldown/spell/cosmig_rune
	name = "Cosmig Rune"
	desc = "Create a cosmig rune for teleportation. If there are already two cosmig runes, it destroys the oldest rune."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "cosmig_rune"

	sound = 'sound/magic/forcewall.ogg'
	school = SCHOOL_FORBIDDEN
	cooldown_time = 40 SECONDS

	invocation = "ST'R R'N'"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	/// Storage for the first rune.
	var/obj/effect/cosmig_rune/first_rune
	/// Storage for the second rune.
	var/obj/effect/cosmig_rune/second_rune
	/// Rune removal effect.
	var/obj/effect/rune_remove_effect = /obj/effect/temp_visual/cosmig_rune_fade

/datum/action/cooldown/spell/cosmig_rune/cast(atom/cast_on)
	. = ..()
	if(first_rune && second_rune)
		var/obj/effect/cosmig_rune/new_rune = new /obj/effect/cosmig_rune(get_turf(cast_on))
		new rune_remove_effect(get_turf(first_rune))
		QDEL_NULL(first_rune)
		first_rune = second_rune
		second_rune = new_rune
		first_rune.link_rune(null)
		first_rune.link_rune(second_rune)
		second_rune.link_rune(first_rune)
	if(!first_rune)
		first_rune = new /obj/effect/cosmig_rune(get_turf(cast_on))
		if(second_rune)
			first_rune.link_rune(second_rune)
			second_rune.link_rune(first_rune)
	else if(!second_rune)
		second_rune = new /obj/effect/cosmig_rune(get_turf(cast_on))
		if(first_rune)
			first_rune.link_rune(second_rune)
			second_rune.link_rune(first_rune)

/obj/effect/cosmig_rune
	name = "cosmig rune"
	desc = "A strange rune, that can instantly transport people to another location."
	anchored = TRUE
	icon = 'icons/obj/hand_of_god_structures.dmi'
	icon_state = "cosmig_rune"
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	layer = SIGIL_LAYER
	/// The other rune this rune is linked with
	var/obj/effect/cosmig_rune/linked_rune
	/// Effect for when someone teleports
	var/obj/effect/rune_effect = /obj/effect/temp_visual/rune_light

/obj/effect/cosmig_rune/attack_paw(mob/living/user, list/modifiers)
	return attack_hand(user, modifiers)

/obj/effect/cosmig_rune/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(!linked_rune)
		to_chat(user, "There must be a second [src] for it to work!")
		fail_invoke()
		return
	if(!(user in get_turf(src)))
		to_chat(user, "You must be standing on [src]!")
		fail_invoke()
		return
	if(user.has_status_effect(/datum/status_effect/star_mark))
		to_chat(user, "You cannot use [src] while having a star mark!")
		fail_invoke()
		return
	invoke(user)

/obj/effect/cosmig_rune/proc/invoke(mob/living/user)
	new rune_effect(get_turf(src))
	do_teleport(
		user,
		get_turf(linked_rune),
		no_effects = TRUE,
		channel = TELEPORT_CHANNEL_MAGIC,
	)
	new rune_effect(get_turf(linked_rune))

/obj/effect/cosmig_rune/proc/fail_invoke()
	visible_message(span_warning("The rune pulses with a small flash of purple light, then returns to normal."))
	var/oldcolor = rgb(255, 255, 255)
	color = rgb(150, 50, 200)
	animate(src, color = oldcolor, time = 5)
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_atom_colour)), 5)

/obj/effect/cosmig_rune/proc/link_rune(obj/effect/cosmig_rune/new_rune)
	linked_rune = new_rune

/obj/effect/temp_visual/cosmig_rune_fade
	name = "cosmig rune"
	icon = 'icons/obj/hand_of_god_structures.dmi'
	icon_state = "cosmig_rune_fade"
	layer = SIGIL_LAYER
	anchored = TRUE
	duration = 5

/obj/effect/temp_visual/rune_light
	name = "cosmig rune"
	icon = 'icons/obj/hand_of_god_structures.dmi'
	icon_state = "cosmig_rune_light"
	layer = SIGIL_LAYER
	anchored = TRUE
	duration = 5
