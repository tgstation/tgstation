/obj/item/storage/box/id_stickers
	name = "ID stickers box"
	desc = "Коробка с кучкой наклеек на ID карту."
	icon = 'modular_bandastation/objects/icons/obj/storage/box.dmi'
	icon_state = "id_stickers_box"
	illustration = "id_stickers_box_label"

/obj/item/storage/box/id_stickers/PopulateContents()
	var/static/list/id_sticker_subtypes = subtypesof(/obj/item/id_sticker)

	var/list/items_inside = list()
	for(var/i in 1 to 3)
		items_inside[pick(id_sticker_subtypes)] += 1
	generate_items_inside(items_inside, src)
