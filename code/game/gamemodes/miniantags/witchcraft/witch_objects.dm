//All objects used in witchcraft, as well as different items, tools, etc.

/obj/item/witchcraft
	name = "disturbing cube"
	desc = "A nondescript, completely symmetrical green cube."
	icon = 'icons/obj/witchcraft.dmi'
	icon_state = "base"
	w_class = 2

/obj/item/witchcraft/guide_book //Liber Naturae. The guide book for witchcraft. It also serves to produce certain materials. Translates to "The Book of Nature" in Latin - at least, Google Translate says so.
	name = "Liber Naturae"
	desc = null //Examine is different depending on whether or not the user is a witch.

/obj/item/witchcraft/guide_book/examine(mob/user)
	..()
	if(!is_witch(user.mind) && user.stat != DEAD)
		user << "A plant encyclopedia."
		return 0
	else
		user << "A detailed volume that describes a wide variety of plants and rituals used in witchcraft."

/obj/item/witchcraft/guide_book/attack_self(mob/living/user)
	if(!is_witch(user.mind))
		user << "<span class='notice'>The book is filled with boring diagrams of plants and text in a language you can't read.</span>"
		return 0
	else
		open_menu(user)

/obj/item/witchcraft/guide_book/proc/open_menu(var/mob/living/user)
	user << "Yell at Xhuis to code this"

/obj/item/witchcraft/herbal_paste //Herbal paste. Used to draw naturalistic circles.
	name = "herbal paste"
	desc = "A fistful of plant matter, crushed into gooey paste."

/obj/item/witchcraft/herbal_paste/attack_self(mob/living/user)
	if(!is_witch(user.mind))
		user << "<span class='warning'>[src] doesn't seem to stick when you try to write with it.</span>"
		return 0
	user.visible_message("<span class='warning'>[user] begins drawing strange markings with [src]!</span>", \
						"<span class='notice'>You begin writing a naturalistic circle...</span>")
	if(!do_after(user, 50, target = user))
		return 0
	user.visible_message("<span class='warning'>[user] writes a ritual circle with [src]!</span>", \
						"<span class='notice'>You draw a naturalistic circle for rituals.</span>")
	new /obj/structure/witchcraft/ritual_circle (get_turf(user))
	user.drop_item()
	qdel(src)
	return 1

/obj/structure/witchcraft
	name = "disturbing box"
	desc = "A nondescript, completely symmetrical green box."
	icon = 'icons/obj/witchcraft.dmi'
	icon_state = "base"
	density = 0
	opacity = 0

/obj/structure/witchcraft/ritual_circle //Naturalistic circle. Used to perform rituals.
	name = "naturalistic circle"
	desc = "Pagan markings drawn with an odorous green paste."
	icon_state = "ritual_circle"
	color = "#3D7A43"
	mouse_opacity = 2
	var/datum/ritual/current_ritual = null

/obj/structure/witchcraft/ritual_circle/attack_hand(mob/living/user)
	if(!is_witch(user.mind))
		user << "<span class='warning'>You can't seem to read the markings.</span>"
		return 0
	if(!current_ritual)
		user << "<span class='warning'>This circle is not attuned to any rituals.</span>"
		return 0
	current_ritual.invoker = user
	current_ritual.begin_ritual()

/obj/structure/witchcraft/ritual_circle/Destroy()
	if(current_ritual)
		qdel(current_ritual)
	..()

/obj/structure/witchcraft/ritual_circle/examine(mob/user)
	..()
	if(is_witch(user.mind))
		if(current_ritual)
			user << "<i>Current Ritual:</i> [current_ritual.ritual_name]"
			user << "<i>Ritual Effects:</i> [current_ritual.ritual_desc]"
		else
			user << "<i>It is not attuned to any rituals.</span>"

/obj/structure/witchcraft/ritual_circle/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/seeds))
		return attune_to_ritual(user, I, /datum/ritual/grow)
	if(istype(I, /obj/item/weapon/nullrod))
		user.visible_message("<span class='warning'>[user] disrupts [src] with [I]!</span>", \
							"<span class='warning'>You disrupt [src] with [I].</span>")
		qdel(src)
		return 1
	..()

/obj/structure/witchcraft/ritual_circle/proc/attune_to_ritual(var/mob/living/user, var/obj/item/O, var/datum/ritual/R)
	user.drop_item()
	qdel(O)
	var/datum/ritual/I = new R (null)
	current_ritual = I
	I.circle = src
	user << "<span class='notice'>New ritual: [I.ritual_name].</span>"
