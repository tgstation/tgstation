/obj/item/grenade/iedcasing
	name = "improvised explosive"
	desc = "An improvised explosive device."
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/weapons/grenade.dmi'
	base_icon_state = "pipebomb"
	icon_state = "slicedapart"
	inhand_icon_state = "flashbang"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	throw_speed = 3
	throw_range = 7
	obj_flags = CONDUCTS_ELECTRICITY
	slot_flags = ITEM_SLOT_BELT
	active = FALSE
	shrapnel_type = /obj/projectile/bullet/shrapnel/ied
	det_time = 225 SECONDS //this is handled by assemblies now
	display_timer = FALSE
	/// Explosive power
	var/power = 5
	/// Our assembly that when activated causes us to explode
	var/obj/item/assembly/activator
	/// List of effects, the key is a path to compare to and the value is incremented by one everytime theres one that is the same type in our contents
	var/list/effects = list(
		/obj/item/food/meat/slab = 0,
		/obj/item/paper = 0,
		/obj/item/shard = 0,
		/obj/item/stack/ore/bluespace_crystal/refined = 0,
	)
	/// Cooldown to prevent spam
	COOLDOWN_DECLARE(spam_cd)

/obj/item/grenade/iedcasing/Initialize(mapload)
	. = ..()
	if(ispath(activator))
		var/obj/item/assembly/new_activator = new activator(src)
		new_activator.toggle_secure()
		activator = null
		attach_activator(new_activator)

/obj/item/grenade/iedcasing/proc/setup_effects_from_contents()
	for(var/item in contents)
		for(var/effect_type in effects)
			if(!istype(item, effect_type))
				continue
			if(isstack(item))
				var/obj/item/stack/as_stack = item
				effects[effect_type] += as_stack.amount
			else
				effects[effect_type]++
			break

/obj/item/grenade/iedcasing/examine(mob/user)
	. = ..()
	. += span_notice("Using it in-hand activates the assembly, which means timers start timing and so on.")
	. += span_notice("Using it off-hand allows you to configure the assembly, if possible.")
	if(contents.len > 1) // above 1, so more than just the activator
		. += span_warning("It seems to have something stuffed in it.")
	if(isnull(activator))
		return
	. += activator.examine(user)

// assembly handling

/obj/item/grenade/iedcasing/IsAssemblyHolder()
	return TRUE

/obj/item/grenade/iedcasing/on_found(mob/finder)
	if(activator)
		activator.on_found(finder)

/obj/item/grenade/iedcasing/Move()
	. = ..()
	if(activator)
		activator.holder_movement()

/obj/item/grenade/iedcasing/dropped()
	. = ..()
	if(activator)
		activator.dropped()

/obj/item/grenade/iedcasing/proc/process_activation(obj/item/assembly)
	detonate()

/obj/item/grenade/iedcasing/proc/attach_activator(obj/item/assembly/new_one)
	if(activator)
		return
	activator = new_one
	activator.holder = src
	activator.on_attach()
	activator.toggle_secure()
	update_icon(UPDATE_ICON_STATE)

/obj/item/grenade/iedcasing/change_det_time()
	return

//assembly handling end

/obj/item/grenade/iedcasing/attack_hand(mob/user, list/modifiers)
	if(loc == user) //if we were picked up already, this opening whenever picked up is not ok
		activator.ui_interact(user) //if any
	. = ..()
	if(.)
		return
	if(isnull(activator))
		return
	activator.attack_hand()

/obj/item/grenade/iedcasing/update_icon_state()
	if(isnull(activator))
		icon_state = "slicedapart" //this shouldnt happen but should prevent runtimes
		return ..()
	var/suffix = ""
	var/obj/item/assembly/timer/as_timer = activator
	var/obj/item/assembly/mousetrap/as_mousetrap = activator
	var/obj/item/assembly/prox_sensor/as_prox = activator
	if((istype(as_timer) && as_timer.timing) || (istype(as_mousetrap) && as_mousetrap.armed)) //these shouldve just had a common "active" variable or something
		suffix = "-a"
	else if(istype(as_prox))
		suffix = as_prox.timing ? "-arming" : (as_prox.scanning ? "-a" : "")
	icon_state = "[base_icon_state]-[initial(activator.name)][suffix]" //signalers detonate instantly so theyre not here
	return ..()

/obj/item/grenade/iedcasing/attack_self(mob/user)
	if(isnull(activator) || !COOLDOWN_FINISHED(src, spam_cd))
		balloon_alert(user, isnull(activator) ? "you shouldnt be seeing this" : "on cooldown!")
		return
	if(istype(activator, /obj/item/assembly/signaler))
		return //no signallers, signallers send a signal and i can imagine this having bad sideeffects if some has multiple of the same frequency in their backpack and uses them inhand by accident
	activator.activate()
	update_icon(UPDATE_ICON_STATE)
	user.balloon_alert_to_viewers("arming!")
	COOLDOWN_START(src, spam_cd, 1 SECONDS)

/obj/item/grenade/iedcasing/detonate(mob/living/lanced_by) //Blowing that can up
	if(effects[/obj/item/shard]) //this has to be before so it initializes us a pellet cloud or something
		shrapnel_radius = effects[/obj/item/shard]
	. = ..()
	if(!.)
		return

	update_mob()
	for(var/i = 1 to effects[/obj/item/food/meat/slab])
		new /obj/effect/gibspawner/generic(loc)
	if(effects[/obj/item/paper])
		for(var/turf/open/floor in view(effects[/obj/item/paper], loc)) //this couldve been light impact range but fake pipebombs exploding into confetti is funny
			new /obj/effect/decal/cleanable/confetti(floor)
	var/heavy = floor(power * 0.2)
	var/light = round(power * 0.7, 1)
	var/flame = round(power + rand(-1, 1), 1)
	explosion(loc, devastation_range = -1, heavy_impact_range = heavy, light_impact_range = light, flame_range = flame, explosion_cause = src)

	if(effects[/obj/item/stack/ore/bluespace_crystal/refined])
		for(var/mob/living/victim in view(light, loc))
			do_teleport(victim, get_turf(victim), min(12, effects[/obj/item/stack/ore/bluespace_crystal/refined] * 3), asoundin = 'sound/effects/phasein.ogg', channel = TELEPORT_CHANNEL_BLUESPACE)

	qdel(src)

/obj/item/grenade/iedcasing/Destroy()
	. = ..()
	activator = null




/obj/item/grenade/iedcasing/spawned
	power = 2.5 //20u welding fuel
	activator = /obj/item/assembly/timer

#define MAX_STUFFINGS 3

/obj/item/sliced_pipe
	name = "halved pipe"
	desc = "Two half-size pipes made from one."
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/weapons/grenade.dmi'
	icon_state = "slicedapart"
	/// Are wires inserted? If so, we are on the final step
	var/wires_are_in = FALSE
	/// Typecache of items we are allowed to stuff into the pipebomb for effects, only add items with effects
	var/static/list/allowed = typecacheof(list(
		/obj/item/food/meat/slab,
		/obj/item/paper,
		/obj/item/shard,
		/obj/item/stack/ore/bluespace_crystal/refined,
	))
	//this probably shouldve been a blacklist instead but god do i not wanna update this anytime a new assembly is added
	/// A static list of types of assemblies that are allowed to be used to finish the bomb
	var/static/list/allowed_activators = list(
		/obj/item/assembly/signaler,
		/obj/item/assembly/prox_sensor,
		/obj/item/assembly/mousetrap,
		/obj/item/assembly/mousetrap/armed,
		/obj/item/assembly/timer,
		/obj/item/assembly/wiremod,
		/obj/item/assembly/voice,
	)
	/// Static list of reagent to explosive power
	var/static/list/fuel_power = list(
		/datum/reagent/fuel = 0.5,
		/datum/reagent/gunpowder = 1,
		/datum/reagent/nitroglycerin = 2,
		/datum/reagent/tatp = 2.5,
	)
	/// Explosion power to be transferred to the new pipebomb
	var/power = 5

/obj/item/sliced_pipe/Initialize(mapload)
	. = ..()
	create_reagents(20, OPENCONTAINER)

/obj/item/sliced_pipe/examine(mob/user)
	. = ..()
	if(!wires_are_in)
		. += span_notice("You could stuff something in, or fill it with fuel or some other volatile chemical..")
		. += span_notice("Afterwards, add some cable.")
	else
		. += span_notice("The wires are just dangling from it, you need some sort of <i> activating assembly</i>.")

/obj/item/sliced_pipe/attackby(obj/item/item, mob/user, list/modifiers, list/attack_modifiers)
	if(!wires_are_in)
		// here we can stuff in additional objects for a cooler effect
		if(is_type_in_typecache(item, allowed) && contents.len < MAX_STUFFINGS)
			balloon_alert(user, "stuffed in")
			var/atom/movable/to_put = item
			if(isstack(item))
				var/obj/item/stack/as_stack = item
				var/obj/item/stack/new_stack = as_stack.split_stack(1)
				new_stack.merge_type = null //prevent them from merging inside for contents.len
				to_put = new_stack
			to_put.forceMove(src)
			return

		//if the item has reagents lets allow it to transfer
		if(item.reagents)
			return ..()
		if(reagents.total_volume < 5)
			balloon_alert(user, "add more fuel!")
			return

		var/obj/item/stack/cable_coil/coil = item
		if(!istype(coil))
			return
		if (coil.get_amount() < 15)
			balloon_alert(user, "need 15 length!")
			return
		coil.use(15)

		var/cur_power = 0
		for(var/datum/reagent/reagent as anything in reagents.reagent_list)
			if(!(reagent.type in fuel_power))
				continue
			cur_power += fuel_power[reagent.type] * reagent.volume / reagents.maximum_volume

		power *= cur_power
		power -= contents.len / 2

		balloon_alert(user, "wires attached")
		icon_state = "[icon_state]-cable"
		reagents.flags = SEALED_CONTAINER
		wires_are_in = TRUE
	else // wires are in, lets finish this up
		var/obj/item/assembly/assembly = item
		if(!istype(assembly) || !(assembly.type in allowed_activators))
			return
		if(assembly.secured)
			balloon_alert(user, "unsecure assembly first!")
			return
		if(!user.transferItemToLoc(assembly, src))
			return
		user.balloon_alert(user, "attached")

		var/obj/item/grenade/iedcasing/pipebomb = new(drop_location())
		for(var/atom/movable/item_inside as anything in contents)
			item_inside.forceMove(pipebomb)

		pipebomb.power = power
		pipebomb.attach_activator(assembly)
		pipebomb.setup_effects_from_contents()
		var/was_in_hands = (loc == user)
		qdel(src)
		if(was_in_hands)
			user.put_in_hands(pipebomb)

#undef MAX_STUFFINGS
