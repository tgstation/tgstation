/obj/item/modular_computer/tablet  //Its called tablet for theme of 90ies but actually its a "big smartphone" sized
	name = "tablet computer"
	icon = 'icons/obj/modular_tablet.dmi'
	icon_state = "tablet-red"
	icon_state_unpowered = "tablet-red"
	icon_state_powered = "tablet-red"
	icon_state_menu = "menu"
	base_icon_state = "tablet"
	worn_icon_state = "tablet"
	hardware_flag = PROGRAM_TABLET
	max_hardware_size = 1
	w_class = WEIGHT_CLASS_SMALL
	max_bays = 3
	steel_sheet_cost = 2
	slot_flags = ITEM_SLOT_ID | ITEM_SLOT_BELT
	has_light = TRUE //LED flashlight!
	comp_light_luminosity = 2.3 //Same as the PDA
	looping_sound = FALSE
	custom_materials = list(/datum/material/iron=300, /datum/material/glass=100, /datum/material/plastic=100)

	var/has_variants = TRUE
	var/finish_color = null

	var/list/contained_item = list(/obj/item/pen, /obj/item/toy/crayon, /obj/item/lipstick, /obj/item/flashlight/pen, /obj/item/clothing/mask/cigarette)
	var/obj/item/insert_type = /obj/item/pen
	var/obj/item/inserted_item

	var/note = "Congratulations on your station upgrading to the new NtOS and Thinktronic based collaboration effort, bringing you the best in electronics and software since 2467!"  // the note used by the notekeeping app, stored here for convenience

/obj/item/modular_computer/tablet/update_icon_state()
	if(has_variants && !bypass_state)
		if(!finish_color)
			finish_color = pick("red", "blue", "brown", "green", "black")
		icon_state = icon_state_powered = icon_state_unpowered = "[base_icon_state]-[finish_color]"
	return ..()

/obj/item/modular_computer/tablet/interact(mob/user)
	. = ..()
	if(HAS_TRAIT(src, TRAIT_PDA_MESSAGE_MENU_RIGGED))
		explode(usr, from_message_menu = TRUE)
		return

/obj/item/modular_computer/tablet/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()

	context[SCREENTIP_CONTEXT_CTRL_LMB] = "Remove pen"

	return CONTEXTUAL_SCREENTIP_SET

/obj/item/modular_computer/tablet/attackby(obj/item/W, mob/user)
	. = ..()

	if(is_type_in_list(W, contained_item))
		if(inserted_item)
			to_chat(user, span_warning("There is already \a [inserted_item] in \the [src]!"))
		else
			if(!user.transferItemToLoc(W, src))
				return
			to_chat(user, span_notice("You insert \the [W] into \the [src]."))
			inserted_item = W
			playsound(src, 'sound/machines/pda_button1.ogg', 50, TRUE)

	if(istype(W, /obj/item/paper))
		var/obj/item/paper/paper = W

		to_chat(user, span_notice("You scan \the [W] into \the [src]."))
		note = paper.info

/obj/item/modular_computer/tablet/AltClick(mob/user)
	. = ..()
	if(.)
		return

	remove_pen(user)

/obj/item/modular_computer/tablet/CtrlClick(mob/user)
	. = ..()
	if(.)
		return

	remove_pen(user)

///Finds how hard it is to send a virus to this tablet, checking all programs downloaded.
/obj/item/modular_computer/tablet/proc/get_detomatix_difficulty()
	var/detomatix_difficulty

	var/obj/item/computer_hardware/hard_drive/hdd = all_components[MC_HDD]
	if(hdd)
		for(var/datum/computer_file/program/downloaded_apps as anything in hdd.stored_files)
			detomatix_difficulty += downloaded_apps.detomatix_resistance

	return detomatix_difficulty

/obj/item/modular_computer/tablet/proc/tab_no_detonate()
	SIGNAL_HANDLER
	return COMPONENT_TABLET_NO_DETONATE

/obj/item/modular_computer/tablet/proc/remove_pen(mob/user)

	if(issilicon(user) || !user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK)) //TK doesn't work even with this removed but here for readability
		return

	if(inserted_item)
		to_chat(user, span_notice("You remove [inserted_item] from [src]."))
		user.put_in_hands(inserted_item)
		inserted_item = null
		update_appearance()
		playsound(src, 'sound/machines/pda_button2.ogg', 50, TRUE)
	else
		to_chat(user, span_warning("This tablet does not have a pen in it!"))

// Tablet 'splosion..

/obj/item/modular_computer/tablet/proc/explode(mob/target, mob/bomber, from_message_menu = FALSE)
	var/turf/T = get_turf(src)

	if(from_message_menu)
		log_bomber(null, null, target, "'s tablet exploded as [target.p_they()] tried to open their tablet message menu because of a recent tablet bomb.")
	else
		log_bomber(bomber, "successfully tablet-bombed", target, "as [target.p_they()] tried to reply to a rigged tablet message [bomber && !is_special_character(bomber) ? "(SENT BY NON-ANTAG)" : ""]")

	if (ismob(loc))
		var/mob/M = loc
		M.show_message(span_userdanger("Your [src] explodes!"), MSG_VISUAL, span_warning("You hear a loud *pop*!"), MSG_AUDIBLE)
	else
		visible_message(span_danger("[src] explodes!"), span_warning("You hear a loud *pop*!"))

	target.client?.give_award(/datum/award/achievement/misc/clickbait, target)

	if(T)
		T.hotspot_expose(700,125)
		if(istype(all_components[MC_SDD], /obj/item/computer_hardware/hard_drive/portable/virus/deto))
			explosion(src, devastation_range = -1, heavy_impact_range = 1, light_impact_range = 3, flash_range = 4)
		else
			explosion(src, devastation_range = -1, heavy_impact_range = -1, light_impact_range = 2, flash_range = 3)
	qdel(src)

// SUBTYPES

/obj/item/modular_computer/tablet/syndicate_contract_uplink
	name = "contractor tablet"
	icon = 'icons/obj/contractor_tablet.dmi'
	icon_state = "tablet"
	icon_state_unpowered = "tablet"
	icon_state_powered = "tablet"
	icon_state_menu = "assign"
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_ID | ITEM_SLOT_BELT
	comp_light_luminosity = 6.3
	has_variants = FALSE

/// Given to Nuke Ops members.
/obj/item/modular_computer/tablet/nukeops
	icon_state = "tablet-syndicate"
	icon_state_powered = "tablet-syndicate"
	icon_state_unpowered = "tablet-syndicate"
	comp_light_luminosity = 6.3
	has_variants = FALSE
	device_theme = "syndicate"
	light_color = COLOR_RED

/obj/item/modular_computer/tablet/nukeops/emag_act(mob/user)
	if(!enabled)
		to_chat(user, span_warning("You'd need to turn the [src] on first."))
		return FALSE
	to_chat(user, span_notice("You swipe \the [src]. It's screen briefly shows a message reading \"MEMORY CODE INJECTION DETECTED AND SUCCESSFULLY QUARANTINED\"."))
	return FALSE

/// Borg Built-in tablet interface
/obj/item/modular_computer/tablet/integrated
	name = "modular interface"
	icon_state = "tablet-silicon"
	icon_state_powered = "tablet-silicon"
	icon_state_unpowered = "tablet-silicon"
	base_icon_state = "tablet-silicon"
	has_light = FALSE //tablet light button actually enables/disables the borg lamp
	comp_light_luminosity = 0
	has_variants = FALSE
	///Ref to the silicon we're installed in. Set by the borg during our creation.
	var/mob/living/silicon/borgo
	///Ref to the RoboTact app. Important enough to borgs to deserve a ref.
	var/datum/computer_file/program/robotact/robotact
	///IC log that borgs can view in their personal management app
	var/list/borglog = list()

/obj/item/modular_computer/tablet/integrated/Initialize(mapload)
	. = ..()
	vis_flags |= VIS_INHERIT_ID
	borgo = loc
	if(!istype(borgo))
		borgo = null
		stack_trace("[type] initialized outside of a borg, deleting.")
		return INITIALIZE_HINT_QDEL

/obj/item/modular_computer/tablet/integrated/Destroy()
	borgo = null
	return ..()

/obj/item/modular_computer/tablet/integrated/turn_on(mob/user)
	if(borgo?.stat != DEAD)
		return ..()
	return FALSE

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
/obj/item/modular_computer/tablet/integrated/proc/get_robotact()
	if(!borgo)
		return null
	if(!robotact)
		var/obj/item/computer_hardware/hard_drive/hard_drive = all_components[MC_HDD]
		robotact = hard_drive.find_file_by_name("robotact")
		if(!robotact)
			stack_trace("Cyborg [borgo] ( [borgo.type] ) was somehow missing their self-manage app in their tablet. A new copy has been created.")
			robotact = new(hard_drive)
			if(!hard_drive.store_file(robotact))
				qdel(robotact)
				robotact = null
				CRASH("Cyborg [borgo]'s tablet hard drive rejected recieving a new copy of the self-manage app. To fix, check the hard drive's space remaining. Please make a bug report about this.")
	return robotact

//Makes the light settings reflect the borg's headlamp settings
/obj/item/modular_computer/tablet/integrated/ui_data(mob/user)
	. = ..()
	.["has_light"] = TRUE
	if(istype(borgo, /mob/living/silicon/robot))
		var/mob/living/silicon/robot/robo = borgo
		.["light_on"] = robo.lamp_enabled
		.["comp_light_color"] = robo.lamp_color

//Makes the flashlight button affect the borg rather than the tablet
/obj/item/modular_computer/tablet/integrated/toggle_flashlight()
	if(!borgo || QDELETED(borgo))
		return FALSE
	if(istype(borgo, /mob/living/silicon/robot))
		var/mob/living/silicon/robot/robo = borgo
		robo.toggle_headlamp()
	return TRUE

//Makes the flashlight color setting affect the borg rather than the tablet
/obj/item/modular_computer/tablet/integrated/set_flashlight_color(color)
	if(!borgo || QDELETED(borgo) || !color)
		return FALSE
	if(istype(borgo, /mob/living/silicon/robot))
		var/mob/living/silicon/robot/robo = borgo
		robo.lamp_color = color
		robo.toggle_headlamp(FALSE, TRUE)
	return TRUE

/obj/item/modular_computer/tablet/integrated/alert_call(datum/computer_file/program/caller, alerttext, sound = 'sound/machines/twobeep_high.ogg')
	if(!caller || !caller.alert_able || caller.alert_silenced || !alerttext) //Yeah, we're checking alert_able. No, you don't get to make alerts that the user can't silence.
		return
	borgo.playsound_local(src, sound, 50, TRUE)
	to_chat(borgo, span_notice("The [src] displays a [caller.filedesc] notification: [alerttext]"))

/obj/item/modular_computer/tablet/integrated/ui_state(mob/user)
	return GLOB.reverse_contained_state

/obj/item/modular_computer/tablet/integrated/syndicate
	icon_state = "tablet-silicon-syndicate"
	icon_state_powered = "tablet-silicon-syndicate"
	icon_state_unpowered = "tablet-silicon-syndicate"
	device_theme = "syndicate"


/obj/item/modular_computer/tablet/integrated/syndicate/Initialize(mapload)
	. = ..()
	if(istype(borgo, /mob/living/silicon/robot))
		var/mob/living/silicon/robot/robo = borgo
		robo.lamp_color = COLOR_RED //Syndicate likes it red

// Round start tablets

/obj/item/modular_computer/tablet/pda
	icon = 'icons/obj/modular_pda.dmi'
	icon_state = "pda"

	greyscale_config = /datum/greyscale_config/tablet
	greyscale_colors = "#999875#a92323"

	bypass_state = TRUE
	allow_chunky = TRUE

	///All applications this tablet has pre-installed
	var/list/default_applications = list()
	///The pre-installed cartridge that comes with the tablet
	var/loaded_cartridge

/obj/item/modular_computer/tablet/pda/update_overlays()
	. = ..()
	var/init_icon = initial(icon)
	var/obj/item/computer_hardware/card_slot/card = all_components[MC_CARD]
	if(!init_icon)
		return
	if(card)
		if(card.stored_card)
			. += mutable_appearance(init_icon, "id_overlay")
	if(light_on)
		. += mutable_appearance(init_icon, "light_overlay")

/obj/item/modular_computer/tablet/pda/attack_ai(mob/user)
	to_chat(user, span_notice("It doesn't feel right to snoop around like that..."))
	return // we don't want ais or cyborgs using a private role tablet

/obj/item/modular_computer/tablet/pda/Initialize(mapload)
	. = ..()
	install_component(new /obj/item/computer_hardware/hard_drive/small)
	install_component(new /obj/item/computer_hardware/processor_unit/small)
	install_component(new /obj/item/computer_hardware/battery(src, /obj/item/stock_parts/cell/computer))
	install_component(new /obj/item/computer_hardware/network_card)
	install_component(new /obj/item/computer_hardware/card_slot)
	install_component(new /obj/item/computer_hardware/identifier)
	install_component(new /obj/item/computer_hardware/sensorpackage)

	if(!isnull(default_applications))
		var/obj/item/computer_hardware/hard_drive/small/hard_drive = find_hardware_by_name("solid state drive")
		for(var/datum/computer_file/program/default_programs as anything in default_applications)
			hard_drive.store_file(new default_programs)

	if(loaded_cartridge)
		var/obj/item/computer_hardware/hard_drive/portable/disk = new loaded_cartridge(src)
		install_component(disk)

	if(insert_type)
		inserted_item = new insert_type(src)
