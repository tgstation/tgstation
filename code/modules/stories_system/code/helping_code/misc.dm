/obj/item/modular_computer/pda/centcom
	name = "\improper Centcom PDA"
	starting_programs = list(
		/datum/computer_file/program/crew_manifest,
		/datum/computer_file/program/status,
		/datum/computer_file/program/science,
		/datum/computer_file/program/robocontrol,
		/datum/computer_file/program/budgetorders,
	)
	inserted_item = /obj/item/pen/fountain/captain
	greyscale_colors = "#017941#0060b8"

/obj/item/storage/box/syndie_kit/rnd_server
	name = "R&D server extraction kit"
	desc = "A box containing the equipment and instructions for extracting the hard drive of a Nanotrasen R&D server."

/obj/item/storage/box/syndie_kit/rnd_server/PopulateContents()
	new /obj/item/screwdriver/nuke(src)
	new /obj/item/crowbar/power/syndicate(src) // Let's be a bit generous
	new /obj/item/paper/guides/antag/hdd_extraction(src)
