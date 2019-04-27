/mob/living/silicon/pai/ClickOn(var/atom/A, params)
	var/list/modifiers = params2list(params)
	if(modifiers["shift"])
		ShiftClickOn(A)
		return
	if(aicamera.in_camera_mode)
		aicamera.camera_mode_off()
		aicamera.captureimage(A, usr)
		return
