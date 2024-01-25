/datum/armor/lootbox_clothing
	melee = 0
	bullet = 0
	laser = 0
	energy = 0
	bomb = 0
	bio = 10 //these are all pretty standard so they should be fine
	fire = 30
	acid = 30
	wound = 0

/obj/item/clothing/head/soft/fishing_hat
	///Do we add the skill reward element to this or not
	var/add_element = TRUE

/obj/item/clothing/head/soft/fishing_hat/lootbox
	name = "fishing hat"
	add_element = FALSE

//versions of clothing with low armor to get given by lootboxes
/obj/item/clothing/head/beanie/durathread/lootbox/Initialize(mapload)
	. = ..()
	set_armor(/datum/armor/lootbox_clothing)

/obj/item/clothing/head/beret/durathread/lootbox/Initialize(mapload)
	. = ..()
	set_armor(/datum/armor/lootbox_clothing)

/obj/item/clothing/head/beret/sec/lootbox/Initialize(mapload)
	. = ..()
	set_armor(/datum/armor/lootbox_clothing)

/obj/item/clothing/head/caphat/beret/lootbox/Initialize(mapload)
	. = ..()
	set_armor(/datum/armor/lootbox_clothing)

/obj/item/clothing/head/cowboy/black/lootbox/Initialize(mapload)
	. = ..()
	set_armor(/datum/armor/lootbox_clothing)

/obj/item/clothing/head/cowboy/bounty/lootbox/Initialize(mapload)
	. = ..()
	set_armor(/datum/armor/lootbox_clothing)

/obj/item/clothing/head/cowboy/brown/lootbox/Initialize(mapload)
	. = ..()
	set_armor(/datum/armor/lootbox_clothing)

/obj/item/clothing/head/cowboy/grey/lootbox/Initialize(mapload)
	. = ..()
	set_armor(/datum/armor/lootbox_clothing)

/obj/item/clothing/head/cowboy/red/lootbox/Initialize(mapload)
	. = ..()
	set_armor(/datum/armor/lootbox_clothing)

/obj/item/clothing/head/cowboy/white/lootbox/Initialize(mapload)
	. = ..()
	set_armor(/datum/armor/lootbox_clothing)

/obj/item/clothing/head/guardmanhelmet/lootbox/Initialize(mapload)
	. = ..()
	set_armor(/datum/armor/lootbox_clothing)

/obj/item/clothing/head/hats/caphat/lootbox/Initialize(mapload)
	. = ..()
	set_armor(/datum/armor/lootbox_clothing)

/obj/item/clothing/head/hats/caphat/parade/lootbox/Initialize(mapload)
	. = ..()
	set_armor(/datum/armor/lootbox_clothing)

/obj/item/clothing/head/hats/centcom_cap/lootbox/Initialize(mapload)
	. = ..()
	set_armor(/datum/armor/lootbox_clothing)

/obj/item/clothing/head/hats/centhat/lootbox/Initialize(mapload)
	. = ..()
	set_armor(/datum/armor/lootbox_clothing)

/obj/item/clothing/head/hats/coordinator/lootbox/Initialize(mapload)
	. = ..()
	set_armor(/datum/armor/lootbox_clothing)

/obj/item/clothing/head/hats/hopcap/lootbox/Initialize(mapload)
	. = ..()
	set_armor(/datum/armor/lootbox_clothing)

/obj/item/clothing/head/hats/hos/beret/lootbox/Initialize(mapload)
	. = ..()
	set_armor(/datum/armor/lootbox_clothing)

/obj/item/clothing/head/hats/hos/cap/lootbox/Initialize(mapload)
	. = ..()
	set_armor(/datum/armor/lootbox_clothing)

/obj/item/clothing/head/hats/hos/shako/lootbox/Initialize(mapload)
	. = ..()
	set_armor(/datum/armor/lootbox_clothing)

/obj/item/clothing/head/hats/warden/lootbox/Initialize(mapload)
	. = ..()
	set_armor(/datum/armor/lootbox_clothing)

/obj/item/clothing/head/hats/warden/drill/lootbox/Initialize(mapload)
	. = ..()
	set_armor(/datum/armor/lootbox_clothing)

/obj/item/clothing/head/hats/warden/red/lootbox/Initialize(mapload)
	. = ..()
	set_armor(/datum/armor/lootbox_clothing)

/obj/item/clothing/head/nanotrasen_consultant/hubert/lootbox/Initialize(mapload)
	. = ..()
	set_armor(/datum/armor/lootbox_clothing)

/obj/item/clothing/head/recruiter_cap/lootbox/Initialize(mapload)
	. = ..()
	set_armor(/datum/armor/lootbox_clothing)

/obj/item/clothing/head/soft/sec/lootbox/Initialize(mapload)
	. = ..()
	set_armor(/datum/armor/lootbox_clothing)

/obj/item/clothing/head/utility/hardhat/pumpkinhead/lootbox/Initialize(mapload)
	. = ..()
	set_armor(/datum/armor/lootbox_clothing)

/obj/item/clothing/head/utility/hardhat/pumpkinhead/blumpkin/lootbox/Initialize(mapload)
	. = ..()
	set_armor(/datum/armor/lootbox_clothing)

/obj/item/clothing/head/wizard/lootbox/Initialize(mapload)
	. = ..()
	set_armor(/datum/armor/lootbox_clothing)

/obj/item/clothing/head/wizard/black/lootbox/Initialize(mapload)
	. = ..()
	set_armor(/datum/armor/lootbox_clothing)

/obj/item/clothing/head/wizard/marisa/lootbox/Initialize(mapload)
	. = ..()
	set_armor(/datum/armor/lootbox_clothing)
