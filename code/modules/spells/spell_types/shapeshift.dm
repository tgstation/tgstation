/obj/effect/proc_holder/spell/targeted/shapeshift
	name = "Shapechange"
	desc = "Take on the shape of another for a time to use their natural abilities. Once you've made your choice it cannot be changed."
	school = SCHOOL_TRANSMUTATION
	clothes_req = FALSE
	human_req = FALSE
	charge_max = 200
	cooldown_min = 50
	range = -1
	include_user = TRUE
	invocation = "RAC'WA NO!"
	invocation_type = INVOCATION_SHOUT
	action_icon_state = "shapeshift"
	nonabstract_req = TRUE

	var/revert_on_death = TRUE
	var/die_with_shapeshifted_form = TRUE
	///If you want to convert the caster's health and blood to the shift, and vice versa.
	var/convert_damage = TRUE
	///The damage type to convert to, as simplemobs don't have advanced damagetypes.
	var/convert_damage_type = BRUTE

	var/mob/living/shapeshift_type
	var/list/possible_shapes = list(
		/mob/living/simple_animal/mouse,
		/mob/living/simple_animal/pet/dog/corgi,
		/mob/living/simple_animal/hostile/carp/ranged/chaos,
		/mob/living/simple_animal/bot/secbot/ed209,
		/mob/living/simple_animal/hostile/giant_spider/viper/wizard,
		/mob/living/simple_animal/hostile/construct/juggernaut/mystic,
	)

/obj/effect/proc_holder/spell/targeted/shapeshift/cast(list/targets, mob/user = usr)
	if(src in user.mob_spell_list)
		LAZYREMOVE(user.mob_spell_list, src)
		user.mind.AddSpell(src)
	if(user.buckled)
		user.buckled.unbuckle_mob(src,force=TRUE)
	for(var/mob/living/shapeshifted_targets in targets)
		if(!shapeshift_type)
			var/list/animal_list = list()
			var/list/display_animals = list()
			for(var/path in possible_shapes)
				var/mob/living/simple_animal/animal = path
				animal_list[initial(animal.name)] = path
				var/image/animal_image = image(icon = initial(animal.icon), icon_state = initial(animal.icon_state))
				display_animals += list(initial(animal.name) = animal_image)
			sort_list(display_animals)
			var/new_shapeshift_type = show_radial_menu(shapeshifted_targets, shapeshifted_targets, display_animals, custom_check = CALLBACK(src, .proc/check_menu, user), radius = 38, require_near = TRUE)
			if(shapeshift_type)
				return
			shapeshift_type = new_shapeshift_type
			if(!shapeshift_type) //If you aren't gonna decide I am!
				shapeshift_type = pick(animal_list)
			shapeshift_type = animal_list[shapeshift_type]

		var/obj/shapeshift_holder/shapeshift_ability = locate() in shapeshifted_targets
		var/currently_ventcrawling = FALSE
		if(shapeshift_ability)
			if(shapeshifted_targets.movement_type & VENTCRAWLING)
				currently_ventcrawling = TRUE
			shapeshifted_targets = restore_form(shapeshifted_targets)
		else
			shapeshifted_targets = Shapeshift(shapeshifted_targets)

		// Can our new form support ventcrawling?
		var/ventcrawler = HAS_TRAIT(shapeshifted_targets, TRAIT_VENTCRAWLER_ALWAYS) || HAS_TRAIT(shapeshifted_targets, TRAIT_VENTCRAWLER_NUDE)
		if(ventcrawler)
			continue

		// Are we currently ventcrawling?
		if(!currently_ventcrawling)
			continue

		// You're shapeshifting into something that can't fit into a vent
		var/obj/machinery/atmospherics/pipeyoudiein = shapeshifted_targets.loc
		var/datum/pipeline/ourpipeline
		var/pipenets = pipeyoudiein.return_pipenets()
		if(islist(pipenets))
			ourpipeline = pipenets[1]
		else
			ourpipeline = pipenets

		to_chat(shapeshifted_targets, span_userdanger("Casting [src] inside of [pipeyoudiein] quickly turns you into a bloody mush!"))
		var/gibtype = /obj/effect/gibspawner/generic
		if(isalien(shapeshifted_targets))
			gibtype = /obj/effect/gibspawner/xeno
		for(var/obj/machinery/atmospherics/components/unary/possiblevent in range(10, get_turf(shapeshifted_targets)))
			if(possiblevent.parents.len && possiblevent.parents[1] == ourpipeline)
				new gibtype(get_turf(possiblevent))
				playsound(possiblevent, 'sound/effects/reee.ogg', 75, TRUE)
		priority_announce("We detected a pipe blockage around [get_area(get_turf(shapeshifted_targets))], please dispatch someone to investigate.", "Central Command")
		shapeshifted_targets.death()
		qdel(shapeshifted_targets)

/**
 * check_menu: Checks if we are allowed to interact with a radial menu
 *
 * Arguments:
 * * user The mob interacting with a menu
 */
/obj/effect/proc_holder/spell/targeted/shapeshift/proc/check_menu(mob/user)
	if(!istype(user))
		return FALSE
	if(user.incapacitated())
		return FALSE
	return TRUE

/obj/effect/proc_holder/spell/targeted/shapeshift/proc/Shapeshift(mob/living/caster)
	var/obj/shapeshift_holder/shapeshift_ability = locate() in caster
	if(shapeshift_ability)
		to_chat(caster, span_warning("You're already shapeshifted!"))
		return

	var/mob/living/shape = new shapeshift_type(caster.loc)
	shapeshift_ability = new(shape, src, caster)

	clothes_req = FALSE
	human_req = FALSE
	return shape

/obj/effect/proc_holder/spell/targeted/shapeshift/proc/restore_form(mob/living/caster)
	var/obj/shapeshift_holder/shapeshift_ability = locate() in caster
	if(!shapeshift_ability)
		return

	var/mob/living/restored_player = shapeshift_ability.stored

	shapeshift_ability.restore()

	clothes_req = initial(clothes_req)
	human_req = initial(human_req)
	return restored_player

/obj/effect/proc_holder/spell/targeted/shapeshift/dragon
	name = "Dragon Form"
	desc = "Take on the shape a lesser ash drake."
	invocation = "RAAAAAAAAWR!"


	shapeshift_type = /mob/living/simple_animal/hostile/megafauna/dragon/lesser


/obj/shapeshift_holder
	name = "Shapeshift holder"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ON_FIRE | UNACIDABLE | ACID_PROOF
	var/mob/living/stored
	var/mob/living/shape
	var/restoring = FALSE
	var/obj/effect/proc_holder/spell/targeted/shapeshift/source

/obj/shapeshift_holder/Initialize(mapload, obj/effect/proc_holder/spell/targeted/shapeshift/_source, mob/living/caster)
	. = ..()
	source = _source
	shape = loc
	if(!istype(shape))
		stack_trace("shapeshift holder created outside mob/living")
		return INITIALIZE_HINT_QDEL
	stored = caster
	if(stored.mind)
		stored.mind.transfer_to(shape)
	stored.forceMove(src)
	stored.notransform = TRUE
	if(source.convert_damage)
		var/damage_percent = (stored.maxHealth - stored.health)/stored.maxHealth;
		var/damapply = damage_percent * shape.maxHealth;

		shape.apply_damage(damapply, source.convert_damage_type, forced = TRUE, wound_bonus=CANT_WOUND);
		shape.blood_volume = stored.blood_volume;

	RegisterSignal(shape, list(COMSIG_PARENT_QDELETING, COMSIG_LIVING_DEATH), .proc/shape_death)
	RegisterSignal(stored, list(COMSIG_PARENT_QDELETING, COMSIG_LIVING_DEATH), .proc/caster_death)

/obj/shapeshift_holder/Destroy()
	// restore_form manages signal unregistering. If restoring is TRUE, we've already unregistered the signals and we're here
	// because restore() qdel'd src.
	if(!restoring)
		restore()
	stored = null
	shape = null
	return ..()

/obj/shapeshift_holder/Moved()
	. = ..()
	if(!restoring && !QDELETED(src))
		restore()

/obj/shapeshift_holder/handle_atom_del(atom/A)
	if(A == stored && !restoring)
		restore()

/obj/shapeshift_holder/Exited(atom/movable/gone, direction)
	if(stored == gone && !restoring)
		restore()

/obj/shapeshift_holder/proc/caster_death()
	SIGNAL_HANDLER
	//Something kills the stored caster through direct damage.
	if(source.revert_on_death)
		restore(death=TRUE)
	else
		shape.death()

/obj/shapeshift_holder/proc/shape_death()
	SIGNAL_HANDLER
	//Shape dies.
	if(source.die_with_shapeshifted_form)
		if(source.revert_on_death)
			restore(death=TRUE)
	else
		restore()

/obj/shapeshift_holder/proc/restore(death=FALSE)
	// Destroy() calls this proc if it hasn't been called. Unregistering here prevents multiple qdel loops
	// when caster and shape both die at the same time.
	UnregisterSignal(shape, list(COMSIG_PARENT_QDELETING, COMSIG_LIVING_DEATH))
	UnregisterSignal(stored, list(COMSIG_PARENT_QDELETING, COMSIG_LIVING_DEATH))
	restoring = TRUE
	stored.forceMove(shape.loc)
	stored.notransform = FALSE
	if(shape.mind)
		shape.mind.transfer_to(stored)
	if(death)
		stored.death()
	else if(source.convert_damage)
		stored.revive(full_heal = TRUE, admin_revive = FALSE)

		var/damage_percent = (shape.maxHealth - shape.health)/shape.maxHealth;
		var/damapply = stored.maxHealth * damage_percent

		stored.apply_damage(damapply, source.convert_damage_type, forced = TRUE, wound_bonus=CANT_WOUND)
	if(source.convert_damage)
		stored.blood_volume = shape.blood_volume;

	// This guard is important because restore() can also be called on COMSIG_PARENT_QDELETING for shape, as well as on death.
	// This can happen in, for example, [/proc/wabbajack] where the mob hit is qdel'd.
	if(!QDELETED(shape))
		QDEL_NULL(shape)

	qdel(src)
	return stored
