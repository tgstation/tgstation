/datum/action/item_action/ninja_sword_recall
	name = "Recall Energy Katana (Variable Cost)"
	desc = "Teleports the Energy Katana linked to this suit to its wearer, cost based on distance."
	button_icon_state = "energy_katana"
	icon_icon = 'icons/obj/items_and_weapons.dmi'

/**
 * Proc called to recall the ninja's sword.
 *
 * Called to summon the ninja's katana back to them
 * If the katana can see the ninja, it will throw itself towards them.
 * If not, the katana will teleport itself to the ninja.
 */
/obj/item/clothing/suit/space/space_ninja/proc/ninja_sword_recall()
	var/mob/living/carbon/human/ninja = affecting
	var/cost = 0
	var/inview = TRUE

	if(!energyKatana)
		to_chat(ninja, "<span class='warning'>Could not locate Energy Katana!</span>")
		return

	if(energyKatana in ninja)
		return

	var/distance = get_dist(ninja,energyKatana)

	if(!(energyKatana in view(ninja)))
		cost = distance //Actual cost is cost x 10, so 5 turfs is 50 cost.
		inview = FALSE

	if(!ninjacost(cost))
		if(iscarbon(energyKatana.loc))
			var/mob/living/carbon/sword_holder = energyKatana.loc
			sword_holder.transferItemToLoc(energyKatana, get_turf(energyKatana), TRUE)

		else
			energyKatana.forceMove(get_turf(energyKatana))

		if(inview) //If we can see the katana, throw it towards ourselves, damaging people as we go.
			energyKatana.spark_system.start()
			playsound(ninja, "sparks", 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
			ninja.visible_message("<span class='danger'>\the [energyKatana] flies towards [ninja]!</span>","<span class='warning'>You hold out your hand and \the [energyKatana] flies towards you!</span>")
			energyKatana.throw_at(ninja, distance+1, energyKatana.throw_speed, ninja)

		else //Else just TP it to us.
			energyKatana.returnToOwner(ninja, 1)
