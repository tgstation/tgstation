/datum/action/item_action/rig
	background_icon_state = "bg_tech_blue"

/datum/action/item_action/rig/deploy
	name = "Deploy RIGsuit"
	desc = "Deploy/Conceal a part of the RIGsuit."
	var/obj/item/rig/control/rig

/datum/action/item_action/rig/deploy/New(Target)
	..()
	rig = Target

/datum/action/item_action/rig/deploy/Trigger()
	var/list/rig_parts
	for(var/part in list(rig.helmet,rig.chestplate,rig.gauntlets,rig.boots))
		LAZYADD(rig_parts, part)
	if(!LAZYLEN(rig_parts))
		return
	var/list/display_names = list()
	var/list/items = list()
	for(var/i in 1 to length(rig_parts))
		var/obj/item/piece = rig_parts[i]
		display_names["[piece.name] ([i])"] = REF(piece)
		var/image/piece_image = image(icon = piece.icon, icon_state = piece.icon_state)
		items += list("[piece.name] ([i])" = piece_image)
	var/pick = show_radial_menu(usr, rig, items, custom_check = FALSE, require_near = TRUE)
	if(!pick)
		return
	var/part_reference = display_names[pick]
	var/obj/item/part = locate(part_reference) in rig_parts
	if(!istype(part) || usr.incapacitated() || !rig)
		return
	if(part.loc == rig)
		rig.deploy(part)
	else
		rig.conceal(part)
