/datum/action/cooldown/borer/toggle_hiding
	name = "Toggle Hiding"
	button_icon_state = "hide"
	var/hidden = FALSE
	ability_explanation = "\
	Turns your hiding abilities on/off\n\
	Whilst on, you will hide under most objects, like tables.\n\
	If you are a diveworm, you will bore into hosts twice as fast whilst not hidden\n\
	"
	// -2 plane to make the borer move into or out of the WALL_PLANE and its original plane irrespective of level offset
/datum/action/cooldown/borer/toggle_hiding/Trigger(trigger_flags, atom/target)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/basic/cortical_borer/cortical_owner = owner
	if(hidden == FALSE)
		cortical_owner.upgrade_flags |= BORER_HIDING
		owner.balloon_alert(owner, "started hiding")
		owner.plane -= 2
		hidden  = TRUE
		ADD_TRAIT(owner, TRAIT_IGNORE_ELEVATION, ACTION_TRAIT)
	else
		cortical_owner.upgrade_flags &= ~BORER_HIDING
		owner.balloon_alert(owner, "stopped hiding")
		owner.plane +=2
		hidden = FALSE
		REMOVE_TRAIT(owner, TRAIT_IGNORE_ELEVATION, ACTION_TRAIT)
	StartCooldown()
  