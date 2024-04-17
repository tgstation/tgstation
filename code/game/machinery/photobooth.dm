/**
 * Photobooth
 * A machine used to change occupant's security record photos, working similarly to a
 * camera, but doesn't give any physical photo to the user.
 * Links to buttons for remote control.
 */
/obj/machinery/photobooth
	name = "photobooth"
	desc = "A machine with some drapes and a camera, used to update security record photos. Requires Law Office access to use."
	icon = 'icons/obj/machines/photobooth.dmi'
	icon_state = "booth_open"
	base_icon_state = "booth"
	state_open = TRUE
	circuit = /obj/item/circuitboard/machine/photobooth
	light_system = OVERLAY_LIGHT_DIRECTIONAL //Used as a flash here.
	light_range = 6
	light_color = COLOR_WHITE
	light_power = FLASH_LIGHT_POWER
	light_on = FALSE
	interaction_flags_atom = INTERACT_ATOM_ATTACK_HAND
	req_one_access = list(ACCESS_LAWYER, ACCESS_SECURITY)
	///Boolean on whether we should add a height chart to the underlays of the people we take photos of.
	var/add_height_chart = FALSE
	///Boolean on whether the machine is currently busy taking someone's pictures, so you can't start taking pictures while it's working.
	var/taking_pictures = FALSE
	///The ID of the photobooth, used to connect it to a button.
	var/button_id = "photobooth_machine_default"

/**
 * Security photobooth
 * Adds a height chart in the background, used for people you want to evidently stick out as prisoners.
 * Good for people you plan on putting in the permabrig.
 */
/obj/machinery/photobooth/security
	name = "security photobooth"
	desc = "A machine with some drapes and a camera, used to update security record photos. Requires Security access to use, and adds a height chart to the person."
	circuit = /obj/item/circuitboard/machine/photobooth/security
	req_one_access = list(ACCESS_SECURITY)
	color = COLOR_LIGHT_GRAYISH_RED
	add_height_chart = TRUE
	button_id = "photobooth_machine_security"

/obj/machinery/photobooth/Initialize(mapload)
	. = ..()
	register_context()

/obj/machinery/photobooth/interact(mob/living/user, list/modifiers)
	. = ..()
	if(taking_pictures)
		balloon_alert(user, "machine busy!")
		return
	if(state_open)
		close_machine()
	else
		open_machine()

/obj/machinery/photobooth/attack_hand_secondary(mob/user, list/modifiers)
	if(taking_pictures)
		balloon_alert(user, "machine busy!")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(occupant)
		if(allowed(user))
			start_taking_pictures()
		else
			balloon_alert(user, "access denied!")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	return ..()

/obj/machinery/photobooth/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	if(machine_stat & (BROKEN|NOPOWER) || !isnull(held_item))
		return NONE

	context[SCREENTIP_CONTEXT_LMB] = "[state_open ? "Close" : "Open"] Machine"
	if(occupant)
		context[SCREENTIP_CONTEXT_RMB] = "Take Pictures"

	return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/photobooth/close_machine(mob/user, density_to_set = TRUE)
	if(panel_open)
		balloon_alert(user, "close panel first!")
		return
	playsound(src, 'sound/effects/curtain.ogg', 50, TRUE)
	return ..()

/obj/machinery/photobooth/open_machine(drop = TRUE, density_to_set = FALSE)
	playsound(src, 'sound/effects/curtain.ogg', 50, TRUE)
	return ..()

/obj/machinery/photobooth/update_icon_state()
	. = ..()
	if(machine_stat & (BROKEN|NOPOWER))
		icon_state = "[base_icon_state]_off"
	else if(state_open)
		icon_state = "[base_icon_state]_open"
	else
		icon_state = "[base_icon_state]_closed"

/obj/machinery/photobooth/update_overlays()
	. = ..()
	if((machine_stat & MAINT) || panel_open)
		. += "[base_icon_state]_panel"

/obj/machinery/photobooth/screwdriver_act(mob/living/user, obj/item/tool)
	if(!has_buckled_mobs() && default_deconstruction_screwdriver(user, icon_state, icon_state, tool))
		update_appearance(UPDATE_ICON)
		return ITEM_INTERACT_SUCCESS
	return ..()

/obj/machinery/photobooth/crowbar_act(mob/living/user, obj/item/tool)
	if(default_deconstruction_crowbar(tool))
		return ITEM_INTERACT_SUCCESS
	return ..()

/obj/machinery/photobooth/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		return FALSE
	req_access = list() //in case someone sets this to something
	req_one_access = list()
	balloon_alert(user, "beeps softly")
	obj_flags |= EMAGGED
	return TRUE

/**
 * Handles the effects of taking pictures of the user, calling finish_taking_pictures
 * to actually update the records.
 */
/obj/machinery/photobooth/proc/start_taking_pictures()
	taking_pictures = TRUE
	if(obj_flags & EMAGGED)
		var/mob/living/carbon/carbon_occupant = occupant
		for(var/i in 1 to 5) //play a ton of sounds to mimic it blinding you
			playsound(src, pick('sound/items/polaroid1.ogg', 'sound/items/polaroid2.ogg'), 75, TRUE)
			if(carbon_occupant)
				carbon_occupant.flash_act(5)
			sleep(0.2 SECONDS)
		if(carbon_occupant)
			carbon_occupant.emote("scream")
		finish_taking_pictures()
		return
	if(!do_after(occupant, 2 SECONDS, src, timed_action_flags = IGNORE_HELD_ITEM)) //gives them time to put their hand items away.
		taking_pictures = FALSE
		return
	playsound(src, 'sound/items/polaroid1.ogg', 75, TRUE)
	flash()
	if(!do_after(occupant, 3 SECONDS, src, timed_action_flags = IGNORE_HELD_ITEM))
		taking_pictures = FALSE
		return
	playsound(src, 'sound/items/polaroid2.ogg', 75, TRUE)
	flash()
	if(!do_after(occupant, 2 SECONDS, src, timed_action_flags = IGNORE_HELD_ITEM))
		taking_pictures = FALSE
		return
	finish_taking_pictures()

///Updates the records (if possible), giving feedback, and spitting the user out if all's well.
/obj/machinery/photobooth/proc/finish_taking_pictures()
	taking_pictures = FALSE
	if(!GLOB.manifest.change_pictures(occupant.name, occupant, add_height_chart = add_height_chart))
		balloon_alert(occupant, "record not found!")
		return
	balloon_alert(occupant, "records updated")
	open_machine()

///Mimicing the camera, gives a flash effect by turning the light on and calling flash_end.
/obj/machinery/photobooth/proc/flash()
	set_light_on(TRUE)
	addtimer(CALLBACK(src, PROC_REF(flash_end)), FLASH_LIGHT_DURATION, TIMER_OVERRIDE|TIMER_UNIQUE)

///Called by a timer to turn the light off to end the flash effect.
/obj/machinery/photobooth/proc/flash_end()
	set_light_on(FALSE)


/obj/machinery/button/photobooth
	name = "photobooth control button"
	desc = "Operates the photobooth from a distance, allowing people to update their security record photos."
	device_type = /obj/item/assembly/control/photobooth_control
	req_one_access = list(ACCESS_SECURITY, ACCESS_LAWYER)
	id = "photobooth_machine_default"

/obj/machinery/button/photobooth/Initialize(mapload)
	. = ..()
	if(device)
		var/obj/item/assembly/control/photobooth_control/ours = device
		ours.id = id

/obj/machinery/button/photobooth/multitool_act(mob/living/user, obj/item/multitool/tool)
	. = ..()
	if(tool.buffer && !istype(tool.buffer, /obj/machinery/photobooth))
		return
	var/obj/item/assembly/control/photobooth_control/controller = device
	controller.booth_machine_ref = WEAKREF(tool.buffer)
	id = null
	controller.id = null
	balloon_alert(user, "linked to [tool.buffer]")

/obj/item/assembly/control/photobooth_control
	name = "photobooth controller"
	desc = "A remote controller for the HoP's photobooth."
	///Weakref to the photobooth we're connected to.
	var/datum/weakref/booth_machine_ref

/obj/item/assembly/control/photobooth_control/Initialize(mapload)
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/item/assembly/control/photobooth_control/LateInitialize()
	find_machine()

/// Locate the photobooth we're linked via ID
/obj/item/assembly/control/photobooth_control/proc/find_machine()
	for(var/obj/machinery/photobooth/booth as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/photobooth))
		if(booth.button_id == id)
			booth_machine_ref = WEAKREF(booth)
	if(booth_machine_ref)
		return TRUE
	return FALSE

/obj/item/assembly/control/photobooth_control/activate(mob/activator)
	if(!booth_machine_ref)
		return
	var/obj/machinery/photobooth/machine = booth_machine_ref.resolve()
	if(!machine)
		return
	if(machine.taking_pictures)
		balloon_alert(activator, "machine busy!")
		return
	machine.start_taking_pictures()
