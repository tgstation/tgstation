GLOBAL_LIST_INIT(store_pockets, generate_store_items(/datum/store_item/pocket))

/datum/store_item/pocket
	category = LOADOUT_ITEM_MISC

/datum/store_item/pocket/wallet
	name = "Wallet"
	item_path = /obj/item/storage/wallet

/datum/store_item/pocket/gum_pack_nicotine
	name = "Pack of Nicotine Gum"
	item_path = /obj/item/storage/box/gum/nicotine

/datum/store_item/pocket/gum_pack_hp
	name = "Pack of HP+ Gum"
	item_path = /obj/item/storage/box/gum/happiness

/*
*	LIPSTICK
*/

/datum/store_item/pocket/lipstick_black
	name = "Black Lipstick"
	item_path = /obj/item/lipstick/black

/datum/store_item/pocket/lipstick_jade
	name = "Jade Lipstick"
	item_path = /obj/item/lipstick/jade

/datum/store_item/pocket/lipstick_purple
	name = "Purple Lipstick"
	item_path = /obj/item/lipstick/purple

/datum/store_item/pocket/lipstick_red
	name = "Red Lipstick"
	item_path = /obj/item/lipstick

/*
*	MISC
*/

/datum/store_item/pocket/rag
	name = "Rag"
	item_path = /obj/item/reagent_containers/cup/rag

/datum/store_item/pocket/razor
	name = "Razor"
	item_path = /obj/item/razor

/datum/store_item/pocket/matches
	name = "Matchbox"
	item_path = /obj/item/storage/box/matches

/datum/store_item/pocket/cheaplighter
	name = "Cheap Lighter"
	item_path = /obj/item/lighter/greyscale

/datum/store_item/pocket/zippolighter
	name = "Zippo Lighter"
	item_path = /obj/item/lighter

/datum/store_item/pocket/zippolighter/bright
	name = "Illuminative Lighter"
	item_path = /obj/item/lighter/bright
	item_cost = 2500

/datum/store_item/pocket/zippolighter/mime
	name = "Mime's Lighter"
	item_path = /obj/item/lighter/mime
	item_cost = 2500

/datum/store_item/pocket/zippolighter/skull
	name = "Skull Zippo Lighter"
	item_path = /obj/item/lighter/skull
	item_cost = 2500

/datum/store_item/pocket/paicard
	name = "Personal AI Device"
	item_path = /obj/item/pai_card
	item_cost = 7500

/datum/store_item/pocket/cigarettes
	name = "Cigarette Pack"
	item_path = /obj/item/storage/fancy/cigarettes

/datum/store_item/pocket/cigar //smoking is bad mkay
	name = "Cigar"
	item_path = /obj/item/clothing/mask/cigarette/cigar
	item_cost = 2500

/datum/store_item/pocket/flask
	name = "Flask"
	item_path = /obj/item/reagent_containers/cup/glass/flask
	item_cost = 3000

/datum/store_item/pocket/multipen
	name = "Multicolored Pen"
	item_path = /obj/item/pen/fourcolor

/datum/store_item/pocket/fountainpen
	name = "Fancy Pen"
	item_path = /obj/item/pen/fountain

/datum/store_item/pocket/tapeplayer
	name = "Universal Recorder"
	item_path = /obj/item/taperecorder
	item_cost = 3000

/datum/store_item/pocket/tape
	name = "Spare Cassette Tape"
	item_path = /obj/item/tape/random
	item_cost = 2500

/datum/store_item/pocket/newspaper
	name = "Newspaper"
	item_path = /obj/item/newspaper

/datum/store_item/pocket/pet_beacon
	name = "Pet Delivery Beacon"
	item_path = /obj/item/choice_beacon/pet
