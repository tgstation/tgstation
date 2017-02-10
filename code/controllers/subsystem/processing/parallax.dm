var/datum/subsystem/processing/parallax/SSparallax

/datum/subsystem/processing/parallax
	name = "parallax"
	wait = 2
	flags = SS_POST_FIRE_TIMING | SS_FIRE_IN_LOBBY | SS_BACKGROUND
	priority = 65

	delegate = /client/.proc/parallax
	processing_list = null	//uses clients

/datum/subsystem/processing/parallax/New()
	NEW_SS_GLOBAL(SSparallax)

/datum/subsystem/processing/parallax/Initialize()
	processing_list = clients
	..()

/datum/subsystem/processing/parallax/Recover()
	//noop

/datum/subsystem/processing/parallax/stop_processing()
	//noop

/client/proc/parallax()
	if(!eye)
		return
	var/atom/movable/A = eye
	if(!A)
		return
	for (A; isloc(A.loc) && !isturf(A.loc); A = A.loc);

	if(A != movingmob)
		if(movingmob != null)
			movingmob.client_mobs_in_contents -= mob
			UNSETEMPTY(movingmob.client_mobs_in_contents)
		LAZYINITLIST(A.client_mobs_in_contents)
		A.client_mobs_in_contents += mob
		movingmob = A