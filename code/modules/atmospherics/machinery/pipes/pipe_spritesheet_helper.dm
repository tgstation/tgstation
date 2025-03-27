ADMIN_VERB(generate_pipe_spritesheet, R_DEBUG, "Generate Pipe Spritesheet", "Generates the pipe spritesheets.", ADMIN_CATEGORY_DEBUG)
	var/datum/pipe_icon_generator/generator = new
	generator.Start()
	fcopy(generator.generated_icons, "icons/obj/pipes_n_cables/!pipes_bitmask.dmi")

	generator.Start("-gas")
	fcopy(generator.generated_icons, "icons/obj/pipes_n_cables/!pipe_gas_overlays.dmi")

/datum/pipe_icon_generator
	var/static/icon/template_pieces = icon('icons/obj/pipes_n_cables/pipe_template_pieces.dmi')
	var/static/list/icon/damage_masks = list(
		"[NORTH]"=icon('icons/obj/pipes_n_cables/pipe_template_pieces.dmi', "damage_mask", NORTH),
		"[EAST]"=icon('icons/obj/pipes_n_cables/pipe_template_pieces.dmi', "damage_mask", EAST),
		"[SOUTH]"=icon('icons/obj/pipes_n_cables/pipe_template_pieces.dmi', "damage_mask", SOUTH),
		"[WEST]"=icon('icons/obj/pipes_n_cables/pipe_template_pieces.dmi', "damage_mask", WEST),
	)

	var/static/list/icon/cap_masks = list(
		"[NORTH]" = icon('icons/obj/pipes_n_cables/pipe_template_pieces.dmi', "cap_mask", NORTH),
		"[EAST]" = icon('icons/obj/pipes_n_cables/pipe_template_pieces.dmi', "cap_mask", EAST),
		"[SOUTH]" = icon('icons/obj/pipes_n_cables/pipe_template_pieces.dmi', "cap_mask", SOUTH),
		"[WEST]" = icon('icons/obj/pipes_n_cables/pipe_template_pieces.dmi', "cap_mask", WEST),
	)

	var/icon/generated_icons

/datum/pipe_icon_generator/proc/Start(icon_state_suffix="")
	var/list/outputs = list()
	for(var/layer in 1 to 5)
		// Since dirs are bitflags, if we want to iterate over every possible direction
		// combination we just need to iterate over every number that can be contained in 4 bits.
		//
		// I wrote this all the hard way originally >.>
		for(var/combined_dirs in 1 to 15)
			switch(combined_dirs)
				if(NORTH, EAST, SOUTH, WEST)
					continue

			outputs += GeneratePipeDir(icon_state_suffix, layer, combined_dirs)

	generated_icons = icon('icons/testing/greyscale_error.dmi')
	for(var/icon/generated_icon as anything in outputs)
		var/pending_icon_state = outputs[generated_icon]
		generated_icons.Insert(generated_icon, pending_icon_state)

/datum/pipe_icon_generator/proc/GeneratePipeDir(icon_state_suffix, layer, combined_dirs)
	var/list/output

	switch(combined_dirs)
		if(NORTH | SOUTH, EAST | WEST)
			output = GeneratePipeStraight(icon_state_suffix, layer, combined_dirs)
		if(NORTH | EAST, SOUTH | EAST, SOUTH | WEST, NORTH | WEST)
			output = GeneratePipeElbow(icon_state_suffix, layer, combined_dirs)
		if(NORTH | EAST | SOUTH, EAST | SOUTH | WEST, SOUTH | WEST | NORTH, WEST | NORTH | EAST)
			output = GeneratePipeTJunction(icon_state_suffix, layer, combined_dirs)
		if(NORTH | EAST | SOUTH | WEST)
			output = GeneratePipeCross(icon_state_suffix, layer, combined_dirs)

	var/shift_amount = (layer - 1) * 5
	for(var/icon/sprite as anything in output)
		if(shift_amount > 0)
			sprite.Shift(EAST, shift_amount)
			sprite.Shift(NORTH, shift_amount)
		sprite.Crop(33, 33, 64, 64)

	return output

/// Generates all variants of damaged pipe from a given icon and the dirs that can be broken
/datum/pipe_icon_generator/proc/GenerateDamaged(icon/working, layer, dirs, x_offset=1, y_offset=1)
	var/outputs = list()
	var/completed = list()
	for(var/combined_dirs in 1 to 15)
		combined_dirs &= dirs

		var/completion_key = "[combined_dirs]"
		if(completed[completion_key] || (combined_dirs == NONE))
			continue
		completed[completion_key] = TRUE

		var/icon/damaged = icon(working)
		for(var/i in 0 to 3)
			var/dir = 1 << i
			if(!(combined_dirs & dir))
				continue
			var/icon/damage_mask = damage_masks["[dir]"]
			damaged.Blend(damage_mask, ICON_MULTIPLY, x_offset, y_offset)

		var/icon_state_dirs = (dirs & ~combined_dirs) | CARDINAL_TO_SHORTPIPES(combined_dirs)
		outputs[damaged] = "[icon_state_dirs]_[layer]"
	return outputs

/datum/pipe_icon_generator/proc/generate_capped(icon/working, layer, dirs, x_offset=1, y_offset=1)
	var/list/outputs = list()
	var/list/completed = list()
	for(var/combined_dirs in 1 to 15)
		combined_dirs &= dirs

		var/completion_key = "[combined_dirs]"
		if(completed[completion_key] || (combined_dirs == NONE))
			continue

		completed[completion_key] = TRUE

		var/icon/capped_mask = icon('icons/obj/pipes_n_cables/pipe_template_pieces.dmi', "blank_mask")
		for(var/i in 0 to 3)
			var/dir = 1 << i
			if(!(combined_dirs & dir))
				continue

			var/icon/cap_mask = cap_masks["[dir]"]
			capped_mask.Blend(cap_mask, ICON_OVERLAY, x_offset, y_offset)

		var/icon/capped = icon(working)
		capped.Blend(capped_mask, ICON_MULTIPLY)

		var/icon_state_dirs = (dirs & ~combined_dirs) | CARDINAL_TO_PIPECAPS(combined_dirs)
		outputs[capped] = "[icon_state_dirs]_[layer]"

	return outputs

/datum/pipe_icon_generator/proc/GeneratePipeStraight(icon_state_suffix, layer, combined_dirs)
	var/list/output = list()
	var/north_or_east = combined_dirs & (NORTH | EAST)
	var/icon/working = icon(template_pieces, "straight[icon_state_suffix]", north_or_east)

	output[working] = "[combined_dirs]_[layer]"

	var/offset = 1 + (5-layer) * 2
	switch(combined_dirs)
		if(NORTH | SOUTH)
			output += GenerateDamaged(working, layer, combined_dirs, y_offset=offset)
			output += generate_capped(working, layer, combined_dirs, y_offset=offset)
		if(EAST | WEST)
			output += GenerateDamaged(working, layer, combined_dirs, x_offset=offset)
			output += generate_capped(working, layer, combined_dirs, x_offset=offset)

	return output

/datum/pipe_icon_generator/proc/GeneratePipeElbow(icon_state_suffix, layer, combined_dirs)
	var/list/output = list()
	var/icon/working
	switch(combined_dirs)
		if(NORTH | EAST)
			working = icon(template_pieces, "elbow[icon_state_suffix]", NORTH)
		if(NORTH | WEST)
			working = icon(template_pieces, "elbow[icon_state_suffix]", WEST)
		if(SOUTH | EAST)
			working = icon(template_pieces, "elbow[icon_state_suffix]", EAST)
		if(SOUTH | WEST)
			working = icon(template_pieces, "elbow[icon_state_suffix]", SOUTH)

	output[working] = "[combined_dirs]_[layer]"
	output += GenerateDamaged(working, layer, combined_dirs)
	output += generate_capped(working, layer, combined_dirs)

	return output

/datum/pipe_icon_generator/proc/GeneratePipeTJunction(icon_state_suffix, layer, combined_dirs)
	var/list/output = list()
	var/icon/working
	switch(combined_dirs)
		if(WEST | NORTH | EAST)
			working = icon(template_pieces, "tee[icon_state_suffix]", NORTH)
		if(NORTH | EAST | SOUTH)
			working = icon(template_pieces, "tee[icon_state_suffix]", EAST)
		if(EAST | SOUTH | WEST)
			working = icon(template_pieces, "tee[icon_state_suffix]", SOUTH)
		if(SOUTH | WEST | NORTH)
			working = icon(template_pieces, "tee[icon_state_suffix]", WEST)

	output[working] = "[combined_dirs]_[layer]"
	output += GenerateDamaged(working, layer, combined_dirs)
	output += generate_capped(working, layer, combined_dirs)

	return output

/datum/pipe_icon_generator/proc/GeneratePipeCross(icon_state_suffix, layer, combined_dirs)
	var/list/output = list()
	var/icon/working = icon(template_pieces, "cross[icon_state_suffix]")

	output[working] = "[combined_dirs]_[layer]"
	output += GenerateDamaged(working, layer, combined_dirs)
	output += generate_capped(working, layer, combined_dirs)

	return output
