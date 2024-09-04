/datum/unit_test/greyscale_map_icons

/datum/unit_test/greyscale_map_icons/Run()
	var/list/cached_icon_states = list() // Lots of things will be getting icon states from the same dmi, may as well speed it up

	for(var/atom/fake as anything in typesof(/atom))
		if(!fake::greyscale_config || !fake::greyscale_colors)
			continue
		var/atom/fake_parent = fake::parent_type
		// As long as the config, colors, and post init icon state are the same, you should use the same map icon
		if(ispath(fake_parent, /atom) && fake::greyscale_config == fake_parent::greyscale_config && fake::greyscale_colors == fake_parent::greyscale_colors && fake::post_init_icon_state == fake_parent::post_init_icon_state)
			if(fake::icon != fake_parent::icon)
				TEST_FAIL("'[fake]' has a different icon defined even though that will do nothing since it has GAGS configured on a parent type.")
			if(fake::icon_state != fake_parent::icon_state)
				TEST_FAIL("'[fake]' has a different icon state defined. It should be the same as parent since both use the same map icon.")
			continue // It can use the same icon as the parent just fine
		if(fake::icon_state != "[fake]")
			TEST_FAIL("'[fake]' has a GAGS generated appearance but does not set its icon state to be the same as the typepath. This will make map graphics for the item fail.")
			continue
		var/list/icon_states = cached_icon_states[fake::icon]
		if(!icon_states)
			// 'fake::icon' occasionally fails to give an icon object even when the value is in single quotes, icon(icon) is safe so this fixes the issue
			var/icon/default_icon = icon(fake::icon)
			icon_states = cached_icon_states[fake::icon] = default_icon.IconStates()
		if(!(fake::icon_state in icon_states))
			TEST_FAIL("The icon file for '[fake]' does not have an icon state for the object. Likely this is because it is the wrong icon file, make sure to reference the right file in 'icons/map_icons/'.")
