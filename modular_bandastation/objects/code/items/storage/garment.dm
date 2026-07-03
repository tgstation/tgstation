/obj/item/storage/bag/garment/blueshield
	name = "blueshield's garment bag"
	desc = "A bag for storing extra clothes and shoes. This one belongs to the blueshield."

/obj/item/storage/bag/garment/blueshield/PopulateContents()
	var/list/items_inside = list(
		/obj/item/clothing/suit/hooded/wintercoat/blueshield = 1,
		/obj/item/clothing/suit/armor/vest/blueshield = 1,
		/obj/item/clothing/suit/armor/vest/blueshield_jacket = 1,
		/obj/item/clothing/head/beret/blueshield = 1,
		/obj/item/clothing/head/beret/blueshield/navy = 1,
		/obj/item/clothing/mask/gas/sechailer = 1,
		/obj/item/clothing/under/rank/blueshield = 1,
		/obj/item/clothing/under/blueshield/skirt/blue = 1,
		/obj/item/clothing/under/blueshield/skirt/black = 1,
		/obj/item/clothing/under/rank/blueshield/skirt = 1,
		/obj/item/clothing/under/rank/blueshield/casual = 1,
		/obj/item/clothing/under/rank/blueshield/casual/skirt = 1,
		/obj/item/clothing/under/rank/blueshield/turtleneck = 1,
		/obj/item/clothing/under/rank/blueshield/turtleneck/skirt = 1,
		/obj/item/clothing/under/rank/blueshield/formal = 1,
		/obj/item/clothing/neck/cloak/blueshield = 1,
		/obj/item/clothing/glasses/sunglasses = 1,
		/obj/item/clothing/glasses/hud/health/sunglasses = 1,
		/obj/item/clothing/shoes/jackboots/sec = 1,
		/obj/item/clothing/shoes/laceup = 1,
	)
	generate_items_inside(items_inside, src)

/obj/item/storage/bag/garment/nanotrasen_representative
	name = "nanotrasen representative's garment bag"
	desc = "A bag for storing extra clothes and shoes. This one belongs to the nanotrasen representative."

/obj/item/storage/bag/garment/nanotrasen_representative/PopulateContents()
	var/list/items_inside = list(
		/obj/item/clothing/glasses/hud/security/sunglasses = 1,
		/obj/item/clothing/glasses/sunglasses = 1,
		/obj/item/clothing/gloves/color/white = 1,
		/obj/item/clothing/shoes/laceup = 1,
		/obj/item/clothing/head/hats/nanotrasen_representative = 1,
		/obj/item/clothing/under/rank/nanotrasen_representative = 1,
		/obj/item/clothing/under/rank/nanotrasen_representative/skirt = 1,
		/obj/item/clothing/under/rank/nanotrasen_representative/formal = 1,
		/obj/item/clothing/under/suit/nanotrasen_representative_female_suit = 1,
	)
	generate_items_inside(items_inside, src)


/obj/item/storage/bag/garment/magistrate
	name = "magistrate's garment bag"
	desc = "A bag for storing extra clothes and shoes. This one belongs to the magistrate."

/obj/item/storage/bag/garment/magistrate/PopulateContents()
	var/list/items_inside = list(
		/obj/item/clothing/under/rank/magistrate = 1,
		/obj/item/clothing/under/rank/magistrate/skirt = 1,
		/obj/item/clothing/under/rank/magistrate/formal = 1,
		/obj/item/clothing/suit/magirobe = 1,
		/obj/item/clothing/suit/magistrate_jacket = 1,
		/obj/item/clothing/shoes/laceup = 1,
		/obj/item/clothing/glasses/sunglasses = 1,
		/obj/item/clothing/gloves/color/white = 1,
	)
	generate_items_inside(items_inside, src)
