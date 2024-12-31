/datum/action/item_action/chameleon/change/neck
	chameleon_type = /obj/item/clothing/neck
	chameleon_name = "Neck Accessory"
	active_type = /obj/item/clothing/neck/tie/black

/datum/action/item_action/chameleon/change/neck/initialize_blacklist()
	. = ..()
	chameleon_blacklist |= typecacheof(/obj/item/clothing/neck/cloak/skill_reward)

/datum/action/item_action/chameleon/change/stamp
	chameleon_type = /obj/item/stamp
	chameleon_name = "Stamp"

/datum/action/item_action/chameleon/change/tablet
	chameleon_type = /obj/item/modular_computer/pda
	chameleon_name = "Tablet"

/datum/action/item_action/chameleon/change/tablet/initialize_blacklist()
	. = ..()
	chameleon_blacklist |= typecacheof(list(/obj/item/modular_computer/pda/heads), only_root_path = TRUE)

/datum/action/item_action/chameleon/change/tablet/update_item(obj/item/picked_item)
	..()
	var/obj/item/modular_computer/pda/agent_pda = target
	if(istype(agent_pda))
		agent_pda.update_appearance()

/datum/action/item_action/chameleon/change/tablet/apply_job_data(datum/job/job_datum)
	..()
	var/obj/item/modular_computer/pda/agent_pda = target
	if(istype(agent_pda) && istype(job_datum))
		agent_pda.imprint_id(job_name = job_datum.title)

/datum/action/item_action/chameleon/change/headset
	chameleon_type = /obj/item/radio/headset
	chameleon_name = "Headset"
	active_type = /obj/item/radio/headset

/datum/action/item_action/chameleon/change/belt
	chameleon_type = /obj/item/storage/belt
	chameleon_name = "Belt"
	active_type = /obj/item/storage/belt/utility

/datum/action/item_action/chameleon/change/backpack
	chameleon_type = /obj/item/storage/backpack
	chameleon_name = "Backpack"
	active_type = /obj/item/storage/backpack

/datum/action/item_action/chameleon/change/shoes
	chameleon_type = /obj/item/clothing/shoes
	chameleon_name = "Shoes"
	active_type = /obj/item/clothing/shoes/sneakers/black

/datum/action/item_action/chameleon/change/shoes/initialize_blacklist()
	. = ..()
	chameleon_blacklist |= typecacheof(/obj/item/clothing/shoes/changeling, only_root_path = TRUE)

/datum/action/item_action/chameleon/change/mask
	chameleon_type = /obj/item/clothing/mask
	chameleon_name = "Mask"
	active_type = /obj/item/clothing/mask/gas

/datum/action/item_action/chameleon/change/mask/initialize_blacklist()
	. = ..()
	chameleon_blacklist |= typecacheof(/obj/item/clothing/mask/changeling, only_root_path = TRUE)

/datum/action/item_action/chameleon/change/mask/initialize_disguises()
	. = ..()
	add_chameleon_items(/obj/item/cigarette)
	add_chameleon_items(/obj/item/vape)

/datum/action/item_action/chameleon/change/hat
	chameleon_type = /obj/item/clothing/head
	chameleon_name = "Hat"
	active_type = /obj/item/clothing/head/soft/black

/datum/action/item_action/chameleon/change/hat/initialize_blacklist()
	. = ..()
	chameleon_blacklist |= typecacheof(/obj/item/clothing/head/changeling, only_root_path = TRUE)

/datum/action/item_action/chameleon/change/gloves
	chameleon_type = /obj/item/clothing/gloves
	chameleon_name = "Gloves"
	active_type = /obj/item/clothing/gloves/color/yellow

/datum/action/item_action/chameleon/change/gloves/initialize_blacklist()
	. = ..()
	chameleon_blacklist |= typecacheof(list(/obj/item/clothing/gloves, /obj/item/clothing/gloves/color, /obj/item/clothing/gloves/changeling), only_root_path = TRUE)

/datum/action/item_action/chameleon/change/glasses
	chameleon_type = /obj/item/clothing/glasses
	chameleon_name = "Glasses"
	active_type = /obj/item/clothing/glasses/meson

/datum/action/item_action/chameleon/change/glasses/initialize_blacklist()
	. = ..()
	chameleon_blacklist |= typecacheof(list(/obj/item/clothing/glasses/changeling, /obj/item/clothing/glasses/hud/security/chameleon, /obj/item/clothing/glasses/thermal/syndi), only_root_path = TRUE)

/datum/action/item_action/chameleon/change/glasses/no_preset
	active_type = null

/datum/action/item_action/chameleon/change/suit
	chameleon_type = /obj/item/clothing/suit
	chameleon_name = "Suit"
	active_type = /obj/item/clothing/suit/armor/vest

/datum/action/item_action/chameleon/change/suit/initialize_blacklist()
	. = ..()
	chameleon_blacklist |= typecacheof(list(/obj/item/clothing/suit/armor/abductor, /obj/item/clothing/suit/changeling), only_root_path = TRUE)

/datum/action/item_action/chameleon/change/suit/apply_outfit(datum/outfit/applying_from, list/all_items_to_apply)
	. = ..()
	if(!. || !ispath(applying_from.suit, /obj/item/clothing/suit/hooded))
		return
	// If we're appling a hooded suit, and wearing a cham hat, make it a hood
	var/obj/item/clothing/suit/hooded/hooded = applying_from.suit
	var/datum/action/item_action/chameleon/change/hat/hood_action = locate() in owner?.actions
	hood_action?.update_look(initial(hooded.hoodtype))

/datum/action/item_action/chameleon/change/jumpsuit
	chameleon_type = /obj/item/clothing/under
	chameleon_name = "Jumpsuit"
	active_type = /obj/item/clothing/under/color/black

/datum/action/item_action/chameleon/change/jumpsuit/initialize_blacklist()
	. = ..()
	chameleon_blacklist |= typecacheof(list(/obj/item/clothing/under, /obj/item/clothing/under/color, /obj/item/clothing/under/rank, /obj/item/clothing/under/changeling), only_root_path = TRUE)

/datum/action/item_action/chameleon/change/id
	chameleon_type = /obj/item/card/id/advanced
	chameleon_name = "ID Card"

/datum/action/item_action/chameleon/change/id/New(Target)
	. = ..()
	if(!istype(target, /obj/item/card/id/advanced/chameleon))
		stack_trace("Adding chameleon ID action to non-chameleon id ([target])")
		qdel(src)

/datum/action/item_action/chameleon/change/id/update_item(obj/item/picked_item)
	. = ..()
	var/obj/item/card/id/advanced/chameleon/agent_card = target
	var/obj/item/card/id/copied_card = picked_item

	// If the outfit comes with a special trim override, we'll steal some stuff from that.
	var/new_trim = initial(copied_card.trim)

	if(new_trim)
		SSid_access.apply_trim_to_chameleon_card(agent_card, new_trim, TRUE)

	// If the ID card hasn't been forged, we'll check if there has been an assignment set already by any new trim.
	// If there has not, we set the assignment to the copied card's default as well as copying over the the
	// default registered name from the copied card.
	if(!agent_card.forged)
		if(!agent_card.assignment)
			agent_card.assignment = initial(copied_card.assignment)

		agent_card.registered_name = initial(copied_card.registered_name)

	agent_card.icon_state = initial(copied_card.icon_state)
	if(ispath(copied_card, /obj/item/card/id/advanced))
		var/obj/item/card/id/advanced/copied_advanced_card = copied_card
		agent_card.assigned_icon_state = initial(copied_advanced_card.assigned_icon_state)

	agent_card.update_label()
	agent_card.update_appearance(UPDATE_ICON)

/datum/action/item_action/chameleon/change/id/apply_job_data(datum/job/job_datum)
	var/obj/item/card/id/advanced/chameleon/agent_card = target
	agent_card.forged = TRUE

	// job_outfit is going to be a path.
	var/datum/outfit/job/job_outfit = job_datum.outfit
	if(isnull(job_outfit))
		return

	// copied_card is also going to be a path.
	var/obj/item/card/id/copied_card = initial(job_outfit.id)
	if(isnull(copied_card))
		return

	// If the outfit comes with a special trim override, we'll use that. Otherwise, use the card's default trim. Failing that, no trim at all.
	var/new_trim = initial(job_outfit.id_trim) ? initial(job_outfit.id_trim) : initial(copied_card.trim)

	if(new_trim)
		SSid_access.apply_trim_to_chameleon_card(agent_card, new_trim, FALSE)
	else
		agent_card.assignment = job_datum.title

	agent_card.icon_state = initial(copied_card.icon_state)
	if(ispath(copied_card, /obj/item/card/id/advanced))
		var/obj/item/card/id/advanced/copied_advanced_card = copied_card
		agent_card.assigned_icon_state = initial(copied_advanced_card.assigned_icon_state)

	agent_card.update_label()
	agent_card.update_appearance(UPDATE_ICON)

/datum/action/item_action/chameleon/change/id_trim
	chameleon_type = /datum/id_trim
	chameleon_name = "ID Trim"

/datum/action/item_action/chameleon/change/id_trim/New(Target)
	. = ..()
	if(!istype(target, /obj/item/card/id/advanced/chameleon))
		stack_trace("Adding chameleon ID trim action to non-chameleon id ([target])")
		qdel(src)

/datum/action/item_action/chameleon/change/id_trim/initialize_blacklist()
	return

/datum/action/item_action/chameleon/change/id_trim/initialize_disguises()
	// Little bit of copypasta but we only use trim datums rather than item paths
	name = "Change [chameleon_name] Appearance"
	build_all_button_icons()

	LAZYINITLIST(chameleon_typecache)
	LAZYINITLIST(chameleon_list)

	for(var/datum/id_trim/trim_path as anything in typesof(/datum/id_trim))
		if(chameleon_blacklist[trim_path])
			continue

		var/datum/id_trim/trim = SSid_access.trim_singletons_by_path[trim_path]

		if(trim && trim.trim_state && trim.assignment)
			var/chameleon_item_name = "[trim.assignment] ([trim.trim_state])"
			chameleon_list[chameleon_item_name] = trim_path
			chameleon_typecache[trim_path] = TRUE

/datum/action/item_action/chameleon/change/id_trim/update_item(picked_trim_path)
	var/obj/item/card/id/advanced/chameleon/agent_card = target

	SSid_access.apply_trim_to_chameleon_card(agent_card, picked_trim_path, TRUE)

	agent_card.update_label()
	agent_card.update_appearance(UPDATE_ICON)

/datum/action/item_action/chameleon/change/gun
	chameleon_type = /obj/item/gun
	chameleon_name = "Gun"

/datum/action/item_action/chameleon/change/gun/New(Target)
	. = ..()
	if(!istype(target, /obj/item/gun/energy/laser/chameleon))
		stack_trace("Adding chameleon gun action to non-chameleon gun ([target])")
		qdel(src)

/datum/action/item_action/chameleon/change/gun/initialize_blacklist()
	. = ..()
	chameleon_blacklist |= typecacheof(/obj/item/gun/energy/minigun)

/datum/action/item_action/chameleon/change/gun/update_look(obj/item/picked_item)
	var/obj/item/gun/energy/laser/chameleon/chameleon_gun = target
	chameleon_gun.set_chameleon_disguise(picked_item)
	return ..()

/datum/action/item_action/chameleon/change/scanner
	chameleon_type = /obj/item/pen
	chameleon_name = "Chameleon Scanner"
	active_type = /obj/item/storage/fancy/cigarettes/cigpack_robustgold
	/// Other types the chameleon scanner can swap into in addition to the chameleon type
	var/static/list/other_cham_types = list(
		/obj/item/analyzer,
		/obj/item/assembly/flash/handheld,
		/obj/item/assembly/signaler,
		/obj/item/autopsy_scanner,
		/obj/item/camera,
		/obj/item/cane,
		/obj/item/detective_scanner,
		/obj/item/door_remote,
		/obj/item/flashlight,
		/obj/item/geiger_counter,
		/obj/item/healthanalyzer,
		/obj/item/mining_scanner,
		/obj/item/multitool,
		/obj/item/plant_analyzer,
		/obj/item/sensor_device,
		/obj/item/storage/fancy/cigarettes, // Fanservice
		/obj/item/taperecorder,
		/obj/item/toy/crayon,
	)
	// (Other ideas include: GPSs, PDAs, station bounced radios, holosign creators, etc. But this is good enough)

/datum/action/item_action/chameleon/change/scanner/initialize_blacklist()
	. = ..()
	chameleon_blacklist |= typecacheof(list(
		/obj/item/assembly/signaler/anomaly,
		/obj/item/camera/siliconcam,
		/obj/item/door_remote/omni,
		/obj/item/flashlight/emp/debug,
		/obj/item/flashlight/flare,
		/obj/item/flashlight/lamp,
		/obj/item/healthanalyzer/rad_laser,
		/obj/item/multitool/ai_detect,
		/obj/item/multitool/cyborg,
		/obj/item/multitool/drone,
		/obj/item/multitool/field_debug,
		/obj/item/storage/fancy/cigarettes/cigars,
	))

/datum/action/item_action/chameleon/change/scanner/initialize_disguises()
	. = ..()
	for(var/other_type in other_cham_types)
		add_chameleon_items(other_type)

/datum/action/item_action/chameleon/change/gun/ballistic
	chameleon_type = /obj/item/gun/ballistic
	chameleon_name = "Gun"
