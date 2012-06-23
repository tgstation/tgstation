/obj/item/clothing/under/scratch
	name = "white suit"
	desc = "A white suit, suitable for an excellent host"
	flags = FPRINT | TABLEPASS
	icon_state = "scratch"
	item_state = "scratch"
	color = "scratch"

/obj/item/clothing/under/sl_suit
	desc = "It's a very amish looking suit."
	name = "amish suit"
	icon_state = "sl_suit"
	color = "sl_suit"

/obj/item/clothing/under/waiter
	name = "waiter's outfit"
	desc = "It's a very smart uniform with a special pocket for tip."
	icon_state = "waiter"
	item_state = "waiter"
	color = "waiter"

/obj/item/clothing/under/rank/mailman
	name = "mailman's jumpsuit"
	desc = "<i>'Special delivery!'</i>"
	icon_state = "mailman"
	item_state = "b_suit"
	color = "mailman"

/obj/item/clothing/under/sexyclown
	name = "sexy-clown suit"
	desc = "It makes you look HONKable!"
	icon_state = "sexyclown"
	item_state = "sexyclown"
	color = "sexyclown"

/obj/item/clothing/under/rank/vice
	name = "vice officer's jumpsuit"
	desc = "It's the standard issue pretty-boy outfit, as seen on Holo-Vision."
	icon_state = "vice"
	item_state = "gy_suit"
	color = "vice"

/obj/item/clothing/under/rank/centcom_officer
	desc = "It's a jumpsuit worn by CentCom Officers."
	name = "\improper CentCom officer's jumpsuit"
	icon_state = "officer"
	item_state = "g_suit"
	color = "officer"

/obj/item/clothing/under/rank/centcom_commander
	desc = "It's a jumpsuit worn by CentCom's highest-tier Commanders."
	name = "\improper CentCom officer's jumpsuit"
	icon_state = "centcom"
	item_state = "dg_suit"
	color = "centcom"

/obj/item/clothing/under/space
	name = "\improper NASA jumpsuit"
	desc = "It has a NASA logo on it and is made of space-proofed materials."
	icon_state = "black"
	item_state = "bl_suit"
	color = "black"
	w_class = 4//bulky item
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.02
	heat_transfer_coefficient = 0.02
	protective_temperature = 1000
	flags = FPRINT | TABLEPASS | SUITSPACE
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS

/obj/item/clothing/under/acj
	name = "administrative cybernetic jumpsuit"
	icon_state = "syndicate"
	item_state = "bl_suit"
	color = "syndicate"
	desc = "it's a cybernetically enhanced jumpsuit used for administrative duties."
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	heat_transfer_coefficient = 0.01
	protective_temperature = 100000
	flags = FPRINT | TABLEPASS | SUITSPACE
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	armor = list(melee = 100, bullet = 100, laser = 100,energy = 100, bomb = 100, bio = 100, rad = 100)