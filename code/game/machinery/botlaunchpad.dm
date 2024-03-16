/obj/machinery/botpad
	name = "Bot pad"
	desc = "A lighter version of the orbital mech pad modified to launch bots. Requires linking to a remote to function."
	icon = 'icons/obj/machines/telepad.dmi'
	icon_state = "botpad"
	circuit = /obj/item/circuitboard/machine/botpad
	// ID of the console, used for linking up
	var/id = "botlauncher"
	var/obj/item/botpad_remote/connected_remote
	var/datum/weakref/launched_bot // we need this to recall the bot

/obj/machinery/botpad/Destroy()
	if(connected_remote)
		connected_remote.connected_botpad = null
		connected_remote = null
	launched_bot = null
	return ..()

/obj/machinery/botpad/screwdriver_act(mob/user, obj/item/tool)
	return default_deconstruction_screwdriver(user, "botpad-open", "botpad", tool)
/obj/machinery/botpad/crowbar_act(mob/user, obj/item/tool)
	return default_deconstruction_crowbar(tool)

/obj/machinery/botpad/multitool_act(mob/living/user, obj/item/tool)
	if(!panel_open)
		return
	if(!multitool_check_buffer(user, tool))
		return
	var/obj/item/multitool/multitool = tool
	multitool.set_buffer(src)
	balloon_alert(user, "saved to multitool buffer")
	return ITEM_INTERACT_SUCCESS


// Checks the turf for a bot and launches it if it's the only mob on the pad.
/obj/machinery/botpad/proc/launch(mob/living/user)
	var/turf/reverse_turf = get_turf(user)
	var/atom/possible_bot
	for(var/mob/living/robot in get_turf(src))
		if(!isbot(robot))
			user.balloon_alert(user, "unidentified life form on the pad!")
			return
		if(!isnull(possible_bot))
			user.balloon_alert(user, "too many bots on the pad!")
			return
		possible_bot = robot  // We don't change the launched_bot var here because we are not sure if there is another bot on the pad.

	if(!use_energy(active_power_usage, force = FALSE))
		balloon_alert(user, "not enough energy!")
		return
	launched_bot = WEAKREF(possible_bot)
	podspawn(list(
		"target" = get_turf(src),
		"path" = /obj/structure/closet/supplypod/botpod,
		"style" = STYLE_SEETHROUGH,
		"reverse_dropoff_coords" = list(reverse_turf.x, reverse_turf.y, reverse_turf.z)
	))

/obj/machinery/botpad/proc/recall(mob/living/user)
	var/atom/our_bot = launched_bot?.resolve()
	if(isnull(our_bot))
		user.balloon_alert(user, "no bots sent from the pad!")
		return
	user.balloon_alert(user, "bot sent back to pad")
	if(isbasicbot(our_bot))
		var/mob/living/basic/bot/basic_bot = our_bot
		basic_bot.summon_bot(src)
		return
	var/mob/living/simple_animal/bot/simple_bot = our_bot
	simple_bot.call_bot(src,  get_turf(src))

/obj/structure/closet/supplypod/botpod
	style = STYLE_SEETHROUGH
	explosionSize = list(0,0,0,0)
	reversing = TRUE
	reverse_option_list = list("Mobs"=TRUE,"Objects"=FALSE,"Anchored"=FALSE,"Underfloor"=FALSE,"Wallmounted"=FALSE,"Floors"=FALSE,"Walls"=FALSE,"Mecha"=FALSE)
	delays = list(POD_TRANSIT = 0, POD_FALLING = 0, POD_OPENING = 0, POD_LEAVING = 0)
	reverse_delays = list(POD_TRANSIT = 15, POD_FALLING = 10, POD_OPENING = 0, POD_LEAVING = 0)
	custom_rev_delay = TRUE
	effectQuiet = TRUE
	leavingSound = 'sound/vehicles/rocketlaunch.ogg'
	close_sound = null
	pod_flags = FIRST_SOUNDS
