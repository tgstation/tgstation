/**
 * Test if icon states for each datum actually exist in the DMI.
 */
/datum/unit_test/barsigns_icon

/datum/unit_test/barsigns_icon/Run()
	var/obj/structure/sign/barsign_type = /obj/structure/sign/barsign
	var/icon/barsign_icon = initial(barsign_type.icon)
	var/list/barsign_icon_states = icon_states(barsign_icon)

	// Check every datum real bar sign
	for(var/sign_type in (subtypesof(/datum/barsign) - /datum/barsign/hiddensigns))
		var/datum/barsign/sign = new sign_type()

		if(!(sign.icon in barsign_icon_states))
			TEST_FAIL("Icon state for [sign_type] does not exist in [barsign_icon].")

/**
 * Check that bar signs have a name and desc, and that the name is unique.
 */
/datum/unit_test/barsigns_name

/datum/unit_test/barsigns_name/Run()
	var/list/existing_names = list()

	for(var/sign_type in subtypesof(/datum/barsign) - /datum/barsign/hiddensigns)
		var/datum/barsign/sign = new sign_type()

		if(!sign.name)
			TEST_FAIL("[sign_type] does not have a name.")
		if(!sign.desc)
			TEST_FAIL("[sign_type] does not have a desc.")

		if(sign.name in existing_names)
			TEST_FAIL("[sign_type] does not have a unique name.")

		existing_names += sign.name
