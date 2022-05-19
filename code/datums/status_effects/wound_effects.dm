
// The shattered remnants of your broken limbs fill you with determination!
/atom/movable/screen/alert/status_effect/determined
	name = "Determined"
	desc = "The serious wounds you've sustained have put your body into fight-or-flight mode! Now's the time to look for an exit!"
	icon_state = "wounded"

/datum/status_effect/determined
	id = "determined"
	alert_type = /atom/movable/screen/alert/status_effect/determined

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
	tick_interval = 0
	alert_type = /atom/movable/screen/alert/status_effect/limp
	var/msg_stage = 0//so you dont get the most intense messages immediately
	/// The left leg of the limping person
	var/obj/item/bodypart/l_leg/left
	/// The right leg of the limping person
	var/obj/item/bodypart/r_leg/right
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
	var/mob/living/carbon/C = owner
	left = C.get_bodypart(BODY_ZONE_L_LEG)
	right = C.get_bodypart(BODY_ZONE_R_LEG)
	update_limp()
	RegisterSignal(C, COMSIG_MOVABLE_MOVED, .proc/check_step)
	RegisterSignal(C, list(COMSIG_CARBON_GAIN_WOUND, COMSIG_CARBON_LOSE_WOUND, COMSIG_CARBON_ATTACH_LIMB, COMSIG_CARBON_REMOVE_LIMB), .proc/update_limp)
	return TRUE

/datum/status_effect/limp/on_remove()
	UnregisterSignal(owner, list(COMSIG_MOVABLE_MOVED, COMSIG_CARBON_GAIN_WOUND, COMSIG_CARBON_LOSE_WOUND, COMSIG_CARBON_ATTACH_LIMB, COMSIG_CARBON_REMOVE_LIMB))

/atom/movable/screen/alert/status_effect/limp
	name = "Limping"
	desc = "One or more of your legs has been wounded, slowing down steps with that leg! Get it fixed, or at least in a sling of gauze!"

/datum/status_effect/limp/proc/check_step(mob/whocares, OldLoc, Dir, forced)
	SIGNAL_HANDLER

	if(!owner.client || owner.body_position == LYING_DOWN || !owner.has_gravity() || (owner.movement_type & FLYING) || forced || owner.buckled)
		return

	// less limping while we have determination still
	var/determined_mod = owner.has_status_effect(/datum/status_effect/determined) ? 0.5 : 1

	if(next_leg == left)
		if(prob(limp_chance_left * determined_mod))
			owner.client.move_delay += slowdown_left * determined_mod
		next_leg = right
	else
		if(prob(limp_chance_right * determined_mod))
			owner.client.move_delay += slowdown_right * determined_mod
		next_leg = left

/datum/status_effect/limp/proc/update_limp()
	SIGNAL_HANDLER

	var/mob/living/carbon/C = owner
	left = C.get_bodypart(BODY_ZONE_L_LEG)
	right = C.get_bodypart(BODY_ZONE_R_LEG)

	if(!left && !right)
		C.remove_status_effect(src)
		return

	slowdown_left = 0
	slowdown_right = 0
	limp_chance_left = 0
	limp_chance_right = 0

	// technically you can have multiple wounds causing limps on the same limb, even if practically only bone wounds cause it in normal gameplay
	if(left)
		for(var/thing in left.wounds)
			var/datum/wound/W = thing
			slowdown_left += W.limp_slowdown
			limp_chance_left = max(limp_chance_left, W.limp_chance)

	if(right)
		for(var/thing in right.wounds)
			var/datum/wound/W = thing
			slowdown_right += W.limp_slowdown
			limp_chance_right = max(limp_chance_right, W.limp_chance)

	// this handles losing your leg with the limp and the other one being in good shape as well
	if(!slowdown_left && !slowdown_right)
		C.remove_status_effect(src)
		return


/////////////////////////
//////// WOUNDS /////////
/////////////////////////

// wound alert
/atom/movable/screen/alert/status_effect/wound
	name = "Wounded"
	desc = "Your body has sustained serious damage, click here to inspect yourself."

/atom/movable/screen/alert/status_effect/wound/Click()
	. = ..()
	if(!.)
		return

	var/mob/living/carbon/carbon_owner = owner
	carbon_owner.check_self_for_injuries()

// wound status effect base
/datum/status_effect/wound
	id = "wound"
	status_type = STATUS_EFFECT_MULTIPLE
	var/obj/item/bodypart/linked_limb
	var/datum/wound/linked_wound
	alert_type = NONE

/datum/status_effect/wound/on_creation(mob/living/new_owner, incoming_wound)
	. = ..()
	linked_wound = incoming_wound
	linked_limb = linked_wound.limb

/datum/status_effect/wound/on_remove()
	linked_wound = null
	linked_limb = null
	UnregisterSignal(owner, COMSIG_CARBON_LOSE_WOUND)

/datum/status_effect/wound/on_apply()
	if(!iscarbon(owner))
		return FALSE
	RegisterSignal(owner, COMSIG_CARBON_LOSE_WOUND, .proc/check_remove)
	return TRUE

/// check if the wound getting removed is the wound we're tied to
/datum/status_effect/wound/proc/check_remove(mob/living/L, datum/wound/W)
	SIGNAL_HANDLER

	if(W == linked_wound)
		qdel(src)


// bones
/datum/status_effect/wound/blunt

/datum/status_effect/wound/blunt/on_apply()
	. = ..()
	RegisterSignal(owner, COMSIG_MOB_SWAP_HANDS, .proc/on_swap_hands)
	on_swap_hands()

/datum/status_effect/wound/blunt/on_remove()
	. = ..()
	UnregisterSignal(owner, COMSIG_MOB_SWAP_HANDS)
	var/mob/living/carbon/wound_owner = owner
	wound_owner.remove_actionspeed_modifier(/datum/actionspeed_modifier/blunt_wound)

/datum/status_effect/wound/blunt/proc/on_swap_hands()
	SIGNAL_HANDLER

	var/mob/living/carbon/wound_owner = owner
	if(wound_owner.get_active_hand() == linked_limb)
		wound_owner.add_actionspeed_modifier(/datum/actionspeed_modifier/blunt_wound, (linked_wound.interaction_efficiency_penalty - 1))
	else
		wound_owner.remove_actionspeed_modifier(/datum/actionspeed_modifier/blunt_wound)

/datum/status_effect/wound/blunt/nextmove_modifier()
	var/mob/living/carbon/C = owner

	if(C.get_active_hand() == linked_limb)
		return linked_wound.interaction_efficiency_penalty

	return 1

// blunt
/datum/status_effect/wound/blunt/moderate
	id = "disjoint"
/datum/status_effect/wound/blunt/severe
	id = "hairline"
/datum/status_effect/wound/blunt/critical
	id = "compound"
// slash
/datum/status_effect/wound/slash/moderate
	id = "abrasion"
/datum/status_effect/wound/slash/severe
	id = "laceration"
/datum/status_effect/wound/slash/critical
	id = "avulsion"
// pierce
/datum/status_effect/wound/pierce/moderate
	id = "breakage"
/datum/status_effect/wound/pierce/severe
	id = "puncture"
/datum/status_effect/wound/pierce/critical
	id = "rupture"
// burns
/datum/status_effect/wound/burn/moderate
	id = "seconddeg"
/datum/status_effect/wound/burn/severe
	id = "thirddeg"
/datum/status_effect/wound/burn/critical
	id = "fourthdeg"
