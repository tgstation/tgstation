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
	force_string = "robust... against germs"

/obj/item/mop/New()
	..()
	create_reagents(mopcap)


/obj/item/mop/proc/clean(turf/A)
	if(reagents.has_reagent("water", 1) || reagents.has_reagent("holywater", 1) || reagents.has_reagent("vodka", 1) || reagents.has_reagent("cleaner", 1))
		A.clean_blood()
		for(var/obj/effect/O in A)
			if(is_cleanable(O))
				qdel(O)
		if(isclosedturf(A))
			var/turf/closed/C = A
			C.thermite = 0
	reagents.reaction(A, TOUCH, 10)	//Needed for proper floor wetting.
	reagents.remove_any(1)			//reaction() doesn't use up the reagents


/obj/item/mop/afterattack(atom/A, mob/user, proximity)
	if(!proximity) return

	if(reagents.total_volume < 1)
		to_chat(user, "<span class='warning'>Your mop is dry!</span>")
		return

	var/turf/T = get_turf(A)

	if(istype(A, /obj/item/reagent_containers/glass/bucket) || istype(A, /obj/structure/janitorialcart))
		return

	if(T)
		user.visible_message("[user] begins to clean \the [T] with [src].", "<span class='notice'>You begin to clean \the [T] with [src]...</span>")

		if(do_after(user, src.mopspeed, target = T))
			to_chat(user, "<span class='notice'>You finish mopping.</span>")
			clean(T)


/obj/effect/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/mop) || istype(I, /obj/item/soap))
		return
	else
		return ..()


/obj/item/mop/proc/janicart_insert(mob/user, obj/structure/janitorialcart/J)
	J.put_in_cart(src, user)
	J.mymop=src
	J.update_icon()

/obj/item/mop/cyborg

/obj/item/mop/cyborg/janicart_insert(mob/user, obj/structure/janitorialcart/J)
	return

/obj/item/mop/advanced
	desc = "The most advanced tool in a custodian's arsenal, complete with a condenser for self-wetting! Just think of all the viscera you will clean up with this!"
	name = "advanced mop"
	mopcap = 10
	icon_state = "advmop"
	origin_tech = "materials=3;engineering=3"
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
