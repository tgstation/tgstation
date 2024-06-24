/obj/item/clothing/shoes/wraps
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/shoes.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/feet.dmi'
	name = "gilded leg wraps"
	desc = "Ankle coverings. These ones have a golden design."
	icon_state = "gildedcuffs"
	body_parts_covered = FALSE

/obj/item/clothing/shoes/wraps/silver
	name = "silver leg wraps"
	desc = "Ankle coverings. Not made of real silver."
	icon_state = "silvergildedcuffs"

/obj/item/clothing/shoes/wraps/red
	name = "red leg wraps"
	desc = "Ankle coverings. Show off your style with these shiny red ones!"
	icon_state = "redcuffs"

/obj/item/clothing/shoes/wraps/blue
	name = "blue leg wraps"
	desc = "Ankle coverings. Hang ten, brother."
	icon_state = "bluecuffs"

/obj/item/clothing/shoes/cowboyboots
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/shoes.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/feet.dmi'
	name = "cowboy boots"
	desc = "A standard pair of brown cowboy boots."
	icon_state = "cowboyboots"

/obj/item/clothing/shoes/cowboyboots/black
	name = "black cowboy boots"
	desc = "A pair of black cowboy boots, pretty easy to scuff up."
	icon_state = "cowboyboots_black"

/obj/item/clothing/shoes/high_heels
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/shoes.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/feet.dmi'
	name = "high heels"
	desc = "A fancy pair of high heels. Won't compensate for your below average height that much."
	icon_state = "heels"
	greyscale_config = /datum/greyscale_config/heels
	greyscale_config_worn = /datum/greyscale_config/heels/worn
	greyscale_config_worn_digitigrade = /datum/greyscale_config/heels/worn/digi
	greyscale_colors = "#FFFFFF"
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/shoes/high_heels/Initialize(mapload)
	. = ..()
	//AddComponent(/datum/component/squeak, list('monkestation/code/modules/blueshift/sounds/effects/heel1.ogg' = 1, 'monkestation/code/modules/blueshift/sounds/effects/heel2.ogg' = 1), 50)

/obj/item/clothing/shoes/fancy_heels
	name = "fancy heels"
	desc = "A pair of fancy high heels that are much smaller on your feet."
	icon_state = "fancyheels"
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/shoes.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/feet.dmi'
	greyscale_colors = "#FFFFFF"
	greyscale_config = /datum/greyscale_config/fancyheels
	greyscale_config_worn = /datum/greyscale_config/fancyheels/worn
	greyscale_config_worn_digitigrade = /datum/greyscale_config/fancyheels/worn/digi
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/shoes/fancy_heels/Initialize(mapload)
	. = ..()
	//AddComponent(/datum/component/squeak, list('monkestation/code/modules/blueshift/sounds/effects/heel1.ogg' = 1, 'monkestation/code/modules/blueshift/sounds/effects/heel2.ogg' = 1), 50)

/obj/item/clothing/shoes/discoshoes
	name = "green snakeskin shoes"
	desc = "They may have lost some of their lustre over the years, but these green crocodile leather shoes fit you perfectly."
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/shoes.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/feet.dmi'
	icon_state = "lizardskin_shoes"

/obj/item/clothing/shoes/kimshoes
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/shoes.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/feet.dmi'
	name = "aerostatic boots"
	desc = "A brown pair of boots, prim and proper, ready to set off and get a body out of a tree."
	icon_state = "aerostatic_boots"


/obj/item/clothing/shoes/jungleboots
	name = "jungle boots"
	desc = "Take me to your paradise, I want to see the Jungle. A brown pair of boots."
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/shoes.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/feet.dmi'
	icon_state = "jungle"
	inhand_icon_state = "jackboots"
	strip_delay = 30
	equip_delay_other = 50
	resistance_flags = NONE

/obj/item/clothing/shoes/jungleboots/Initialize(mapload)
	. = ..()

	create_storage(storage_type = /datum/storage/pockets/shoes)

/obj/item/clothing/shoes/jackboots/black
	name = "dark jackboots"
	desc = "Nanotrasen-issue Security combat boots for combat scenarios or combat situations. All combat, all the time. These are fully black."
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/shoes.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/feet.dmi'
	icon_state = "blackjack"

/obj/item/clothing/shoes/wraps/cloth
	name = "cloth foot wraps"
	desc = "Boxer tape or bandages wrapped like a mummy, all left up to the choice of the wearer."
	icon_state = "clothwrap"
	greyscale_config = /datum/greyscale_config/clothwraps
	greyscale_config_worn = /datum/greyscale_config/clothwraps/worn
	greyscale_config_worn_digitigrade = /datum/greyscale_config/clothwraps/worn/digi
	greyscale_colors = "#FFFFFF"
	body_parts_covered = FALSE
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/shoes/wraps/colourable
	name = "colourable foot wraps"
	desc = "Ankle coverings. These ones have a customisable colour design."
	icon_state = "legwrap"
	greyscale_config = /datum/greyscale_config/legwraps
	greyscale_config_worn = /datum/greyscale_config/legwraps/worn
	greyscale_config_worn_digitigrade = /datum/greyscale_config/legwraps/worn/digi
	greyscale_colors = "#FFFFFF"
	body_parts_covered = FALSE
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/shoes/sports
	name = "sport shoes"
	desc = "Shoes for the sporty individual. The giants of Charlton play host to the titans of Ipswich - making them both seem normal sized."
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/shoes.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/feet.dmi'
	icon_state = "sportshoe"

/obj/item/clothing/shoes/jackboots/knee
	name = "knee boots"
	desc = "Black leather boots that go up to the knee."
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/shoes.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/feet.dmi'
	icon_state = "kneeboots"

/obj/item/clothing/shoes/jackboots/timbs
	name = "fashionable boots"
	desc = "Fresh from Luna, deadass good for rappers."
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/shoes.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/feet.dmi'
	icon_state = "timbs"

/obj/item/clothing/shoes/winterboots/christmas
	name = "red christmas boots"
	desc = "A pair of fluffy red christmas boots!"
	icon_state = "christmas_boots"
	greyscale_colors = "#cc0f0f#c4c2c2"
	greyscale_config = /datum/greyscale_config/boots/christmasboots
	greyscale_config_worn = /datum/greyscale_config/boots/christmasboots/worn
	greyscale_config_worn_digitigrade = /datum/greyscale_config/boots/christmasboots/worn/digi
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/shoes/winterboots/christmas/green
	name = "green christmas boots"
	desc = "A pair of fluffy green christmas boots!"
	greyscale_colors = "#1a991a#c4c2c2"

/obj/item/clothing/shoes/clown_shoes/pink
	name = "pink clown shoes"
	desc = "A particularly pink pair of punny shoes."
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/shoes.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/feet.dmi'
	icon_state = "pink_clown_shoes"

//Modular overide to give jackboots laces
/obj/item/clothing/shoes/jackboots
	can_be_tied = TRUE

/obj/item/clothing/shoes/colorable_laceups
	name = "laceup shoes"
	desc = "These don't seem to come pre-polished, how saddening."
	icon = 'monkestation/code/modules/blueshift/gags/icons/shoes/shoes.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/gags/icons/shoes/shoes.dmi'
	icon_state = "laceups"
	greyscale_colors = "#383631"
	greyscale_config = /datum/greyscale_config/laceup
	greyscale_config_worn = /datum/greyscale_config/laceup/worn
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/shoes/colorable_sandals
	name = "sandals"
	desc = "Rumor has it that wearing these with socks puts you on a no entry list in several sectors."
	icon = 'monkestation/code/modules/blueshift/gags/icons/shoes/shoes.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/gags/icons/shoes/shoes.dmi'
	icon_state = "sandals"
	greyscale_colors = "#383631"
	greyscale_config = /datum/greyscale_config/sandals
	greyscale_config_worn = /datum/greyscale_config/sandals/worn
	greyscale_config_worn_digitigrade = /datum/greyscale_config/sandals/worn/digi
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/shoes/jackboots/recolorable
	icon = 'monkestation/code/modules/blueshift/gags/icons/shoes/shoes.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/gags/icons/shoes/shoes.dmi'
	icon_state = "boots"
	greyscale_colors = "#383631"
	greyscale_config = /datum/greyscale_config/boots
	greyscale_config_worn = /datum/greyscale_config/boots/worn
	greyscale_config_worn_digitigrade = /datum/greyscale_config/boots/worn/digi
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/shoes/wraps/cloth
	name = "cloth foot wraps"
	desc = "Boxer tape or bandages wrapped like a mummy, all left up to the choice of the wearer."
	icon_state = "clothwrap"
	greyscale_config = /datum/greyscale_config/clothwraps
	greyscale_config_worn = /datum/greyscale_config/clothwraps/worn
	greyscale_config_worn_digitigrade = /datum/greyscale_config/clothwraps/worn/digi
	greyscale_colors = "#FFFFFF"
	body_parts_covered = FALSE
	flags_1 = IS_PLAYER_COLORABLE_1
