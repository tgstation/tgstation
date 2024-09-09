//RAPID HANDHELD DEVICE. the base for all rapid devices

#define SILO_USE_AMOUNT (SHEET_MATERIAL_AMOUNT / 4)

/obj/item/construction
	name = "not for ingame use"
	desc = "A device used to rapidly build and deconstruct. Reload with iron, plasteel, glass or compressed matter cartridges."
	opacity = FALSE
	density = FALSE
	anchored = FALSE
	obj_flags = CONDUCTS_ELECTRICITY
	item_flags = NOBLUDGEON
	force = 0
	throwforce = 10
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_NORMAL
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 50)
	req_access = list(ACCESS_ENGINE_EQUIP)
	armor_type = /datum/armor/item_construction
	resistance_flags = FIRE_PROOF
	/// the spark system which sparks whever the ui options are dited
	var/datum/effect_system/spark_spread/spark_system
	/// current local matter inside the device, not used when silo link is on
	var/matter = 0
	/// maximum local matter this device can hold, not used when silo link is on
	var/max_matter = 100
	/// controls whether or not does update_icon apply ammo indicator overlays
	var/has_ammobar = FALSE
	/// amount of divisions in the ammo indicator overlay/number of ammo indicator states
	var/ammo_sections = 10
	/// bitflags for upgrades
	var/upgrade = NONE
	/// bitflags for banned upgrades
	var/banned_upgrades = NONE
	/// remote connection to the silo
	var/datum/component/remote_materials/silo_mats
	/// switch to use internal or remote storage
	var/silo_link = FALSE
	/// has the blueprint design changed
	var/blueprint_changed = FALSE

/datum/armor/item_construction
	fire = 100
	acid = 50

/obj/item/construction/Initialize(mapload)
	. = ..()
	spark_system = new /datum/effect_system/spark_spread
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)
	if(upgrade & RCD_UPGRADE_SILO_LINK)
		silo_mats = AddComponent(/datum/component/remote_materials, mapload, FALSE)
	update_appearance()

///An do_after() specially designed for rhd devices
/obj/item/construction/proc/build_delay(mob/user, delay, atom/target)
	if(delay <= 0)
		return TRUE

	blueprint_changed = FALSE

	return do_after(user, delay, target, extra_checks = CALLBACK(src, PROC_REF(blueprint_change)))

/obj/item/construction/proc/blueprint_change()
	return !blueprint_changed

///used for examining the RCD and for its UI
/obj/item/construction/proc/get_silo_iron()
	if(silo_link && silo_mats.mat_container && !silo_mats.on_hold())
		return silo_mats.mat_container.get_material_amount(/datum/material/iron) / SILO_USE_AMOUNT
	return 0

///returns local matter units available. overriden by rcd borg to return power units available
/obj/item/construction/proc/get_matter(mob/user)
	return matter

/obj/item/construction/examine(mob/user)
	. = ..()
	. += "It currently holds [get_matter(user)]/[max_matter] matter-units."
	if(upgrade & RCD_UPGRADE_SILO_LINK)
		. += "Remote storage link state: [silo_link ? "[silo_mats.on_hold() ? "ON HOLD" : "ON"]" : "OFF"]."
		var/iron = get_silo_iron()
		if(iron)
			. += "Remote connection has iron in equivalent to [iron] RCD unit\s." //1 matter for 1 floor tile, as 4 tiles are produced from 1 iron

/obj/item/construction/Destroy()
	QDEL_NULL(spark_system)
	silo_mats = null
	return ..()

/obj/item/construction/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	SHOULD_CALL_PARENT(TRUE)
	if(istype(interacting_with, /obj/item/rcd_upgrade))
		install_upgrade(interacting_with, user)
		return ITEM_INTERACT_SUCCESS
	if(insert_matter(interacting_with, user))
		return ITEM_INTERACT_SUCCESS
	return ..()

/obj/item/construction/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	SHOULD_CALL_PARENT(TRUE)
	if(istype(tool, /obj/item/rcd_upgrade))
		install_upgrade(tool, user)
		return ITEM_INTERACT_SUCCESS
	if(insert_matter(tool, user))
		return ITEM_INTERACT_SUCCESS
	return ..()

/// Installs an upgrade into the RCD checking if it is already installed, or if it is a banned upgrade
/obj/item/construction/proc/install_upgrade(obj/item/rcd_upgrade/design_disk, mob/user)
	if(design_disk.upgrade & upgrade)
		balloon_alert(user, "already installed!")
		return FALSE
	if(design_disk.upgrade & banned_upgrades)
		balloon_alert(user, "cannot install upgrade!")
		return FALSE
	upgrade |= design_disk.upgrade
	if((design_disk.upgrade & RCD_UPGRADE_SILO_LINK) && !silo_mats)
		silo_mats = AddComponent(/datum/component/remote_materials, FALSE, FALSE)
	playsound(loc, 'sound/machines/click.ogg', 50, TRUE)
	qdel(design_disk)
	update_static_data_for_all_viewers()
	return TRUE

/// Inserts matter into the RCD allowing it to build
/obj/item/construction/proc/insert_matter(obj/item, mob/user)
	if(iscyborg(user))
		return FALSE

	var/loaded = FALSE
	if(istype(item, /obj/item/rcd_ammo))
		var/obj/item/rcd_ammo/ammo = item
		var/load = min(ammo.ammoamt, max_matter - matter)
		if(load <= 0)
			balloon_alert(user, "storage full!")
			return FALSE
		ammo.ammoamt -= load
		if(ammo.ammoamt <= 0)
			qdel(ammo)
		matter += load
		playsound(loc, 'sound/machines/click.ogg', 50, TRUE)
		loaded = TRUE
	else if(isstack(item))
		loaded = loadwithsheets(item, user)
	if(loaded)
		update_appearance() //ensures that ammo counters (if present) get updated
	return loaded

/obj/item/construction/proc/loadwithsheets(obj/item/stack/the_stack, mob/user)
	if(the_stack.matter_amount <= 0)
		balloon_alert(user, "invalid sheets!")
		return FALSE
	var/maxsheets = round((max_matter-matter) / the_stack.matter_amount) //calculate the max number of sheets that will fit in RCD
	if(maxsheets > 0)
		var/amount_to_use = min(the_stack.amount, maxsheets)
		the_stack.use(amount_to_use)
		matter += the_stack.matter_amount * amount_to_use
		playsound(loc, 'sound/machines/click.ogg', 50, TRUE)
		return TRUE
	balloon_alert(user, "storage full!")
	return FALSE

/obj/item/construction/proc/activate()
	playsound(loc, 'sound/items/deconstruct.ogg', 50, TRUE)

/obj/item/construction/attack_self(mob/user)
	playsound(loc, 'sound/effects/pop.ogg', 50, FALSE)
	if(prob(20))
		spark_system.start()

/obj/item/construction/update_overlays()
	. = ..()
	if(has_ammobar)
		var/ratio = CEILING((matter / max_matter) * ammo_sections, 1)
		if(ratio > 0)
			. += "[icon_state]_charge[ratio]"

/obj/item/construction/proc/useResource(amount, mob/user)
	if(!silo_mats || !silo_link)
		if(matter < amount)
			if(user)
				balloon_alert(user, "not enough matter!")
			return FALSE
		matter -= amount
		update_appearance()
		return TRUE
	else
		if(silo_mats.on_hold())
			if(user)
				balloon_alert(user, "silo on hold!")
			return FALSE
		if(!silo_mats.mat_container)
			if(user)
				balloon_alert(user, "no silo detected!")
			return FALSE

		if(!silo_mats.mat_container.has_enough_of_material(/datum/material/iron, amount * SILO_USE_AMOUNT))
			if(user)
				balloon_alert(user, "not enough silo material!")
			return FALSE
		silo_mats.use_materials(list(/datum/material/iron = SILO_USE_AMOUNT), multiplier = amount, action = "build", name = "consume")
		return TRUE

/obj/item/construction/ui_static_data(mob/user)
	. = list()

	.["silo_upgraded"] = !!(upgrade & RCD_UPGRADE_SILO_LINK)

///shared data for rcd,rld & plumbing
/obj/item/construction/ui_data(mob/user)
	var/list/data = list()

	//matter in the rcd
	var/total_matter = ((upgrade & RCD_UPGRADE_SILO_LINK) && silo_link) ? get_silo_iron() : get_matter(user)
	if(!total_matter)
		total_matter = 0
	data["matterLeft"] = total_matter

	data["silo_enabled"] = silo_link

	return data

/obj/item/construction/proc/toggle_silo(mob/user)
	if(!silo_mats)
		to_chat(user, span_warning("no remote storage connection."))
		return FALSE

	if(!silo_mats.mat_container && !silo_link) // Allow them to turn off an invalid link.
		to_chat(user, span_warning("no silo link detected."))
		return FALSE

	silo_link = !silo_link
	to_chat(user, span_notice("silo link state: [silo_link ? "on" : "off"]"))
	return TRUE

///shared action for toggling silo link rcd,rld & plumbing
/obj/item/construction/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	if(action == "toggle_silo" && (upgrade & RCD_UPGRADE_SILO_LINK))
		toggle_silo(ui.user)
		return TRUE

	var/update = handle_ui_act(action, params, ui, state)
	if(isnull(update))
		update = FALSE
	return update

/// overwrite to insert custom ui handling for subtypes
/obj/item/construction/proc/handle_ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	return null

/obj/item/construction/proc/checkResource(amount, mob/user)
	if(!silo_mats || !silo_mats.mat_container || !silo_link)
		if(silo_link)
			balloon_alert(user, "silo link invalid!")
			return FALSE
		else
			. = matter >= amount
	else
		if(silo_mats.on_hold())
			if(user)
				balloon_alert(user, "silo on hold!")
			return FALSE
		. = silo_mats.mat_container.has_enough_of_material(/datum/material/iron, amount * SILO_USE_AMOUNT)
	if(!. && user)
		balloon_alert(user, "low ammo!")
		if(has_ammobar)
			flick("[icon_state]_empty", src) //somewhat hacky thing to make RCDs with ammo counters actually have a blinking yellow light
	return .

/obj/item/construction/proc/range_check(atom/target, mob/user)
	if(target.z != user.z)
		return
	if(!(target in dview(7, get_turf(user))))
		balloon_alert(user, "out of range!")
		flick("[icon_state]_empty", src)
		return FALSE
	else
		return TRUE

/**
 * Checks if we are allowed to interact with a radial menu
 *
 * Arguments:
 * * user The living mob interacting with the menu
 * * remote_anchor The remote anchor for the menu
 */
/obj/item/construction/proc/check_menu(mob/living/user, remote_anchor)
	if(!istype(user))
		return FALSE
	if(user.incapacitated)
		return FALSE
	if(remote_anchor && user.remote_control != remote_anchor)
		return FALSE
	return TRUE

/obj/item/rcd_upgrade
	name = "RCD advanced design disk"
	desc = "It seems to be empty."
	icon = 'icons/obj/devices/circuitry_n_data.dmi'
	icon_state = "datadisk3"
	var/upgrade

/obj/item/rcd_upgrade/frames
	name = "RCD advanced upgrade: frames"
	desc = "It contains the design for machine frames and computer frames."
	icon_state = "datadisk6"
	upgrade = RCD_UPGRADE_FRAMES

/obj/item/rcd_upgrade/simple_circuits
	name = "RCD advanced upgrade: simple circuits"
	desc = "It contains the design for firelock, air alarm, fire alarm, apc circuits and crap power cells."
	icon_state = "datadisk4"
	upgrade = RCD_UPGRADE_SIMPLE_CIRCUITS

/obj/item/rcd_upgrade/anti_interrupt
	name = "RCD advanced upgrade: anti disruption"
	desc = "It contains the upgrades necessary to prevent interruption of RCD construction and deconstruction."
	icon_state = "datadisk2"
	upgrade = RCD_UPGRADE_ANTI_INTERRUPT

/obj/item/rcd_upgrade/cooling
	name = "RCD advanced upgrade: enhanced cooling"
	desc = "It contains the upgrades necessary to allow more frequent use of the RCD."
	icon_state = "datadisk7"
	upgrade = RCD_UPGRADE_NO_FREQUENT_USE_COOLDOWN

/obj/item/rcd_upgrade/silo_link
	name = "RCD advanced upgrade: silo link"
	desc = "It contains direct silo connection RCD upgrade."
	icon_state = "datadisk8"
	upgrade = RCD_UPGRADE_SILO_LINK

/obj/item/rcd_upgrade/furnishing
	name = "RCD advanced upgrade: furnishings"
	desc = "It contains the design for chairs, stools, tables, and glass tables."
	icon_state = "datadisk5"
	upgrade = RCD_UPGRADE_FURNISHING

/datum/action/item_action/rcd_scan
	name = "Destruction Scan"
	desc = "Scans the surrounding area for destruction. Scanned structures will rebuild significantly faster."

#undef SILO_USE_AMOUNT
