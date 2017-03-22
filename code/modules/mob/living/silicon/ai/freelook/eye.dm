// AI EYE
//
// An invisible (no icon) mob that the AI controls to look around the station with.
// It streams chunks as it moves around, which will show it what the AI can and cannot see.

/mob/camera/aiEye
	name = "Inactive AI Eye"

	invisibility = INVISIBILITY_MAXIMUM
	var/list/visibleCameraChunks = list()
	var/mob/living/silicon/ai/ai = null
	var/relay_speech = FALSE

// Use this when setting the aiEye's location.
// It will also stream the chunk that the new loc is in.

/mob/camera/aiEye/proc/setLoc(T)

	if(ai)
		if(!isturf(ai.loc))
			return
		T = get_turf(T)
		loc = T
		cameranet.visibility(src)
		if(ai.client)
			ai.client.eye = src
		update_parallax_contents()
		//Holopad
		if(istype(ai.current, /obj/machinery/holopad))
			var/obj/machinery/holopad/H = ai.current
			H.move_hologram(ai)

/mob/camera/aiEye/Move()
	return 0

/mob/camera/aiEye/proc/GetViewerClient()
	if(ai)
		return ai.client
	return null

/mob/camera/aiEye/Destroy()
	ai = null
	return ..()

/atom/proc/move_camera_by_click()
	if(isAI(usr))
		var/mob/living/silicon/ai/AI = usr
		if(AI.eyeobj && AI.client.eye == AI.eyeobj)
			AI.cameraFollow = null
			if (isturf(src.loc) || isturf(src))
				AI.eyeobj.setLoc(src)

// This will move the AIEye. It will also cause lights near the eye to light up, if toggled.
// This is handled in the proc below this one.

/client/proc/AIMove(n, direct, mob/living/silicon/ai/user)

	var/initial = initial(user.sprint)
	var/max_sprint = 50

	if(user.cooldown && user.cooldown < world.timeofday) // 3 seconds
		user.sprint = initial

	for(var/i = 0; i < max(user.sprint, initial); i += 20)
		var/turf/step = get_turf(get_step(user.eyeobj, direct))
		if(step)
			user.eyeobj.setLoc(step)

	user.cooldown = world.timeofday + 5
	if(user.acceleration)
		user.sprint = min(user.sprint + 0.5, max_sprint)
	else
		user.sprint = initial

	if(!user.tracking)
		user.cameraFollow = null

	//user.unset_machine() //Uncomment this if it causes problems.
	//user.lightNearbyCamera()
	if(user.camera_light_on)
		user.light_cameras()

// Return to the Core.
/mob/living/silicon/ai/proc/view_core()

	current = null
	cameraFollow = null
	unset_machine()

	if(!eyeobj || !eyeobj.loc || QDELETED(eyeobj))
		to_chat(src, "ERROR: Eyeobj not found. Creating new eye...")
		eyeobj = new(loc)
		eyeobj.ai = src
		eyeobj.name = "[src.name] (AI Eye)" // Give it a name

	eyeobj.setLoc(loc)

/mob/living/silicon/ai/verb/toggle_acceleration()
	set category = "AI Commands"
	set name = "Toggle Camera Acceleration"

	if(usr.stat == 2)
		return //won't work if dead
	acceleration = !acceleration
	to_chat(usr, "Camera acceleration has been toggled [acceleration ? "on" : "off"].")

/mob/camera/aiEye/Hear(message, atom/movable/speaker, message_langs, raw_message, radio_freq, list/spans)
	if(relay_speech && speaker && ai && !radio_freq && speaker != ai && near_camera(speaker))
		ai.relay_speech(message, speaker, message_langs, raw_message, radio_freq, spans)
