#define BEE_IDLE_ROAMING 		70 	//The value of idle at which a bee in a beebox can try to wander around
#define BEE_IDLE_GOHOME			0	//The value of itdle at which a bee will try to go home

#define BEE_PROB_GOHOME			35	//Probability to go home when idle is below BEE_IDLE_GOHOME
#define BEE_PROB_GOROAM			5	//Probability to go roamining when idle is above BEE_IDLE_ROAMING

#define BEE_TRAY_RECENT_VISIT	200	//How long in deciseconds until a tray can be visited by a bee again

/mob/living/simple_animal/hostile/poison/bees
	name = "space bee swarm"
	desc = "buzzy buzzy bees, stingy sti- Ouch!"
	icon_state = "bee_1"
	icon_living = "bee"
	speak_emote = list("buzzes")
	emote_hear = list("buzzes")
	turns_per_move = 0
	melee_damage_lower = 1
	melee_damage_upper = 1
	attacktext = "stings"
	response_help  = "shoos"
	response_disarm = "swats away"
	response_harm   = "squashes"
	maxHealth = 10
	health = 10
	faction = list("hostile")
	move_to_delay = 0
	environment_smash = 0
	mouse_opacity = 2
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	mob_size = MOB_SIZE_SMALL
	flying = 1
	search_objects = 1 //have to find those plant trays!

	//Spaceborn beings don't get hurt by space
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0

	//wanted_objects = list(/obj/machinery/hydroponics) //so they actually go back and forth between the trays and their beebox

	//I'M FUNNY OK
	var/datum/reagent/beegent = null
	var/obj/structure/beebox/beehome = null
	var/idle = 0
	var/isqueen = FALSE
	var/ready_to_mutate = FALSE

/mob/living/simple_animal/hostile/poison/bees/Process_Spacemove(var/movement_dir = 0)
	return 1

/mob/living/simple_animal/hostile/poison/bees/New()
	..()
	generate_bee_visuals()


/mob/living/simple_animal/hostile/poison/bees/death(gibbed)
	..(1)

	if(beehome)
		beehome.bees -= src
		beehome = null

	ghostize()
	qdel(src)
	return


/mob/living/simple_animal/hostile/poison/bees/Destroy()
	if(beehome)
		beehome.bees -= src
		beehome = null
	..()


/mob/living/simple_animal/hostile/poison/bees/proc/generate_bee_visuals()
	overlays.Cut()

	if(beegent && beegent.color)
		color = beegent.color

	for(var/i =1, i<=health, i++)
		var/N = rand(1,4)
		var/image/I = image(icon='icons/mob/animal.dmi',icon_state="bee_[N]",pixel_x = rand(-8, 8), pixel_y = rand(-8, 8))
		overlays += I


//We don't attack beekeepers/people dressed as bees
/mob/living/simple_animal/hostile/poison/bees/CanAttack(var/atom/the_target)
	. = ..()
	if(!.)
		return 0
	if(istype(the_target, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = the_target
		//I am the beekeeper!
		if(H.wear_suit && H.wear_suit.bee_friendly && H.head && H.head.bee_friendly)
			return 0


/mob/living/simple_animal/hostile/poison/bees/Found(var/atom/A)
	if(istype(A, /obj/machinery/hydroponics))
		var/obj/machinery/hydroponics/Hydro = A
		if(Hydro.myseed && !Hydro.dead && !Hydro.recent_bee_visit)
			wanted_objects += /obj/machinery/hydroponics //so we only hunt them while they're alive/seeded/not visisted
			return 1
	if(istype(A, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = A
		if(!(H.wear_suit && H.wear_suit.bee_friendly && H.head && H.head.bee_friendly))
			return 1
	return 0


/mob/living/simple_animal/hostile/poison/bees/AttackingTarget()
	//Pollinate
	if(istype(target, /obj/machinery/hydroponics))
		var/obj/machinery/hydroponics/Hydro = target
		pollinate(Hydro)

	//Enter home
	else if(target == beehome)
		var/obj/structure/beebox/BB = target
		loc = BB
		target = null
		wanted_objects -= /obj/structure/beebox //so we don't attack beeboxes when not going home

	else
		if(beegent && istype(target, /mob/living))
			var/mob/living/L = target
			beegent.reaction_mob(L, TOUCH)
		target.attack_animal(src)


/mob/living/simple_animal/hostile/poison/bees/proc/pollinate(var/obj/machinery/hydroponics/Hydro)
	if(!istype(Hydro) || !Hydro.myseed || Hydro.dead || Hydro.recent_bee_visit)
		target = null
		return

	target = null //so we pick a new hydro tray next FindTarget(), instead of loving the same plant for eternity
	wanted_objects -= /obj/machinery/hydroponics //so we only hunt them while they're alive/seeded/not visisted
	Hydro.recent_bee_visit = TRUE
	spawn(BEE_TRAY_RECENT_VISIT)
		if(Hydro)
			Hydro.recent_bee_visit = FALSE

	var/growth = health //Health also means how many bees are in the swarm, roughly.
	//better healthier plants!
	Hydro.health += growth
	Hydro.pestlevel = max(0,--Hydro.pestlevel)
	Hydro.yieldmod++

	if(beehome)
		beehome.bee_resources = min(beehome.bee_resources + growth, 100)



/mob/living/simple_animal/hostile/poison/bees/Life()
	if(!stat)
		if(loc == beehome)
			if(idle >= BEE_IDLE_ROAMING && prob(BEE_PROB_GOROAM))
				loc = get_turf(beehome)
			idle = min(100, ++idle)
		else
			idle = max(0, --idle)

			if(idle <= BEE_IDLE_GOHOME && prob(BEE_PROB_GOHOME))
				if(!FindTarget())
					wanted_objects += /obj/structure/beebox //so we don't attack beeboxes when not going home
					target = beehome

	//Find a suitable home if we don't have one
	if(!beehome)
		for(var/obj/structure/beebox/BB in view(vision_range,src))
			listclearnulls(BB.bees)
			if(BB.queen_bee && (BB.get_bees_amt() < BB.get_max_bees()))
				BB.bees |= src
				beehome = BB

	. = ..()




//QUEEN BEES!
/mob/living/simple_animal/hostile/poison/bees/queen
	name = "queen bee"
	desc = "she's the queen of bees, BZZ BZZ"
	icon_state = "queen_bee"
	icon_living = "queen_bee"
	isqueen = TRUE

/mob/living/simple_animal/hostile/poison/bees/queen/generate_bee_visuals()
	if(beegent && beegent.color)
		icon_state = "queen_bee_grey"
		color = beegent.color
	else
		icon_state = "queen_bee"
		color = ""

//the Queen doesn't leave the box on her own, and she CERTAINLY doesn't pollinate by herself
/mob/living/simple_animal/hostile/poison/bees/queen/Found(var/atom/A)
	return 0

//leave pollination for the peasent bees
/mob/living/simple_animal/hostile/poison/bees/queen/AttackingTarget()
	if(beegent && istype(target, /mob/living))
		var/mob/living/L = target
		beegent.reaction_mob(L, TOUCH)
	target.attack_animal(src)

//PEASENT BEES
/mob/living/simple_animal/hostile/poison/bees/queen/pollinate()
	return