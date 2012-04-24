
/obj/item/device/encryptionkey/
	name = "Standard Encrpytion Key"
	desc = "An encyption key for a radio headset.  Has no special codes in it.  WHY DOES IT EXIST?  ASK NANOTRASEN."
	icon = 'radio.dmi'
	icon_state = "cypherkey"
	item_state = ""
	var/translate_binary = 0
	var/translate_hive = 0
	var/list/channels = list()


/obj/item/device/encryptionkey/New()

/obj/item/device/radio/headset/attackby(obj/item/weapon/W as obj, mob/user as mob)

/obj/item/device/encryptionkey/traitor
	icon_state = "cypherkey"
	channels = list("Syndicate" = 1)
	origin_tech = "syndicate=3"

/obj/item/device/encryptionkey/binary
	icon_state = "cypherkey"
	translate_binary = 1
	origin_tech = "syndicate=3"

/obj/item/device/encryptionkey/headset_sec
	name = "Security Radio Encryption Key"
	desc = "An encyption key for a radio headset.  Contains cypherkeys."
	icon_state = "sec_cypherkey"
	channels = list("Security" = 1)

/obj/item/device/encryptionkey/headset_eng
	name = "Engineering Radio Encryption Key"
	desc = "An encyption key for a radio headset.  Contains cypherkeys."
	icon_state = "eng_cypherkey"
	channels = list("Engineering" = 1)

/obj/item/device/encryptionkey/headset_rob
	name = "Robotics Radio Encryption Key"
	desc = "An encyption key for a radio headset.  Contains cypherkeys."
	icon_state = "rob_cypherkey"
	channels = list("Engineering" = 1, "Science" = 1)

/obj/item/device/encryptionkey/headset_med
	name = "Medical Radio Encryption Key"
	desc = "An encyption key for a radio headset.  Contains cypherkeys."
	icon_state = "med_cypherkey"
	channels = list("Medical" = 1)

/obj/item/device/encryptionkey/headset_sci
	name = "Science Radio Encryption Key"
	desc = "An encyption key for a radio headset.  Contains cypherkeys."
	icon_state = "sci_cypherkey"
	channels = list("Science" = 1)

/obj/item/device/encryptionkey/headset_medsci
	name = "Medical Research Radio Encryption Key"
	desc = "An encyption key for a radio headset.  Contains cypherkeys."
	icon_state = "medsci_cypherkey"
	channels = list("Medical" = 1, "Science" = 1)

/obj/item/device/encryptionkey/headset_com
	name = "Command Radio Encryption Key"
	desc = "An encyption key for a radio headset.  Contains cypherkeys."
	icon_state = "com_cypherkey"
	channels = list("Command" = 1)

/obj/item/device/encryptionkey/heads/captain
	name = "Captain's Encryption Key"
	desc = "An encyption key for a radio headset.  Contains cypherkeys."
	icon_state = "cap_cypherkey"
	channels = list("Command" = 1, "Science" = 0, "Medical" = 0, "Security" = 1, "Engineering" = 0, "Mining" = 0, "Cargo" = 0)

/obj/item/device/encryptionkey/heads/rd
	name = "Research Director's Encryption Key"
	desc = "An encyption key for a radio headset.  Contains cypherkeys."
	icon_state = "rd_cypherkey"
	channels = list("Science" = 1, "Command" = 1)

/obj/item/device/encryptionkey/heads/hos
	name = "Head of Security's Encryption Key"
	desc = "An encyption key for a radio headset.  Contains cypherkeys."
	icon_state = "hos_cypherkey"
	channels = list("Security" = 1, "Command" = 1)

/obj/item/device/encryptionkey/heads/ce
	name = "Chief Engineer's Encryption Key"
	desc = "An encyption key for a radio headset.  Contains cypherkeys."
	icon_state = "ce_cypherkey"
	channels = list("Engineering" = 1, "Command" = 1)

/obj/item/device/encryptionkey/heads/cmo
	name = "Chief Medical Officer's Encryption Key"
	desc = "An encyption key for a radio headset.  Contains cypherkeys."
	icon_state = "cmo_cypherkey"
	channels = list("Medical" = 1, "Command" = 1)

/obj/item/device/encryptionkey/heads/hop
	name = "Head of Personnel's Encryption Key"
	desc = "An encyption key for a radio headset.  Contains cypherkeys."
	icon_state = "hop_cypherkey"
	channels = list("Command" = 1, "Security" = 0, "Cargo" = 1, "Mining" = 0)

/obj/item/device/encryptionkey/headset_mine
	name = "Mining Radio Encryption Key"
	desc = "An encyption key for a radio headset.  Contains cypherkeys."
	icon_state = "mine_cypherkey"
	channels = list("Mining" = 1)

/obj/item/device/encryptionkey/heads/qm
	name = "Quartermaster's Encryption Key"
	desc = "An encyption key for a radio headset.  Contains cypherkeys."
	icon_state = "qm_cypherkey"
	channels = list("Cargo" = 1, "Mining" = 1)

/obj/item/device/encryptionkey/headset_cargo
	name = "Cargo Radio Encryption Key"
	desc = "An encyption key for a radio headset.  Contains cypherkeys."
	icon_state = "cargo_cypherkey"
	channels = list("Cargo" = 1)

/obj/item/device/encryptionkey/nuclear
	channels = list("Nuclear" = 1)
	origin_tech = "syndicate=3"

/obj/item/device/encryptionkey/ert
	name = "NanoTrasen ERT Radio Encryption Key"
	desc = "An encyption key for a radio headset.  Contains cypherkeys."
	channels = list("Response Team" = 1, "Science" = 1, "Command" = 1, "Medical" = 1, "Engineering" = 1, "Security" = 1, "Mining" = 1, "Cargo" = 1,)