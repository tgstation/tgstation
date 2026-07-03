// Blueshield
/obj/item/encryptionkey/heads/blueshield
	name = "blueshield's encryption key"
	icon_state = "cypherkey_centcom"
	channels = list(RADIO_CHANNEL_COMMAND = 1, RADIO_CHANNEL_SECURITY = 1, RADIO_CHANNEL_JUSTICE = 1)
	greyscale_config = /datum/greyscale_config/encryptionkey_centcom
	greyscale_colors = "#1d2657#dca01b"

/obj/item/radio/headset/blueshield
	name = "blueshield's headset"
	desc = "The headset of the guy who keeps the administration alive."
	icon_state = "com_headset"
	worn_icon_state = "com_headset"
	keyslot = /obj/item/encryptionkey/heads/blueshield

/obj/item/radio/headset/blueshield/alt
	name = "blueshield's bowman headset"
	desc = "The headset of the guy who keeps the administration alive. Protects your ears from flashbangs."
	icon_state = "com_headset_alt"
	worn_icon_state = "com_headset_alt"

/obj/item/radio/headset/blueshield/alt/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/wearertargeting/earprotection, list(ITEM_SLOT_EARS))

// Nanotrasen Representative
/obj/item/encryptionkey/heads/nanotrasen_representative
	name = "nanotrasen representative's encryption key"
	icon_state = "cypherkey_centcom"
	channels = list(RADIO_CHANNEL_COMMAND = 1, RADIO_CHANNEL_JUSTICE = 1, RADIO_CHANNEL_SECURITY = 1, RADIO_CHANNEL_ENGINEERING = 0, RADIO_CHANNEL_SCIENCE = 0, RADIO_CHANNEL_MEDICAL = 0, RADIO_CHANNEL_SUPPLY = 0, RADIO_CHANNEL_SERVICE = 0)
	greyscale_config = /datum/greyscale_config/encryptionkey_centcom
	greyscale_colors = "#1d2657#dca01b"

/obj/item/radio/headset/heads/nanotrasen_representative
	name = "nanotrasen representative's headset"
	desc = "The headset of the guy who keeps the administration alive."
	icon_state = "com_headset"
	worn_icon_state = "com_headset"
	keyslot = /obj/item/encryptionkey/heads/nanotrasen_representative

/obj/item/radio/headset/heads/nanotrasen_representative/alt
	name = "nanotrasen representative's bowman headset"
	desc = "The headset of the guy who keeps the administration alive. Protects your ears from flashbangs."
	icon_state = "com_headset_alt"
	worn_icon_state = "com_headset_alt"

/obj/item/radio/headset/heads/nanotrasen_representative/alt/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/wearertargeting/earprotection, list(ITEM_SLOT_EARS))

// Magistrate
/obj/item/encryptionkey/heads/magistrate
	name = "magistrate's encryption key"
	channels = list(RADIO_CHANNEL_COMMAND = 1, RADIO_CHANNEL_SECURITY = 1, RADIO_CHANNEL_JUSTICE = 1)

/obj/item/radio/headset/heads/magistrate
	name = "magistrate's headset"
	desc = "Я веселое описание."
	icon_state = "com_headset"
	worn_icon_state = "com_headset"
	keyslot = /obj/item/encryptionkey/heads/magistrate

/obj/item/radio/headset/heads/magistrate/alt
	name = "magistrate's bowman headset"
	desc = "Я веселое описание. Защищает уши от громкого шума."
	icon_state = "com_headset_alt"
	worn_icon_state = "com_headset_alt"

/obj/item/radio/headset/heads/magistrate/alt/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/wearertargeting/earprotection, list(ITEM_SLOT_EARS))

// Lawyer
/obj/item/encryptionkey/lawyer
	name = "lawyer's encryption key"
	channels = list(RADIO_CHANNEL_SECURITY = 1, RADIO_CHANNEL_JUSTICE = 1)

/obj/item/radio/headset/lawyer
	name = "lawyer's headset"
	desc = "Простой наушник юриста, имеющий доступ к юридическому и каналу безопасности."
	icon_state = "justice_headset"
	worn_icon_state = "justice_headset"
	keyslot = /obj/item/encryptionkey/lawyer
