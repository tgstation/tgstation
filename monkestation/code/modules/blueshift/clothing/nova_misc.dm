//DO NOT ADD TO THIS FILE UNLESS THE SITUATION IS DIRE
//MISC FILES = UNSORTED FILES. EVEN TG HATES THIS ONE.

/obj/item/clothing/under/misc
	worn_icon_digitigrade = 'monkestation/code/modules/blueshift/icons/mob/clothing/under/misc_digi.dmi'

/obj/item/clothing/under/misc/nova
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/under/misc.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/under/misc.dmi'
	can_adjust = FALSE

/*
	Do we even bother sorting these? We don't want to use the file, it's for emergencies and in-betweens.
	Just... don't lose your stuff.
*/

/obj/item/clothing/under/misc/nova/taccas
	name = "tacticasual uniform"
	desc = "A white wifebeater on top of some cargo pants. For when you need to carry various beers."
	icon_state = "tac_s"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION

/obj/item/clothing/under/misc/nova/mechanic
	name = "mechanic's overalls"
	desc = "An old-fashioned pair of brown overalls, along with assorted pockets and belt-loops."
	icon_state = "mechanic"

/obj/item/clothing/under/misc/nova/utility
	name = "general utility uniform"
	desc = "A utility uniform worn by civilian-ranked crew."
	icon_state = "utility"
	body_parts_covered = CHEST|ARMS|GROIN|LEGS
	can_adjust = FALSE

/obj/item/clothing/under/misc/nova/utility/syndicate
	armor_type = /datum/armor/clothing_under/utility_syndicate
	has_sensor = NO_SENSORS

/datum/armor/clothing_under/utility_syndicate
	melee = 10
	fire = 50
	acid = 40

/obj/item/clothing/suit/wornshirt
	name = "worn shirt"
	desc = "A worn out (or perhaps just baggy), curiously comfortable t-shirt."
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/suits.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/suit.dmi'
	icon_state = "wornshirt"
	inhand_icon_state = "labcoat"
	body_parts_covered = CHEST|GROIN
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/suit/dutchjacketsr
	name = "western jacket"
	desc = "Botanists screaming of mangos have been rumored to wear this."
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/suits.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/suit.dmi'
	icon_state = "dutchjacket"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON


/obj/item/clothing/suit/toggle/trackjacket
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/suits.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/suit.dmi'
	worn_icon_digitigrade = 'monkestation/code/modules/blueshift/icons/mob/clothing/suit.dmi'
	name = "track jacket"
	desc = "A black jacket with blue stripes for the athletic. It is also popular among russian delinquents."
	icon_state = "trackjacket"
	toggle_noun = "zipper"

/obj/item/clothing/suit/frenchtrench
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/suits.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/suit.dmi'
	name = "blue trenchcoat"
	icon_state = "frenchtrench"
	desc = "There's a certain timeless feeling to this coat, like it was once worn by a romantic, broken through his travels, from a schemer who hunted injustice to a traveller, however it arrived in your hands? Who knows?"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/suit/victoriantailcoatbutler
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/suits.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/suit.dmi'
	name = "caretaker tailcoat"
	desc = "You've ALWAYS been the Caretaker. I ought to know, I've ALWAYS been here."
	icon_state = "victorian_tailcoat"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/suit/koreacoat
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/suits.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/suit.dmi'
	name = "eastern winter coat"
	desc = "War makes people cold, not just on the inside, but on the outside as well... luckily this coat's not seen any hardships like that, and is actually quite warm!"
	icon_state = "chi_korea_coat"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	body_parts_covered = CHEST|GROIN|ARMS
	cold_protection = CHEST|GROIN|ARMS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT

/obj/item/clothing/suit/modernwintercoatthing
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/suits.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/suit.dmi'
	name = "modern winter coat"
	desc = "Warm and comfy, the inner fur seems to be removable, not this one though, someone's sewn it in and left the buttons!"
	icon_state = "modern_winter"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	body_parts_covered = CHEST|GROIN|ARMS
	cold_protection = CHEST|GROIN|ARMS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT

/obj/item/clothing/suit/toggle/jacket/cardigan
	name = "cardigan"
	desc = "It's like, half a jacket."
	icon_state = "cardigan"
	greyscale_config = /datum/greyscale_config/cardigan
	greyscale_config_worn = /datum/greyscale_config/cardigan/worn
	greyscale_colors = "#FFFFFF"
	flags_1 = IS_PLAYER_COLORABLE_1
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/suit/toggle/jacket/cardigan/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/toggle_clothes, "cardigan_t")

/obj/item/clothing/suit/discoblazer
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/suits.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/suit.dmi'
	name = "disco ass blazer"
	desc = "Looks like someone skinned this blazer off some long extinct disco-animal. It has an enigmatic white rectangle on the back and the right sleeve."
	icon_state = "jamrock_blazer"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/suit/kimjacket
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/suits.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/suit.dmi'
	name = "aerostatic bomber jacket"
	desc = "A jacket once worn by the Air Force during the Antecentennial Revolution, there are quite a few pockets on the inside, mostly for storing notebooks and compasses."
	icon_state = "aerostatic_bomber_jacket"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/suit/blackfurrich
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/suits.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/suit.dmi'
	name = "expensive black fur coat"
	desc = "Ever thought to yourself 'I'm a rich bitch, but I haven't GOT the Mafia Princess look?' Well thanks to the tireless work of underpaid slave labour in Space China, your dreams of looking like a bitch have been fulfilled, like a Genie with a sweatshop."
	icon_state = "expensivecoat"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	body_parts_covered = CHEST|GROIN|ARMS
	cold_protection = CHEST|GROIN|ARMS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT

/obj/item/clothing/suit/brownbattlecoat
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/suits.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/suit.dmi'
	name = "expensive brown fur coat"
	desc = "There is nothing more valuable, nothing more sacred, look at the fur lining, it's beautiful, when you cruse through Necropolis in this thing, you're gonna be balls deep in Ash Walker snatch."
	icon_state = "battlecoat"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	body_parts_covered = CHEST|GROIN|ARMS
	cold_protection = CHEST|GROIN|ARMS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT

/obj/item/clothing/suit/brownfurrich
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/suits.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/suit.dmi'
	name = "quartermaster fur coat"
	desc = "Cargonia, or if you're a dork, Cargoslavia has shipped out a coat for loyal quartermasters, despite accusations it's just a dyed black fur coat, it's...not, promise!"
	icon_state = "winter_coat"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	body_parts_covered = CHEST|GROIN|ARMS
	cold_protection = CHEST|GROIN|ARMS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	armor_type = /datum/armor/suit_brownfurrich

/datum/armor/suit_brownfurrich
	melee = 10
	bullet = 10

/obj/item/clothing/suit/brownfurrich/public
	name = "fur coat"
	desc = "A lavishly cosy furr coat, made with 100% recycled carbon!"

/obj/item/clothing/suit/brownfurrich/white
	name = "white fur coat"
	desc = "A lavishly cosy furr coat, made with 100% recycled carbon!"
	icon_state = "winter_coat_white"

/obj/item/clothing/suit/brownfurrich/cream
	name = "cream fur coat"
	desc = "A lavishly cosy furr coat, made with 100% recycled carbon!"
	icon_state = "winter_coat_cream"

/obj/item/clothing/suit/fallsparka
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/suits.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/suit.dmi'
	name = "falls parka"
	desc = "A light brown coat with light fur lighting around the collar."
	icon_state = "fallsparka"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	body_parts_covered = CHEST|GROIN|ARMS
	cold_protection = CHEST|GROIN|ARMS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT

/obj/item/clothing/suit/british_officer
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/suits.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/suit.dmi'
	name = "british officers coat"
	desc = "Whether you're commanding a colonial crusade or commanding a battalion for the British Empire, this coat will suit you."
	icon_state = "british_officer"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	body_parts_covered = CHEST|GROIN|ARMS
	cold_protection = CHEST|GROIN|ARMS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	armor_type = /datum/armor/suit_british_officer

/datum/armor/suit_british_officer
	melee = 10
	bullet = 10

/obj/item/clothing/suit/modern_winter
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/suits.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/suit.dmi'
	name = "modern winter coat"
	desc = "A comfy modern winter coat."
	icon_state = "modern_winter"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	body_parts_covered = CHEST|GROIN|ARMS
	cold_protection = CHEST|GROIN|ARMS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT

/obj/item/clothing/suit/woolcoat
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/suits.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/suit.dmi'
	name = "wool coat"
	desc = "A fine coat made from the richest of wool."
	icon_state = "woolcoat"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	body_parts_covered = CHEST|GROIN|ARMS


/obj/item/clothing/suit/gautumn
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/suits.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/suit.dmi'
	name = "neo american general's coat"
	desc = "In stark contrast to the undersuit, this large and armored coat is as white as snow, perfect for the bloodstains."
	icon_state = "soldier"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	body_parts_covered = CHEST|GROIN|ARMS
	cold_protection = CHEST|GROIN|ARMS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	armor_type = /datum/armor/suit_gautumn

/datum/armor/suit_gautumn
	melee = 10
	bullet = 10
	laser = 20
	energy = 20

/obj/item/clothing/suit/autumn
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/suits.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/suit.dmi'
	name = "neo american officer's coat"
	desc = "In stark contrast to the undersuit, this coat is a greeny white colour, layered with slight protection against bullets and melee weapons."
	icon_state = "autumn"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	body_parts_covered = CHEST|GROIN|ARMS
	cold_protection = CHEST|GROIN|ARMS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	armor_type = /datum/armor/suit_autumn

/datum/armor/suit_autumn
	melee = 10
	bullet = 10

/obj/item/clothing/suit/texas
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/suits.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/suit.dmi'
	name = "white suit coat"
	desc = "A white suit coat, perfect for fat oil barons."
	icon_state = "texas"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	body_parts_covered = CHEST|ARMS

/obj/item/clothing/suit/cossack
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/suits.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/suit.dmi'
	name = "ukrainian coat"
	desc = "Hop on your horse, dawn your really fluffy hat, and strap this coat to your back."
	icon_state = "kuban_cossak"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/suit/corgisuit/en
	name = "\improper super-hero E-N suit"
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/suits.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/suit.dmi'
	icon_state = "ensuit"
	supports_variations_flags = NONE

/obj/item/clothing/suit/trenchbrown
	name = "brown trenchcoat"
	desc = "A brown noir-inspired coat. Looks best if you're not wearing it over a baggy t-shirt."
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/suits.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/suit.dmi'
	icon_state = "brtrenchcoat"
	body_parts_covered = CHEST|ARMS

/obj/item/clothing/suit/trenchblack
	name = "black trenchcoat"
	desc = "A matte-black coat. Best suited for space-italians, or maybe a monochrome-cop."
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/suits.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/suit.dmi'
	icon_state = "bltrenchcoat"
	body_parts_covered = CHEST|ARMS

/obj/item/clothing/suit/apron/chef/colorable_apron
	name = "apron"
	desc = "A basic apron."
	icon = 'monkestation/code/modules/blueshift/gags/icons/suit/suit.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/gags/icons/suit/suit.dmi'
	icon_state = "apron"
	greyscale_colors = "#ffffff"
	greyscale_config = /datum/greyscale_config/apron
	greyscale_config_worn = /datum/greyscale_config/apron/worn
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/suit/apron/overalls/Initialize(mapload)
	. = ..()
	allowed += list(
		/obj/item/flashlight,
		/obj/item/lighter,
		/obj/item/modular_computer/pda,
		/obj/item/radio,
		/obj/item/storage/bag/books,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/tank/internals/plasmaman,
		/obj/item/toy,
		/obj/item/analyzer,
		/obj/item/construction/rcd,
		/obj/item/fireaxe/metal_h2_axe,
		/obj/item/pipe_dispenser,
		/obj/item/storage/bag/construction,
		/obj/item/t_scanner,
	)

/obj/item/clothing/suit/warm_sweater
	name = "warm sweater"
	desc = "A comfortable warm-looking sweater."
	icon_state = "warm_sweater"
	greyscale_config = /datum/greyscale_config/warm_sweater
	greyscale_config_worn = /datum/greyscale_config/warm_sweater/worn
	greyscale_colors = "#867361"
	flags_1 = IS_PLAYER_COLORABLE_1
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/suit/heart_sweater
	name = "heart sweater"
	desc = "A comfortable warm-looking sweater. It even has a heart pattern on it, how cute."
	icon_state = "heart_sweater"
	greyscale_config = /datum/greyscale_config/heart_sweater
	greyscale_config_worn = /datum/greyscale_config/heart_sweater/worn
	greyscale_colors = "#867361#8f3a3a"
	flags_1 = IS_PLAYER_COLORABLE_1
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
