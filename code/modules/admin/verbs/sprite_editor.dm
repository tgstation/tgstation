/datum/sprite_editor
	var/datum/sprite_editor_workspace/workspace

/datum/sprite_editor/New()
	workspace = new()

/datum/sprite_editor/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new (user, src, "SpriteEditor")
		ui.open()

/datum/sprite_editor/ui_state(mob/user)
	return GLOB.always_state

/datum/sprite_editor/ui_data(mob/user)
	return workspace.sprite_editor_ui_data()

/datum/sprite_editor/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	switch(action)
		if("spriteEditorCommand")
			var/command = params["command"]
			switch(command)
				if("transaction")
					workspace.new_transaction(params["transaction"])
				if("toggleVisible")
					workspace.toggle_layer_visible(params["layer"])
				if("undo")
					workspace.undo()
				if("redo")
					workspace.redo()
			return TRUE
		if("save")
			fcopy(workspace.to_icon(), "tmp/sprite_editor_result.dmi")
			return TRUE

ADMIN_VERB(test_sprite_editor, R_DEBUG, "Test Sprite Editor", "Test the Sprite Editor", ADMIN_CATEGORY_DEBUG)
	BLACKBOX_LOG_ADMIN_VERB("Test Sprite Editor")
	var/datum/sprite_editor/editor = new()
	editor.ui_interact(user.mob)
