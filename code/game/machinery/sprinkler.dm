///basic plumbing machinery it holds a wrench_act used in all plumbing machinery
/obj/machinery/plumbing
	name = "pipe thing"
	icon = 'icons/obj/plumbing/plumbers.dmi'
	icon_state = "pump"
	anchored = FALSE
	active_power_usage = 30
	use_power = ACTIVE_POWER_USE
	///how much chems it can hold
	var/volume = 100
	///var to prevent do_after stacking
	var/working = FALSE
	///if crowbar'd what it turns into
	var/deployable = null

/obj/machinery/plumbing/Initialize()
	create_reagents(volume, OPENCONTAINER | AMOUNT_VISIBLE)
	update_icon()
	power_change()
	return ..()

/obj/machinery/plumbing/ComponentInitialize()
	AddComponent(/datum/component/plumbing/input)

/obj/machinery/plumbing/wrench_act(mob/living/user, obj/item/I)
	if(pre_wrench_check())
		to_chat(user, "<span class='warning'>There is already a pipe machinery here!</span>")
		return FALSE
	default_unfasten_wrench(user, I)
	update_icon()
	return TRUE

///checks if there are other machinery already to prevent wrenching one on top of another
/obj/machinery/plumbing/proc/pre_wrench_check()
	var/turf/T = get_turf(loc)
	for(var/A in T.contents)
		if(istype(A,/obj/machinery/plumbing) && A != src && !anchored)
			return TRUE
	return FALSE

/obj/machinery/plumbing/default_unfasten_wrench(mob/user, obj/item/I, time = 5)
	..()
	var/datum/component/plumbing/P = GetComponent(/datum/component/plumbing)
	if(anchored)
		P.start()
	else
		P.disable()

/obj/machinery/plumbing/crowbar_act(mob/living/user, obj/item/I)
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
			return FALSE
		else
			working = FALSE

/obj/machinery/plumbing/pipeinput
	name = "pipe input"
	icon_state = "input"
	volume = 100
	anchored = FALSE

/obj/machinery/plumbing/pipeoutput
	name = "pipe output"
	icon_state = "output"
	volume = 100
	anchored = FALSE

/obj/machinery/plumbing/pipeoutput/Initialize()
	create_reagents(volume, OPENCONTAINER | AMOUNT_VISIBLE)
	return ..()

/obj/machinery/plumbing/pipeoutput/ComponentInitialize()
	AddComponent(/datum/component/plumbing/output)

/obj/machinery/plumbing/sprinkler
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
	active_power_usage = 70
	deployable = /obj/item/deployable/sprinkler
	volume = 10
	/// if the machine is dirty and needs plunging
	var/dirty = FALSE
	/// it holds the time after the sprinkler can dispense again
	var/cooldown = 0

/obj/machinery/plumbing/sprinkler/Initialize()
	create_reagents(volume, AMOUNT_VISIBLE)
	update_icon()
	return ..()

/obj/machinery/plumbing/sprinkler/ComponentInitialize()
	AddComponent(/datum/component/plumbing/output)

/obj/machinery/plumbing/sprinkler/examine(mob/user)
	. = ..()
	. += "<span class='notice'>It is [anchored? "anchored" : "not anchored"].</span>"
	. += "<span class='notice'>[dirty? "It's dirty" : "It's clean"].</span>"

/obj/machinery/plumbing/sprinkler/power_change()
	if(powered())
		stat &= ~NOPOWER
	else
		stat |= NOPOWER
	update_icon()

/obj/machinery/plumbing/sprinkler/default_unfasten_wrench(mob/user, obj/item/I, time = 5)
	..()
	if(anchored)
		START_PROCESSING(SSobj, src)
	else
		STOP_PROCESSING(SSobj, src)

///locates spark effects on the tile and returns a boolean
/obj/machinery/plumbing/sprinkler/proc/find_sparks(turf/T)
	var/obj/effect/particle_effect/sparks/S = locate() in T.contents
	if(S)
		return TRUE
	else
		return FALSE

///locates cleanable effects on the tile and returns a boolean
/obj/machinery/plumbing/sprinkler/proc/find_dirt(turf/T)
	var/obj/effect/decal/cleanable/D = locate() in T.contents
	if(D)
		return TRUE
	else
		return FALSE

/obj/machinery/plumbing/sprinkler/process()
	var/turf/T = get_turf(loc)
	if(find_sparks(T))
		dispense()
	if(prob(10) && find_dirt(T))
		dirty = TRUE
		STOP_PROCESSING(SSobj, src)
		update_icon()

/obj/machinery/plumbing/sprinkler/update_icon()
	. = ..()
	cut_overlays()
	if(stat&NOPOWER)
		return
	if(dirty)
		add_overlay(mutable_appearance(icon,"sprinkler_dirty"))
	if(!anchored)
		add_overlay(mutable_appearance(icon,"sprinkler_connection"))
	else
		add_overlay(mutable_appearance(icon,"sprinkler_working"))

/obj/machinery/plumbing/sprinkler/plunger_act(obj/item/plunger/P, mob/living/user)
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

/obj/machinery/plumbing/sprinkler/interact(mob/user)
	if(!allowed(user))
		to_chat(user, "<span class='warning'>Access denied.</span>")
		return
	dispense()
	log_game("[user] has manually actived the sprinkler in [AREACOORD(src)]")

/obj/machinery/plumbing/sprinkler/fire_act()
	. = ..()
	dispense()

///dispenses 10u of the chemicals inside as not blinding smoke
/obj/machinery/plumbing/sprinkler/proc/dispense()
	if(cooldown < world.time && !dirty && anchored)
		playsound(src, 'sound/machines/beep.ogg', 100, 1)
		var/datum/effect_system/smoke_spread/chem/smoke_machine/smoke = new()
		smoke.set_up(reagents, 5, 8,  get_turf(src))
		smoke.start()
		cooldown = world.time + 200
		log_game("A sprinkler has been activated in [AREACOORD(src)]")

/obj/machinery/plumbing/sprinkler/Destroy()
	STOP_PROCESSING(SSobj, src)
	..()

///deployable object that has the only function to create something when pressed in hand
/obj/item/deployable
	name = "deployable thing"
	desc = "A self-deploying thing, it shouldn't be here."
	icon = 'icons/obj/plumbing/plumbers.dmi'
	icon_state = "sprinkler_d"
	///var to prevent do_after stacking
	var/deploying = FALSE
	///result thing that gets spawned after deploying it
	var/obj/result

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
	result = /obj/machinery/plumbing/sprinkler

/obj/item/deployable/input
	name = "deployable input pipe"
	desc = "A self-deploying input pipe, just press the button to activate it."
	icon_state = "input_d"
	result = /obj/machinery/plumbing/pipeinput

/obj/item/deployable/output
	name = "deployable output pipe"
	desc = "A self-deploying output pipe, just press the button to activate it."
	icon_state = "output_d"
	result = /obj/machinery/plumbing/pipeoutput
