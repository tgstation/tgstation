///Ensures no plane master starts with a * render target (for consistency)
/datum/unit_test/plane_render_check

/datum/unit_test/plane_render_check/Run()
	var/list/plane_integer_list = list()
	for(var/atom/movable/screen/plane_master/plane_path as anything in subtypesof(/atom/movable/screen/plane_master))
		if(!initial(plane_path.render_target) || copytext(initial(plane_path.render_target), 1, 2) != "*")
			continue
		TEST_FAIL("MALFORMED RENDER TARGET!! [initial(plane_path.name)]'s default render target ([initial(plane_path.render_target)]) begins with *, breaking convention")
