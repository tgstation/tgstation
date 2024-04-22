#define SYNTH_REVIVE_WELD_INTERNALS_DAMAGE 30

// Should be a very quick surgery, it's meant to replace defibs (mostly!)
/datum/surgery/positronic_restoration
	name = "Posibrain Reboot (Revival)"
	steps = list(
		/datum/surgery_step/mechanic_unwrench,
		/datum/surgery_step/pry_off_plating/fullbody,
		/datum/surgery_step/weld_plating/fullbody,
		/datum/surgery_step/prepare_electronics,
		/datum/surgery_step/finalize_positronic_restoration,
		/datum/surgery_step/add_plating/fullbody,
		/datum/surgery_step/mechanic_close,
	)

	target_mobtypes = list(/mob/living/carbon/human)
	possible_locs = list(BODY_ZONE_CHEST)
	requires_bodypart_type = BODYTYPE_ROBOTIC
	desc = "A surgical procedure that reboots a positronic brain."

/datum/surgery/robot_chassis_restoration/can_start(mob/user, mob/living/carbon/target)
	if(!..() || target.stat != DEAD ||  !target.get_organ_slot(ORGAN_SLOT_BRAIN))
		return FALSE

	return TRUE

/datum/surgery_step/pry_off_plating/fullbody
	time = 1.4 SECONDS

/datum/surgery_step/pry_off_plating/fullbody/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("You begin to pry open the outer protective panels on [target]'s braincase..."),
		span_notice("[user] begins to pry open the outer protective panels on [target]'s braincase."),
	)

/datum/surgery_step/weld_plating/fullbody
	time = 2 SECONDS

/datum/surgery_step/weld_plating/fullbody/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("You begin to slice the inner protective panels from [target]'s braincase..."),
		span_notice("[user] begins to slice the inner protective panels from [target]'s braincase."),
	)

/datum/surgery_step/weld_plating/fullbody/success(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results)
	. = ..()

	target.apply_damage(SYNTH_REVIVE_WELD_INTERNALS_DAMAGE, BRUTE, "[target_zone]", wound_bonus = CANT_WOUND)

/datum/surgery_step/add_plating/fullbody
	time = 3 SECONDS
	ironamount = 15

/datum/surgery_step/add_plating/fullbody/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("You begin to add new panels to [target]'s braincase..."),
		span_notice("[user] begins to add new panels to [target]'s braincase."),
	)

/datum/surgery_step/add_plating/fullbody/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	. = ..()

	target.heal_bodypart_damage(brute = SYNTH_REVIVE_WELD_INTERNALS_DAMAGE, target_zone = "[target_zone]")

/datum/surgery_step/finalize_positronic_restoration
	name = "finalize positronic restoration (multitool/shocking implement)"
	implements = list(
		TOOL_MULTITOOL = 100,
		/obj/item/shockpaddles = 70,
		/obj/item/melee/touch_attack/shock = 70,
		/obj/item/melee/baton/security = 35,
		/obj/item/gun/energy = 10
	)
	time = 5 SECONDS

/datum/surgery_step/finalize_positronic_restoration/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("You begin to force a reboot in [target]'s posibrain..."),
		span_notice("[user] begins to force a reboot in [target]'s posibrain."),
	)

	target.notify_revival("Someone is trying to reboot your posibrain.", source = target)

/datum/surgery_step/finalize_positronic_restoration/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if (target.stat < DEAD)
		target.visible_message(span_notice("...[target] is completely unaffected! Seems like they're already active!"))
		return FALSE

	target.cure_husk()
	target.grab_ghost()
	target.updatehealth()

	if(target.revive())
		target.emote("chime")
		target.visible_message(span_notice("...[target] reactivates, their chassis coming online!"))
		return FALSE //This is due to synths having some weirdness with their revive.
	else
		target.emote("buzz")
		target.visible_message(span_warning("...[target.p_they()] convulses, then goes offline."))
		return TRUE

/datum/surgery_step/finalize_positronic_restoration/failure(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery, fail_prob)
	. = ..()

	target.adjustOrganLoss(ORGAN_SLOT_BRAIN, 5, 130)

#undef SYNTH_REVIVE_WELD_INTERNALS_DAMAGE

///Notify a ghost that its body is being revived
/mob/proc/notify_revival(message = "Someone is trying to revive you. Re-enter your corpse if you want to be revived!", sound = 'sound/effects/genetics.ogg', atom/source = null, flashwindow = TRUE)
	var/mob/dead/observer/ghost = get_ghost()
	if(ghost)
		ghost.send_revival_notification(message, sound, source, flashwindow)
		return ghost


/mob/dead/observer/proc/send_revival_notification(message, sound, atom/source, flashwindow)
	if(flashwindow)
		window_flash(client)
	if(message)
		to_chat(src, span_ghostalert("[message]"))
		if(source)
			var/atom/movable/screen/alert/A = throw_alert("[REF(source)]_revival", /atom/movable/screen/alert/revival)
			if(A)
				var/ui_style = client?.prefs?.read_preference(/datum/preference/choiced/ui_style)
				if(ui_style)
					A.icon = ui_style2icon(ui_style)
				A.desc = message
				var/old_layer = source.layer
				var/old_plane = source.plane
				source.layer = FLOAT_LAYER
				source.plane = FLOAT_PLANE
				A.add_overlay(source)
				source.layer = old_layer
				source.plane = old_plane
	to_chat(src, span_ghostalert("<a href=?src=[REF(src)];reenter=1>(Click to re-enter)</a>"))
	if(sound)
		SEND_SOUND(src, sound(sound))


//GHOSTS
//TODO: expand this system to replace the pollCandidates/CheckAntagonist/"choose quickly"/etc Yes/No messages
/atom/movable/screen/alert/revival
	name = "Revival"
	desc = "Someone is trying to revive you. Re-enter your corpse if you want to be revived!"
	icon_state = "template"
	timeout = 300

/atom/movable/screen/alert/revival/Click()
	. = ..()
	if(!.)
		return
	var/mob/dead/observer/dead_owner = owner
	dead_owner.reenter_corpse()
