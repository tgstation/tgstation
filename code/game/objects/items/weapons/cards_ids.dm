/*
CONTAINS:
DATA CARD
ID CARD
FINGERPRINT CARD HOLDER
FINGERPRINT CARD
*/

/obj/item/weapon/card
	name = "card"
	desc = "Does card things."
	icon = 'card.dmi'
	w_class = 1.0

	var/list/files = list(  )

/obj/item/weapon/card/emag
	desc = "An identification card. Seems to have some funny chip on it, though."
	name = "modified identification card"
	icon_state = "emag"
	item_state = "card-id"
	origin_tech = "magnets=2;syndicate=2"
	var/uses = 5

	New()
		..()
		uses = rand(3,5)
		return

// DATA CARDS
/obj/item/weapon/card/data
	name = "data disk"
	desc = "A disk with data."
	icon_state = "data"
	var/function = "storage"
	var/data = "null"
	var/special = null
	item_state = "card-id"

/obj/item/weapon/card/data/verb/label(t as text)
	set name = "Label Disk"
	set category = "Object"
	set src in usr

	if (t)
		src.name = text("Data Disk- '[]'", t)
	else
		src.name = "Data Disk"
	src.add_fingerprint(usr)
	return


// ID CARDS
/obj/item/weapon/card/id
	name = "identification card"
	desc = "An identification card."
	icon_state = "id"
	item_state = "card-id"
	var/access = list()
	var/registered_name = null // The name registered on the card
	var/assignment = null
	var/obj/item/weapon/photo/PHOTO = null
	var/over_jumpsuit = 1 // If set to 0, it won't display on top of the mob's jumpsuit
	var/dorm = 0    // determines if this ID has claimed a dorm already

/obj/item/weapon/card/id/gold
	name = "identification card"
	desc = "A golden identification card."
	icon_state = "gold"
	item_state = "gold_id"

/obj/item/weapon/card/id/captains_spare
	name = "Captain's spare ID"
	icon_state = "gold"
	item_state = "gold_id"
	registered_name = "Captain"
	assignment = "Captain"
	New()
		access = get_access("Captain")
		..()

/obj/item/weapon/card/id/centcom
	name = "CentCom ID"
	desc = "An ID straight from Cent. Com."
	icon_state = "centcom"
	registered_name = "Central Command"
	assignment = "General"
	New()
		access = get_all_centcom_access()
		..()

/obj/item/weapon/card/id/syndicate
	name = "agent card"
	desc = "Shhhhh."
	access = list(access_maint_tunnels)
	origin_tech = "syndicate=3"

/obj/item/weapon/card/id/syndicate_command
	name = "Syndicate ID card"
	desc = "An ID straight from the Syndicate."
	registered_name = "Syndicate"
	assignment = "Syndicate Overlord"
	access = list(access_syndicate)


/obj/item/weapon/card/id/attack_self(mob/user as mob)
	for(var/mob/O in viewers(user, null))
		O.show_message(text("[] shows you: \icon[] []: assignment: []", user, src, src.name, src.assignment), 1)

	src.add_fingerprint(user)
	return

/obj/item/weapon/card/id/verb/read()
	set name = "Read ID Card"
	set category = "Object"
	set src in usr

	usr << text("\icon[] []: The current assignment on the card is [].", src, src.name, src.assignment)
	return

/obj/item/weapon/card/id/syndicate/attack_self(mob/user as mob)
	src.registered_name = input(user, "What name would you like to put on this card?", "Agent card name", ishuman(user) ? user.real_name : user.name)
	src.assignment = input(user, "What occupation would you like to put on this card?\nNote: This will not grant any access levels other than Maintenance.", "Agent card job assignment", "Assistant")
	src.name = "[src.registered_name]'s ID Card ([src.assignment])"
	user << "\blue You successfully forge the ID card."

/obj/item/weapon/card/id/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if(istype(W,/obj/item/weapon/photo))
		if(!(PHOTO))
			src.PHOTO = W
			usr.before_take_item(W)
			W.loc = src
			//src.orient2hud(usr)
			add_fingerprint(usr)
			usr << "\blue You add the photo to the ID."
		else
			usr << "\blue There is already a photo on this ID."

			//PHOTO.loc = locate(0,0,0)

/obj/item/weapon/card/id/verb/removePhoto()
	set name = "Remove Photo From ID"
	set category = "Object"

	if(PHOTO)
		contents -= PHOTO
		PHOTO.loc = usr.loc
		PHOTO.layer = 3
		PHOTO = null
	else
		usr << "\blue There is no photo to remove."


// FINGERPRINT HOLDER

/obj/item/weapon/fcardholder/attack_self(mob/user as mob)
	var/dat = "<B>Clipboard</B><BR>"
	for(var/obj/item/weapon/f_card/P in src)
		dat += text("<A href='?src=\ref[];read=\ref[]'>[]</A> <A href='?src=\ref[];remove=\ref[]'>Remove</A><BR>", src, P, P.name, src, P)
	user << browse(dat, "window=fcardholder")
	onclose(user, "fcardholder")
	return

/obj/item/weapon/fcardholder/Topic(href, href_list)
	..()
	if ((usr.stat || usr.restrained()))
		return
	if (usr.contents.Find(src))
		usr.machine = src
		if (href_list["remove"])
			var/obj/item/P = locate(href_list["remove"])
			if ((P && P.loc == src))
				if ((usr.hand && !( usr.l_hand )))
					usr.l_hand = P
					P.loc = usr
					P.layer = 20
					usr.update_clothing()
				else
					if (!( usr.r_hand ))
						usr.r_hand = P
						P.loc = usr
						P.layer = 20
						usr.update_clothing()
				src.add_fingerprint(usr)
				P.add_fingerprint(usr)
			src.update()
		if (href_list["read"])
			var/obj/item/weapon/f_card/P = locate(href_list["read"])
			if ((P && P.loc == src))
				if (!( istype(usr, /mob/living/carbon/human) ))
					usr << browse(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", P.name, P.display()), text("window=[]", P.name))
					onclose(usr, "[P.name]")
				else
					usr << browse(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", P.name, P.display()), text("window=[]", P.name))
					onclose(usr, "[P.name]")
			src.add_fingerprint(usr)
		if (ismob(src.loc))
			var/mob/M = src.loc
			if (M.machine == src)
				spawn( 0 )
					src.attack_self(M)
					return
	return

/obj/item/weapon/fcardholder/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/item/weapon/fcardholder/attack_hand(mob/user as mob)
	if (user.contents.Find(src))
		spawn( 0 )
			src.attack_self(user)
			return
		src.add_fingerprint(user)
	else
		return ..()
	return

/obj/item/weapon/fcardholder/attackby(obj/item/weapon/P as obj, mob/user as mob)
	..()
	if (istype(P, /obj/item/weapon/f_card))
		if (src.contents.len < 30)
			user.drop_item()
			P.loc = src
			add_fingerprint(user)
			src.add_fingerprint(user)
		else
			user << "\blue Not enough space!!!"
	else
		if (istype(P, /obj/item/weapon/pen))
			var/t = input(user, "Holder Label:", text("[]", src.name), null)  as text
			if (user.equipped() != P)
				return
			if ((!in_range(src, usr) && src.loc != user))
				return
			t = copytext(sanitize(t),1,MAX_MESSAGE_LEN)
			if (t)
				src.name = text("FPCase- '[]'", t)
			else
				src.name = "Finger Print Case"
		else
			return
	src.update()
	spawn( 0 )
		attack_self(user)
		return
	return

/obj/item/weapon/fcardholder/proc/update()
	var/i = 0
	for(var/obj/item/weapon/f_card/F in src)
		i = 1
		break
	src.icon_state = text("fcardholder[]", (i ? "1" : "0"))
	return





// FINGERPRINT CARD


/obj/item/weapon/f_card/examine()
	set src in view(2)

	..()
	usr << text("\blue There are [] on the stack!", src.amount)
	usr << browse(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", src.name, display()), text("window=[]", src.name))
	onclose(usr, "[src.name]")
	return

/obj/item/weapon/f_card/proc/display()

	if (length(src.fingerprints))
		var/dat = "<B>Fingerprints on Card</B><HR>"
		for(var/i = 1, i < (src.fingerprints.len + 1), i++)
			var/list/L = params2list(src.fingerprints[i])
			dat += text("[]<BR>", L["1"])
			//Foreach goto(41)
		return dat
	else
		return "<B>There are no fingerprints on this card.</B>"
	return

/obj/item/weapon/f_card/attack_hand(mob/user as mob)

	if ((user.r_hand == src || user.l_hand == src))
		src.add_fingerprint(user)
		var/obj/item/weapon/f_card/F = new /obj/item/weapon/f_card( user )
		F.amount = 1
		src.amount--
		if (user.hand)
			user.l_hand = F
		else
			user.r_hand = F
		F.layer = 20
		F.add_fingerprint(user)
		if (src.amount < 1)
			//SN src = null
			del(src)
			return
	else
		..()
	return

/obj/item/weapon/f_card/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if (istype(W, /obj/item/weapon/f_card))
		if ((src.fingerprints || W.fingerprints))
			return
		if (src.amount == 10)
			return
		if (W:amount + src.amount > 10)
			src.amount = 10
			W:amount = W:amount + src.amount - 10
		else
			src.amount += W:amount
			//W = null
			del(W)
		src.add_fingerprint(user)
		if (W)
			W.add_fingerprint(user)
	else
		if (istype(W, /obj/item/weapon/pen))
			var/t = input(user, "Card Label:", text("[]", src.name), null)  as text
			if (user.equipped() != W)
				return
			if ((!in_range(src, usr) && src.loc != user))
				return
			t = copytext(sanitize(t),1,MAX_MESSAGE_LEN)
			if (t)
				src.name = text("FPrintC- '[]'", t)
			else
				src.name = "Finger Print Card"
			W.add_fingerprint(user)
			src.add_fingerprint(user)
	return

/obj/item/weapon/f_card/add_fingerprint()

	..()
	if (!istype(usr, /mob/living/silicon))
		if (src.fingerprints)
			if (src.amount > 1)
				var/obj/item/weapon/f_card/F = new /obj/item/weapon/f_card(get_turf(src))
				F.amount = --src.amount
				src.amount = 1
			src.icon_state = "fingerprint1"
	return