/mob/living/silicon/pai/ClickOn(atom/A, params)
	..()
	if(aicamera.in_camera_mode) //pAI picture taking
		aicamera.camera_mode_off()
		aicamera.captureimage(A, usr, aicamera.picture_size_x - 1, aicamera.picture_size_y - 1)
		return
