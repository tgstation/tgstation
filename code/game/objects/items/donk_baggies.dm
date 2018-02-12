/obj/item/donk_bag
	name = "sealed donk pocket"
	desc = "It's a sealed baggie, capable of keeping donk pockets warm for much longer."
	icon = 'icons/obj/donks.dmi'
	icon_state = "sbag"
	var/list/contained_donks = list()
	var/max_donks = 1

/obj/item/donk_bag/update_icon()
	if(LAZYLEN(contained_donks))
		icon_state = "sbag"
	else
		icon_state = "empty_sbag"

/obj/item/donk_bag/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(. && istype(I, /obj/item/reagent_containers/food/snacks/donkpocket) && !(I in contained_donks) && contained_donks.len < max_donks)
		I.forceMove(src)
		contained_donks += I
		to_chat(user, "<span class='notice'>You put [I] into [src].</span>")

/obj/item/donk_bag/attack_hand(mob/user)
	. = ..()
	if(. && user.is_holding(src) && LAZYLEN(contained_donks))
		var/obj/item/new_donk = contained_donks[1]
		contained_donks.Remove(new_donk)
		new_donk.forceMove(get_turf(user))
		user.put_in_hands(new_donk)
		to_chat(user, "<span class='notice'>You remove [new_donk] from [src].</span>")
		update_icon()

/obj/item/donk_bag/attack_self(mob/user)
	. = ..()
	if(. && user.is_holding(src) && LAZYLEN(contained_donks))
		var/obj/item/new_donk = contained_donks[1]
		contained_donks.Remove(new_donk)
		new_donk.forceMove(get_turf(user))
		user.put_in_hands(new_donk)
		to_chat(user, "<span class='notice'>You remove [new_donk] from [src].</span>")
		update_icon()

/obj/item/donk_bag/large
	name = "large sealed donk pocket baggy"
	desc = "It's a large donk pocket baggy, capable of holding 4 donks and keeping them warm!"
	icon_state = "empty_lbag"
	max_donks = 4

/obj/item/donk_bag/large/update_icon()
	if(LAZYLEN(contained_donks))
		icon_state = "lbag_[contained_donks.len]"
	else
		icon_state = "empty_lbag"