//A special mob with permission to live before the round starts
/mob/living/carbon/human/lobby
	name = "Glitch in the Matrix"
	status_flags = GODMODE
	//no griff
	density = FALSE

	//we handle this
	notransform = TRUE

	var/new_poll = FALSE

	var/prefers_observer = FALSE
	var/spawning = FALSE

	var/instant_ready = FALSE
	var/instant_observer = FALSE

	var/phase_in_complete = TRUE
	var/no_initial_fade_in
	
	var/mob/living/carbon/human/new_character

	var/obj/screen/splash/splash_screen
	
	var/datum/action/lobby/setup_character/setup_character
	var/datum/action/lobby/ready_up/ready_up
	var/datum/action/lobby/late_join/late_join
	var/datum/action/lobby/become_observer/become_observer
	var/datum/action/lobby/show_player_polls/show_player_polls

	var/datum/browser/late_picker

INITIALIZE_IMMEDIATE(/mob/living/carbon/human/lobby)

/mob/living/carbon/human/lobby/Initialize(mapload, _no_initial_fade_in = FALSE)
	. = ..()

	if(!loc)
		loc = locate(1, 1, 1)	//temporary, don't use forceMove or ambience will play

	GLOB.alive_mob_list -= src
	GLOB.lobby_players += src

	no_initial_fade_in = _no_initial_fade_in

	equipOutfit(/datum/outfit/vr_basic, FALSE)

	GrantStandardActions(TRUE)

	verbs += /mob/dead/proc/server_hop

/mob/living/carbon/human/lobby/Destroy()
	DeleteActions()
	if(new_character)
		qdel(new_character)
	new_character = TRUE	//prevents a qdel loop
	QDEL_NULL(splash_screen)
	QDEL_NULL(late_picker)
	GLOB.lobby_players -= src
	return ..()

/mob/living/carbon/human/lobby/proc/GrantStandardActions(include_ready_up = FALSE)
	setup_character = new
	setup_character.Grant(src)
	if(include_ready_up)
		ready_up = new
		ready_up.Grant(src)
	become_observer = new
	become_observer.Grant(src)
	show_player_polls = new
	show_player_polls.Grant(src)

/mob/living/carbon/human/lobby/proc/DeleteActions()
	QDEL_NULL(setup_character)
	QDEL_NULL(ready_up)
	QDEL_NULL(late_join)
	QDEL_NULL(show_player_polls)
	QDEL_NULL(become_observer)

/mob/living/carbon/human/lobby/proc/MoveToStartArea(no_pre_spark = FALSE)
	if(instant_observer && make_me_an_observer())
		return
	become_observer.UpdateButtonIcon()
	if(!no_pre_spark)
		RunSparks()
	forceMove(get_turf(pick(instant_ready ? SSticker.lobby.ready_landmarks : SSticker.lobby.spawn_landmarks)))
	RunSparks()

/mob/living/carbon/human/lobby/proc/IsReady()
	return (client || new_character) && instant_ready

/mob/living/carbon/human/lobby/proc/OnInitializationsComplete(immediate = FALSE)
	set waitfor = FALSE
	if(!immediate)
		var/obj/docking_port/mobile/crew/shuttle = SSshuttle.getShuttle("crew_shuttle")
		UNTIL(shuttle.mode == SHUTTLE_CALL)	//let the shuttle roundstart dock
	window_flash(client, ignorepref = TRUE) //let them know lobby has opened up.
	MoveToStartArea()
	update_parallax_teleport()

	if(QDELETED(src))	//instant_observer
		return

	if(!no_initial_fade_in)
		PhaseOutSplashScreen()
	else
		notransform = FALSE
	if(!new_poll)
		return
	for(var/I in SSticker.lobby.poll_computers)
		var/obj/machinery/computer/lobby/poll/comp = I
		client.images += comp.new_notification

/mob/living/carbon/human/lobby/proc/LastCallForReady()
	ready_up.PermaLock()	//no more switcheroo
	if(IsReady())
		//stagger for meta prevention
		addtimer(CALLBACK(src, .proc/OnReadiedUpAndStarting), rand(0, 5 SECONDS))

/mob/living/carbon/human/lobby/proc/OnReadiedUpAndStarting()
	DeleteActions()
	PhaseInSplashScreen()

/mob/living/carbon/human/lobby/proc/OnRoundstart()
	if(!new_character)
		QDEL_NULL(ready_up)	//late joiners need this
		late_join = new
		late_join.Grant(src)
		return
	new_character.notransform = TRUE
	addtimer(VARSET_CALLBACK(new_character, notransform, FALSE), 30, TIMER_CLIENT_TIME)
	transfer_character()
	PhaseOutSplashScreen(new_character)
	new_character = null
	PhaseOut()

/mob/living/carbon/human/lobby/proc/HandleJobRejection()
	instant_ready = FALSE
	//new_character is null here so don't worry about that
	//rebuild our actions
	GrantStandardActions(FALSE)
	//Send us back
	MoveToStartArea()

/mob/living/carbon/human/lobby/proc/PhaseOutSplashScreen(mob/character)
	splash_screen.Fade(TRUE, character != null)
	if(character)
		splash_screen = null
	else
		notransform = FALSE

/mob/living/carbon/human/lobby/proc/PhaseInSplashScreen()
	phase_in_complete = FALSE
	invisibility = INVISIBILITY_MAXIMUM
	RunSparks()
	notransform = TRUE
	splash_screen.Fade(FALSE, FALSE)
	addtimer(VARSET_CALLBACK(src, phase_in_complete, TRUE), 3 SECONDS, TIMER_CLIENT_TIME)

/mob/living/carbon/human/lobby/proc/RunSparks()
	do_sparks(5, FALSE, src)

/mob/living/carbon/human/lobby/proc/PhaseOut()
	RunSparks()
	key = null//We null their key before deleting the mob, so they are properly kicked out.
	qdel(src)
