#define CRITICAL_HEALTH_THRESHOLD 20

#define STAGE_SINGULARITY_CONSOLE_NOT_STARTED "not_started"
#define STAGE_SINGULARITY_CONSOLE_PREPARING "preparing"
#define STAGE_SINGULARITY_CONSOLE_FINISHED "finished"
#define STAGE_SINGULARITY_CONSOLE_SELF_DESTRUCTING "self_destructing"
#define STAGE_SINGULARITY_CONSOLE_DESTROYED "destroyed"

GLOBAL_LIST_EMPTY_TYPED(singularity_computers, /obj/machinery/computer/singularity)

/obj/machinery/computer/singularity
	name = "singularity control console"
	desc = "Transforming the singularity from a terror-inducing class action lawsuit into a useful class action lawsuit, this console safely controls the equipment containing the singularity, as well as harnessing its energy output."
	icon_screen = "commsyndie" // idk
	light_color = COLOR_SOFT_RED

	req_access = list(ACCESS_ENGINEERING)

	COOLDOWN_DECLARE(overclock_cooldown)

	VAR_PRIVATE
		list/connected_machines = list()

		stage = STAGE_SINGULARITY_CONSOLE_NOT_STARTED
		talk_into_radio = TRUE

		obj/item/radio/internal_radio
		datum/weakref/singularity_ref

		atom/movable/screen/map_view/camera_screen
		atom/movable/screen/background/camera_background
		obj/machinery/camera/active_camera

		last_reported_health
		report_health_timer_id

		camera_map_name

// HACK: We assume these won't be moving for the prototype.
// Thus, we don't care about building a new one on top of an existing powernet.
/obj/machinery/computer/singularity/Initialize(mapload)
	. = ..()

	GLOB.singularity_computers += src

	internal_radio = new(src)
	internal_radio.keyslot = new /obj/item/encryptionkey/headset_eng
	internal_radio.recalculateChannels()

	camera_map_name = "singularity_camera_[REF(src)]"

/obj/machinery/computer/singularity/post_machine_initialize()
	. = ..()

	for (var/obj/machinery/camera/camera as anything in SScameras.cameras)
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

/obj/machinery/computer/singularity/examine(mob/user)
	. = ..()

	if (talk_into_radio)
		. += span_notice("[p_Their()] communication wire is intact.")
	else
		. += span_warning("[p_Their()] communication wire is cut!")

	return .

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
	var/mob/user = usr

	. = ..()
	if (.)
		return .

	switch (stage)
		if (STAGE_SINGULARITY_CONSOLE_NOT_STARTED)
			switch (action)
				if ("fire_emitters")
					fire_emitters(user)
					return TRUE
		if (STAGE_SINGULARITY_CONSOLE_FINISHED)
			switch (action)
				if ("enable_all_emitters")
					enable_all_emitters(user)
					return TRUE
				if ("disable_all_emitters")
					disable_all_emitters(user)
					return TRUE
				if ("overclock")
					try_overclock(user)
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
	data["enabled_emitters"] = 0
	data["disabled_emitters"] = 0
	data["has_access"] = allowed(user)
	data["overclock_access"] = overclock_access(user)

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
			var/obj/machinery/singularity_turret/turret = connected_machine
			if (turret.datum_flags & DF_ISPROCESSING)
				data["enabled_emitters"] += 1
			else
				data["disabled_emitters"] += 1

	return data

/obj/machinery/computer/singularity/ui_static_data(mob/user)
	return list(
		"map_name" = camera_map_name,
		"emitters_require_shields" = POWER_BAR_FLAG(FFLAG_EMITTERS_REQUIRE_SHIELDS),
	)

/obj/machinery/computer/singularity/ui_status(mob/user)
	. = ..()

	if (!allowed(user))
		return min(., UI_UPDATE)

	return .

/obj/machinery/computer/singularity/emag_act(mob/user, obj/item/card/emag/emag_card)
	if (obj_flags & EMAGGED)
		return

	obj_flags |= EMAGGED
	balloon_alert(user, "overrode access")
	req_access.Cut()

/obj/machinery/computer/singularity/wirecutter_act(mob/living/user, obj/item/tool)
	if (DOING_INTERACTION_WITH_TARGET(user, src))
		return TRUE

	if (talk_into_radio)
		balloon_alert(user, "cutting communication wire...")
		if (!do_after(user, 3 SECONDS))
			return TRUE

		talk_into_radio = FALSE
		balloon_alert(user, "cut communication wire")
		user.log_message("cut communication wire to singularity console at [AREACOORD(src)]", LOG_GAME)
	else
		balloon_alert(user, "mending communication wire...")
		if (!do_after(user, 3 SECONDS))
			return TRUE

		talk_into_radio = TRUE
		balloon_alert(user, "mended communication wire")
		user.log_message("mended communication wire to singularity console at [AREACOORD(src)]", LOG_GAME)

	user.playsound_local(get_turf(src), tool.usesound, 50, vary = TRUE)

	return TRUE

/obj/machinery/computer/singularity/proc/try_singularity_ui_data()
	var/obj/contained_singularity/singularity = singularity_ref?.resolve()
	if (isnull(singularity))
		stage = STAGE_SINGULARITY_CONSOLE_NOT_STARTED
		return null

	var/list/ui_data = singularity.console_ui_data()
	ui_data["delay_to_overclock"] = COOLDOWN_TIMELEFT(src, overclock_cooldown)
	return ui_data

/obj/machinery/computer/singularity/proc/fire_emitters(mob/user)
	if (stage != STAGE_SINGULARITY_CONSOLE_NOT_STARTED)
		return

	stage = STAGE_SINGULARITY_CONSOLE_PREPARING
	speak("Preparing to fire emitters.")

	var/enabled_field_generators = 0
	for (var/obj/machinery/field/generator/singularity/field_generator in connected_machines)
		if (field_generator.active == 2) // FG_ONLINE :(((((
			enabled_field_generators += 1

	var/enough_field_generators = enabled_field_generators >= 4

	user?.log_message("started the emitters for the singularity[enough_field_generators ? "" : " with only [enabled_field_generators] field generator\s"].", LOG_GAME)
	if (!enough_field_generators)
		message_admins("[user ? ADMIN_LOOKUPFLW(user) : "Something"] started the emitters for the singularity with only [enabled_field_generators] field generator\s.")

	for (var/obj/machinery/singularity_turret/emitter in connected_machines)
		emitter.prepare_fire()

/obj/machinery/computer/singularity/proc/speak(message, common = FALSE)
	if (talk_into_radio)
		internal_radio.talk_into(src, message, RADIO_CHANNEL_ENGINEERING)
		if (common)
			internal_radio.talk_into(src, message)
	else
		say(message)

/obj/machinery/computer/singularity/proc/enable_all_emitters(mob/user)
	user?.log_message("enabled all emitters.", LOG_GAME)

	for (var/obj/machinery/singularity_turret/turret in connected_machines)
		turret.begin_processing()

/obj/machinery/computer/singularity/proc/disable_all_emitters(mob/user)
	user?.log_message("disabled all emitters.", LOG_GAME)

	for (var/obj/machinery/singularity_turret/turret in connected_machines)
		turret.end_processing()

/obj/machinery/computer/singularity/proc/connect_machine(machine)
	connected_machines += machine

	if (istype(machine, /obj/machinery/singularity_generator))
		RegisterSignal(machine, COMSIG_SINGULARITY_GENERATOR_CREATED_SINGULARITY, PROC_REF(on_created_singularity))

/obj/machinery/computer/singularity/proc/disconnect_machine(atom/machine)
	// This is the most important part, we can't let you start it without the computer connected.
	if (istype(machine, /obj/machinery/singularity_generator))
		// This hard-dels but it's a protoype I don't care
		if (QDELETED(machine))
			connected_machines -= machine

		return

	connected_machines -= machine

/obj/machinery/computer/singularity/proc/on_created_singularity(datum/source, obj/contained_singularity/singularity)
	SIGNAL_HANDLER

	stage = STAGE_SINGULARITY_CONSOLE_FINISHED
	last_reported_health = singularity.health
	COOLDOWN_START(src, overclock_cooldown, POWER_BAR_FLAG(FFLAG_INITIAL_OVERCLOCK_DELAY))

	singularity_ref = WEAKREF(singularity)

	RegisterSignal(singularity, COMSIG_SINGULARITY_TAKE_DAMAGE, PROC_REF(on_singularity_take_damage))
	RegisterSignal(singularity, COMSIG_SINGULARITY_SELF_DESTRUCTING, PROC_REF(on_self_destructing))
	RegisterSignal(singularity, COMSIG_SINGULARITY_ADVANCE_SELF_DESTRUCT_STAGE, PROC_REF(on_advance_self_destruct_stage))

#define OVERCLOCK_ACCESS_NOT_ALLOWED "not_allowed"
#define OVERCLOCK_ACCESS_NOT_ALLOWED_SILICON "not_allowed_silicon"
#define OVERCLOCK_ACCESS_NOT_ALLOWED_TOO_DAMAGED "not_allowed_too_damaged"
#define OVERCLOCK_ACCESS_ALLOWED "allowed"

/obj/machinery/computer/singularity/proc/overclock_access(mob/living/user)
	if (!istype(user))
		return OVERCLOCK_ACCESS_NOT_ALLOWED

	if (issilicon(user))
		return OVERCLOCK_ACCESS_NOT_ALLOWED_SILICON

	if (!COOLDOWN_FINISHED(src, overclock_cooldown))
		return OVERCLOCK_ACCESS_NOT_ALLOWED

	var/obj/contained_singularity/singularity = singularity_ref?.resolve()
	if (isnull(singularity))
		return OVERCLOCK_ACCESS_NOT_ALLOWED

	if (singularity.health / singularity.max_health < POWER_BAR_FLAG(FFLAG_OVERCLOCK_NECESSARY_HEALTH))
		return OVERCLOCK_ACCESS_NOT_ALLOWED_TOO_DAMAGED

	if (obj_flags & EMAGGED)
		return OVERCLOCK_ACCESS_ALLOWED

	var/obj/item/id = user.get_idcard(hand_first = TRUE)
	if (isnull(id))
		return OVERCLOCK_ACCESS_NOT_ALLOWED

	return OVERCLOCK_ACCESS_ALLOWED

/obj/machinery/computer/singularity/proc/try_overclock(mob/user)
	if (overclock_access(user) != OVERCLOCK_ACCESS_ALLOWED)
		return

	user.log_message("started an overclock on the singularity", LOG_GAME)
	message_admins("[ADMIN_LOOKUPFLW(user)] started an overclock on the singularity.")

	COOLDOWN_START(src, overclock_cooldown, POWER_BAR_FLAG(FFLAG_ADDED_OVERCLOCK_DELAY))

	INVOKE_ASYNC(src, PROC_REF(perform_overclock))

/obj/machinery/computer/singularity/proc/perform_overclock()
	speak("Commencing overclocking sequence.")

	playsound(src, 'sound/effects/seedling_chargeup.ogg', vol = 60, vary = TRUE, frequency = 44100 / 2)

	var/list/emitters = list()

	for (var/obj/machinery/singularity_turret/emitter in connected_machines)
		emitters += emitter
		emitter.pause_counter += 1

	stoplag(6 SECONDS)

	var/time_spent = 0

	while (time_spent < POWER_BAR_FLAG(FFLAG_OVERCLOCK_TIME_SPENT))
		for (var/obj/machinery/singularity_turret/emitter as anything in emitters)
			if (QDELETED(emitter))
				emitters -= emitter
				continue

			emitter.fire_beam(overclocked = TRUE)

		if (POWER_BAR_FLAG(FFLAG_OVERCLOCK_USES_SLEEP))
			sleep(0.2 SECONDS)
			time_spent += 0.2 SECONDS
		else
			time_spent += TICKS2DS(stoplag(0.2 SECONDS))

	for (var/obj/machinery/singularity_turret/emitter as anything in emitters)
		emitter.pause_counter -= 1

	var/obj/contained_singularity/singularity = singularity_ref?.resolve()

	if (emitters.len == 0 || isnull(singularity))
		speak("Overclocking was not successful, something critical was missing.")
		return

	speak("Overclocking successful, extracted temporary power bars. Singularity is currently at [round(100 * (singularity.health / singularity.max_health))]% containment.")

#undef OVERCLOCK_ACCESS_NOT_ALLOWED
#undef OVERCLOCK_ACCESS_NOT_ALLOWED_SILICON
#undef OVERCLOCK_ACCESS_ALLOWED

/obj/machinery/computer/singularity/proc/on_singularity_take_damage(obj/contained_singularity/singularity)
	SIGNAL_HANDLER

	if (!isnull(report_health_timer_id))
		var/difference = abs((singularity.health / singularity.max_health) - (last_reported_health / singularity.max_health))

		if (difference > 0.35 || ((last_reported_health > CRITICAL_HEALTH_THRESHOLD) != (singularity.health > CRITICAL_HEALTH_THRESHOLD)))
			report_singularity_health()

		return

	report_singularity_health()
	start_singularity_health_report_timer()

/obj/machinery/computer/singularity/proc/report_singularity_health()
	deltimer(report_health_timer_id)
	report_health_timer_id = null

	var/obj/contained_singularity/singularity = singularity_ref?.resolve()
	if (isnull(singularity))
		return

	var/health = singularity.health
	if (health == last_reported_health)
		return

	if (health == singularity.max_health)
		speak("Singularity containment fully restored.")
	else if (health > last_reported_health)
		speak("Singularity containment restoring, containment at [health]%.")
	else if (health > CRITICAL_HEALTH_THRESHOLD)
		speak("Singularity containment <b>dropping</b>, containment at [health]%.")
	else if (health > 0)
		speak("<b>DANGER:</b> SINGULARITY CONTAINMENT <b>CRITICALLY LOW</b>, containment at [health]%!", common = TRUE)
	else
		// We'll report it later
		return

	last_reported_health = health
	if (health != singularity.max_health)
		start_singularity_health_report_timer()

/obj/machinery/computer/singularity/proc/start_singularity_health_report_timer()
	report_health_timer_id = addtimer(CALLBACK(src, PROC_REF(report_singularity_health)), 45 SECONDS, TIMER_STOPPABLE)

/obj/machinery/computer/singularity/proc/on_self_destructing()
	SIGNAL_HANDLER

	stage = STAGE_SINGULARITY_CONSOLE_SELF_DESTRUCTING

	// talk_into directly so that we can't get snipped
	internal_radio.talk_into(src, "<b>Singularity containment FAILED, containment breach IMMINENT, repair IMPOSSIBLE. Emergency casualty destabilization field has been activated. [SINGULARITY_BREACH_TIME] seconds until containment breach.</b>")

/obj/machinery/computer/singularity/proc/on_advance_self_destruct_stage(datum/source, time_left)
	SIGNAL_HANDLER

	if (time_left > 5)
		internal_radio.talk_into(src, "<b>[time_left] seconds until containment breach.</b>")
	else
		internal_radio.talk_into(src, "[time_left]...")

	if (time_left <= 1)
		stage = STAGE_SINGULARITY_CONSOLE_DESTROYED

/obj/machinery/computer/singularity/proc/assign_camera(obj/machinery/camera/camera)
	active_camera = camera
	RegisterSignal(camera, COMSIG_QDELETING, PROC_REF(clear_camera))

	camera_screen = new
	camera_screen.generate_view(camera_map_name)

	camera_background = new
	camera_background.assigned_map = camera_map_name
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

#undef CRITICAL_HEALTH_THRESHOLD
#undef STAGE_SINGULARITY_CONSOLE_DESTROYED
#undef STAGE_SINGULARITY_CONSOLE_FINISHED
#undef STAGE_SINGULARITY_CONSOLE_NOT_STARTED
#undef STAGE_SINGULARITY_CONSOLE_PREPARING
#undef STAGE_SINGULARITY_CONSOLE_SELF_DESTRUCTING
