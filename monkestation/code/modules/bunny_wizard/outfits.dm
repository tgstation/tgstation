/datum/outfit/cursed_bunny //for bunny wizards, try not to use this one
	name = "Cursed Bunny"
	uniform = /obj/item/clothing/under/costume/playbunny/color
	suit = /obj/item/clothing/suit/jacket/tailcoat/color
	shoes = /obj/item/clothing/shoes/heels/color
	head = /obj/item/clothing/head/playbunnyears/color
	gloves = /obj/item/clothing/gloves/color/white
	neck = /obj/item/clothing/accessory/bunnytie/color
	r_pocket = /obj/item/toy/cards/deck
	l_pocket = 	/obj/item/reagent_containers/cup/rag
	r_hand = /obj/item/storage/bag/tray
	l_hand = /obj/item/reagent_containers/cup/glass/drinkingglass/filled/champagne

/datum/outfit/cursed_bunny/post_equip(mob/living/carbon/human/equipped_on, visualsOnly=FALSE)
	if(visualsOnly)
		return
	equipped_on.physique = FEMALE
	equipped_on.underwear = "Nude"
	equipped_on.undershirt = "Nude"
	equipped_on.socks = "Nude"
	equipped_on.facial_hairstyle = "Shaved"
	equipped_on.update_body(is_creating = TRUE) //actually update your body
	var/list/no_drops = list()
	no_drops += equipped_on.get_item_by_slot(ITEM_SLOT_FEET)
	no_drops += equipped_on.get_item_by_slot(ITEM_SLOT_ICLOTHING)
	no_drops += equipped_on.get_item_by_slot(ITEM_SLOT_HEAD)
	for(var/obj/item/trait_needed as anything in no_drops)
		ADD_TRAIT(trait_needed, TRAIT_NODROP, CURSED_ITEM_TRAIT(trait_needed.type))

/datum/outfit/cursed_bunny/color
	name "Colorful Cursed Bunny"

/datum/outfit/cursed_bunny/color/post_equip(mob/living/carbon/human/equipped_on, visualsOnly=FALSE)
	if(visualsOnly)
		return
	var/bunny_color = random_color()
	equipped_on.w_uniform?.greyscale_colors = "#[bunny_color]#[bunny_color]#ffffff#87502e"
	equipped_on.wear_suit?.greyscale_colors = "#[bunny_color]"
	equipped_on.head?.greyscale_colors = "#[bunny_color]"
	equipped_on.shoes?.greyscale_colors = "#[bunny_color]"
	equipped_on.w_uniform?.update_greyscale()
	equipped_on.wear_suit?.update_greyscale()
	equipped_on.head?.update_greyscale()
	equipped_on.shoes?.update_greyscale()
	equipped_on.update_worn_undersuit()
	equipped_on.update_worn_oversuit()
	equipped_on.update_worn_shoes()
	equipped_on.update_worn_head()

/datum/outfit/cursed_bunny/syndicate
	name = "Cursed Bunny (Syndicate)"
	uniform = /obj/item/clothing/under/syndicate/syndibunny
	suit = /obj/item/clothing/suit/jacket/tailcoat/syndicate
	head = /obj/item/clothing/head/playbunnyears/syndicate
	neck = /obj/item/clothing/accessory/bunnytie/syndicate
	r_pocket = /obj/item/toy/cards/deck/syndicate

/datum/outfit/plasmaman/cursed_bunny
	name = "Cursed Bunny (Plasmaman)"
	uniform = /obj/item/clothing/under/plasmaman/bunny
	head = /obj/item/clothing/head/helmet/space/plasmaman/bunny
	neck = /obj/item/clothing/neck/bunnytie/color
	belt = /obj/item/tank/internals/plasmaman/belt/full
	r_pocket = /obj/item/toy/cards/deck
	l_pocket = 	/obj/item/reagent_containers/cup/rag
	r_hand = /obj/item/storage/bag/tray
	l_hand = /obj/item/reagent_containers/cup/glass/drinkingglass/filled/champagne
	internals_slot = ITEM_SLOT_BELT

/obj/item/reagent_containers/cup/glass/drinkingglass/filled/champagne
	name = "Champagne"
	list_reagents = list(/datum/reagent/consumable/ethanol/champagne = 50)
