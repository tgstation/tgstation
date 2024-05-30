/datum/uplink_item/bundles_tc/sandy
	name = "Sandevistan Bundle"
	desc = "A box containing various implants"
	item = /obj/item/storage/box/syndie_kit/sandy
	cost = 12
	purchasable_from = UPLINK_TRAITORS

/obj/item/storage/box/syndie_kit/sandy/PopulateContents()
	new /obj/item/autosurgeon/organ/cyberlink_syndicate(src)
	new /obj/item/autosurgeon/organ/syndicate/sandy(src)


/datum/uplink_item/bundles_tc/mantis
	name = "Mantis Blade Bundle"
	desc = "A box containing various implants"
	item = /obj/item/storage/box/syndie_kit/mantis
	cost = 12
	purchasable_from = UPLINK_TRAITORS

/obj/item/storage/box/syndie_kit/mantis/PopulateContents()
	new /obj/item/autosurgeon/organ/cyberlink_syndicate(src)
	new /obj/item/autosurgeon/organ/syndicate/syndie_mantis(src)
	new /obj/item/autosurgeon/organ/syndicate/syndie_mantis/l(src)

