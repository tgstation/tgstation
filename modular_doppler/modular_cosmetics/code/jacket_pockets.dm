/*(:`--..___...-''``-._             |`. _       this module allows us to to add pockets to garments we make either with an individualized \
  	```--...--.      . `-..__      .`/   _\   / proc or by making a child of an item that already has that proc attached. it's intended for \
            	`\     '       ```--`.    />    suit slot clothes!
            	: :   :               `:`-'
            	 `.:.  `.._--...___     ``--...__
                	``--..,)       ```----....__,)  this ascii cat was credited to Felix Lee!*/


//the pockets themselves

/datum/storage/pockets/jacket
	max_slots = 2
	max_total_storage = 5

/datum/storage/pockets/jacket/New(
	atom/parent,
	max_slots,
	max_specific_storage,
	max_total_storage,
)
	. = ..()
	set_holdable(list(
		/obj/item/,
		))

/datum/storage/pockets/jacket/jumbo
	max_specific_storage = WEIGHT_CLASS_NORMAL
	max_slots = 3
	max_total_storage = 6

/datum/storage/pockets/jacket/jumbo/New(
	atom/parent,
	max_slots,
	max_specific_storage,
	max_total_storage,
)
	. = ..()
	set_holdable(list(
		/obj/item/,
		))

//overrides for existing tg jackets to get pockets and neckslotability

/obj/item/clothing/suit/jacket //we give all jackets neckslotability and basic pockets and override individually when we want jumbo pockets or no pockets
	slot_flags = ITEM_SLOT_OCLOTHING|ITEM_SLOT_NECK
/obj/item/clothing/suit/jacket/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/pockets/jacket)

/obj/item/clothing/suit/jacket/oversized/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/pockets/jacket/jumbo)

/obj/item/clothing/suit/jacket/bomber/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/pockets/jacket/jumbo)

/obj/item/clothing/suit/jacket/miljacket/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/pockets/jacket/jumbo)

/obj/item/clothing/suit/jacket/letterman_syndie/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/pockets/jacket/jumbo)

// suit/toggle objects are basically deprecated but there's a few desirable sprites. we override individually
// because otherwise we would put pockets on suspenders

/obj/item/clothing/suit/toggle/cargo_tech
	slot_flags = ITEM_SLOT_OCLOTHING|ITEM_SLOT_NECK
/obj/item/clothing/suit/toggle/cargo_tech/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/pockets/jacket/jumbo)

/obj/item/clothing/suit/toggle/chef
	slot_flags = ITEM_SLOT_OCLOTHING|ITEM_SLOT_NECK
/obj/item/clothing/suit/toggle/chef/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/pockets/jacket/jumbo)

/obj/item/clothing/suit/toggle/labcoat
	slot_flags = ITEM_SLOT_OCLOTHING|ITEM_SLOT_NECK
/obj/item/clothing/suit/toggle/labcoat/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/pockets/jacket/jumbo)

/obj/item/clothing/suit/toggle/lawyer
	slot_flags = ITEM_SLOT_OCLOTHING|ITEM_SLOT_NECK
/obj/item/clothing/suit/toggle/lawyer/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/pockets/jacket/jumbo)

// some wintercoats come with pretty significant armor, so we only give them pockets and not neckslots to stave off a meta

/obj/item/clothing/suit/hooded/wintercoat/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/pockets/jacket/jumbo)

// most costumes don't have pockets, but neckslotability is probably fine.

/obj/item/clothing/suit/costume
	slot_flags = ITEM_SLOT_OCLOTHING|ITEM_SLOT_NECK

