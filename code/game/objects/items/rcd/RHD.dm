//RAPID HANDHELD DEVICE. the base for all rapid devices

/obj/item/construction
	name = "not for ingame use"
	desc = "A device used to rapidly build and deconstruct. Reload with iron, plasteel, glass or compressed matter cartridges."
	opacity = FALSE
	density = FALSE
	anchored = FALSE
	flags_1 = CONDUCT_1
	item_flags = NOBLUDGEON
	force = 0
	throwforce = 10
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_NORMAL
	custom_materials = list(/datum/material/iron=SHEET_MATERIAL_AMOUNT*50)
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

/datum/armor/item_construction
	fire = 100
	acid = 50

/obj/item/construction/Initialize(mapload)
	. = ..()
	spark_system = new /datum/effect_system/spark_spread
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)
	if(upgrade & RCD_UPGRADE_SILO_LINK)
		silo_mats = AddComponent(/datum/component/remote_materials, "RCD", mapload, FALSE)
	update_appearance()

///used for examining the RCD and for its UI
/obj/item/construction/proc/get_silo_iron()
	if(silo_link && silo_mats.mat_container && !silo_mats.on_hold())
		return silo_mats.mat_container.get_material_amount(/datum/material/iron)/500
	return FALSE

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

/obj/item/construction/pre_attack(atom/target, mob/user, params)
	if(istype(target, /obj/item/rcd_upgrade))
		install_upgrade(target, user)
		return TRUE
	if(insert_matter(target, user))
		return TRUE
	return ..()

/obj/item/construction/attackby(obj/item/item, mob/user, params)
	if(istype(item, /obj/item/rcd_upgrade))
		install_upgrade(item, user)
		return TRUE
	if(insert_matter(item, user))
		return TRUE
	return ..()

/// Installs an upgrade into the RCD checking if it is already installed, or if it is a banned upgrade
/obj/item/construction/proc/install_upgrade(obj/item/rcd_upgrade/design_disk, mob/user)
	if(design_disk.upgrade & upgrade)
		balloon_alert(user, "already installed!")
		return
	if(design_disk.upgrade & banned_upgrades)
		balloon_alert(user, "cannot install upgrade!")
		return
	upgrade |= design_disk.upgrade
	if((design_disk.upgrade & RCD_UPGRADE_SILO_LINK) && !silo_mats)
		silo_mats = AddComponent(/datum/component/remote_materials, "RCD", FALSE, FALSE)
	playsound(loc, 'sound/machines/click.ogg', 50, TRUE)
	qdel(design_disk)

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
			balloon_alert(user, "no silo detected!")
			return FALSE
		if(!silo_mats.mat_container.has_materials(list(/datum/material/iron = 500), amount))
			if(user)
				balloon_alert(user, "not enough silo material!")
			return FALSE

		var/list/materials = list()
		materials[GET_MATERIAL_REF(/datum/material/iron)] = 500
		silo_mats.mat_container.use_materials(materials, amount)
		silo_mats.silo_log(src, "consume", -amount, "build", materials)
		return TRUE

///shared data for rcd,rld & plumbing
/obj/item/construction/ui_data(mob/user)
	var/list/data = list()

	//matter in the rcd
	var/total_matter = ((upgrade & RCD_UPGRADE_SILO_LINK) && silo_link) ? get_silo_iron() : get_matter(user)
	if(!total_matter)
		total_matter = 0
	data["matterLeft"] = total_matter

	//silo details
	data["silo_upgraded"] = !!(upgrade & RCD_UPGRADE_SILO_LINK)
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
		. = silo_mats.mat_container.has_materials(list(/datum/material/iron = 500), amount)
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
	if(user.incapacitated())
		return FALSE
	if(remote_anchor && user.remote_control != remote_anchor)
		return FALSE
	return TRUE

/obj/item/rcd_upgrade
	name = "RCD advanced design disk"
	desc = "It seems to be empty."
	icon = 'icons/obj/module.dmi'
	icon_state = "datadisk3"
	var/upgrade

/obj/item/rcd_upgrade/frames
	desc = "It contains the design for machine frames and computer frames."
	upgrade = RCD_UPGRADE_FRAMES

/obj/item/rcd_upgrade/simple_circuits
	desc = "It contains the design for firelock, air alarm, fire alarm, apc circuits and crap power cells."
	upgrade = RCD_UPGRADE_SIMPLE_CIRCUITS

/obj/item/rcd_upgrade/silo_link
	desc = "It contains direct silo connection RCD upgrade."
	upgrade = RCD_UPGRADE_SILO_LINK

/obj/item/rcd_upgrade/furnishing
	desc = "It contains the design for chairs, stools, tables, and glass tables."
	upgrade = RCD_UPGRADE_FURNISHING

/datum/action/item_action/rcd_scan
	name = "Destruction Scan"
	desc = "Scans the surrounding area for destruction. Scanned structures will rebuild significantly faster."

