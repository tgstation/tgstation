/obj/machinery/power/plumbing
	name = "pipe thing"
	icon = 'icons/obj/plumbing/plumbers.dmi'
	icon_state = "pump"
	anchored = FALSE
	idle_power_usage = 10
	active_power_usage = 300
	var/volume = 100
	var/working = FALSE
	var/deployable = null

/obj/machinery/power/plumbing/Initialize()
	create_reagents(volume, OPENCONTAINER | AMOUNT_VISIBLE)
	update_icon()
	return ..()

/obj/machinery/power/plumbing/ComponentInitialize()
	AddComponent(/datum/component/plumbing/input)

/obj/machinery/power/plumbing/wrench_act(mob/living/user, obj/item/I)
	/// check to prevent pipe stacking on same tile
	var/turf/T = get_turf(loc)
	for(var/A in T.contents)
		if(istype(A,/obj/machinery/power/plumbing) && A != src && anchored)
			to_chat(user, "<span class='warning'>There is already a pipe machinery here!</span>")
			return FALSE
	default_unfasten_wrench(user, I)
	update_icon()
	/// connects to pipes nearby
	for(var/D in GLOB.cardinals)
		for(var/obj/machinery/duct/P in get_step(src, D))
			if(istype(P))
				P.attempt_connect()
	return TRUE

/obj/machinery/power/plumbing/default_unfasten_wrench(mob/user, obj/item/I, time = 5)
	..()
	var/datum/component/plumbing/P = GetComponent(/datum/component/plumbing)
	if(anchored)
		P.start()
		connect_to_network()
	else
		P.disable()
		disconnect_from_network()

/obj/machinery/power/plumbing/crowbar_act(mob/living/user, obj/item/I)
	if(anchored)
		to_chat(user, "<span class='warning'>Unbolt it from the floor first.</span>")
		return
	if(!working)
		to_chat(user, "<span class='notice'>You start disassembling  \the [src]...</span>")
		working = TRUE
		if(do_after(user, 50, target = src))
			to_chat(user, "<span class='notice'>You have disassembled \the [src].</span>")
			new deployable (get_turf(src))
			qdel(src)
		else
			working = FALSE

/obj/machinery/power/plumbing/pipeinput
	name = "pipe input"
	icon_state = "input"
	volume = 100
	anchored = FALSE

/obj/machinery/power/plumbing/pipeoutput
	name = "pipe output"
	icon_state = "output"
	volume = 100
	anchored = FALSE

/obj/machinery/power/plumbing/pipeoutput/Initialize()
	create_reagents(volume, OPENCONTAINER | AMOUNT_VISIBLE)
	return ..()


/obj/machinery/power/plumbing/pipeoutput/ComponentInitialize()
	AddComponent(/datum/component/plumbing/output)

/obj/machinery/power/plumbing/sprinkler
	name = "sprinkler"
	desc = "An automated sprinkler capable of detecting fire and spraying coolant."
	icon_state = "sprinkler"
	layer = PROJECTILE_HIT_THRESHHOLD_LAYER
	plane = FLOOR_PLANE
	max_integrity = 100
	armor = list("melee" = 20, "bullet" = 10, "laser" = 10, "energy" = 20, "bomb" = 50, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 30)
	req_access = list(ACCESS_ENGINE)
	anchored = FALSE
	density = FALSE
	deployable = /obj/item/deployable/sprinkler
	volume = 10
	var/dirty = FALSE
	var/cooldown = 0

/obj/machinery/power/plumbing/sprinkler/Initialize()
	create_reagents(volume, AMOUNT_VISIBLE)
	update_icon()
	return ..()

/obj/machinery/power/plumbing/sprinkler/ComponentInitialize()
	AddComponent(/datum/component/plumbing/output)

/obj/machinery/power/plumbing/sprinkler/examine(mob/user)
	. = ..()
	. += "<span class='notice'>It is [anchored? "anchored" : "not anchored"].</span>"
	. += "<span class='notice'>[dirty? "It's dirty" : "It's clean"].</span>"

/obj/machinery/power/plumbing/sprinkler/default_unfasten_wrench(mob/user, obj/item/I, time = 5)
	..()
	if(anchored)
		START_PROCESSING(SSobj, src)
	else
		STOP_PROCESSING(SSobj, src)

/obj/machinery/power/plumbing/sprinkler/process()
	///find sparks
	var/turf/T = get_turf(loc)
	var/obj/effect/particle_effect/sparks/S = locate() in T.contents
	if(S)
		dispense()
	if(prob(10))
		///find dirt
		var/obj/effect/decal/cleanable/D = locate() in T.contents
		if(D)
			dirty = TRUE
			STOP_PROCESSING(SSobj, src)
			update_icon()

/obj/machinery/power/plumbing/sprinkler/update_icon()
	. = ..()
	cut_overlays()
	if(dirty)
		add_overlay(mutable_appearance(icon,"sprinkler_dirty"))
	if(!anchored)
		add_overlay(mutable_appearance(icon,"sprinkler_connection"))

/obj/machinery/power/plumbing/sprinkler/plunger_act(obj/item/plunger/P, mob/living/user)
	. = ..()
	if(!dirty)
		to_chat(user, "<span class='notice'>\The [src] is clean, there is no need to plunger it.</span>")
		return
	if(!working)
		to_chat(user, "<span class='notice'>You start plunging  \the [src]...</span>")
		working = TRUE
		if(do_after(user, 50, target = src))
			to_chat(user, "<span class='notice'>You have plunged \the [src].</span>")
			dirty = FALSE
			START_PROCESSING(SSobj, src)
			update_icon()
		else
			working = FALSE

/obj/machinery/power/plumbing/sprinkler/interact(mob/user)
	if(!allowed(user))
		to_chat(user, "<span class='warning'>Access denied.</span>")
		return
	dispense()
	log_game("[user] has manually actived the sprinkler in [AREACOORD(src)]")

/obj/machinery/power/plumbing/sprinkler/fire_act()
	. = ..()
	dispense()

/obj/machinery/power/plumbing/sprinkler/proc/dispense()
	if(cooldown < world.time && !dirty && anchored)
		playsound(src, 'sound/machines/beep.ogg', 100, 1)
		var/datum/effect_system/smoke_spread/chem/smoke_machine/smoke = new()
		smoke.set_up(reagents, 5, 8,  get_turf(src))
		smoke.start()
		cooldown = world.time + 200
		log_game("A sprinkler has been activated in [AREACOORD(src)]")

/obj/machinery/power/plumbing/sprinkler/Destroy()
	STOP_PROCESSING(SSobj, src)
	..()

/obj/item/deployable
	name = "deployable thing"
	desc = "A self-deploying thing, it shouldn't be here."
	icon = 'icons/obj/plumbing/plumbers.dmi'
	icon_state = "sprinkler_d"
	var/deploying = FALSE
	var/obj/machinery/power/plumbing/result

/obj/item/deployable/attack_self(mob/user)
	. = ..()
	if(!deploying)
		to_chat(user, "<span class='notice'>You start planting \the [src]...</span>")
		deploying = TRUE
		if(do_after(user, 50, target = src))
			to_chat(user, "<span class='notice'>You have activated \the [src].</span>")
			new result (get_turf(src))
			qdel(src)
		else
			deploying = FALSE

/obj/item/deployable/sprinkler
	name = "deployable sprinkler"
	desc = "A self-deploying sprinkler, just press the button to activate it."
	icon_state = "sprinkler_d"
	result = /obj/machinery/power/plumbing/sprinkler

/obj/item/deployable/input
	name = "deployable input pipe"
	desc = "A self-deploying input pipe, just press the button to activate it."
	icon_state = "input_d"
	result = /obj/machinery/power/plumbing/pipeinput

/obj/item/deployable/output
	name = "deployable output pipe"
	desc = "A self-deploying output pipe, just press the button to activate it."
	icon_state = "output_d"
	result = /obj/machinery/power/plumbing/pipeoutput
