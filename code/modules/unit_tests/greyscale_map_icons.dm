/datum/unit_test/greyscale_map_icons

/datum/unit_test/greyscale_map_icons/Run()
	var/list/cached_icon_states = list() // Lots of things will be getting icon states from the same dmi, may as well speed it up

	for(var/atom/fake as anything in typesof(/atom))
		if(!fake::greyscale_config || !fake::greyscale_colors)
			continue
		if(fake::icon_state != "[fake]")
			TEST_FAIL("'[fake]' has a GAGS generated appearance but does not set its icon state to be the same as the typepath. This will make map tool graphics for the item fail.")
			continue
		var/list/icon_states = cached_icon_states[fake::icon]
		if(!icon_states)
			var/icon/default_icon = fake::icon
			icon_states = cached_icon_states[fake::icon] = default_icon.IconStates()
		if(!(fake::icon_state in icon_states))
			TEST_FAIL("The icon file for '[fake]' does not have an icon state for the object. Likely this is because it is the wrong icon file, make sure to reference the right file in 'icons/map_icons/'.")
