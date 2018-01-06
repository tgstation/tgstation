/obj/structure/mineral_door/transparent/reagent
	name = "reagent door"
	icon_state = "silver"
	sheetType = /obj/item/stack/sheet/mineral/reagent
	alpha = 200
	var/datum/reagent/reagent_type
	var/obj/effect/particle_effect/fakeholder

/obj/structure/mineral_door/transparent/reagent/ComponentInitialize()
	return

/obj/structure/mineral_door/transparent/reagent/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature && !fakeholder)
		fakeholder = new(get_turf(src))
		fakeholder.create_reagents(50)
		fakeholder.reagents.add_reagent(reagent_type.id, 50, reagtemp = exposed_temperature)
		fakeholder.reagents.handle_reactions()
		QDEL_IN(fakeholder, 150)

	else if(exposed_temperature && fakeholder && !QDELETED(fakeholder))
		fakeholder.reagents.chem_temp = exposed_temperature
		fakeholder.reagents.handle_reactions()

	if(exposed_temperature > 4000)
		for(var/mob/M in viewers(3, src))
			to_chat(M, ("<span class='warning'>[icon2html(src, viewers(src))] The [src] boils away in the extreme heat!</span>"))
		vapourise()
	..()

/obj/structure/mineral_door/transparent/reagent/proc/vapourise()
	if(reagent_type && !QDELETED(src))
		var/obj/effect/particle_effect/vapour/foundvape = locate() in get_turf(src)
		if(foundvape && foundvape.reagent_type == src)
			foundvape.VM.volume += 20000
		else
			var/obj/effect/particle_effect/vapour/master/V = new(get_turf(src))
			V.volume = 20000
			var/paths = subtypesof(/datum/reagent)
			for(var/path in paths)
				var/datum/reagent/RR = new path
				if(RR.id == reagent_type.id)
					V.reagent_type = RR
					break
				else
					qdel(RR)

	deconstruct(FALSE)

/obj/structure/mineral_door/transparent/reagent/proc/reagent_act(atom/A)
	if(prob(90) && reagent_type)
		if(isliving(A))
			reagent_type.reaction_mob(A, TOUCH, 3)
		else if(isturf(A))
			reagent_type.reaction_turf(A, TOUCH, 3)
		else if(isobj(A))
			reagent_type.reaction_obj(A, TOUCH, 3)
	else if(reagent_type)
		for(var/atom/AM in view(2, src))
			if(isliving(AM))
				reagent_type.reaction_mob(AM, TOUCH, 3)
			else if(isturf(AM))
				reagent_type.reaction_turf(AM, TOUCH, 3)
			else if(isobj(AM))
				reagent_type.reaction_obj(AM, TOUCH, 3)


/obj/structure/mineral_door/transparent/reagent/attack_hand(mob/user)
	reagent_act(user)
	..()

/obj/structure/mineral_door/transparent/reagent/attack_paw(mob/user)
	reagent_act(user)
	..()

/obj/structure/mineral_door/transparent/reagent/CollidedWith(atom/movable/AM)
	reagent_act(AM)
	..()

/obj/structure/mineral_door/transparent/reagent/attackby(obj/item/I, mob/user, params)
	var/hotness = I.is_hot()
	if(hotness)
		temperature_expose(exposed_temperature = hotness)
		to_chat(user, "<span class='warning'>You heat [src] with [I]!</span>")
	..()

/obj/structure/mineral_door/transparent/reagent/ex_act()
	if(fakeholder && fakeholder.reagents && !QDELETED(fakeholder))
		for(var/datum/reagent/R in fakeholder.reagents.reagent_list)
			R.on_ex_act()
	else
		fakeholder = new(get_turf(src))
		fakeholder.create_reagents(30)
		fakeholder.reagents.add_reagent(reagent_type.id, 100)
		for(var/datum/reagent/R in fakeholder.reagents.reagent_list)
			R.on_ex_act()
		fakeholder.reagents.handle_reactions()
		QDEL_IN(fakeholder, 150)
	..()

/obj/structure/mineral_door/transparent/reagent/deconstruct(disassembled = TRUE)
	var/turf/T = get_turf(src)
	var/obj/item/stack/sheet/mineral/reagent/RS = new(T, sheetAmount)
	var/paths = subtypesof(/datum/reagent)//one reference per stack
	for(var/path in paths)
		var/datum/reagent/RR = new path
		if(RR.id == reagent_type.id)
			RS.reagent_type = RR
			RS.name = "[RR.name] ingots"
			RS.singular_name = "[RR.name] ingot"
			RS.add_atom_colour(RR.color, FIXED_COLOUR_PRIORITY)
			break
		else
			qdel(RR)

	qdel(src)

/obj/structure/mineral_door/transparent/reagent/Destroy()
	if(fakeholder)
		qdel(fakeholder)
	return ..()

/obj/structure/mineral_door/transparent/reagent/bullet_act(obj/item/projectile/Proj)
	if(istype(Proj, /obj/item/projectile/beam))
		temperature_expose(exposed_temperature = 1000)
	else
		reagent_act(src)
	..()