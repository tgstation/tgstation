/obj/item/storage/bag/folder
	name = "folder"
	desc = "A folder."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "folder"
	w_class = WEIGHT_CLASS_SMALL
	pressure_resistance = 2
	resistance_flags = FLAMMABLE

/obj/item/storage/bag/folder/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_combined_w_class = 31
	STR.max_items = 21
	STR.insert_preposition = "on"
	STR.set_holdable(list(/obj/item/paper,
						  /obj/item/ticket_machine_ticket,
						  /obj/item/photo,
						  /obj/item/documents))

/obj/item/storage/bag/folder/update_icon()
	cut_overlays()
	if(contents.len)
		add_overlay("folder_paper")

/obj/item/storage/bag/folder/Entered()
	. = ..()
	update_icon()

/obj/item/storage/bag/folder/Exited()
	. = ..()
	update_icon()

/obj/item/folder/attackby(obj/item/W, mob/user, params)

/obj/item/storage/bag/folder/suicide_act(mob/living/user)
	user.visible_message("<span class='suicide'>[user] begins filing an imaginary death warrant! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return OXYLOSS

/obj/item/storage/bag/folder/blue
	desc = "A blue folder."
	icon_state = "folder_blue"

/obj/item/storage/bag/folder/red
	desc = "A red folder."
	icon_state = "folder_red"

/obj/item/storage/bag/folder/yellow
	desc = "A yellow folder."
	icon_state = "folder_yellow"

/obj/item/storage/bag/folder/white
	desc = "A white folder."
	icon_state = "folder_white"

/obj/item/storage/bag/folder/documents
	name = "folder - 'TOP SECRET'"
	desc = "A folder stamped \"Top Secret - Property of Nanotrasen Corporation. Unauthorized distribution is punishable by death.\""

/obj/item/storage/bag/folder/documents/PopulateContents()
	. = ..()
	new /obj/item/documents/nanotrasen(src)
	update_icon()

/obj/item/storage/bag/folder/syndicate
	icon_state = "folder_syndie"
	name = "folder - 'TOP SECRET'"
	desc = "A folder stamped \"Top Secret - Property of The Syndicate.\""

/obj/item/storage/bag/folder/syndicate/red
	icon_state = "folder_sred"

/obj/item/storage/bag/folder/syndicate/red/PopulateContents()
	new /obj/item/documents/syndicate/red(src)
	update_icon()

/obj/item/storage/bag/folder/syndicate/blue
	icon_state = "folder_sblue"

/obj/item/storage/bag/folder/syndicate/blue/PopulateContents()
	new /obj/item/documents/syndicate/blue(src)
	update_icon()

/obj/item/storage/bag/folder/syndicate/mining/PopulateContents()
	new /obj/item/documents/syndicate/mining(src)
	update_icon()
