/obj/item/stack/sheet/mineral/reagent
	name = "reagent ingots"
	desc = "Ingots made out of treated solidified reagents"
	singular_name = "reagent ingot"
	icon_state = "sheet-silver"
	materials = list(MAT_REAGENT=MINERAL_MATERIAL_AMOUNT)
	merge_type = /obj/item/stack/sheet/mineral/reagent
	amount = 1
	max_amount = 50
	var/datum/reagent/reagent_type


GLOBAL_LIST_INIT(reagent_recipes, list ( \
	new/datum/stack_recipe("reagent door", /obj/structure/mineral_door/transparent/reagent, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("reagent tile", /obj/item/stack/tile/mineral/reagent, 1, 4, 20), \
	new/datum/stack_recipe("reagent wall", /turf/closed/wall/mineral/reagent, 4, one_per_turf = 1, on_floor = 1), \
	))

/obj/item/stack/sheet/mineral/reagent/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.reagent_recipes
	. = ..()


/obj/item/stack/sheet/mineral/reagent/change_stack(mob/user,amount)
	var/obj/item/stack/sheet/mineral/reagent/F = new(user, amount, FALSE)
	if(!isnull(reagent_type))
		F.reagent_type = reagent_type
		F.name = "[reagent_type.name] ingots"
		F.singular_name = "[reagent_type.name] ingot"
		F.add_atom_colour(reagent_type.color, FIXED_COLOUR_PRIORITY)

	F.copy_evidences(src)
	user.put_in_hands(F)
	add_fingerprint(user)
	F.add_fingerprint(user)
	use(amount, TRUE)


/obj/item/stack/sheet/mineral/reagent/merge(obj/item/stack/S) //Merge src into S, as much as possible
	if(!istype(S, /obj/item/stack/sheet/mineral/reagent))
		return
	var/obj/item/stack/sheet/mineral/reagent/R = S
	if(QDELETED(S) || QDELETED(src) || S == src || !R.reagent_type || !reagent_type || R.reagent_type.id != reagent_type.id) //amusingly this can cause a stack to consume itself, let's not allow that.
		return

	var/transfer = get_amount()

	if(S.is_cyborg)
		transfer = min(transfer, round((S.source.max_energy - S.source.energy) / S.cost))
	else
		transfer = min(transfer, S.max_amount - S.amount)

	if(pulledby)
		pulledby.start_pulling(S)

	S.copy_evidences(src)
	use(transfer, TRUE)
	S.add(transfer)


/obj/item/stack/sheet/mineral/reagent/Topic(href, href_list)//this is a disgusting proc
	if(usr.restrained() || usr.stat || usr.get_active_held_item() != src)
		return
	if(href_list["make"])
		if (get_amount() < 1)
			qdel(src) //Never should happen

		var/datum/stack_recipe/R = recipes[text2num(href_list["make"])]
		var/multiplier = text2num(href_list["multiplier"])
		if(!multiplier ||(multiplier <= 0)) //href protection
			return
		if(!building_checks(R, multiplier))
			return

		if(R.result_type == /turf/closed/wall/mineral/reagent)
			to_chat(usr, "<span class='notice'>You start building the wall</span>")
			if(do_after(usr, 50, target = src))
				use(R.req_amount * multiplier)
				var/turf/T = get_turf(usr)
				var/turf/closed/wall/mineral/reagent/W = T.ChangeTurf(/turf/closed/wall/mineral/reagent)
				var/paths = subtypesof(/datum/reagent)
				for(var/path in paths)
					var/datum/reagent/RR = new path
					if(RR.id == reagent_type.id)
						W.reagent_type = RR
						W.name ="[reagent_type] plated wall"
						W.desc = "A wall plated with sheets of [reagent_type]"
						W.add_atom_colour(reagent_type.color, FIXED_COLOUR_PRIORITY)
						W.hardness = W.hardness / reagent_type.density
						W.slicing_duration = 50 * reagent_type.density
						break
					else
						qdel(RR)

			if(src && usr.machine==src) //do not reopen closed window
				addtimer(CALLBACK(src, /atom/.proc/interact, usr), 0)
			return

		var/obj/O
		if(R.max_res_amount > 1) //Is it a stack?
			O = new R.result_type(usr.drop_location(), R.res_amount * multiplier)
		else
			O = new R.result_type(usr.drop_location())
		O.setDir(usr.dir)
		use(R.req_amount * multiplier)

		if(istype(O, /obj/structure/mineral_door/transparent/reagent))
			var/obj/structure/mineral_door/transparent/reagent/D = O
			var/paths = subtypesof(/datum/reagent)
			for(var/path in paths)
				var/datum/reagent/RR = new path
				if(RR.id == reagent_type.id)
					D.reagent_type = RR
					D.name ="[reagent_type] door"
					D.desc = "A slightly transparent door made out of sheets of [reagent_type]"
					D.add_atom_colour(reagent_type.color, FIXED_COLOUR_PRIORITY)
					D.max_integrity = reagent_type.density * 100
					D.obj_integrity = D.max_integrity
					break
				else
					qdel(RR)

		if(istype(O, /obj/item/stack/tile/mineral/reagent))
			var/obj/item/stack/tile/mineral/reagent/F = O
			var/paths = subtypesof(/datum/reagent)
			for(var/path in paths)
				var/datum/reagent/RR = new path
				if(RR.id == reagent_type.id)
					F.reagent_type = RR
					F.name ="[reagent_type] floor tiles"
					F.singular_name = "[reagent_type] floor tile"
					F.desc = "Floor tiles made of [reagent_type]"
					F.add_atom_colour(reagent_type.color, FIXED_COLOUR_PRIORITY)
					break
				else
					qdel(RR)