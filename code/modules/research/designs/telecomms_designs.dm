///////////////////////////////////
/////Subspace Telecomms////////////
///////////////////////////////////

/datum/design/board/subspace_receiver
	name = "Machine Design (Subspace Receiver)"
	desc = "Allows for the construction of Subspace Receiver equipment."
	id = "s-receiver"
	req_tech = list("programming" = 2, "engineering" = 2, "bluespace" = 1)
	build_path = /obj/item/circuitboard/machine/telecomms/receiver
	category = list("Subspace Telecomms")

/datum/design/board/telecomms_bus
	name = "Machine Design (Bus Mainframe)"
	desc = "Allows for the construction of Telecommunications Bus Mainframes."
	id = "s-bus"
	req_tech = list("programming" = 2, "engineering" = 2)
	build_path = /obj/item/circuitboard/machine/telecomms/bus
	category = list("Subspace Telecomms")

/datum/design/board/telecomms_hub
	name = "Machine Design (Hub Mainframe)"
	desc = "Allows for the construction of Telecommunications Hub Mainframes."
	id = "s-hub"
	req_tech = list("programming" = 2, "engineering" = 2)
	build_path = /obj/item/circuitboard/machine/telecomms/hub
	category = list("Subspace Telecomms")

/datum/design/board/telecomms_relay
	name = "Machine Design (Relay Mainframe)"
	desc = "Allows for the construction of Telecommunications Relay Mainframes."
	id = "s-relay"
	req_tech = list("programming" = 2, "engineering" = 2, "bluespace" = 2)
	build_path = /obj/item/circuitboard/machine/telecomms/relay
	category = list("Subspace Telecomms")

/datum/design/board/telecomms_processor
	name = "Machine Design (Processor Unit)"
	desc = "Allows for the construction of Telecommunications Processor equipment."
	id = "s-processor"
	req_tech = list("programming" = 2, "engineering" = 2)
	build_path = /obj/item/circuitboard/machine/telecomms/processor
	category = list("Subspace Telecomms")

/datum/design/board/telecomms_server
	name = "Machine Design (Server Mainframe)"
	desc = "Allows for the construction of Telecommunications Servers."
	id = "s-server"
	req_tech = list("programming" = 2, "engineering" = 2)
	build_path = /obj/item/circuitboard/machine/telecomms/server
	category = list("Subspace Telecomms")

/datum/design/board/subspace_broadcaster
	name = "Machine Design (Subspace Broadcaster)"
	desc = "Allows for the construction of Subspace Broadcasting equipment."
	id = "s-broadcaster"
	req_tech = list("programming" = 2, "engineering" = 2)
	build_path = /obj/item/circuitboard/machine/telecomms/broadcaster
	category = list("Subspace Telecomms")
