/* Diffrent misc types of tiles & the tile prototype
 * Contains:
 		Tile
 *		Grass
 *		Wood
 *		Carpet
 */

/*
 * Tile
 */
/obj/item/stack/tile
	name = "broken tile"
	singular_name = "broken tile"
	desc = "A broken tile. This should not exist."
	var/turf_type = null
	var/mineralType = null

/obj/item/stack/tile/attackby(obj/item/W as obj, mob/user as mob, params)

	if (istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W

		if(get_amount() < 4)
			user << "<span class='warning'>You need at least four tiles to do this!</span>"
			return

		if(is_hot(WT) && !mineralType)
			user << "<span class='warning'>You can not reform this!</span>"
			return

		if(WT.remove_fuel(0,user))

			if(mineralType == "plasma")
				atmos_spawn_air(SPAWN_HEAT | SPAWN_TOXINS, 5)
				user.visible_message("<span class='warning'>[user.name] sets the plasma tiles on fire!</span>", \
									"<span class='warning'>You set the plasma tiles on fire!</span>")
				qdel(src)
				return

			if (mineralType == "metal")
				var/obj/item/stack/sheet/metal/new_item = new(user.loc)
				new_item.add_to_stacks(user)
				user.visible_message("[user.name] shaped [src] into metal with the weldingtool.", \
							 "<span class='notice'>You shaped [src] into metal with the weldingtool.</span>", \
							 "<span class='italics'>You hear welding.</span>")
				var/obj/item/stack/rods/R = src
				src = null
				var/replace = (user.get_inactive_hand()==R)
				R.use(4)
				if (!R && replace)
					user.put_in_hands(new_item)

			else
				var/sheet_type = text2path("/obj/item/stack/sheet/mineral/[mineralType]")
				var/obj/item/stack/sheet/mineral/new_item = new sheet_type(user.loc)
				new_item.add_to_stacks(user)
				user.visible_message("[user.name] shaped [src] into a sheet with the weldingtool.", \
							 "<span class='notice'>You shaped [src] into a sheet with the weldingtool.</span>", \
							 "<span class='italics'>You hear welding.</span>")
				var/obj/item/stack/rods/R = src
				src = null
				var/replace = (user.get_inactive_hand()==R)
				R.use(4)
				if (!R && replace)
					user.put_in_hands(new_item)
		return
	else
		..()

/*
 * Grass
 */
/obj/item/stack/tile/grass
	name = "grass tile"
	singular_name = "grass floor tile"
	desc = "A patch of grass like they often use on golf courses."
	icon_state = "tile_grass"
	w_class = 3.0
	force = 1.0
	throwforce = 1.0
	throw_speed = 3
	throw_range = 7
	max_amount = 60
	origin_tech = "biotech=1"
	turf_type = /turf/simulated/floor/fancy/grass
	burn_state = 0 //Burnable

/*
 * Wood
 */
/obj/item/stack/tile/wood
	name = "wood floor tile"
	singular_name = "wood floor tile"
	desc = "an easy to fit wood floor tile."
	icon_state = "tile-wood"
	w_class = 3.0
	force = 1.0
	throwforce = 1.0
	throw_speed = 3
	throw_range = 7
	max_amount = 60
	origin_tech = "biotech=1"
	turf_type = /turf/simulated/floor/wood
	burn_state = 0 //Burnable

/*
 * Carpets
 */
/obj/item/stack/tile/carpet
	name = "carpet"
	singular_name = "carpet"
	desc = "A piece of carpet. It is the same size as a floor tile."
	icon_state = "tile-carpet"
	w_class = 3.0
	force = 1.0
	throwforce = 1.0
	throw_speed = 3
	throw_range = 7
	max_amount = 60
	turf_type = /turf/simulated/floor/carpet
	burn_state = 0 //Burnable

/*
 * High-traction
 */
/obj/item/stack/tile/noslip
	name = "high-traction floor tile"
	singular_name = "high-traction floor tile"
	desc = "A high-traction floor tile. It feels rubbery in your hand."
	icon_state = "tile_noslip"
	w_class = 3.0
	force = 1.0
	throwforce = 1.0
	throw_speed = 3
	throw_range = 7
	max_amount = 60
	turf_type = /turf/simulated/floor/noslip
	origin_tech = "material=3"