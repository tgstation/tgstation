/* Not quite there yet
#define ANY_SIDE list(NORTH,SOUTH,EAST,WEST)

/layout_rule/place_adjacent/workbench
	placetype=/obj/structure/table

	min_to_place=3
	min_to_place=7

	next_to=list(
		/turf/simulated/wall = ANY_SIDE,
		/turf/simulated/wall/r_wall = ANY_SIDE,
	)
	// MUST NOT be next to these.
	not_next_to=list()

	decorations=list(
		/obj/item/weapon/screwdriver=2,
		/obj/item/weapon/crowbar=2,
		/obj/item/stack/metal=1,
		/obj/item/weapon/wrench=2
	)

/layout_rule/place_adjacent/workbench/wooden
	placetype=/obj/structure/table/woodentable

/layout_rule/place_adjacent/workbench/reinforced
	placetype=/obj/structure/table/reinforced

/layout_rule/place_adjacent/chair
	placetype=/obj/structure/stool/bed/chair

	min_to_place=1
	min_to_place=2

	next_to=list(
		/obj/structure/table = ANY_SIDE,
	)
	// MUST NOT be next to these.
	not_next_to=list(
		/obj/structure/stool/bed/chair = ANY_SIDE
	)

	//flags = FACE_MATCH

/layout_rule/place_adjacent/chair/wooden
	placetype=/obj/structure/stool/bed/chair/wooden

	min_to_place=1
	min_to_place=2

	next_to=list(
		/obj/structure/table/wooden = ANY_SIDE,
	)
	// MUST NOT be next to these.
	not_next_to=list(
		/obj/structure/stool/bed/chair = ANY_SIDE
	)

	//flags = FACE_MATCH
*/
/mining_surprise/human
	name="Hidden Complex"
	floortypes = list(
		/turf/simulated/floor/airless=95,
		/turf/simulated/floor/plating/airless=5
	)
	walltypes = list(
		/turf/simulated/wall=100
	)
	spawntypes = list(
		/obj/item/weapon/pickaxe/silver					=4,
		/obj/item/weapon/pickaxe/drill					=4,
		/obj/item/weapon/pickaxe/jackhammer				=4,
		/obj/item/weapon/pickaxe/diamond				=3,
		/obj/item/weapon/pickaxe/diamonddrill			=3,
		/obj/item/weapon/pickaxe/gold					=3,
		/obj/item/weapon/pickaxe/plasmacutter			=2,
		/obj/structure/closet/syndicate/resources		=2,
		/obj/item/weapon/melee/energy/sword/pirate		=1,
		/obj/mecha/working/ripley/mining				=1
	)
	complex_max_size=2

	flags = CONTIGUOUS_WALLS | CONTIGUOUS_FLOORS

/mining_surprise/alien_nest
	name="Hidden Nest"
	floortypes = list(
		/turf/unsimulated/floor/asteroid=100
	)

	walltypes = list(
		/turf/unsimulated/mineral/random/high_chance=1
	)

	spawntypes = list(
		/obj/item/clothing/mask/facehugger				=4,
		/obj/mecha/working/ripley/mining				=1
	)
	fluffitems = list(
		/obj/effect/decal/remains/human                 = 5,
		/obj/effect/decal/cleanable/blood/xeno          = 5,
		/obj/effect/decal/mecha_wreckage/ripley			= 1
	)
	complex_max_size=6
	room_size_max=7

	var/const/eggs_left=10 // Per complex
	var/turf/weeds[0] // Turfs with weeds.
	postProcessComplex()
		..()
		var/list/all_floors=list()
		for(var/surprise_room/room in rooms)
			var/list/w_cand=room.GetTurfs(TURF_FLOOR)
			all_floors |= w_cand
			var/egged=0
			while(w_cand.len>0)
				var/turf/weed_turf = pick(w_cand)
				w_cand -= weed_turf
				if(weed_turf.density)
					continue
				if(locate(/obj/effect/alien) in weed_turf)
					continue
				if(weed_turf && !egged)
					new /obj/effect/alien/weeds/node(weed_turf)
					weeds += weed_turf
					break

		for(var/e=0;e<eggs_left;e++)
			var/turf/egg_turf = pick(all_floors)
			if(egg_turf && !(locate(/obj/effect/alien) in egg_turf))
				new /obj/effect/alien/egg(egg_turf)
