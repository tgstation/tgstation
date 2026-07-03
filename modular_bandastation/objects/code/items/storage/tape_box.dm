/obj/item/storage/box/tapes
	name = "tape box"
	desc = "Коробка запасных плёнок для диктофона."

/obj/item/storage/box/tapes/PopulateContents()
	for(var/i in 1 to 6)
		new /obj/item/tape/random(src)
