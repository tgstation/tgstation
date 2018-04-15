GLOBAL_LIST_EMPTY(chempiles)
/obj/effect/decal/cleanable/chempile
	name = "chemicals"
	desc = "An indiscernible mixture of chemicals"
	icon = 'hippiestation/icons/effects/32x32.dmi'
	icon_state = "chempile"
	mergeable_decal = FALSE

/obj/effect/decal/cleanable/chempile/examine(mob/user)
	..()
	to_chat(user, "It contains:")
	if(reagents.reagent_list.len)
		if(user.can_see_reagents()) //Show each individual reagent
			for(var/datum/reagent/R in reagents.reagent_list)
				to_chat(user, "[R.volume] units of [R.name]")
		else //Otherwise, just show the total volume
			var/total_volume = 0
			for(var/datum/reagent/R in reagents.reagent_list)
				total_volume += R.volume
			to_chat(user, "[total_volume] units of various reagents")
	else
		to_chat(user, "Nothing.")

/obj/effect/decal/cleanable/chempile/experience_pressure_difference(pressure_difference)
	if(reagents)
		reagents.chem_pressure = pressure_difference / 100

/obj/effect/decal/cleanable/chempile/Initialize()
	. = ..()
	GLOB.chempiles += src
	if(reagents && reagents.total_volume)
		if(reagents.total_volume < 5)
			reagents.set_reacting(FALSE)

/obj/effect/decal/cleanable/chempile/Destroy()
	..()
	GLOB.chempiles -= src

/obj/effect/decal/cleanable/chempile/ex_act()
	qdel(src)

/obj/effect/decal/cleanable/chempile/Crossed(mob/mover)
	if(isliving(mover))
		var/mob/living/M = mover
		var/protection = 1
		for(var/obj/item/I in M.get_equipped_items())
			if(I.body_parts_covered & FEET)
				protection = I.permeability_coefficient
		if(reagents && reagents.total_volume >= 1)	//No transfer if there's less than 1u total
			reagents.trans_to(M, 2, protection)
			CHECK_TICK
			for(var/datum/reagent/R in reagents)
				if(R.volume < 0.2)
					reagents.remove_reagent(R)	//Should remove most stray cases of microdosages that may get through without compromising chempiles with lots of mixes in them

/obj/effect/decal/cleanable/chempile/fire_act(exposed_temperature, exposed_volume)
	if(reagents && reagents.chem_temp)
		reagents.expose_temperature(exposed_temperature)
		CHECK_TICK

/obj/effect/decal/cleanable/chempile/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/reagent_containers/glass) || istype(I, /obj/item/reagent_containers/food/drinks))//copypaste scoop code so I can nerf it to halve effectiveness
		if(src.reagents && I.reagents)
			. = 1 //so the containers don't splash their content on the src while scooping.
			if(!src.reagents.total_volume)
				to_chat(user, "<span class='notice'>[src] isn't thick enough to scoop up!</span>")
				return
			if(I.reagents.total_volume >= I.reagents.maximum_volume)
				to_chat(user, "<span class='notice'>[I] is full!</span>")
				return
			to_chat(user, "<span class='notice'>You attempt to scoop up what you can from the [src] into [I]!</span>")
			reagents.trans_to(I, max(0.1, reagents.total_volume * 0.05))//fuck you
			qdel(src)
			return

	var/hotness = I.is_hot()
	if(hotness && reagents)
		reagents.expose_temperature(hotness)
		to_chat(user, "<span class='notice'>You heat [src] with [I].</span>")