/obj/structure/reagent_dispensers
	icon = 'hippiestation/icons/obj/objects.dmi'
	var/mutable_appearance/reagent_icon
	var/use_reagent_icon = FALSE

/obj/structure/reagent_dispensers/water_cooler
	icon = 'hippiestation/icons/obj/vending.dmi'

/obj/structure/reagent_dispensers/on_reagent_change()
	update_icon()

/obj/structure/reagent_dispensers/attack_hand()
	..()
	update_icon()

/obj/structure/reagent_dispensers/update_icon()
	if(!use_reagent_icon)
		return
	cut_overlays()
	if(reagent_icon && reagents.total_volume)
		reagent_icon.icon_state = "tankfilling[Clamp(round(reagents.total_volume / (tank_volume * 0.2)), 1, 4)]"
		reagent_icon.color = mix_color_from_reagents(reagents.reagent_list)
		add_overlay(reagent_icon)

/obj/structure/reagent_dispensers/chemical
	name = "chem tank"
	desc = "It can hold a large amount of chemicals. Use a screwdriver to open and close its lid."
	icon_state = "chem"
	tank_volume = 300
	use_reagent_icon = TRUE
	reagent_id = null

/obj/structure/reagent_dispensers/proc/generate_reagent_icon()
	if(!use_reagent_icon)
		return
	reagent_icon = new
	update_icon()

/obj/structure/reagent_dispensers/attackby(obj/item/weapon/W, mob/user, params)
	..()
	update_icon()

/obj/structure/reagent_dispensers/chemical/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/weapon/screwdriver))
		if(container_type & DRAWABLE)
			container_type |= INJECTABLE
			container_type &= ~DRAWABLE
			to_chat(user, "<span class='notice'>You unfasten the tank's cap.</span>")
		else if(container_type & INJECTABLE)
			container_type |= DRAWABLE
			container_type &= ~INJECTABLE
			to_chat(user, "<span class='notice'>You fasten the tank's cap.</span>")
		update_icon()
		playsound(src.loc, 'sound/machines/click.ogg', 20, 1)
		return FALSE
	var/hotness = W.is_hot()
	if(hotness && reagents)
		var/added_heat = (hotness * 0.01) //ishot returns a temperature
		if(reagents.chem_temp < hotness) //can't be heated to be hotter than the source
			reagents.chem_temp += added_heat
			to_chat(user, "<span class='notice'>You heat [src] with [W].</span>")
			reagents.handle_reactions()
		else
			to_chat(user, "<span class='warning'>[W] cannot heat anything inside [src]!</span>")
		return FALSE
	..()

/obj/structure/reagent_dispensers/chemical/update_icon()
	..()
	if(container_type & DRAWABLE)
		add_overlay("chemlid")

/obj/structure/reagent_dispensers/watertank
	use_reagent_icon = TRUE

/obj/structure/reagent_dispensers/watertank/high
	use_reagent_icon = FALSE

/obj/structure/reagent_dispensers/fueltank
	use_reagent_icon = TRUE

/obj/structure/reagent_dispensers/water_cooler/honk
	name = "honk-cooler"
	desc = "A machine that dispenses the clown's thick juice. HONK!"
	icon_state = "honk_cooler"
	reagent_id = "banana"