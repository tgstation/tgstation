/obj/item/storage/bag/garment/brig_physician
	name = "brig physician's garment bag"
	desc = "A bag for storing extra clothes and shoes. This one belongs to the brig physician."

/obj/item/storage/bag/garment/brig_physician/PopulateContents()
	new /obj/item/clothing/under/rank/security/brig_physician(src)
	new /obj/item/clothing/under/rank/security/brig_physician/skirt(src)
	new /obj/item/clothing/under/rank/security/scrubs/sec(src)
	new /obj/item/clothing/head/utility/surgerycap/sec(src)
	new /obj/item/clothing/suit/toggle/labcoat/brig_physician(src)
	new /obj/item/clothing/shoes/sneakers/secred(src)
	new /obj/item/clothing/gloves/latex/nitrile(src)

