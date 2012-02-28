
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

/obj/item/device/encryptionkey/attackby(obj/item/weapon/W as obj, mob/user as mob)

/obj/item/device/encryptionkey/traitor
	channels = list("Syndicate" = 1)
	origin_tech = "syndicate=3"

/obj/item/device/encryptionkey/binary
	translate_binary = 1
	origin_tech = "syndicate=3"

/obj/item/device/encryptionkey/headset_sec
	name = "Security Radio Encryption Key"
	desc = "An encyption key for a radio headset.  Contains cypherkeys."
	channels = list("Security" = 1)

/obj/item/device/encryptionkey/headset_eng
	name = "Engineering Radio Encryption Key"
	desc = "An encyption key for a radio headset.  Contains cypherkeys."
	channels = list("Engineering" = 1)

/obj/item/device/encryptionkey/headset_rob
	name = "Robotics Radio Encryption Key"
	desc = "An encyption key for a radio headset.  Contains cypherkeys."
	channels = list("Engineering" = 1, "Science" = 1)

/obj/item/device/encryptionkey/headset_med
	name = "Medical Radio Encryption Key"
	desc = "An encyption key for a radio headset.  Contains cypherkeys."
	channels = list("Medical" = 1)

/obj/item/device/encryptionkey/headset_sci
	name = "Science Radio Encryption Key"
	desc = "An encyption key for a radio headset.  Contains cypherkeys."
	channels = list("Science" = 1)

/obj/item/device/encryptionkey/headset_medsci
	name = "Medical Research Radio Encryption Key"
	desc = "An encyption key for a radio headset.  Contains cypherkeys."
	channels = list("Medical" = 1, "Science" = 1)

/obj/item/device/encryptionkey/headset_com
	name = "Command Radio Encryption Key"
	desc = "An encyption key for a radio headset.  Contains cypherkeys."
	channels = list("Command" = 1)

/obj/item/device/encryptionkey/heads/captain
	name = "Captain's Encryption Key"
	desc = "An encyption key for a radio headset.  Contains cypherkeys."
	channels = list("Command" = 1, "Science" = 0, "Medical" = 0, "Security" = 1, "Engineering" = 0, "Mining" = 0, "Cargo" = 0)

/obj/item/device/encryptionkey/heads/rd
	name = "Research Director's Encryption Key"
	desc = "An encyption key for a radio headset.  Contains cypherkeys."
	channels = list("Science" = 1, "Command" = 1)

/obj/item/device/encryptionkey/heads/hos
	name = "Head of Security's Encryption Key"
	desc = "An encyption key for a radio headset.  Contains cypherkeys."
	channels = list("Security" = 1, "Command" = 1)

/obj/item/device/encryptionkey/heads/ce
	name = "Chief Engineer's Encryption Key"
	desc = "An encyption key for a radio headset.  Contains cypherkeys."
	channels = list("Engineering" = 1, "Command" = 1)

/obj/item/device/encryptionkey/heads/cmo
	name = "Chief Medical Officer's Encryption Key"
	desc = "An encyption key for a radio headset.  Contains cypherkeys."
	channels = list("Medical" = 1, "Command" = 1)

/obj/item/device/encryptionkey/heads/hop
	name = "Head of Personnel's Encryption Key"
	desc = "An encyption key for a radio headset.  Contains cypherkeys."
	channels = list("Command" = 1, "Security" = 0, "Cargo" = 1, "Mining" = 0)

/obj/item/device/encryptionkey/headset_mine
	name = "Mining Radio Encryption Key"
	desc = "An encyption key for a radio headset.  Contains cypherkeys."
	channels = list("Mining" = 1)

/obj/item/device/encryptionkey/heads/qm
	name = "Quartermaster's Encryption Key"
	desc = "An encyption key for a radio headset.  Contains cypherkeys."
	channels = list("Cargo" = 1, "Mining" = 1)

/obj/item/device/encryptionkey/headset_cargo
	name = "Cargo Radio Encryption Key"
	desc = "An encyption key for a radio headset.  Contains cypherkeys."
	channels = list("Cargo" = 1)