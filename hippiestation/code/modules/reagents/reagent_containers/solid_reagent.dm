/obj/item/reagent_containers/food/snacks/solid_reagent
	name = "solidified chemicals"
	desc = "Are you sure eating this is a good idea?"
	icon = 'hippiestation/icons/obj/chemical.dmi'
	icon_state = "chembar"
	unique_rename = TRUE
	var/reagent_type
	foodtype = TOXIC
	volume = 200
	container_type = TRANSPARENT_1
	bitesize = 5

/obj/item/reagent_containers/food/snacks/solid_reagent/Initialize()
	. = ..()
	pixel_x = rand(8,-8)
	pixel_y = rand(8,-8)

/obj/item/reagent_containers/food/snacks/solid_reagent/microwave_act(obj/machinery/microwave/M)
	if(reagents)
		reagents.chem_temp = max(reagents.chem_temp, 1000)
		reagents.handle_reactions()

/obj/item/reagent_containers/food/snacks/solid_reagent/ex_act()
	if(reagents)
		for(var/datum/reagent/R in reagents.reagent_list)
			R.on_ex_act()
	if(!QDELETED(src))
		..()

/obj/item/reagent_containers/food/snacks/solid_reagent/fire_act(exposed_temperature, exposed_volume)
	reagents.chem_temp += 30
	reagents.handle_reactions()//no ..() so it doesn't burn to ash
	if(volume <= 0)
		qdel(src)

/obj/item/reagent_containers/food/snacks/solid_reagent/attackby(obj/item/I, mob/user, params)
	var/hotness = I.is_hot()
	if(hotness)
		var/added_heat = (hotness / 100) //ishot returns a temperature
		if(reagents)
			if(reagents.chem_temp < hotness) //can't be heated to be hotter than the source
				reagents.chem_temp += added_heat
				to_chat(user, "<span class='notice'>You heat [src] with [I].</span>")
				reagents.handle_reactions()
				if(volume <= 0)
					qdel(src)
			else
				to_chat(user, "<span class='warning'>[src] is already hotter than [I]!</span>")


/obj/item/reagent_containers/food/snacks/solid_reagent/afterattack(obj/target, mob/user , proximity)
	if(!proximity)
		return
	if(target.is_open_container() || istype(target, /obj/effect/decal/cleanable/chempile) && target.reagents)
		if(!target.reagents.total_volume)
			to_chat(user, "<span class='warning'>[target] is empty! There's nothing to dissolve [src] in.</span>")
			return
		to_chat(user, "<span class='notice'>You dissolve [src] in [target].</span>")
		for(var/mob/O in viewers(2, user))	//viewers is necessary here because of the small radius
			to_chat(O, "<span class='warning'>[user] dissolves [src] into [target]!</span>")
		reagents.trans_to(target, reagents.total_volume)
		qdel(src)