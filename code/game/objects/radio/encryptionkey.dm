
/obj/item/device/radio/headset/encryptionkey/
	name = "Standard Encrpytion Key"
	desc = "An encyption key for a radio headset.  Has no special codes in it.  WHY DOES IT EXIST?  ASK NANOTRASEN."
	icon_state = "cypherkey"
	item_state = ""

/obj/item/device/radio/headset/encryptionkey/New()

/obj/item/device/radio/headset/attackby(obj/item/weapon/W as obj, mob/user as mob)

/obj/item/device/radio/headset/encryptionkey/traitor
	channels = list("Syndicate" = 1)
	origin_tech = "syndicate=3"

/obj/item/device/radio/headset/encryptionkey/binary
	translate_binary = 1
	origin_tech = "syndicate=3"

/obj/item/device/radio/headset/encryptionkey/headset_sec
	name = "Security Radio Encryption Key"
	desc = "An encyption key for a radio headset.  Contains cypherkeys."
	channels = list("Security" = 1)

/obj/item/device/radio/headset/encryptionkey/headset_eng
	name = "Engineering Radio Encryption Key"
	desc = "An encyption key for a radio headset.  Contains cypherkeys."
	channels = list("Engineering" = 1)

/obj/item/device/radio/headset/encryptionkey/headset_rob
	name = "Robotics Radio Encryption Key"
	desc = "An encyption key for a radio headset.  Contains cypherkeys."
	channels = list("Engineering" = 1, "Science" = 1)

/obj/item/device/radio/headset/encryptionkey/headset_med
	name = "Medical Radio Encryption Key"
	desc = "An encyption key for a radio headset.  Contains cypherkeys."
	channels = list("Medical" = 1)

/obj/item/device/radio/headset/encryptionkey/headset_sci
	name = "Science Radio Encryption Key"
	desc = "An encyption key for a radio headset.  Contains cypherkeys."
	channels = list("Science" = 1)

/obj/item/device/radio/headset/encryptionkey/headset_medsci
	name = "Medical Research Radio Encryption Key"
	desc = "An encyption key for a radio headset.  Contains cypherkeys."
	channels = list("Medical" = 1, "Science" = 1)

/obj/item/device/radio/headset/encryptionkey/headset_com
	name = "Command Radio Encryption Key"
	desc = "An encyption key for a radio headset.  Contains cypherkeys."
	channels = list("Command" = 1)

/obj/item/device/radio/headset/encryptionkey/heads/captain
	name = "Captain's Encryption Key"
	desc = "An encyption key for a radio headset.  Contains cypherkeys."
	channels = list("Command" = 1, "Science" = 0, "Medical" = 0, "Security" = 1, "Engineering" = 0, "Mining" = 0, "Cargo" = 0)

/obj/item/device/radio/headset/encryptionkey/heads/rd
	name = "Research Director's Encryption Key"
	desc = "An encyption key for a radio headset.  Contains cypherkeys."
	channels = list("Science" = 1, "Command" = 1)

/obj/item/device/radio/headset/encryptionkey/heads/hos
	name = "Head of Security's Encryption Key"
	desc = "An encyption key for a radio headset.  Contains cypherkeys."
	channels = list("Security" = 1, "Command" = 1)

/obj/item/device/radio/headset/encryptionkey/heads/ce
	name = "Chief Engineer's Encryption Key"
	desc = "An encyption key for a radio headset.  Contains cypherkeys."
	channels = list("Engineering" = 1, "Command" = 1)

/obj/item/device/radio/headset/encryptionkey/heads/cmo
	name = "Chief Medical Officer's Encryption Key"
	desc = "An encyption key for a radio headset.  Contains cypherkeys."
	channels = list("Medical" = 1, "Command" = 1)

/obj/item/device/radio/headset/encryptionkey/heads/hop
	name = "Head of Personnel's Encryption Key"
	desc = "An encyption key for a radio headset.  Contains cypherkeys."
	channels = list("Command" = 1, "Security" = 0, "Cargo" = 1, "Mining" = 0)

/obj/item/device/radio/headset/encryptionkey/headset_mine
	name = "Mining Radio Encryption Key"
	desc = "An encyption key for a radio headset.  Contains cypherkeys."
	channels = list("Mining" = 1)

/obj/item/device/radio/headset/encryptionkey/heads/qm
	name = "Quartermaster's Encryption Key"
	desc = "An encyption key for a radio headset.  Contains cypherkeys."
	channels = list("Cargo" = 1, "Mining" = 1)

/obj/item/device/radio/headset/encryptionkey/headset_cargo
	name = "Cargo Radio Encryption Key"
	desc = "An encyption key for a radio headset.  Contains cypherkeys."
	channels = list("Cargo" = 1)