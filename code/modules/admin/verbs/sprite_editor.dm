/datum/sprite_editor/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new (user, src, "SpriteEditor")
		ui.open()

/datum/sprite_editor/ui_state(mob/user)
	return GLOB.always_state

/datum/sprite_editor/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	switch(action)
		if("save")
			var/data = json_encode(params["data"])
			var/result = rustg_dmi_create_dmi("tmp/temp_icon.dmi", data)
			if(result)
				stack_trace(result)

ADMIN_VERB(test_sprite_editor, R_DEBUG, "Test Sprite Editor", "Test the Sprite Editor", ADMIN_CATEGORY_DEBUG)
	BLACKBOX_LOG_ADMIN_VERB("Test Sprite Editor")
	var/datum/sprite_editor/editor = new()
	editor.ui_interact(user.mob)
