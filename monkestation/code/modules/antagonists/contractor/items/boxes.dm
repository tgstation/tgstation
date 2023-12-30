/obj/item/storage/box/contractor/fulton_extraction
	name = "Fulton Extraction Kit"
	icon_state = "syndiebox"
	illustration = "writing_syndie"

/obj/item/storage/box/contractor/fulton_extraction/PopulateContents()
	new /obj/item/extraction_pack/contractor(src)
	generate_items_inside(list(/obj/item/fulton_core = 3), src)
