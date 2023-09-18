/obj/structure/disposalpipe/loafer
	name = "loafing device"
	desc = "A prisoner feeding device that condenses matter into an Ultra Delicious(tm) nutrition bar!"
	icon = 'monkestation/code/modules/loafing/icon/obj.dmi'
	icon_state = "loafer"


/obj/structure/disposalpipe/loafer/transfer(obj/structure/disposalholder/debris)

	//check if there's anything in there
	if (debris.contents.len)
		//start playing sound
		playsound(src.loc, "sound", 50, 1)
		src.icon_state = "loafer-on"

		//create new loaf
		var/obj/item/food/prison_loaf/loaf = new /obj/item/food/prison_loaf(src)

		//add all the garbage to the loaf's contents
		for (var/atom/movable/foodstuff in debris)
			if(foodstuff.reagents)//the object has reagents
				foodstuff.reagents.trans_to(loaf, 1000)
			if(istype(foodstuff, /obj/item/food/prison_loaf))//the object is a loaf, compress somehow
				var/obj/item/food/prison_loaf/loaf_to_grind = foodstuff
				loaf.loaf_density += loaf_to_grind.loaf_density
				loaf_to_grind = null
			else if(isliving(foodstuff))
				var/mob/living/victim = foodstuff
				//different mobs add different reagents
				if(issilicon(victim))
					loaf.reagents.add_reagent("oil", 10)
					loaf.reagents.add_reagent("iron", 10)
				else
					loaf.reagents.add_reagent("blood", 10)
					loaf.reagents.add_reagent("urine", 10)
				//then we give the loaf more power
				if(ishuman(victim))
					loaf.loaf_density += 50
				else
					loaf.loaf_density += 10
				if(!isdead(victim))
					victim.emote("scream")
				victim.death()
				if(victim.mind || victim.client)
					victim.ghostize(FALSE)
			else if (istype(foodstuff, /obj/item))//everything else
				var/obj/item/kitchen_sink = foodstuff
				var/weight = kitchen_sink.w_class
				loaf.loaf_density += weight
			debris.contents -= foodstuff
			qdel(foodstuff)

		loaf.condense()
		loaf.loc = debris.loc
		src.icon_state = "loafer"

	return transfer_to_dir(debris, nextdir(debris))

/obj/structure/disposalpipe/loafer/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(disassembled)
			if(stored)
				stored.forceMove(loc)
				transfer_fingerprints_to(stored)
				stored.setDir(dir)
				stored = null
		else
			var/turf/T = get_turf(src)
			for(var/D in GLOB.cardinals)
				if(D & dpdir)
					var/obj/structure/disposalpipe/broken/P = new(T)
					P.setDir(D)
	spew_forth()
	qdel(src)

/obj/structure/disposalconstruct/loafer
	name = "disposal pipe segment"
	desc = "A huge pipe segment used for constructing disposal systems."
	icon = 'monkestation/code/modules/loafing/icon/obj.dmi'
	icon_state = "conloafer"
	pipe_type = /obj/structure/disposalpipe/loafer

/obj/structure/disposalpipe/loafer/broken
	desc = "A broken piece of disposal pipe."
	icon_state = "loafer_broken"
	initialize_dirs = DISP_DIR_NONE

