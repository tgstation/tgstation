/obj/effect/decal/cleanable
	gender = PLURAL
	layer = ABOVE_NORMAL_TURF_LAYER
	var/list/random_icon_states = list()
	var/blood_state = "" //I'm sorry but cleanable/blood code is ass, and so is blood_DNA
	var/bloodiness = 0 //0-100, amount of blood in this decal, used for making footprints and affecting the alpha of bloody footprints
	var/mergeable_decal = 1 //when two of these are on a same tile or do we need to merge them into just one?

/obj/effect/decal/cleanable/Initialize(mapload)
	if (random_icon_states && length(src.random_icon_states) > 0)
		src.icon_state = pick(src.random_icon_states)
	create_reagents(300)
	if(src.loc && isturf(src.loc))
		for(var/obj/effect/decal/cleanable/C in src.loc)
			if(C != src && C.type == src.type)
				replace_decal(C)
	. = ..()



/obj/effect/decal/cleanable/proc/replace_decal(obj/effect/decal/cleanable/C)
	if(mergeable_decal)
		qdel(C)

/obj/effect/decal/cleanable/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/reagent_containers/glass) || istype(W, /obj/item/reagent_containers/food/drinks))
		if(src.reagents && W.reagents)
			. = 1 //so the containers don't splash their content on the src while scooping.
			if(!src.reagents.total_volume)
				to_chat(user, "<span class='notice'>[src] isn't thick enough to scoop up!</span>")
				return
			if(W.reagents.total_volume >= W.reagents.maximum_volume)
				to_chat(user, "<span class='notice'>[W] is full!</span>")
				return
			to_chat(user, "<span class='notice'>You scoop up [src] into [W]!</span>")
			reagents.trans_to(W, reagents.total_volume)
			if(!reagents.total_volume) //scooped up all of it
				qdel(src)
				return
	if(W.is_hot()) //todo: make heating a reagent holder proc
		if(istype(W, /obj/item/clothing/mask/cigarette))
			return
		else
			var/hotness = W.is_hot()
			var/added_heat = (hotness / 100)
			src.reagents.chem_temp = min(src.reagents.chem_temp + added_heat, hotness)
			src.reagents.handle_reactions()
			to_chat(user, "<span class='notice'>You heat [src] with [W]!</span>")
	else
		return ..()

/obj/effect/decal/cleanable/ex_act()
	if(reagents)
		for(var/datum/reagent/R in reagents.reagent_list)
			R.on_ex_act()
	..()

/obj/effect/decal/cleanable/fire_act(exposed_temperature, exposed_volume)
	if(reagents)
		reagents.chem_temp += 30
		reagents.handle_reactions()
	..()


//Add "bloodiness" of this blood's type, to the human's shoes
//This is on /cleanable because fuck this ancient mess
/obj/effect/decal/cleanable/Crossed(atom/movable/O)
	if(ishuman(O))
		var/mob/living/carbon/human/H = O
		if(H.shoes && blood_state && bloodiness)
			var/obj/item/clothing/shoes/S = H.shoes
			var/add_blood = 0
			if(bloodiness >= BLOOD_GAIN_PER_STEP)
				add_blood = BLOOD_GAIN_PER_STEP
			else
				add_blood = bloodiness
			bloodiness -= add_blood
			S.bloody_shoes[blood_state] = min(MAX_SHOE_BLOODINESS,S.bloody_shoes[blood_state]+add_blood)
			if(blood_DNA && blood_DNA.len)
				S.add_blood(blood_DNA)
			S.blood_state = blood_state
			update_icon()
			H.update_inv_shoes()



/obj/effect/decal/cleanable/proc/can_bloodcrawl_in()
	if((blood_state != BLOOD_STATE_OIL) && (blood_state != BLOOD_STATE_NOT_BLOODY))
		return bloodiness
	else
		return 0
