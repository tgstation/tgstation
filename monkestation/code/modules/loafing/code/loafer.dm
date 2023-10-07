/obj/structure/disposalpipe/loafer
	name = "loafing device"
	desc = "A prisoner feeding device that condenses matter into an Ultra Delicious(tm) nutrition bar!"
	icon = 'monkestation/code/modules/loafing/icons/obj.dmi'
	icon_state = "loafer"
	var/is_loafing = FALSE
	var/list/loaf_blacklist = list(/obj/item/organ/internal/brain, /obj/item/bodypart/head)

/obj/structure/disposalpipe/loafer/transfer(obj/structure/disposalholder/holder)
	if(is_loafing)
		return src
	//check if there's anything in there
	if (holder.contents.len)
		//start playing sound
		is_loafing = TRUE
		src.icon_state = "loafer-on"
		src.update_appearance()
		playsound(src, 'monkestation/code/modules/loafing/sound/loafer.ogg', 100, 1, mixer_channel = CHANNEL_MACHINERY)

		//create new loaf
		var/obj/item/food/prison_loaf/loaf = new /obj/item/food/prison_loaf(src)

		//add all the garbage to the loaf's contents
		for (var/atom/movable/debris in holder)
			if(debris.resistance_flags & INDESTRUCTIBLE || (debris.type in loaf_blacklist))
				if(holder.contents.len > 1)
					continue
				else
					loaf = null
					src.icon_state = "loafer"
					is_loafing = FALSE
					return transfer_to_dir(holder, nextdir(holder))
			if(debris.reagents)//the object has reagents
				debris.reagents.trans_to(loaf, 1000)
			if(istype(debris, /obj/item/food/prison_loaf))//the object is a loaf, compress somehow
				var/obj/item/food/prison_loaf/loaf_to_grind = debris
				loaf.loaf_density += loaf_to_grind.loaf_density * 1.05
				loaf_to_grind = null
			else if(isliving(debris))
				var/mob/living/victim = debris
				//different mobs add different reagents
				if(issilicon(victim))
					loaf.reagents.add_reagent(/datum/reagent/fuel, 10)
					loaf.reagents.add_reagent(/datum/reagent/iron, 10)
				else
					loaf.reagents.add_reagent(/datum/reagent/bone_dust, 3)
					loaf.reagents.add_reagent(/datum/reagent/ammonia/urine, 2)
					loaf.reagents.add_reagent(/datum/reagent/consumable/liquidgibs, 2)
					loaf.reagents.add_reagent(/datum/reagent/consumable/nutriment/organ_tissue, 2)
				//then we give the loaf more power
				if(ishuman(victim))
					loaf.loaf_density += 25
				else
					loaf.loaf_density += 10
				if(!isdead(victim))
					victim.emote("scream")
				victim.gib()
				if(victim.mind || victim.client)
					victim.ghostize(FALSE)
			else if (istype(debris, /obj/item))//everything else
				var/obj/item/kitchen_sink = debris
				var/weight = kitchen_sink.w_class
				loaf.loaf_density += weight * 3
			holder.contents -= debris
			qdel(debris)

		sleep(3 SECONDS)

		//condense the loaf
		loaf.condense()
		//place the loaf
		loaf.forceMove(holder)
		holder.contents += loaf
		is_loafing = FALSE
		src.icon_state = "loafer"
	return transfer_to_dir(holder, nextdir(holder))

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
	name = "loafing device"
	desc = "A prisoner feeding device that condenses matter into an Ultra Delicious(tm) nutrition bar!"
	icon = 'monkestation/code/modules/loafing/icons/obj.dmi'
	icon_state = "conloafer"
	pipe_type = /obj/structure/disposalpipe/loafer


//spawning

/obj/effect/spawner/random/loafer
	name = "loafer spawner"
	spawn_scatter_radius = 5
	var/spawn_loot_chance = 20
	layer = DISPOSAL_PIPE_LAYER

/obj/effect/spawner/random/loafer/Initialize(mapload)
	loot = list(
		/obj/structure/disposalpipe/loafer/)
	return ..()
