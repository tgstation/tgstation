
GLOBAL_LIST_EMPTY_TYPED(singularity_computers, /obj/machinery/computer/singularity)

// MBTODO: Make it have its own speaker for singularity operations.
// Can be disabled with wirecutter.
/obj/machinery/computer/singularity
	name = "singularity control console"
	desc = "Transforming the singularity from a terror-inducing class action lawsuit into a useful class action lawsuit, this console safely controls the equipment containing the singularity, as well as harnessing its energy output."
	icon_screen = "commsyndie" // idk
	light_color = COLOR_SOFT_RED

	var/list/connected_machines = list()

	VAR_PRIVATE/stage = STAGE_SINGULARITY_CONSOLE_NOT_STARTED
	VAR_PRIVATE/obj/item/radio/internal_radio
	VAR_PRIVATE/talk_into_radio = TRUE

// HACK: We assume these won't be moving for the prototype.
// Thus, we don't care about building a new one on top of an existing powernet.
/obj/machinery/computer/singularity/Initialize(mapload)
	. = ..()

	GLOB.singularity_computers += src

	internal_radio = new(src)
	internal_radio.keyslot = new /obj/item/encryptionkey/headset_eng
	internal_radio.set_listening(TRUE)
	internal_radio.recalculateChannels()

/obj/machinery/computer/singularity/Destroy()
	GLOB.singularity_computers -= src
	QDEL_NULL(internal_radio)

	return ..()

// not now, definitely later
/obj/machinery/computer/singularity/screwdriver_act(mob/living/user, obj/item/I)
	balloon_alert(user, "you can't find the panel!")
	return TRUE

/obj/machinery/computer/singularity/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
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

/obj/machinery/computer/singularity/proc/fire_emitters()
	if (stage != STAGE_SINGULARITY_CONSOLE_NOT_STARTED)
		return

	stage = STAGE_SINGULARITY_CONSOLE_PREPARING
	speak("Preparing to fire emitters.")

	// TODO: 'sound/magic/lightning_chargeup.ogg' from the generator

	for (var/obj/machinery/singularity_turret/emitter in connected_machines)
		emitter.prepare_fire()

/obj/machinery/computer/singularity/proc/speak(message)
	if (talk_into_radio)
		internal_radio.talk_into(src, message, RADIO_CHANNEL_ENGINEERING)
	else
		say(message)
