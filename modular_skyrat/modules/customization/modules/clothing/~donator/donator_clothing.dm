/**************SKYRAT REWARDS**************/
//SUITS
/obj/item/clothing/suit/hooded/wintercoat/polychromic
	name = "polychromic winter coat"
	icon = 'modular_skyrat/modules/customization/icons/~donator/obj/clothing/suits.dmi'
	worn_icon = 'modular_skyrat/modules/customization/icons/~donator/mob/clothing/suit.dmi'
	icon_state = "coatpoly"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/polychromic

/obj/item/clothing/suit/hooded/wintercoat/polychromic/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/polychromic, list("666", "CBA", "00F"))

//We need this to color the hood that comes up
/obj/item/clothing/suit/hooded/wintercoat/polychromic/ToggleHood()
	. = ..()
	if(hood)
		hood.color = color
		hood.update_slot_icon()

/obj/item/clothing/head/hooded/winterhood/polychromic
	icon = 'modular_skyrat/modules/customization/icons/~donator/obj/clothing/hats.dmi'
	worn_icon = 'modular_skyrat/modules/customization/icons/~donator/mob/clothing/head.dmi'
	icon_state = "winterhood_poly"

//SCARVES
/obj/item/clothing/neck/cloak/polychromic
	name = "polychromic cloak"
	desc = "For when you want to show off your horrible colour coordination skills."
	icon_state = "polycloak"
	icon = 'modular_skyrat/modules/customization/icons/~donator/obj/clothing/cloaks.dmi'
	worn_icon = 'modular_skyrat/modules/customization/icons/~donator/mob/clothing/neck.dmi'
	var/list/poly_colors = list("FFF", "FFF", "888")

/obj/item/clothing/neck/cloak/polychromic/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/polychromic, poly_colors)

/obj/item/clothing/neck/cloak/polychromic/veil
	name = "polychromic veil"
	icon_state = "polyveil"

/obj/item/clothing/neck/cloak/polychromic/boat
	name = "polychromic boatcloak"
	icon_state = "polyboat"

/obj/item/clothing/neck/cloak/polychromic/shroud
	name = "polychromic shroud"
	icon_state = "polyshroud"

//UNIFORMS
/obj/item/clothing/under/dress/skirt/polychromic
	name = "polychromic skirt"
	desc = "A fancy skirt made with polychromic threads."
	icon = 'modular_skyrat/modules/customization/icons/~donator/obj/clothing/uniform.dmi'
	worn_icon = 'modular_skyrat/modules/customization/icons/~donator/mob/clothing/uniform.dmi'
	icon_state = "polyskirt"
	mutant_variants = NONE
	var/list/poly_colors = list("FFF", "F88", "888")

/obj/item/clothing/under/dress/skirt/polychromic/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/polychromic, poly_colors)

/obj/item/clothing/under/dress/skirt/polychromic/pleated
	name = "polychromic pleated skirt"
	desc = "A magnificent pleated skirt complements the woolen polychromatic sweater."
	icon_state = "polypleat"
	body_parts_covered = CHEST|GROIN|ARMS
	poly_colors = list("8CF", "888", "F33")

/obj/item/clothing/under/misc/poly_shirt
	name = "polychromic button-up shirt"
	desc = "A fancy button-up shirt made with polychromic threads."
	icon = 'modular_skyrat/modules/customization/icons/~donator/obj/clothing/uniform.dmi'
	worn_icon = 'modular_skyrat/modules/customization/icons/~donator/mob/clothing/uniform.dmi'
	icon_state = "polysuit"
	mutant_variants = NONE

/obj/item/clothing/under/misc/poly_shirt/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/polychromic, list("FFF", "333", "333"))

/obj/item/clothing/under/misc/polyshorts
	name = "polychromic shorts"
	desc = "For ease of movement and style."
	icon = 'modular_skyrat/modules/customization/icons/~donator/obj/clothing/uniform.dmi'
	worn_icon = 'modular_skyrat/modules/customization/icons/~donator/mob/clothing/uniform.dmi'
	icon_state = "polyshorts"
	can_adjust = FALSE
	body_parts_covered = CHEST|GROIN|ARMS
	mutant_variants = NONE

/obj/item/clothing/under/misc/polyshorts/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/polychromic, list("333", "888", "888"))

/obj/item/clothing/under/misc/polyjumpsuit
	name = "polychromic tri-tone jumpsuit"
	desc = "A fancy jumpsuit made with polychromic threads."
	icon = 'modular_skyrat/modules/customization/icons/~donator/obj/clothing/uniform.dmi'
	worn_icon = 'modular_skyrat/modules/customization/icons/~donator/mob/clothing/uniform.dmi'
	icon_state = "polyjump"
	can_adjust = FALSE
	mutant_variants = NONE

/obj/item/clothing/under/misc/polyjumpsuit/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/polychromic, list("FFF", "888", "333"))

/obj/item/clothing/under/misc/poly_bottomless
	name = "polychromic bottomless shirt"
	desc = "Great for showing off your underwear in dubious style."
	icon = 'modular_skyrat/modules/customization/icons/~donator/obj/clothing/uniform.dmi'
	worn_icon = 'modular_skyrat/modules/customization/icons/~donator/mob/clothing/uniform.dmi'
	icon_state = "polybottomless"
	body_parts_covered = CHEST|ARMS	//Because there's no bottom included
	can_adjust = FALSE
	mutant_variants = NONE

/obj/item/clothing/under/misc/poly_bottomless/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/polychromic, list("888", "F33", "FFF"))

/obj/item/clothing/under/misc/poly_tanktop
	name = "polychromic tank top"
	desc = "For those lazy summer days."
	icon = 'modular_skyrat/modules/customization/icons/~donator/obj/clothing/uniform.dmi'
	worn_icon = 'modular_skyrat/modules/customization/icons/~donator/mob/clothing/uniform.dmi'
	icon_state = "polyshimatank"
	body_parts_covered = CHEST|GROIN
	can_adjust = FALSE
	mutant_variants = NONE
	var/list/poly_colors = list("888", "FFF", "8CF")

/obj/item/clothing/under/misc/poly_tanktop/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/polychromic, poly_colors)

/obj/item/clothing/under/misc/poly_tanktop/female
	name = "polychromic feminine tank top"
	desc = "Great for showing off your chest in style. Not recommended for males."
	icon_state = "polyfemtankpantsu"
	poly_colors = list("888", "F33", "FFF")

/obj/item/clothing/under/shorts/polychromic
	name = "polychromic athletic shorts"
	desc = "95% Polychrome, 5% Spandex!"
	icon = 'modular_skyrat/modules/customization/icons/~donator/obj/clothing/uniform.dmi'
	worn_icon = 'modular_skyrat/modules/customization/icons/~donator/mob/clothing/uniform.dmi'
	icon_state = "polyshortpants"
	mutant_variants = NONE
	var/list/poly_colors = list("FFF", "F88", "FFF")

/obj/item/clothing/under/shorts/polychromic/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/polychromic, poly_colors)

/obj/item/clothing/under/shorts/polychromic/pantsu
	name = "polychromic panties"
	desc = "Topless striped panties. Now with 120% more polychrome!"
	icon_state = "polypantsu"
	body_parts_covered = GROIN
	mutant_variants = NONE
	poly_colors = list("FFF", "8CF", "FFF")

/**************CKEY EXCLUSIVES*************/
//Donation reward for Random516
/obj/item/clothing/head/drake_skull
	name = "skull of an ashdrake"
	desc = "How did they get this?"
	icon = 'modular_skyrat/modules/customization/icons/~donator/obj/clothing/hats.dmi'
	icon_state = "drake_skull"
	worn_icon = 'modular_skyrat/modules/customization/icons/~donator/mob/clothing/large-worn-icons/32x64/head.dmi'
	flags_cover = HEADCOVERSEYES
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR
	mutant_variants = NONE

//Donation reward for Random516
/obj/item/clothing/gloves/fingerless/blutigen_wraps
	name = "Blutigen Wraps"
	desc = "The one who wears these had everything and yet lost it all..."
	icon = 'modular_skyrat/modules/customization/icons/~donator/obj/clothing/gloves.dmi'
	icon_state = "blutigen_wraps"
	worn_icon = 'modular_skyrat/modules/customization/icons/~donator/mob/clothing/hands.dmi'

//Donation reward for Random516
/obj/item/clothing/suit/blutigen_kimono
	name = "Blutigen Kimono"
	desc = "For the eyes bestowed upon this shall seek adventure..."
	icon = 'modular_skyrat/modules/customization/icons/~donator/obj/clothing/suits.dmi'
	icon_state = "blutigen_kimono"
	worn_icon = 'modular_skyrat/modules/customization/icons/~donator/mob/clothing/suit.dmi'
	body_parts_covered = CHEST|GROIN|ARMS
	mutant_variants = NONE

//Donation reward for Random516
/obj/item/clothing/under/custom/blutigen_undergarment
	name = "Dragon Undergarments"
	desc = "The Dragon wears the sexy?"
	icon = 'modular_skyrat/modules/customization/icons/~donator/obj/clothing/uniform.dmi'
	icon_state = "blutigen_undergarment"
	worn_icon = 'modular_skyrat/modules/customization/icons/~donator/mob/clothing/uniform.dmi'
	mutant_variants = NONE
	fitted = FEMALE_UNIFORM_TOP

//Donation reward for NetraKyram
/obj/item/clothing/under/custom/kilano
	name = "black and gold dress uniform"
	desc = "A light black and gold dress made out some sort of silky material."
	icon = 'modular_skyrat/modules/customization/icons/~donator/obj/clothing/uniform.dmi'
	icon_state = "kilanosuit"
	worn_icon = 'modular_skyrat/modules/customization/icons/~donator/mob/clothing/uniform.dmi'
	mutant_variants = NONE
	fitted = FEMALE_UNIFORM_TOP

//Donation reward for NetraKyram
/obj/item/clothing/gloves/kilano
	name = "black and gold gloves"
	desc = "Some black and gold gloves, It seems like they're made to match something."
	icon = 'modular_skyrat/modules/customization/icons/~donator/obj/clothing/gloves.dmi'
	icon_state = "kilanogloves"
	worn_icon = 'modular_skyrat/modules/customization/icons/~donator/mob/clothing/hands.dmi'

//Donation reward for NetraKyram
/obj/item/clothing/shoes/winterboots/kilano
	name = "black and gold boots"
	desc = "Some heavy furred boots, why would you need fur on a space station? Seems redundant."
	icon = 'modular_skyrat/modules/customization/icons/~donator/obj/clothing/shoes.dmi'
	icon_state = "kilanoboots"
	worn_icon = 'modular_skyrat/modules/customization/icons/~donator/mob/clothing/feet.dmi'
	mutant_variants = NONE


/****************LEGACY REWARDS***************/
//Donation reward for inferno707
/obj/item/clothing/neck/cloak/inferno
	name = "Kiara's Cloak"
	desc = "The design on this seems a little too familiar."
	icon = 'modular_skyrat/modules/customization/icons/~donator/obj/custom.dmi'
	icon_state = "infcloak"
	worn_icon = 'modular_skyrat/modules/customization/icons/~donator/mob/clothing/custom_w.dmi'
	w_class = WEIGHT_CLASS_SMALL
	body_parts_covered = CHEST|GROIN|LEGS|ARMS

//Donation reward for inferno707
/obj/item/clothing/neck/human_petcollar/inferno
	name = "Kiara's Collar"
	desc = "A soft black collar that seems to stretch to fit whoever wears it."
	icon = 'modular_skyrat/modules/customization/icons/~donator/obj/custom.dmi'
	icon_state = "infcollar"
	worn_icon = 'modular_skyrat/modules/customization/icons/~donator/mob/clothing/custom_w.dmi'
	tagname = null

//Donation reward for inferno707
/obj/item/clothing/accessory/medal/steele
	name = "Insignia Of Steele"
	desc = "An intricate pendant given to those who help a key member of the Steele Corporation."
	icon = 'modular_skyrat/modules/customization/icons/~donator/obj/custom.dmi'
	icon_state = "steele"
	medaltype = "medal-silver"

//Donation reward for inferno707
/obj/item/toy/darksabre
	name = "Kiara's Sabre"
	desc = "This blade looks as dangerous as its owner."
	icon = 'modular_skyrat/modules/customization/icons/~donator/obj/custom.dmi'
	worn_icon = 'modular_skyrat/modules/customization/icons/~donator/mob/clothing/custom_w.dmi'
	icon_state = "darksabre"
	lefthand_file = 'modular_skyrat/modules/customization/icons/~donator/mob/inhands/donator_left.dmi'
	righthand_file = 'modular_skyrat/modules/customization/icons/~donator/mob/inhands/donator_right.dmi'

/obj/item/toy/darksabre/get_belt_overlay()
	return mutable_appearance('modular_skyrat/modules/customization/icons/~donator/obj/custom.dmi', "darksheath-darksabre")

//Donation reward for inferno707
/obj/item/storage/belt/sabre/darksabre
	name = "Ornate Sheathe"
	desc = "An ornate and rather sinister looking sabre sheathe."
	icon = 'modular_skyrat/modules/customization/icons/~donator/obj/custom.dmi'
	worn_icon = 'modular_skyrat/modules/customization/icons/~donator/mob/clothing/custom_w.dmi'
	icon_state = "darksheath"

/obj/item/storage/belt/sabre/darksabre/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.set_holdable(list(
		/obj/item/toy/darksabre
		))

/obj/item/storage/belt/sabre/darksabre/PopulateContents()
	new /obj/item/toy/darksabre(src)
	update_icon()

//Donation reward for inferno707
/obj/item/clothing/suit/armor/vest/darkcarapace
	name = "Dark Armor"
	desc = "A dark, non-functional piece of armor sporting a red and black finish."
	icon = 'modular_skyrat/modules/customization/icons/~donator/obj/custom.dmi'
	worn_icon = 'modular_skyrat/modules/customization/icons/~donator/mob/clothing/custom_w.dmi'
	icon_state = "darkcarapace"
	blood_overlay_type = "armor"
	dog_fashion = /datum/dog_fashion/back
	mutant_variants = NONE
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)

//Donation reward for inferno707
/obj/item/clothing/mask/hheart
	name = "Hollow Heart"
	desc = "It's an odd ceramic mask. Set in the internal side are several suspicious electronics branded by Steele Tech."
	icon = 'modular_skyrat/modules/customization/icons/~donator/obj/clothing/masks.dmi'
	icon_state = "hheart"
	worn_icon = 'modular_skyrat/modules/customization/icons/~donator/mob/clothing/mask.dmi'
	var/c_color_index = 1
	var/list/possible_colors = list("off", "blue", "red")
	actions_types = list(/datum/action/item_action/hheart)
	mutant_variants = NONE

/obj/item/clothing/mask/hheart/Initialize()
	. = ..()
	update_icon()

/obj/item/clothing/mask/hheart/update_icon()
	. = ..()
	icon_state = "hheart-[possible_colors[c_color_index]]"

/datum/action/item_action/hheart
	name = "Toggle Mode"
	desc = "Toggle the color of the hollow heart."

/obj/item/clothing/mask/hheart/ui_action_click(mob/user, action)
	. = ..()
	if(istype(action, /datum/action/item_action/hheart))
		if(!isliving(user))
			return
		var/mob/living/ooser = user
		var/the = possible_colors.len
		var/index = 0
		if(c_color_index >= the)
			index = 1
		else
			index = c_color_index + 1
		c_color_index = index
		update_icon()
		ooser.update_inv_wear_mask()
		ooser.update_action_buttons_icon()
		to_chat(ooser, "<span class='notice'>You toggle the [src] to [possible_colors[c_color_index]].</span>")

/obj/item/clothing/suit/hooded/cloak/zuliecloak
	name = "Project: Zul-E"
	desc = "A standard version of a prototype cloak given out by Nanotrasen higher ups. It's surprisingly thick and heavy for a cloak despite having most of it's tech stripped. It also comes with a bluespace trinket which calls it's accompanying hat onto the user. A worn inscription on the inside of the cloak reads 'Fleuret' ...the rest is faded away."
	icon_state = "zuliecloak"
	icon = 'modular_skyrat/modules/customization/icons/~donator/obj/clothing/cloaks.dmi'
	worn_icon = 'modular_skyrat/modules/customization/icons/~donator/mob/clothing/neck.dmi'
	hoodtype = /obj/item/clothing/head/hooded/cloakhood/zuliecloak
	body_parts_covered = CHEST|GROIN|ARMS
	slot_flags = ITEM_SLOT_OCLOTHING | ITEM_SLOT_NECK //it's a cloak. it's cosmetic. so why the hell not? what could possibly go wrong?
	mutant_variants = NONE

/obj/item/clothing/head/hooded/cloakhood/zuliecloak
	name = "NT Special Issue"
	desc = "This hat is unquestionably the best one, bluespaced to and from CentComm. It smells of Fish and Tea with a hint of antagonism"
	icon_state = "zuliecap"
	icon = 'modular_skyrat/modules/customization/icons/~donator/obj/clothing/cloaks.dmi'
	worn_icon = 'modular_skyrat/modules/customization/icons/~donator/mob/clothing/neck.dmi'
	flags_inv = HIDEEARS|HIDEHAIR
	mutant_variants = NONE
