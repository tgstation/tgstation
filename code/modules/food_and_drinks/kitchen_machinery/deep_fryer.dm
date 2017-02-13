/*
April 3rd, 2014 marks the day this machine changed the face of the kitchen on NTStation13
God bless America.
insert ascii eagle on american flag background here
*/

// April 3rd, 2014 marks the day this machine changed the face of the kitchen on NTStation13
// God bless America.
/obj/machinery/deepfryer
	name = "deep fryer"
	desc = "Deep fried <i>everything</i>."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "fryer_off"
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 5
	container_type = OPENCONTAINER
	var/obj/item/frying = null	//What's being fried RIGHT NOW?
	var/cook_time = 0
	var/static/list/blacklisted_items = typecacheof(list(
		/obj/item/weapon/screwdriver,
		/obj/item/weapon/crowbar,
		/obj/item/weapon/wrench,
		/obj/item/weapon/wirecutters,
		/obj/item/device/multitool,
		/obj/item/weapon/weldingtool,
		/obj/item/weapon/reagent_containers/glass,
		/obj/item/weapon/storage/part_replacer))

/obj/item/weapon/circuitboard/machine/deep_fryer
	name = "circuit board (Deep Fryer)"
	build_path = /obj/machinery/deepfryer
	origin_tech = "programming=1"
	req_components = list(/obj/item/weapon/stock_parts/micro_laser = 1)

/obj/machinery/deepfryer/New()
	..()
	create_reagents(50)
	reagents.add_reagent("nutriment", 25)
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/machine/deep_fryer(null)
	component_parts += new /obj/item/weapon/stock_parts/micro_laser(null)
	RefreshParts()

/obj/machinery/deepfryer/examine()
	..()
	if(frying)
		usr << "You can make out [frying] in the oil."

/obj/machinery/deepfryer/attackby(obj/item/I, mob/user)
	if(!reagents.total_volume)
		user << "There's nothing to fry with in [src]!"
		return
	if(istype(I, /obj/item/weapon/reagent_containers/food/snacks/deepfryholder))
		user << "<span class='userdanger'>Your cooking skills are not up to the legendary Doublefry technique.</span>"
		return
	if(default_unfasten_wrench(user, I))
		return
	else if(exchange_parts(user, I))
		return
	else if(default_deconstruction_screwdriver(user, "fryer_off", "fryer_off" ,I))	//where's the open maint panel icon?!
		return
	else
		if(is_type_in_typecache(I, blacklisted_items))
			. = ..()
		else if(user.drop_item() && !frying)
			user << "<span class='notice'>You put [I] into [src].</span>"
			frying = I
			frying.forceMove(src)
			icon_state = "fryer_on"

/obj/machinery/deepfryer/process()
	..()
	if(!reagents.total_volume)
		return
	if(frying)
		cook_time++
		if(cook_time == 30)
			playsound(src.loc, "sound/machines/ding.ogg", 50, 1)
			visible_message("[src] dings!")
		else if (cook_time == 60)
			visible_message("[src] emits an acrid smell!")


/obj/machinery/deepfryer/attack_hand(mob/user)
	if(frying)
		if(frying.loc == src)
			user << "<span class='notice'>You eject [frying] from [src].</span>"
			var/obj/item/weapon/reagent_containers/food/snacks/deepfryholder/S = new(get_turf(src))
			if(istype(frying, /obj/item/weapon/reagent_containers/))
				var/obj/item/weapon/reagent_containers/food = frying
				food.reagents.trans_to(S, food.reagents.total_volume)
			S.icon = frying.icon
			S.overlays = frying.overlays
			S.icon_state = frying.icon_state
			S.desc = frying.desc
			S.w_class = frying.w_class
			reagents.trans_to(S, 2*(cook_time/15))
			switch(cook_time)
				if(0 to 15)
					S.color = rgb(166,103,54)
					S.name = "lightly-fried [frying.name]"
				if(16 to 49)
					S.color = rgb(103,63,24)
					S.name = "fried [frying.name]"
				if(50 to 59)
					S.color = rgb(63, 23, 4)
					S.name = "deep-fried [frying.name]"
				if(60 to INFINITY)
					S.color = rgb(33,19,9)
					S.name = "the physical manifestation of the very concept of fried foods"
					S.desc = "A heavily fried...something.  Who can tell anymore?"
			S.filling_color = S.color
			if(istype(frying, /obj/item/weapon/reagent_containers/food/snacks/))
				qdel(frying)
			else
				frying.forceMove(S)

			icon_state = "fryer_off"
			user.put_in_hands(S)
			frying = null
			cook_time = 0
			return
	else if(user.pulling && user.a_intent == "grab" && iscarbon(user.pulling) && reagents.total_volume)
		if(user.grab_state < GRAB_AGGRESSIVE)
			user << "<span class='warning'>You need a better grip to do that!</span>"
			return
		var/mob/living/carbon/C = user.pulling
		user.visible_message("<span class = 'danger'>[user] dunks [C]'s face in [src]!</span>")
		reagents.reaction(C, TOUCH)
		C.adjustFireLoss(reagents.total_volume)
		reagents.remove_any((reagents.total_volume/2))
		C.Weaken(3)
		user.changeNext_move(CLICK_CD_MELEE)
	..()
