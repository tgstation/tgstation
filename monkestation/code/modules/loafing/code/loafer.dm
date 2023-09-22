
/obj/structure/disposalpipe/loafer
	name = "loafing device"
	desc = "A prisoner feeding device that condenses matter into an Ultra Delicious(tm) nutrition bar!"
	icon = 'monkestation/code/modules/loafing/icon/obj.dmi'
	icon_state = "loafer"


/obj/structure/disposalpipe/loafer/transfer(obj/structure/disposalholder/debris)
	var/nextdir = nextdir(debris.dir)
	//check if there's anything in there
	if (debris.contents.len)
		//start playing sound
		src.icon_state = "loafer-on"
		playsound(src, 'monkestation/code/modules/loafing/sound/loafer.ogg', 50, 1)
		//create the loaf
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
					loaf.reagents.add_reagent(/datum/reagent/fuel, 10)
					loaf.reagents.add_reagent(/datum/reagent/iron, 10)
				else
					loaf.reagents.add_reagent(/datum/reagent/blood, 10)
					loaf.reagents.add_reagent(/datum/reagent/ammonia/urine, 10)
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

		//condense the loaf
		loaf.condense()
		src.icon_state = "loafer"
		playsound(src, 'sound/machines/microwave/microwave-end.ogg', 50, 1)
		debris.contents += loaf

		addtimer(CALLBACK(src, PROC_REF(output_debris), debris, nextdir), 10 SECONDS)

/obj/structure/disposalpipe/loafer/proc/output_debris(obj/structure/disposalholder/debris, nextdir)
	debris.setDir(nextdir)
	var/turf/nextturf = debris.nextloc()
	var/obj/structure/disposalpipe/nextpipe = debris.findpipe(nextturf)

	if(!nextpipe) // if there wasn't a pipe, then they'll be expelled.
		return
	// find other holder in next loc, if inactive merge it with current
	var/obj/structure/disposalholder/nextholder = locate() in nextpipe
	if(nextholder && !nextholder.active)
		if(nextholder.hasmob) //If it's stopped and there's a mob, add to the pile
			nextholder.merge(debris)
			return
		debris.merge(nextholder)//Otherwise, we push it along through.
	debris.forceMove(nextpipe)
	return nextpipe

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

