/obj/item/clothing/suit/armor/makeshift
	name = "makeshift armor"
	desc = "A hazard vest with metal plate taped on it. It offers some protection, but not as much as the real deal."
	icon_state = "metalarmor"
	item_state = "metalarmor"
	w_class = 3
	blood_overlay_type = "armor"
	armor = list(melee = 30, bullet = 10, laser = 0, energy = 0, bomb = 5, bio = 0, rad = 0)

/obj/item/clothing/suit/hazardvest/attackby(obj/item/W as obj, mob/user as mob, params)
	..()
	if(istype(W, /obj/item/stack/sheet/metal))
		var/obj/item/clothing/suit/armor/makeshift/new_item = new(user.loc)
		user << "<span class='notice'>You use [W] to turn [src] into [new_item].</span>"
		var/replace = (user.get_inactive_hand()==src)
		qdel(W)
		qdel(src)
		if(replace)
			user.put_in_hands(new_item)
		return