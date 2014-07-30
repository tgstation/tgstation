/obj/machinery/foodgrill
	name = "grill"
	desc = "Backyard grilling, IN SPACE."
	icon = 'icons/obj/cooking_machines.dmi'
	icon_state = "grill_off"
	layer = 2.9
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 5
	var/on = FALSE	//Is it grilling food already?

/obj/machinery/foodgrill/attackby(obj/item/I, mob/user)
	if(on)
		user << "<span class='notice'>[src] is already processing, please wait.</span>"
		return
	if(istype(I, /obj/item/weapon/grab)||istype(I, /obj/item/tk_grab))
		user << "<span class='warning'>That isn't going to fit.</span>"
		return
	user << "<span class='notice'>You put [I] onto [src].</span>"
	on = TRUE
	user.drop_item()
	I.loc = src
	icon_state = "grill_on"

	var/image/img = new(I.icon, I.icon_state)
	img.pixel_y = 5
	overlays += img
	sleep(200)
	overlays.Cut()
	img.color = "#C28566"
	overlays += img
	sleep(200)
	overlays.Cut()
	img.color = "#A34719"
	overlays += img
	sleep(50)
	overlays.Cut()

	on = FALSE
	icon_state = "grill_off"

	if(istype(I, /obj/item/weapon/reagent_containers/))
		var/obj/item/weapon/reagent_containers/food = I
		food.reagents.add_reagent("nutriment", 10)
		food.reagents.trans_to(I, food.reagents.total_volume)
	I.loc = get_turf(src)
	I.color = "#A34719"
	var/tempname = I.name
	I.name = "grilled [tempname]"