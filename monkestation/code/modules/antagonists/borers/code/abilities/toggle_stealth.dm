/datum/action/cooldown/borer/toggle_hiding
	name = "Toggle Hiding"
	button_icon_state = "hide"
	var/hide_layer = ABOVE_NORMAL_TURF_LAYER
	var/hide_plane = WALL_PLANE
	ability_explanation = "\
	Turns your hiding abilities on/off\n\
	Whilst on, you will hide under most objects, like tables.\n\
	If you are a diveworm, you will bore into hosts twice as fast whilst not hidden\n\
	"
	// WALL_PLANE lets the borer hide under tables
/datum/action/cooldown/borer/toggle_hiding/Trigger(trigger_flags, atom/target)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/basic/cortical_borer/cortical_owner = owner
	if(owner.layer != hide_layer)
		cortical_owner.upgrade_flags |= BORER_HIDING
		owner.balloon_alert(owner, "started hiding")
		owner.layer = hide_layer
		owner.plane = WALL_PLANE

		ADD_TRAIT(owner, TRAIT_IGNORE_ELEVATION, ACTION_TRAIT)
	else
		cortical_owner.upgrade_flags &= ~BORER_HIDING
		owner.balloon_alert(owner, "stopped hiding")
		owner.layer = BELOW_MOB_LAYER
		owner.plane = initial(owner.plane)
		REMOVE_TRAIT(owner, TRAIT_IGNORE_ELEVATION, ACTION_TRAIT)
	StartCooldown()
