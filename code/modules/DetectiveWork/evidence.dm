//CONTAINS: Evidence bags

/obj/item/weapon/evidencebag
	name = "evidence bag"
	desc = "An empty evidence bag."
	icon = 'icons/obj/storage.dmi'
	icon_state = "evidenceobj"
	w_class = 1

/obj/item/weapon/evidencebag/afterattack(obj/item/O, mob/user as mob)
	if(!in_range(O,user))
		return

	if(istype(O, /obj/item/weapon/storage))
		return ..()

	if(!istype(O) || O.anchored == 1)
		user << "<span class='notice'>You can't put that inside \the [src]!</span>"
		return ..()

	if(istype(O, /obj/item/weapon/evidencebag))
		user << "<span class='notice'>You find putting an evidence bag in another evidence bag to be slightly absurd.</span>"
		return

	if(contents.len)
		user << "<span class='notice'>\The [src] already has something inside it.</span>"
		return ..()

	if(!isturf(O.loc)) //If it isn't on the floor. Do some checks to see if it's in our hands or a box. Otherwise give up.
		if(istype(O.loc,/obj/item/weapon/storage))	//in a container.
			var/obj/item/weapon/storage/U = O.loc
			user.client.screen -= O
			U.contents.Remove(O)
		else if(user.l_hand == O)					//in a hand
			user.drop_l_hand()
		else if(user.r_hand == O)					//in a hand
			user.drop_r_hand()
		else
			return

	user.visible_message("\The [user] puts \a [O] into \a [src]", "You put \the [O] inside \the [src].",\
	"You hear a rustle as someone puts something into a plastic bag.")
	icon_state = "evidence"
	var/image/I = image("icon"=O, "layer"=FLOAT_LAYER)	//take a snapshot. (necessary to stop the underlays appearing under our inventory-HUD slots ~Carn
	underlays += I
	desc = "An evidence bag containing \a [O]. [O.desc]"
	O.loc = src
	w_class = O.w_class
	return


/obj/item/weapon/evidencebag/attack_self(mob/user as mob)
	if (contents.len)
		var/obj/item/I = contents[1]
		user.visible_message("\The [user] takes \a [I] out of \a [src]", "You take \the [I] out of \the [src].",\
		"You hear someone rustle around in a plastic bag, and remove something.")
		underlays = null	//remove the underlays
		user.put_in_hands(I)
		w_class = 1
		icon_state = "evidenceobj"
		desc = "An empty evidence bag."

	else
		user << "\The [src] is empty."
		icon_state = "evidenceobj"
	return

/obj/item/weapon/storage/box/evidence
	name = "evidence bag box"
	desc = "A box claiming to contain evidence bags."
	New()
		new /obj/item/weapon/evidencebag(src)
		new /obj/item/weapon/evidencebag(src)
		new /obj/item/weapon/evidencebag(src)
		new /obj/item/weapon/evidencebag(src)
		new /obj/item/weapon/evidencebag(src)
		new /obj/item/weapon/evidencebag(src)
		new /obj/item/weapon/f_card(src)
		..()
		return