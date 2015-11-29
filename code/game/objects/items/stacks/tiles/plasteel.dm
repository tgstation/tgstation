/obj/item/stack/tile/plasteel
	name = "floor tile"
	singular_name = "floor tile"
	desc = "Those could work as a pretty decent throwing weapon"
	icon_state = "tile"
	w_class = 3.0
	force = 6.0
	starting_materials = list(MAT_IRON = 937.5)
	w_type = RECYK_METAL
	melt_temperature = MELTPOINT_STEEL
	throwforce = 15.0
	throw_speed = 5
	throw_range = 20
	flags = FPRINT
	siemens_coefficient = 1
	max_amount = 60

	material = "metal"

/obj/item/stack/tile/plasteel/New(var/loc, var/amount=null)
	. = ..()
	pixel_x = rand(1, 14)
	pixel_y = rand(1, 14)

/obj/item/stack/tile/plasteel/recycle(var/datum/materials/rec)
	rec.addAmount("iron",amount/4)
	return 1

/*
/obj/item/stack/tile/plasteel/attack_self(mob/user as mob)
	if (usr.stat)
		return
	var/T = user.loc
	if (!( istype(T, /turf) ))
		to_chat(user, "<span class='warning'>You must be on the ground!</span>")
		return
	if (!( istype(T, /turf/space) ))
		to_chat(user, "<span class='warning'>You cannot build on or repair this turf!</span>")
		return
	src.build(T)
	src.add_fingerprint(user)
	use(1)
	return
*/

/obj/item/stack/tile/plasteel/proc/build(turf/S as turf)


	if(istype(S,/turf/space) || istype(S,/turf/unsimulated))
		S.ChangeTurf(/turf/simulated/floor/plating/airless)
	else
		S.ChangeTurf(/turf/simulated/floor/plating)
	return

/obj/item/stack/tile/plasteel/attackby(obj/item/W as obj, mob/user as mob)
	if(iswelder(W))
		var/obj/item/weapon/weldingtool/WT = W
		if(amount < 4)
			to_chat(user, "<span class='warning'>You need at least four tiles to do this.</span>")
			return

		if(WT.remove_fuel(0,user))
			var/obj/item/stack/sheet/metal/M = getFromPool(/obj/item/stack/sheet/metal, get_turf(usr))
			M.amount = 1
			M.add_to_stacks(usr)
			user.visible_message("<span class='warning'>[src] is shaped into metal by [user.name] with the weldingtool.</span>", \
			"<span class='warning'>You shape the [src] into metal with the weldingtool.</span>", \
			"<span class='warning'>You hear welding.</span>")
			var/obj/item/stack/tile/plasteel/R = src
			src = null
			var/replace = (user.get_inactive_hand()==R)
			R.use(4)
			if (!R && replace)
				user.put_in_hands(M)
		return 1
	return ..()

/obj/item/stack/tile/plasteel/afterattack(atom/target, mob/user, adjacent, params)
	if(adjacent)
		if(isturf(target) || istype(target, /obj/structure/lattice))
			var/turf/T = get_turf(target)
			var/obj/structure/lattice/L
			var/obj/item/stack/tile/plasteel/S = src
			switch(T.canBuildPlating())
				if(BUILD_SUCCESS)
					L = locate(/obj/structure/lattice) in T
					if(!istype(L))
						return
					qdel(L)
					playsound(get_turf(src), 'sound/weapons/Genhit.ogg', 50, 1)
					S.build(T)
					S.use(1)
					return
				if(BUILD_IGNORE)
					playsound(get_turf(src), 'sound/weapons/Genhit.ogg', 50, 1)
					S.build(T)
					S.use(1)
				if(BUILD_FAILURE)
					to_chat(user, "<span class='warning'>The plating is going to need some support.</span>")
					return
