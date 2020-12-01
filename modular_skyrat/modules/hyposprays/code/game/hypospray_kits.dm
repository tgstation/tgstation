/obj/item/storage/hypospraykit
	name = "hypospray kit"
	desc = "It's a kit containing a hypospray and specific treatment chemical-filled vials."
	icon = 'modular_skyrat/modules/hyposprays/icons/hypokits.dmi'
	icon_state = "firstaid-mini"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	throw_speed = 3
	throw_range = 7
	var/empty = FALSE

/obj/item/storage/hypospraykit/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 12
	STR.can_hold = typecacheof(list(
	/obj/item/hypospray/mkii,
	/obj/item/reagent_containers/glass/bottle/vial))

/obj/item/storage/hypospraykit/empty
	desc = "A hypospray kit with general use vials."

/obj/item/storage/hypospraykit/empty/PopulateContents()
	if(empty)
		return
	new /obj/item/hypospray/mkii(src)
	new /obj/item/reagent_containers/glass/bottle/vial/small(src)
	new /obj/item/reagent_containers/glass/bottle/vial/small(src)
	new /obj/item/reagent_containers/glass/bottle/vial/small(src)

/obj/item/storage/hypospraykit/regular
	icon_state = "firstaid-mini"
	desc = "A hypospray kit with general use vials."

/obj/item/storage/hypospraykit/regular/PopulateContents()
	if(empty)
		return
	new /obj/item/hypospray/mkii/tricord(src)
	new /obj/item/reagent_containers/glass/bottle/vial/small/tricord(src)
	new /obj/item/reagent_containers/glass/bottle/vial/small/tricord(src)

/obj/item/storage/hypospraykit/cmo
	name = "deluxe hypospray kit"
	desc = "A kit containing a Deluxe hypospray and Vials."
	icon_state = "tactical-mini"

/obj/item/storage/hypospraykit/cmo/PopulateContents()
	if(empty)
		return
	new /obj/item/hypospray/mkii/CMO(src)
	new /obj/item/reagent_containers/glass/bottle/vial/large/tricord(src)
	new /obj/item/reagent_containers/glass/bottle/vial/large/charcoal(src)
	new /obj/item/reagent_containers/glass/bottle/vial/large/salglu(src)
	new /obj/item/reagent_containers/glass/bottle/vial/large/dexalin(src)
	new /obj/item/reagent_containers/glass/bottle/vial/large/synthflesh(src)

/obj/item/storage/box/vials
	name = "box of hypovials"

/obj/item/storage/box/vials/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/glass/bottle/vial/small( src )
