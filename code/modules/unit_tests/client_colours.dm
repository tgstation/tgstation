///Checks that client colours have valid colour variables values at least when inited.
/datum/unit_test/client_colours

/datum/unit_test/client_colours/Run()
	for(var/datum/client_colour/colour as anything in subtypesof(/datum/client_colour))
		// colours can be color matrices (lists), which initial() cannot read.
		colour = new colour
		if(!color_to_full_rgba_matrix(colour.colour, FALSE))
			TEST_FAIL("[colour.type] has an invalid default colour value: [colour.colour]")
