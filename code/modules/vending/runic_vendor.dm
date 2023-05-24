//This one's from bay12
/obj/machinery/vending/runic_vendor
	name = "\improper Runic Vending Machine"
	desc = "A magic vending machine."
	icon_state = "RunicVendor"
	panel_type = "panel10"
	product_slogans = "Sling spells the proper way with MagiVend!;Be your own Houdini! Use MagiVend!"
	vend_reply = "Have an enchanted evening!"
	product_ads = "FJKLFJSD;AJKFLBJAKL;1234 LOONIES LOL!;>MFW;Kill them fuckers!;GET DAT FUKKEN DISK;HONK!;EI NATH;Destroy the station!;Admin conspiracies since forever!;Space-time bending hardware!"
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
	default_price = 0 //Just in case, since it's primary use is storage.
	light_mask = "RunicVendor-light-mask"
	/// How long the vendor stays up before it decays.
	var/time_to_decay = 20 SECONDS
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
	explosion(src, devastation_range = -1, light_impact_range = 2)
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
			visible_message(span_boldwarning("[L] is knocked back by the gust!"))
			to_chat(L, span_userdanger("You're knocked back by the gust!"))
			var/atom/target = get_edge_target_turf(L, get_dir(src, get_step_away(L, src)))
			if(isliving(L))
				to_chat(L, span_userdanger("The field repels you with tremendous force!"))
				playsound(src, 'sound/effects/gravhit.ogg', 50, TRUE)
				L.throw_at(target, 20, 4)
	return


/obj/machinery/vending/runic_vendor/screwdriver_act(mob/living/user, obj/item/I)
	explosion(src, devastation_range = -1, light_impact_range = 2)
	qdel(src)
	return

/obj/machinery/vending/runic_vendor/proc/decay()
	qdel(src)
	return
