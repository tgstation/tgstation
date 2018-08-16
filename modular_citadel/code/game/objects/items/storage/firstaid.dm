//help I have no idea what I'm doing

/obj/item/storage/firstaid
	icon = 'modular_citadel/icons/firstaid.dmi'

/obj/item/storage/firstaid/Initialize(mapload)
	. = ..()
	icon_state = pick("[initial(icon_state)]","[initial(icon_state)]2","[initial(icon_state)]3","[initial(icon_state)]4")

/obj/item/storage/firstaid/fire
	icon_state = "burn"

/obj/item/storage/firstaid/fire/Initialize(mapload)
	. = ..()
	icon_state = pick("[initial(icon_state)]","[initial(icon_state)]2","[initial(icon_state)]3","[initial(icon_state)]4")

/obj/item/storage/firstaid/toxin
	icon_state = "toxin"

/obj/item/storage/firstaid/toxin/Initialize(mapload)
	. = ..()
	icon_state = pick("[initial(icon_state)]","[initial(icon_state)]2","[initial(icon_state)]3","[initial(icon_state)]4")

/obj/item/storage/firstaid/o2
	icon_state = "oxy"

/obj/item/storage/firstaid/tactical
	icon_state = "tactical"

//hijacking the minature first aids for hypospray boxes. <3
/obj/item/storage/hypospraykit
	name = "hypospray kit"
	desc = "It's a kit containing a hypospray and specific treatment chemical-filled vials."
	icon = 'modular_citadel/icons/firstaid.dmi'
	icon_state = "firstaid-mini"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	throw_speed = 3
	throw_range = 7
	var/empty = FALSE
	item_state = "firstaid"

/obj/item/storage/hypospraykit/ComponentInitialize()
	. = ..()
	GET_COMPONENT(STR, /datum/component/storage)
	STR.max_w_class = WEIGHT_CLASS_SMALL
	STR.max_combined_w_class = 5
	STR.max_items = 5
	STR.cant_hold = typecacheof(list(/obj/item/disk/nuclear))

/obj/item/storage/hypospraykit/regular
	icon_state = "firstaid-mini"
	desc = "A hypospray kit with general use vials."

/obj/item/storage/hypospraykit/regular/PopulateContents()
	if(empty)
		return
	new /obj/item/hypospray/mkii/tricord(src)
	new /obj/item/reagent_containers/glass/bottle/vial/small/preloaded/tricord(src)
	new /obj/item/reagent_containers/glass/bottle/vial/small/preloaded/tricord(src)

/obj/item/storage/hypospraykit/fire
	name = "burn treatment hypospray kit"
	desc = "A specialized hypospray kit for burn treatments. Apply with sass."
	icon_state = "burn-mini"
	item_state = "firstaid-ointment"

/obj/item/storage/hypospraykit/fire/PopulateContents()
	if(empty)
		return
	new /obj/item/hypospray/mkii/burn(src)
	new /obj/item/reagent_containers/glass/bottle/vial/small/preloaded/kelotane(src)
	new /obj/item/reagent_containers/glass/bottle/vial/small/preloaded/kelotane(src)

/obj/item/storage/hypospraykit/toxin
	name = "toxin treatment hypospray kit"
	icon_state = "toxin-mini"
	item_state = "firstaid-toxin"

/obj/item/storage/hypospraykit/toxin/PopulateContents()
	if(empty)
		return
	new /obj/item/hypospray/mkii/toxin(src)
	new /obj/item/reagent_containers/glass/bottle/vial/small/preloaded/antitoxin(src)
	new /obj/item/reagent_containers/glass/bottle/vial/small/preloaded/antitoxin(src)

/obj/item/storage/hypospraykit/o2
	name = "oxygen deprivation hypospray kit"
	icon_state = "oxy-mini"
	item_state = "firstaid-o2"

/obj/item/storage/hypospraykit/o2/PopulateContents()
	if(empty)
		return
	new /obj/item/hypospray/mkii/oxygen(src)
	new /obj/item/reagent_containers/glass/bottle/vial/small/preloaded/dexalin(src)
	new /obj/item/reagent_containers/glass/bottle/vial/small/preloaded/dexalin(src)

/obj/item/storage/hypospraykit/brute
	name = "brute trauma hypospray kit"
	icon_state = "brute-mini"
	item_state = "firstaid-brute"

/obj/item/storage/hypospraykit/brute/PopulateContents()
	if(empty)
		return
	new /obj/item/hypospray/mkii/brute(src)
	new /obj/item/reagent_containers/glass/bottle/vial/small/preloaded/bicaridine(src)
	new /obj/item/reagent_containers/glass/bottle/vial/small/preloaded/bicaridine(src)

/obj/item/storage/hypospraykit/tactical
	name = "combat hypospray kit"
	desc = "A hypospray kit best suited for combat situations."
	icon_state = "tactical-mini"

/obj/item/storage/hypospraykit/tactical/PopulateContents()
	if(empty)
		return
	new /obj/item/defibrillator/compact/combat/loaded(src)
	new /obj/item/hypospray/mkii/CMO/combat(src)
	new /obj/item/reagent_containers/glass/bottle/vial/large/preloaded/combat(src)
	new /obj/item/reagent_containers/glass/bottle/vial/large/preloaded/combat(src)

/obj/item/storage/hypospraykit/cmo
	name = "deluxe hypospray kit"
	desc = "A kit containing a Deluxe hypospray and Vials."
	icon_state = "tactical-mini"

/obj/item/storage/hypospraykit/cmo/ComponentInitialize()
	. = ..()
	GET_COMPONENT(STR, /datum/component/storage)
	STR.max_w_class = WEIGHT_CLASS_SMALL
	STR.max_combined_w_class = 6
	STR.max_items = 6
	STR.cant_hold = typecacheof(list(/obj/item/disk/nuclear))

/obj/item/storage/hypospraykit/cmo/PopulateContents()
	if(empty)
		return
	new /obj/item/hypospray/mkii/CMO(src)
	new /obj/item/reagent_containers/glass/bottle/vial/large/preloaded/tricord(src)
	new /obj/item/reagent_containers/glass/bottle/vial/large/preloaded/charcoal(src)
	new /obj/item/reagent_containers/glass/bottle/vial/large/preloaded/salglu(src)
	new /obj/item/reagent_containers/glass/bottle/vial/large/preloaded/dexalin(src)
	new /obj/item/reagent_containers/glass/bottle/vial/large/preloaded/synthflesh(src)

/obj/item/storage/box/vials
	name = "box of hypovials"

/obj/item/storage/box/vials/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/glass/bottle/vial/small( src )
