GLOBAL_LIST_EMPTY_TYPED(singularity_computers, /obj/machinery/computer/singularity)

// MBTODO: Make it have its own speaker for singularity operations.
// Can be disabled with wirecutter.
/obj/machinery/computer/singularity
	name = "singularity control console"
	desc = "Transforming the singularity from a terror-inducing class action lawsuit into a useful class action lawsuit, this console safely controls the equipment containing the singularity, as well as harnessing its energy output."
	icon_screen = "commsyndie" // idk
	light_color = COLOR_SOFT_RED

	VAR_PRIVATE
		list/connected_machines = list()

		stage = STAGE_SINGULARITY_CONSOLE_NOT_STARTED
		talk_into_radio = TRUE

		obj/item/radio/internal_radio
		datum/weakref/singularity_ref

		atom/movable/screen/map_view/camera_screen
		atom/movable/screen/background/camera_background
		obj/machinery/camera/active_camera

		map_name

// HACK: We assume these won't be moving for the prototype.
// Thus, we don't care about building a new one on top of an existing powernet.
/obj/machinery/computer/singularity/Initialize(mapload)
	. = ..()

	GLOB.singularity_computers += src

	internal_radio = new(src)
	internal_radio.keyslot = new /obj/item/encryptionkey/headset_eng
	internal_radio.set_listening(TRUE)
	internal_radio.recalculateChannels()

	map_name = "singularity_camera_[REF(src)]"

/obj/machinery/computer/singularity/LateInitialize()
	. = ..()

	for (var/obj/machinery/camera/camera as anything in GLOB.cameranet.cameras)
		if (camera.c_tag != "Singularity Bay")
			continue

		assign_camera(camera)
		return

/obj/machinery/computer/singularity/Destroy()
	GLOB.singularity_computers -= src

	active_camera = null

	QDEL_NULL(camera_background)
	QDEL_NULL(camera_screen)
	QDEL_NULL(internal_radio)

	return ..()

// not now, definitely later
/obj/machinery/computer/singularity/screwdriver_act(mob/living/user, obj/item/I)
	balloon_alert(user, "you can't find the panel!")
	return TRUE

/obj/machinery/computer/singularity/ui_interact(mob/user, datum/tgui/ui)
	. = ..()

	ui = SStgui.try_update_ui(user, src, ui)
	update_camera_view()

	if(!ui)
		camera_screen.display_to(user)
		user.client?.register_map_obj(camera_background)

		ui = new(user, src, "SingularityControl")
		ui.open()

/obj/machinery/computer/singularity/ui_act(action, list/params)
	. = ..()
	if (.)
		return .

	// MBTODO: Access? Whatever
	switch (action)
		if ("fire_emitters")
			fire_emitters()
			return TRUE

	return TRUE

/obj/machinery/computer/singularity/ui_data(mob/user)
	var/list/data = list()

	if (stage == STAGE_SINGULARITY_CONSOLE_FINISHED)
		data["singularity_data"] = try_singularity_ui_data() // Might mutate stage

	data["stage"] = stage
	data["enabled_field_generators"] = 0
	data["disabled_field_generators"] = 0
	data["singularity_generator"] = FALSE
	data["turrets"] = 0

	for (var/obj/connected_machine as anything in connected_machines)
		if (istype(connected_machine, /obj/machinery/field/generator/singularity))
			var/obj/machinery/field/generator/singularity/field_generator = connected_machine
			if (field_generator.active == 2) // FG_ONLINE :(((((
				data["enabled_field_generators"] += 1
			else
				data["disabled_field_generators"] += 1
		else if (istype(connected_machine, /obj/machinery/singularity_generator))
			data["singularity_generator"] = TRUE
		else if (istype(connected_machine, /obj/machinery/singularity_turret))
			data["turrets"] += 1

	return data

/obj/machinery/computer/singularity/ui_static_data(mob/user)
	return list(
		"map_name" = map_name,
	)

/obj/machinery/computer/singularity/proc/try_singularity_ui_data()
	var/obj/contained_singularity/singularity = singularity_ref?.resolve()
	if (isnull(singularity))
		stage = STAGE_SINGULARITY_CONSOLE_NOT_STARTED
		return null

	return singularity.console_ui_data()

/obj/machinery/computer/singularity/proc/fire_emitters()
	if (stage != STAGE_SINGULARITY_CONSOLE_NOT_STARTED)
		return

	stage = STAGE_SINGULARITY_CONSOLE_PREPARING
	speak("Preparing to fire emitters.")

	for (var/obj/machinery/singularity_turret/emitter in connected_machines)
		emitter.prepare_fire()

/obj/machinery/computer/singularity/proc/speak(message)
	if (talk_into_radio)
		internal_radio.talk_into(src, message, RADIO_CHANNEL_ENGINEERING)
	else
		say(message)

/obj/machinery/computer/singularity/proc/connect_machine(parent)
	connected_machines += parent

	if (istype(parent, /obj/machinery/singularity_generator))
		RegisterSignal(parent, COMSIG_SINGULARITY_GENERATOR_CREATED_SINGULARITY, PROC_REF(on_created_singularity))

/obj/machinery/computer/singularity/proc/disconnect_machine(parent)
	connected_machines -= parent

	if (istype(parent, /obj/machinery/singularity_generator))
		UnregisterSignal(parent, COMSIG_SINGULARITY_GENERATOR_CREATED_SINGULARITY)

/obj/machinery/computer/singularity/proc/on_created_singularity(datum/source, obj/contained_singularity/singularity)
	SIGNAL_HANDLER

	stage = STAGE_SINGULARITY_CONSOLE_FINISHED
	singularity_ref = WEAKREF(singularity)

/obj/machinery/computer/singularity/proc/assign_camera(obj/machinery/camera/camera)
	active_camera = camera
	RegisterSignal(camera, COMSIG_PARENT_QDELETING, PROC_REF(clear_camera))

	camera_screen = new
	camera_screen.generate_view(map_name)

	camera_background = new
	camera_background.assigned_map = map_name
	camera_background.del_on_map_removal = FALSE

	update_camera_view()

/obj/machinery/computer/singularity/proc/clear_camera()
	SIGNAL_HANDLER

	active_camera = null
	update_camera_view()

/obj/machinery/computer/singularity/proc/update_camera_view()
	if (isnull(active_camera) || !active_camera.can_use())
		camera_screen.vis_contents.Cut()
		camera_background.icon_state = "scanline2"
		camera_background.fill_rect(1, 1, DEFAULT_MAP_SIZE, DEFAULT_MAP_SIZE)
	else if (camera_screen.vis_contents.len == 0)
		active_camera.update_camera_screens(camera_screen, camera_background)
