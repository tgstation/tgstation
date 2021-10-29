/mob/living/simple_animal/pet/dog/markus
	name = "\proper Markus"
	real_name = "Markus"
	gender = MALE
	desc = "It's the Cargo's overfed, yet still beloved dog."
	icon = 'modular_skyrat/master_files/icons/mob/pets.dmi'
	icon_state = "markus"
	icon_dead = "markus_dead"
	icon_living = "markus"
	speak = list("Borf!", "Boof!", "Bork!", "Bowwow!", "Burg?")
	butcher_results = list(/obj/item/food/burger/cheese = 1, /obj/item/food/meat/slab = 2, /obj/item/trash/syndi_cakes = 1)
	animal_species = /mob/living/simple_animal/pet/dog
	can_be_held = FALSE
	gold_core_spawnable = FRIENDLY_SPAWN

/mob/living/simple_animal/pet/dog/markus/treat_message(message)
	return client ? pick(speak) : message //markus only talks business

/datum/chemical_reaction/mark_reaction
	results = list(/datum/reagent/liquidgibs = 15)
	required_reagents = list(/datum/reagent/blood = 20,
	/datum/reagent/medicine/omnizine = 20,
	/datum/reagent/medicine/c2/synthflesh = 20,
	/datum/reagent/consumable/nutriment/protein = 10,
	/datum/reagent/consumable/nutriment = 10,
	/datum/reagent/consumable/ketchup = 5,
	/datum/reagent/consumable/mayonnaise = 5,
	/datum/reagent/colorful_reagent/powder/yellow/crayon = 5)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)
	required_temp = 480

/datum/chemical_reaction/mark_reaction/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	. = ..()
	var/location = get_turf(holder.my_atom)
	new /mob/living/simple_animal/pet/dog/markus(location)
	playsound(location, 'modular_skyrat/master_files/sound/effects/dorime.ogg', 100, 0, 7)

/mob/living/simple_animal/pet/dog/corgi/borgi
	name = "E-N"
	real_name = "E-N" //Intended to hold the name without altering it.
	gender = NEUTER
	desc = "It's a borgi."
	icon = 'modular_skyrat/master_files/icons/mob/pets.dmi'
	icon_state = "borgi"
	icon_living = "borgi"
	icon_dead = "borgi_dead"
	maxHealth = 60
	health = 60
	var/emagged = 0
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	loot = list(/obj/effect/decal/cleanable/oil/slippery)
	butcher_results = list(/obj/item/clothing/head/corgi/en = 1, /obj/item/clothing/suit/corgisuit/en = 1)
	deathmessage = "beeps, its mechanical parts hissing before the chassis collapses in a loud thud."
	animal_species = /mob/living/simple_animal/pet/dog/corgi/borgi
	nofur = TRUE

/mob/living/simple_animal/pet/dog/corgi/borgi/Initialize()
	. = ..()
	//Defense protocol
	RegisterSignal(src, COMSIG_ATOM_ATTACK_HAND, .proc/on_attack_hand)
	RegisterSignal(src, COMSIG_PARENT_ATTACKBY, .proc/on_attackby)
	RegisterSignal(src, COMSIG_ATOM_HITBY, .proc/on_hitby)

/mob/living/simple_animal/pet/dog/corgi/borgi/proc/on_attack_hand(datum/source, mob/living/target)
	if(target.combat_mode && health > 0)
		shootAt(target)
		var/datum/ai_controller/dog/EN = ai_controller
		if(health <= 30 && !(WEAKREF(target) in EN.blackboard[BB_DOG_FRIENDS]))
			EN.current_movement_target = target
			EN.blackboard[BB_DOG_HARASS_TARGET] = WEAKREF(target)
			EN.current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/harass)

/mob/living/simple_animal/pet/dog/corgi/borgi/proc/on_attackby(datum/source, obj/item/I, mob/living/target)
	if(I.force && I.damtype != STAMINA && health > 0)
		shootAt(target)
		var/datum/ai_controller/dog/EN = ai_controller
		if(health <= 30 && !(WEAKREF(target) in EN.blackboard[BB_DOG_FRIENDS]))
			EN.current_movement_target = target
			EN.blackboard[BB_DOG_HARASS_TARGET] = WEAKREF(target)
			EN.current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/harass)

/mob/living/simple_animal/pet/dog/corgi/borgi/proc/on_hitby(datum/source, atom/movable/AM)
	if(istype(AM, /obj/item))
		var/obj/item/I = AM
		var/mob/thrown_by = I.thrownby?.resolve()
		if(I.throwforce >= 5 && ishuman(thrown_by) && health > 0)
			var/mob/living/carbon/human/target = thrown_by
			var/datum/ai_controller/dog/EN = ai_controller
			if(!(WEAKREF(target) in EN.blackboard[BB_DOG_FRIENDS]))
				shootAt(target)
			if(health <= 30)
				EN.current_movement_target = target
				EN.blackboard[BB_DOG_HARASS_TARGET] = WEAKREF(target)
				EN.current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/harass)

/mob/living/simple_animal/pet/dog/corgi/borgi/bullet_act(obj/projectile/proj)
	if(istype(proj, /obj/projectile/beam) || istype(proj, /obj/projectile/bullet))
		var/mob/living/carbon/human/target = proj.firer
		if(!proj.nodamage && proj.damage >= 10)
			if((proj.damage_type == BRUTE || proj.damage_type == BURN))
				adjustBruteLoss(proj.damage)
				if(isliving(target) && health > 0)
					shootAt(target)
					var/datum/ai_controller/dog/EN = ai_controller
					EN.current_movement_target = target
					EN.blackboard[BB_DOG_HARASS_TARGET] = WEAKREF(target)
					EN.current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/harass)
		else
			shootToyAt(target)
	return BULLET_ACT_HIT

/mob/living/simple_animal/pet/dog/corgi/borgi/proc/shootAt(atom/movable/target)
	var/turf/T = get_turf(src)
	var/turf/U = get_turf(target)
	if(!T || !U)
		return
	var/obj/projectile/beam/laser = new /obj/projectile/beam(loc)
	laser.icon = 'icons/effects/genetics.dmi'
	laser.icon_state = "eyelasers"
	playsound(loc, 'sound/weapons/taser.ogg', 75, 1)
	laser.preparePixelProjectile(target, T)
	laser.firer = src
	laser.fired_from = src
	laser.fire()

/mob/living/simple_animal/pet/dog/corgi/borgi/proc/shootToyAt(atom/movable/target)
	var/turf/T = get_turf(src)
	var/turf/U = get_turf(target)
	if(!T || !U)
		return
	var/obj/projectile/bullet/reusable/foam_dart/FD = new /obj/projectile/bullet/reusable/foam_dart(loc)
	FD.icon = 'icons/obj/guns/toy.dmi'
	FD.icon_state = "foamdart_proj"
	playsound(loc, 'sound/items/syringeproj.ogg', 75, 1)
	FD.preparePixelProjectile(target, T)
	FD.firer = src
	FD.fired_from = src
	FD.fire()

/mob/living/simple_animal/pet/dog/corgi/borgi/Life(seconds, times_fired)
	..()
	//spark for no reason
	if(prob(5))
		do_sparks(3, 1, src)

/mob/living/simple_animal/pet/dog/corgi/borgi/handle_automated_action()
	if(emagged && prob(25))
		var/mob/living/carbon/target = locate() in view(10, src)
		if(target)
			shootAt(target)

/mob/living/simple_animal/pet/dog/corgi/borgi/death(gibbed)
	// Only execute the below if we successfully died
	. = ..(gibbed)
	if(!.)
		return FALSE
	do_sparks(3, 1, src)
	var/datum/ai_controller/dog/EN = ai_controller
	LAZYCLEARLIST(EN.current_behaviors)

/mob/living/simple_animal/pet/dog/corgi/borgi/emag_act(user as mob)
	if(!emagged)
		emagged = 1
		visible_message(span_warning("[user] swipes a card through [src].</span>"),span_notice("You overload [src]s internal reactor.</span>"))
		addtimer(CALLBACK(src, .proc/explode), 60 SECONDS)

/mob/living/simple_animal/pet/dog/corgi/borgi/proc/explode()
	visible_message(span_warning("[src] makes an odd whining noise.</span>"))
	explosion(get_turf(src), 0, 1, 6, 9, 2, TRUE)
	death()

/mob/living/simple_animal/pet/dog/dobermann
	name = "\proper Dobermann"
	gender = MALE
	desc = "A larger breed of dog."
	icon = 'modular_skyrat/master_files/icons/mob/newmobs.dmi'
	icon_state = "dobber"
	icon_dead = "dobbydead"
	icon_living = "dobber"

