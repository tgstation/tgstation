/obj/item/clothing/head/hats/flakhelm	//Actually the M1 Helmet
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/hats.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/head.dmi'
	name = "flak helmet"
	icon_state = "m1helm"
	inhand_icon_state = "helmet"
	armor_type = /datum/armor/hats_flakhelm
	desc = "A dilapidated helmet used in ancient wars. This one is brittle and essentially useless. An ace of spades is tucked into the band around the outer shell."

/datum/armor/hats_flakhelm
	bomb = 0.1
	fire = -10
	acid = -15
	wound = 1

/obj/item/clothing/head/hats/flakhelm/Initialize(mapload)
	. = ..()

	create_storage(storage_type = /datum/storage/pockets/tiny/spacenam)

/datum/storage/pockets/tiny/spacenam
	attack_hand_interact = TRUE		//So you can actually see what you stuff in there

//Cyberpunk PI Costume - Sprites from Eris
/obj/item/clothing/head/fedora/det_hat/cybergoggles //Subset of detective fedora so that detectives dont have to sacrifice candycorns for style
	name = "type-34P semi-enclosed headwear"
	desc = "A popular helmet used by certain law enforcement agencies. It has minor armor plating and a neo-laminated fiber lining."
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/hats.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/head.dmi'
	icon_state = "cyberpunkgoggle"

/obj/item/clothing/head/fedora/det_hat/cybergoggles/civilian //Actually civilian with no armor for drip purposes only
	name = "type-34C semi-enclosed headwear"
	desc = "The civilian model of a popular helmet used by certain law enforcement agencies. It has no armor plating."
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/hats.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/head.dmi'
	icon_state = "cyberpunkgoggle"
	armor_type = /datum/armor/none

/obj/item/clothing/head/hats/intern/developer
	name = "intern beancap"

/obj/item/clothing/head/beret/sec/navywarden/syndicate
	name = "master at arms' beret"
	desc = "Surprisingly stylish, if you lived in a silent impressionist film."
	greyscale_config = /datum/greyscale_config/beret_badge
	greyscale_config_worn = /datum/greyscale_config/beret_badge/worn
	greyscale_colors = "#353535#AAAAAA"
	icon_state = "beret_badge"
	armor_type = /datum/armor/navywarden_syndicate
	strip_delay = 60

/datum/armor/navywarden_syndicate
	melee = 40
	bullet = 30
	laser = 30
	energy = 40
	bomb = 25
	fire = 30
	acid = 50
	wound = 6

/obj/item/clothing/head/colourable_flatcap
	name = "colourable flat cap"
	desc = "You in the computers son? You work the computers?"
	icon_state = "flatcap"
	greyscale_config = /datum/greyscale_config/flatcap
	greyscale_config_worn = /datum/greyscale_config/flatcap/worn
	greyscale_colors = "#79684c"
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/head/hats/imperial
	name = "grey naval officer cap"
	desc = "A grey naval cap with a silver disk in the center."
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/hats.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/head.dmi'
	icon_state = "impcom"

/obj/item/clothing/head/hats/imperial/grey
	name = "dark grey naval officer cap"
	desc = "A dark grey naval cap with a silver disk in the center."
	icon_state = "impcommand"

/obj/item/clothing/head/hats/imperial/red
	name = "red naval officer cap"
	desc = "A red naval cap with a silver disk in the center."
	icon_state = "impcap_red"

/obj/item/clothing/head/hats/imperial/white
	name = "white naval officer cap"
	desc = "A white naval cap with a silver disk in the center."
	icon_state = "impcap"

/obj/item/clothing/head/hats/imperial/cap
	name = "captain's naval officer cap"
	desc = "A white naval cap with a silver disk in the center."
	icon_state = "impcap"

/obj/item/clothing/head/hats/imperial/hop
	name = "head of personnel's naval officer cap"
	desc = "An olive naval cap with a silver disk in the center."
	icon_state = "imphop"

/obj/item/clothing/head/hats/imperial/hos
	name = "head of security's naval officer cap"
	desc = "A tar black naval cap with a silver disk in the center."
	icon_state = "imphos"
	armor_type = /datum/armor/hats_hos

/obj/item/clothing/head/hats/imperial/cmo
	name = "chief medical officer's naval cap"
	desc = "A teal naval cap with a silver disk in the center."
	icon_state = "impcmo"

/obj/item/clothing/head/hats/imperial/ce
	name = "chief engineer's blast helmet"
	desc = "Despite seeming like it's made of metal, it's actually a very cheap plastic.."
	armor_type = /datum/armor/imperial_ce
	clothing_flags = STOPSPRESSUREDAMAGE
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_HELM_MAX_TEMP_PROTECT
	cold_protection = HEAD
	min_cold_protection_temperature = FIRE_HELM_MIN_TEMP_PROTECT
	icon_state = "impce"
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT


/datum/armor/imperial_ce
	melee = 15
	bullet = 5
	laser = 20
	energy = 10
	bomb = 20
	bio = 10
	fire = 100
	acid = 50
	wound = 10

/obj/item/clothing/head/hats/imperial/helmet
	name = "blast helmet"
	desc = "A sharp helmet with some goggles on the top. Unfortunately, both those and the helmet itself are made of flimsy plastic." //No armor moment
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/hats.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/head.dmi'
	icon_state = "blast_helmet"

/obj/item/clothing/head/hats/imperial/helmet/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/toggle_icon, "goggles")

/obj/item/clothing/head/soft/yankee
	name = "fashionable baseball cap"
	desc = "Rimmed and brimmed."
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/hats.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/head.dmi'
	icon_state = "yankeesoft"
	soft_type = "yankee"

/obj/item/clothing/head/soft/yankee/rimless
	name = "rimless fashionable baseball cap"
	desc = "Rimless for her pleasure."
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/hats.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/head.dmi'
	icon_state = "yankeenobrimsoft"
	soft_type = "yankeenobrim"

/obj/item/clothing/head/fedora/brown //Fedora without detective's candy corn gimmick
	name = "brown fedora"
	icon_state = "detective"
	inhand_icon_state = "det_hat"

/obj/item/clothing/head/standalone_hood
	name = "hood"
	desc = "A hood with a bit of support around the neck so it actually stays in place, for all those times you want a hood without the coat."
	icon = 'monkestation/code/modules/blueshift/gags/icons/head/head.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/gags/icons/head/head.dmi'
	icon_state = "hood"
	body_parts_covered = HEAD
	cold_protection = HEAD
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	flags_inv = HIDEEARS|HIDEHAIR
	flags_1 = IS_PLAYER_COLORABLE_1
	greyscale_colors = "#4e4a43#F1F1F1"
	greyscale_config = /datum/greyscale_config/standalone_hood
	greyscale_config_worn = /datum/greyscale_config/standalone_hood/worn

/obj/item/clothing/head/beret/badge
	name = "badged beret"
	desc = "A beret. With a badge. What do you want, a dissertation? It's a hat."
	icon_state = "beret_badge"
	greyscale_config = /datum/greyscale_config/beret_badge
	greyscale_config_worn = /datum/greyscale_config/beret_badge/worn
	greyscale_colors = "#972A2A#EFEFEF"
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/head/costume/cowboyhat_old
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/hats.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/head.dmi'
	name = "old cowboy hat"
	desc = "An older cowboy hat, perfect for any outlaw, though lacking fancy colour magic."
	icon_state = "cowboyhat_black"
	inhand_icon_state = "cowboy_hat_black"

//BOWS
/obj/item/clothing/head/small_bow
	name = "small bow"
	desc = "A small compact bow that you can place on the side of your hair."
	icon_state = "small_bow"
	greyscale_config = /datum/greyscale_config/small_bow
	greyscale_config_worn = /datum/greyscale_config/small_bow/worn
	greyscale_colors = "#7b9ab5"
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/head/small_bow/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/toggle_clothes, "small_bow_t")

/obj/item/clothing/head/large_bow
	name = "large bow"
	desc = "A large bow that you can place on top of your head."
	icon_state = "large_bow"
	greyscale_config = /datum/greyscale_config/large_bow
	greyscale_config_worn = /datum/greyscale_config/large_bow/worn
	greyscale_colors = "#7b9ab5"
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/head/back_bow
	name = "back bow"
	desc = "A large bow that you can place on the back of your head."
	icon_state = "back_bow"
	greyscale_config = /datum/greyscale_config/back_bow
	greyscale_config_worn = /datum/greyscale_config/back_bow/worn
	greyscale_colors = "#7b9ab5"
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/head/sweet_bow
	name = "sweet bow"
	desc = "A sweet bow that you can place on the back of your head."
	icon_state = "sweet_bow"
	greyscale_config = /datum/greyscale_config/sweet_bow
	greyscale_config_worn = /datum/greyscale_config/sweet_bow/worn
	greyscale_colors = "#7b9ab5"
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/head/beret/sec/nri
	name = "commander's beret"
	desc = "Za rodinu!!"
	armor_type = /datum/armor/sec_nri

/datum/armor/sec_nri
	melee = 40
	bullet = 35
	laser = 30
	energy = 40
	bomb = 25
	fire = 20
	acid = 50
	wound = 20
