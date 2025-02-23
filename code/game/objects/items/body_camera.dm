/**
 * Bodycamera Upgrade
 *
 * An item that can be inserted into any piece of clothing that goes on the Exosuit slot.
 * Allows you to turn it on/off with an ID card to add the suit & the wearer's name into the security camera system.
 */
/obj/item/bodycam_upgrade
	name = "\improper body camera"
	desc = "A body camera device attachable to most outerwear. There's an instructions tag if you look a little closer..."
	icon = 'icons/obj/clothing/neck.dmi'
	icon_state = "bodycamera"

	///The network we give to the builtin body camera while it's on and active.
	var/list/network = list(CAMERANET_NETWORK_SS13)
	///The camera itself, made when we need it and deleted on Destroy. Installed into the clothing item directly.
	var/obj/machinery/camera/bodycamera/builtin_bodycamera
	/**
	 * Sprites by: @Partheo from Yogstation, colors very, very slightly edited.
	 * A static overlay put onto any clothing item that has the camera installed.
	 */
	var/static/mutable_appearance/equipped_overlay = mutable_appearance('icons/mob/clothing/neck.dmi', "bodycamera")
	///Signals we register to connect_loc to ensure the radio jammer always follows the person wearing the body camera.
	var/static/list/loc_connections = list(
		COMSIG_RADIO_JAMMED = PROC_REF(on_jammed),
	)

/obj/item/bodycam_upgrade/Destroy(force)
	if(!isnull(builtin_bodycamera))
		QDEL_NULL(builtin_bodycamera)
	return ..()

/obj/item/bodycam_upgrade/examine_more(mob/user)
	. = ..()
	. += span_notice("You can use [name] on any outerwear to install it, automatically turning on if the outerwear is equipped.")
	. += span_notice("Once installed, you can use an [EXAMINE_HINT("ID card")] to turn the camera on and off.")

/obj/item/bodycam_upgrade/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!isitem(interacting_with))
		return NONE
	var/obj/item/interacting_item = interacting_with
	if(!(interacting_item.slot_flags & ITEM_SLOT_OCLOTHING))
		return NONE
	if(interacting_item.item_flags & (ABSTRACT|DROPDEL)) //things like changeling suits don't get body cameras.
		return NONE
	install_camera(interacting_item, user)
	return ITEM_INTERACT_SUCCESS

///Installs the bodycamera into a piece of clothing, updating the overlays on the mob if they're actively wearing it.
/obj/item/bodycam_upgrade/proc/install_camera(obj/item/installing_into, mob/user)
	var/obj/item/bodycam_upgrade/existing_upgrade = locate() in installing_into.contents
	if(existing_upgrade)
		//this is where your mouse is, so more likely where you're looking.
		installing_into.balloon_alert(user, "camera already installed!")
		playsound(installing_into, 'sound/machines/buzz/buzz-two.ogg', 20, TRUE, -1)
		return
	installing_into.add_overlay(equipped_overlay)
	forceMove(installing_into)
	playsound(installing_into, 'sound/items/tools/drill_use.ogg', 20, TRUE, -1)
	RegisterSignal(installing_into, COMSIG_ATOM_ATTACKBY, PROC_REF(on_attackby))
	RegisterSignal(installing_into, COMSIG_ATOM_EXAMINE_MORE, PROC_REF(on_examine_more))
	RegisterSignal(installing_into, COMSIG_ATOM_TOOL_ACT(TOOL_SCREWDRIVER), PROC_REF(on_screwdriver_act))
	RegisterSignal(installing_into, COMSIG_ITEM_GET_WORN_OVERLAYS, PROC_REF(on_checked_overlays))
	RegisterSignal(installing_into, COMSIG_ATOM_EMP_ACT, PROC_REF(on_emp_act))
	AddComponent(/datum/component/connect_loc_behalf, installing_into, loc_connections)
	if(user.get_item_by_slot(ITEM_SLOT_OCLOTHING) == installing_into)
		user.update_worn_oversuit(update_obscured = FALSE)
		turn_on(user)

///Uninstalls the bodycamera from a piece of clothing.
/obj/item/bodycam_upgrade/proc/uninstall_camera(obj/item/taking_from, mob/user)
	UnregisterSignal(taking_from, list(
		COMSIG_ATOM_ATTACKBY,
		COMSIG_ATOM_EXAMINE_MORE,
		COMSIG_ATOM_TOOL_ACT(TOOL_SCREWDRIVER),
		COMSIG_ITEM_GET_WORN_OVERLAYS,
		COMSIG_ATOM_EMP_ACT,
	))
	qdel(GetComponent(/datum/component/connect_loc_behalf))
	if(builtin_bodycamera) //retract the camera back in.
		builtin_bodycamera.forceMove(src)
		builtin_bodycamera.network = list()
	taking_from.cut_overlay(equipped_overlay)
	forceMove(user.drop_location())
	turn_off()
	user.put_in_hands(src)
	if(user.get_item_by_slot(ITEM_SLOT_OCLOTHING) == taking_from)
		user.update_worn_oversuit(update_obscured = FALSE)

///Turns the camera on. Will be silent if 'user' is null, but it REQUIRES either a user or a provided ID.
///Because cameras are named after the ID, or person if there isn't one, then having neither means we can't turn
///on at all.
/obj/item/bodycam_upgrade/proc/turn_on(mob/living/user, obj/item/card/id/id_card)
	if(!id_card && !user)
		return
	if(!builtin_bodycamera)
		builtin_bodycamera = new(loc) //made in the vest it's located in.
	if(!id_card)
		id_card = user.get_idcard() || null
	if(id_card)
		builtin_bodycamera.c_tag = "-Body Camera: [(id_card.registered_name)] ([id_card.assignment])"
	else
		builtin_bodycamera.c_tag = "-Body Camera: [(user.name)]"
	if(user)
		user.balloon_alert(user, "bodycamera activated")
		playsound(loc, 'sound/machines/beep/beep.ogg', get_clamped_volume(), TRUE, -1)
	builtin_bodycamera.network = network //sync the network of the camera to us, the upgrade.
	builtin_bodycamera.camera_enabled = TRUE

///Turns the camera off. Will be silent if 'user' is null.
/obj/item/bodycam_upgrade/proc/turn_off(mob/user)
	if(user)
		user.balloon_alert(user, "bodycamera deactivated")
		playsound(loc, 'sound/machines/beep/beep.ogg', get_clamped_volume(), TRUE, -1)
	builtin_bodycamera.camera_enabled = FALSE

/**
 * on_emp_act
 *
 * Called when the body camera is EMPed.
 * Will destroy the camera, regardless of whether it is equipped or not.
 */
/obj/item/bodycam_upgrade/proc/on_emp_act(atom/source, severity, protection)
	SIGNAL_HANDLER
	if(protection & EMP_PROTECT_SELF)
		return
	if(!isnull(builtin_bodycamera))
		QDEL_NULL(builtin_bodycamera)

/**
 * Examine more
 *
 * Called when the item the bodycamera is installed into is double-examined,
 * letting it know it's examined and how to get it out.
 */
/obj/item/bodycam_upgrade/proc/on_examine_more(atom/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	examine_list += span_notice("It has [name] installed[builtin_bodycamera ? " and is currently [builtin_bodycamera.camera_enabled ? "on" : "off"]" : ""]. You can toggle it with an [EXAMINE_HINT("ID card")] or remove it with a [EXAMINE_HINT("screwdriver")].")

/**
 * Screwdriver act
 *
 * Called when a screwdriver is used on the item the bodycamera is installed into.
 * Removes the bodycamera from the clothing and puts it in the user's hand.
 */
/obj/item/bodycam_upgrade/proc/on_screwdriver_act(atom/source, mob/user, obj/item/tool)
	SIGNAL_HANDLER

	playsound(source, 'sound/items/tools/drill_use.ogg', tool.get_clamped_volume(), TRUE, -1)
	INVOKE_ASYNC(src, PROC_REF(uninstall_camera), source, user)

/**
 * On Attackby
 *
 * Called when the piece of clothing the bodycamera is installed into is attacked by an item.
 * If the item is an ID card, it will turn the camera on/off.
 */
/obj/item/bodycam_upgrade/proc/on_attackby(datum/source, obj/item/item, mob/living/user)
	SIGNAL_HANDLER

	var/obj/item/card/id/card = item.GetID()
	if(!card)
		return

	if(builtin_bodycamera?.camera_enabled)
		return turn_off(user)
	return turn_on(user, card)

/**
 * On checked overlays
 *
 * Called when the item the bodycamera is installed into is getting their worn overlays updated.
 * We add our body camera overlay to the list of overlays.
 */
/obj/item/bodycam_upgrade/proc/on_checked_overlays(obj/item/source, list/overlays, mutable_appearance/standing, isinhands, icon_file)
	SIGNAL_HANDLER
	if(isinhands)
		return
	overlays += equipped_overlay

///Called when the body camera has been jammed.
/obj/item/bodycam_upgrade/proc/on_jammed(datum/source, ignore_syndie)
	SIGNAL_HANDLER
	if(isnull(builtin_bodycamera))
		return
	if(ignore_syndie && (OPERATIVE_CAMERA_NET in network))
		return
	turn_off()
