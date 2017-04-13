/datum/round_event_control/camera_failure
	name = "Camera Failure"
	typepath = /datum/round_event/camera_failure
	weight = 100
	max_occurrences = 20
	alertadmins = 0

/datum/round_event/camera_failure
	startWhen = 1
	endWhen = 2
	announceWhen = 0

/datum/round_event/camera_failure/tick()
	var/iterations = 1
	var/obj/machinery/camera/C = pick(GLOB.cameranet.cameras)
	while(prob(round(100/iterations)))
		while(!("SS13" in C.network))
			C = pick(GLOB.cameranet.cameras)
		if(C.status)
			C.toggle_cam(null, 0)
		iterations *= 2.5
