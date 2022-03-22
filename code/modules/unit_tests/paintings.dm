///Checks that all kind of painting frames have a sprite for each canvas type in the game.
/datum/unit_test/paintings

/datum/unit_test/paintings/Run()
	for(var/obj/item/canvas/canvas_prototype as anything in typesof(/obj/item/canvas))
		var/canvas_icons = icon_states(initial(canvas_prototype.icon))
		var/canvas_icon_state = initial(canvas_prototype.icon_state)
		for(var/frame_type in SSpersistent_paintings.frame_types_by_patronage_tier)
			if(!("[canvas_icon_state]frame_[frame_type]" in canvas_icons))
				Fail("Canvas [canvas_icon_state] doesn't have an icon state for frame: [frame_type].")
