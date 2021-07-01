/**
 * Proc called to check if the ninja can afford an ability's cost.
 *
 * Proc which determine whether or not a space ninja can afford to use a specific ability.
 * It can also cancel stealth if the ability requested it.
 * Arguments:
 * * cost - the energy cost of the ability
 * * specificCheck - Determines if the check is a normal one, an adrenaline one, or a stealth cancel check.
 * * Returns TRUE or the current cooldown timer if we can't perform the ability, and FALSE if we can.
 */
/obj/item/clothing/suit/space/space_ninja/proc/ninjacost(cost = 0, specificCheck = 0)
	var/mob/living/carbon/human/ninja = affecting
	var/actualCost = cost*10
	if(cost && cell.charge < actualCost)
		to_chat(ninja, "<span class='warning'>Not enough energy!</span>")
		return TRUE
	else
		//This shit used to be handled individually on every proc.. why even bother with a universal check proc then?
		cell.charge-=(actualCost)

	switch(specificCheck)
		if(N_STEALTH_CANCEL)
			cancel_stealth()//Get rid of it.
		if(N_ADRENALINE)
			if(!a_boost)
				to_chat(ninja, "<span class='warning'>You do not have any more adrenaline boosters!</span>")
				return TRUE
	return (s_coold)//Returns the value of the variable which counts down to zero.
