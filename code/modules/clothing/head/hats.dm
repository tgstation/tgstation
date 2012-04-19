// HATS. OH MY WHAT A FINE CHAPEAU, GOOD SIR.
/obj/item/clothing/head
	name = "head"
	icon = 'hats.dmi'
	body_parts_covered = HEAD
	var/list/allowed = list()

/obj/item/clothing/head/cakehat
	name = "cake-hat"
	desc = "It's tasty looking!"
	icon_state = "cake0"
	var/onfire = 0.0
	var/status = 0
	flags = FPRINT|TABLEPASS|HEADSPACE|HEADCOVERSEYES
	var/fire_resist = T0C+1300	//this is the max temp it can stand before you start to cook. although it might not burn away, you take damage

/obj/item/clothing/head/caphat
	name = "captain's hat"
	icon_state = "captain"
	desc = "It's good being the king."
	flags = FPRINT|TABLEPASS|SUITSPACE
	item_state = "caphat"

/obj/item/clothing/head/centhat
	name = "\improper CentComm. hat"
	icon_state = "centcom"
	desc = "It's good to be emperor."
	flags = FPRINT|TABLEPASS|SUITSPACE
	item_state = "centhat"

/obj/item/clothing/head/deathsquad/beret
	name = "officer's beret"
	desc = "An armored beret commonly used by special operations officers."
	icon_state = "beret_badge"
	flags = FPRINT|TABLEPASS
	armor = list(melee = 65, bullet = 55, laser = 35,energy = 20, bomb = 30, bio = 30, rad = 30)


/obj/item/clothing/head/powdered_wig
	name = "powdered wig"
	desc = "A powdered wig."
	icon_state = "pwig"
	item_state = "pwig"

/obj/item/clothing/head/that
	name = "top-hat"
	desc = "It's an amish looking hat."
	icon_state = "tophat"
	item_state = "that"
	flags = FPRINT|TABLEPASS


/obj/item/clothing/head/chefhat
	name = "chef's hat"
	desc = "It's a hat used by chefs to keep hair out of your food. Judging by the food in the mess, they don't work."
	icon_state = "chef"
	item_state = "chef"
	desc = "The commander in chef's head wear."
	flags = FPRINT | TABLEPASS

/obj/item/clothing/head/redcoat
	name = "redcoat's hat"
	icon_state = "redcoat"
	desc = "<i>'I guess it's a redhead.'</i>"
	flags = FPRINT | TABLEPASS

/obj/item/clothing/head/mailman
	name = "mailman's hat"
	icon_state = "mailman"
	desc = "<i>'Right-on-time'</i> mail service head wear."
	flags = FPRINT | TABLEPASS

/obj/item/clothing/head/plaguedoctorhat
	name = "plague doctor's hat"
	desc = "These were once used by Plague doctors. They're pretty much useless."
	icon_state = "plaguedoctor"
	flags = FPRINT | TABLEPASS
	permeability_coefficient = 0.01

/obj/item/clothing/head/beret
	name = "beret"
	desc = "A beret, a mime's favorite headwear."
	icon_state = "beret"
	flags = FPRINT | TABLEPASS


// CHUMP HELMETS: COOKING THEM DESTROYS THE CHUMP HELMET SPAWN.

/obj/item/clothing/head/helmet/cueball
	name = "cueball helmet"
	desc = "A large, featureless white orb mean to be worn on your head. How do you even see out of this thing?"
	icon_state = "cueball"
	flags = FPRINT|TABLEPASS|SUITSPACE|HEADCOVERSEYES|HEADCOVERSMOUTH|BLOCKHAIR
	item_state="cueball"
	flags_inv = 0

/obj/item/clothing/head/secsoft
	name = "soft cap"
	desc = "It's baseball hat in tasteful red colour."
	icon_state = "secsoft"
	flags = FPRINT|TABLEPASS|HEADCOVERSEYES
	item_state = "helmet"

/obj/item/clothing/head/cargosoft
	name = "cargo cap"
	desc = "It's a baseball hat in a tasteless yellow colour."
	icon_state = "cargosoft"
	flags = FPRINT|TABLEPASS|HEADCOVERSEYES
	item_state = "helmet"
	var/flipped = 0

/obj/item/clothing/head/syndicatefake
	name = "red space-helmet replica"
	desc = "A plastic replica of a red space space helmet. This is a toy, it is not made for use in space!"
	icon_state = "syndicate"
	item_state = "syndicate"
	see_face = 0.0
	flags = FPRINT | TABLEPASS | BLOCKHAIR

/obj/item/clothing/head/chaplain_hood
	name = "chaplain's hood"
	desc = "It's hood that covers the head. It keeps you warm during the space winters."
	icon_state = "chaplain_hood"
	flags = FPRINT|TABLEPASS|HEADSPACE|HEADCOVERSEYES|BLOCKHAIR

/obj/item/clothing/head/hasturhood
	name = "hastur's hood"
	desc = "It's unspeakably stylish"
	icon_state = "hasturhood"
	flags = FPRINT|TABLEPASS|HEADSPACE|HEADCOVERSEYES|BLOCKHAIR

/obj/item/clothing/head/nursehat
	name = "nurse's hat"
	desc = "It allows quick identification of trained medical personnel."
	icon_state = "nursehat"
	flags = FPRINT|TABLEPASS

/obj/item/clothing/head/helmet/cardborg
	name = "cardborg helmet"
	desc = "A helmet made out of a box."
	icon_state = "cardborg_h"
	item_state = "cardborg_h"
	flags = FPRINT | TABLEPASS | HEADCOVERSEYES | HEADCOVERSMOUTH
	see_face = 0.0
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES
