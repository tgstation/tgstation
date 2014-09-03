/obj/machinery/cerealmaker
	name = "cereal maker"
	desc = "Now with Dann O's available!"
	icon = 'icons/obj/cooking_machines.dmi'
	icon_state = "cereal_off"
	layer = 2.9
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 20
	active_power_usage = 500
	var/on = FALSE	//Is it making cereal already?

/obj/machinery/cerealmaker/attackby(obj/item/I, mob/user)
	if(on)
		user << "<span class='notice'>[src] is currently turning something into cereal!</span>"
		return
	if(istype(I,/obj/item/weapon/wrench))
		if(!anchored)
			playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
			if(do_after(user, 30))
				anchored = 1
				user << "You wrench [src] in place."
			return
		else
			playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
			if(do_after(user, 30))
				anchored = 0
				user << "You unwrench [src]."
			return
	if(!anchored)
		user << "<span class='warning'>[src] must be anchored first!</span>"
		return
	if(!istype(I, /obj/item/weapon/reagent_containers/food/snacks/))
		user << "<span class='warning'>Budget cuts won't let you put that in there.</span>"
		return
	if(istype(I, /obj/item/weapon/reagent_containers/food/snacks/cereal/))
		user << "<span class='warning'>That isn't going to fit.</span>"
		return
	user << "<span class='notice'>You put [I] into [src].</span>"
	on = TRUE
	user.drop_item()
	I.loc = src
	icon_state = "cereal_on"
	playsound(get_turf(src), 'sound/machines/juicer.ogg', 20, 1)
	sleep(200)
	icon_state = "cereal_off"
	var/obj/item/weapon/reagent_containers/food/snacks/cereal/S = new(get_turf(src))
	var/image/img = new(I.icon, I.icon_state)
	img.transform *= 0.7
	if(istype(I, /obj/item/weapon/reagent_containers/))
		var/obj/item/weapon/reagent_containers/food = I
		food.reagents.trans_to(S, food.reagents.total_volume)
	S.overlays += img
	S.overlays += I.overlays
	S.name = "box of [I] cereal"
	playsound(loc, 'sound/machines/ding.ogg', 50, 1)
	on = FALSE
	qdel(I)

