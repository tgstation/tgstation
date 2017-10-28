GLOBAL_LIST_EMPTY(chempiles)
/obj/effect/decal/cleanable/chempile
	name = "chemicals"
	desc = "An indiscernible mixture of chemicals"
	icon = 'hippiestation/icons/effects/32x32.dmi'
	icon_state = "chempile"
	mergeable_decal = FALSE

/obj/effect/decal/cleanable/chempile/examine(mob/user)
	..()
	if(user.research_scanner || isobserver(user))
		if(LAZYLEN(reagents.reagent_list)) //find a reagent list if there is and check if it has entries
			to_chat(user, "<span class='notice'>Chemical contents:</span>")
			for(var/RE in reagents.reagent_list) //no reagents will be left behind
				var/datum/reagent/R = RE
				to_chat(user, "<span class='warning'>[R]: [round(R.volume,0.01)]u</span>")

/obj/effect/decal/cleanable/chempile/experience_pressure_difference(pressure_difference)
	if(reagents)
		reagents.chem_pressure = pressure_difference / 100

/obj/effect/decal/cleanable/chempile/Initialize()
	. = ..()
	LAZYADD(GLOB.chempiles, src)
	if(reagents && reagents.total_volume)
		if(reagents.total_volume < 5)
			reagents.set_reacting(FALSE)

/obj/effect/decal/cleanable/chempile/Destroy()
	..()
	LAZYREMOVE(GLOB.chempiles, src)

/obj/effect/decal/cleanable/chempile/ex_act()
	qdel(src)

/obj/effect/decal/cleanable/chempile/Crossed(mob/mover)
	if(isliving(mover))
		var/mob/living/M = mover
		var/protection = 1
		for(var/obj/item/I in M.get_equipped_items())
			if(I.body_parts_covered & FEET)
				protection = I.permeability_coefficient
		if(reagents)
			reagents.trans_to(M, 2, protection)
			CHECK_TICK

/obj/effect/decal/cleanable/chempile/fire_act(exposed_temperature, exposed_volume)
	if(reagents && reagents.chem_temp)
		reagents.chem_temp += 30
		reagents.handle_reactions()
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
			reagents.trans_to(I, reagents.total_volume* 0.5)//nerfed to half and deletes after a single scoop
			qdel(src)
			return

	var/hotness = I.is_hot()
	if(hotness)
		var/added_heat = (hotness / 100) //ishot returns a temperature
		if(reagents)
			if(reagents.chem_temp < hotness) //can't be heated to be hotter than the source
				reagents.chem_temp += added_heat
				to_chat(user, "<span class='notice'>You heat [src] with [I].</span>")
				reagents.handle_reactions()
			else
				to_chat(user, "<span class='warning'>[src] is already hotter than [I]!</span>")