/datum/sprite_editor_workspace
	var/width
	var/height
	var/dirs
	var/list/layers
	var/list/undo_stack = list()
	var/list/undo_names = list()
	var/list/redo_stack = list()
	var/list/redo_names = list()

/datum/sprite_editor_workspace/New(width = 32, height = 32, dirs = 1)
	. = ..()
	src.width = width
	src.height = height
	src.dirs = dirs
	layers = list(list("name" = "Background", "data" = create_layer_data()))

/datum/sprite_editor_workspace/proc/create_layer_data()
	var/static/list/dir_list = list(SOUTH, NORTH, EAST, WEST)
	var/list/out = list()
	for(var/i in 1 to dirs)
		var/list/layer = list()
		for(var/y in 1 to height)
			var/list/row = list()
			for(var/x in 1 to width)
				row += "#00000000"
			layer += list(row)
		out["[dir_list[i]]"] = layer
	return out

/datum/sprite_editor_workspace/proc/new_transaction(transaction)
	redo_stack.Cut()
	redo_names.Cut()
	preprocess_new_transaction(transaction)
	transact(transaction)
	undo_stack += list(transaction)
	undo_names += transaction["name"]

/datum/sprite_editor_workspace/proc/undo()
	if(length(undo_stack))
		pop(undo_names)
		var/transaction = pop(undo_stack)
		reverse_transact(transaction)
		redo_stack += list(transaction)
		redo_names += transaction["name"]

/datum/sprite_editor_workspace/proc/redo()
	if(length(redo_stack))
		pop(redo_names)
		var/transaction = pop(redo_stack)
		transact(transaction)
		undo_stack += list(transaction)
		undo_names += transaction["name"]

/datum/sprite_editor_workspace/proc/preprocess_new_transaction(list/transaction)
	switch(transaction["type"])
		if("pencil", "eraser")
			var/layer = transaction["layer"]
			var/dir = transaction["dir"]
			var/list/points = transaction["points"]
			var/list/affected_frame = layers[layer]["data"][dir]
			for(var/point in points)
				var/x = point[1]+1
				var/y = point[2]+1
				points += affected_frame[y][x]
		if("flatten_layer")
			var/layer = transaction["layer"]
			var/list/top_layer = layers[layer]
			var/list/bottom_layer = layers[layer-1]
			transaction["oldTop"] = top_layer
			transaction["oldBottom"] = deep_copy_list(bottom_layer)
		if("delete_layer")
			var/layer = transaction["layer"]
			var/list/old_layer = layers[layer]
			transaction["oldLayer"] = old_layer

/datum/sprite_editor_workspace/proc/transact(list/transaction)
	switch(transaction["type"])
		if("pencil")
			var/layer = transaction["layer"]
			var/dir = transaction["dir"]
			var/color = transaction["color"]
			var/list/points = transaction["points"]
			var/list/affected_frame = layers[layer]["data"][dir]
			for(var/list/point in points)
				var/x = point[1]+1
				var/y = point[2]+1
				affected_frame[y][x] = blend_color(affected_frame[y][x], color)
		if("eraser")
			var/layer = transaction["layer"]
			var/dir = transaction["dir"]
			var/list/points = transaction["points"]
			var/list/affected_frame = layers[layer]["data"][dir]
			for(var/list/point in points)
				var/x = point[1]+1
				var/y = point[2]+1
				affected_frame[y][x] = "#00000000"
		if("renameLayer")
			var/layer = transaction["layer"]
			var/new_name = transaction["newName"]
			layers[layer]["name"] = new_name
		if("moveLayerUp")
			var/layer = transaction["layer"]
			layers.Swap(layer, layer+1)
		if("moveLayerDown")
			var/layer = transaction["layer"]
			layers.Swap(layer, layer-1)
		if("flattenLayer")
			var/layer = transaction["layer"]
			var/list/top_layer = layers[layer]
			var/list/bottom_layer = layers[layer-1]
			for(var/dir in 1 to dirs)
				for(var/y in 1 to height)
					for(var/x in 1 to width)
						bottom_layer["[dir]"][y][x] = blend_color(bottom_layer["[dir]"][y][x], top_layer["[dir]"][y][x])
			layers.Cut(layer, layer+1)
		if("addLayer")
			layers += list(list("name" = "New Layer", "data" = create_layer_data()))
		if("deleteLayer")
			var/layer = transaction["layer"]
			layers.Cut(layer, layer+1)

/datum/sprite_editor_workspace/proc/reverse_transact(list/transaction)
	switch(transaction["type"])
		if("pencil", "eraser")
			var/layer = transaction["layer"]
			var/dir = transaction["dir"]
			var/list/points = transaction["points"]
			var/list/affected_frame = layers[layer]["data"][dir]
			for(var/list/point in points)
				var/x = point[1]+1
				var/y = point[2]+1
				affected_frame[y][x] = point[3]
		if("renameLayer")
			var/layer = transaction["layer"]
			var/old_name = transaction["oldName"]
			layers[layer]["name"] = old_name
		if("moveLayerUp")
			var/layer = transaction["layer"]
			layers.Swap(layer, layer+1)
		if("moveLayerDown")
			var/layer = transaction["layer"]
			layers.Swap(layer, layer-1)
		if("flattenLayer")
			var/layer = transaction["layer"]
			var/top_layer = transaction["oldTop"]
			var/bottom_layer = transaction["oldBottom"]
			layers[layer-1] = bottom_layer
			layers.Insert(layer, top_layer)
		if("addLayer")
			pop(layers)
		if("deleteLayer")
			var/layer = transaction["layer"]
			var/old_layer = transaction["oldLayer"]
			layers.Insert(layer, old_layer)

/datum/sprite_editor_workspace/proc/sprite_editor_ui_data()
	return list(
		"undoStack" = undo_names,
		"redoStack" = redo_names,
		"sprite" = list(
			"width" = width,
			"height" = height,
			"dirs" = dirs,
			"layers" = layers,
		)
	)
