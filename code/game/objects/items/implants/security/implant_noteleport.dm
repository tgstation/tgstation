///Blocks the implantee from being teleported
/obj/item/implant/teleport_blocker
	name = "bluespace grounding implant"
	desc = "Grounds your bluespace signature in baseline reality, whatever the hell that means."
	actions_types = null
	implant_flags = IMPLANT_TYPE_SECURITY
	hud_icon_state = "hud_imp_noteleport"

/obj/item/implant/teleport_blocker/get_data()
	return "<b>Implant Specifications:</b><BR> \
		<b>Name:</b> Robust Corp EXP-001 'Bluespace Grounder'<BR> \
		<b>Implant Details:</b> Upon implantation, grounds the user's bluespace signature to their currently occupied plane of existence. \
		Most, if not all forms of teleportation on the implantee will be rendered ineffective. Useful for keeping especially slippery prisoners in place.<BR>"

/obj/item/implant/teleport_blocker/implant(mob/living/target, mob/user, silent = FALSE, force = FALSE)
	. = ..()
	if(!. || !isliving(target))
		return FALSE
	RegisterSignal(target, COMSIG_MOVABLE_TELEPORTING, PROC_REF(on_teleport))
	RegisterSignal(target, COMSIG_MOB_PRE_JAUNT, PROC_REF(on_jaunt))
	return TRUE

/obj/item/implant/teleport_blocker/removed(mob/target, silent = FALSE, special = FALSE)
	. = ..()
	if(!. || !isliving(target))
		return FALSE
	UnregisterSignal(target, COMSIG_MOVABLE_TELEPORTING)
	UnregisterSignal(target, COMSIG_MOB_PRE_JAUNT)
	return TRUE

/// Signal for COMSIG_MOVABLE_TELEPORTED that blocks teleports and stuns the would-be-teleportee.
/obj/item/implant/teleport_blocker/proc/on_teleport(mob/living/teleportee, atom/destination, channel)
	SIGNAL_HANDLER

	to_chat(teleportee, span_holoparasite("You feel yourself teleporting, but are suddenly flung back to where you just were!"))

	teleportee.apply_status_effect(/datum/status_effect/incapacitating/paralyzed, 5 SECONDS)
	var/datum/effect_system/spark_spread/quantum/spark_system = new()
	spark_system.set_up(5, TRUE, teleportee)
	spark_system.start()
	return COMPONENT_BLOCK_TELEPORT

/// Signal for COMSIG_MOB_PRE_JAUNT that prevents a user from entering a jaunt.
/obj/item/implant/teleport_blocker/proc/on_jaunt(mob/living/jaunter)
	SIGNAL_HANDLER

	to_chat(jaunter, span_holoparasite("As you attempt to jaunt, you slam directly into the barrier between realities and are sent crashing back into corporeality!"))

	jaunter.apply_status_effect(/datum/status_effect/incapacitating/paralyzed, 5 SECONDS)
	var/datum/effect_system/spark_spread/quantum/spark_system = new()
	spark_system.set_up(5, TRUE, jaunter)
	spark_system.start()
	return COMPONENT_BLOCK_JAUNT

/obj/item/implantcase/teleport_blocker
	name = "implant case - 'Bluespace Grounding'"
	desc = "A glass case containing a bluespace grounding implant."
	imp_type = /obj/item/implant/teleport_blocker

/obj/item/implant/teleport_blocker/c38
	name = "ANCR implant"
	desc = "A smaller bluespace grounding implant that supplies power for only one minute."
	implant_flags = NONE
	///How long before this implant self-deletes?
	var/lifespan = 1 MINUTES
	///The id of the timer that's qdeleting us
	var/timerid

/obj/item/implant/teleport_blocker/c38/implant(mob/living/target, mob/user, silent, force)
	. = ..()
	timerid = QDEL_IN_STOPPABLE(src, lifespan)
	target.apply_status_effect(/datum/status_effect/teleport_blocked)

/obj/item/implant/teleport_blocker/c38/removed(mob/living/target, silent = FALSE, special = FALSE)
	. = ..()
	deltimer(timerid)
	timerid = null
	target.remove_status_effect(/datum/status_effect/teleport_blocked)

/obj/item/implant/teleport_blocker/c38/Destroy()
	return ..()

/// Uh oh, you can't move, yell for help
/datum/status_effect/teleport_blocked
	id = "teleport_blocked"
	alert_type = /atom/movable/screen/alert/status_effect/teleport_blocked

/atom/movable/screen/alert/status_effect/teleport_blocked
	name = "Bluespace Anchored"
	desc = "Your bluespace signature has been stabilised. You can't teleport anymore!"
	icon_state = "teleport_blocked"

/datum/status_effect/teleport_blocked/on_apply()
	. = ..()
	if (!.)
		return FALSE
	owner.visible_message(span_warning("[owner] crackles with bluespace energy!"), span_warning("You can sense your bluespace signature stabilising!"))
	return TRUE

/datum/status_effect/teleport_blocked/get_examine_text()
	return span_warning("[owner.p_They()] [owner.p_are()] is shimmering with blueish sparks!")

/datum/status_effect/teleport_blocked/on_remove()
	owner.visible_message(span_warning("[owner] looks less blue than moments ago!"), span_warning("You can sense your bluespace signature destabilising!"))
	return ..()
