/obj/item/clothing/head/bio_hood
	name = "bio hood"
	icon_state = "bio"
	desc = "A hood that protects the head and face from biological comtaminants."
	permeability_coefficient = 0.01
	flags = FPRINT|TABLEPASS|HEADSPACE|HEADCOVERSEYES|HEADCOVERSMOUTH|BLOCKHAIR
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 100, rad = 10)
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES

/obj/item/clothing/suit/bio_suit
	name = "bio suit"
	desc = "A suit that protects against biological contamination."
	icon_state = "bio"
	item_state = "bio_suit"
	w_class = 4//bulky item
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	heat_transfer_coefficient = 0.30
	flags = FPRINT | TABLEPASS
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	slowdown = 1.0
	allowed = list(/obj/item/weapon/tank/emergency_oxygen,/obj/item/weapon/pen,/obj/item/device/flashlight/pen)
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 100, rad = 20)
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT


/obj/item/clothing/head/bio_hood/general
	icon_state = "bio_general"

/obj/item/clothing/suit/bio_suit/general
	icon_state = "bio_general"


/obj/item/clothing/head/bio_hood/virology
	icon_state = "bio_virology"

/obj/item/clothing/suit/bio_suit/virology
	icon_state = "bio_virology"


/obj/item/clothing/head/bio_hood/security
	icon_state = "bio_security"

/obj/item/clothing/suit/bio_suit/security
	icon_state = "bio_security"


/obj/item/clothing/head/bio_hood/janitor
	icon_state = "bio_janitor"

/obj/item/clothing/suit/bio_suit/janitor
	icon_state = "bio_janitor"


/obj/item/clothing/head/bio_hood/scientist
	icon_state = "bio_scientist"

/obj/item/clothing/suit/bio_suit/scientist
	icon_state = "bio_scientist"


/obj/item/clothing/suit/bio_suit/cmo
	icon_state = "bio_cmo"

/obj/item/clothing/head/bio_hood/cmo
	icon_state = "bio_cmo"


/obj/item/clothing/suit/bio_suit/plaguedoctorsuit
	name = "Plague doctor suit"
	desc = "It protected doctors from the Black Death, back then. You bet your arse it's gonna help you against viruses."
	icon_state = "plaguedoctor"
	item_state = "bio_suit"


/obj/item/clothing/head/bio_hood/hazmat_white
	icon_state = "hazmat_white"
	item_state = "hazhat_white"

/obj/item/clothing/suit/bio_suit/hazmat_white
	icon_state = "hazmat_white"
	item_state = "hazsuit_white"


/obj/item/clothing/head/bio_hood/hazmat_janitor
	icon_state = "hazmat_janitor"
	item_state = "hazhat_janitor"

/obj/item/clothing/suit/bio_suit/hazmat_janitor
	icon_state = "hazmat_janitor"
	item_state = "hazsuit_janitor"


/obj/item/clothing/head/bio_hood/hazmat_green
	icon_state = "hazmat_green"
	item_state = "hazhat_green"

/obj/item/clothing/suit/bio_suit/hazmat_green
	icon_state = "hazmat_green"
	item_state = "hazsuit_green"


/obj/item/clothing/head/bio_hood/hazmat_yellow
	icon_state = "hazmat_yellow"
	item_state = "hazhat_yellow"

/obj/item/clothing/suit/bio_suit/hazmat_yellow
	icon_state = "hazmat_yellow"
	item_state = "hazsuit_yellow"


/obj/item/clothing/head/bio_hood/hazmat_orange
	icon_state = "hazmat_orange"
	item_state = "hazhat_orange"

/obj/item/clothing/suit/bio_suit/hazmat_orange
	icon_state = "hazmat_orange"
	item_state = "hazsuit_orange"


/obj/item/clothing/head/bio_hood/hazmat_firered
	icon_state = "hazmat_firered"
	item_state = "hazhat_firered"

/obj/item/clothing/suit/bio_suit/hazmat_firered
	icon_state = "hazmat_firered"
	item_state = "hazsuit_firered"