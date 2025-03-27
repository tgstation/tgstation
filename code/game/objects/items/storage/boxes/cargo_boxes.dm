// This file contains all boxes used by the Cargo department and its purpose on the station.

/obj/item/storage/box/shipping
	name = "box of shipping supplies"
	desc = "Contains several scanners and labelers for shipping things. Wrapping Paper not included."
	illustration = "shipping"

/obj/item/storage/box/shipping/PopulateContents()
	return list(
		/obj/item/dest_tagger,
		/obj/item/universal_scanner,
		/obj/item/stack/package_wrap/small,
		/obj/item/stack/package_wrap/small,
		/obj/item/stack/wrapping_paper/small
	)
