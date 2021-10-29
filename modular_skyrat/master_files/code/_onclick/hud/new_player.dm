/atom/movable/screen/lobby/button/server_swap
	icon = 'modular_skyrat/master_files/icons/hud/lobby/bottom_buttons.dmi'
	icon_state = "server_swap"
	base_icon_state = "server_swap"
	screen_loc = "TOP:-122,CENTER:-54"

/atom/movable/screen/lobby/button/server_swap/Click(location, control, params)
	. = ..()
	if(!.)
		return
	if(!CONFIG_GET(flag/server_swap_enabled))
		return
	var/mob/dead/new_player/new_player = hud.mymob
	if(GLOB.swappable_ips.len == 1)
		var/server_name = GLOB.swappable_ips[1]
		var/server_ip = GLOB.swappable_ips[server_name]
		var/confirm = tgui_alert(new_player, "Are you sure you want to swap to [server_name] ([server_ip])?", "Swapping server!", list("Connect me!", "Stay here!"))
		if(confirm == "Connect me!")
			to_chat_immediate(new_player, "So long, spaceman.")
			new_player.client << link(server_ip)
		return
	var/server_name = tgui_input_list(new_player, "Please select the server you wish to swap to:", "Swap servers!", GLOB.swappable_ips)
	if(!server_name)
		return
	var/server_ip = GLOB.swappable_ips[server_name]
	var/confirm = tgui_alert(new_player, "Are you sure you want to swap to [server_name] ([server_ip])?", "Swapping server!", list("Connect me!", "Stay here!"))
	if(confirm == "Connect me!")
		to_chat_immediate(new_player, "So long, spaceman.")
		new_player.client << link(server_ip)
	return
