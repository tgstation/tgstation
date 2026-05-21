#define MAX_LOG_ENTRIES 400

/**
 * The server logs all traffic and signal data. Once it records the signal, it
 * sends it to the subspace broadcaster.
 *
 * Store a maximum of `MAX_LOG_ENTRIES` (400) log entries and then deletes them.
 */
/obj/machinery/telecomms/server
	name = "telecommunication server"
	icon_state = "comm_server"
	desc = "A machine used to store data and network statistics."
	telecomms_type = /obj/machinery/telecomms/server
	density = TRUE
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 0.01
	circuit = /obj/item/circuitboard/machine/telecomms/server
	/// List of frequency info: the name and color of each frequency that the server processes
	var/list/frequency_infos = list()
	/// A list of previous entries on the network. It will not exceed
	/// `MAX_LOG_ENTRIES` entries in length, flushing the oldest entries
	/// automatically.
	var/list/log_entries = list()
	/// Total trafic, which is increased every time a signal is increased and
	/// the current traffic is higher than 0. See `traffic` for more info.
	var/total_traffic = 0

/obj/machinery/telecomms/server/receive_information(datum/signal/subspace/vocal/signal, obj/machinery/telecomms/machine_from)
	// can't log non-vocal signals
	if(!istype(signal) || !signal.data["message"] || !is_freq_listening(signal))
		return

	if(traffic > 0)
		total_traffic += traffic // add current traffic to total traffic

	var/freq_info = frequency_infos["[signal.frequency]"]
	if(freq_info)
		signal.data["frequency_name"] = freq_info["name"]
		signal.data["frequency_color"] = freq_info["color"]

	// Delete particularly old logs
	if (log_entries.len >= MAX_LOG_ENTRIES)
		log_entries.Cut(1, 2)

	// Don't create a log if the frequency is banned from being logged
	if(!(signal.frequency in banned_frequencies))
		var/datum/comm_log_entry/log = new
		log.parameters["mobtype"] = signal.virt.source.type
		log.parameters["name"] = signal.data["name"]
		log.parameters["job"] = signal.data["job"]
		log.parameters["message"] = signal.data["message"]
		log.parameters["language"] = signal.language

		// If the signal is still compressed, make the log entry gibberish
		var/compression = signal.data["compression"]
		if(compression > NONE)
			log.input_type = "Corrupt File"
			var/replace_characters = compression >= 20 ? TRUE : FALSE
			log.parameters["name"] = Gibberish(signal.data["name"], replace_characters)
			log.parameters["job"] = Gibberish(signal.data["job"], replace_characters)
			log.parameters["message"] = Gibberish(signal.data["message"], replace_characters)

		// Give the log a name and store it
		var/identifier = num2text(rand(-1000, 1000) + world.time)
		log.name = "data packet ([md5(identifier)])"
		log_entries.Add(log)

	var/can_send = relay_information(signal, /obj/machinery/telecomms/hub)
	if(!can_send)
		relay_information(signal, /obj/machinery/telecomms/broadcaster)

	use_energy(idle_power_usage)

#undef MAX_LOG_ENTRIES

/// Simple log entry datum for the telecommunication server
/datum/comm_log_entry
	/// Type of entry.
	var/input_type = "Speech File"
	/// Name of the entry.
	var/name = "data packet (#)"
	/// Parameters extracted from the signal.
	var/parameters = list()


// Preset Servers
/obj/machinery/telecomms/server/presets
	network = "tcommsat"

/obj/machinery/telecomms/server/presets/Initialize(mapload)
	. = ..()
	name = id


/obj/machinery/telecomms/server/presets/science
	id = "Science Server"
	freq_listening = list(FREQ_SCIENCE)
	autolinkers = list("science")

/obj/machinery/telecomms/server/presets/science/New()
	. = ..()
	frequency_infos["[FREQ_SCIENCE]"] = list(
		"name" = RADIO_CHANNEL_SCIENCE,
		"color" = RADIO_COLOR_SCIENCE
	)

/obj/machinery/telecomms/server/presets/medical
	id = "Medical Server"
	freq_listening = list(FREQ_MEDICAL)
	autolinkers = list("medical")

/obj/machinery/telecomms/server/presets/medical/New()
	. = ..()
	frequency_infos["[FREQ_MEDICAL]"] = list(
		"name" = RADIO_CHANNEL_MEDICAL,
		"color" = RADIO_COLOR_MEDICAL
	)

/obj/machinery/telecomms/server/presets/supply
	id = "Supply Server"
	freq_listening = list(FREQ_SUPPLY)
	autolinkers = list("supply")

/obj/machinery/telecomms/server/presets/supply/New()
	. = ..()
	frequency_infos["[FREQ_SUPPLY]"] = list(
		"name" = RADIO_CHANNEL_SUPPLY,
		"color" = RADIO_COLOR_SUPPLY
	)

/obj/machinery/telecomms/server/presets/service
	id = "Service & Entertainment Server"
	freq_listening = list(FREQ_SERVICE, FREQ_ENTERTAINMENT)
	autolinkers = list("service", "entertainment")

/obj/machinery/telecomms/server/presets/service/New()
	. = ..()
	frequency_infos["[FREQ_SERVICE]"] = list(
		"name" = RADIO_CHANNEL_SERVICE,
		"color" = RADIO_COLOR_SERVICE
	)
	frequency_infos["[FREQ_ENTERTAINMENT]"] = list(
		"name" = RADIO_CHANNEL_ENTERTAINMENT,
		"color" = RADIO_COLOR_ENTERTAIMENT
	)

/obj/machinery/telecomms/server/presets/common
	id = "Common & AI Server"
	freq_listening = list()
	autolinkers = list("common")

/obj/machinery/telecomms/server/presets/common/New()
	. = ..()
	frequency_infos["[FREQ_COMMON]"] = list(
		"name" = RADIO_CHANNEL_COMMON,
		"color" = RADIO_COLOR_COMMON
	)
	frequency_infos["[FREQ_AI_PRIVATE]"] = list(
		"name" = RADIO_CHANNEL_AI_PRIVATE,
		"color" = RADIO_COLOR_AI_PRIVATE
	)

/obj/machinery/telecomms/server/presets/common/Initialize(mapload)
	. = ..()
	// Common and other radio frequencies for people to freely use
	for(var/i = MIN_FREQ, i <= MAX_FREQ, i += 2)
		freq_listening |= i

/obj/machinery/telecomms/server/presets/command
	id = "Command Server"
	freq_listening = list(FREQ_COMMAND)
	autolinkers = list("command")

/obj/machinery/telecomms/server/presets/command/New()
	. = ..()
	frequency_infos["[FREQ_COMMAND]"] = list(
		"name" = RADIO_CHANNEL_COMMAND,
		"color" = RADIO_COLOR_COMMAND
	)

/obj/machinery/telecomms/server/presets/engineering
	id = "Engineering Server"
	freq_listening = list(FREQ_ENGINEERING)
	autolinkers = list("engineering")

/obj/machinery/telecomms/server/presets/engineering/New()
	. = ..()
	frequency_infos["[FREQ_ENGINEERING]"] = list(
		"name" = RADIO_CHANNEL_ENGINEERING,
		"color" = RADIO_COLOR_ENGINEERING
	)

/obj/machinery/telecomms/server/presets/security
	id = "Security Server"
	freq_listening = list(FREQ_SECURITY)
	autolinkers = list("security")

/obj/machinery/telecomms/server/presets/security/New()
	. = ..()
	frequency_infos["[FREQ_SECURITY]"] = list(
		"name" = RADIO_CHANNEL_SECURITY,
		"color" = RADIO_COLOR_SECURITY
	)

/obj/machinery/telecomms/server/presets/common/birdstation/Initialize(mapload)
	. = ..()
	freq_listening = list()
