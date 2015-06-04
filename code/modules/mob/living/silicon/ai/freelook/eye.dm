// AI EYE
//
// An invisible (no icon) mob that the AI controls to look around the station with.
// It streams chunks as it moves around, which will show it what the AI can and cannot see.

/mob/camera/aiEye
	name = "Inactive AI Eye"

	var/list/visibleCameraChunks = list()
	var/mob/living/silicon/ai/ai = null


// Use this when setting the aiEye's location.
// It will also stream the chunk that the new loc is in.

/mob/camera/aiEye/proc/setLoc(var/T)

	if(ai)
		if(!isturf(ai.loc))
			return
		T = get_turf(T)
		loc = T
		cameranet.visibility(src)
		if(ai.client)
			ai.client.eye = src
		//Holopad
		if(istype(ai.current, /obj/machinery/hologram/holopad))
			var/obj/machinery/hologram/holopad/H = ai.current
			H.move_hologram(ai)

/mob/camera/aiEye/Move()
	return 0

/mob/camera/aiEye/proc/GetViewerClient()
	if(ai)
		return ai.client
	return null


// AI MOVEMENT

// The AI's "eye". Described on the top of the page.

/mob/living/silicon/ai
	var/mob/camera/aiEye/eyeobj = new()
	var/sprint = 10
	var/cooldown = 0
	var/acceleration = 1


// Intiliaze the eye by assigning it's "ai" variable to us. Then set it's loc to us.
/mob/living/silicon/ai/New()
	..()
	eyeobj.ai = src
	eyeobj.name = "[src.name] (AI Eye)" // Give it a name
	spawn(5)
		eyeobj.loc = src.loc

/mob/living/silicon/ai/Destroy()
	eyeobj.ai = null
	qdel(eyeobj) // No AI, no Eye
	eyeobj = null
	..()

/atom/proc/move_camera_by_click()
	if(istype(usr, /mob/living/silicon/ai))
		var/mob/living/silicon/ai/AI = usr
		if(AI.eyeobj && AI.client.eye == AI.eyeobj)
			AI.cameraFollow = null
			if (isturf(src.loc) || isturf(src))
				AI.eyeobj.setLoc(src)

// This will move the AIEye. It will also cause lights near the eye to light up, if toggled.
// This is handled in the proc below this one.

/client/proc/AIMove(n, direct, var/mob/living/silicon/ai/user)

	if(user.controlled_mech) //The AI is a mech pilot!
		user.controlled_mech.relaymove(user, direct)


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

	user.cameraFollow = null

	//user.unset_machine() //Uncomment this if it causes problems.
	//user.lightNearbyCamera()
	if (user.camera_light_on)
		user.light_cameras()


// Return to the Core.
/mob/living/silicon/ai/proc/view_core()

	current = null
	cameraFollow = null
	unset_machine()

	if(src.eyeobj && src.loc)
		src.eyeobj.loc = src.loc
	else
		src << "ERROR: Eyeobj not found. Creating new eye..."
		src.eyeobj = new(src.loc)
		src.eyeobj.ai = src
		src.eyeobj.name = "[src.name] (AI Eye)" // Give it a name

	if(client && client.eye)
		client.eye = src
	for(var/datum/camerachunk/c in eyeobj.visibleCameraChunks)
		c.remove(eyeobj)

/mob/living/silicon/ai/verb/toggle_acceleration()
	set category = "AI Commands"
	set name = "Toggle Camera Acceleration"

	acceleration = !acceleration
	usr << "Camera acceleration has been toggled [acceleration ? "on" : "off"]."



