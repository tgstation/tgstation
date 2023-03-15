/obj/item/reagent_containers/food/drinks/attack_self(mob/user)
	if(!is_drainable())
		open_drink(user)
		return
	return ..()

/obj/item/reagent_containers/food/drinks/proc/open_drink(mob/user, burstopen = FALSE)
	ENABLE_BITFIELD(reagents.flags, OPENCONTAINER)
	ENABLE_BITFIELD(reagents.flags, DUNKABLE)
	playsound(src, "can_open", 50, 1)
	spillable = TRUE
	canopened = TRUE
	possible_transfer_amounts = list(5,10,15,20,25,30,50)
	if(!burstopen)
		to_chat(user, "You open \the [src] with an audible pop.") //Ahhhhhhhh
	else
		visible_message("<span class='warning'>[src] bursts open!</span>")

	if(times_shaken < 5)
		visible_message("<span class='warning'>[src] fizzes violently!</span>")
	else
		visible_message("<span class='boldwarning'>[src] erupts into foam!</span>")
		if(reagents.total_volume)
			var/datum/effect_system/foam_spread/sodafizz = new
			sodafizz.set_up(1, get_turf(src), reagents)
			sodafizz.start()
	if(times_shaken >= 1 && times_shaken < 5)
		for(var/mob/living/carbon/C in range(1, get_turf(src)))
			to_chat(C, "<span class='warning'>You are splattered with [name]!</span>")
			reagents.reaction(C, TOUCH)

	reagents.remove_any(times_shaken / 5 * reagents.total_volume)


/obj/item/reagent_containers/food/drinks/AltClick(mob/user)
	if(!isShakeable)
		return
	var/mob/living/carbon/human/H
	H = user
	if(canopened)
		to_chat(H, "<span class='warning'>You carefully reseal the [src].")
		canopened = FALSE
		spillable = FALSE
		possible_transfer_amounts = list()
		times_shaken = 0
		DISABLE_BITFIELD(reagents.flags, OPENCONTAINER)
		DISABLE_BITFIELD(reagents.flags, DUNKABLE)
		return ..()
	else
		can_shake = FALSE
		addtimer(CALLBACK(src, .proc/reset_shakable), 1 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE)
		to_chat(H, "<span class='notice'>You start shaking up [src].</span>")
		if(do_after(H, 1 SECONDS, target = H))
			visible_message("<span class='warning'>[user] shakes up [src]!</span>")
			if(times_shaken == 0)
				times_shaken++
				addtimer(CALLBACK(src, .proc/reset_shaken), 1 MINUTES, TIMER_UNIQUE | TIMER_OVERRIDE | TIMER_NO_HASH_WAIT)
			else if(times_shaken < 5)
				times_shaken++
				addtimer(CALLBACK(src, .proc/reset_shaken), (70 - (times_shaken * 10)) SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE | TIMER_NO_HASH_WAIT)
			else
				addtimer(CALLBACK(src, .proc/reset_shaken), 20 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE | TIMER_NO_HASH_WAIT)
				handle_bursting(user)

/obj/item/reagent_containers/food/drinks/proc/reset_shaken()
	times_shaken--
	if(can_burst)
		can_burst = FALSE
		burst_chance = 0
	if(times_shaken)
		addtimer(CALLBACK(src, .proc/reset_shaken), (70 - (times_shaken * 10)) SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE | TIMER_NO_HASH_WAIT)

/obj/item/reagent_containers/food/drinks/proc/reset_shakable()
	can_shake = TRUE

/obj/item/reagent_containers/food/drinks/proc/handle_bursting(mob/user)
	if(times_shaken != 5 || canopened)
		return

	if(!can_burst)
		can_burst = TRUE
		burst_chance = 5
		return

	if(burst_chance < 50)
		burst_chance += 5

	if(prob((burst_chance)))
		if(user)
			open_drink(user, burstopen = TRUE)
		else
			open_drink(burstopen = TRUE)

/obj/item/reagent_containers/food/drinks/examine(mob/user)
	. = ..()
	if(canopened)
		. += "<span class='notice'>It has been opened.</span>"
		. += "<span class='info'>Alt-click to reseal it.</span>"
	else
		. += "<span class='info'>Alt-click to shake it up!</span>"
	if(times_shaken > 0)
		. += "<span class='warning'>This container looks under pressure.</span>"
