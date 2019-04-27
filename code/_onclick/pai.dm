/mob/living/silicon/pai/ClickOn(var/atom/A, params)
	if(aicamera.in_camera_mode)
		aicamera.camera_mode_off()
		aicamera.captureimage(A, usr)
		return