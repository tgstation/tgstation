//This one's from bay12
/obj/machinery/vending/runic_vendor
	name = "\improper Runic Vending Machine"
	desc = "This vending machine was designed for warfare! A perfect bait for NanoTrasen's crew thirst for consumerism!."
	icon_state = "RunicVendor"
	panel_type = "panel10"
	product_slogans = "Come get free magic!;50% off on Mjollnirs today!; Buy a warp whistle and get another one free!"
	vend_reply = "Please, stand still near the vending machine for your special package!"
	products = list(
		/obj/item/clothing/head/wizard = 1,
		/obj/item/clothing/suit/wizrobe = 1,
		/obj/item/clothing/head/wizard/red = 1,
		/obj/item/clothing/suit/wizrobe/red = 1,
		/obj/item/clothing/head/wizard/yellow = 1,
		/obj/item/clothing/suit/wizrobe/yellow = 1,
		/obj/item/clothing/shoes/sandal/magic = 1,
		/obj/item/staff = 2,
	)
	resistance_flags = FIRE_PROOF
	light_mask = "RunicVendor-light-mask"
	/// How long the vendor stays up before it decays.
	var/time_to_decay = 30 SECONDS
	/// Area around the vendor that will pushback nearby mobs.
	var/pulse_distance = 2


/obj/machinery/vending/runic_vendor/Initialize(mapload)
	addtimer(CALLBACK(src, PROC_REF(decay)), time_to_decay, TIMER_STOPPABLE)
	runic_pulse()
	. = ..()

/obj/machinery/vending/runic_vendor/Destroy()
	visible_message(span_warning("[src] flickers and disappears!"))
	playsound(src,'sound/weapons/resonator_blast.ogg',25,TRUE)
	return ..()

/obj/machinery/vending/runic_vendor/proc/runic_explosion()
	explosion(src, light_impact_range = 2)
	qdel(src)
	return

/obj/machinery/vending/runic_vendor/proc/runic_pulse()//atom/movable/considered_atom as mob|obj)
	var/pulse_locs = spiral_range_turfs(pulse_distance, get_turf(src))
	var/list/hit_things = list()
	for(var/turf/T in pulse_locs)
		for(var/mob/living/L in T.contents)
			if(!L == src)
				return
			hit_things += L
			var/atom/target = get_edge_target_turf(L, get_dir(src, get_step_away(L, src)))
			if(isliving(L))
				to_chat(L, span_userdanger("The field repels you with tremendous force!"))
				playsound(src, 'sound/effects/gravhit.ogg', 50, TRUE)
				L.throw_at(target, 4, 4)
	return


/obj/machinery/vending/runic_vendor/screwdriver_act(mob/living/user, obj/item/I)
	explosion(src, light_impact_range = 2)
	qdel(src)
	return

/obj/machinery/vending/runic_vendor/proc/decay()
	qdel(src)
	return
