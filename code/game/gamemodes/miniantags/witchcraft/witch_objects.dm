//All objects used in witchcraft, as well as different items, tools, etc.

/obj/item/witchcraft
	name = "disturbing cube"
	desc = "A nondescript, completely symmetrical green cube."
	icon = 'icons/obj/witchcraft.dmi'
	icon_state = "base"
	w_class = 2

/obj/structure/witchcraft
	name = "disturbing box"
	desc = "A nondescript, completely symmetrical green box."
	icon = 'icons/obj/witchcraft.dmi'
	icon_state = "base"
	density = 0
	opacity = 0

//Naturalistic circle: required for rituals
/obj/structure/witchcraft/ritual_circle
	name = "naturalistic circle"
	desc = "Pagan markings drawn with plant matter crushed into paste."
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
	..()

/obj/structure/witchcraft/ritual_circle/proc/attune_to_ritual(var/mob/living/user, var/obj/item/O, var/datum/ritual/R)
	user.drop_item()
	qdel(O)
	var/datum/ritual/I = new R (null)
	current_ritual = I
	I.circle = src
	user << "<span class='notice'>New ritual: [I.ritual_name].</span>"
