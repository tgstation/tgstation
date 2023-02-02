/**
 * Virus disk
 * Can't hold apps, instead does unique actions.
 */
/obj/item/computer_disk/virus
	name = "\improper generic virus disk"
	icon_state = "virusdisk"
	max_capacity = 0
	///How many charges the virus has left
	var/charges = 5

/obj/item/computer_disk/virus/proc/send_virus(obj/item/modular_computer/pda/source, obj/item/modular_computer/pda/target, mob/living/user)
	if(charges <= 0)
		to_chat(user, span_notice("ERROR: Out of charges."))
		return FALSE
	if(!target)
		to_chat(user, span_notice("ERROR: Could not find device."))
		return FALSE
	return TRUE

/**
 * Clown virus
 * Makes people's PDA honk
 * Can also be used on open panel airlocks to make them honk on opening.
 */
/obj/item/computer_disk/virus/clown
	name = "\improper H.O.N.K. disk"

/obj/item/computer_disk/virus/clown/send_virus(obj/item/modular_computer/pda/source, obj/item/modular_computer/pda/target, mob/living/user)
	. = ..()
	if(!.)
		return FALSE

	user.show_message(span_notice("Success!"))
	charges--
	target.honkvirus_amount = rand(15, 25)
	return TRUE

/**
 * Mime virus
 * Makes PDA's silent, removing their ringtone.
 */
/obj/item/computer_disk/virus/mime
	name = "\improper sound of silence disk"

/obj/item/computer_disk/virus/mime/send_virus(obj/item/modular_computer/pda/source, obj/item/modular_computer/pda/target, mob/living/user)
	. = ..()
	if(!.)
		return FALSE

	var/datum/computer_file/program/messenger/app = locate() in target.stored_files
	if(!app)
		return FALSE
	user.show_message(span_notice("Success!"))
	charges--
	app.ringer_status = FALSE
	app.ringtone = ""

/**
 * Detomatix virus
 * Sends a false message, and blows the PDA up if the target responds to it (or opens their messenger before a timer)
 */
/obj/item/computer_disk/virus/detomatix
	name = "\improper D.E.T.O.M.A.T.I.X. disk"
	charges = 6

/obj/item/computer_disk/virus/detomatix/send_virus(obj/item/modular_computer/pda/source, obj/item/modular_computer/pda/target, mob/living/user)
	. = ..()
	if(!.)
		return FALSE

	var/difficulty = target.get_detomatix_difficulty()
	if(SEND_SIGNAL(target, COMSIG_TABLET_CHECK_DETONATE) & COMPONENT_TABLET_NO_DETONATE || prob(difficulty * 15))
		user.show_message(span_danger("ERROR: Target could not be bombed."), MSG_VISUAL)
		charges--
		return

	var/original_host = source
	var/fakename = sanitize_name(tgui_input_text(user, "Enter a name for the rigged message.", "Forge Message", max_length = MAX_NAME_LEN), allow_numbers = TRUE)
	if(!fakename || source != original_host || !user.canUseTopic(source, be_close = TRUE))
		return
	var/fakejob = sanitize_name(tgui_input_text(user, "Enter a job for the rigged message.", "Forge Message", max_length = MAX_NAME_LEN), allow_numbers = TRUE)
	if(!fakejob || source != original_host || !user.canUseTopic(source, be_close = TRUE))
		return

	var/datum/computer_file/program/messenger/app = locate() in source.stored_files
	if(!app || charges <= 0 || !app.send_message(user, list(target), rigged = REF(user), fake_name = fakename, fake_job = fakejob))
		return FALSE
	charges--
	user.show_message(span_notice("Success!"))
	var/reference = REF(src)
	ADD_TRAIT(target, TRAIT_PDA_CAN_EXPLODE, reference)
	ADD_TRAIT(target, TRAIT_PDA_MESSAGE_MENU_RIGGED, reference)
	addtimer(TRAIT_CALLBACK_REMOVE(target, TRAIT_PDA_MESSAGE_MENU_RIGGED, reference), 10 SECONDS)
	return TRUE

/**
 * Frame cartridge
 * Creates and opens a false uplink on someone's PDA
 * Can be loaded with TC to show up on the false uplink.
 */
/obj/item/computer_disk/virus/frame
	name = "\improper F.R.A.M.E. disk"

	///How many telecrystals the uplink should have
	var/telecrystals = 0
	///How much progression should be shown in the uplink, set on purchase of the item.
	var/current_progression = 0

/obj/item/computer_disk/virus/frame/attackby(obj/item/attacking_item, mob/user, params)
	. = ..()
	if(!istype(attacking_item, /obj/item/stack/telecrystal))
		return
	if(!charges)
		to_chat(user, span_notice("[src] is out of charges, it's refusing to accept [attacking_item]."))
		return
	var/obj/item/stack/telecrystal/telecrystal_stack = attacking_item
	telecrystals += telecrystal_stack.amount
	to_chat(user, span_notice("You slot [telecrystal_stack] into [src]. The next time it's used, it will also give telecrystals."))
	telecrystal_stack.use(telecrystal_stack.amount)


/obj/item/computer_disk/virus/frame/send_virus(obj/item/modular_computer/pda/source, obj/item/modular_computer/pda/target, mob/living/user)
	. = ..()
	if(!.)
		return FALSE

	charges--
	var/unlock_code = "[rand(100,999)] [pick(GLOB.phonetic_alphabet)]"
	to_chat(user, span_notice("Success! The unlock code to the target is: [unlock_code]"))
	var/datum/component/uplink/hidden_uplink = target.GetComponent(/datum/component/uplink)
	if(!hidden_uplink)
		var/datum/mind/target_mind
		var/list/backup_players = list()
		for(var/datum/mind/player as anything in get_crewmember_minds())
			if(player.assigned_role?.title == target.saved_job)
				backup_players += player
			if(player.name == target.saved_identification)
				target_mind = player
				break
		if(!target_mind)
			if(!length(backup_players))
				target_mind = user.mind
			else
				target_mind = pick(backup_players)
		hidden_uplink = target.AddComponent(/datum/component/uplink, target_mind, enabled = TRUE, starting_tc = telecrystals, has_progression = TRUE)
		hidden_uplink.unlock_code = unlock_code
		hidden_uplink.uplink_handler.has_objectives = TRUE
		hidden_uplink.uplink_handler.owner = target_mind
		hidden_uplink.uplink_handler.can_take_objectives = FALSE
		hidden_uplink.uplink_handler.progression_points = min(SStraitor.current_global_progression, current_progression)
		hidden_uplink.uplink_handler.generate_objectives()
		SStraitor.register_uplink_handler(hidden_uplink.uplink_handler)
	else
		hidden_uplink.add_telecrystals(telecrystals)
	telecrystals = 0
	hidden_uplink.locked = FALSE
	hidden_uplink.active = TRUE
