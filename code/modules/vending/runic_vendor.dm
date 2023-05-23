//This one's from bay12
/obj/machinery/vending/runic_vendor
	name = "\improper Runic Vending Machine"
	desc = "All the fine parts you need in one vending machine!"
	products = list(
		/obj/item/assembly/igniter = 6,
		/obj/item/assembly/prox_sensor = 6,
		/obj/item/assembly/signaler = 6,
		/obj/item/assembly/timer = 6,
		/obj/item/clothing/head/bio_hood = 6,
		/obj/item/clothing/suit/bio_suit = 6,
		/obj/item/clothing/under/rank/rnd/scientist = 6,
		/obj/item/transfer_valve = 6,
	)
	contraband = list(/obj/item/assembly/health = 3)
	default_price = PAYCHECK_CREW
	extra_price = PAYCHECK_CREW
	payment_department = ACCOUNT_SCI
	var/duration = 20 SECONDS


/obj/machinery/vending/runic_vendor/Initialize(mapload, obj/item/forcefield_projector/origin)
	addtimer(CALLBACK(src, PROC_REF(decay)), duration, TIMER_STOPPABLE)

	. = ..()

/obj/machinery/vending/runic_vendor/Destroy()
	visible_message(span_warning("[src] flickers and disappears!"))
	playsound(src,'sound/weapons/resonator_blast.ogg',25,TRUE)
	return ..()

/obj/machinery/vending/runic_vendor/proc/runic_explosion()
	explosion(src, devastation_range = -1, light_impact_range = 2)
	qdel(src)
	return

/obj/machinery/vending/runic_vendor/screwdriver_act(mob/living/user, obj/item/I)
	explosion(src, devastation_range = -1, light_impact_range = 2)
	qdel(src)
	return

/obj/machinery/vending/runic_vendor/proc/decay()
	qdel(src)
	return
