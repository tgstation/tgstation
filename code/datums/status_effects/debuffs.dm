//Largely negative status effects go here, even if they have small benificial effects

/datum/status_effect/sigil_mark //allows the affected target to always trigger sigils while mindless
	id = "sigil_mark"
	duration = -1
	alert_type = null
	var/stat_allowed = DEAD //if owner's stat is below this, will remove itself

/datum/status_effect/sigil_mark/tick()
	if(owner.stat < stat_allowed)
		qdel(src)

/datum/status_effect/his_wrath //does minor damage over time unless holding His Grace
	id = "his_wrath"
	duration = -1
	tick_interval = 4
	alert_type = /obj/screen/alert/status_effect/his_wrath

/obj/screen/alert/status_effect/his_wrath
	name = "His Wrath"
	desc = "You fled from His Grace instead of feeding Him, and now you suffer."
	icon_state = "his_grace"
	alerttooltipstyle = "hisgrace"

/datum/status_effect/his_wrath/tick()
	for(var/obj/item/weapon/his_grace/HG in owner.held_items)
		qdel(src)
		return
	owner.adjustBruteLoss(0.1)
	owner.adjustFireLoss(0.1)
	owner.adjustToxLoss(0.2, TRUE, TRUE)

/datum/status_effect/belligerent
	id = "belligerent"
	duration = 70
	tick_interval = 0 //tick as fast as possible
	status_type = STATUS_EFFECT_REPLACE
	alert_type = /obj/screen/alert/status_effect/belligerent
	var/leg_damage_on_toggle = 2 //damage on initial application and when the owner tries to toggle to run
	var/cultist_damage_on_toggle = 10 //damage on initial application and when the owner tries to toggle to run, but to cultists

/obj/screen/alert/status_effect/belligerent
	name = "Belligerent"
	desc = "<b><font color=#880020>Kneel, her-eti'c.</font></b>"
	icon_state = "belligerent"
	alerttooltipstyle = "clockcult"

/datum/status_effect/belligerent/on_apply()
	return do_movement_toggle(TRUE)

/datum/status_effect/belligerent/tick()
	if(!do_movement_toggle())
		qdel(src)

/datum/status_effect/belligerent/proc/do_movement_toggle(force_damage)
	var/number_legs = owner.get_num_legs()
	if(iscarbon(owner) && !is_servant_of_ratvar(owner) && !owner.null_rod_check() && number_legs)
		if(force_damage || owner.m_intent != MOVE_INTENT_WALK)
			if(GLOB.ratvar_awakens)
				owner.Weaken(1)
			if(iscultist(owner))
				owner.apply_damage(cultist_damage_on_toggle * 0.5, BURN, "l_leg")
				owner.apply_damage(cultist_damage_on_toggle * 0.5, BURN, "r_leg")
			else
				owner.apply_damage(leg_damage_on_toggle * 0.5, BURN, "l_leg")
				owner.apply_damage(leg_damage_on_toggle * 0.5, BURN, "r_leg")
		if(owner.m_intent != MOVE_INTENT_WALK)
			if(!iscultist(owner))
				to_chat(owner, "<span class='warning'>Your leg[number_legs > 1 ? "s shiver":" shivers"] with pain!</span>")
			else //Cultists take extra burn damage
				to_chat(owner, "<span class='warning'>Your leg[number_legs > 1 ? "s burn":" burns"] with pain!</span>")
			owner.toggle_move_intent()
		return TRUE
	return FALSE

/datum/status_effect/belligerent/on_remove()
	if(owner.m_intent == MOVE_INTENT_WALK)
		owner.toggle_move_intent()
