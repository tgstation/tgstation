/obj/item/reagent_containers/cup/beaker/vial
	name = "vial"
	icon = 'monkestation/code/modules/virology/icons/items.dmi'
	desc = "A small glass vial. Can hold up to 25 units."
	icon_state = "vial"
	inhand_icon_state = "beaker"
	custom_materials = list(/datum/material/glass = 250)
	volume = 25
	possible_transfer_amounts = list(5,10,15,25)
	fill_icon_thresholds = list(0, 1, 20, 40, 60, 80, 100)
	fill_icon = 'monkestation/code/modules/virology/icons/items.dmi'

/obj/item/storage/box/vials
	name = "box of vials"

/obj/item/storage/box/vials/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/cup/beaker/vial( src )
