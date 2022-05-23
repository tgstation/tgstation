
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
	base_icon_state = "bee"
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
	mob_size = MOB_SIZE_TINY
	mob_biotypes = MOB_ORGANIC|MOB_BUG
	gold_core_spawnable = FRIENDLY_SPAWN
	search_objects = 1 //have to find those plant trays!
	can_be_held = TRUE
	held_w_class = WEIGHT_CLASS_TINY

	//Spaceborn beings don't get hurt by space
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	del_on_death = 1

	/// The reagent acting as the venom for this bee.
	var/datum/reagent/beegent = null //hehe, beegent
	/// The amount of beegent this bee contains.
	var/beegent_amount = 5
	/// The apiary this bee calls home.
	var/obj/structure/beebox/beehome = null
	/// How many ticks this bee has been idling in the apiary.
	var/idle = 0
	/// Whether this bee is a queen bee.
	var/isqueen = FALSE
	/// A static typecache of apiary types this bee is compatible with.
	var/static/beehometypecache = typecacheof(/obj/structure/beebox)
	/// A static typecache of hydroponics trays this bee can pollinate.
	var/static/hydroponicstypecache = typecacheof(/obj/machinery/hydroponics)

/mob/living/simple_animal/hostile/bee/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)

	create_reagents(max(beegent_amount, 5), REAGENT_HOLDER_ALIVE | INJECTABLE | DRAWABLE)
	if (beegent && beegent_amount > 0)
		assign_reagent(beegent, beegent_amount)

	update_appearance()

	AddElement(/datum/element/simple_flying)
	AddComponent(/datum/component/clickbox, x_offset = -2, y_offset = -2)
	AddComponent(/datum/component/swarming)
	add_cell_sample()

/mob/living/simple_animal/hostile/bee/mob_pickup(mob/living/L)
	if(flags_1 & HOLOGRAM_1)
		return
	var/obj/item/clothing/head/mob_holder/destructible/holder = new(get_turf(src), src, held_state, head_icon, held_lh, held_rh, worn_slot_flags)

	var/list/reee = list(/datum/reagent/consumable/nutriment/vitamin = 5)
	var/list/breeagents = reagents.reagent_list
	for(var/datum/reagent/beeagent as anything in breeagents)
		reee[beeagent.type] += beeagent.volume
	holder.AddComponent(/datum/component/edible, reee, null, RAW | MEAT | GROSS, 10, 0, list("bee"), null, 10)

	L.visible_message(span_warning("[L] scoops up [src]!"))
	L.put_in_hands(holder)

/mob/living/simple_animal/hostile/bee/Destroy()
	if(beehome)
		beehome.bees -= src
		beehome = null
	beegent = null
	return ..()

/mob/living/simple_animal/hostile/bee/update_name(updates)
	name = initial(name)
	if (beegent)
		var/datum/reagent/actual_beegent = reagents.get_reagent(beegent)
		if (actual_beegent)
			name = "[actual_beegent.name] [name]"
	real_name = name
	return ..()

/mob/living/simple_animal/hostile/bee/update_overlays()
	. = ..()

	icon_state = "[base_icon_state]_base"
	. += "[base_icon_state]_base"

	var/col = BEE_DEFAULT_COLOUR
	if (beegent)
		var/datum/reagent/actual_beegent = reagents.get_reagent(beegent)
		if (actual_beegent)
			col = actual_beegent.color

	var/static/mutable_appearance/beeagent_overlay
	beeagent_overlay = beeagent_overlay || mutable_appearance('icons/mob/bees.dmi')
	beeagent_overlay.icon_state = "[base_icon_state]_grey"
	beeagent_overlay.color = col
	. += beeagent_overlay
	. += "[base_icon_state]_wings"


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

	var/list/reee = list()
	var/list/breeagents = reagents.reagent_list
	for(var/datum/reagent/beeagent as anything in breeagents)
		reee[beeagent.type] += beeagent.volume

	if (reee.len)
		bee_to_eat.reagents.add_reagent_list(reee)

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
		for(var/obj/found_obj in searched_for)
			. += found_obj
		for(var/mob/found_mob in searched_for)
			. += found_mob


//We don't attack beekeepers/people dressed as bees//Todo: bee costume// 6 years and counting
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
		return

	if(istype(target, /obj/structure/beebox))
		if(target == beehome)
			var/obj/structure/beebox/BB = target
			forceMove(BB)
			toggle_ai(AI_IDLE)
			LoseTarget()
			wanted_objects -= beehometypecache //so we don't attack beeboxes when not going home
		return //no don't attack the goddamm box

	. = ..()
	if(. && reagents.total_volume && isliving(target))
		on_sting(target)

/**
 * Handles exposing the target mob to the bees venom and injecting the target with the venom.
 *
 * Arguments:
 * - [target][/mob/living]: The mob that has been stung.
 */
/mob/living/simple_animal/hostile/bee/proc/on_sting(mob/living/target)
	if(!reagents.total_volume)
		return

	var/sting_amt = rand(1, 5)
	if (target.reagents)
		var/old_amt = beegent ? reagents.get_reagent_amount(beegent) : null
		reagents.trans_to(target, sting_amt, methods = INJECT, ignore_stomach = TRUE)
		if (old_amt > 0) // Refill beegent.
			reagents.add_reagent(beegent, old_amt - reagents.get_reagent_amount(beegent))
	else
		reagents.expose(target, methods = INJECT, volume_modifier = min(sting_amt / reagents.total_volume, 1))

/**
 *
 */
/mob/living/simple_animal/hostile/bee/proc/assign_reagent(datum/reagent/new_venom, new_venom_amt = beegent_amount)
	if (new_venom == beegent && new_venom_amt == beegent_amount)
		return
	if(!(isnull(new_venom) || ispath(new_venom, /datum/reagent)))
		return
	if (new_venom_amt < 0)
		new_venom_amt = 0

	if (beegent && beegent_amount > 0)
		reagents.remove_reagent(beegent, beegent_amount)

	beegent = new_venom
	beegent_amount = new_venom_amt
	if (new_venom && new_venom_amt > 0)
		reagents.maximum_volume = max(reagents.maximum_volume, reagents.total_volume + new_venom_amt)
		reagents.add_reagent(new_venom, new_venom_amt, ignore_splitting = TRUE)

	//clear the old since this one is going to have some new value
	RemoveElement(/datum/element/venomous)
	AddElement(/datum/element/venomous, new_venom, list(1, new_venom_amt), methods = INJECT)
	update_appearance()

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
	base_icon_state = "queen"
	isqueen = TRUE

//the Queen doesn't leave the box on her own, and she CERTAINLY doesn't pollinate by herself
/mob/living/simple_animal/hostile/bee/queen/Found(atom/A)
	return FALSE


//leave pollination for the peasent bees
/mob/living/simple_animal/hostile/bee/queen/AttackingTarget()
	. = ..()
	if(. && beegent && isliving(target))
		on_sting(target)


//PEASENT BEES
/mob/living/simple_animal/hostile/bee/queen/pollinate()
	return

/mob/living/simple_animal/hostile/bee/queen/will_escape_storage()
	return FALSE

/mob/living/simple_animal/hostile/bee/proc/reagent_incompatible(mob/living/simple_animal/hostile/bee/B)
	if(!B)
		return FALSE
	if (B.beegent && B.beegent != beegent)
		return FALSE
	return TRUE

/mob/living/simple_animal/hostile/bee/consider_wakeup()
	// If bees are chilling in their nest, they're not actively looking for targets.
	if (!beehome || loc == beehome)
		return ..()

	idle = min(100, idle + 1)
	if(idle >= BEE_IDLE_ROAMING && prob(BEE_PROB_GOROAM))
		toggle_ai(AI_ON)
		forceMove(beehome.drop_location())

/**
 * The item representing a held queen bee.
 * Contains the actual queen bee.
 */
/obj/item/queen_bee
	name = "queen bee"
	desc = "She's the queen of bees, BZZ BZZ!"
	icon_state = "queen_item"
	inhand_icon_state = ""
	icon = 'icons/mob/bees.dmi'
	/// The queen be we are pretending to bee.
	var/mob/living/simple_animal/hostile/bee/queen/queen

/obj/item/queen_bee/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_QUEEN_BEE, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)

/obj/item/queen_bee/Destroy()
	QDEL_NULL(queen)
	return ..()

/obj/item/queen_bee/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == queen)
		queen = null
		// the bee should not exist without a bee.
		if(!QDELETED(src))
			qdel(src)

/obj/item/queen_bee/attackby(obj/item/tool, mob/user, params)
	if(!istype(tool, /obj/item/reagent_containers/syringe))
		return ..()

	var/obj/item/reagent_containers/syringe/syringe = tool
	if (syringe.reagents.has_reagent(/datum/reagent/royal_bee_jelly)) //checked twice, because I really don't want royal bee jelly to be duped
		if(!syringe.reagents.has_reagent(/datum/reagent/royal_bee_jelly, 5))
			to_chat(user, span_warning("You don't have enough royal bee jelly to split a bee in two!"))
			return ..()


		syringe.reagents.remove_reagent(/datum/reagent/royal_bee_jelly, 5)

		var/obj/item/queen_bee/qb = new(user.drop_location())
		qb.queen = new(qb)
		if (queen?.beegent)
			qb.queen.assign_reagent(queen.beegent)
		user.put_in_active_hand(qb)
		user.visible_message(
			span_notice("[user] injects [src] with royal bee jelly, causing it to split into two bees, MORE BEES!"),
			span_warning("You inject [src] with royal bee jelly, causing it to split into two bees, MORE BEES!")
		)
		return ..()

	var/datum/reagent/mut_reagent = syringe.reagents.get_master_reagent_id()
	if(!syringe.reagents.has_reagent(mut_reagent, 5))
		to_chat(user, span_warning("You don't have enough units of that chemical to modify the bee's DNA!"))
		return ..()

	var/datum/reagent/mut_reagent_name = syringe.reagents.get_reagent(mut_reagent)
	mut_reagent_name = mut_reagent_name.name
	syringe.reagents.remove_reagent(mut_reagent, 5)
	queen.assign_reagent(mut_reagent)
	user.visible_message(
		span_warning("[user] injects [src]'s genome with [mut_reagent_name], mutating its DNA!"),
		span_warning("You inject [src]'s genome with [mut_reagent_name], mutating its DNA!")
	)
	name = queen.name
	return..()

/obj/item/queen_bee/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] eats [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	user.say("IT'S HIP TO EAT BEES!")
	qdel(src)
	return TOXLOSS

/obj/item/queen_bee/bought

/obj/item/queen_bee/bought/Initialize(mapload)
	. = ..()
	queen = new(src)

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
	/// The typepath of the venom of the bee this was created from.
	var/datum/reagent/beegent

/obj/item/trash/bee/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/edible, list(/datum/reagent/consumable/nutriment/vitamin = 5), null, RAW | MEAT | GROSS, 10, 0, list("bee"), null, 10)
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_QUEEN_BEE, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)

/obj/item/trash/bee/update_overlays()
	. = ..()
	var/mutable_appearance/body_overlay = mutable_appearance(icon = icon, icon_state = "bee_item_overlay")
	var/col = BEE_DEFAULT_COLOUR
	if (beegent)
		var/datum/reagent/actual_beegent = reagents.has_reagent(beegent)
		if (actual_beegent)
			col = actual_beegent.color
	body_overlay.color = col
	. += body_overlay
