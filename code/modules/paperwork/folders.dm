/obj/item/folder
	name = "folder"
	desc = "A folder."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "folder"
	w_class = WEIGHT_CLASS_SMALL
	pressure_resistance = 2
	resistance_flags = FLAMMABLE


/obj/item/clipboard/AllowDrop()
	return FALSE

/obj/item/clipboard/get_dumping_location(obj/item/storage/source,mob/user)
	return src

/obj/item/folder/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = AddComponent(/datum/component/storage/concrete)
	STR.allow_quick_gather = TRUE
	STR.allow_quick_empty = TRUE
	STR.display_numerical_stacking = TRUE
	STR.click_gather = TRUE
	STR.max_combined_w_class = 31
	STR.max_items = 21
	STR.insert_preposition = "in"
	STR.set_holdable(list(/obj/item/paper,
						  /obj/item/ticket_machine_ticket,
						  /obj/item/photo,
						  /obj/item/documents))

/obj/item/folder/pre_attack(atom/target, mob/user, params)
	. = ..()
	if(istype(target, /obj/structure/closet/crate))
		var/obj/structure/closet/crate/C = target
		if(!C.manifest)
			return
		C.tear_manifest(user, src)

/obj/item/folder/update_icon()
	cut_overlays()
	if(contents.len)
		add_overlay("folder_paper")

/obj/item/folder/suicide_act(mob/living/user)
	user.visible_message("<span class='suicide'>[user] begins filing an imaginary death warrant! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return OXYLOSS

/obj/item/folder/update_icon()
	cut_overlays()
	if(contents.len)
		add_overlay("folder_paper")

/obj/item/folder/blue
	desc = "A blue folder."
	icon_state = "folder_blue"

/obj/item/folder/red
	desc = "A red folder."
	icon_state = "folder_red"

/obj/item/folder/yellow
	desc = "A yellow folder."
	icon_state = "folder_yellow"

/obj/item/folder/white
	desc = "A white folder."
	icon_state = "folder_white"

/obj/item/folder/documents
	name = "folder- 'TOP SECRET'"
	desc = "A folder stamped \"Top Secret - Property of Nanotrasen Corporation. Unauthorized distribution is punishable by death.\""

/obj/item/folder/documents/Initialize()
	. = ..()
	new /obj/item/documents/nanotrasen(src)
	update_icon()

/obj/item/folder/syndicate
	icon_state = "folder_syndie"
	name = "folder - 'TOP SECRET'"
	desc = "A folder stamped \"Top Secret - Property of The Syndicate.\""

/obj/item/folder/syndicate/red
	icon_state = "folder_sred"

/obj/item/folder/syndicate/red/Initialize()
	. = ..()
	new /obj/item/documents/syndicate/red(src)
	update_icon()

/obj/item/folder/syndicate/blue
	icon_state = "folder_sblue"

/obj/item/folder/syndicate/blue/Initialize()
	. = ..()
	new /obj/item/documents/syndicate/blue(src)
	update_icon()

/obj/item/folder/syndicate/mining/Initialize()
	. = ..()
	new /obj/item/documents/syndicate/mining(src)
	update_icon()
