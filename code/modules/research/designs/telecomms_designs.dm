///////////////////////////////////
/////Subspace Telecomms////////////
///////////////////////////////////

/datum/design/board/subspace_receiver
	name = "Subspace Receiver Board"
	desc = "Used to build a subspace receiver, an element of telecommunications. The \"input\" of a telecomms network, \
		the receiver captures compressed subspace signals directly from the source (such as radio headsets). \
		They typically link to a telecommunication hub, or directly to processors."
	build_path = /obj/item/circuitboard/machine/telecomms/receiver
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_TELECOMMS
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/telecomms_bus
	name = "Bus Mainframe Board"
	desc = "Used to build a telecommunications bus mainframe, an element of telecommunications. \
		Generally acts as a junction between components, transferring ingoing packets to processors or outgoing packets to servers. \
		In the absence of a server, can be linked directly to hubs and broadcasters, at the cost of latency."
	build_path = /obj/item/circuitboard/machine/telecomms/bus
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_TELECOMMS
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/telecomms_hub
	name = "Hub Mainframe Board"
	desc = "Used to build a telecommunications hub mainframe, an element of telecommunications. \
		Acts as a central point for connecting various components, managing the flow of data between receivers, processors, and servers."
	build_path = /obj/item/circuitboard/machine/telecomms/hub
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_TELECOMMS
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/telecomms_relay
	name = "Relay Mainframe Board"
	desc = "Used to build a telecommunications relay mainframe, an element of telecommunications. \
		Relays are used to extend the range across massive distances, such as between the station and lavaland or deep space."
	build_path = /obj/item/circuitboard/machine/telecomms/relay
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_TELECOMMS
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/telecomms_processor
	name = "Processor Unit Board"
	desc = "Used to build a telecommunications processor unit, an element of telecommunications. \
		Decompresses subspace packets and returns it to whichever bus it originated from - an essential step in producing legible communications. \
		Typically connected to the server, but can be linked directly to a bus if necessary."
	build_path = /obj/item/circuitboard/machine/telecomms/processor
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_TELECOMMS
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/telecomms_server
	name = "Server Mainframe Board"
	desc = "Used to build a telecommunications server mainframe, an element of telecommunications. \
		Logs and stores outgoing subspace communications, then forwards it to the subspace broadcaster."
	build_path = /obj/item/circuitboard/machine/telecomms/server
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_TELECOMMS
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/telecomms_messaging
	name = "Messaging Server Board"
	desc = "Used to build a telecommunications messaging server, an element of telecommunications. \
		Logs and stores outgoing PDA and request console messages."
	build_path = /obj/item/circuitboard/machine/telecomms/message_server
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_TELECOMMS
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/subspace_broadcaster
	name = "Subspace Broadcaster Board"
	desc = "Used to build subspace broadcasting equipment, an element of telecommunications. The \"output\" of a telecomms network, \
		the broadcaster transmits outgoing subspace communications to recipients (such as radio headsets). \
		They are typically linked to servers."
	build_path = /obj/item/circuitboard/machine/telecomms/broadcaster
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_TELECOMMS
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_SCIENCE
