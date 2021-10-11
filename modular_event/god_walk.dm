// A useful spell for getting around quickly into places you will want your mob to be to do event running and the like
/obj/effect/proc_holder/spell/targeted/godwalk
	name = "God Walk"
	desc = "Grants unlimited movement anywhere."
	charge_max = 0
	clothes_req = FALSE
	antimagic_allowed = TRUE
	phase_allowed = TRUE
	selection_type = "range"
	range = -1
	include_user = TRUE
	cooldown_min = 0
	overlay = null
	action_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	action_icon_state = "hide"
	action_background_icon_state = "bg_default"

/obj/effect/proc_holder/spell/targeted/godwalk/cast_check(skipcharge = 0, mob/user = usr)
	return TRUE

/obj/effect/proc_holder/spell/targeted/godwalk/cast(list/targets, mob/living/user = usr)
	if(istype(user.loc, /obj/effect/dummy/phased_mob/godwhisp))
		var/obj/effect/dummy/phased_mob/godwhisp/whisp = user.loc
		qdel(whisp)
		user.visible_message(span_boldnotice("[user] emerges from thin air!"))
		playsound(get_turf(user), 'sound/magic/ethereal_exit.ogg', 10, TRUE, -1)
		REMOVE_TRAIT(user, TRAIT_MOVE_VENTCRAWLING, "godwalk") // to allow use of up/down verb
		REMOVE_TRAIT(user, TRAIT_XRAY_VISION, "godwalk")
		REMOVE_TRAIT(user, TRAIT_THERMAL_VISION, "godwalk")
		user.update_sight()
		return
	playsound(get_turf(user), 'sound/magic/ethereal_enter.ogg', 15, TRUE, -1)
	user.visible_message(span_boldnotice("[user] vanishes!"))
	user.SetAllImmobility(0)
	user.setStaminaLoss(0, 0)
	var/obj/effect/dummy/phased_mob/godwhisp/new_whisp = new(get_turf(user.loc))
	user.forceMove(new_whisp)
	ADD_TRAIT(user, TRAIT_MOVE_VENTCRAWLING, "godwalk")
	ADD_TRAIT(user, TRAIT_XRAY_VISION, "godwalk")
	ADD_TRAIT(user, TRAIT_THERMAL_VISION, "godwalk")
	user.update_sight()

/obj/effect/dummy/phased_mob/godwhisp/phased_check(mob/living/user, direction)
	return get_step(src, direction) // override to bypass all jaunt blockers
