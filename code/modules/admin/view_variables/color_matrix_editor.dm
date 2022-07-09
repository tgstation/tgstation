INITIALIZE_IMMEDIATE(/atom/movable/screen/color_matrix_proxy_view)

/atom/movable/screen/color_matrix_proxy_view
	name = "color_matrix_proxy_view"
	del_on_map_removal = FALSE
	layer = GAME_PLANE
	plane = GAME_PLANE

	var/list/plane_masters = list()

	/// The client that is watching this view
	var/client/client

/atom/movable/screen/color_matrix_proxy_view/Initialize(mapload)
	. = ..()

	assigned_map = "color_matrix_proxy_[REF(src)]"
	set_position(1, 1)

/atom/movable/screen/color_matrix_proxy_view/Destroy()
	for (var/plane_master in plane_masters)
		client?.screen -= plane_master
		qdel(plane_master)

	client?.clear_map(assigned_map)

	client = null
	plane_masters = null

	return ..()

/atom/movable/screen/color_matrix_proxy_view/proc/register_to_client(client/client)
	QDEL_LIST(plane_masters)

	src.client = client

	if (!client)
		return

	for (var/plane_master_type in subtypesof(/atom/movable/screen/plane_master) - /atom/movable/screen/plane_master/blackness)
		var/atom/movable/screen/plane_master/plane_master = new plane_master_type()
		plane_master.screen_loc = "[assigned_map]:CENTER"
		client?.screen |= plane_master

		plane_masters += plane_master

	client?.register_map_obj(src)

/datum/color_matrix_editor
	var/client/owner
	var/datum/weakref/target
	var/atom/movable/screen/color_matrix_proxy_view/proxy_view
	var/list/current_color
	var/closed

/datum/color_matrix_editor/New(user, atom/_target = null)
	owner = CLIENT_FROM_VAR(user)
	if(islist(_target?.color))
		current_color = _target.color
	else if(istext(_target?.color))
		current_color = color_hex2color_matrix(_target.color)
	else
		current_color = color_matrix_identity()
	proxy_view = new
	if(_target)
		target = WEAKREF(_target)
		proxy_view.appearance = image(_target)
	else
		proxy_view.appearance = image('icons/misc/colortest.dmi', "colors")

	proxy_view.color = current_color
	proxy_view.register_to_client(owner)

/datum/color_matrix_editor/Destroy(force, ...)
	QDEL_NULL(proxy_view)
	return ..()

/datum/color_matrix_editor/ui_state(mob/user)
	return GLOB.admin_state

/datum/color_matrix_editor/ui_static_data(mob/user)
	var/list/data = list()
	data["mapRef"] = proxy_view.assigned_map

	return data

/datum/color_matrix_editor/ui_data(mob/user)
	var/list/data = list()
	data["currentColor"] = current_color

	return data

/datum/color_matrix_editor/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ColorMatrixEditor")
		ui.open()

/datum/color_matrix_editor/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("transition_color")
			current_color = params["color"]
			animate(proxy_view, time = 4, color = current_color)
		if("confirm")
			on_confirm()
			SStgui.close_uis(src)

/datum/color_matrix_editor/ui_close(mob/user)
	. = ..()
	closed = TRUE

/datum/color_matrix_editor/proc/on_confirm()
	var/atom/target_atom = target?.resolve()
	if(istype(target_atom))
		target_atom.vv_edit_var("color", current_color)

/datum/color_matrix_editor/proc/wait()
	while(!closed)
		stoplag(1)

/client/proc/open_color_matrix_editor(atom/in_atom)
	var/datum/color_matrix_editor/editor = new /datum/color_matrix_editor(src, in_atom)
	editor.ui_interact(mob)
	editor.wait()
	. = editor.current_color
	qdel(editor)
