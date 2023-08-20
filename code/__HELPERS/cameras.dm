///Checks if a mob is visible to the cameranet.
/proc/near_camera(mob/living/mob_to_check)
	if (!isturf(mob_to_check.loc))
		return FALSE
	if(issilicon(mob_to_check))
		var/mob/living/silicon/silicon_tracked = mob_to_check
		if((QDELETED(silicon_tracked.builtInCamera) || !silicon_tracked.builtInCamera.can_use()) && !GLOB.cameranet.checkCameraVis(silicon_tracked))
			return FALSE
	else if(!GLOB.cameranet.checkCameraVis(mob_to_check))
		return FALSE
	return TRUE

/proc/camera_sort(list/L)
	var/obj/machinery/camera/a
	var/obj/machinery/camera/b

	for (var/i = length(L), i > 0, i--)
		for (var/j = 1 to i - 1)
			a = L[j]
			b = L[j + 1]
			if (sorttext(a.c_tag, b.c_tag) < 0)
				L.Swap(j, j + 1)
	return L

/**
 * get_camera_list
 *
 * Builds a list of all available cameras that can be seen to networks_available
 * Args:
 *  networks_available - List of networks that we use to see which cameras are visible to it.
 */
/proc/get_camera_list(list/networks_available)
	var/list/all_camera_list = list()
	for (var/obj/machinery/camera/camera as anything in GLOB.cameranet.cameras)
		all_camera_list.Add(camera)

	camera_sort(all_camera_list)

	var/list/usable_camera_list = list()

	for (var/obj/machinery/camera/camera as anything in all_camera_list)
		var/list/tempnetwork = camera.network & networks_available
		if (length(tempnetwork))
			usable_camera_list["[camera.c_tag][camera.can_use() ? null : " (Deactivated)"]"] = camera

	return usable_camera_list
