
#define BEEBOX_MAX_FRAMES 3 //Max frames per box
#define BEES_RATIO 0.5 //Multiplied by the max number of honeycombs to find the max number of bees
#define BEE_PROB_NEW_BEE 20 //The chance for spare bee_resources to be turned into new bees
#define BEE_RESOURCE_HONEYCOMB_COST 100 //The amount of bee_resources for a new honeycomb to be produced, percentage cost 1-100
#define BEE_RESOURCE_NEW_BEE_COST 50 //The amount of bee_resources for a new bee to be produced, percentage cost 1-100



/mob/proc/bee_friendly()
	return 0



/mob/living/carbon/human/bee_friendly()
	if(dna && dna.species && dna.species.id == SPECIES_PODPERSON) //bees pollinate plants, duh.
		return 1
	if (wear_suit && head && isclothing(wear_suit) && isclothing(head))
		var/obj/item/clothing/CS = wear_suit
		var/obj/item/clothing/CH = head
		if (CS.clothing_flags & CH.clothing_flags & THICKMATERIAL)
			return 1
	return 0


/obj/structure/beebox
	name = "apiary"
	desc = "Dr. Miles Manners is just your average wasp-themed super hero by day, but by night he becomes DR. BEES!"
	icon = 'icons/obj/service/hydroponics/equipment.dmi'
	icon_state = "beebox"
	anchored = TRUE
	density = TRUE
	var/mob/living/basic/bee/queen/queen_bee = null
	var/list/bees = list() //bees owned by the box, not those inside it
	var/list/honeycombs = list()
	var/list/honey_frames = list()
	var/bee_resources = 0


/obj/structure/beebox/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)


/obj/structure/beebox/Destroy()
	STOP_PROCESSING(SSobj, src)
	queen_bee = null
	QDEL_LIST(bees)
	QDEL_LIST(honey_frames)
	QDEL_LIST(honeycombs)
	return ..()


//Premade apiaries can spawn with a random reagent
/obj/structure/beebox/premade
	var/random_reagent = FALSE


/obj/structure/beebox/premade/Initialize(mapload)
	. = ..()

	icon_state = "beebox"
	var/datum/reagent/R = null
	if(random_reagent)
		R = pick(subtypesof(/datum/reagent))
		R = GLOB.chemical_reagents_list[R]

	queen_bee = new(src)
	queen_bee.beehome = src
	bees += queen_bee
	queen_bee.assign_reagent(R)

	for(var/i in 1 to BEEBOX_MAX_FRAMES)
		var/obj/item/honey_frame/HF = new(src)
		honey_frames += HF

	for(var/i in 1 to get_max_bees())
		var/mob/living/basic/bee/B = new(src)
		bees += B
		B.beehome = src
		B.assign_reagent(R)


/obj/structure/beebox/premade/random
	icon_state = "random_beebox"
	random_reagent = TRUE


/obj/structure/beebox/process()
	if(queen_bee)
		if(bee_resources >= BEE_RESOURCE_HONEYCOMB_COST)
			if(honeycombs.len < get_max_honeycomb())
				bee_resources = max(bee_resources-BEE_RESOURCE_HONEYCOMB_COST, 0)
				var/obj/item/food/honeycomb/HC = new(src)
				if(queen_bee.beegent)
					HC.set_reagent(queen_bee.beegent.type)
				honeycombs += HC

		if(bees.len < get_max_bees())
			var/freebee = FALSE //a freebee, geddit?, hahaha HAHAHAHA
			if(bees.len <= 1) //there's always one set of worker bees, this isn't colony collapse disorder its 2d spessmen
				freebee = TRUE
			if((bee_resources >= BEE_RESOURCE_NEW_BEE_COST && prob(BEE_PROB_NEW_BEE)) || freebee)
				if(!freebee)
					bee_resources = max(bee_resources - BEE_RESOURCE_NEW_BEE_COST, 0)
				var/mob/living/basic/bee/B = new(get_turf(src))
				B.beehome = src
				B.assign_reagent(queen_bee.beegent)
				bees += B


/obj/structure/beebox/proc/get_max_honeycomb()
	. = 0
	for(var/hf in honey_frames)
		var/obj/item/honey_frame/HF = hf
		. += HF.honeycomb_capacity


/obj/structure/beebox/proc/get_max_bees()
	. = get_max_honeycomb() * BEES_RATIO


/obj/structure/beebox/examine(mob/user)
	. = ..()

	if(!queen_bee)
		. += span_warning("There is no queen bee! There won't bee any honeycomb without a queen!")

	var/half_bee = get_max_bees()*0.5
	if(half_bee && (bees.len >= half_bee))
		. += span_notice("This place is aBUZZ with activity... there are lots of bees!")

	. += span_notice("[bee_resources]/100 resource supply.")
	. += span_notice("[bee_resources]% towards a new honeycomb.")
	. += span_notice("[bee_resources*2]% towards a new bee.")

	if(honeycombs.len)
		var/plural = honeycombs.len > 1
		. += span_notice("There [plural? "are" : "is"] [honeycombs.len] uncollected honeycomb[plural ? "s":""] in the apiary.")

	if(honeycombs.len >= get_max_honeycomb())
		. += span_warning("There's no room for more honeycomb!")

/obj/structure/beebox/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool)
	return ITEM_INTERACT_SUCCESS

/obj/structure/beebox/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/honey_frame))
		var/obj/item/honey_frame/HF = I
		if(honey_frames.len < BEEBOX_MAX_FRAMES)
			visible_message(span_notice("[user] adds a frame to the apiary."))
			if(!user.transferItemToLoc(HF, src))
				return
			honey_frames += HF
		else
			to_chat(user, span_warning("There's no room for any more frames in the apiary!"))
		return

	if(istype(I, /obj/item/queen_bee))
		if(queen_bee)
			to_chat(user, span_warning("This hive already has a queen!"))
			return

		var/obj/item/queen_bee/new_queen = I
		user.temporarilyRemoveItemFromInventory(new_queen)

		bees += new_queen.queen
		queen_bee = new_queen.queen

		new_queen.queen.forceMove(src)

		if(queen_bee)
			visible_message(span_notice("[user] sets [queen_bee] down inside the apiary, making it their new home."))
			var/relocated = 0
			for(var/b in bees)
				var/mob/living/basic/bee/B = b
				if(B.reagent_incompatible(queen_bee))
					bees -= B
					B.beehome = null
					if(B.loc == src)
						B.forceMove(drop_location())
					relocated++
			if(relocated)
				to_chat(user, span_warning("This queen has a different reagent to some of the bees who live here, those bees will not return to this apiary!"))

		else
			to_chat(user, span_warning("The queen bee disappeared! Disappearing bees have been in the news lately..."))

		return

	..()

/obj/structure/beebox/interact(mob/user)
	. = ..()
	if(!user.bee_friendly())
		//Time to get stung!
		var/bees_attack = FALSE
		for(var/mob/living/basic/bee/worker as anything in bees) //everyone who's ever lived here now instantly hates you, suck it assistant!
			if(worker.is_queen)
				continue
			if(worker.loc == src)
				worker.forceMove(drop_location())
			bees_attack = TRUE
		if(bees_attack)
			visible_message(span_danger("[user] disturbs the bees!"))
		else
			visible_message(span_danger("[user] disturbs the [name] to no effect!"))
	else
		var/option = tgui_alert(user, "Which piece do you wish to remove?", "Apiary Adjustment", list("Honey Frame", "Queen Bee"))
		if(!option || QDELETED(user) || QDELETED(src) || !user.can_perform_action(src, NEED_DEXTERITY))
			return
		switch(option)
			if("Honey Frame")
				if(!honey_frames.len)
					to_chat(user, span_warning("There are no honey frames to remove!"))
					return

				var/obj/item/honey_frame/HF = pick_n_take(honey_frames)
				if(HF)
					if(!user.put_in_active_hand(HF))
						HF.forceMove(drop_location())
					visible_message(span_notice("[user] removes a frame from the apiary."))

					var/amtH = HF.honeycomb_capacity
					var/fallen = 0
					while(honeycombs.len && amtH) //let's pretend you always grab the frame with the most honeycomb on it
						var/obj/item/food/honeycomb/HC = pick_n_take(honeycombs)
						if(HC)
							HC.forceMove(drop_location())
							amtH--
							fallen++
					if(fallen)
						var/multiple = fallen > 1
						visible_message(span_notice("[user] scrapes [multiple ? "[fallen]" : "a"] honeycomb[multiple ? "s" : ""] off of the frame."))

			if("Queen Bee")
				if(!queen_bee || queen_bee.loc != src)
					to_chat(user, span_warning("There is no queen bee to remove!"))
					return
				var/obj/item/queen_bee/QB = new()
				queen_bee.forceMove(QB)
				bees -= queen_bee
				QB.queen = queen_bee
				QB.name = queen_bee.name
				if(!user.put_in_active_hand(QB))
					QB.forceMove(drop_location())
				visible_message(span_notice("[user] removes the queen from the apiary."))
				queen_bee = null

/obj/structure/beebox/atom_deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/mineral/wood (loc, 20)
	for(var/mob/living/basic/bee/worker as anything in bees)
		if(worker.loc == src)
			worker.forceMove(get_turf(src))
		bees -= worker
		worker.beehome = null
	for(var/obj/item/honey_frame/frame as anything in honey_frames)
		if(frame.loc == src)
			frame.forceMove(get_turf(src))
		honey_frames -= frame

/obj/structure/beebox/unwrenched
	anchored = FALSE

/obj/structure/beebox/proc/habitable(mob/living/basic/target)
	if(!istype(target, /mob/living/basic/bee))
		return FALSE
	var/mob/living/basic/bee/citizen = target
	if(citizen.reagent_incompatible(queen_bee) || bees.len >= get_max_bees())
		return FALSE
	return TRUE

#undef BEE_PROB_NEW_BEE
#undef BEE_RESOURCE_HONEYCOMB_COST
#undef BEE_RESOURCE_NEW_BEE_COST
#undef BEEBOX_MAX_FRAMES
#undef BEES_RATIO
