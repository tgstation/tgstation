//Disables nearby tech equipment.

/datum/action/item_action/ninjapulse
	name = "EM Burst (50E)"
	desc = "Disable any nearby technology with an electro-magnetic pulse."
	button_icon_state = "emp"
	icon_icon = 'icons/mob/actions/actions_spells.dmi'

/**
 * Proc called to allow the ninja to EMP the nearby area.
 *
 * Proc called to allow the ninja to EMP the nearby area.  By default, costs 500E, which is half of the default battery's max charge.
 * Also affects the ninja as well.
 */
/obj/item/clothing/suit/space/space_ninja/proc/ninjapulse()
	if(ninjacost(500,N_STEALTH_CANCEL))
		return
	var/mob/living/carbon/human/H = affecting
	playsound(H.loc, 'sound/effects/empulse.ogg', 60, 2)
	empulse(H, 4, 6) //Procs sure are nice. Slightly weaker than wizard's disable tch.
	s_coold = 4
