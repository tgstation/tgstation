
#define BEE_IDLE_ROAMING 70 //The value of idle at which a bee in a beebox will try to wander
#define BEE_IDLE_GOHOME 0  //The value of idle at which a bee will try to go home
#define BEE_PROB_GOHOME 35 //Probability to go home when idle is below BEE_IDLE_GOHOME
#define BEE_PROB_GOROAM 5 //Probability to go roaming when idle is above BEE_IDLE_ROAMING
#define BEE_TRAY_RECENT_VISIT 200 //How long in deciseconds until a tray can be visited by a bee again
#define BEE_DEFAULT_COLOUR "#e5e500" //the colour we make the stripes of the bee if our reagent has no colour (or we have no reagent)

#define BEE_POLLINATE_YIELD_CHANCE 33
#define BEE_POLLINATE_PEST_CHANCE 33
#define BEE_POLLINATE_POTENCY_CHANCE 50

/mob/living/simple_animal/hostile/bee
	name = "bee"
	desc = "Buzzy buzzy bee, stingy sti- Ouch!"
	icon_state = ""
	icon_living = ""
	icon = 'icons/mob/bees.dmi'
	gender = FEMALE
	speak_emote = list("buzzes")
	emote_hear = list("buzzes")
	turns_per_move = 0
	melee_damage_lower = 1
	melee_damage_upper = 1
	attack_verb_continuous = "stings"
	attack_verb_simple = "sting"
	response_help_continuous = "shoos"
	response_help_simple = "shoo"
	response_disarm_continuous = "swats away"
	response_disarm_simple = "swat away"
	response_harm_continuous = "squashes"
	response_harm_simple = "squash"
	maxHealth = 10
	health = 10
	faction = list("hostile")
	move_to_delay = 0
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	density = FALSE
	atom_size = MOB_SIZE_TINY
	mob_biotypes = MOB_ORGANIC|MOB_BUG
	gold_core_spawnable = FRIENDLY_SPAWN
	search_objects = 1 //have to find those plant trays!
	can_be_held = TRUE
	atom_size = ITEM_SIZE_TINY

	//Spaceborn beings don't get hurt by space
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	del_on_death = 1

	var/datum/reagent/beegent = null //hehe, beegent
	var/obj/structure/beebox/beehome = null
	var/idle = 0
	var/isqueen = FALSE
	var/icon_base = "bee"
	var/static/beehometypecache = typecacheof(/obj/structure/beebox)
	var/static/hydroponicstypecache = typecacheof(/obj/machinery/hydroponics)

/mob/living/simple_animal/hostile/bee/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)
	generate_bee_visuals()
	AddElement(/datum/element/simple_flying)
	AddComponent(/datum/component/clickbox, x_offset = -2, y_offset = -2)
	AddComponent(/datum/component/swarming)
	add_cell_sample()

/mob/living/simple_animal/hostile/bee/mob_pickup(mob/living/L)
	if(flags_1 & HOLOGRAM_1)
		return
	var/obj/item/clothing/head/mob_holder/destructible/holder = new(get_turf(src), src, held_state, head_icon, held_lh, held_rh, worn_slot_flags)
	var/list/reee = list(/datum/reagent/consumable/nutriment/vitamin = 5)
	if(beegent)
		reee[beegent.type] = 5
	holder.AddComponent(/datum/component/edible, reee, null, RAW | MEAT | GROSS, 10, 0, list("bee"), null, 10)
	L.visible_message(span_warning("[L] scoops up [src]!"))
	L.put_in_hands(holder)

/mob/living/simple_animal/hostile/bee/Destroy()
	if(beehome)
		beehome.bees -= src
		beehome = null
	beegent = null
	return ..()


/mob/living/simple_animal/hostile/bee/death(gibbed)
	if(beehome)
		beehome.bees -= src
		beehome = null
	if((flags_1 & HOLOGRAM_1))
		return ..()
	var/obj/item/trash/bee/bee_to_eat = new(loc)
	bee_to_eat.pixel_x = pixel_x
	bee_to_eat.pixel_y = pixel_y
	if(beegent)
		bee_to_eat.beegent = beegent
		bee_to_eat.reagents.add_reagent(beegent.type, 5)
	bee_to_eat.update_appearance()
	beegent = null
	return ..()


/mob/living/simple_animal/hostile/bee/examine(mob/user)
	. = ..()

	if(!beehome)
		. += span_warning("This bee is homeless!")

/mob/living/simple_animal/hostile/bee/ListTargets() // Bee processing is expessive, so we override them finding targets here.
	if(!search_objects) //In case we want to have purely hostile bees
		return ..()
	else
		. = list() // The following code is only very slightly slower than just returning oview(vision_range, targets_from), but it saves us much more work down the line
		var/atom/target_from = GET_TARGETS_FROM(src)
		var/list/searched_for = oview(vision_range, target_from)
		for(var/obj/A in searched_for)
			. += A
		for(var/mob/A in searched_for)
			. += A

/mob/living/simple_animal/hostile/bee/proc/generate_bee_visuals()
	cut_overlays()

	var/col = BEE_DEFAULT_COLOUR
	if(beegent?.color)
		col = beegent.color

	icon_state = "[icon_base]_base"
	add_overlay("[icon_base]_base")

	var/static/mutable_appearance/greyscale_overlay
	greyscale_overlay = greyscale_overlay || mutable_appearance('icons/mob/bees.dmi')
	greyscale_overlay.icon_state = "[icon_base]_grey"
	greyscale_overlay.color = col
	add_overlay(greyscale_overlay)

	add_overlay("[icon_base]_wings")


//We don't attack beekeepers/people dressed as bees//Todo: bee costume
/mob/living/simple_animal/hostile/bee/CanAttack(atom/the_target)
	. = ..()
	if(!.)
		return FALSE
	if(isliving(the_target))
		var/mob/living/H = the_target
		return !H.bee_friendly()


/mob/living/simple_animal/hostile/bee/Found(atom/A)
	if(isliving(A))
		var/mob/living/H = A
		return !H.bee_friendly()
	if(istype(A, /obj/machinery/hydroponics))
		var/obj/machinery/hydroponics/Hydro = A
		if(Hydro.myseed && Hydro.plant_status != HYDROTRAY_PLANT_DEAD && !Hydro.recent_bee_visit)
			wanted_objects |= hydroponicstypecache //so we only hunt them while they're alive/seeded/not visisted
			return TRUE
	return FALSE


/mob/living/simple_animal/hostile/bee/AttackingTarget()
	//Pollinate
	if(istype(target, /obj/machinery/hydroponics))
		var/obj/machinery/hydroponics/Hydro = target
		pollinate(Hydro)
	else if(istype(target, /obj/structure/beebox))
		if(target == beehome)
			var/obj/structure/beebox/BB = target
			forceMove(BB)
			toggle_ai(AI_IDLE)
			LoseTarget()
			wanted_objects -= beehometypecache //so we don't attack beeboxes when not going home
		return //no don't attack the goddamm box
	else
		. = ..()
		if(. && beegent && isliving(target))
			var/mob/living/L = target
			if(L.reagents)
				beegent.expose_mob(L, INJECT)
				L.reagents.add_reagent(beegent.type, rand(1,5))

/mob/living/simple_animal/hostile/bee/proc/assign_reagent(datum/reagent/R)
	if(istype(R))
		beegent = R
		name = "[initial(name)] ([R.name])"
		real_name = name
		//clear the old since this one is going to have some new value
		RemoveElement(/datum/element/venomous)
		AddElement(/datum/element/venomous, beegent.type, list(1, 5))
		generate_bee_visuals()

/mob/living/simple_animal/hostile/bee/proc/pollinate(obj/machinery/hydroponics/Hydro)
	if(!istype(Hydro) || !Hydro.myseed || Hydro.plant_status == HYDROTRAY_PLANT_DEAD || Hydro.recent_bee_visit)
		LoseTarget()
		return

	LoseTarget() //so we pick a new hydro tray next FindTarget(), instead of loving the same plant for eternity
	wanted_objects -= hydroponicstypecache //so we only hunt them while they're alive/seeded/not visisted
	Hydro.recent_bee_visit = TRUE
	addtimer(VARSET_CALLBACK(Hydro, recent_bee_visit, FALSE), BEE_TRAY_RECENT_VISIT)

	var/growth = health //Health also means how many bees are in the swarm, roughly.
	//better healthier plants!
	Hydro.adjust_plant_health(growth*0.5)
	if(prob(BEE_POLLINATE_PEST_CHANCE))
		Hydro.adjust_pestlevel(-10)
	if(prob(BEE_POLLINATE_YIELD_CHANCE))
		Hydro.myseed.adjust_yield(1)
		Hydro.yieldmod = 2
	if(prob(BEE_POLLINATE_POTENCY_CHANCE))
		Hydro.myseed.adjust_potency(1)

	if(beehome)
		beehome.bee_resources = min(beehome.bee_resources + growth, 100)


/mob/living/simple_animal/hostile/bee/handle_automated_action()
	. = ..()
	if(!.)
		return

	if(!isqueen)
		if(loc == beehome)
			idle = min(100, ++idle)
			if(idle >= BEE_IDLE_ROAMING && prob(BEE_PROB_GOROAM))
				toggle_ai(AI_ON)
				forceMove(beehome.drop_location())
		else
			idle = max(0, --idle)
			if(idle <= BEE_IDLE_GOHOME && prob(BEE_PROB_GOHOME))
				if(!FindTarget())
					wanted_objects |= beehometypecache //so we don't attack beeboxes when not going home
					GiveTarget(beehome)
	if(!beehome) //add outselves to a beebox (of the same reagent) if we have no home
		for(var/obj/structure/beebox/BB in view(vision_range, src))
			if(reagent_incompatible(BB.queen_bee) || BB.bees.len >= BB.get_max_bees())
				continue
			BB.bees |= src
			beehome = BB
			break // End loop after the first compatible find.

/mob/living/simple_animal/hostile/bee/will_escape_storage()
	return TRUE

/mob/living/simple_animal/hostile/bee/toxin/Initialize(mapload)
	. = ..()
	var/datum/reagent/R = pick(typesof(/datum/reagent/toxin))
	assign_reagent(GLOB.chemical_reagents_list[R])

/mob/living/simple_animal/hostile/bee/add_cell_sample()
	. = ..()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_QUEEN_BEE, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)

/mob/living/simple_animal/hostile/bee/queen
	name = "queen bee"
	desc = "She's the queen of bees, BZZ BZZ!"
	icon_base = "queen"
	isqueen = TRUE

//the Queen doesn't leave the box on her own, and she CERTAINLY doesn't pollinate by herself
/mob/living/simple_animal/hostile/bee/queen/Found(atom/A)
	return FALSE


//leave pollination for the peasent bees
/mob/living/simple_animal/hostile/bee/queen/AttackingTarget()
	. = ..()
	if(. && beegent && isliving(target))
		var/mob/living/L = target
		beegent.expose_mob(L, TOUCH)
		L.reagents.add_reagent(beegent.type, rand(1,5))


//PEASENT BEES
/mob/living/simple_animal/hostile/bee/queen/pollinate()
	return

/mob/living/simple_animal/hostile/bee/queen/will_escape_storage()
	return FALSE

/mob/living/simple_animal/hostile/bee/proc/reagent_incompatible(mob/living/simple_animal/hostile/bee/B)
	if(!B)
		return FALSE
	if(B.beegent && beegent && B.beegent.type != beegent.type || B.beegent && !beegent || !B.beegent && beegent)
		return TRUE
	return FALSE

/obj/item/queen_bee
	name = "queen bee"
	desc = "She's the queen of bees, BZZ BZZ!"
	icon_state = "queen_item"
	inhand_icon_state = ""
	icon = 'icons/mob/bees.dmi'
	var/mob/living/simple_animal/hostile/bee/queen/queen


/obj/item/queen_bee/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/reagent_containers/syringe))
		var/obj/item/reagent_containers/syringe/S = I
		if(S.reagents.has_reagent(/datum/reagent/royal_bee_jelly)) //checked twice, because I really don't want royal bee jelly to be duped
			if(S.reagents.has_reagent(/datum/reagent/royal_bee_jelly,5))
				S.reagents.remove_reagent(/datum/reagent/royal_bee_jelly, 5)
				var/obj/item/queen_bee/qb = new(user.drop_location())
				qb.queen = new(qb)
				if(queen?.beegent)
					qb.queen.assign_reagent(queen.beegent) //Bees use the global singleton instances of reagents, so we don't need to worry about one bee being deleted and her copies losing their reagents.
				user.put_in_active_hand(qb)
				user.visible_message(span_notice("[user] injects [src] with royal bee jelly, causing it to split into two bees, MORE BEES!"),span_warning("You inject [src] with royal bee jelly, causing it to split into two bees, MORE BEES!"))
			else
				to_chat(user, span_warning("You don't have enough royal bee jelly to split a bee in two!"))
		else
			var/datum/reagent/R = GLOB.chemical_reagents_list[S.reagents.get_master_reagent_id()]
			if(R && S.reagents.has_reagent(R.type, 5))
				S.reagents.remove_reagent(R.type,5)
				queen.assign_reagent(R)
				user.visible_message(span_warning("[user] injects [src]'s genome with [R.name], mutating its DNA!"),span_warning("You inject [src]'s genome with [R.name], mutating its DNA!"))
				name = queen.name
			else
				to_chat(user, span_warning("You don't have enough units of that chemical to modify the bee's DNA!"))
	..()

/obj/item/queen_bee/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] eats [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	user.say("IT'S HIP TO EAT BEES!")
	qdel(src)
	return TOXLOSS

/obj/item/queen_bee/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_QUEEN_BEE, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)

/obj/item/queen_bee/bought/Initialize(mapload)
	. = ..()
	queen = new(src)

/obj/item/queen_bee/Destroy()
	QDEL_NULL(queen)
	return ..()

/mob/living/simple_animal/hostile/bee/consider_wakeup()
	if (beehome && loc == beehome) // If bees are chilling in their nest, they're not actively looking for targets
		idle = min(100, ++idle)
		if(idle >= BEE_IDLE_ROAMING && prob(BEE_PROB_GOROAM))
			toggle_ai(AI_ON)
			forceMove(beehome.drop_location())
	else
		..()

/mob/living/simple_animal/hostile/bee/short
	desc = "These bees seem unstable and won't survive for long."

/mob/living/simple_animal/hostile/bee/short/Initialize(mapload, timetolive=50 SECONDS)
	. = ..()
	addtimer(CALLBACK(src, .proc/death), timetolive)

/obj/item/trash/bee
	name = "bee"
	desc = "No wonder the bees are dying out, you monster."
	icon = 'icons/mob/bees.dmi'
	icon_state = "bee_item"
	var/datum/reagent/beegent

/obj/item/trash/bee/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/edible, list(/datum/reagent/consumable/nutriment/vitamin = 5), null, RAW | MEAT | GROSS, 10, 0, list("bee"), null, 10)
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_QUEEN_BEE, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)

/obj/item/trash/bee/update_overlays()
	. = ..()
	var/mutable_appearance/body_overlay = mutable_appearance(icon = icon, icon_state = "bee_item_overlay")
	body_overlay.color = beegent ? beegent.color : BEE_DEFAULT_COLOUR
	. += body_overlay
