/obj/effect/decal/cleanable
	var/list/random_icon_states = list()
	var/blood_state = "" //I'm sorry but cleanable/blood code is ass, and so is blood_DNA
	var/bloodiness = 0 //0-100, amount of blood in this decal, used for making footprints and affecting the alpha of bloody footprints

/obj/effect/decal/cleanable/New()
	if (random_icon_states && length(src.random_icon_states) > 0)
		src.icon_state = pick(src.random_icon_states)
	create_reagents(300)
	..()

/obj/effect/decal/cleanable/attackby(obj/item/weapon/W, mob/user,)
	if(istype(W, /obj/item/weapon/reagent_containers/glass) || istype(W, /obj/item/weapon/reagent_containers/food/drinks))
		if(src.reagents && W.reagents)
			if(!src.reagents.total_volume)
				user << "<span class='notice'>[src] isn't thick enough to scoop up!</span>"
				return
			if(W.reagents.total_volume >= W.reagents.maximum_volume)
				user << "<span class='notice'>[W] is full!</span>"
				return
			user << "<span class='notice'>You scoop up [src] into [W]!</span>"
			reagents.trans_to(W, reagents.total_volume)
			if(!reagents.total_volume) //scooped up all of it
				qdel(src)
				return
	if(is_hot(W)) //todo: make heating a reagent holder proc
		if(istype(W, /obj/item/clothing/mask/cigarette)) return
		else
			var/hotness = is_hot(W)
			var/added_heat = (hotness / 100)
			src.reagents.chem_temp = min(src.reagents.chem_temp + added_heat, hotness)
			src.reagents.handle_reactions()
			user << "<span class='notice'>You heat [src] with [W]!</span>"

/obj/effect/decal/cleanable/ex_act()
	if(reagents)
		for(var/datum/reagent/R in reagents.reagent_list)
			R.on_ex_act()
	..()

/obj/effect/decal/cleanable/fire_act()
	if(reagents)
		reagents.chem_temp += 30
		reagents.handle_reactions()
	..()


//Add "bloodiness" of this blood's type, to the human's shoes
//This is on /cleanable because fuck this ancient mess
/obj/effect/decal/cleanable/Crossed(atom/movable/O)
	if(ishuman(O))
		var/mob/living/carbon/human/H = O
		if(H.shoes && blood_state)
			var/obj/item/clothing/shoes/S = H.shoes
			var/add_blood = 0
			if(bloodiness >= BLOOD_GAIN_PER_STEP)
				add_blood = BLOOD_GAIN_PER_STEP
			else
				add_blood = bloodiness
			bloodiness -= add_blood
			S.bloody_shoes[blood_state] = min(MAX_SHOE_BLOODINESS,S.bloody_shoes[blood_state]+add_blood)
			S.blood_state = blood_state
			alpha = BLOODY_FOOTPRINT_BASE_ALPHA+bloodiness
			update_icon()
			H.update_inv_shoes()
			if(!bloodiness)
				animate(src,alpha = 0,BLOOD_FADEOUT_TIME)
				sleep(BLOOD_FADEOUT_TIME)
				qdel(src)
				return