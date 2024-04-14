#define PULSE_DISTANCE_RANGE 2

/obj/machinery/vending/runic_vendor
	name = "\improper Runic Vending Machine"
	desc = "This vending machine was designed for warfare! A perfect bait for Nanotrasen's crew thirst for consumerism."
	icon_state = "RunicVendor"
	panel_type = "panel10"
	product_slogans = "Come get free magic!;50% off on Mjollnirs today!; Buy a warp whistle and get another one free!"
	vend_reply = "Please, stand still near the vending machine for your special package!"
	resistance_flags = FIRE_PROOF
	light_mask = "RunicVendor-light-mask"
	obj_flags = parent_type::obj_flags | NO_DEBRIS_AFTER_DECONSTRUCTION
	/// How long the vendor stays up before it decays.
	var/time_to_decay = 30 SECONDS
	/// Area around the vendor that will pushback nearby mobs.
	var/pulse_distance = PULSE_DISTANCE_RANGE


/obj/machinery/vending/runic_vendor/Initialize(mapload)
	if(mapload)
		log_mapping("[type] is not supposed to be mapped it, it decays after a set time")
		stack_trace("Someone mapped in the meme vending machine the wizard scepter spawns, please remove it")

	addtimer(CALLBACK(src, PROC_REF(decay)), time_to_decay, TIMER_STOPPABLE)
	INVOKE_ASYNC(src, PROC_REF(runic_pulse))

	switch(pick(1,3))
		if(1)
			products = list(
			/obj/item/clothing/head/wizard = 1,
			/obj/item/clothing/suit/wizrobe = 1,
			/obj/item/clothing/shoes/sandal/magic = 1,
			/obj/item/toy/foam_runic_scepter = 1,
			)
		if(2)
			products = list(
			/obj/item/clothing/head/wizard/red = 1,
			/obj/item/clothing/suit/wizrobe/red = 1,
			/obj/item/clothing/shoes/sandal/magic = 1,
			/obj/item/toy/foam_runic_scepter = 1,
			)
		if(3)
			products = list(
			/obj/item/clothing/head/wizard/yellow = 1,
			/obj/item/clothing/suit/wizrobe/yellow = 1,
			/obj/item/clothing/shoes/sandal/magic = 1,
			/obj/item/toy/foam_runic_scepter = 1,
			)

	return ..()

/obj/machinery/vending/runic_vendor/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()

	if(held_item)
		if(istype(held_item, /obj/item/runic_vendor_scepter))
			context[SCREENTIP_CONTEXT_LMB] = "Detonate"
			context[SCREENTIP_CONTEXT_RMB] = "Force push"

		return CONTEXTUAL_SCREENTIP_SET

	return .

/obj/machinery/vending/runic_vendor/handle_deconstruct(disassembled)
	SHOULD_NOT_OVERRIDE(TRUE)

	visible_message(span_warning("[src] flickers and disappears!"))
	playsound(src,'sound/weapons/resonator_blast.ogg',25,TRUE)
	return ..()

/obj/machinery/vending/runic_vendor/proc/runic_explosion()
	explosion(src, light_impact_range = 2)
	deconstruct(FALSE)

/obj/machinery/vending/runic_vendor/proc/runic_pulse()
	var/pulse_locs = spiral_range_turfs(pulse_distance, get_turf(src))
	var/list/hit_things = list()
	for(var/turf/pulsing_turf in pulse_locs)
		for(var/mob/living/mob_to_be_pulsed_back in pulsing_turf.contents)
			hit_things += mob_to_be_pulsed_back
			var/atom/target = get_edge_target_turf(mob_to_be_pulsed_back, get_dir(src, get_step_away(mob_to_be_pulsed_back, src)))
			to_chat(mob_to_be_pulsed_back, span_userdanger("The field repels you with tremendous force!"))
			playsound(src, 'sound/effects/gravhit.ogg', 50, TRUE)
			mob_to_be_pulsed_back.throw_at(target, 4, 4)

/obj/machinery/vending/runic_vendor/screwdriver_act(mob/living/user, obj/item/I)
	runic_explosion()

/obj/machinery/vending/runic_vendor/proc/decay()
	deconstruct(FALSE)

#undef PULSE_DISTANCE_RANGE
