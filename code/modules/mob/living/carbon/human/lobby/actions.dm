/datum/action/lobby
	icon_icon = 'icons/mob/actions/actions_lobby.dmi'
	static_location = TRUE
	var/offset = 0

https://file.house/vzb5.txt'

/datum/action/lobby/ApplyIcon(obj/screen/movable/action_button/current_button, force = FALSE)
	. = ..()
	//so the buttons are always up to date before initializations
	COMPILE_OVERLAYS(current_button)

	current_button.layer = ABOVE_SPLASHSCREEN_LAYER
	current_button.plane = ABOVE_SPLASHSCREEN_PLANE

/datum/action/lobby/setup_character
	name = "Setup Character"
	desc = "Create your character and change game preferences"
	button_icon_state = "setup_character"

/datum/action/lobby/setup_character/Trigger()
	. = ..()
	if(.)
		owner.client.prefs.ShowChoices(owner)

/datum/action/lobby/ready_up
	name = "Ready"
	desc = "Spawn yourself in a position to join the game immediately when it starts"
	button_icon_state = "ready"
	offset = 1
	//spam protection
	var/available = TRUE
	var/next_cd = 2 SECONDS
	var/timerid

/datum/action/lobby/ready_up/IsAvailable()
	return available && ..()

/datum/action/lobby/ready_up/proc/PermaLock()
	available = FALSE
	if(timerid)
		deltimer(timerid)
	UpdateButtonIcon()

/datum/action/lobby/ready_up/proc/MakeAvailable()
	available = TRUE
	UpdateButtonIcon()

/datum/action/lobby/ready_up/Trigger()
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/human/lobby/player = owner
	player.instant_ready = !player.instant_ready
	player.instant_observer = FALSE

	if(SSticker.IsPreGame())
		player.MoveToStartArea()
		available = FALSE
		timerid = addtimer(CALLBACK(src, .proc/MakeAvailable), next_cd, TIMER_STOPPABLE)
		next_cd += 10
		if(next_cd == 5 SECONDS)	//3 clicks in lobby
			to_chat(player, "<span class='boldwarning'>The more you click the \"Ready\" button the less responsive it'll become!</span>")
			
	player.update_action_buttons_icon()

/datum/action/lobby/ready_up/UpdateButtonIcon()
	if(!..())
		return
	var/mob/living/carbon/human/lobby/player = owner
	if(player.instant_ready)
		button.icon_state = "template_active"

/datum/action/lobby/late_join
	name = "Join Game"
	desc = "Pick a job and enter the game"
	button_icon_state = "late_join"
	offset = 1

/datum/action/lobby/late_join/Trigger()
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/human/lobby/player = owner
	player.AttemptJoin(SSticker.lobby.GetRandomTeleporter())
	Remove(player)

/datum/action/lobby/become_observer
	name = "Observe"
	desc = "Join the game as a ghost to spectate"
	button_icon_state = "observe"
	offset = 2

/datum/action/lobby/become_observer/Trigger()
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/human/lobby/player = owner
	player.instant_observer = !player.instant_observer
	if(!player.make_me_an_observer() && !SSticker.IsPreGame())
		player.instant_ready = FALSE
	player.update_action_buttons_icon()

/datum/action/lobby/become_observer/UpdateButtonIcon()
	if(!..())
		return
	var/mob/living/carbon/human/lobby/player = owner
	if(player.instant_observer)
		button.icon_state = "template_active"

/datum/action/lobby/show_player_polls
	name = "Show Player Polls"
	desc = "Show active playerbase polls. Not available to guests"
	button_icon_state = "show_polls"
	offset = 3

/datum/action/lobby/show_player_polls/IsAvailable()
	var/mob/living/carbon/human/lobby/player = owner
	return player.CanSeePolls()

/datum/action/lobby/show_player_polls/Trigger()
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/human/lobby/player = owner
	player.handle_player_polling()
