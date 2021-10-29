/obj/item/modular_computer/laptop/preset/syndicate
	desc = "A SYNDIX operating system laptop, modified through open source to be compatible with NTOS programs. The miracle of software!"
	device_theme = "syndicate"


/obj/item/modular_computer/laptop/preset/syndicate/install_programs()
	var/obj/item/computer_hardware/hard_drive/hard_drive = all_components[MC_HDD]
	hard_drive.store_file(new/datum/computer_file/program/ntnetdownload())
