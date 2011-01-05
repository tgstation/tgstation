/obj/item/weapon/cartridge
	name = "generic cartridge"
	desc = "A data cartridge for portable microcomputers."
	icon = 'pda.dmi'
	icon_state = "cart"
	item_state = "electronic"
	w_class = 1

	var/obj/item/radio/integrated/radio = null
	var/access_security = 0
	var/access_engine = 0
	var/access_medical = 0
	var/access_manifest = 0
	var/access_clown = 0
	var/access_mime = 0
	var/access_janitor = 0
	var/access_reagent_scanner = 0
	var/access_remote_door = 0 //Control some blast doors remotely!!
	var/remote_door_id = ""
	var/access_status_display = 0
	var/access_quartermaster = 0
	var/access_hydroponics = 0

/obj/item/weapon/cartridge/engineering
	name = "Power-ON Cartridge"
	icon_state = "cart-e"
	access_engine = 1

/obj/item/weapon/cartridge/medical
	name = "Med-U Cartridge"
	icon_state = "cart-m"
	access_medical = 1

/obj/item/weapon/cartridge/security
	name = "R.O.B.U.S.T. Cartridge"
	icon_state = "cart-s"
	access_security = 1

	New()
		..()
		spawn(5)
			radio = new /obj/item/radio/integrated/beepsky(src)

/obj/item/weapon/cartridge/janitor
	name = "CustodiPRO Cartridge"
	desc = "The ultimate in clean-room design."
	icon_state = "cart-j"
	access_janitor = 1

/obj/item/weapon/cartridge/clown
	name = "Honkworks 5.0"
	icon_state = "cart-clown"
	access_clown = 1
	var/honk_charges = 5

/obj/item/weapon/cartridge/mime
	name = "Gestur-O 1000"
	icon_state = "cart-mi"
	access_mime = 1
	var/mime_charges = 5

/obj/item/weapon/cartridge/signal
	name = "generic signaler cartridge"
	desc = "A data cartridge with an integrated radio signaler module."

	New()
		..()
		spawn(5)
			radio = new /obj/item/radio/integrated/signal(src)

/obj/item/weapon/cartridge/signal/toxins
	name = "Signal Ace 2"
	desc = "Complete with integrated radio signaler!"
	icon_state = "cart-tox"
	access_reagent_scanner = 1

/obj/item/weapon/cartridge/quartermaster
	name = "Space Parts & Space Vendors Cartridge"
	desc = "Perfect for the Quartermaster on the go!"
	icon_state = "cart-q"
	access_quartermaster = 1

	New()
		..()
		spawn(5)
			radio = new /obj/item/radio/integrated/mule(src)

/obj/item/weapon/cartridge/head
	name = "Easy-Record DELUXE"
	icon_state = "cart-h"
	access_manifest = 1
	access_engine = 1
	access_security = 1
	access_status_display = 1

/obj/item/weapon/cartridge/captain
	name = "Value-PAK Cartridge"
	desc = "Now with 200% more value!"
	icon_state = "cart-c"
	access_manifest = 1
	access_engine = 1
	access_security = 1
	access_medical = 1
	access_reagent_scanner = 1
	access_status_display = 1

/obj/item/weapon/cartridge/syndicate
	name = "Detomatix Cartridge"
	icon_state = "cart"
	access_remote_door = 1
	remote_door_id = "syndicate" //Make sure this matches the syndicate shuttle's shield/door id!!
	var/shock_charges = 4