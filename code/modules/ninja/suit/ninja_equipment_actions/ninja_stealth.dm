/datum/action/item_action/ninja_stealth
	name = "Toggle Stealth"
	desc = "Toggles stealth mode on and off."
	button_icon_state = "ninja_cloak"
	icon_icon = 'icons/mob/actions/actions_minor_antag.dmi'

/**
 * Proc called to toggle ninja stealth.
 *
 * Proc called to toggle whether or not the ninja is in stealth mode.
 * If cancelling, calls a separate proc in case something else needs to quickly cancel stealth.
 */
/obj/item/clothing/suit/space/space_ninja/proc/toggle_stealth()
	var/mob/living/carbon/human/ninja = affecting
	if(!ninja)
		return
	if(stealth)
		cancel_stealth()
	else
		if(cell.charge <= 0)
			to_chat(ninja, "<span class='warning'>You don't have enough power to enable Stealth!</span>")
			return
		stealth = !stealth
		animate(ninja, alpha = 20,time = 12)
		ninja.visible_message("<span class='warning'>[ninja.name] vanishes into thin air!</span>", \
						"<span class='notice'>You are now mostly invisible to normal detection.</span>")

/**
 * Proc called to cancel stealth.
 *
 * Called to cancel the stealth effect if it is ongoing.
 * Does nothing otherwise.
 * Arguments:
 * * Returns false if either the ninja no longer exists or is already visible, returns true if we successfully made the ninja visible.
 */
/obj/item/clothing/suit/space/space_ninja/proc/cancel_stealth()
	var/mob/living/carbon/human/ninja = affecting
	if(!ninja)
		return FALSE
	if(stealth)
		stealth = !stealth
		animate(ninja, alpha = 255, time = 12)
		ninja.visible_message("<span class='warning'>[ninja.name] appears from thin air!</span>", \
						"<span class='notice'>You are now visible.</span>")
		return TRUE
	return FALSE
