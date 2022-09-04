/**
 * Unit tests various image related hallucinations
 * that their icon_states and icons still exist,
 * as often hallucinations are copy and pasted
 * implementations of existing image setups
 * that may be changed and not updated.
 */
/datum/unit_test/hallucination_icons

/datum/unit_test/hallucination_icons/Run()

	// Test nearby_fake_item hallucinations for invalid image setups
	for(var/datum/hallucination/nearby_fake_item/hallucination as anything in subtypesof(/datum/hallucination/nearby_fake_item))
		var/left_icon = initial(hallucination.left_hand_file)
		var/right_icon = initial(hallucination.right_hand_file)
		var/icon_state = initial(hallucination.image_icon_state)
		if(!icon_state)
			Fail("Hallucination [hallucination] forgot to set an icon state.")
			continue
		if(!left_icon || !right_icon)
			Fail("Hallucination [hallucination] forgot to set its icon files.")
			continue

		if(!icon_exists(left_icon, icon_state))
			Fail("Hallucination [hallucination] had an invalid icon_state ([icon_state]) in its left icon file ([left_icon]).")
		if(!icon_exists(right_icon, icon_state))
			Fail("Hallucination [hallucination] had an invalid icon_state ([icon_state]) in its right icon file ([right_icon]).")

	// Test preset delusion hallucinations for invalid image setups
	for(var/datum/hallucination/delusion/preset/hallucination as anything in subtypesof(/datum/hallucination/delusion/preset))
		var/icon = initial(hallucination.delusion_icon_file)
		var/icon_state = initial(hallucination.delusion_icon_state)
		if(!icon_state)
			Fail("Hallucination [hallucination] forgot to set an icon state.")
			continue
		if(!icon)
			Fail("Hallucination [hallucination] forgot to set its icon file.")
			continue

		if(icon_exists(icon, icon_state))
			continue
		Fail("Hallucination [hallucination] has an invalid icon_state ([icon_state]) for its delusion ([icon]).")

	// Test on_fire hallucination for if the fire icon state exists
	var/datum/hallucination/fire/fire_hallucination = /datum/hallucination/fire
	var/fire_hallucination_icon = initial(fire_hallucination.fire_icon)
	var/fire_hallucination_icon_state = initial(fire_hallucination.fire_icon_state)
	if(!fire_hallucination_icon || !fire_hallucination_icon_state)
		Fail("Hallucination [fire_hallucination] didn't have a valid overlay setup.")

	else if(!icon_exists(fire_hallucination_icon, fire_hallucination_icon_state))
		Fail("Hallucination [fire_hallucination] didn't have its icon_state ([fire_hallucination_icon_state]) located in its icon file ([fire_hallucination_icon]).")

	// Test shock hallucination for if the shock icon state exists
	var/datum/hallucination/shock/shock_hallucination = /datum/hallucination/shock
	var/shock_hallucination_icon = initial(shock_hallucination.electrocution_icon)
	var/shock_hallucination_icon_state = initial(shock_hallucination.electrocution_icon_state)
	if(!shock_hallucination_icon || !shock_hallucination_icon_state)
		Fail("Hallucination [shock_hallucination] didn't have a valid overlay setup.")

	else if(!icon_exists(shock_hallucination_icon, shock_hallucination_icon_state))
		Fail("Hallucination [shock_hallucination] didn't have its icon_state ([shock_hallucination_icon_state]) located in its icon file ([shock_hallucination_icon]).")

	// Test fake_flood hallucination for if its fake plasmaflood icon exists
	var/datum/hallucination/fake_flood/flood_hallucination = /datum/hallucination/fake_flood
	var/flood_hallucination_icon = initial(flood_hallucination.image_icon)
	var/flood_hallucination_icon_state = initial(flood_hallucination.image_state)
	if(!flood_hallucination_icon || !flood_hallucination_icon_state)
		Fail("Hallucination [flood_hallucination] didn't have a valid image holder setup.")

	else if(!icon_exists(flood_hallucination_icon, flood_hallucination_icon_state))
		Fail("Hallucination [flood_hallucination] didn't have its image icon_state ([flood_hallucination_icon_state]) located in its image icon file ([flood_hallucination_icon]).")

	// Test hallucination client_image_holders that are used for various hallucinations (bubblegum, xeno attack)
	for(var/obj/effect/client_image_holder/hallucination/image_holder as anything in subtypesof(/obj/effect/client_image_holder/hallucination))
		var/icon = initial(image_holder.image_icon)
		var/icon_state = initial(image_holder.image_state)
		if(!icon_state || !icon)
			// Not having an icon_state or icon set by default is okay, for these.
			continue

		if(icon_exists(icon, icon_state))
			continue

		Fail("Hallucination image holder [image_holder] had an invalid / missing icon state for the icon [icon].")
