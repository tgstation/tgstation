/**
 * get_camera_list
 *
 * Builds a list of all available cameras that can be seen to networks_available
 * Args:
 *  networks_available - List of networks that we use to see which cameras are visible to it.
 */
/proc/get_camera_list(list/networks_available)
	var/list/all_camera_list = list()
	for(var/obj/machinery/camera/camera as anything in GLOB.cameranet.cameras)
		all_camera_list.Add(camera)

	camera_sort(all_camera_list)

	var/list/usable_camera_list = list()

	for(var/obj/machinery/camera/camera as anything in all_camera_list)
		var/list/tempnetwork = camera.network & networks_available
		if(length(tempnetwork))
			usable_camera_list["[camera.c_tag][camera.can_use() ? null : " (Deactivated)"]"] = camera

	return usable_camera_list

///Sorts the list of cameras by their c_tag to display to players.
/proc/camera_sort(list/camera_list)
	var/obj/machinery/camera/camera_comparing_a
	var/obj/machinery/camera/camera_comparing_b

	for(var/i = length(camera_list), i > 0, i--)
		for(var/j = 1 to i - 1)
			camera_comparing_a = camera_list[j]
			camera_comparing_b = camera_list[j + 1]
			if(sorttext(camera_comparing_a.c_tag, camera_comparing_b.c_tag) < 0)
				camera_list.Swap(j, j + 1)
	return camera_list
