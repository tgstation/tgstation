#define MAX_STICKER_COUNT 15

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

	item_flags = NOBLUDGEON | XENOMORPH_HOLDABLE //funny ~Jimmyl
	w_class = WEIGHT_CLASS_TINY

	/// `list` or `null`, contains possible alternate `icon_states`.
	var/list/icon_states
	/// Whether sticker is legal and allowed to generate inside non-syndicate boxes.
	var/contraband = FALSE

/obj/item/sticker/Initialize(mapload)
	. = ..()

	if(length(icon_states))
		icon_state = pick(icon_states)

/obj/item/sticker/Bump(atom/bumped_atom)
	if(prob(50) && attempt_attach(bumped_atom))
		bumped_atom.balloon_alert_to_viewers("sticker landed on sticky side!")

/obj/item/sticker/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!isatom(interacting_with))
		return NONE

	var/cursor_x = text2num(LAZYACCESS(modifiers, ICON_X))
	var/cursor_y = text2num(LAZYACCESS(modifiers, ICON_Y))

	if(isnull(cursor_x) || isnull(cursor_y))
		return NONE

	if(attempt_attach(interacting_with, user, cursor_x, cursor_y))
		return ITEM_INTERACT_SUCCESS

	return NONE

/**
 * Attempts to attach sticker to an object. Returns `FALSE` if atom has more than
 * `MAX_STICKER_COUNT` stickers, `TRUE` otherwise. If no `px` or `py` were passed
 * picks random coordinates based on a `target`'s icon.
 */
/obj/item/sticker/proc/attempt_attach(atom/target, mob/user, px, py)
	if(COUNT_TRAIT_SOURCES(target, TRAIT_STICKERED) >= MAX_STICKER_COUNT)
		balloon_alert_to_viewers("sticker won't stick!")
		return FALSE

	if(isnull(px) || isnull(py))
		var/icon/target_mask = icon(target.icon, target.icon_state)

		if(isnull(px))
			px = rand(1, target_mask.Width())

		if(isnull(py))
			py = rand(1, target_mask.Height())

	if(!isnull(user))
		user.do_attack_animation(target, used_item = src)
		target.balloon_alert(user, "sticker sticked")
		var/mob/living/victim = target
		if(istype(victim) && !isnull(victim.client))
			user.log_message("stuck [src] to [key_name(victim)]", LOG_ATTACK)
			victim.log_message("had [src] stuck to them by [key_name(user)]", LOG_ATTACK)

	target.AddComponent(/datum/component/sticker, src, get_dir(target, src), px, py)
	return TRUE

#undef MAX_STICKER_COUNT

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

/obj/item/sticker/anti_skub
	name = "anti-skub sticker"
	icon_state = "anti_skub"

/obj/item/sticker/syndicate
	name = "syndicate sticker"
	icon_state = "synd"
	contraband = TRUE

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
