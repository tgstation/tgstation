/*/////////////////////////////////////////////////////////////////////////////////
///////																		///////
///////			Cit's exclusive suits, armor, etc. go here			///////
///////																		///////
*//////////////////////////////////////////////////////////////////////////////////


/obj/item/clothing/suit/armor/hos/trenchcoat/cloak
	name = "armored trenchcloak"
	desc = "A trenchcoat enchanced with a special lightweight kevlar. This one appears to be designed to be draped over one's shoulders rather than worn normally.."
	alternate_worn_icon = 'modular_citadel/icons/mob/citadel/suit.dmi'
	icon_state = "hostrench"
	item_state = "hostrench"

/obj/item/clothing/suit/hooded/cloak/david
	name = "red cloak"
	icon_state = "goliath_cloak"
	desc = "Ever wanted to look like a badass without ANY effort? Try this nanotrasen brand red cloak, perfect for kids"
	hoodtype = /obj/item/clothing/head/hooded/cloakhood/david
	body_parts_covered = CHEST|GROIN|ARMS

/obj/item/clothing/head/hooded/cloakhood/david
	name = "red cloak hood"
	icon_state = "golhood"
	desc = "conceal your face in shame with this nanotrasen brand hood"
	flags_inv = HIDEEARS|HIDEEYES|HIDEHAIR|HIDEFACIALHAIR

/obj/item/clothing/suit/flakjack
	name = "flak jacket"
	desc = "A dilapidated jacket made of a supposedly bullet-proof material (Hint: It isn't.). Smells faintly of napalm."
	icon = 'modular_citadel/icons/obj/clothing/space_nam.dmi'
	alternate_worn_icon = 'modular_citadel/icons/mob/clothing/space_nam.dmi'
	icon_state = "flakjack"
	item_state = "redtag"
	blood_overlay_type = "armor"
	body_parts_covered = CHEST
	resistance_flags = NONE
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 5, "bio" = 0, "rad" = 0, "fire" = -5, "acid" = -15) //nylon sucks against acid