/datum/export/gear

/datum/export/gear/sec_helmet
	cost = CARGO_CRATE_VALUE * 0.5
	unit_name = "helmet"
	export_types = list(/obj/item/clothing/head/helmet/sec)

/datum/export/gear/sec_armor
	cost = CARGO_CRATE_VALUE * 0.5
	unit_name = "armor vest"
	export_types = list(/obj/item/clothing/suit/armor/vest)

/datum/export/gear/riot_shield
	cost = CARGO_CRATE_VALUE * 0.5
	unit_name = "riot shield"
	export_types = list(/obj/item/shield/riot)


/datum/export/gear/mask/breath
	cost = CARGO_CRATE_VALUE * 0.01
	unit_name = "breath mask"
	export_types = list(/obj/item/clothing/mask/breath)

/datum/export/gear/mask/gas
	cost = CARGO_CRATE_VALUE * 0.05
	unit_name = "gas mask"
	export_types = list(/obj/item/clothing/mask/gas)
	include_subtypes = FALSE


/datum/export/gear/space/helmet
	cost = CARGO_CRATE_VALUE * 0.15
	unit_name = "space helmet"
	export_types = list(/obj/item/clothing/head/helmet/space, /obj/item/clothing/head/helmet/space/eva, /obj/item/clothing/head/helmet/space/nasavoid)
	include_subtypes = FALSE

/datum/export/gear/space/suit
	cost = CARGO_CRATE_VALUE * 0.3
	unit_name = "space suit"
	export_types = list(/obj/item/clothing/suit/space, /obj/item/clothing/suit/space/eva, /obj/item/clothing/suit/space/nasavoid)
	include_subtypes = FALSE


/datum/export/gear/space/syndiehelmet
	cost = CARGO_CRATE_VALUE * 0.3
	unit_name = "Syndicate space helmet"
	export_types = list(/obj/item/clothing/head/helmet/space/syndicate)

/datum/export/gear/space/syndiesuit
	cost = CARGO_CRATE_VALUE * 0.6
	unit_name = "Syndicate space suit"
	export_types = list(/obj/item/clothing/suit/space/syndicate)


/datum/export/gear/radhelmet
	cost = CARGO_CRATE_VALUE * 0.1
	unit_name = "radsuit hood"
	export_types = list(/obj/item/clothing/head/radiation)

/datum/export/gear/radsuit
	cost = CARGO_CRATE_VALUE * 0.2
	unit_name = "radsuit"
	export_types = list(/obj/item/clothing/suit/utility/radiation)

/datum/export/gear/biohood
	cost = CARGO_CRATE_VALUE * 0.1
	unit_name = "biosuit hood"
	export_types = list(/obj/item/clothing/head/bio_hood)

/datum/export/gear/biosuit
	cost = CARGO_CRATE_VALUE * 0.2
	unit_name = "biosuit"
	export_types = list(/obj/item/clothing/suit/bio_suit)

/datum/export/gear/bombhelmet
	cost = CARGO_CRATE_VALUE * 0.1
	unit_name = "bomb suit hood"
	export_types = list(/obj/item/clothing/head/bomb_hood)

/datum/export/gear/bombsuit
	cost = CARGO_CRATE_VALUE * 0.2
	unit_name = "bomb suit"
	export_types = list(/obj/item/clothing/suit/utility/bomb_suit)

/datum/export/gear/lizardboots
	cost = CARGO_CRATE_VALUE * 0.7
	unit_name = "lizard skin boots"
	export_types = list(/obj/item/clothing/shoes/cowboy/lizard)
	include_subtypes = FALSE

/datum/export/gear/lizardmasterwork
	cost = CARGO_CRATE_VALUE * 2
	unit_name = "Hugs-the-Feet lizard boots"
	export_types = list(/obj/item/clothing/shoes/cowboy/lizard/masterwork)

/datum/export/gear/bilton
	cost = CARGO_CRATE_VALUE * 5
	unit_name = "bilton wrangler boots"
	export_types = list(/obj/item/clothing/shoes/cowboy/fancy)

/datum/export/gear/ebonydie
	cost = CARGO_CRATE_VALUE
	unit_name = "ebony die"
	export_types = list(/obj/item/dice/d6/ebony)

