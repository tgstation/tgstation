// AI EYE
//
// An invisible (no icon) mob that the AI controls to look around the station with.
// It streams chunks as it moves around, which will show it what the AI can and cannot see.

/mob/aiEye
	name = "Inactive AI Eye"
	var/list/visibleCameraChunks = list()
	var/mob/living/silicon/ai/ai = null
	density = 0
	nodamage = 1 // You can't damage it.

// Movement code. Returns 0 to stop air movement from moving it.
/mob/aiEye/Move()
	return 0

// Hide popout menu verbs
/mob/aiEye/examine()
	set popup_menu = 0
	set src = usr.contents
	return 0

/mob/aiEye/pull()
	set popup_menu = 0
	set src = usr.contents
	return 0

/mob/aiEye/point()
	set popup_menu = 0
	set src = usr.contents
	return 0

// Use this when setting the aiEye's location.
// It will also stream the chunk that the new loc is in.

/mob/aiEye/proc/setLoc(var/T)
	T = get_turf(T)
	loc = T
	cameranet.visibility(src)

// AI MOVEMENT

// The AI's "eye". Described on the top of the page.

/mob/living/silicon/ai/var/mob/aiEye/eyeobj = new()

// Intiliaze the eye by assigning it's "ai" variable to us. Then set it's loc to us.
/mob/living/silicon/ai/New()
	..()
	eyeobj.ai = src
	spawn(5)
		eyeobj.loc = src.loc
		eyeobj.name = "[src.name] (AI Eye)" // Give it a name

/mob/living/silicon/ai/Del()
	eyeobj.ai = null
	del(eyeobj) // No AI, no Eye
	..()

// This will move the AIEye. It will also cause lights near the eye to light up, if toggled.
// This is handled in the proc below this one.

/client/AIMove(n, direct, var/mob/living/silicon/ai/user)

	user.eyeobj.setLoc(get_turf(get_step(user.eyeobj, direct)))
	user.cameraFollow = null
	src.eye = user.eyeobj
	//user.machine = null //Uncomment this if it causes problems.
	user.lightNearbyCamera()


// Return to the Core.

/mob/living/silicon/ai/verb/core()
	set category = "AI Commands"
	set name = "AI Core"
	current = null
	cameraFollow = null
	machine = null
	src.eyeobj.loc = src.loc
	if(client && client.eye)
		client.eye = src
	for(var/datum/camerachunk/c in eyeobj.visibleCameraChunks)
		c.remove(eyeobj)

