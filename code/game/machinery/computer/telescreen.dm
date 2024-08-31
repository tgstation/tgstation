/obj/machinery/computer/security/telescreen
	name = "\improper Telescreen"
	desc = "Used for watching an empty arena."
	icon = 'icons/obj/machines/telescreens.dmi'
	icon_state = "telescreen"
	base_icon_state = "telescreen"
	icon_screen = null
	icon_keyboard = null
	layer = SIGN_LAYER
	network = list(CAMERANET_NETWORK_THUNDERDOME)
	density = FALSE
	circuit = null
	light_power = 0
	/// The kind of wallframe that this telescreen drops
	var/frame_type = /obj/item/wallframe/telescreen

/obj/item/wallframe/telescreen
	name = "telescreen frame"
	desc = "A wall-mountable telescreen frame. Apply to wall to use."
	icon = 'icons/obj/machines/telescreens.dmi'
	icon_state = "telescreen"
	result_path = /obj/machinery/computer/security/telescreen

TELESCREEN_DIRECTIONAL_HELPERS(/obj/machinery/computer/security/telescreen)

/obj/machinery/computer/security/telescreen/Initialize(mapload)
	. = ..()
	find_and_hang_on_wall()

/obj/machinery/computer/security/telescreen/on_deconstruction(disassembled)
	new frame_type(loc)

/obj/machinery/computer/security/telescreen/update_icon_state()
	icon_state = initial(icon_state)
	if(machine_stat & BROKEN)
		icon_state += "b"
	return ..()


/obj/machinery/computer/security/telescreen/entertainment
	name = "entertainment monitor"
	desc = "Damn, they better have the /tg/ channel on these things."
	icon = 'icons/obj/machines/telescreens.dmi'
	icon_state = "telescreen" // wallening todo - Should this be merged back into telescreens or keep using status display icons? Icon needs updating regardless.
	network = list()
	density = FALSE
	circuit = null
	interaction_flags_atom = INTERACT_ATOM_UI_INTERACT | INTERACT_ATOM_NO_FINGERPRINT_INTERACT | INTERACT_ATOM_NO_FINGERPRINT_ATTACK_HAND | INTERACT_MACHINE_REQUIRES_SIGHT
	frame_type = /obj/item/wallframe/telescreen/entertainment
	/// Virtual radio inside of the entertainment monitor to broadcast audio
	var/obj/item/radio/entertainment/speakers/speakers

/obj/item/wallframe/telescreen/entertainment
	name = "entertainment telescreen frame"
	icon = 'icons/obj/machines/telescreens.dmi'
	icon_state = "telescreen"
	result_path = /obj/machinery/computer/security/telescreen/entertainment

TELESCREEN_DIRECTIONAL_HELPERS(/obj/machinery/computer/security/telescreen/entertainment) // Wallening todo: Depending on the comment on icon_state, adjust offset. Keep wall_mount element in mind.

/obj/machinery/computer/security/telescreen/entertainment/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_CLICK, PROC_REF(BigClick))
	update_appearance()
	speakers = new(src)

/obj/machinery/computer/security/telescreen/entertainment/Destroy()
	. = ..()
	QDEL_NULL(speakers)

/obj/machinery/computer/security/telescreen/on_set_machine_stat(old_value)
	. = ..()
	update_appearance()

/// Bypass clickchain to allow humans to use the telescreen from a distance
/obj/machinery/computer/security/telescreen/entertainment/proc/BigClick()
	SIGNAL_HANDLER

	if(!network.len)
		balloon_alert(usr, "nothing on TV!")
		return

	INVOKE_ASYNC(src, TYPE_PROC_REF(/atom, interact), usr)

/// Sets the monitor's icon to the selected state, and says an announcement
/obj/machinery/computer/security/telescreen/entertainment/proc/notify(on, announcement)
	if(announcement)
		say(announcement)

// Wallening todo: does this show when it should, and hide when it shouldn't?
/obj/machinery/computer/security/telescreen/entertainment/update_overlays()
	. = ..()
	if(machine_stat & (NOPOWER|BROKEN))
		return
	. += "[base_icon_state]_program[rand(1,4)]"
	. += emissive_appearance(icon, "[base_icon_state]_emissive", src, alpha = src.alpha)

/// Adds a camera network ID to the entertainment monitor, and turns off the monitor if network list is empty
/obj/machinery/computer/security/telescreen/entertainment/proc/update_shows(is_show_active, tv_show_id, announcement)
	if(!network)
		return

	if(is_show_active)
		network |= tv_show_id
	else
		network -= tv_show_id

	notify(network.len, announcement)

/**
 * Adds a camera network to all entertainment monitors.
 *
 * * camera_net - The camera network ID to add to the monitors.
 * * announcement - Optional, what announcement to make when the show starts.
 */
/proc/start_broadcasting_network(camera_net, announcement)
	for(var/obj/machinery/computer/security/telescreen/entertainment/tv as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/computer/security/telescreen/entertainment))
		tv.update_shows(
			is_show_active = TRUE,
			tv_show_id = camera_net,
			announcement = announcement,
		)

/**
 * Removes a camera network from all entertainment monitors.
 *
 * * camera_net - The camera network ID to remove from the monitors.
 * * announcement - Optional, what announcement to make when the show ends.
 */
/proc/stop_broadcasting_network(camera_net, announcement)
	for(var/obj/machinery/computer/security/telescreen/entertainment/tv as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/computer/security/telescreen/entertainment))
		tv.update_shows(
			is_show_active = FALSE,
			tv_show_id = camera_net,
			announcement = announcement,
		)

/**
 * Sets the camera network status on all entertainment monitors.
 * A way to force a network to a status if you are unsure of the current state.
 *
 * * camera_net - The camera network ID to set on the monitors.
 * * is_show_active - Whether the show is active or not.
 * * announcement - Optional, what announcement to make.
 * Note this announcement will be made regardless of the current state of the show:
 * This means if it's currently on and you set it to on, the announcement will still be made.
 * Likewise, there's no way to differentiate off -> on and on -> off, unless you handle that yourself.
 */
/proc/set_network_broadcast_status(camera_net, is_show_active, announcement)
	for(var/obj/machinery/computer/security/telescreen/entertainment/tv as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/computer/security/telescreen/entertainment))
		tv.update_shows(
			is_show_active = is_show_active,
			tv_show_id = camera_net,
			announcement = announcement,
		)

/obj/machinery/computer/security/telescreen/rd
	name = "\improper Research Director's telescreen"
	desc = "Used for watching the AI and the RD's goons from the safety of his office."
	network = list(
		CAMERANET_NETWORK_RD,
		CAMERANET_NETWORK_AI_CORE,
		CAMERANET_NETWORK_AI_UPLOAD,
		CAMERANET_NETWORK_MINISAT,
		CAMERANET_NETWORK_XENOBIOLOGY,
		CAMERANET_NETWORK_TEST_CHAMBER,
		CAMERANET_NETWORK_ORDNANCE,
	)
	frame_type = /obj/item/wallframe/telescreen/rd

/obj/item/wallframe/telescreen/rd
	name = "\improper Research Director's telescreen frame"
	result_path = /obj/machinery/computer/security/telescreen/rd

TELESCREEN_DIRECTIONAL_HELPERS(/obj/machinery/computer/security/telescreen/rd)

/obj/machinery/computer/security/telescreen/research
	name = "research telescreen"
	desc = "A telescreen with access to the research division's camera network."
	network = list(CAMERANET_NETWORK_RD)
	frame_type = /obj/item/wallframe/telescreen/research

/obj/item/wallframe/telescreen/research
	name = "research telescreen frame"
	result_path = /obj/machinery/computer/security/telescreen/research

TELESCREEN_DIRECTIONAL_HELPERS(/obj/machinery/computer/security/telescreen/research)

/obj/machinery/computer/security/telescreen/ce
	name = "\improper Chief Engineer's telescreen"
	desc = "Used for watching the engine, telecommunications and the minisat."
	network = list(CAMERANET_NETWORK_ENGINE, CAMERANET_NETWORK_TELECOMMS, CAMERANET_NETWORK_MINISAT)
	frame_type = /obj/item/wallframe/telescreen/ce

/obj/item/wallframe/telescreen/ce
	name = "\improper Chief Engineer's telescreen frame"
	result_path = /obj/machinery/computer/security/telescreen/ce

TELESCREEN_DIRECTIONAL_HELPERS(/obj/machinery/computer/security/telescreen/ce)

/obj/machinery/computer/security/telescreen/cmo
	name = "\improper Chief Medical Officer's telescreen"
	desc = "A telescreen with access to the medbay's camera network."
	network = list(CAMERANET_NETWORK_MEDBAY)
	frame_type = /obj/item/wallframe/telescreen/cmo

/obj/item/wallframe/telescreen/cmo
	name = "\improper Chief Medical Officer's telescreen frame"
	result_path = /obj/machinery/computer/security/telescreen/cmo

TELESCREEN_DIRECTIONAL_HELPERS(/obj/machinery/computer/security/telescreen/cmo)

/obj/machinery/computer/security/telescreen/med_sec
	name = "\improper medical telescreen"
	desc = "A telescreen with access to the medbay's camera network."
	network = list(CAMERANET_NETWORK_MEDBAY)
	frame_type = /obj/item/wallframe/telescreen/med_sec

/obj/item/wallframe/telescreen/med_sec
	name = "\improper medical telescreen frame"
	result_path = /obj/machinery/computer/security/telescreen/med_sec

TELESCREEN_DIRECTIONAL_HELPERS(/obj/machinery/computer/security/telescreen/med_sec)

/obj/machinery/computer/security/telescreen/vault
	name = "vault monitor"
	desc = "A telescreen that connects to the vault's camera network."
	network = list(CAMERANET_NETWORK_VAULT)
	frame_type = /obj/item/wallframe/telescreen/vault

/obj/item/wallframe/telescreen/vault
	name = "vault telescreen frame"
	result_path = /obj/machinery/computer/security/telescreen/vault

TELESCREEN_DIRECTIONAL_HELPERS(/obj/machinery/computer/security/telescreen/vault)

/obj/machinery/computer/security/telescreen/ordnance
	name = "bomb test site monitor"
	desc = "A telescreen that connects to the bomb test site's camera."
	network = list(CAMERANET_NETWORK_ORDNANCE)
	frame_type = /obj/item/wallframe/telescreen/ordnance

/obj/item/wallframe/telescreen/ordnance
	name = "bomb test site telescreen frame"
	result_path = /obj/machinery/computer/security/telescreen/ordnance

TELESCREEN_DIRECTIONAL_HELPERS(/obj/machinery/computer/security/telescreen/ordnance)

/obj/machinery/computer/security/telescreen/engine
	name = "engine monitor"
	desc = "A telescreen that connects to the engine's camera network."
	network = list(CAMERANET_NETWORK_ENGINE)
	frame_type = /obj/item/wallframe/telescreen/engine

/obj/item/wallframe/telescreen/engine
	name = "engine telescreen frame"
	result_path = /obj/machinery/computer/security/telescreen/engine

TELESCREEN_DIRECTIONAL_HELPERS(/obj/machinery/computer/security/telescreen/engine)

/obj/machinery/computer/security/telescreen/turbine
	name = "turbine monitor"
	desc = "A telescreen that connects to the turbine's camera."
	network = list(CAMERANET_NETWORK_TURBINE)
	frame_type = /obj/item/wallframe/telescreen/turbine

/obj/item/wallframe/telescreen/turbine
	name = "turbine telescreen frame"
	result_path = /obj/machinery/computer/security/telescreen/turbine

TELESCREEN_DIRECTIONAL_HELPERS(/obj/machinery/computer/security/telescreen/turbine)

/obj/machinery/computer/security/telescreen/interrogation
	name = "interrogation room monitor"
	desc = "A telescreen that connects to the interrogation room's camera."
	network = list(CAMERANET_NETWORK_INTERROGATION)
	frame_type = /obj/item/wallframe/telescreen/interrogation

/obj/item/wallframe/telescreen/interrogation
	name = "interrogation telescreen frame"
	result_path = /obj/machinery/computer/security/telescreen/interrogation

TELESCREEN_DIRECTIONAL_HELPERS(/obj/machinery/computer/security/telescreen/interrogation)

/obj/machinery/computer/security/telescreen/prison
	name = "prison monitor"
	desc = "A telescreen that connects to the permabrig's camera network."
	network = list(CAMERANET_NETWORK_PRISON)
	frame_type = /obj/item/wallframe/telescreen/prison

/obj/item/wallframe/telescreen/prison
	name = "prison telescreen frame"
	result_path = /obj/machinery/computer/security/telescreen/prison

TELESCREEN_DIRECTIONAL_HELPERS(/obj/machinery/computer/security/telescreen/prison)

/obj/machinery/computer/security/telescreen/auxbase
	name = "auxiliary base monitor"
	desc = "A telescreen that connects to the auxiliary base's camera."
	network = list(CAMERANET_NETWORK_AUXBASE)
	frame_type = /obj/item/wallframe/telescreen/auxbase

/obj/item/wallframe/telescreen/auxbase
	name = "auxiliary base telescreen frame"
	result_path = /obj/machinery/computer/security/telescreen/auxbase

TELESCREEN_DIRECTIONAL_HELPERS(/obj/machinery/computer/security/telescreen/auxbase)

/obj/machinery/computer/security/telescreen/minisat
	name = "minisat monitor"
	desc = "A telescreen that connects to the minisat's camera network."
	network = list(CAMERANET_NETWORK_MINISAT)
	frame_type = /obj/item/wallframe/telescreen/minisat

/obj/item/wallframe/telescreen/minisat
	name = "minisat telescreen frame"
	result_path = /obj/machinery/computer/security/telescreen/minisat

TELESCREEN_DIRECTIONAL_HELPERS(/obj/machinery/computer/security/telescreen/minisat)

/obj/machinery/computer/security/telescreen/aiupload
	name = "\improper AI upload monitor"
	desc = "A telescreen that connects to the AI upload's camera network."
	network = list(CAMERANET_NETWORK_AI_UPLOAD)
	frame_type = /obj/item/wallframe/telescreen/aiupload

/obj/item/wallframe/telescreen/aiupload
	name = "\improper AI upload telescreen frame"
	result_path = /obj/machinery/computer/security/telescreen/aiupload

TELESCREEN_DIRECTIONAL_HELPERS(/obj/machinery/computer/security/telescreen/aiupload)

/obj/machinery/computer/security/telescreen/bar
	name = "bar monitor"
	desc = "A telescreen that connects to the bar's camera network. Perfect for checking on customers."
	network = list(CAMERANET_NETWORK_BAR)
	frame_type = /obj/item/wallframe/telescreen/bar

/obj/item/wallframe/telescreen/bar
	name = "bar telescreen frame"
	result_path = /obj/machinery/computer/security/telescreen/bar

TELESCREEN_DIRECTIONAL_HELPERS(/obj/machinery/computer/security/telescreen/bar)

/obj/machinery/computer/security/telescreen/isolation
	name = "isolation cell monitor"
	desc = "A telescreen that connects to the isolation cells camera network."
	network = list(CAMERANET_NETWORK_ISOLATION)
	frame_type = /obj/item/wallframe/telescreen/bar

/obj/item/wallframe/telescreen/isolation
	name = "isolation telescreen frame"
	result_path = /obj/machinery/computer/security/telescreen/isolation

TELESCREEN_DIRECTIONAL_HELPERS(/obj/machinery/computer/security/telescreen/isolation)

/obj/machinery/computer/security/telescreen/normal
	name = "security camera monitor"
	desc = "A telescreen that connects to the stations camera network."
	network = list(CAMERANET_NETWORK_SS13)
	frame_type = /obj/item/wallframe/telescreen/normal

/obj/item/wallframe/telescreen/normal
	name = "security camera telescreen frame"
	result_path = /obj/machinery/computer/security/telescreen/normal

TELESCREEN_DIRECTIONAL_HELPERS(/obj/machinery/computer/security/telescreen/normal)

/obj/machinery/computer/security/telescreen/tcomms
	name = "tcomms camera monitor"
	desc = "A telescreen that connects to the tcomms camera network."
	network = list(CAMERANET_NETWORK_TELECOMMS)
	frame_type = /obj/item/wallframe/telescreen/tcomms

/obj/item/wallframe/telescreen/tcomms
	name = "tcomms camera telescreen frame"
	result_path = /obj/machinery/computer/security/telescreen/tcomms

TELESCREEN_DIRECTIONAL_HELPERS(/obj/machinery/computer/security/telescreen/tcomms)

/obj/machinery/computer/security/telescreen/test_chamber
	name = "xenobiology test chamber camera monitor"
	desc = "A telescreen that connects to the xenobiology test chamber camera network."
	network = list(CAMERANET_NETWORK_XENOBIOLOGY)
	frame_type = /obj/item/wallframe/telescreen/test_chamber

/obj/item/wallframe/telescreen/test_chamber
	name = "xenobiology test chamber camera telescreen frame"
	result_path = /obj/machinery/computer/security/telescreen/test_chamber

TELESCREEN_DIRECTIONAL_HELPERS(/obj/machinery/computer/security/telescreen/test_chamber)

/obj/machinery/computer/security/telescreen/engine_waste
	name = "\improper Engine Waste Monitor"
	desc = "A telescreen that connects to the engine waste camera network."
	network = list(CAMERANET_NETWORK_WASTE)
	frame_type = /obj/item/wallframe/telescreen/engine_waste

/obj/item/wallframe/telescreen/engine_waste
	name = "\improper Engine Waste telescreen frame"
	result_path = /obj/machinery/computer/security/telescreen/engine_waste

TELESCREEN_DIRECTIONAL_HELPERS(/obj/machinery/computer/security/telescreen/engine_waste)

/obj/machinery/computer/security/telescreen/cargo_sec
	name = "cargo camera monitor"
	desc = "A telescreen that connects to the cargo and main station camera network."
	network = list(CAMERANET_NETWORK_SS13,
					CAMERA_NETWORK_CARGO,
					)
	frame_type = /obj/item/wallframe/telescreen/cargo_sec

/obj/item/wallframe/telescreen/cargo_sec
	name = "cargo telescreen frame"
	result_path = /obj/machinery/computer/security/telescreen/cargo_sec

TELESCREEN_DIRECTIONAL_HELPERS(/obj/machinery/computer/security/telescreen/cargo_sec)

// This is used in moonoutpost19.dmm
/obj/machinery/computer/security/telescreen/moon_outpost

/obj/machinery/computer/security/telescreen/moon_outpost/research
	name = "research monitor"
	desc = "Used for monitoring the research division and the labs within."
	network = list(CAMERANET_NETWORK_MOON19_RESEARCH,
					CAMERANET_NETWORK_MOON19_XENO,
					)

TELESCREEN_DIRECTIONAL_HELPERS(/obj/machinery/computer/security/telescreen/moon_outpost/research)

/obj/machinery/computer/security/telescreen/moon_outpost/xenobio
	name = "xenobiology monitor"
	desc = "Used for watching the contents of the xenobiology containment pen."
	network = list(CAMERANET_NETWORK_MOON19_XENO)

TELESCREEN_DIRECTIONAL_HELPERS(/obj/machinery/computer/security/telescreen/moon_outpost/xenobio)

// This is used in undergroundoutpost45.dmm
/obj/machinery/computer/security/telescreen/underground_outpost

/obj/machinery/computer/security/telescreen/underground_outpost/research
	name = "research monitor"
	desc = "Used for monitoring the research division and the labs within."
	network = list(CAMERANET_NETWORK_UGO45_RESEARCH)

TELESCREEN_DIRECTIONAL_HELPERS(/obj/machinery/computer/security/telescreen/underground_outpost/research)

// This is used in forgottenship.dmm
/obj/machinery/computer/security/telescreen/forgotten_ship

/obj/machinery/computer/security/telescreen/forgotten_ship/sci
	name = "Cameras monitor"
	network = list(CAMERANET_NETWORK_FSCI)
	req_access = list("syndicate")

TELESCREEN_DIRECTIONAL_HELPERS(/obj/machinery/computer/security/telescreen/forgotten_ship/sci)

// This is used in deepstorage.dmm
/obj/machinery/computer/security/telescreen/deep_storage

/obj/machinery/computer/security/telescreen/deep_storage/bunker
	name = "Bunker Entrance monitor"
	network = list(CAMERA_NETWORK_BUNKER)

TELESCREEN_DIRECTIONAL_HELPERS(/obj/machinery/computer/security/telescreen/deep_storage/bunker)

/// A button that adds a camera network to the entertainment monitors
/obj/machinery/button/showtime
	name = "thunderdome showtime button"
	desc = "Use this button to allow entertainment monitors to broadcast the big game."
	base_icon_state = "button_table"
	icon_state = "button_table"
	device_type = /obj/item/assembly/control/showtime
	req_access = list()
	id = "showtime_1"

/obj/machinery/button/showtime/Initialize(mapload)
	. = ..()
	if(device)
		var/obj/item/assembly/control/showtime/ours = device
		ours.id = id

/obj/item/assembly/control/showtime
	name = "showtime controller"
	desc = "A remote controller for entertainment monitors."
	/// Stores if the show associated with this controller is active or not
	var/is_show_active = FALSE
	/// The camera network id this controller toggles
	var/tv_network_id = "thunder"
	/// The display TV show name
	var/tv_show_name = "Thunderdome"
	/// List of phrases the entertainment console may say when the show begins
	var/list/tv_starters = list(
		"Feats of bravery live now at the thunderdome!",
		"Two enter, one leaves! Tune in now!",
		"Violence like you've never seen it before!",
		"Spears! Camera! Action! LIVE NOW!",
	)
	/// List of phrases the entertainment console may say when the show ends
	var/list/tv_enders = list(
		"Thank you for tuning in to the slaughter!",
		"What a show! And we guarantee next one will be bigger!",
		"Celebrate the results with Thundermerch!",
		"This show was brought to you by Nanotrasen.",
	)

/obj/item/assembly/control/showtime/activate()
	is_show_active = !is_show_active
	say("The [tv_show_name] show has [is_show_active ? "begun" : "ended"]")
	var/announcement = is_show_active ? pick(tv_starters) : pick(tv_enders)
	set_network_broadcast_status(tv_network_id, is_show_active, announcement)
