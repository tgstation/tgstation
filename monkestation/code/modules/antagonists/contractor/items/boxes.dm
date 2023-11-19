/obj/item/storage/box/contractor/fulton_extraction
	name = "Fulton Extraction Kit"
	icon_state = "syndiebox"
	illustration = "writing_syndie"

/obj/item/storage/box/contractor/fulton_extraction/PopulateContents()
	new /obj/item/extraction_pack/contractor(src)
	new /obj/item/fulton_core(src)
