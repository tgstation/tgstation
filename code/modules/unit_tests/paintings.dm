///Checks that all kind of painting frames have a sprite for each canvas type in the game.
/datum/unit_test/paintings

/datum/unit_test/paintings/Run()
	for(var/obj/item/canvas/canvas as anything in typesof(/obj/item/canvas))
		canvas = new canvas
		var/canvas_icons = icon_states(canvas.frame_icon)
		for(var/frame_type in SSpersistent_paintings.frame_types_by_patronage_tier)
			var/complete_icon_state = "[canvas.icon_state]frame_[frame_type]"
			if(!(complete_icon_state in canvas_icons))
				TEST_FAIL("Canvas [canvas.icon_state] doesn't have an icon state for '[frame_type]': '[complete_icon_state]'.")
