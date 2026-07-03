/obj/item/modular_computer/pda/heads/centcom // Special PDA for centcom cause they don't have their own
	name = "centcom officer PDA"
	greyscale_config = /datum/greyscale_config/tablet/stripe_double
	greyscale_colors = "#141414#FFD700#FFD700"
	internal_cell = /obj/item/stock_parts/power_store/cell/infinite
	inserted_item = /obj/item/pen/fountain/captain
	starting_programs = list(
		/datum/computer_file/program/status,
		/datum/computer_file/program/science,
		/datum/computer_file/program/records/medical,
		/datum/computer_file/program/records/security,
		/datum/computer_file/program/budgetorders,
	)
