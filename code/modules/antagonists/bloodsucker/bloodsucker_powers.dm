


/datum/action/bloodsucker
	name = "Bloodsucker Power"//"Cellular Emporium"
	background_icon_state = "bg_changeling"
	icon_icon = 'icons/mob/actions/actions_changeling.dmi'


	// Action-Related
	var/active = FALSE
	var/amToggle = FALSE
	var/cooldown = 20
	//icon_icon = 'icons/obj/drinks.dmi'
	//button_icon_state = "changelingsting"
	//background_icon_state = "bg_changeling"

	// Power-Related
	var/powerlevel = 1		// Can increase to yield new abilities
	var/bloodcost = 10
	var/needs_button = TRUE // Taken from Changeling - for passive abilities that dont need a button


///datum/action/bloodsucker/proc/GivePower(mob/user)
//	Grant(user) // (from Changeling) how powers are added rather than the checks in mob.dm

///datum/action/bloodsucker/proc/RemovePower(mob/user)
//
//	Remove(user)




//							NOTES
//
// 	click.dm <--- Where we can take over mouse clicks to have
//	spells.dm  /add_ranged_ability()  <--- How we take over the mouse click to use a power on a target.



/datum/action/bloodsucker/Trigger()

	// Active? DEACTIVATE AND END!
	if (active && CheckCanDeactivate(TRUE))
		DeactivatePower()
		return

	if(!owner || !owner.mind || !owner.mind.has_antag_datum(/datum/antagonist/bloodsucker))
		return

	if (!CheckCanUse(TRUE))
		return

	PayCost()

	if (amToggle)
		active = !active

	ActivatePower()

	to_chat(owner, "You use [name]!")


/datum/action/bloodsucker/proc/CheckCanUse(display_error)
	// owner for actions is the mob, not mind.
	var/mob/living/L = owner

	// Have enough blood?
	if (L.blood_volume < bloodcost)
		if (display_error)
			to_chat(L, "You need at least [bloodcost] blood to activate [name]!</span>")
		return FALSE

	return TRUE


/datum/action/bloodsucker/proc/CheckCanDeactivate(display_error)
	return TRUE



/datum/action/bloodsucker/proc/PayCost()
	// owner for actions is the mob, not mind.
	var/mob/living/L = owner
	L.blood_volume -= bloodcost


/datum/action/bloodsucker/proc/ActivatePower()



/datum/action/bloodsucker/proc/DeactivatePower(mob/living/user = owner, mob/living/target)
	active = FALSE


/datum/action/bloodsucker/feed/proc/ContinueActive(mob/living/user) // Used by loops to make sure this power can stay active.
	return active && user.mind && user.mind.has_antag_datum(ANTAG_DATUM_BLOODSUCKER)
