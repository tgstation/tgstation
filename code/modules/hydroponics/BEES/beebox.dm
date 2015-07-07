#define BEEBOX_MAX_FRAMES 				3		//How many frames can one beebox store
#define BEES_RATIO						0.5		//A value to times the max number of honeycombs by to find the max number of bees
#define BEE_PROB_NEW_BEE				20		//The chance for spare bee_resources to be turned into new bees
#define BEE_RESOURCE_HONEYCOMB_COST		100		//The amount of bee_resources for a new honeycomb to be produced
#define BEE_RESOURCE_NEW_BEE_COST		50		//The amount of bee_resources for a new bee swarm to be produced

/obj/structure/beebox
	name = "beebox"
	desc = "Dr Miles Manners is just your average Wasp themed super hero by day, but by night he becomes DR BEES!"
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "beebox"
	anchored = 1
	density = 1
	var/mob/living/simple_animal/hostile/poison/bees/queen/queen_bee = null
	var/list/bees = list() //list of bees who belong to this box, NOT how many are inside it
	var/list/honeycombs = list()
	var/list/honey_frames = list()
	var/bee_resources = 0


//PREMADE BEEBOXES
/obj/structure/beebox/premade
	var/random_reagent = FALSE

/obj/structure/beebox/premade/New()
	..()

	var/datum/reagent/R = null
	if(random_reagent)
		var/reag = pick(typesof(/datum/reagent) - /datum/reagent)
		R = new reag

	queen_bee = new(src)
	bees |= queen_bee
	if(R)
		queen_bee.beegent = R
		queen_bee.generate_bee_visuals()

	for(var/i = 1, i<= BEEBOX_MAX_FRAMES, i++)
		var/obj/item/honey_frame/HF = new(src)
		honey_frames |= HF

	for(var/i = 1, i<= get_max_bees(), i++)
		var/mob/living/simple_animal/hostile/poison/bees/B = new(src)
		bees |= B
		B.beehome = src
		if(R)
			B.beegent = R
			B.generate_bee_visuals()


/obj/structure/beebox/premade/random
	random_reagent = TRUE
//END PREMADE


/obj/structure/beebox/New()
	..()
	SSobj.processing += src


/obj/structure/beebox/Destroy()
	SSobj.processing -= src
	for(var/atom/movable/AM in contents)
		AM.loc = get_turf(src)
	bees = null
	honeycombs = null
	honey_frames = null
	queen_bee = null
	..()


/obj/structure/beebox/process()
	if(queen_bee)
		if(bee_resources >= BEE_RESOURCE_HONEYCOMB_COST)
			if(get_honeycomb_amt() < get_max_honeycomb())
				bee_resources = 0
				var/obj/item/weapon/reagent_containers/honeycomb/HC = new /obj/item/weapon/reagent_containers/honeycomb(src)
				if(queen_bee.beegent)
					HC.icon_state = "honeycomb_grey"
					HC.reagents.add_reagent(queen_bee.beegent.id,5)
					HC.color = queen_bee.beegent.color
				honeycombs += HC

		if(get_bees_amt() < get_max_bees())
			var/freebee = FALSE
			if(!get_bees_amt()) //there is always one set of worker bees, so a colony doesn't die
				freebee = TRUE
			if((bee_resources >= BEE_RESOURCE_NEW_BEE_COST && prob(BEE_PROB_NEW_BEE)) || freebee)
				if(!freebee)
					bee_resources = max(bee_resources - 50, 0)
				var/mob/living/simple_animal/hostile/poison/bees/Bee = new /mob/living/simple_animal/hostile/poison/bees (src)
				Bee.beehome = src
				Bee.beegent = queen_bee.beegent
				Bee.generate_bee_visuals()
				bees += Bee


/obj/structure/beebox/proc/get_max_honeycomb()
	. = 0
	for(var/obj/item/honey_frame/HF in honey_frames)
		. += HF.honeycomb_capacity


/obj/structure/beebox/proc/get_max_bees()
	. = get_max_honeycomb() * BEES_RATIO


/obj/structure/beebox/proc/get_honeycomb_amt()
	listclearnulls(honeycombs)
	. = honeycombs.len


/obj/structure/beebox/proc/get_bees_amt()
	listclearnulls(bees)
	. = bees.len


/obj/structure/beebox/proc/get_frames_amt()
	listclearnulls(honey_frames)
	. = honey_frames.len


/obj/structure/beebox/examine(mob/user)
	..()

	if(get_bees_amt() >= get_max_bees()*0.5)
		user << "This place is a BUZZ with activity..."

	if(bee_resources)
		user << "[bee_resources]/100 honey supply"
		user << "[bee_resources]% towards a new Honeycomb"
		user << "[bee_resources*2]% towards a new Bee swarm"

	if(get_honeycomb_amt() >= get_max_honeycomb())
		user << "there's no room for more honeycomb!"


/obj/structure/beebox/attackby(var/obj/item/I, var/mob/user, params)
	if(istype(I, /obj/item/weapon/crowbar))
		if(get_frames_amt())
			var/obj/item/honey_frame/HF = pick_n_take(honey_frames)
			if(HF)
				HF.loc = get_turf(src)
				visible_message("<span class='notice'>[user] removes a frame from the beebox</span>")

				//if our capacity is now less than the amount we're storing
				//dump out the extras.
				var/amtH = get_honeycomb_amt()
				var/maxH = get_max_honeycomb()
				var/fallen = 0
				while(amtH > maxH)
					var/obj/item/weapon/reagent_containers/honeycomb/HC = pick_n_take(honeycombs)
					honeycombs -= HC
					HC.loc = get_turf(src)
					amtH--
					fallen++
				if(fallen)
					if(fallen > 1)
						visible_message("<span class='notice'>[fallen] honeycombs have fallen out of the beebox!</span>")
					else
						visible_message("<span class='notice'>[fallen] honeycomb has fallen out of the beebox!</span>")

		else
			user << "<span class='warning'>There are no frames to remove!</span>"

	if(istype(I, /obj/item/honey_frame))
		var/obj/item/honey_frame/HF = I
		if(get_frames_amt() < BEEBOX_MAX_FRAMES)
			visible_message("<span class='notice'>[user] adds a frame to the beebox</span>")
			user.unEquip(HF)
			HF.loc = src
			honey_frames |= HF
		else
			user << "<span class='warning'>There's no room for anymore frames in the beebox!</span>"

	if(istype(I, /obj/item/weapon/wrench))
		anchored = !anchored
		user << "<span class='notice'>you [anchored ? "anchor" : "unanchor"] the beebox.</span>"


/obj/structure/beebox/attack_hand(mob/user)
	if(istype(user, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		var/turf/T = get_turf(src)

		if(!(H.wear_suit && H.wear_suit.bee_friendly && H.head && H.head.bee_friendly))

			//Time to get stung!
			var/bees = FALSE
			for(var/mob/living/simple_animal/hostile/poison/bees/B in src)
				if(B.isqueen)
					continue
				B.loc = T
				B.target = user
				bees = TRUE
			if(bees)
				visible_message("<span class='danger'>[user] disturbs the bees!</span>")


		else if(get_honeycomb_amt())
			for(var/obj/item/weapon/reagent_containers/honeycomb/HC in honeycombs)
				HC.loc = T
				honeycombs -= HC
			visible_message("<span class='notice'>[user] empties the honeycombs out of the beebox</span>")
