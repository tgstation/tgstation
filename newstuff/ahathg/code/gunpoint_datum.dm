

/obj/effect/overlay/gunpoint_effect
	icon = 'newstuff/ahathg/icons/targeted.dmi'
	icon_state = "locking"
	layer = FLY_LAYER
	plane = GAME_PLANE
	appearance_flags = APPEARANCE_UI_IGNORE_ALPHA | KEEP_APART
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/datum/gunpoint
	var/mob/living/source
	var/mob/living/target

	var/obj/item/gun/aimed_gun

	var/locked = FALSE
	var/was_running = FALSE


/datum/gunpoint/New(user, tar, gun)
	source = user
	source.gunpointing = src
	target = tar
	target.gunpointed += src
	aimed_gun = gun

	source.face_atom(target)
	source.visible_message(span_danger("[source.name] aims at [target.name] with the [aimed_gun.name]!"))

	was_running = (source.move_intent == MOVE_INTENT_RUN)
	if(was_running)
		source.toggle_move_intent()
	ADD_TRAIT(source, TRAIT_NORUNNING, "gunpoint")

	if(!target.gp_effect)
		target.gp_effect = new
		target.vis_contents += target.gp_effect

	RegisterSignal(source, COMSIG_MOVABLE_MOVED, PROC_REF(source_moved))

	RegisterSignal(source, COMSIG_LIVING_STATUS_STUN, PROC_REF(source_cc))
	RegisterSignal(source, COMSIG_LIVING_STATUS_KNOCKDOWN, PROC_REF(source_cc))
	RegisterSignal(source, COMSIG_LIVING_STATUS_PARALYZE, PROC_REF(source_cc))
	RegisterSignal(source, COMSIG_LIVING_UPDATED_RESTING, PROC_REF(source_updated_resting))

	RegisterSignal(aimed_gun, COMSIG_ITEM_EQUIPPED,PROC_REF(click_destroy))
	RegisterSignal(aimed_gun, COMSIG_ITEM_DROPPED,PROC_REF(click_destroy))

	RegisterSignal(target, COMSIG_QDELETING, PROC_REF(Destroy))
	RegisterSignal(source, COMSIG_QDELETING, PROC_REF(Destroy))


	addtimer(CALLBACK(src, PROC_REF(lock_on)), 7)

/datum/gunpoint/proc/lock_on()
	if(src) //if we're not present then locking on failed and this datum is deleted
		if(!check_continuity())
			qdel(src)
			return
		locked = TRUE
		log_combat(target, source, "locked onto with aiming")
		playsound(get_turf(source), 'newstuff/ahathg/sound/targeton.ogg', 50,1)
		to_chat(source, span_notice("<b>You lock onto [target.name]!</b>"))
		target.visible_message(span_warning("<b>[source.name] holds [target.name] at gunpoint with the [aimed_gun.name]!</b>"), span_userdanger("[source.name] holds you at gunpoint with the [aimed_gun.name]!"))
		if(target.gunpointed.len == 1)//First case
			to_chat(target, span_danger("You can move, but you see that [source.name] has a gun pointed at you!"))
		if(target.gp_effect.icon_state != "locked")
			target.gp_effect.icon_state = "locked"

/datum/gunpoint/proc/check_continuity()
	if(!target)
		return FALSE
	if(source.CanGunpointAt(target))
		source.face_atom(target)
		return TRUE
	return FALSE

/datum/gunpoint/Destroy()
	UnregisterSignal(aimed_gun, list(COMSIG_ITEM_DROPPED, COMSIG_ITEM_EQUIPPED))
	UnregisterSignal(target, list(COMSIG_QDELETING, COMSIG_ITEM_ATTACK_SELF, COMSIG_LIVING_UNARMED_ATTACK, COMSIG_ITEM_ATTACK_SELF, COMSIG_MOB_FIRED_GUN, COMSIG_MOVABLE_MOVED))
	UnregisterSignal(source, list(COMSIG_QDELETING, COMSIG_MOVABLE_MOVED, COMSIG_LIVING_STATUS_STUN, COMSIG_LIVING_STATUS_KNOCKDOWN, COMSIG_LIVING_STATUS_PARALYZE, COMSIG_LIVING_UPDATED_RESTING))

	REMOVE_TRAIT(source, TRAIT_NORUNNING, "gunpoint")
	if(was_running)
		source.toggle_move_intent()
	if(target.gunpointed.len == 1) //Last instance being deleted
		target.vis_contents -= target.gp_effect
		QDEL_NULL(target.gp_effect)
	target.gunpointed -= src
	source.gunpointing = null
	if(locked)
		target.visible_message(span_notice("[source.name] no longer holds [target.name] at gunpoint."), span_notice("<b>[source.name] no longer holds you at gunpoint.</b>"))
	source = null
	target = null
	aimed_gun = null
	return ..()

/datum/gunpoint/proc/click_destroy()
	SIGNAL_HANDLER
	if(locked)
		playsound(get_turf(source), 'newstuff/ahathg/sound/targetoff.ogg', 50,1)
	qdel(src)

/datum/gunpoint/proc/source_cc(datum/source, amount, update, ignore)
	SIGNAL_HANDLER
	if(amount && !ignore)
		qdel(src)

/datum/gunpoint/proc/source_moved(datum/datum_source)
	SIGNAL_HANDLER
	if(!check_continuity())
		qdel(src)

/datum/gunpoint/proc/source_updated_resting(datum/datum_source, resting)
	SIGNAL_HANDLER
	if(resting)
		qdel(src)
