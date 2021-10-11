/obj/machinery/computer/tournament_controller/proc/start_countdown(mob/user)
	if (countdown_started)
		to_chat(user, span_notice("The countdown has already started!"))
		return

	countdown_started = TRUE

	message_admins("[key_name_admin(user)] has started the countdown in the [arena_id] arena.")
	log_admin("[key_name(user)] has started the countdown in the [arena_id] arena.")

	var/list/countdown_timers = list()

	for (var/mob/player_mob as anything in GLOB.player_list)
		if (player_mob.z == z)
			var/atom/movable/screen/tournament_countdown/tournament_countdown = new

			countdown_timers[player_mob.client] = tournament_countdown
			player_mob.client?.screen += tournament_countdown

	for (var/timer in 3 to 1 step -1)
		for (var/client in countdown_timers)
			var/atom/movable/screen/tournament_countdown/tournament_countdown = countdown_timers[client]
			tournament_countdown.set_text(timer)

		stoplag(1 SECONDS)

	open_shutters()
	countdown_started = FALSE

	for (var/client in countdown_timers)
		var/atom/movable/screen/tournament_countdown/tournament_countdown = countdown_timers[client]
		tournament_countdown.set_text("Fight!")

	stoplag(2 SECONDS)

	for (var/client/client as anything in countdown_timers)
		client?.screen -= countdown_timers[client]
		qdel(countdown_timers[client])

/atom/movable/screen/tournament_countdown
	icon = null
	icon_state = null
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	screen_loc = "TOP:-122,LEFT"
	maptext_height = 480
	maptext_width = 480
	maptext = ""

/atom/movable/screen/tournament_countdown/proc/set_text(text)
	maptext = "<b style='font-family: Arial Black; text-align: center; font-size: 60px'>[text]</b>"
