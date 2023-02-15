/obj/item/reagent_containers/spray
	name = "spray bottle"
	desc = "A spray bottle, with an unscrewable top."
	icon = 'icons/obj/janitor.dmi'
	icon_state = "sprayer_large"
	inhand_icon_state = "cleaner"
	worn_icon_state = "spraybottle"
	lefthand_file = 'icons/mob/inhands/equipment/custodial_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/custodial_righthand.dmi'
	item_flags = NOBLUDGEON
	reagent_flags = OPENCONTAINER
	slot_flags = ITEM_SLOT_BELT
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 7
	var/stream_mode = FALSE //whether we use the more focused mode
	var/current_range = 3 //the range of tiles the sprayer will reach.
	var/spray_range = 3 //the range of tiles the sprayer will reach when in spray mode.
	var/stream_range = 1 //the range of tiles the sprayer will reach when in stream mode.
	var/can_fill_from_container = TRUE
	/// Are we able to toggle between stream and spray modes, which change the distance and amount sprayed?
	var/can_toggle_range = TRUE
	amount_per_transfer_from_this = 5
	volume = 250
	possible_transfer_amounts = list(5,10)

/obj/item/reagent_containers/spray/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(istype(target, /obj/structure/sink) || istype(target, /obj/structure/mop_bucket/janitorialcart) || istype(target, /obj/machinery/hydroponics))
		return

	. |= AFTERATTACK_PROCESSED_ITEM

	if((target.is_drainable() && !target.is_refillable()) && (get_dist(src, target) <= 1) && can_fill_from_container)
		if(!target.reagents.total_volume)
			to_chat(user, span_warning("[target] is empty."))
			return

		if(reagents.holder_full())
			to_chat(user, span_warning("[src] is full."))
			return

		var/trans = target.reagents.trans_to(src, 50, transfered_by = user) //transfer 50u , using the spray's transfer amount would take too long to refill
		to_chat(user, span_notice("You fill \the [src] with [trans] units of the contents of \the [target]."))
		return

	if(reagents.total_volume < amount_per_transfer_from_this)
		to_chat(user, span_warning("Not enough left!"))
		return

	spray(target, user)

	playsound(src.loc, 'sound/effects/spray2.ogg', 50, TRUE, -6)
	user.changeNext_move(CLICK_CD_RANGE*2)
	user.newtonian_move(get_dir(target, user))
	return

/// Handles creating a chem puff that travels towards the target atom, exposing reagents to everything it hits on the way.
/obj/item/reagent_containers/spray/proc/spray(atom/target, mob/user)
	var/range = max(min(current_range, get_dist(src, target)), 1)

	var/obj/effect/decal/chempuff/reagent_puff = new /obj/effect/decal/chempuff(get_turf(src))

	reagent_puff.create_reagents(amount_per_transfer_from_this)
	var/puff_reagent_left = range //how many turf, mob or dense objet we can react with before we consider the chem puff consumed
	if(stream_mode)
		reagents.trans_to(reagent_puff, amount_per_transfer_from_this)
		puff_reagent_left = 1
	else
		reagents.trans_to(reagent_puff, amount_per_transfer_from_this, 1/range)
	reagent_puff.color = mix_color_from_reagents(reagent_puff.reagents.reagent_list)
	var/wait_step = max(round(2+3/range), 2)

	var/puff_reagent_string = reagent_puff.reagents.get_reagent_log_string()
	var/turf/src_turf = get_turf(src)

	log_combat(user, src_turf, "fired a puff of reagents from", src, addition="with a range of \[[range]\], containing [puff_reagent_string].")
	user.log_message("fired a puff of reagents from \a [src] with a range of \[[range]\] and containing [puff_reagent_string].", LOG_ATTACK)

	// do_spray includes a series of step_towards and sleeps. As a result, it will handle deletion of the chempuff.
	do_spray(target, wait_step, reagent_puff, range, puff_reagent_left, user)

/// Handles exposing atoms to the reagents contained in a spray's chempuff. Deletes the chempuff when it's completed.
/obj/item/reagent_containers/spray/proc/do_spray(atom/target, wait_step, obj/effect/decal/chempuff/reagent_puff, range, puff_reagent_left, mob/user)
	var/datum/move_loop/our_loop = SSmove_manager.move_towards_legacy(reagent_puff, target, wait_step, timeout = range * wait_step, flags = MOVEMENT_LOOP_START_FAST, priority = MOVEMENT_ABOVE_SPACE_PRIORITY)
	reagent_puff.user = user
	reagent_puff.sprayer = src
	reagent_puff.lifetime = puff_reagent_left
	reagent_puff.stream = stream_mode
	reagent_puff.RegisterSignal(our_loop, COMSIG_PARENT_QDELETING, TYPE_PROC_REF(/obj/effect/decal/chempuff, loop_ended))
	reagent_puff.RegisterSignal(our_loop, COMSIG_MOVELOOP_POSTPROCESS, TYPE_PROC_REF(/obj/effect/decal/chempuff, check_move))

/obj/item/reagent_containers/spray/attack_self(mob/user)
	. = ..()
	toggle_stream_mode(user)

/obj/item/reagent_containers/spray/attack_self_secondary(mob/user)
	. = ..()
	toggle_stream_mode(user)

/obj/item/reagent_containers/spray/proc/toggle_stream_mode(mob/user)
	if(stream_range == spray_range || !stream_range || !spray_range || possible_transfer_amounts.len > 2 || !can_toggle_range)
		return
	stream_mode = !stream_mode
	if(stream_mode)
		current_range = stream_range
	else
		current_range = spray_range
	to_chat(user, span_notice("You switch the nozzle setting to [stream_mode ? "\"stream\"":"\"spray\""]."))

/obj/item/reagent_containers/spray/attackby(obj/item/I, mob/user, params)
	var/hotness = I.get_temperature()
	if(hotness && reagents)
		reagents.expose_temperature(hotness)
		to_chat(user, span_notice("You heat [name] with [I]!"))

	//Cooling method
	if(istype(I, /obj/item/extinguisher))
		var/obj/item/extinguisher/extinguisher = I
		if(extinguisher.safety)
			return
		if (extinguisher.reagents.total_volume < 1)
			to_chat(user, span_warning("\The [extinguisher] is empty!"))
			return
		var/cooling = (0 - reagents.chem_temp) * extinguisher.cooling_power * 2
		reagents.expose_temperature(cooling)
		to_chat(user, span_notice("You cool the [name] with the [I]!"))
		playsound(loc, 'sound/effects/extinguish.ogg', 75, TRUE, -3)
		extinguisher.reagents.remove_all(1)

	return ..()

/obj/item/reagent_containers/spray/verb/empty()
	set name = "Empty Spray Bottle"
	set category = "Object"
	set src in usr
	if(usr.incapacitated())
		return
	if (tgui_alert(usr, "Are you sure you want to empty that?", "Empty Bottle:", list("Yes", "No")) != "Yes")
		return
	if(isturf(usr.loc) && src.loc == usr)
		to_chat(usr, span_notice("You empty \the [src] onto the floor."))
		reagents.expose(usr.loc)
		log_combat(usr, usr.loc, "emptied onto", src, addition="which had [reagents.get_reagent_log_string()]")
		src.reagents.clear_reagents()

/// Handles updating the spray distance when the reagents change.
/obj/item/reagent_containers/spray/on_reagent_change(datum/reagents/holder, ...)
	. = ..()
	var/total_reagent_weight = 0
	var/number_of_reagents = 0
	var/amount_of_reagents = holder.total_volume
	var/list/cached_reagents = holder.reagent_list
	for(var/datum/reagent/reagent in cached_reagents)
		total_reagent_weight += reagent.reagent_weight * reagent.volume
		number_of_reagents++

	if(total_reagent_weight && number_of_reagents && amount_of_reagents) //don't bother if the container is empty - DIV/0
		var/average_reagent_weight = total_reagent_weight / amount_of_reagents
		spray_range = clamp(round((initial(spray_range) / average_reagent_weight) - ((number_of_reagents - 1) * 1)), 3, 5) //spray distance between 3 and 5 tiles rounded down; extra reagents lose a tile
	else
		spray_range = initial(spray_range)

	if(stream_mode == 0)
		current_range = spray_range

//space cleaner
/obj/item/reagent_containers/spray/cleaner
	name = "space cleaner"
	desc = "BLAM!-brand non-foaming space cleaner!"
	icon_state = "cleaner"
	volume = 100
	list_reagents = list(/datum/reagent/space_cleaner = 100)
	amount_per_transfer_from_this = 2
	possible_transfer_amounts = list(2,5)

/obj/item/reagent_containers/spray/cleaner/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is putting the nozzle of \the [src] in [user.p_their()] mouth. It looks like [user.p_theyre()] trying to commit suicide!"))
	if(do_after(user, 3 SECONDS, user))
		if(reagents.total_volume >= amount_per_transfer_from_this)//if not empty
			user.visible_message(span_suicide("[user] pulls the trigger!"))
			spray(user)
			return BRUTELOSS
		else
			user.visible_message(span_suicide("[user] pulls the trigger...but \the [src] is empty!"))
			return SHAME
	else
		user.visible_message(span_suicide("[user] decided life was worth living."))
		return MANUAL_SUICIDE_NONLETHAL

//spray tan
/obj/item/reagent_containers/spray/spraytan
	name = "spray tan"
	volume = 50
	desc = "Gyaro brand spray tan. Do not spray near eyes or other orifices."
	list_reagents = list(/datum/reagent/spraytan = 50)


//pepperspray
/obj/item/reagent_containers/spray/pepper
	name = "pepperspray"
	desc = "Manufactured by UhangInc, used to blind and down an opponent quickly."
	icon = 'icons/obj/weapons/items_and_weapons.dmi'
	icon_state = "pepperspray"
	inhand_icon_state = "pepperspray"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	volume = 50
	stream_range = 4
	amount_per_transfer_from_this = 5
	list_reagents = list(/datum/reagent/consumable/condensedcapsaicin = 50)

/obj/item/reagent_containers/spray/pepper/empty //for protolathe printing
	list_reagents = null

/obj/item/reagent_containers/spray/pepper/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] begins huffing \the [src]! It looks like [user.p_theyre()] getting a dirty high!"))
	return OXYLOSS

// Fix pepperspraying yourself
/obj/item/reagent_containers/spray/pepper/afterattack(atom/A as mob|obj, mob/user)
	if (A.loc == user)
		return
	return ..() | AFTERATTACK_PROCESSED_ITEM

//water flower
/obj/item/reagent_containers/spray/waterflower
	name = "water flower"
	desc = "A seemingly innocent sunflower...with a twist."
	icon = 'icons/obj/hydroponics/harvest.dmi'
	icon_state = "sunflower"
	inhand_icon_state = "sunflower"
	lefthand_file = 'icons/mob/inhands/weapons/plants_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/plants_righthand.dmi'
	amount_per_transfer_from_this = 1
	possible_transfer_amounts = list(1)
	can_toggle_range = FALSE
	current_range = 1
	volume = 10
	list_reagents = list(/datum/reagent/water = 10)

///Subtype used for the lavaland clown ruin.
/obj/item/reagent_containers/spray/waterflower/superlube
	name = "clown flower"
	desc = "A delightly devilish flower... you got a feeling where this is going."
	icon = 'icons/obj/medical/chemical.dmi'
	icon_state = "clownflower"
	volume = 30
	list_reagents = list(/datum/reagent/lube/superlube = 30)

/obj/item/reagent_containers/spray/waterflower/cyborg
	reagent_flags = NONE
	volume = 100
	list_reagents = list(/datum/reagent/water = 100)
	var/generate_amount = 5
	var/generate_type = /datum/reagent/water
	var/last_generate = 0
	var/generate_delay = 10 //deciseconds
	can_fill_from_container = FALSE

/obj/item/reagent_containers/spray/waterflower/cyborg/hacked
	name = "nova flower"
	desc = "This doesn't look safe at all..."
	list_reagents = list(/datum/reagent/clf3 = 3)
	volume = 3
	generate_type = /datum/reagent/clf3
	generate_amount = 1
	generate_delay = 40 //deciseconds

/obj/item/reagent_containers/spray/waterflower/cyborg/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSfastprocess, src)

/obj/item/reagent_containers/spray/waterflower/cyborg/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/obj/item/reagent_containers/spray/waterflower/cyborg/process()
	if(world.time < last_generate + generate_delay)
		return
	last_generate = world.time
	generate_reagents()

/obj/item/reagent_containers/spray/waterflower/cyborg/empty()
	to_chat(usr, span_warning("You can not empty this!"))
	return

/obj/item/reagent_containers/spray/waterflower/cyborg/proc/generate_reagents()
	reagents.add_reagent(generate_type, generate_amount)

//chemsprayer
/obj/item/reagent_containers/spray/chemsprayer
	name = "chem sprayer"
	desc = "A utility used to spray large amounts of reagents in a given area."
	icon = 'icons/obj/weapons/guns/ballistic.dmi'
	icon_state = "chemsprayer"
	inhand_icon_state = "chemsprayer"
	lefthand_file = 'icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/guns_righthand.dmi'
	throwforce = 0
	w_class = WEIGHT_CLASS_NORMAL
	stream_mode = 1
	current_range = 7
	spray_range = 4
	stream_range = 7
	amount_per_transfer_from_this = 10
	volume = 600

/obj/item/reagent_containers/spray/chemsprayer/afterattack(atom/A as mob|obj, mob/user)
	// Make it so the bioterror spray doesn't spray yourself when you click your inventory items
	if (A.loc == user)
		return
	return ..() | AFTERATTACK_PROCESSED_ITEM

/obj/item/reagent_containers/spray/chemsprayer/spray(atom/A, mob/user)
	var/direction = get_dir(src, A)
	var/turf/T = get_turf(A)
	var/turf/T1 = get_step(T,turn(direction, 90))
	var/turf/T2 = get_step(T,turn(direction, -90))
	var/list/the_targets = list(T,T1,T2)

	for(var/i in 1 to 3) // intialize sprays
		if(reagents.total_volume < 1)
			return
		..(the_targets[i], user)

/obj/item/reagent_containers/spray/chemsprayer/bioterror
	list_reagents = list(/datum/reagent/toxin/sodium_thiopental = 100, /datum/reagent/toxin/coniine = 100, /datum/reagent/toxin/venom = 100, /datum/reagent/consumable/condensedcapsaicin = 100, /datum/reagent/toxin/initropidril = 100, /datum/reagent/toxin/polonium = 100)


/obj/item/reagent_containers/spray/chemsprayer/janitor
	name = "janitor chem sprayer"
	desc = "A utility used to spray large amounts of cleaning reagents in a given area. It regenerates space cleaner by itself but it's unable to be fueled by normal means."
	icon_state = "chemsprayer_janitor"
	inhand_icon_state = "chemsprayer_janitor"
	lefthand_file = 'icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/guns_righthand.dmi'
	reagent_flags = NONE
	list_reagents = list(/datum/reagent/space_cleaner = 1000)
	volume = 1000
	amount_per_transfer_from_this = 5
	var/generate_amount = 50
	var/generate_type = /datum/reagent/space_cleaner
	var/last_generate = 0
	var/generate_delay = 10 //deciseconds

/obj/item/reagent_containers/spray/chemsprayer/janitor/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSfastprocess, src)

/obj/item/reagent_containers/spray/chemsprayer/janitor/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/obj/item/reagent_containers/spray/chemsprayer/janitor/process()
	if(world.time < last_generate + generate_delay)
		return
	last_generate = world.time
	reagents.add_reagent(generate_type, generate_amount)

// Plant-B-Gone
/obj/item/reagent_containers/spray/plantbgone // -- Skie
	name = "Plant-B-Gone"
	desc = "Kills those pesky weeds!"
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "plantbgone"
	inhand_icon_state = "plantbgone"
	lefthand_file = 'icons/mob/inhands/equipment/hydroponics_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/hydroponics_righthand.dmi'
	volume = 100
	list_reagents = list(/datum/reagent/toxin/plantbgone = 100)

/obj/item/reagent_containers/spray/syndicate
	name = "suspicious spray bottle"
	desc = "A spray bottle, with a high performance plastic nozzle. The color scheme makes you feel slightly uneasy."
	icon = 'icons/obj/medical/chemical.dmi'
	icon_state = "sprayer_sus_8"
	inhand_icon_state = "sprayer_sus"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	spray_range = 4
	stream_range = 2
	volume = 100
	custom_premium_price = PAYCHECK_COMMAND * 2

/obj/item/reagent_containers/spray/syndicate/Initialize(mapload)
	. = ..()
	icon_state = pick("sprayer_sus_1", "sprayer_sus_2", "sprayer_sus_3", "sprayer_sus_4", "sprayer_sus_5","sprayer_sus_6", "sprayer_sus_7", "sprayer_sus_8")

/obj/item/reagent_containers/spray/medical
	name = "medical spray bottle"
	icon = 'icons/obj/medical/chemical.dmi'
	icon_state = "sprayer_med_red"
	inhand_icon_state = "sprayer_med_red"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	volume = 100
	unique_reskin = list("Red" = "sprayer_med_red",
						"Yellow" = "sprayer_med_yellow",
						"Blue" = "sprayer_med_blue")

/obj/item/reagent_containers/spray/medical/AltClick(mob/user)
	if(unique_reskin && !current_skin && user.can_perform_action(src, NEED_DEXTERITY))
		reskin_obj(user)

/obj/item/reagent_containers/spray/medical/reskin_obj(mob/M)
	..()
	switch(icon_state)
		if("sprayer_med_red")
			inhand_icon_state = "sprayer_med_red"
		if("sprayer_med_yellow")
			inhand_icon_state = "sprayer_med_yellow"
		if("sprayer_med_blue")
			inhand_icon_state = "sprayer_med_blue"
	M.update_held_items()

/obj/item/reagent_containers/spray/hercuri
	name = "medical spray (hercuri)"
	desc = "A medical spray bottle.This one contains hercuri, a medicine used to negate the effects of dangerous high-temperature environments. Careful not to freeze the patient!"
	icon_state = "sprayer_large"
	list_reagents = list(/datum/reagent/medicine/c2/hercuri = 100)
