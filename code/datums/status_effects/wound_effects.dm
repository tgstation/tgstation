
// The shattered remnants of your broken limbs fill you with determination!
/obj/screen/alert/status_effect/determined
	name = "Determined"
	desc = "The serious wounds you've sustained have put your body into fight-or-flight mode! Now's the time to look for an exit!"
	icon_state = "regenerative_core"

/datum/status_effect/determined
	id = "determined"
	alert_type = /obj/screen/alert/status_effect/determined

/datum/status_effect/determined/on_apply()
	owner.visible_message("<span class='danger'>[owner] grits [owner.p_their()] teeth in pain!</span>", "<span class='notice'><b>Your senses sharpen as your body tenses up from the wounds you've sustained!</b></span>", vision_distance=COMBAT_MESSAGE_RANGE)
	return ..()

/datum/status_effect/determined/on_remove()
	owner.visible_message("<span class='danger'>[owner]'s body slackens noticeably!</span>", "<span class='warning'><b>Your adrenaline rush dies off, and the pain from your wounds come aching back in...</b></span>", vision_distance=COMBAT_MESSAGE_RANGE)




/datum/status_effect/limp
	id = "limp"
	status_type = STATUS_EFFECT_REPLACE
	tick_interval = 10
	alert_type = /obj/screen/alert/status_effect/limp
	var/msg_stage = 0//so you dont get the most intense messages immediately
	var/obj/item/bodypart/l_leg/left
	var/obj/item/bodypart/r_leg/right
	var/obj/item/bodypart/next_leg
	var/slowdown_left = 0
	var/slowdown_right = 0

/datum/status_effect/limp/on_apply()
	if(!iscarbon(owner))
		return FALSE
	var/mob/living/carbon/C = owner
	left = C.get_bodypart(BODY_ZONE_L_LEG)
	right = C.get_bodypart(BODY_ZONE_R_LEG)
	update_limp()
	RegisterSignal(C, COMSIG_MOVABLE_MOVED, .proc/check_step)
	RegisterSignal(C, list(COMSIG_CARBON_GAIN_WOUND, COMSIG_CARBON_LOSE_WOUND, COMSIG_CARBON_ATTACH_LIMB, COMSIG_CARBON_REMOVE_LIMB), .proc/update_limp)
	return TRUE

/datum/status_effect/limp/on_remove()
	UnregisterSignal(owner, list(COMSIG_MOVABLE_MOVED, COMSIG_CARBON_GAIN_WOUND, COMSIG_CARBON_LOSE_WOUND, COMSIG_CARBON_ATTACH_LIMB, COMSIG_CARBON_REMOVE_LIMB))

/obj/screen/alert/status_effect/limp
	name = "Limping"
	desc = "One or more of your legs has been wounded, slowing down steps with that leg! Get it fixed, or at least splinted!"

/datum/status_effect/limp/proc/check_step()
	if(!owner.client || !(owner.mobility_flags & MOBILITY_STAND))
		return
	var/determined_mod = 1
	if(owner.has_status_effect(STATUS_EFFECT_DETERMINED))
		determined_mod = 0.25
	if(next_leg == left)
		owner.client.move_delay += slowdown_left * determined_mod
		next_leg = right
	else
		owner.client.move_delay += slowdown_right * determined_mod
		next_leg = left

/datum/status_effect/limp/proc/update_limp()
	var/mob/living/carbon/C = owner
	left = C.get_bodypart(BODY_ZONE_L_LEG)
	right = C.get_bodypart(BODY_ZONE_R_LEG)

	if(!left && !right)
		C.remove_status_effect(src)
		return

	slowdown_left = 0
	slowdown_right = 0

	if(left)
		for(var/thing in left.wounds)
			var/datum/wound/W = thing
			slowdown_left += W.limp_slowdown

	if(right)
		for(var/thing in right.wounds)
			var/datum/wound/W = thing
			slowdown_right += W.limp_slowdown

	// this handles losing your leg with the limp and the other one being in good shape as well
	if(!slowdown_left && !slowdown_right)
		C.remove_status_effect(src)
		return


/////////////////////////
//////// WOUNDS /////////
/////////////////////////

// wound alert base
/obj/screen/alert/status_effect/wound

/obj/screen/alert/status_effect/wound/proc/update_text()
	name = "[name]"

// wound status effect base
/datum/status_effect/wound
	id = "wound"
	status_type = STATUS_EFFECT_MULTIPLE
	var/obj/item/bodypart/linked_limb
	var/datum/wound/linked_wound

/datum/status_effect/wound/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	if(owner)
		if(LAZYLEN(owner.has_status_effect_list(id)) <= 1)
			owner.clear_alert(id)
		LAZYREMOVE(owner.status_effects, src)
		on_remove()
		owner = null
/*
/datum/status_effect/wound/on_creation(mob/living/new_owner, incoming_wound)
	..()
	var/datum/wound/W = incoming_wound
	linked_wound = W
	linked_limb = linked_wound.limb
	if(linked_alert)
		var/obj/screen/alert/status_effect/wound/wound_alert = linked_alert
		if(!istype(wound_alert))
			return
*/
/datum/status_effect/wound/on_creation(mob/living/new_owner, incoming_wound)
	if(new_owner)
		owner = new_owner
	if(owner)
		LAZYADD(owner.status_effects, src)
	if(!owner || !on_apply())
		qdel(src)
		return
	if(duration != -1)
		duration = world.time + duration
	tick_interval = world.time + tick_interval
	if(alert_type && !owner.alerts[id])
		var/obj/screen/alert/status_effect/A = owner.throw_alert(id, alert_type)
		A.attached_effect = src //so the alert can reference us, if it needs to
		linked_alert = A //so we can reference the alert, if we need to
	START_PROCESSING(SSfastprocess, src)
	var/datum/wound/W = incoming_wound
	linked_wound = W
	linked_limb = linked_wound.limb
	return TRUE

/datum/status_effect/wound/on_remove()
	linked_wound = null
	linked_limb = null
	UnregisterSignal(owner, COMSIG_CARBON_LOSE_WOUND)

/datum/status_effect/wound/on_apply()
	if(!iscarbon(owner))
		return FALSE
	RegisterSignal(owner, COMSIG_CARBON_LOSE_WOUND, .proc/check_remove)
	return TRUE

/datum/status_effect/wound/proc/check_remove(mob/living/L, datum/wound/W)
	if(W == linked_wound)
		qdel(src)


// bones
/datum/status_effect/wound/bone

/datum/status_effect/wound/bone/nextmove_modifier()
	var/mob/living/carbon/C = owner

	if(C.get_active_hand() == linked_limb)
		return linked_wound.interaction_efficiency_penalty
	else
		return 1

/datum/status_effect/wound/bone/moderate
	id = "disjoint"
	alert_type = /obj/screen/alert/status_effect/wound/bone/moderate

/obj/screen/alert/status_effect/wound/bone/moderate
	name = "Disjointed"
	desc = "One of your limbs is disjointed, you should get that popped back into place."


/datum/status_effect/wound/bone/severe
	id = "hairline"
	alert_type = /obj/screen/alert/status_effect/wound/bone/severe

/obj/screen/alert/status_effect/wound/bone/severe
	name = "Hairline Fractured"
	desc = "One of your limbs has a hairline fracture, you should get that treated, or at least splinted."


/datum/status_effect/wound/bone/critical
	id = "compound"
	alert_type = /obj/screen/alert/status_effect/wound/bone/critical

/obj/screen/alert/status_effect/wound/bone/critical
	name = "Compound Fractured"
	desc = "One of your limbs has a compound fracture, you should get that treated, or at least splinted."



// cuts
/datum/status_effect/wound/cut/moderate
	id = "abrasion"
	alert_type = /obj/screen/alert/status_effect/wound/cut/moderate

/obj/screen/alert/status_effect/wound/cut/moderate
	name = "Abraised"
	desc = "One of your limbs has an open cut, you should get that stitched, wrapped, or at least cauterized."


/datum/status_effect/wound/cut/severe
	id = "laceration"
	alert_type = /obj/screen/alert/status_effect/wound/cut/severe

/obj/screen/alert/status_effect/wound/cut/severe
	name = "Lacerated"
	desc = "One of your limbs has a serious laceration, you should get that stitched, wrapped, or at least cauterized."


/datum/status_effect/wound/cut/critical
	id = "avulsion"
	alert_type = /obj/screen/alert/status_effect/wound/cut/critical

/obj/screen/alert/status_effect/wound/cut/critical
	name = "Avulsed"
	desc = "One of your limbs has a really bad tear, you should get that stitched, wrapped, or at least cauterized."


// burns
/datum/status_effect/wound/burn/moderate
	id = "seconddeg"
	alert_type = /obj/screen/alert/status_effect/wound/burn/moderate

/obj/screen/alert/status_effect/wound/burn/moderate
	name = "Lightly Singed"
	desc = "One of your limbs has an open cut, you should get that stitched, wrapped, or at least cauterized."


/datum/status_effect/wound/burn/severe
	id = "thirddeg"
	alert_type = /obj/screen/alert/status_effect/wound/burn/severe

/obj/screen/alert/status_effect/wound/burn/severe
	name = "Badly Burned"
	desc = "One of your limbs has a serious laceration, you should get that stitched, wrapped, or at least cauterized."


/datum/status_effect/wound/burn/critical
	id = "fourthdeg"
	alert_type = /obj/screen/alert/status_effect/wound/burn/critical

/obj/screen/alert/status_effect/wound/burn/critical
	name = "Critically Charred"
	desc = "One of your limbs has a really bad tear, you should get that stitched, wrapped, or at least cauterized."
