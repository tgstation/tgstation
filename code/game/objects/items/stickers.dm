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
	desc = "it sticks to objects"

	icon = 'icons/obj/toys/stickers.dmi'
	icon_state = "plizard"

	w_class = WEIGHT_CLASS_TINY

	throw_range = 3

	pressure_resistance = 0

	resistance_flags = FLAMMABLE
	max_integrity = 50

	/// `list` or `null`, contains possible alternate `icon_states`.
	var/list/icon_states

/obj/item/sticker/Initialize(mapload)
	. = ..()

	if(length(icon_states))
		icon_state = pick(icon_states)

/obj/item/sticker/Bump(atom/bumped_atom)
	if(prob(100))
		attempt_attach(bumped_atom)

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

/obj/item/sticker/proc/attempt_attach(atom/target, mob/user, px, py)
	if(COUNT_TRAIT_SOURCES(target, TRAIT_STICKERED) >= MAX_STICKER_COUNT)
		return FALSE

	if(isnull(px))
		px = rand(1, world.icon_size)

	if(isnull(py))
		py = rand(1, world.icon_size)

	if(!isnull(user))
		user.do_attack_animation(target, used_item = src)

	user.balloon_alert(user, "sticker attached")
	target.AddComponent(/datum/component/sticker, src, user, get_dir(target, src), px, py)

#undef MAX_STICKER_COUNT
