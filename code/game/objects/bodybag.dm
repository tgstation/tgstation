//Thank you BS12! For the sprites as well. -Petethegoat

//folded bodybag (for boxes)
obj/item/bodybag
	icon = 'bodybag.dmi'
	icon_state = "folded"
	desc = "A folded body bag designed to contain those with a less fortunate fate."
	name = "body bag"

	attack_self(mob/user)
		var/obj/item/bodybag/unfolded/R = new /obj/item/bodybag/unfolded(user.loc)
		R.add_fingerprint(user)
		del(src)

//unfolded, real world bodybag
obj/item/bodybag/unfolded
	icon = 'bodybag.dmi'
	icon_state = "b00"
	desc = "A body bag designed to contain those with a less fortunate fate."
	name = "body bag"
	var/mob/captured
	var/writhe_time = 0
	var/open = 0

obj/item/bodybag/unfolded/attack_hand(mob/user)
	add_fingerprint(user)

	if(open)
		close()
	else
		open()

obj/item/bodybag/unfolded/proc/open()
	if(captured)
		captured.loc = src.loc
		captured = null

	for (var/obj/item/I in src)
		I.loc = src.loc

	open = 1
	UpdateIcon()

//Bug alert! Somehow this seems to pick up bodybag boxes (and only bodybag boxes) in the tiles south, southwest, and west of itself.
//A bajillion points if you can fix it. -Petethegoat
obj/item/bodybag/unfolded/proc/close()
	for (var/obj/item/I in src.loc)
		if (!I.anchored)
			I.loc = src

	for(var/mob/M in src.loc)
		if(M.lying)
			captured = M
			M.loc = src
			break
	open = 0
	UpdateIcon()

obj/item/bodybag/unfolded/proc/UpdateIcon()
	icon_state = "b[open][captured?"1":"0"]"
	return

//mouthwatering copypasta from morgue trays
/obj/item/bodybag/unfolded/attackby(P as obj, mob/user as mob)
	if (istype(P, /obj/item/weapon/pen))
		var/t = input(user, "What would you like the label to be?", text("[]", src.name), null)  as text
		if (user.equipped() != P)
			return
		if (!in_range(src, user) && src.loc != user)
			return
		t = copytext(sanitize(t),1,MAX_MESSAGE_LEN)
		if (t)
			src.name = t
		else
			src.name = "body bag"
	add_fingerprint(user)
	return

