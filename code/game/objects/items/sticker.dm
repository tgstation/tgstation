/// parent type for all other stickers. do not spawn directly
/obj/item/sticker
	name = "sticker"
	desc = "A sticker with some strong adhesive on the back, sticks to stuff!"
	item_flags = NOBLUDGEON | XENOMORPH_HOLDABLE //funny
	resistance_flags = FLAMMABLE
	icon = 'icons/obj/stickers.dmi'
	w_class = WEIGHT_CLASS_TINY
	throw_range = 3
	vis_flags = VIS_INHERIT_DIR | VIS_INHERIT_PLANE | VIS_INHERIT_LAYER
	///If not null, pick an icon_state from this list
	var/icon_states
	/// If the sticker should be disincluded from normal sticker boxes.
	var/contraband = FALSE

/obj/item/sticker/Initialize(mapload)
	. = ..()
	if(icon_states)
		icon_state = pick(icon_states)
	pixel_y = rand(-3,3)
	pixel_x = rand(-3,3)
	AddElement(/datum/element/sticker)

/obj/item/sticker/smile
	name = "smiley sticker"
	icon_state = "smile"

/obj/item/sticker/frown
	name = "frowny sticker"
	icon_state = "frown"

/obj/item/sticker/left_arrow
	name = "left arrow sticker"
	icon_state = "larrow"

/obj/item/sticker/right_arrow
	name = "right arrow sticker"
	icon_state = "rarrow"

/obj/item/sticker/star
	name = "star sticker"
	icon_state = "star1"
	icon_states = list("star1","star2")

/obj/item/sticker/heart
	name = "heart sticker"
	icon_state = "heart"

/obj/item/sticker/googly
	name = "googly eye sticker"
	icon_state = "googly1"
	icon_states = list("googly1","googly2")

/obj/item/sticker/rev
	name = "blue R sticker"
	desc = "A sticker of FUCK THE SYSTEM, the galaxy's premiere hardcore punk band."
	icon_state = "revhead"

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
	icon_states = list("tile","medbot","clean")

/obj/item/sticker/toolbox
	name = "toolbox sticker"
	icon_state = "toolbox"

/obj/item/sticker/clown
	name = "clown sticker"
	icon_state = "honkman"

/obj/item/sticker/mime
	name = "mime sticker"
	icon_state = "silentman"

/obj/item/sticker/assistant
	name = "assistant sticker"
	icon_state = "tider"

/obj/item/sticker/syndicate
	name = "syndicate sticker"
	icon_state = "synd"
	contraband = TRUE

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
