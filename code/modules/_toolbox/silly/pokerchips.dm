/* Stack type objects!
 * Contains:
 * 		Stacks
 *		Recipe datum
 */

/*
 * Stacks
 */
/obj/item/poker_chips
	name = "poker chips (5)"
	var/list/monomers = list(5, 25, 50, 100)
	var/value = 5
	icon = 'icons/oldschool/chips.dmi'

/obj/item/poker_chips/c25
	name = "poker chips (25)"
	value = 25

/obj/item/poker_chips/c50
	name = "poker chips (50)"
	value = 50

/obj/item/poker_chips/c100
	name = "poker chips (100)"
	value = 100

/obj/item/poker_chips/New()
	..()
	update_icon()

/obj/item/poker_chips/Destroy()
	if (usr && usr.machine==src)
		usr << browse(null, "window=pokerchips")
	return ..()

/obj/item/poker_chips/examine(mob/user)
	..()
	to_chat(user, "The value of these chips is [value].")

/obj/item/poker_chips/attack_self(mob/user)
	interact(user)

/obj/item/poker_chips/interact(mob/user)
	if (!src || value <= 0)
		user << browse(null, "window=pokerchips")
		return // t1 += " <A href='?src=\ref[src];make=[i];multiplier=[n]'>[n*R.res_amount]x</A>"
	user.set_machine(src) //for correct work of onclose
	var/t1 = "<HTML><HEAD><title>Poker Chips ([value])</title></HEAD><body><b>Poker Chips ([value])</b><br>"
	for(var/m in monomers)
		if (value >= m)
			t1 += "Take [m]-chip."
			for (var/m2 in list(1,2,3,5,10))
				if (value >= m * m2)
					t1 += " <a href='?src=\ref[src];take=[m * m2]'>x[m2]</a>"
			t1 += "<br>"

	t1 += "</body></HTML>"
	user << browse(t1, "window=pokerchips")
	onclose(user, "pokerchips")
	return

/obj/item/poker_chips/Topic(href, href_list)
	..()
	if (usr.restrained() || usr.stat || usr.get_active_held_item() != src)
		return
	if (href_list["take"])
		var/amt = text2num(href_list["take"])
		if (amt <= 0 || value < amt)
			return
		var/fnd = 0
		for(var/d in monomers)
			if (value % d == 0)
				fnd = 1
				break
		if (!fnd)
			return
		take(usr, amt)
		if (value == 0) qdel(src)

	if (src && usr.machine==src) //do not reopen closed window
		spawn( 0 )
			src.interact(usr)
			return
	return

/obj/item/poker_chips/proc/take(mob/user, amount)
	if (user.get_active_held_item() != src)
		return

	var/obj/I = user.get_inactive_held_item()
	if (istype(I, /obj/item/poker_chips))
		var/obj/item/poker_chips/chips = I
		chips.value += amount
		value -= amount
		update_icon()
		chips.update_icon()
		return

	if (I == null)
		var/obj/item/poker_chips/chips = new(user)
		chips.value = amount
		value -= amount
		user.put_in_hands(chips)
		update_icon()
		chips.update_icon()
		return

	var/obj/item/poker_chips/chips = new(user.loc)
	chips.value = amount
	value -= amount
	update_icon()
	chips.update_icon()

/obj/item/poker_chips/update_icon()
	if (value <= 0)
		qdel(src)
		return

	name = "poker chips ([value])"

	for(var/d in monomers)
		if(value == d)
			icon_state = "chip_[d]"
			return
	var/num = 0
	if (value < 25) num = 0
	else if (value < 50) num = 1
	else if (value < 100) num = 2
	else if (value < 150) num = 3
	else num = 4
	icon_state = "chipstack_[num]"

/obj/item/poker_chips/proc/merge(obj/item/poker_chips/chips) //Merge src into S, as much as possible
	if(QDELETED(chips) || chips == src) //amusingly this can cause a stack to consume itself, let's not allow that.
		return
	value += chips.value
	update_icon()
	qdel(chips)

/obj/item/poker_chips/Crossed(obj/o)
	if(istype(o, /obj/item/poker_chips) && !o.throwing)
		merge(o)
	return ..()

/obj/item/poker_chips/hitby(atom/movable/AM, skip, hitpush)
	if(istype(AM, /obj/item/poker_chips))
		merge(AM)
	return ..()

/obj/item/poker_chips/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/poker_chips))
		var/obj/item/poker_chips/chips = W
		chips.merge(src)
		to_chat(user, "<span class='notice'>You merge the chips.</span>")
	else
		return ..()
