// MASK WAS THAT MOVIE WITH THAT GUY WITH THE MESSED UP FACE. WHAT'S HIS NAME . . . JIM CARREY, I THINK.

/obj/item/clothing/mask
	name = "mask"
	icon = 'masks.dmi'
	body_parts_covered = HEAD
	armor = list(melee = 0, bullet = 0, laser = 2, taser = 2, bomb = 0, bio = 0, rad = 0)


/obj/item/clothing/mask/breath
	desc = "A close-fitting mask that can be connected to an air supply but does not work very well in hard vacuum."
	name = "Breath Mask"
	icon_state = "breath"
	item_state = "breath"
	flags = FPRINT | TABLEPASS | SUITSPACE | HEADSPACE | MASKCOVERSMOUTH
	w_class = 2
	protective_temperature = 420
	heat_transfer_coefficient = 0.90
	gas_transfer_coefficient = 0.10
	permeability_coefficient = 0.50

/obj/item/clothing/mask/medical
	desc = "This mask does not work very well in low pressure environments."
	name = "Medical Mask"
	icon_state = "medical"
	item_state = "medical"
	flags = FPRINT|TABLEPASS|SUITSPACE|HEADSPACE|MASKCOVERSMOUTH
	w_class = 3
	protective_temperature = 420
	gas_transfer_coefficient = 0.10
	permeability_coefficient = 0.10

/obj/item/clothing/mask/muzzle
	name = "muzzle"
	icon_state = "muzzle"
	item_state = "muzzle"
	flags = FPRINT|TABLEPASS|MASKCOVERSMOUTH
	w_class = 2
	gas_transfer_coefficient = 0.90

/obj/item/clothing/mask/surgical
	name = "Sterile Mask"
	icon_state = "sterile"
	item_state = "sterile"
	w_class = 1
	flags = FPRINT|TABLEPASS|HEADSPACE|MASKCOVERSMOUTH
	gas_transfer_coefficient = 0.90
	permeability_coefficient = 0.05
	armor = list(melee = 0, bullet = 0, laser = 2, taser = 2, bomb = 0, bio = 75, rad = 0)

/obj/item/clothing/mask/gas
	name = "gas mask"
	desc = "A close-fitting mask that can filter some environmental toxins or be connected to an air supply."
	icon_state = "gas_mask"
	flags = FPRINT|TABLEPASS|SUITSPACE|MASKCOVERSMOUTH|MASKCOVERSEYES
	w_class = 3.0
	see_face = 0.0
	item_state = "gas_mask"
	protective_temperature = 500
	heat_transfer_coefficient = 0.01
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01

/obj/item/clothing/mask/gas/plaguedoctor
	name = "Plague doctor mask"
	desc = "A modernised version of the classic design, this mask will not only filter out toxins but it can also be connected to an air supply."
	icon_state = "plaguedoctor"
	item_state = "gas_mask"
	armor = list(melee = 0, bullet = 0, laser = 2, taser = 2, bomb = 0, bio = 75, rad = 0)

/obj/item/clothing/mask/gas/emergency
	name = "emergency gas mask"
	icon_state = "gas_alt"
	item_state = "gas_alt"

/obj/item/clothing/mask/gas/swat
	name = "SWAT Mask"
	desc = "A close-fitting tactical mask that can filter some environmental toxins or be connected to an air supply."
	icon_state = "swat"

/obj/item/clothing/mask/gas/voice
	name = "gas mask"
	desc = "A close-fitting mask that can filter some environmental toxins or be connected to an air supply."
	icon_state = "gas_mask"
	var/mode = 0// 0==Scouter | 1==Night Vision | 2==Thermal | 3==Meson
	var/voice = "Unknown"
	var/vchange = 0//This didn't do anything before. It now checks if the mask has special functions/N

/obj/item/clothing/mask/gas/voice/space_ninja
	name = "ninja mask"
	desc = "A close-fitting mask that acts both as an air filter and a post-modern fashion statement."
	icon_state = "s-ninja"
	item_state = "s-ninja_mask"
	vchange = 1

/obj/item/clothing/mask/gas/clown_hat
	name = "clown wig and mask"
	desc = "You're gay for even considering wearing this."
	icon_state = "clown"
	item_state = "clown_hat"

/obj/item/clothing/mask/gas/mime
	name = "mime mask"
	desc = "It looks a little creepy"
	icon_state = "mime"

/obj/item/clothing/mask/cigarette
	name = "Cigarette"
	icon_state = "cigoff"
	var/lit = 0
	var/icon_on = "cigon"  //Note - these are in masks.dmi not in cigarette.dmi
	var/icon_off = "cigoff"
	var/icon_butt = "cigbutt"
	throw_speed = 0.5
	item_state = "cigoff"
	var/lastHolder = null
	var/smoketime = 300
	w_class = 1
	body_parts_covered = null

/obj/item/clothing/mask/cigarette/cigar
	name = "Premium Cigar"
	desc = "Only for the best of space travelers."
	icon_state = "cigaroff"
	icon_on = "cigaron"
	icon_off = "cigaroff"
	icon_butt = "cigarbutt"
	throw_speed = 0.5
	item_state = "cigaroff"
	smoketime = 1500

/obj/item/clothing/mask/cigarette/cigar/cohiba
	name = "Cohiba Cigar"
	desc = "There's little more you could want from a cigar."
	icon_state = "cigaroff"
	icon_on = "cigaron"
	icon_off = "cigaroff"
	icon_butt = "cigarbutt"