/obj/item/computer_hardware/hard_drive/role/virus
	name = "generic virus disk"
	var/charges = 5

/obj/item/computer_hardware/hard_drive/role/virus/proc/send_virus(obj/item/modular_computer/tablet/target, mob/living/user)
	return

/obj/item/computer_hardware/hard_drive/role/virus/clown
	name = "H.O.N.K disk"

/obj/item/computer_hardware/hard_drive/role/virus/mime
	name = "sound of silence disk"

/obj/item/computer_hardware/hard_drive/role/virus/deto
	name = "D.E.T.O.M.A.X disk"

/obj/item/computer_hardware/hard_drive/role/virus/deto/send_virus(obj/item/modular_computer/tablet/target, mob/living/user)
	if(charges <= 0)
		to_chat(user, span_notice("ERROR: Out of charges."))
		return

	var/difficulty = 0
	var/obj/item/computer_hardware/hard_drive/role/disk = target.all_components[MC_HDD_JOB]

	if(disk)
		difficulty += bit_count(disk.disk_flags & (DISK_MED | DISK_SEC | DISK_POWER | DISK_CLOWN | DISK_MANIFEST))
		if(disk.disk_flags & CART_MANIFEST)
			difficulty++ //if cartridge has manifest access it has extra snowflake difficulty
	if(SEND_SIGNAL(target, COMSIG_PDA_CHECK_DETONATE) & COMPONENT_PDA_NO_DETONATE || prob(difficulty * 15))
		user.show_message(span_danger("ERROR: Target could not be bombed."), MSG_VISUAL)
		charges--
		return

	var/original_host = holder
	var/fakename = sanitize_name(tgui_input_text(user, "Enter a name for the rigged message.", "Forge Message", max_length = MAX_NAME_LEN), allow_numbers = TRUE)
	if(!fakename || holder != original_host || !user.canUseTopic(holder, BE_CLOSE))
		return
	var/fakejob = sanitize_name(tgui_input_text(user, "Enter a job for the rigged message.", "Forge Message", max_length = MAX_NAME_LEN), allow_numbers = TRUE)
	if(!fakejob || holder != original_host || !user.canUseTopic(holder, BE_CLOSE))
		return

	var/obj/item/computer_hardware/hard_drive/drive = holder.all_components[MC_HDD]

	for(var/datum/computer_file/program/messenger/app in drive.stored_files)
		if(charges > 0 && app.send_message(user, list(target), rigged = REF(user), fake_name = fakename, fake_job = fakejob))
			charges--
			user.show_message(span_notice("Success!"), MSG_VISUAL)
			var/reference = REF(src)
			ADD_TRAIT(target, TRAIT_PDA_CAN_EXPLODE, reference)
			ADD_TRAIT(target, TRAIT_PDA_MESSAGE_MENU_RIGGED, reference)
			addtimer(TRAIT_CALLBACK_REMOVE(target, TRAIT_PDA_MESSAGE_MENU_RIGGED, reference), 10 SECONDS)
