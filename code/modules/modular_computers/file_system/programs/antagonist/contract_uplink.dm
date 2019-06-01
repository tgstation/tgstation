/datum/computer_file/program/contract_uplink
	filename = "contract uplink"
	filedesc = "Contract Uplink"
	program_icon_state = "hostile"
	extended_desc = "A standard, Syndicate issued system for handling important contracts while on the field."
	size = 10
	requires_ntnet = 0
	available_on_ntnet = 0
	tgui_id = "synd_contract"
	ui_style = "syndicate"
	ui_x = 600
	ui_y = 600

/datum/computer_file/program/revelation/run_program(var/mob/living/user)
	. = ..(user)
