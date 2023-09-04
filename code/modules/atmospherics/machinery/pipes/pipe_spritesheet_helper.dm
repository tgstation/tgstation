/client/proc/GeneratePipeSpritesheet()
	set name = "Generate Pipe Spritesheet"
	set category = "Debug"

	var/datum/pipe_icon_generator/generator = new
	generator.Start()
	fcopy(generator.generated_icons, "icons/obj/pipes_n_cables/!pipes_bitmask.dmi")
	fcopy(generator.generated_gas_overlays, "icons/obj/pipes_n_cables/!pipe_gas_overlays.dmi")

/datum/pipe_icon_generator
	var/static/icon/template_pieces = icon('icons/obj/pipes_n_cables/pipe_template_pieces.dmi')
	var/static/list/icon/damage_masks = list(
		"[NORTH]"=icon('icons/obj/pipes_n_cables/pipe_template_pieces.dmi', "damage_mask", NORTH),
		"[EAST]"=icon('icons/obj/pipes_n_cables/pipe_template_pieces.dmi', "damage_mask", EAST),
		"[SOUTH]"=icon('icons/obj/pipes_n_cables/pipe_template_pieces.dmi', "damage_mask", SOUTH),
		"[WEST]"=icon('icons/obj/pipes_n_cables/pipe_template_pieces.dmi', "damage_mask", WEST),
	)

	var/icon/generated_icons = icon('icons/testing/greyscale_error.dmi')
	var/icon/generated_gas_overlays = icon('icons/testing/greyscale_error.dmi')
	var/list/generated_icons_queue
	var/list/generated_gas_queue

/datum/pipe_icon_generator/proc/Start()
	for(var/layer in 1 to 5)
		// Since dirs are bitflags, if we want to iterate over every possible direction
		// combination we just need to iterate over every number that can be contained in 4 bits.
		//
		// I wrote this all the hard way originally >.>
		for(var/combined_dirs in 1 to 15)
			switch(combined_dirs)
				if(NORTH, EAST, SOUTH, WEST)
					continue

			GeneratePipeDir(layer, combined_dirs)

/datum/pipe_icon_generator/proc/GeneratePipeDir(layer, combined_dirs)
	generated_icons_queue = list()
	generated_gas_queue = list()

	switch(combined_dirs)
		if(NORTH | SOUTH, EAST | WEST)
			GeneratePipeStraight(layer, combined_dirs)
		if(NORTH | EAST, SOUTH | EAST, SOUTH | WEST, NORTH | WEST)
			GeneratePipeElbow(layer, combined_dirs)
		if(NORTH | EAST | SOUTH, EAST | SOUTH | WEST, SOUTH | WEST | NORTH, WEST | NORTH | EAST)
			GeneratePipeTJunction(layer, combined_dirs)
		if(NORTH | EAST | SOUTH | WEST)
			GeneratePipeCross(layer, combined_dirs)

	Finalize(generated_icons, generated_icons_queue, layer, combined_dirs)
	Finalize(generated_gas_overlays, generated_gas_queue, layer, combined_dirs)

/datum/pipe_icon_generator/proc/Finalize(icon/spritesheet, list/queue, layer, combined_dirs)
	var/shift_amount = (layer - 1) * 5
	for(var/icon/output as anything in queue)
		if(shift_amount > 0)
			output.Shift(EAST, shift_amount)
			output.Shift(NORTH, shift_amount)
		output.Crop(33, 33, 64, 64)

		var/broken_dirs = queue[output]
		var/state_dirs = (combined_dirs & ~broken_dirs) | CARDINAL_TO_SHORTPIPES(broken_dirs)
		var/state = "[state_dirs]_[layer]"
		spritesheet.Insert(output, state)

/// Generates all variants of damaged pipe from a given icon and the dirs that can be broken
/datum/pipe_icon_generator/proc/GenerateDamaged(icon/working, dirs, x_offset=1, y_offset=1)
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
		outputs[damaged] = combined_dirs
	return outputs


/datum/pipe_icon_generator/proc/GeneratePipeStraight(layer, combined_dirs)
	var/north_or_east = combined_dirs & (NORTH | EAST)
	var/icon/working = icon(template_pieces, "straight", north_or_east)
	var/icon/gas = icon(template_pieces, "straight-gas", north_or_east)

	generated_icons_queue[working] = NONE
	generated_gas_queue[gas] = NONE

	var/offset = 1 + (5-layer) * 2
	switch(combined_dirs)
		if(NORTH | SOUTH)
			generated_icons_queue += GenerateDamaged(working, combined_dirs, y_offset=offset)
			generated_gas_queue += GenerateDamaged(gas, combined_dirs, y_offset=offset)
		if(EAST | WEST)
			generated_icons_queue += GenerateDamaged(working, combined_dirs, x_offset=offset)
			generated_gas_queue += GenerateDamaged(gas, combined_dirs, x_offset=offset)

/datum/pipe_icon_generator/proc/GeneratePipeElbow(layer, combined_dirs)
	var/icon/working
	var/icon/gas
	switch(combined_dirs)
		if(NORTH | EAST)
			working = icon(template_pieces, "elbow", NORTH)
			gas = icon(template_pieces, "elbow-gas", NORTH)
		if(NORTH | WEST)
			working = icon(template_pieces, "elbow", WEST)
			gas = icon(template_pieces, "elbow-gas", WEST)
		if(SOUTH | EAST)
			working = icon(template_pieces, "elbow", EAST)
			gas = icon(template_pieces, "elbow-gas", EAST)
		if(SOUTH | WEST)
			working = icon(template_pieces, "elbow", SOUTH)
			gas = icon(template_pieces, "elbow-gas", SOUTH)

	generated_icons_queue[working] = NONE
	generated_icons_queue += GenerateDamaged(working, combined_dirs)

	generated_gas_queue[gas] = NONE
	generated_gas_queue += GenerateDamaged(gas, combined_dirs)

/datum/pipe_icon_generator/proc/GeneratePipeTJunction(layer, combined_dirs)
	var/icon/working
	var/icon/gas
	switch(combined_dirs)
		if(WEST | NORTH | EAST)
			working = icon(template_pieces, "tee", NORTH)
			gas = icon(template_pieces, "tee-gas", NORTH)
		if(NORTH | EAST | SOUTH)
			working = icon(template_pieces, "tee", EAST)
			gas = icon(template_pieces, "tee-gas", EAST)
		if(EAST | SOUTH | WEST)
			working = icon(template_pieces, "tee", SOUTH)
			gas = icon(template_pieces, "tee-gas", SOUTH)
		if(SOUTH | WEST | NORTH)
			working = icon(template_pieces, "tee", WEST)
			gas = icon(template_pieces, "tee-gas", WEST)

	generated_icons_queue[working] = NONE
	generated_icons_queue += GenerateDamaged(working, combined_dirs)

	generated_gas_queue[gas] = NONE
	generated_gas_queue += GenerateDamaged(gas, combined_dirs)

/datum/pipe_icon_generator/proc/GeneratePipeCross(layer, combined_dirs)
	var/icon/working = icon(template_pieces, "cross")
	generated_icons_queue[working] = NONE
	generated_icons_queue += GenerateDamaged(working, combined_dirs)

	var/icon/gas = icon(template_pieces, "cross-gas")
	generated_gas_queue[gas] = NONE
	//generated_gas_queue += GenerateDamaged(gas, combined_dirs)
