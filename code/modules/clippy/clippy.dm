/datum/agent
	var/id

	var/name
	var/frameWidth
	var/frameHeight

	var/icon
	var/list/info

	var/current_animation
	var/exitingAnim = FALSE
	var/queued_animation
	var/current_frame

	var/intro_anim
	var/list/idle_animations = list()
	var/list/all_animations = list()

	var/mob/target

	var/next_fire

	var/obj/effect/abstract/agent/holder
	var/obj/effect/abstract/agent_part/parts = list()


	var/mob/controller
	var/datum/action/innate/agent/change_agent_animation/change_animation_action
	var/datum/action/innate/agent/talk/talk_action

	// Hud attached to => hud element
	var/list/viewers = list()

/obj/effect/abstract/agent
	name = "agent holder"
	vis_flags = VIS_INHERIT_ID | VIS_INHERIT_LAYER | VIS_INHERIT_PLANE

/obj/effect/abstract/agent_part
	name = "agent_part"
	vis_flags = VIS_INHERIT_ID | VIS_INHERIT_LAYER | VIS_INHERIT_PLANE

/datum/agent/New()
	. = ..()

	info = json_decode(file2text("code/modules/clippy/AgentData/[id]/agent.json"))
	icon = file("code/modules/clippy/AgentData/[id]/agent.dmi")

	change_animation_action = new
	change_animation_action.agent = src

	talk_action = new
	talk_action.agent = src

	name = info["name"]
	frameWidth = info["framesize"][1]
	frameHeight = info["framesize"][2]
	//normalize here maybe so they're same size ignoring png size, though they do look kinda scrunchy already

	for(var/anim in info["animations"])
		all_animations += anim

	//todo: add separate ss
	next_fire = world.time
	START_PROCESSING(SSfishing, src) //coincidentally msagent delay resolution is 1ds

	holder = new
	holder.name = name
	// Centering runechat
	holder.maptext_height = frameHeight
	holder.base_pixel_x = -0.375* frameWidth

	for(var/i in 1 to info["overlayCount"])
		var/obj/effect/abstract/agent_part/part = new
		part.icon = icon
		parts += part
		holder.vis_contents += part

/datum/agent/Destroy(force)
	. = ..()
	STOP_PROCESSING(SSfishing, src)
	remove_control()
	for(var/datum/hud/hud in viewers)
		remove_from(hud.mymob)
	viewers = null

/datum/agent/proc/set_name(new_name)
	name = new_name
	holder.name = new_name
	for(var/hud in viewers)
		var/atom/movable/screen/movable/agent/hud_element = viewers[hud]
		hud_element.name = new_name

/atom/movable/screen/movable/agent
	screen_loc = "EAST-5, SOUTH+3" //Bottom-right somewhere to start with
	desc = "Very useful!"
	var/datum/agent/our_agent

/atom/movable/screen/movable/agent/Click(location, control, params)
	return

/datum/agent/proc/prod()
	set_animation(pick(all_animations))

/// We really need a helper for dynamically adding stuff to hud that survives reconnect without having to define shit in base huds
/datum/agent/proc/show_to(mob/victim)
	var/datum/hud/our_hud = victim.hud_used
	if(!our_hud || viewers[our_hud])
		return

	var/atom/movable/screen/movable/agent/hud_element = new(null, our_hud)
	hud_element.vis_contents += holder
	hud_element.name = name
	hud_element.our_agent = src

	viewers[our_hud] = hud_element
	our_hud.agents += hud_element
	if(victim.client)
		victim.client.screen += hud_element

/datum/agent/proc/remove_from(mob/victim)
	if(!victim.hud_used)
		return
	var/atom/movable/screen/movable/agent/hud_element = viewers[victim.hud_used]
	victim.hud_used.agents -= hud_element
	if(victim.client)
		victim.client.screen -= hud_element
	viewers -= victim.hud_used
	qdel(hud_element)


/datum/action/innate/agent
	var/datum/agent/agent

/datum/action/innate/agent/change_agent_animation
	name = "Change Agent Animation"
	desc = "Haha funny."
	button_icon = 'icons/hud/screen_pai.dmi'
	button_icon_state = "avatar"

/datum/action/innate/agent/change_agent_animation/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return
	var/picked = tgui_input_list(usr, message = "Choose animation", items = agent.all_animations)
	agent.set_animation(picked)

/datum/action/innate/agent/talk
	name = "Agent Talk"
	desc = "Make the helpful avatar give sage advice."
	button_icon = 'icons/hud/screen_pai.dmi'
	button_icon_state = "avatar"

/datum/action/innate/agent/talk/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return
	var/text = tgui_input_text(usr, "Enter sage advice", "Agent Talk")
	agent.talk(text)

/datum/agent/proc/give_control_to(mob/target)
	// Give them action to choose animation and talk
	if(controller)
		remove_control()
	controller = target
	talk_action.Grant(controller)
	change_animation_action.Grant(controller)
	// Pass move to screen loc changes so they can move around the screen with some delay to be annoying ?

/datum/agent/proc/remove_control()
	if(controller)
		change_animation_action.Remove(controller)
		talk_action.Remove(controller)
		controller = null

/datum/agent/proc/talk(text)
	for(var/datum/hud/hud in viewers)
		hud.mymob.create_chat_message(holder, null, text, null)
		// would be nice to add the scroll background

/datum/agent/process(seconds_per_tick)
	if(next_fire > world.time)
		return

	if(!current_animation)
		current_animation = pick(idle_animations)

	update_current_frame()

/datum/agent/proc/update_current_frame()
	var/list/animation_info = info["animations"][current_animation]["frames"]
	var/total_frames = length(animation_info)

	if(current_frame >= total_frames) //Finished animation, continue with queued one or go back to idle anim
		current_animation = null
		current_frame = null
		exitingAnim = FALSE
		if(queued_animation)
			current_animation = queued_animation
			queued_animation = null
		else
			current_animation = pick(idle_animations)

	var/next_frame = get_next_frame()
	animation_info = info["animations"][current_animation]["frames"]
	total_frames = length(animation_info)
	var/list/frame = animation_info[next_frame]
	// Frame duration in ds
	var/frame_duration = frame["duration"] / 100

	if(frame_duration == 0) //Skip this frame, this is for the wait on exit ones
		current_frame = next_frame
		return

	var/index = 1
	var/list/images = frame["images"]
	for(var/obj/effect/abstract/agent_part/part in parts)
		if(!images || index > length(images))
			part.icon_state = null
		else
			var/x = images[index][1]
			var/y = images[index][2]
			part.icon_state = "[x]-[y]"
		index++

	if(frame["sound"])
		play_sound(frame["sound"])

	current_frame = next_frame
	//replace with addtimer/ss
	next_fire = world.time + frame_duration

/datum/agent/proc/play_sound(sound_id)
	var/sound_path = "code/modules/clippy/AgentData/[id]/Sounds/[sound_id].ogg"
	for(var/datum/hud/hud in viewers)
		hud.mymob.playsound_local(get_turf(hud.mymob),sound(sound_path),50)

/datum/agent/proc/get_next_frame()
	if(!current_animation)
		return
	if(!current_frame)
		return 1

	var/animation_info = info["animations"][current_animation]["frames"]
	var/list/frame = animation_info[current_frame]

	if(frame["duration"] == 0) // These branching rules make no sense
		return current_frame + 1

	if(exitingAnim && frame["exitBranch"] != null)
		return frame["exitBranch"] + 1

	if(frame["branching"])
		var/list/branches = frame["branching"]["branches"]
		var/rnd = rand(0,100)
		for(var/list/branch in branches)
			if(rnd <= branch["weight"])
				world << "Branched"
				return branch["frameIndex"] + 1
			rnd -= branch["weight"]

	return current_frame + 1

/datum/agent/proc/set_animation(name)
	if(current_animation != name)
		exitingAnim = TRUE
		queued_animation = name

/datum/agent/clippy
	id = "Clippy"
	intro_anim = "Greeting"
	idle_animations = list(
			"IdleSnooze",
			"IdleEyeBrowRaise",
			"Idle1_1",
			"IdleRopePile",
			"IdleAtom",
			"IdleFingerTap",
			"IdleHeadScratch",
			"IdleSideToSide"
		)

/datum/agent/merlin
	id = "Merlin"
	intro_anim = "Greet"
	idle_animations = list(
		"Idle1_1",
		"Idle1_2",
		"Idle1_3",
		"Idle1_4",
		"Idle2_1",
		"Idle2_2",
		"Idle3_1",
		"Idle3_2",
		"RestPose"
	)

/datum/agent/bonzi
	id = "Bonzi"
	intro_anim = "Greet"
	idle_animations = list(
		"Idle1_1",
		"Idle1_2",
		"Idle1_3",
		"Idle1_4",
		"Idle1_5",
		"Idle2_1",
		"Idle2_2",
		"Idle3_1",
		"Idle3_2",
		"Idle3_3",
		"RestPose"
	)

/datum/agent/genie
	id = "Genie"
	intro_anim = "Greet"
	idle_animations = list(
		"Idle1_1",
		"Idle1_2",
		"Idle1_3",
		"Idle1_4",
		"Idle1_5",
		"Idle1_6",
		"Idle2_1",
		"Idle2_2",
		"Idle3_1",
		"Idle3_2",
		"RestPose"
	)

/datum/agent/fone
	id = "F1"
	intro_anim = "Greeting"
	idle_animations = list(
		"IdleLookDown",
		"IdleCuteToeTwist",
		"IdleLowersBrows",
		"IdleBlink",
		"IdleHeadPatting",
		"Idle1_1",
		"IdleBlinkWithBrows",
		"IdleLeansAgainstWall",
		"IdleLooksAtUser",
		"IdleLookRight",
		"IdleFallsAsleep",
		"IdleLowersToGround",
		"IdleLookLeft",
		"RestPose"
	)

/datum/agent/genius
	id = "Genius"
	intro_anim = "Greeting"
	idle_animations = list(
		"DeepIdle1",
		"Idle1_1",
		"Idle7",
		"Idle6",
		"Idle5",
		"Idle4",
		"Idle3",
		"Idle2",
		"Idle1",
		"Idle0",
		"Idle9",
		"Idle8",
		"RestPose"
	)

/datum/agent/links
	id = "Links"
	intro_anim = "Greeting"
	idle_animations = list(
		"IdleTailWagA",
		"IdleTailWagC",
		"IdleScratch",
		"IdleTailWagD",
		"IdleTailWagB",
		"IdleBlink",
		"Idle1_1",
		"IdleStretch",
		"DeepIdleE",
		"IdleButterFly",
		"IdleTwitch",
		"IdleCleaning",
		"IdleLegLick",
		"DeepIdleA",
		"IdleYawn",
		"RestPose"
	)

/datum/agent/peedy
	id = "Peedy"
	intro_anim = "Greet"
	idle_animations = list(
		"Idle1_1",
		"Idle1_2",
		"Idle1_3",
		"Idle1_4",
		"Idle1_5",
		"Idle2_1",
		"Idle2_2",
		"Idle3_1",
		"Idle3_2",
		"Idle3_3",
		"RestPose"
	)

/datum/agent/rocky
	id = "Rocky"
	intro_anim = "Greeting"
	idle_animations = list(
		"DeepIdle1",
		"Idle(1)",
		"Idle(3)",
		"Idle(5)",
		"Idle1_1",
		"Idle(9)",
		"Idle(7)",
		"Idle(2)",
		"Idle(4)",
		"Idle(6)",
		"Idle(8)",
		"RestPose"
	)

/datum/agent/rover
	id = "Rover"
	intro_anim = "Greet"
	idle_animations = list(
		"Idle",
		"RestPose"
	)
