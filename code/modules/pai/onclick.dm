/mob/living/silicon/pai/ClickOn(atom/target, params)
	..()
	if(!aicamera)
		return
	if(aicamera.in_camera_mode) //pAI picture taking
		aicamera.toggle_camera_mode(sound = FALSE)
		aicamera.captureimage(target, usr, aicamera.picture_size_x - 1, aicamera.picture_size_y - 1)
		return
