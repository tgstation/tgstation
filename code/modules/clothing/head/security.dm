/obj/item/clothing/head/helmet
	name = "helmet"
	desc = "Standard Security gear. Protects the head from impacts."
	icon_state = "helmet"
	flags = FPRINT | TABLEPASS | SUITSPACE | HEADCOVERSEYES
	item_state = "helmet"
	armor = list(melee = 50, bullet = 15, laser = 50,energy = 10, bomb = 25, bio = 0, rad = 0)
	protective_temperature = 500
	heat_transfer_coefficient = 0.10
	flags_inv = HIDEEARS|HIDEEYES

/obj/item/clothing/head/helmet/warden
	name = "warden's hat"
	desc = "It's a special helmet issued to the Warden of a securiy force. Protects the head from impacts."
	icon_state = "policehelm"
	flags_inv = 0

/obj/item/clothing/head/helmet/riot
	name = "riot helmet"
	desc = "It's a helmet specifically designed to protect against close range attacks."
	icon_state = "riot"
	item_state = "helmet"
	flags = FPRINT|TABLEPASS|SUITSPACE|HEADCOVERSEYES
	armor = list(melee = 82, bullet = 15, laser = 5,energy = 5, bomb = 5, bio = 2, rad = 0)
	flags_inv = HIDEEARS

/obj/item/clothing/head/soft/sec
	name = "security cap"
	desc = "It's baseball hat in tasteful red colour."
	icon_state = "secsoft"
	color = "sec"
