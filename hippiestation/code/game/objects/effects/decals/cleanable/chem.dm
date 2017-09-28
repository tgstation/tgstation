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
		if(reagents)
			reagents.trans_to(M, 2 * M.get_permeability_protection())
			CHECK_TICK

/obj/effect/decal/cleanable/chempile/fire_act(exposed_temperature, exposed_volume)
	if(reagents && reagents.chem_temp)
		reagents.chem_temp += 30
		reagents.handle_reactions()
		CHECK_TICK

/obj/effect/decal/cleanable/chempile/attackby(obj/item/I, mob/user, params)
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