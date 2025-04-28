// A decorational representation of SSblackbox, usually placed alongside the message server. Also contains a traitor theft item.
/obj/machinery/blackbox_recorder
	name = "Blackbox Recorder"
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "blackbox"
	density = TRUE
	armor_type = /datum/armor/machinery_blackbox_recorder
	/// The object that's stored in the machine, which is to say, the blackbox itself.
	/// When it hasn't already been stolen, of course.
	var/obj/item/stored

/datum/armor/machinery_blackbox_recorder
	melee = 25
	bullet = 10
	laser = 10
	fire = 50
	acid = 70

/obj/machinery/blackbox_recorder/Initialize(mapload)
	. = ..()
	stored = new /obj/item/blackbox(src)

/obj/machinery/blackbox_recorder/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(stored)
		stored.forceMove(drop_location())
		if(Adjacent(user))
			user.put_in_hands(stored)
		stored = null
		to_chat(user, span_notice("You remove the blackbox from [src]. The tapes stop spinning."))
		update_appearance()
		return
	else
		to_chat(user, span_warning("It seems that the blackbox is missing..."))
		return

/obj/machinery/blackbox_recorder/attackby(obj/item/attacking_item, mob/living/user, list/modifiers)
	if(istype(attacking_item, /obj/item/blackbox))
		if(HAS_TRAIT(attacking_item, TRAIT_NODROP) || !user.transferItemToLoc(attacking_item, src))
			to_chat(user, span_warning("[attacking_item] is stuck to your hand!"))
			return
		user.visible_message(span_notice("[user] clicks [attacking_item] into [src]!"), \
		span_notice("You press the device into [src], and it clicks into place. The tapes begin spinning again."))
		playsound(src, 'sound/machines/click.ogg', 50, TRUE)
		stored = attacking_item
		update_appearance()
		return
	return ..()

/obj/machinery/blackbox_recorder/Destroy()
	if(stored)
		stored.forceMove(loc)
		new /obj/effect/decal/cleanable/oil(loc)
	return ..()

/obj/machinery/blackbox_recorder/update_icon_state()
	icon_state = "blackbox[stored ? null : "_b"]"
	return ..()

/obj/item/blackbox
	name = "\proper the blackbox"
	desc = "A strange relic, capable of recording data on extradimensional vertices. It lives inside the blackbox recorder for safe keeping."
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "blackcube"
	inhand_icon_state = "blackcube"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF


/**
 * The equivalent of the server, for PDA and request console messages.
 * Without it, PDA and request console messages cannot be transmitted.
 * PDAs require the rest of the telecomms setup, but request consoles only
 * require the message server.
 */
/obj/machinery/telecomms/message_server
	name = "Messaging Server"
	desc = "A machine that processes and routes PDA and request console messages."
	icon_state = "message_server"
	telecomms_type = /obj/machinery/telecomms/message_server
	density = TRUE
	circuit = /obj/item/circuitboard/machine/telecomms/message_server

	/// A list of all the PDA messages that were intercepted and processed by
	/// this messaging server.
	var/list/datum/data_tablet_msg/pda_msgs = list()
	/// A list of all the Request Console messages that were intercepted and
	/// processed by this messaging server.
	var/list/datum/data_rc_msg/rc_msgs = list()
	/// The password of this messaging server.
	var/decryptkey = "password"
	/// Init reads this and adds world.time, then becomes 0 when that time has
	/// passed and the machine works.
	/// Basically, if it's not 0, it's calibrating and therefore non-functional.
	var/calibrating = 15 MINUTES
	/// List of all the computers monitoring this server
	var/list/obj/machinery/computer/message_monitor/listening_computers = list()

#define MESSAGE_SERVER_FUNCTIONING_MESSAGE "This is an automated message. The messaging system is functioning correctly."

/obj/machinery/telecomms/message_server/Initialize(mapload)
	. = ..()
	if (calibrating)
		calibrating += world.time
		say("Calibrating... Estimated wait time: [rand(3, 9)] minutes.")
		pda_msgs += new /datum/data_tablet_msg("System Administrator", "system", "This is an automated message. System calibration started at [station_time_timestamp()].")
	else
		pda_msgs += new /datum/data_tablet_msg("System Administrator", "system", MESSAGE_SERVER_FUNCTIONING_MESSAGE)

/obj/machinery/telecomms/message_server/Destroy()
	for(var/obj/machinery/computer/message_monitor/monitor in listening_computers)
		monitor.set_linked_server(null)
	listening_computers = null
	return ..()

/obj/machinery/telecomms/message_server/examine(mob/user)
	. = ..()
	if(calibrating)
		. += span_warning("It's still calibrating.")

/obj/machinery/telecomms/message_server/process()
	. = ..()
	if(calibrating && calibrating <= world.time)
		calibrating = 0
		pda_msgs += new /datum/data_tablet_msg("System Administrator", "system", MESSAGE_SERVER_FUNCTIONING_MESSAGE)

#undef MESSAGE_SERVER_FUNCTIONING_MESSAGE

/obj/machinery/telecomms/message_server/receive_information(datum/signal/subspace/messaging/signal, obj/machinery/telecomms/machine_from)
	// can't log non-message signals
	if(!istype(signal) || !signal.data["message"] || !on || calibrating)
		return

	// log the signal
	if(istype(signal, /datum/signal/subspace/messaging/tablet_message))
		var/datum/signal/subspace/messaging/tablet_message/PDAsignal = signal
		var/datum/data_tablet_msg/log_message = new(PDAsignal.format_target(), PDAsignal.format_sender(), PDAsignal.format_message(), PDAsignal.format_photo_path())
		pda_msgs += log_message
	else if(istype(signal, /datum/signal/subspace/messaging/rc))
		var/datum/data_rc_msg/msg = new(signal.data["receiving_department"], signal.data["sender_department"], signal.data["message"], signal.data["stamped"], signal.data["verified"], signal.data["priority"])
		if(signal.data["sender_department"]) // don't log messages not from a department but allow them to work
			rc_msgs += msg
	signal.data["reject"] = FALSE

	// pass it along to either the hub or the broadcaster
	if(!relay_information(signal, /obj/machinery/telecomms/hub))
		relay_information(signal, /obj/machinery/telecomms/broadcaster)

/obj/machinery/telecomms/message_server/update_overlays()
	. = ..()

	if(calibrating)
		. += "message_server_calibrate"

// Preset messaging server
/obj/machinery/telecomms/message_server/preset
	id = "Messaging Server"
	network = "tcommsat"
	autolinkers = list("messaging")
	calibrating = 0

GLOBAL_VAR(preset_station_message_server_key)

/obj/machinery/telecomms/message_server/preset/Initialize(mapload)
	. = ..()
	// Just in case there are multiple preset messageservers somehow once the CE arrives,
	// we want those on the station to share the same preset default decrypt key shown in his memories.
	var/is_on_station = is_station_level(z)
	if(is_on_station && GLOB.preset_station_message_server_key)
		decryptkey = GLOB.preset_station_message_server_key
		return
	//Generate a random password for the message server
	decryptkey = pick("the", "if", "of", "as", "in", "a", "you", "from", "to", "an", "too", "little", "snow", "dead", "drunk", "rosebud", "duck", "al", "le")
	decryptkey += pick("diamond", "beer", "mushroom", "assistant", "clown", "captain", "twinkie", "security", "nuke", "small", "big", "escape", "yellow", "gloves", "monkey", "engine", "nuclear", "ai")
	decryptkey += "[rand(0, 9)]"
	if(is_on_station)
		GLOB.preset_station_message_server_key = decryptkey

// Root messaging signal datum
/datum/signal/subspace/messaging
	frequency = FREQ_COMMON
	server_type = /obj/machinery/telecomms/message_server

/datum/signal/subspace/messaging/New(init_source, init_data)
	source = init_source
	data = init_data
	var/turf/origin_turf = get_turf(source)
	levels = SSmapping.get_connected_levels(origin_turf)
	if(!("reject" in data))
		data["reject"] = TRUE

/datum/signal/subspace/messaging/copy()
	var/datum/signal/subspace/messaging/copy = new type(source, data.Copy())
	copy.original = src
	copy.levels = levels
	return copy

// Tablet message signal datum
/// Returns a string representing the target of this message, formatted properly.
/datum/signal/subspace/messaging/tablet_message/proc/format_target()
	if (data["everyone"])
		return "Everyone"

	var/datum/computer_file/program/messenger/target_app = data["targets"][1]
	var/obj/item/modular_computer/target = target_app.computer
	return STRINGIFY_PDA_TARGET(target.saved_identification, target.saved_job)

/// Returns a string representing the sender of this message, formatted properly.
/datum/signal/subspace/messaging/tablet_message/proc/format_sender()
	var/display_name = get_messenger_name(locate(data["ref"]))
	return display_name ? display_name : STRINGIFY_PDA_TARGET(data["fakename"], data["fakejob"])

/// Returns the formatted message contained in this message. Use this to apply
/// any processing to it if it needs to be formatted in a specific way.
/datum/signal/subspace/messaging/tablet_message/proc/format_message()
	return data["message"]

/// Returns the formatted photo path contained in this message, if there's one.
/datum/signal/subspace/messaging/tablet_message/proc/format_photo_path()
	return data["photo"]

/datum/signal/subspace/messaging/tablet_message/broadcast()
	for (var/datum/computer_file/program/messenger/app in data["targets"])
		if(!QDELETED(app))
			app.receive_message(src)

// Request Console signal datum
/datum/signal/subspace/messaging/rc/broadcast()
	var/recipient_department = ckey(data["recipient_department"])
	for (var/obj/machinery/requests_console/console in GLOB.req_console_all)
		if(ckey(console.department) == recipient_department || (data["ore_update"] && console.receive_ore_updates))
			console.create_message(data)

/// Log datums stored by the message server.
/datum/data_tablet_msg
	/// Who sent the message.
	var/sender = "Unspecified"
	/// Who was targeted by the message.
	var/recipient = "Unspecified"
	/// The transfered message.
	var/message = "Blank"
	/// The attached photo path, if any.
	var/picture_asset_key
	/// Whether or not it's an automated message. Defaults to `FALSE`.
	var/automated = FALSE


/datum/data_tablet_msg/New(param_rec, param_sender, param_message, param_photo)
	if(param_rec)
		recipient = param_rec
	if(param_sender)
		sender = param_sender
	if(param_message)
		message = param_message
	if(param_photo)
		picture_asset_key = param_photo


#define REQUEST_PRIORITY_NORMAL "Normal"
#define REQUEST_PRIORITY_HIGH "High"
#define REQUEST_PRIORITY_EXTREME "Extreme"
#define REQUEST_PRIORITY_UNDETERMINED "Undetermined"


/datum/data_rc_msg
	/// The department that sent the request.
	var/sender_department = "Unspecified"
	/// The department that was targeted by the request.
	var/receiving_department = "Unspecified"
	/// The message of the request.
	var/message = "Blank"
	/// The stamp that authenticated this message, if any.
	var/stamp = "Unstamped"
	/// The ID that authenticated this message, if any.
	var/id_auth = "Unauthenticated"
	/// The priority of this request.
	var/priority = REQUEST_PRIORITY_NORMAL

/datum/data_rc_msg/New(param_rec, param_sender, param_message, param_stamp, param_id_auth, param_priority)
	if(param_rec)
		receiving_department = param_rec
	if(param_sender)
		sender_department = param_sender
	if(param_message)
		message = param_message
	if(param_stamp)
		stamp = param_stamp
	if(param_id_auth)
		id_auth = param_id_auth
	if(param_priority)
		switch(param_priority)
			if(REQ_NORMAL_MESSAGE_PRIORITY)
				priority = REQUEST_PRIORITY_NORMAL
			if(REQ_HIGH_MESSAGE_PRIORITY)
				priority = REQUEST_PRIORITY_HIGH
			if(REQ_EXTREME_MESSAGE_PRIORITY)
				priority = REQUEST_PRIORITY_EXTREME
			else
				priority = REQUEST_PRIORITY_UNDETERMINED

#undef REQUEST_PRIORITY_NORMAL
#undef REQUEST_PRIORITY_HIGH
#undef REQUEST_PRIORITY_EXTREME
#undef REQUEST_PRIORITY_UNDETERMINED
