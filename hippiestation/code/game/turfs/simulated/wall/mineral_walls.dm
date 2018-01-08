/turf/closed/wall/mineral/reagent
	name = "reagent wall"
	desc = "A wall with reagent plating."
	icon = 'icons/turf/walls/silver_wall.dmi'
	icon_state = "silver"
	sheet_type = /obj/item/stack/sheet/mineral/reagent
	canSmoothWith = list(/turf/closed/wall/mineral/reagent)
	var/datum/reagent/reagent_type
	var/obj/effect/particle_effect/fakeholder
	sheet_amount = 4

/turf/closed/wall/mineral/reagent/proc/heat(exposed_temperature)
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

/turf/closed/wall/mineral/reagent/proc/vapourise()
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

		new girder_type(src)
		ChangeTurf(/turf/open/floor/plasteel)

/turf/closed/wall/mineral/reagent/proc/reagent_act(atom/A)
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


/turf/closed/wall/mineral/reagent/attack_hand(mob/user)
	reagent_act(user)
	..()

/turf/closed/wall/mineral/reagent/attack_paw(mob/user)
	reagent_act(user)
	..()

/turf/closed/wall/mineral/reagent/CollidedWith(atom/movable/AM)
	reagent_act(AM)
	..()

/turf/closed/wall/mineral/reagent/attackby(obj/item/I, mob/user, params)
	var/hotness = I.is_hot()
	if(hotness)
		heat(exposed_temperature = hotness)
		to_chat(user, "<span class='warning'>You heat [src] with [I]!</span>")
	..()

/turf/closed/wall/mineral/reagent/ex_act()
	if(fakeholder && fakeholder.reagents && !QDELETED(fakeholder))
		for(var/datum/reagent/R in fakeholder.reagents.reagent_list)
			R.on_ex_act()
	else
		fakeholder = new(get_turf(src))
		fakeholder.create_reagents(50)
		fakeholder.reagents.add_reagent(reagent_type.id, 50)
		for(var/datum/reagent/R in fakeholder.reagents.reagent_list)
			R.on_ex_act()
		fakeholder.reagents.handle_reactions()
		QDEL_IN(fakeholder, 150)
	..()

/turf/closed/wall/mineral/reagent/break_wall()
	var/turf/T = get_turf(src)
	new sheet_type(src, sheet_amount)
	var/obj/item/stack/sheet/mineral/reagent/RS = new(T, sheet_amount)
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

/turf/closed/wall/mineral/reagent/devastate_wall()
	var/turf/T = get_turf(src)
	var/obj/item/stack/sheet/mineral/reagent/RS = new(T, sheet_amount)
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

/turf/closed/wall/mineral/reagent/Destroy()
	if(fakeholder)
		qdel(fakeholder)
	return ..()

/turf/closed/wall/mineral/reagent/bullet_act(obj/item/projectile/Proj)
	if(istype(Proj, /obj/item/projectile/beam))
		heat(1000)
	else
		reagent_act(src)
	..()