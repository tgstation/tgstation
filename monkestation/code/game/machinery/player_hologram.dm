/obj/machinery/player_hologram
	name = "holographic display"
	desc = "This is how the Observers observe"
	icon = 'monkestation/icons/obj/machines/holo.dmi'
	icon_state = "display_base"

	var/mutable_appearance/copied_appearance
	var/set_ckey = ""
	var/mob/living/current_mob
	var/image/visual_maptext/stored_maptext
	var/image/player_image

/obj/machinery/player_hologram/AltClick(mob/user)
	. = ..()
	if(current_mob)
		unset_player()
	var/choice = tgui_input_list(user, "Choose a ckey to watch", "[name]", GLOB.alive_player_list)
	if(!choice)
		return
	current_mob = choice
	set_ckey = current_mob.client.ckey

	RegisterSignal(current_mob, COMSIG_LIVING_DEATH, TYPE_PROC_REF(/obj/machinery/player_hologram, unset_player))
	RegisterSignal(current_mob, COMSIG_LIVING_HEALTH_UPDATE, TYPE_PROC_REF(/obj/machinery/player_hologram, update_maptext))

	update_maptext()
	update_visual()

/obj/machinery/player_hologram/proc/unset_player()
	set_ckey = null
	UnregisterSignal(current_mob, COMSIG_LIVING_DEATH)
	UnregisterSignal(current_mob, COMSIG_LIVING_HEALTH_UPDATE)
	current_mob = null
	clear_visuals()

/obj/machinery/player_hologram/proc/update_maptext()
	if(!current_mob)
		return

	var/the_string_of_destiny = "<span class='ol c pixel'><span style='color: #40b0ff;'>[current_mob.getOxyLoss()]</span> - <span style='color: #33ff33;'>[current_mob.getToxLoss()]</span> - <span style='color: #ffee00;'>[current_mob.getFireLoss()]</span> - <span style='color: #ff6666;'>[current_mob.getBruteLoss()]</span></span>"
	if(stored_maptext)
		stored_maptext.maptext = the_string_of_destiny
	else
		stored_maptext = generate_maptext(src, the_string_of_destiny, x_offset = -8, y_offset = 32)
	update_appearance()

/obj/machinery/player_hologram/update_overlays()
	. = ..()
	cut_overlays()
	if(stored_maptext)
		add_overlay(stored_maptext)
	if(player_image)
		add_overlay(player_image)
/obj/machinery/player_hologram/proc/update_visual()
	if(!current_mob)
		return

	if(!player_image)
		player_image = new

	player_image.appearance = current_mob.appearance
	player_image.alpha = 120
	player_image.color = COLOR_BLUE_LIGHT
	update_appearance()

/obj/machinery/player_hologram/proc/clear_visuals()
	if(copied_appearance)
		qdel(player_image)
	if(stored_maptext)
		qdel(stored_maptext)
	update_appearance()
