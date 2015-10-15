/obj/structure/cult
	density = 1
	anchored = 1
	icon = 'icons/obj/cult.dmi'

/obj/structure/table/altar
	name = "altar"
	desc = "A bloodstained altar dedicated to Nar-Sie."
	icon_state = "talismanaltar"


/obj/structure/cult/forge
	name = "daemon forge"
	desc = "A forge used in crafting the unholy weapons used by the armies of Nar-Sie."
	icon_state = "forge"

/obj/structure/cult/pylon
	name = "pylon"
	desc = "A floating crystal that hums with an unearthly energy."
	icon_state = "pylon"
	luminosity = 5

/obj/structure/table/cult
	name = "mysterious desk"
	desc = "A desk covered in arcane manuscripts and tomes in unknown languages. Looking at the text makes your skin crawl."
	icon_state = "tomealtar"
	luminosity = 1
	var/occupied = 1
	var/obj/item/hidden = null

/obj/structure/table/cult/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/weapon/tome) || istype(O, /obj/item/weapon/paper/talisman))
		if(!user.drop_item())
			return
		if (occupied)
			..()
		else
			occupied = 1
			O.loc = src
			hidden = O
			user << "<span class='notice'>[O] flies out of your hands and into a compartment of the desk, one that wasn't there before.</span>"

/obj/structure/table/cult/attack_hand(mob/user)
	if(!occupied)
		user << "<span class='notice'>You can't seem to find any drawers. Strange...</span>"
		return
	else
		occupied = 0
		hidden.loc = user.loc
		user.put_in_hands(hidden)
		user << "<span class='notice'>As you touch the desk, [hidden] flies out of a compartment that wasnn't there before and into your hands.</span>"
		hidden = null

/obj/effect/gateway
	name = "gateway"
	desc = "You're pretty sure that abyss is staring back."
	icon = 'icons/obj/cult.dmi'
	icon_state = "hole"
	density = 1
	unacidable = 1
	anchored = 1
