/obj/item/sticker
	name = "sticker"
	desc = "it sticks to objects"

	icon = 'icons/obj/toys/stickers.dmi'
	icon_state = "plizard"

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

/obj/item/sticker/Initialize(mapload)
	. = ..()

	AddElement(/datum/element/atmos_sensitive)

/obj/item/sticker/Bump(atom/bumped_atom)
	if(prob(100))
		attach(bumped_atom)

/obj/item/sticker/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()

	if(!proximity_flag)
		return

	if(!(ismob(target) || isobj(target) || isturf(target)))
		return

	var/params = params2list(click_parameters)

	var/cursor_x = text2num(LAZYACCESS(params, ICON_X))
	var/cursor_y = text2num(LAZYACCESS(params, ICON_Y))

	if(isnull(cursor_x) || isnull(cursor_y))
		return FALSE

	attach(target, user, cursor_x, cursor_y)
	return TRUE

/obj/item/sticker/proc/attach(atom/target, mob/user, x, y)
	if(!(ismob(target) || isobj(target) || isturf(target)))
		return

	if(isnull(x))
		x = rand(0, world.icon_size)

	if(isnull(y))
		y = rand(0, world.icon_size)

	var/icon/sticker_icon = icon(icon, icon_state)

	var/pos_x = x - sticker_icon.Width() / 2
	var/pos_y = y - sticker_icon.Height() / 2

	if(!isnull(user))
		user.do_attack_animation(target, used_item = src)

	target.AddComponent(/datum/component/sticker, src, pos_x, pos_y)

/obj/item/sticker/proc/remove(atom/our_atom)
	forceMove(get_turf(our_atom))

/obj/item/sticker/should_atmos_process(datum/gas_mixture/air, exposed_temperature)
	return exposed_temperature >= 373

/obj/item/sticker/atmos_expose(datum/gas_mixture/air, exposed_temperature)
	new /obj/effect/decal/cleanable/ash(get_turf(src))
	qdel(src)
