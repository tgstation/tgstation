/**
 * What stickers can do?
 *
 * - They can be attached to any object.
 * - They inherit cursor position when attached.
 * - They are unclickable by mouse, I suppose?
 * - They can be washed off.
 * - They can be burnt off.
 * - They can be attached to the object they collided with.
 * - They play "attack" animation when attached.
 *
 */

/obj/item/sticker
	name = "sticker"
	desc = "A sticker with some strong adhesive on the back, sticks to stuff!"

	icon = 'icons/obj/toys/stickers.dmi'

	max_integrity = 50
	resistance_flags = FLAMMABLE

	throw_range = 3
	pressure_resistance = 0

	item_flags = NOBLUDGEON
	w_class = WEIGHT_CLASS_TINY

	/// `list` or `null`, contains possible alternate `icon_states`.
	var/list/icon_states
	/// This sticker won't be generated inside random sticker packs.
	var/exclude_from_random = FALSE
	/// Text added to the atom's examine when stickered.
	var/examine_text

/obj/item/sticker/Initialize(mapload)
	. = ..()
	if(length(icon_states))
		icon_state = pick(icon_states)
	AddElement(/datum/element/stickerable, 15, examine_text)

/obj/item/sticker/smile
	name = "smiley sticker"
	icon_state = "smile"

/obj/item/sticker/frown
	name = "frowny sticker"
	icon_state = "frown"

/obj/item/sticker/left_arrow
	name = "left arrow sticker"
	icon_state = "arrow-left"

/obj/item/sticker/right_arrow
	name = "right arrow sticker"
	icon_state = "arrow-right"

/obj/item/sticker/star
	name = "star sticker"
	icon_state = "star"

/obj/item/sticker/heart
	name = "heart sticker"
	icon_state = "heart"

/obj/item/sticker/googly
	name = "googly eye sticker"
	icon_state = "googly"
	icon_states = list("googly", "googly-alt")

/obj/item/sticker/rev
	name = "blue R sticker"
	desc = "A sticker of FUCK THE SYSTEM, the galaxy's premiere hardcore punk band."
	icon_state = "revhead"
	examine_text = "There is a sticker displaying <b>FUCK THE SYSTEM</b>, the galaxy's premiere hardcore punk band."

/obj/item/sticker/pslime
	name = "slime plushie sticker"
	icon_state = "pslime"

/obj/item/sticker/pliz
	name = "lizard plushie sticker"
	icon_state = "plizard"

/obj/item/sticker/pbee
	name = "bee plushie sticker"
	icon_state = "pbee"

/obj/item/sticker/psnake
	name = "snake plushie sticker"
	icon_state = "psnake"

/obj/item/sticker/robot
	name = "bot sticker"
	icon_state = "tile"
	icon_states = list("tile", "medbot", "clean")

/obj/item/sticker/toolbox
	name = "toolbox sticker"
	icon_state = "soul"

/obj/item/sticker/chief_engineer
	name = "CE approved sticker"
	icon_state = "ce_approved"
	exclude_from_random = TRUE
	examine_text = "There is a sticker displaying the <b>Chief Engineer's SEAL OF APPROVAL.</b>"

/obj/item/sticker/clown
	name = "clown sticker"
	icon_state = "honkman"

/obj/item/sticker/mime
	name = "mime sticker"
	icon_state = "silentman"

/obj/item/sticker/assistant
	name = "assistant sticker"
	icon_state = "tider"

/obj/item/sticker/skub
	name = "skub sticker"
	icon_state = "skub"
	examine_text = "There is a sticker displaying <b>Skubtide, Stationwide!</b>"

/obj/item/sticker/anti_skub
	name = "anti-skub sticker"
	icon_state = "anti_skub"
	examine_text = "There is an <b>anti-skub</b> sticker."

/obj/item/sticker/syndicate
	name = "syndicate sticker"
	icon_state = "synd"
	exclude_from_random = TRUE

/obj/item/sticker/syndicate/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_CONTRABAND, INNATE_TRAIT)

/obj/item/sticker/syndicate/c4
	name = "C-4 sticker"
	icon_state = "c4"

/obj/item/sticker/syndicate/bomb
	name = "syndicate bomb sticker"
	icon_state = "sbomb"

/obj/item/sticker/syndicate/apc
	name = "broken APC sticker"
	icon_state = "milf"

/obj/item/sticker/syndicate/larva
	name = "larva sticker"
	icon_state = "larva"

/obj/item/sticker/syndicate/cult
	name = "bloody paper sticker"
	icon_state = "cult"

/obj/item/sticker/syndicate/flash
	name = "flash sticker"
	icon_state = "flash"

/obj/item/sticker/syndicate/op
	name = "operative sticker"
	icon_state = "newcop"

/obj/item/sticker/syndicate/trap
	name = "bear trap sticker"
	icon_state = "trap"

/obj/item/sticker/purity_seal
	name = "purity seal"
	icon_state = "purity_seal_1"
	desc =  "Looking closer, you realize it's actually a mass produced sticker. You suppose it's the holiness that counts."

/obj/item/sticker/purity_seal/purity_seal_2
	icon_state = "purity_seal_2"
