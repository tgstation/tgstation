/obj/item/clothing/under/pj/red
	name = "red pj's"
	desc = "Sleepwear."
	icon_state = "red_pyjamas"
	color = "red_pyjamas"
	item_state = "w_suit"

/obj/item/clothing/under/pj/blue
	name = "blue pj's"
	desc = "Sleepwear."
	icon_state = "blue_pyjamas"
	color = "blue_pyjamas"
	item_state = "w_suit"

/obj/item/clothing/under/scratch
	name = "white suit"
	desc = "A white suit, suitable for an excellent host"
	icon_state = "scratch"
	item_state = "scratch"
	color = "scratch"

/obj/item/clothing/under/sl_suit
	desc = "It's a very amish looking suit."
	name = "amish suit"
	icon_state = "sl_suit"
	color = "sl_suit"
	flags = FPRINT | TABLEPASS | ONESIZEFITSALL

/obj/item/clothing/under/waiter
	name = "waiter's outfit"
	desc = "It's a very smart uniform with a special pocket for tip."
	icon_state = "waiter"
	item_state = "waiter"
	color = "waiter"
	flags = FPRINT | TABLEPASS | ONESIZEFITSALL

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
	flags = FPRINT | TABLEPASS
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	cold_protection = UPPER_TORSO | LOWER_TORSO | LEGS | ARMS //Needs gloves and shoes with cold protection to be fully protected.
	min_cold_protection_temperature = SPACE_SUIT_MIN_COLD_PROTECITON_TEMPERATURE

/obj/item/clothing/under/acj
	name = "administrative cybernetic jumpsuit"
	icon_state = "syndicate"
	item_state = "bl_suit"
	color = "syndicate"
	desc = "it's a cybernetically enhanced jumpsuit used for administrative duties."
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	flags = FPRINT | TABLEPASS
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	armor = list(melee = 100, bullet = 100, laser = 100,energy = 100, bomb = 100, bio = 100, rad = 100)
	cold_protection = UPPER_TORSO | LOWER_TORSO | LEGS | FEET | ARMS | HANDS
	min_cold_protection_temperature = SPACE_SUIT_MIN_COLD_PROTECITON_TEMPERATURE

/obj/item/clothing/under/owl
	name = "owl uniform"
	desc = "A jumpsuit with owl wings. Photorealistic owl feathers! Twooooo!"
	icon_state = "owl"
	color = "owl"
	flags = FPRINT | TABLEPASS | ONESIZEFITSALL

/obj/item/clothing/under/johnny
	name = "johnny~~ jumpsuit"
	desc = "Johnny~~"
	icon_state = "johnny"
	color = "johnny"

/obj/item/clothing/under/rainbow
	name = "rainbow"
	desc = "rainbow"
	icon_state = "rainbow"
	item_state = "rainbow"
	color = "rainbow"

/obj/item/clothing/under/cloud
	name = "cloud"
	desc = "cloud"
	icon_state = "cloud"
	color = "cloud"

/obj/item/clothing/under/gimmick/rank/captain/suit
	name = "captain's suit"
	desc = "A green suit and yellow necktie. Exemplifies authority."
	icon_state = "green_suit"
	item_state = "dg_suit"
	color = "green_suit"

/obj/item/clothing/under/gimmick/rank/head_of_personnel/suit
	name = "head of personnel's suit"
	desc = "A teal suit and yellow necktie. An authoritative yet tacky ensemble."
	icon_state = "teal_suit"
	item_state = "g_suit"
	color = "teal_suit"

/obj/item/clothing/under/suit_jacket
	name = "black suit"
	desc = "A black suit and red tie. Very formal."
	icon_state = "black_suit"
	item_state = "bl_suit"
	color = "black_suit"

/obj/item/clothing/under/suit_jacket/really_black
	name = "executive suit"
	desc = "A formal black suit and red tie, intended for the station's finest."
	icon_state = "really_black_suit"
	item_state = "bl_suit"
	color = "black_suit"

/obj/item/clothing/under/suit_jacket/female
	name = "executive suit"
	desc = "A formal trouser suit for women, intended for the station's finest."
	icon_state = "black_suit_fem"
	item_state = "black_suit_fem"
	color = "black_suit_fem"

/obj/item/clothing/under/suit_jacket/red
	name = "red suit"
	desc = "A red suit and blue tie. Somewhat formal."
	icon_state = "red_suit"
	item_state = "r_suit"
	color = "red_suit"

/obj/item/clothing/under/blackskirt
	name = "black skirt"
	desc = "A black skirt, very fancy!"
	icon_state = "blackskirt"
	color = "blackskirt"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/schoolgirl
	name = "schoolgirl uniform"
	desc = "It's just like one of my Japanese animes!"
	icon_state = "schoolgirl"
	item_state = "schoolgirl"
	color = "schoolgirl"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/overalls
	name = "laborer's overalls"
	desc = "A set of durable overalls for getting the job done."
	icon_state = "overalls"
	item_state = "lb_suit"
	color = "overalls"

/obj/item/clothing/under/pirate
	name = "pirate outfit"
	desc = "Yarr."
	icon_state = "pirate"
	item_state = "pirate"
	color = "pirate"

/obj/item/clothing/under/soviet
	name = "soviet uniform"
	desc = "For the Motherland!"
	icon_state = "soviet"
	item_state = "soviet"
	color = "soviet"

/obj/item/clothing/under/redcoat
	name = "redcoat uniform"
	desc = "Looks old."
	icon_state = "redcoat"
	item_state = "redcoat"
	color = "redcoat"

/obj/item/clothing/under/kilt
	name = "kilt"
	desc = "Includes shoes and plaid"
	icon_state = "kilt"
	item_state = "kilt"
	color = "kilt"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|FEET

/obj/item/clothing/under/sexymime
	name = "sexy mime outfit"
	desc = "The only time when you DON'T enjoy looking at someone's rack."
	icon_state = "sexymime"
	item_state = "sexymime"
	color = "sexymime"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO

/obj/item/clothing/under/gladiator
	name = "gladiator uniform"
	desc = "Are you not entertained? Is that not why you are here?"
	icon_state = "gladiator"
	item_state = "gladiator"
	color = "gladiator"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

//wedding stuff
/obj/item/clothing/under/wedding/bride_orange
	name = "orange wedding dress"
	desc = "A big and puffy orange dress."
	icon_state = "bride_orange"
	item_state = "creamsuit"
	color = "bride_orange"
	flags_inv = HIDESHOES

/obj/item/clothing/under/wedding/suit_white
	name = "white suit"
	desc = "A fabulous white suit with orange shirt."
	icon_state = "white_suit"
	item_state = "creamsuit"
	color = "white_suit"

/obj/item/clothing/under/wedding/bridesmaid
	name = "yellow dress"
	desc = "A big and puffy orange dress."
	icon_state = "bridesmaid"
	item_state = "creamsuit"
	color = "bridesmaid"

/obj/item/clothing/under/wedding/firedress
	name = "flaming hot black dress"
	desc = "A small black dress with blue flames print on it."
	icon_state = "dress_fire"
	item_state = "creamsuit"
	color = "dress_fire"

/obj/item/clothing/under/wedding/dress_orange
	name = "orange dress"
	icon_state = "d_orange"
	color = "d_orange"

/obj/item/clothing/under/wedding/dress_green
	name = "green dress"
	icon_state = "d_green"
	color = "d_green"

/obj/item/clothing/under/wedding/dress_purple
	name = "purple dress"
	icon_state = "d_purple"
	color = "d_purple"

/obj/item/clothing/under/wedding/dress_red
	name = "red dress"
	icon_state = "d_red"
	color = "d_red"

/obj/item/clothing/under/wedding/dress_blue
	name = "blue dress"
	icon_state = "d_blue"
	color = "d_blue"

/obj/item/clothing/under/wedding/officer_blue
	name = "blue officer dress"
	icon_state = "officer_blue"
	color = "officer_blue"

/obj/item/clothing/under/wedding/dress_vampire
	name = "vampire dress"
	icon_state = "d_vampire"
	color = "d_vampire"

/obj/item/clothing/under/sundress
	name = "sundress"
	desc = "Makes you want to frolic in a field of daisies."
	icon_state = "sundress"
	item_state = "sundress"
	color = "sundress"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO