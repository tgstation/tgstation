#define CLEAN_TILE_REWARD 50

/obj/item/mop
	desc = "The world of janitalia wouldn't be complete without a mop."
	name = "mop"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "mop"
	lefthand_file = 'icons/mob/inhands/equipment/custodial_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/custodial_righthand.dmi'
	force = 3
	throwforce = 5
	throw_speed = 3
	throw_range = 7
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb = list("mopped", "bashed", "bludgeoned", "whacked")
	resistance_flags = FLAMMABLE
	var/mopping = 0
	var/mopcount = 0
	var/mopcap = 5
	var/mopspeed = 30
	var/stored_points = 0
	force_string = "robust... against germs"
	var/insertable = TRUE

/obj/item/mop/New()
	..()
	create_reagents(mopcap)


/obj/item/mop/proc/clean(turf/A, mob/user)
	var/cleaned = FALSE
	if(reagents.has_reagent("water", 1) || reagents.has_reagent("holywater", 1) || reagents.has_reagent("vodka", 1) || reagents.has_reagent("cleaner", 1))
		SEND_SIGNAL(A, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_MEDIUM)
		for(var/obj/effect/O in A)
			if(is_cleanable(O))
				cleaned = TRUE
				qdel(O)
	if(cleaned && user && user.mind && user.mind.assigned_role == "Janitor")
		stored_points += CLEAN_TILE_REWARD
	reagents.reaction(A, TOUCH, 10)	//Needed for proper floor wetting.
	reagents.remove_any(1)			//reaction() doesn't use up the reagents
	return cleaned

/obj/item/mop/pre_attack(atom/target, mob/user, params)
	if(istype(target, /obj/machinery/computer/rdconsole))
		var/obj/machinery/computer/rdconsole/RDC = target
		if(stored_points)
			RDC.stored_research.add_point_type(TECHWEB_POINT_TYPE_DEFAULT, stored_points)
			user.visible_message("<span class='notice'>[user] passes [src] over [RDC], wirelessly transmitting its stored information \
			into [RDC].</span>", "<span class='boldnotice'>You upload [stored_points] points to [RDC]'s research storage.</span>")
			stored_points = 0
	else
		return ..()

/obj/item/mop/afterattack(atom/A, mob/user, proximity)
	. = ..()
	if(!proximity)
		return

	if(reagents.total_volume < 1)
		to_chat(user, "<span class='warning'>Your mop is dry!</span>")
		return

	var/turf/T = get_turf(A)

	if(istype(A, /obj/item/reagent_containers/glass/bucket) || istype(A, /obj/structure/janitorialcart))
		return

	if(T)
		user.visible_message("[user] begins to clean \the [T] with [src].", "<span class='notice'>You begin to clean \the [T] with [src]...</span>")

		if(do_after(user, src.mopspeed, target = T))
			var/got_points = clean(T, user)
			to_chat(user, "<span class='notice'>You finish mopping.[got_points?" [src] flashes that it has gathered and stored useful research data from your efforts.":""]</span>")


/obj/effect/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/mop) || istype(I, /obj/item/soap))
		return
	else
		return ..()


/obj/item/mop/proc/janicart_insert(mob/user, obj/structure/janitorialcart/J)
	if(insertable)
		J.put_in_cart(src, user)
		J.mymop=src
		J.update_icon()
	else
		to_chat(user, "<span class='warning'>You are unable to fit your [name] into the [J.name].</span>")
		return

/obj/item/mop/cyborg
	insertable = FALSE

/obj/item/mop/advanced
	desc = "The most advanced tool in a custodian's arsenal, complete with a condenser for self-wetting! Just think of all the viscera you will clean up with this!"
	name = "advanced mop"
	mopcap = 10
	icon_state = "advmop"
	item_state = "mop"
	lefthand_file = 'icons/mob/inhands/equipment/custodial_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/custodial_righthand.dmi'
	force = 6
	throwforce = 8
	throw_range = 4
	mopspeed = 20
	var/refill_enabled = TRUE //Self-refill toggle for when a janitor decides to mop with something other than water.
	var/refill_rate = 1 //Rate per process() tick mop refills itself
	var/refill_reagent = "water" //Determins what reagent to use for refilling, just in case someone wanted to make a HOLY MOP OF PURGING

/obj/item/mop/advanced/New()
	..()
	START_PROCESSING(SSobj, src)

/obj/item/mop/advanced/attack_self(mob/user)
	refill_enabled = !refill_enabled
	if(refill_enabled)
		START_PROCESSING(SSobj, src)
	else
		STOP_PROCESSING(SSobj,src)
	to_chat(user, "<span class='notice'>You set the condenser switch to the '[refill_enabled ? "ON" : "OFF"]' position.</span>")
	playsound(user, 'sound/machines/click.ogg', 30, 1)

/obj/item/mop/advanced/process()

	if(reagents.total_volume < mopcap)
		reagents.add_reagent(refill_reagent, refill_rate)

/obj/item/mop/advanced/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>The condenser switch is set to <b>[refill_enabled ? "ON" : "OFF"]</b>.</span>")

/obj/item/mop/advanced/Destroy()
	if(refill_enabled)
		STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/mop/advanced/cyborg
	insertable = FALSE

#undef CLEAN_TILE_REWARD
