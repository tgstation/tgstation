
// The shattered remnants of your broken limbs fill you with determination!
/atom/movable/screen/alert/status_effect/determined
	name = "Determined"
	desc = "The serious wounds you've sustained have put your body into fight-or-flight mode! Now's the time to look for an exit!"
	icon_state = "wounded"

/datum/status_effect/determined
	id = "determined"
	alert_type = /atom/movable/screen/alert/status_effect/determined
	remove_on_fullheal = TRUE

/datum/status_effect/determined/on_apply()
	. = ..()
	owner.visible_message(span_danger("[owner]'s body tenses up noticeably, gritting against [owner.p_their()] pain!"), span_notice("<b>Your senses sharpen as your body tenses up from the wounds you've sustained!</b>"), \
		vision_distance=COMBAT_MESSAGE_RANGE)
	if(ishuman(owner))
		var/mob/living/carbon/human/human_owner = owner
		human_owner.physiology.bleed_mod *= WOUND_DETERMINATION_BLEED_MOD

/datum/status_effect/determined/on_remove()
	owner.visible_message(span_danger("[owner]'s body slackens noticeably!"), span_warning("<b>Your adrenaline rush dies off, and the pain from your wounds come aching back in...</b>"), vision_distance=COMBAT_MESSAGE_RANGE)
	if(ishuman(owner))
		var/mob/living/carbon/human/human_owner = owner
		human_owner.physiology.bleed_mod /= WOUND_DETERMINATION_BLEED_MOD
	return ..()

/datum/status_effect/limp
	id = "limp"
	status_type = STATUS_EFFECT_REPLACE
	tick_interval = STATUS_EFFECT_NO_TICK
	alert_type = /atom/movable/screen/alert/status_effect/limp
	on_remove_on_mob_delete = TRUE
	var/msg_stage = 0//so you dont get the most intense messages immediately
	/// The left leg of the limping person
	var/obj/item/bodypart/leg/left/left
	/// The right leg of the limping person
	var/obj/item/bodypart/leg/right/right
	/// Which leg we're limping with next
	var/obj/item/bodypart/next_leg
	/// How many deciseconds we limp for on the left leg
	var/slowdown_left = 0
	/// How many deciseconds we limp for on the right leg
	var/slowdown_right = 0
	/// The chance we limp with the left leg each step it takes
	var/limp_chance_left = 0
	/// The chance we limp with the right leg each step it takes
	var/limp_chance_right = 0

/datum/status_effect/limp/on_apply()
	if(!iscarbon(owner))
		return FALSE
	var/mob/living/carbon/carbon_owner = owner
	left = carbon_owner.get_bodypart(BODY_ZONE_L_LEG)
	right = carbon_owner.get_bodypart(BODY_ZONE_R_LEG)
	update_limp(src)
	RegisterSignal(carbon_owner, COMSIG_MOVABLE_MOVED, PROC_REF(check_step))
	RegisterSignal(carbon_owner, COMSIG_CARBON_REMOVE_LIMB, PROC_REF(on_limb_removed))
	RegisterSignals(carbon_owner, list(COMSIG_CARBON_GAIN_WOUND, COMSIG_CARBON_POST_LOSE_WOUND, COMSIG_CARBON_ATTACH_LIMB), PROC_REF(update_limp))
	return TRUE

/datum/status_effect/limp/on_remove()
	UnregisterSignal(owner, list(COMSIG_MOVABLE_MOVED, COMSIG_CARBON_GAIN_WOUND, COMSIG_CARBON_POST_LOSE_WOUND, COMSIG_CARBON_ATTACH_LIMB, COMSIG_CARBON_REMOVE_LIMB))
	left = null
	right = null

/atom/movable/screen/alert/status_effect/limp
	name = "Limping"
	desc = "One or more of your legs has been wounded, slowing down steps with that leg! Get it fixed, or at least in a sling of gauze!"

/datum/status_effect/limp/proc/check_step(mob/whocares, OldLoc, Dir, forced)
	SIGNAL_HANDLER

	if(!owner.client || owner.body_position == LYING_DOWN || !owner.has_gravity() || (owner.movement_type & (FLYING|FLOATING)) || forced || owner.buckled)
		return

	// less limping while we have determination still
	var/determined_mod = owner.has_status_effect(/datum/status_effect/determined) ? 0.5 : 1

	if(SEND_SIGNAL(owner, COMSIG_CARBON_LIMPING) & COMPONENT_CANCEL_LIMP)
		return

	if(next_leg == left)
		if(prob(limp_chance_left * determined_mod))
			owner.client.move_delay += slowdown_left * determined_mod
		next_leg = right
	else
		if(prob(limp_chance_right * determined_mod))
			owner.client.move_delay += slowdown_right * determined_mod
		next_leg = left

/// We need to make sure that we properly clear these refs if one of the owner's limbs gets deleted
/datum/status_effect/limp/proc/on_limb_removed(datum/source, obj/item/bodypart/limb_lost, special, dismembered)
	SIGNAL_HANDLER

	if(limb_lost == left)
		left = null
	if(limb_lost == right)
		right = null

	update_limp() // calling this with no arg so we know it's coming from here and not a signal

/datum/status_effect/limp/proc/update_limp(datum/source)
	SIGNAL_HANDLER

	var/mob/living/carbon/carbon_mob = owner
	if(source) // if we don't have a source, that means we are calling it from on_limb_removed. In that case we do not want to reassign these to the about-to-be-removed limbs (which can cause hanging refs)
		left = carbon_mob.get_bodypart(BODY_ZONE_L_LEG)
		right = carbon_mob.get_bodypart(BODY_ZONE_R_LEG)

	if(!left && !right)
		carbon_mob.remove_status_effect(src)
		return

	slowdown_left = 0
	slowdown_right = 0
	limp_chance_left = 0
	limp_chance_right = 0

	// technically you can have multiple wounds causing limps on the same limb, even if practically only bone wounds cause it in normal gameplay
	if(left)
		for(var/thing in left.wounds)
			var/datum/wound/wound = thing
			slowdown_left += wound.limp_slowdown
			limp_chance_left = max(limp_chance_left, wound.limp_chance)

	if(right)
		for(var/thing in right.wounds)
			var/datum/wound/wound = thing
			slowdown_right += wound.limp_slowdown
			limp_chance_right = max(limp_chance_right, wound.limp_chance)

	// this handles losing your leg with the limp and the other one being in good shape as well
	if(!slowdown_left && !slowdown_right)
		carbon_mob.remove_status_effect(src)
		return

/////////////////////////
//////// WOUNDS /////////
/////////////////////////

// wound status effect base
/datum/status_effect/wound
	id = "wound"
	status_type = STATUS_EFFECT_MULTIPLE
	var/obj/item/bodypart/linked_limb
	var/datum/wound/linked_wound
	alert_type = NONE

/datum/status_effect/wound/on_creation(mob/living/new_owner, incoming_wound)
	linked_wound = incoming_wound
	linked_limb = linked_wound.limb
	return ..()

/datum/status_effect/wound/on_remove()
	linked_wound = null
	linked_limb = null
	UnregisterSignal(owner, COMSIG_CARBON_LOSE_WOUND)

/datum/status_effect/wound/on_apply()
	if(!iscarbon(owner))
		return FALSE
	RegisterSignal(owner, COMSIG_CARBON_LOSE_WOUND, PROC_REF(check_remove))
	return TRUE

/// check if the wound getting removed is the wound we're tied to
/datum/status_effect/wound/proc/check_remove(mob/living/L, datum/wound/W)
	SIGNAL_HANDLER

	if(W == linked_wound)
		qdel(src)

/datum/status_effect/wound/nextmove_modifier()
	var/mob/living/carbon/C = owner

	if(C.get_active_hand() == linked_limb)
		return linked_wound.get_action_delay_mult()

	return ..()

/datum/status_effect/wound/nextmove_adjust()
	var/mob/living/carbon/C = owner

	if(C.get_active_hand() == linked_limb)
		return linked_wound.get_action_delay_increment()

	return ..()


// bones
/datum/status_effect/wound/blunt/bone

// blunt
/datum/status_effect/wound/blunt/bone/moderate
	id = "disjoint"
/datum/status_effect/wound/blunt/bone/severe
	id = "hairline"
/datum/status_effect/wound/blunt/bone/critical
	id = "compound"

// slash

/datum/status_effect/wound/slash/flesh/moderate
	id = "abrasion"
/datum/status_effect/wound/slash/flesh/severe
	id = "laceration"
/datum/status_effect/wound/slash/flesh/critical
	id = "avulsion"
// pierce
/datum/status_effect/wound/pierce/moderate
	id = "breakage"
/datum/status_effect/wound/pierce/severe
	id = "puncture"
/datum/status_effect/wound/pierce/critical
	id = "rupture"
// burns
/datum/status_effect/wound/burn/flesh/moderate
	id = "seconddeg"
/datum/status_effect/wound/burn/flesh/severe
	id = "thirddeg"
/datum/status_effect/wound/burn/flesh/critical
	id = "fourthdeg"
