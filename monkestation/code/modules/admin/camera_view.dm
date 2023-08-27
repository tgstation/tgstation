/client
	var/atom/movable/screen/map_view/cam_screen

/client/proc/view_player_camera()
	set category = "Admin"

	set name = "Show Player Camera"
	set desc = "Lets you see around another player in a seperate window, useful for tracking players that might be bad."

	var/mob/choice = tgui_input_list(usr, "Choose a client to see", "Client Selection", GLOB.player_list)
	if(!choice || !choice.client)
		return
	var/client/choice_client = choice.client

	if(!choice_client.cam_screen)
		choice_client.cam_screen = new
		choice_client.cam_screen.generate_view("adminview[choice_client.ckey]_map")

	var/client/user_client = usr.client
	if(user_client.screen_maps["adminview[choice_client.ckey]"])
		return
	user_client.setup_popup("adminview[choice_client.ckey]", 7, 7, 2, choice_client.ckey)
	choice_client.cam_screen.display_to(usr)
	choice_client.RegisterSignal(user_client, COMSIG_POPUP_CLEARED, PROC_REF(on_screen_clear))
	choice_client.RegisterSignal(choice_client, COMSIG_MOB_CLIENT_MOVED_CLIENT_SEND, PROC_REF(update_view))
	choice_client.update_view()

/client/proc/on_screen_clear(client/source, window)
	SIGNAL_HANDLER
	cam_screen.hide_from(source.mob)
	UnregisterSignal(src, COMSIG_MOB_CLIENT_MOVED_CLIENT_SEND)

/client/proc/update_view()//this doesn't do anything too crazy, just updates the vis_contents of its screen obj
	SIGNAL_HANDLER

	cam_screen.vis_contents.Cut()
	for(var/turf/visible_turf in view(3, get_turf(src.mob)))//fuck you usr
		cam_screen.vis_contents += visible_turf
