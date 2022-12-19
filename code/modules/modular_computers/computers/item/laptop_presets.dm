/obj/item/modular_computer/laptop/preset/civilian
	desc = "A low-end laptop often used for personal recreation."
	starting_programs = list(
		/datum/computer_file/program/chatclient,
	)

/obj/item/modular_computer/laptop/preset/signal_tracker
	desc = "A laptop with a prototype of NT's telecrystal signal tracking program."
	icon_state = "signal-laptop-closed"
	icon_state_closed = "signal-laptop-closed"
	icon_state_powered = "signal-laptop"
	icon_state_unpowered = "signal-laptop-off"
	start_open = FALSE
	starting_programs = list(
		/datum/computer_file/program/radar/telecrystal_signal_tracker,
	)
