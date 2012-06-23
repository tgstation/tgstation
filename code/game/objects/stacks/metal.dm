/*
CONTAINS:
RODS
METAL
REINFORCED METAL
FLOOR TILES
*/



// RODS

/obj/item/stack/rods/attackby(obj/item/W as obj, mob/user as mob)
	..()
	if (istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W

		if(amount < 2)
			user << "\red You need at least two rods to do this."
			return

		if(WT.remove_fuel(0,user))
			var/obj/item/stack/sheet/metal/new_item = new(usr.loc)
			new_item.add_to_stacks(usr)
			for (var/mob/M in viewers(src))
				M.show_message("\red [src] is shaped into metal by [user.name] with the weldingtool.", 3, "\red You hear welding.", 2)
			var/obj/item/stack/rods/R = src
			src = null
			var/replace = (user.get_inactive_hand()==R)
			R.use(2)
			if (!R && replace)
				user.put_in_hands(new_item)
		return
	..()


/obj/item/stack/rods/attack_self(mob/user as mob)
	src.add_fingerprint(user)

	if(!istype(user.loc,/turf)) return 0

	if (locate(/obj/structure/grille, usr.loc))
		for(var/obj/structure/grille/G in usr.loc)
			if (G.destroyed)
				G.health = 10
				G.density = 1
				G.destroyed = 0
				G.icon_state = "grille"
				use(1)
			else
				return 1
	else
		if(amount < 2)
			user << "\blue You need at least two rods to do this."
			return
		usr << "\blue Assembling grille..."
		if (!do_after(usr, 10))
			return
		var/obj/structure/grille/F = new /obj/structure/grille/ ( usr.loc )
		usr << "\blue You assemble a grille"
		F.add_fingerprint(usr)
		use(2)
	return



// METAL SHEET

// /datum/stack_recipe/New(title, result_type, req_amount, res_amount, max_res_amount, time, one_per_turf, on_floor = 0)
var/global/list/datum/stack_recipe/metal_recipes = list ( \
	new/datum/stack_recipe("stool", /obj/structure/stool, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("chair", /obj/structure/stool/bed/chair, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("bed", /obj/structure/stool/bed, 2, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("table parts", /obj/item/weapon/table_parts, 2), \
	new/datum/stack_recipe("rack parts", /obj/item/weapon/rack_parts), \
	new/datum/stack_recipe("closet", /obj/structure/closet, 2, one_per_turf = 1, on_floor = 1), \
	null, \
	new/datum/stack_recipe("canister", /obj/machinery/portable_atmospherics/canister, 10, one_per_turf = 1, on_floor = 1), \
	null, \
	new/datum/stack_recipe("floor tile", /obj/item/stack/tile/plasteel, 1, 4, 10), \
	new/datum/stack_recipe("metal rod", /obj/item/stack/rods, 1, 2, 60), \
	null, \
	new/datum/stack_recipe("computer frame", /obj/structure/computerframe, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("wall girders", /obj/structure/girder, 2, time = 50, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("airlock assembly", /obj/structure/door_assembly, 4, time = 50, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("machine frame", /obj/machinery/constructable_frame/machine_frame, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("turret frame", /obj/machinery/porta_turret_construct, 5, one_per_turf = 1, on_floor = 1), \
	null, \
	new/datum/stack_recipe("apc frame", /obj/item/apc_frame, 2), \
	new/datum/stack_recipe("grenade casing", /obj/item/weapon/chem_grenade), \
	new/datum/stack_recipe("light fixture frame", /obj/item/light_fixture_frame, 2), \
	new/datum/stack_recipe("small light fixture frame", /obj/item/light_fixture_frame/small, 1), \
	null, \
	new/datum/stack_recipe("iron door", /obj/structure/mineral_door/iron, 20, one_per_turf = 1, on_floor = 1), \
)

/obj/item/stack/sheet/metal
	New(var/loc, var/amount=null)
		recipes = metal_recipes
		return ..()

// REINFORCED METAL SHEET

// /datum/stack_recipe/New(title, result_type, req_amount, res_amount, max_res_amount, time, one_per_turf, on_floor = 0)
var/global/list/datum/stack_recipe/plasteel_recipes = list ( \
	new/datum/stack_recipe("AI core", /obj/structure/AIcore, 4, one_per_turf = 1), \
	)

/obj/item/stack/sheet/plasteel
	New(var/loc, var/amount=null)
		recipes = plasteel_recipes
		return ..()



// TILES

/obj/item/stack/tile/plasteel/New(var/loc, var/amount=null)
	..()
	src.pixel_x = rand(1, 14)
	src.pixel_y = rand(1, 14)
	return

/obj/item/stack/tile/plasteel/attack_self(mob/user as mob)
	if (usr.stat)
		return
	var/T = user.loc
	if (!( istype(T, /turf) ))
		user << "\red You must be on the ground!"
		return
	if (!( istype(T, /turf/space) ))
		user << "\red You cannot build on or repair this turf!"
		return
	src.build(T)
	src.add_fingerprint(user)
	use(1)
	return

/obj/item/stack/tile/plasteel/proc/build(turf/S as turf)
	S.ReplaceWithPlating()
//	var/turf/simulated/floor/W = S.ReplaceWithFloor()
//	W.make_plating()
	return

// CARDBOARD SHEET - BubbleWrap

// /datum/stack_recipe/New(title, result_type, req_amount, res_amount, max_res_amount, time, one_per_turf, on_floor = 0)
var/global/list/datum/stack_recipe/cardboard_recipes = list ( \
	new/datum/stack_recipe("box", /obj/item/weapon/storage/box), \
	new/datum/stack_recipe("light tubes", /obj/item/weapon/storage/lightbox/tubes), \
	new/datum/stack_recipe("light bulbs", /obj/item/weapon/storage/lightbox/bulbs), \
	new/datum/stack_recipe("mouse traps", /obj/item/weapon/storage/mousetraps), \
	new/datum/stack_recipe("cardborg suit", /obj/item/clothing/suit/cardborg, 3), \
	new/datum/stack_recipe("cardborg helmet", /obj/item/clothing/head/cardborg), \
)

/obj/item/stack/sheet/cardboard
	New(var/loc, var/amount=null)
		recipes = cardboard_recipes
		return ..()
