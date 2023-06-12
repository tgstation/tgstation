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
		check_hallucination_icon(hallucination, left_icon, icon_state)
		check_hallucination_icon(hallucination, right_icon, icon_state)

	// Test preset delusion hallucinations for invalid image setups
	for(var/datum/hallucination/delusion/preset/hallucination as anything in subtypesof(/datum/hallucination/delusion/preset))
		if(initial(hallucination.dynamic_icon))
			continue
		var/icon = initial(hallucination.delusion_icon_file)
		var/icon_state = initial(hallucination.delusion_icon_state)
		check_hallucination_icon(hallucination, icon, icon_state)

	// Test fake body hallucinations
	for(var/datum/hallucination/body/husk/hallucination as anything in subtypesof(/datum/hallucination/body/husk))
		var/icon = initial(hallucination.body_image_file)
		var/icon_state = initial(hallucination.body_image_state)
		check_hallucination_icon(hallucination, icon, icon_state)

	// Test on_fire hallucination for if the fire icon state exists
	var/datum/hallucination/fire/fire_hallucination = /datum/hallucination/fire
	var/fire_hallucination_icon = initial(fire_hallucination.fire_icon)
	var/fire_hallucination_icon_state = initial(fire_hallucination.fire_icon_state)
	check_hallucination_icon(fire_hallucination, fire_hallucination_icon, fire_hallucination_icon_state)

	// Test shock hallucination for if the shock icon state exists
	var/datum/hallucination/shock/shock_hallucination = /datum/hallucination/shock
	var/shock_hallucination_icon = initial(shock_hallucination.electrocution_icon)
	var/shock_hallucination_icon_state = initial(shock_hallucination.electrocution_icon_state)
	check_hallucination_icon(shock_hallucination, shock_hallucination_icon, shock_hallucination_icon_state)

	// Test fake_flood hallucination for if its fake plasmaflood icon exists
	var/datum/hallucination/fake_flood/flood_hallucination = /datum/hallucination/fake_flood
	var/flood_hallucination_icon = initial(flood_hallucination.image_icon)
	var/flood_hallucination_icon_state = initial(flood_hallucination.image_state)
	check_hallucination_icon(flood_hallucination, flood_hallucination_icon, flood_hallucination_icon_state)

	// Test hallucination client_image_holders that are used for various hallucinations (bubblegum, xeno attack)
	for(var/obj/effect/client_image_holder/hallucination/image_holder as anything in subtypesof(/obj/effect/client_image_holder/hallucination))
		var/icon = initial(image_holder.image_icon)
		var/icon_state = initial(image_holder.image_state)
		if(!icon_state || !icon)
			// Not having an icon_state or icon set by default is okay, for these.
			continue

		if(icon_exists(icon, icon_state))
			continue

		TEST_FAIL("Hallucination image holder [image_holder] had an invalid / missing icon state for the icon [icon].")

	// Test ice hallucination for if the ice cube icon state exists
	var/datum/hallucination/ice/ice_hallucination = /datum/hallucination/ice
	var/ice_hallucination_icon = initial(ice_hallucination.ice_icon)
	var/ice_hallucination_icon_state = initial(ice_hallucination.ice_icon_state)
	check_hallucination_icon(ice_hallucination, ice_hallucination_icon, ice_hallucination_icon_state)

/datum/unit_test/hallucination_icons/proc/check_hallucination_icon(hallucination, icon, icon_state)
	if(!icon)
		TEST_FAIL("Hallucination [hallucination] forgot to set its icon file.")
	if(!icon_state)
		TEST_FAIL("Hallucination [hallucination] forgot to set an icon state.")
	if(!icon || !icon_state || icon_exists(icon, icon_state))
		return
	TEST_FAIL("Hallucination [hallucination] has an invalid icon_state ([icon_state]) for its icon ([icon]).")
