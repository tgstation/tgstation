
/obj/item/clothing/under/rank/civilian/mime
	name = "mime's outfit"
	desc = "It's not very colourful."
	icon_state = "mime"
	inhand_icon_state = null

/obj/item/clothing/under/rank/civilian/mime/skirt
	name = "mime's skirt"
	desc = "It's not very colourful."
	icon_state = "mime_skirt"
	inhand_icon_state = null
	body_parts_covered = CHEST|GROIN|ARMS
	dying_key = DYE_REGISTRY_JUMPSKIRT
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/civilian/mime/sexy
	name = "sexy mime outfit"
	desc = "Pretty inappropriate for a circus."
	icon_state = "sexymime"
	inhand_icon_state = null
	body_parts_covered = CHEST|GROIN|LEGS
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	can_adjust = FALSE

/obj/item/clothing/under/rank/civilian/clown
	name = "clown suit"
	desc = "<i>'HONK!'</i>"
	icon_state = "clown"
	inhand_icon_state = "clown"
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	can_adjust = FALSE
	supports_variations_flags = CLOTHING_NO_VARIATION

/obj/item/clothing/under/rank/civilian/clown/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/squeak, list('sound/items/bikehorn.ogg'=1), 50, falloff_exponent = 20) //die off quick please
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_CLOWN, CELL_VIRUS_TABLE_GENERIC, rand(2,3), 0)

/obj/item/clothing/under/rank/civilian/clown/blue
	name = "blue clown suit"
	desc = "<i>'BLUE HONK!'</i>"
	icon_state = "blueclown"
	inhand_icon_state = "blueclown"

/obj/item/clothing/under/rank/civilian/clown/green
	name = "green clown suit"
	desc = "<i>'GREEN HONK!'</i>"
	icon_state = "greenclown"
	inhand_icon_state = "greenclown"

/obj/item/clothing/under/rank/civilian/clown/yellow
	name = "yellow clown suit"
	desc = "<i>'YELLOW HONK!'</i>"
	icon_state = "yellowclown"
	inhand_icon_state = "yellowclown"

/obj/item/clothing/under/rank/civilian/clown/purple
	name = "purple clown suit"
	desc = "<i>'PURPLE HONK!'</i>"
	icon_state = "purpleclown"
	inhand_icon_state = "purpleclown"

/obj/item/clothing/under/rank/civilian/clown/orange
	name = "orange clown suit"
	desc = "<i>'ORANGE HONK!'</i>"
	icon_state = "orangeclown"
	inhand_icon_state = "orangeclown"

/obj/item/clothing/under/rank/civilian/clown/rainbow
	name = "rainbow clown suit"
	desc = "<i>'R A I N B O W HONK!'</i>"
	icon_state = "rainbowclown"
	inhand_icon_state = "rainbowclown"

/obj/item/clothing/under/rank/civilian/clown/jester
	name = "jester suit"
	desc = "A jolly dress, well suited to entertain your master, nuncle."
	icon_state = "jester_map"
	greyscale_colors = "#00ff00#ff0000"
	greyscale_config = /datum/greyscale_config/jester_suit
	greyscale_config_worn = /datum/greyscale_config/jester_suit/worn
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/under/rank/civilian/clown/jesteralt
	name = "jester suit"
	desc = "A jolly dress, well suited to entertain your master, nuncle."
	icon_state = "jester2"

/obj/item/clothing/under/rank/civilian/clown/sexy
	name = "sexy-clown suit"
	desc = "It makes you look HONKable!"
	icon_state = "sexyclown"
	inhand_icon_state = null
