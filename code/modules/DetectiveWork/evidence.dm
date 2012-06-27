//CONTAINS: Evidence bags

/obj/item/weapon/evidencebag
	name = "evidence bag"
	desc = "An empty evidence bag."
	icon = 'storage.dmi'
	icon_state = "evidenceobj"
	w_class = 1

/obj/item/weapon/evidencebag/afterattack(obj/item/O, mob/user as mob)
	if(!in_range(O,user))
		return

	if(istype(O, /obj/item/weapon/storage) && O in user)
		return ..()

	if(!(O && istype(O)) || O.anchored == 1)
		user << "You can't put that inside \the [src]!"
		return ..()

	if(istype(O, /obj/item/weapon/evidencebag))
		user << "You find putting an evidence bag in another evidence bag to be slightly absurd."
		return

	if(O in user && (user.l_hand != O && user.r_hand != O)) //If it is in their inventory, but not in their hands, don't grab it off of them.
		user << "You are wearing that."
		return

	if(O in user) //TEMPORARY FIX. It seems trying to put items that are in your hand in the bags breaks them horribly. - Erthilo
		user << "You'll need to put the evidence down to properly bag it."
		return

	if(contents.len)
		user << "The [src] already has something inside it."
		return ..()

	if(istype(O.loc,/obj/item/weapon/storage))
		var/obj/item/weapon/storage/U = O.loc
		user.client.screen -= O
		U.contents.Remove(O)

	if(istype(O.loc,/obj/item/clothing/suit/storage/))
		var/obj/item/clothing/suit/storage/U = O.loc
		user.client.screen -= O
		U.contents.Remove(O)

	user.visible_message("\The [user] puts \a [O] into \a [src]", "You put \the [O] inside \the [src].",\
	"You hear a rustle as someone puts something into a plastic bag.")
	icon_state = "evidence"
	overlays += O
	desc = "An evidence bag containing \a [O]. [O.desc]"
	O.loc = src
	w_class = O.w_class
	return


/obj/item/weapon/evidencebag/attack_self(mob/user as mob)
	if (contents.len)
		var/obj/item/I = contents[1]
		user.visible_message("\The [user] takes \a [I] out of \a [src]", "You take \the [I] out of \the [src].",\
		"You hear someone rustle around in a plastic bag, and remove something.")
		overlays -= I
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