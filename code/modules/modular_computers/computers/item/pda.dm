/obj/item/modular_computer/pda
	name = "pda"
	icon = 'icons/obj/devices/modular_pda.dmi'
	icon_state = "pda"
	worn_icon_state = "nothing"
	base_icon_state = "tablet"
	greyscale_config = /datum/greyscale_config/tablet
	greyscale_colors = "#999875#a92323"

	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	inhand_icon_state = "electronic"

	steel_sheet_cost = 2
	custom_materials = list(/datum/material/iron=SMALL_MATERIAL_AMOUNT * 3, /datum/material/glass=SMALL_MATERIAL_AMOUNT, /datum/material/plastic=SMALL_MATERIAL_AMOUNT)
	interaction_flags_atom = parent_type::interaction_flags_atom | INTERACT_ATOM_ALLOW_USER_LOCATION | INTERACT_ATOM_IGNORE_MOBILITY

	icon_state_menu = "menu"
	max_capacity = 64
	allow_chunky = TRUE
	hardware_flag = PROGRAM_PDA
	max_idle_programs = 2
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_ID | ITEM_SLOT_BELT
	has_light = TRUE //LED flashlight!
	comp_light_luminosity = 2.3 //this is what old PDAs were set to
	looping_sound = FALSE

	shell_capacity = SHELL_CAPACITY_SMALL

	///The item currently inserted into the PDA, starts with a pen.
	var/obj/item/inserted_item = /obj/item/pen

	///Whether the PDA should have 'pda_programs' apps installed on Initialize.
	var/has_pda_programs = TRUE
	///Static list of default PDA apps to install on Initialize.
	var/static/list/datum/computer_file/pda_programs = list(
		/datum/computer_file/program/messenger,
		/datum/computer_file/program/nt_pay,
		/datum/computer_file/program/notepad,
	)
	///List of items that can be stored in a PDA
	var/static/list/contained_item = list(
		/obj/item/pen,
		/obj/item/toy/crayon,
		/obj/item/lipstick,
		/obj/item/flashlight/pen,
		/obj/item/reagent_containers/hypospray/medipen,
		/obj/item/clothing/mask/cigarette,
	)

/obj/item/modular_computer/pda/Initialize(mapload)
	. = ..()
	if(inserted_item)
		inserted_item = new inserted_item(src)

/obj/item/modular_computer/pda/Destroy()
	if(istype(inserted_item))
		QDEL_NULL(inserted_item)
	return ..()

/obj/item/modular_computer/pda/install_default_programs()
	var/list/apps_to_download = list()
	if(has_pda_programs)
		apps_to_download += default_programs + pda_programs
	apps_to_download += starting_programs

	for(var/programs as anything in apps_to_download)
		var/datum/computer_file/program/program_type = new programs
		store_file(program_type)

/obj/item/modular_computer/pda/update_overlays()
	. = ..()
	if(computer_id_slot)
		. += mutable_appearance(initial(icon), "id_overlay")
	if(light_on)
		. += mutable_appearance(initial(icon), "light_overlay")
	if(inserted_pai)
		. += mutable_appearance(initial(icon), "pai_inserted")

/obj/item/modular_computer/pda/attack_ai(mob/user)
	to_chat(user, span_notice("It doesn't feel right to snoop around like that..."))
	return // we don't want ais or cyborgs using a private role tablet

/obj/item/modular_computer/pda/interact(mob/user)
	. = ..()
	if(HAS_TRAIT(src, TRAIT_PDA_MESSAGE_MENU_RIGGED))
		explode(user, from_message_menu = TRUE)

/obj/item/modular_computer/pda/attack_self(mob/user)
	// bypass literacy checks to access syndicate uplink
	var/datum/component/uplink/hidden_uplink = GetComponent(/datum/component/uplink)
	if(hidden_uplink?.owner && HAS_TRAIT(user, TRAIT_ILLITERATE))
		if(hidden_uplink.owner != user.key)
			return ..()

		hidden_uplink.locked = FALSE
		hidden_uplink.interact(null, user)
		return COMPONENT_CANCEL_ATTACK_CHAIN

	return ..()

/obj/item/modular_computer/pda/pre_attack(atom/target, mob/living/user, params)
	if(!inserted_disk || !ismachinery(target))
		return ..()

	var/obj/machinery/target_machine = target
	if(!target_machine.panel_open && !istype(target, /obj/machinery/computer))
		return ..()

	if(!istype(inserted_disk, /obj/item/computer_disk/virus/clown))
		return ..()
	var/obj/item/computer_disk/virus/clown/installed_cartridge = inserted_disk
	if(!installed_cartridge.charges)
		to_chat(user, span_notice("Out of virus charges."))
		return ..()

	to_chat(user, span_notice("You upload the virus to [target]!"))
	var/sig_list = list(COMSIG_ATOM_ATTACK_HAND)
	if(istype(target,/obj/machinery/door/airlock))
		sig_list = list(COMSIG_AIRLOCK_OPEN, COMSIG_AIRLOCK_CLOSE)

	installed_cartridge.charges--
	target.AddComponent(
		/datum/component/sound_player, \
		uses = rand(15,20), \
		signal_list = sig_list, \
	)
	return TRUE

/obj/item/modular_computer/pda/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()

	if(inserted_item)
		context[SCREENTIP_CONTEXT_CTRL_LMB] = "Remove [inserted_item]"
		. = CONTEXTUAL_SCREENTIP_SET
	else if(istype(held_item) && is_type_in_list(held_item, contained_item))
		context[SCREENTIP_CONTEXT_LMB] = "Insert [held_item]"
		. = CONTEXTUAL_SCREENTIP_SET

	return . || NONE

/obj/item/modular_computer/pda/attackby(obj/item/attacking_item, mob/user, params)
	. = ..()

	if(!is_type_in_list(attacking_item, contained_item))
		return
	if(attacking_item.w_class >= WEIGHT_CLASS_SMALL) // Anything equal to or larger than small won't work
		user.balloon_alert(user, "too big!")
		return
	if(inserted_item)
		balloon_alert(user, "no room!")
		return
	if(!user.transferItemToLoc(attacking_item, src))
		return
	balloon_alert(user, "inserted [attacking_item]")
	inserted_item = attacking_item
	playsound(src, 'sound/machines/pda_button1.ogg', 50, TRUE)


/obj/item/modular_computer/pda/CtrlClick(mob/user)
	. = ..()
	if(.)
		return

	remove_pen(user)

///Finds how hard it is to send a virus to this tablet, checking all programs downloaded.
/obj/item/modular_computer/pda/proc/get_detomatix_difficulty()
	var/detomatix_difficulty

	for(var/datum/computer_file/program/downloaded_apps in stored_files)
		detomatix_difficulty += downloaded_apps.detomatix_resistance

	return detomatix_difficulty

/obj/item/modular_computer/pda/proc/remove_pen(mob/user)

	if(issilicon(user) || !user.can_perform_action(src, FORBID_TELEKINESIS_REACH)) //TK doesn't work even with this removed but here for readability
		return

	if(inserted_item)
		balloon_alert(user, "removed [inserted_item]")
		user.put_in_hands(inserted_item)
		inserted_item = null
		update_appearance()
		playsound(src, 'sound/machines/pda_button2.ogg', 50, TRUE)

/obj/item/modular_computer/pda/proc/explode(mob/target, mob/bomber, from_message_menu = FALSE)
	var/turf/current_turf = get_turf(src)

	if(from_message_menu)
		log_bomber(null, null, target, "'s tablet exploded as [target.p_they()] tried to open their tablet message menu because of a recent tablet bomb.")
	else
		log_bomber(bomber, "successfully tablet-bombed", target, "as [target.p_they()] tried to reply to a rigged tablet message [bomber && !is_special_character(bomber) ? "(SENT BY NON-ANTAG)" : ""]")

	if (ismob(loc))
		var/mob/loc_mob = loc
		loc_mob.show_message(
			msg = span_userdanger("Your [src] explodes!"),
			type = MSG_VISUAL,
			alt_msg = span_warning("You hear a loud *pop*!"),
			alt_type = MSG_AUDIBLE,
		)
	else
		visible_message(span_danger("[src] explodes!"), span_warning("You hear a loud *pop*!"))

	target.client?.give_award(/datum/award/achievement/misc/clickbait, target)

	if(current_turf)
		current_turf.hotspot_expose(700,125)
		if(istype(inserted_disk, /obj/item/computer_disk/virus/detomatix))
			explosion(src, devastation_range = -1, heavy_impact_range = 1, light_impact_range = 3, flash_range = 4)
		else
			explosion(src, devastation_range = -1, heavy_impact_range = -1, light_impact_range = 2, flash_range = 3)
	qdel(src)


/**
 * A simple helper proc that applies the client's ringtone prefs to the tablet's messenger app,
 * if it has one.
 *
 * Arguments:
 * * owner_client - The client whose prefs we'll use to set the ringtone of this PDA.
 */
/obj/item/modular_computer/pda/proc/update_pda_prefs(client/owner_client)
	if(!owner_client)
		return

	var/new_ringtone = owner_client.prefs.read_preference(/datum/preference/text/pda_ringtone)
	if(new_ringtone && (new_ringtone != MESSENGER_RINGTONE_DEFAULT))
		update_ringtone(new_ringtone)

	var/new_theme = owner_client.prefs.read_preference(/datum/preference/choiced/pda_theme)
	if(new_theme)
		device_theme = GLOB.pda_name_to_theme[new_theme]

/// A simple proc to set the ringtone from a pda.
/obj/item/modular_computer/pda/proc/update_ringtone(new_ringtone)
	if(!istext(new_ringtone))
		return
	var/datum/computer_file/program/messenger/messenger_app = locate() in stored_files
	if(messenger_app)
		messenger_app.ringtone = new_ringtone

/**
 * Nuclear PDA
 *
 * PDA that doesn't come with the default apps but has Fission360
 * Resistant to emags, these are given to nukies for disk pinpointer stuff.
 */
/obj/item/modular_computer/pda/nukeops
	name = "nuclear pda"
	device_theme = PDA_THEME_SYNDICATE
	comp_light_luminosity = 6.3 //matching a flashlight
	light_color = COLOR_RED
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick
	greyscale_colors = "#a80001#5C070F#000000"
	long_ranged = TRUE
	starting_programs = list(
		/datum/computer_file/program/radar/fission360,
	)

/obj/item/modular_computer/pda/nukeops/Initialize(mapload)
	. = ..()
	emag_act(forced = TRUE)
	var/datum/computer_file/program/messenger/msg = locate() in stored_files
	if(msg)
		msg.invisible = TRUE

/obj/item/modular_computer/pda/syndicate_contract_uplink
	name = "contractor tablet"
	device_theme = PDA_THEME_SYNDICATE
	icon_state_menu = "contractor-assign"
	comp_light_luminosity = 6.3
	has_pda_programs = FALSE
	greyscale_config = /datum/greyscale_config/tablet/stripe_double
	greyscale_colors = "#696969#000000#FFA500"

	starting_programs = list(
		/datum/computer_file/program/contract_uplink,
		/datum/computer_file/program/secureye/syndicate,
	)

/**
 * Silicon PDA
 *
 * PDAs that are built-in to Silicons and should not exist at any point without being inside of one.
 */
/obj/item/modular_computer/pda/silicon
	name = "modular interface"
	icon_state = "tablet-silicon"
	base_icon_state = "tablet-silicon"
	greyscale_config = null
	greyscale_colors = null

	has_light = FALSE //tablet light button actually enables/disables the borg lamp
	comp_light_luminosity = 0
	inserted_item = null
	has_pda_programs = FALSE
	starting_programs = list(
		/datum/computer_file/program/messenger,
	)

	///Ref to the RoboTact app. Important enough to borgs to deserve a ref.
	var/datum/computer_file/program/robotact/robotact
	///IC log that borgs can view in their personal management app
	var/list/borglog = list()
	///Ref to the silicon we're installed in. Set by the silicon itself during its creation.
	var/mob/living/silicon/silicon_owner

/obj/item/modular_computer/pda/silicon/cyborg
	starting_programs = list(
		/datum/computer_file/program/filemanager,
		/datum/computer_file/program/robotact,
	)

/obj/item/modular_computer/pda/silicon/Initialize(mapload)
	. = ..()
	vis_flags |= VIS_INHERIT_ID
	silicon_owner = loc
	if(!istype(silicon_owner))
		silicon_owner = null
		stack_trace("[type] initialized outside of a silicon, deleting.")
		return INITIALIZE_HINT_QDEL

/obj/item/modular_computer/pda/silicon/Destroy()
	silicon_owner = null
	return ..()

///Silicons don't have the tools (or hands) to make circuits setups with their own PDAs.
/obj/item/modular_computer/pda/silicon/add_shell_component(capacity)
	return

/obj/item/modular_computer/pda/silicon/turn_on(mob/user, open_ui = FALSE)
	if(silicon_owner?.stat != DEAD)
		return ..()
	return FALSE

/obj/item/modular_computer/pda/silicon/get_ntnet_status()
	//No borg found
	if(!silicon_owner)
		return FALSE
	// no AIs/pAIs
	var/mob/living/silicon/robot/cyborg_check = silicon_owner
	if(!istype(cyborg_check))
		return ..()
	//lockdown restricts borg networking
	if(cyborg_check.lockcharge)
		return FALSE
	//borg cell dying restricts borg networking
	if(!cyborg_check.cell || cyborg_check.cell.charge == 0)
		return FALSE

	return ..()

/**
 * Returns a ref to the RoboTact app, creating the app if need be.
 *
 * The RoboTact app is important for borgs, and so should always be available.
 * This proc will look for it in the tablet's robotact var, then check the
 * hard drive if the robotact var is unset, and finally attempt to create a new
 * copy if the hard drive does not contain the app. If the hard drive rejects
 * the new copy (such as due to lack of space), the proc will crash with an error.
 * RoboTact is supposed to be undeletable, so these will create runtime messages.
 */
/obj/item/modular_computer/pda/silicon/proc/get_robotact()
	if(robotact)
		return robotact
	robotact = find_file_by_name("robotact")
	if(robotact)
		return robotact
	stack_trace("Cyborg [silicon_owner] ( [silicon_owner.type] ) was somehow missing their self-manage app in their tablet. A new copy has been created.")
	robotact = new(src)
	if(store_file(robotact))
		return robotact
	qdel(robotact)
	robotact = null
	CRASH("Cyborg [silicon_owner]'s tablet hard drive rejected receiving a new copy of the self-manage app. To fix, check the hard drive's space remaining. Please make a bug report about this.")

//Makes the light settings reflect the borg's headlamp settings
/obj/item/modular_computer/pda/silicon/cyborg/ui_data(mob/user)
	. = ..()
	.["has_light"] = TRUE
	if(iscyborg(silicon_owner))
		var/mob/living/silicon/robot/robo = silicon_owner
		.["light_on"] = robo.lamp_enabled
		.["comp_light_color"] = robo.lamp_color

//Makes the flashlight button affect the borg rather than the tablet
/obj/item/modular_computer/pda/silicon/toggle_flashlight(mob/user)
	if(!silicon_owner || QDELETED(silicon_owner))
		return FALSE
	if(iscyborg(silicon_owner))
		var/mob/living/silicon/robot/robo = silicon_owner
		robo.toggle_headlamp()
	return TRUE

//Makes the flashlight color setting affect the borg rather than the tablet
/obj/item/modular_computer/pda/silicon/set_flashlight_color(color)
	if(!silicon_owner || QDELETED(silicon_owner) || !color)
		return FALSE
	if(iscyborg(silicon_owner))
		var/mob/living/silicon/robot/robo = silicon_owner
		robo.lamp_color = color
		robo.toggle_headlamp(FALSE, TRUE)
	return TRUE

/obj/item/modular_computer/pda/silicon/ui_state(mob/user)
	return GLOB.reverse_contained_state

/obj/item/modular_computer/pda/silicon/cyborg/syndicate
	icon_state = "tablet-silicon-syndicate"
	device_theme = PDA_THEME_SYNDICATE

/obj/item/modular_computer/pda/silicon/cyborg/syndicate/Initialize(mapload)
	. = ..()
	if(iscyborg(silicon_owner))
		var/mob/living/silicon/robot/robo = silicon_owner
		robo.lamp_color = COLOR_RED //Syndicate likes it red
