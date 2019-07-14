///basic plumbing machinery it holds a wrench_act used in all plumbing machinery
/obj/machinery/plumbing
	name = "pipe thing"
	icon = 'icons/obj/plumbing/plumbers.dmi'
	icon_state = "pump"
	anchored = FALSE
	active_power_usage = 30
	use_power = ACTIVE_POWER_USE
	///how many chems can it hold
	var/capacity = 100
	///var to prevent do_after stacking
	var/working = FALSE
	///if crowbar'd what it turns into
	var/deployable

/obj/machinery/plumbing/wrench_act(mob/living/user, obj/item/I)
	. = ..()
	if(pre_wrench_check())
		to_chat(user, "<span class='warning'>There is already a pipe machinery here!</span>")
		return TRUE
	default_unfasten_wrench(user, I)
	update_icon()
	return TRUE

///checks if there are other machinery already to prevent wrenching one on top of another
/obj/machinery/plumbing/proc/pre_wrench_check()
	var/turf/T = get_turf(loc)
	var/obj/machinery/plumbing/P = locate() in T.contents
	if(P && P != src && !anchored)
		return TRUE
	return FALSE

/obj/machinery/plumbing/default_unfasten_wrench(mob/user, obj/item/I, time = 5)
	. = ..()
	var/datum/component/plumbing/P = GetComponent(/datum/component/plumbing)
	if(anchored)
		P.start()
	else
		P.disable()

/obj/machinery/plumbing/screwdriver_act(mob/living/user, obj/item/I)
	. = FALSE
	if(anchored)
		to_chat(user, "<span class='warning'>Unbolt it from the floor first.</span>")
		return
	if(I.use_tool(src, user, 40, volume = 100))
		to_chat(user, "<span class='notice'>You have disassembled \the [src].</span>")
		if(deployable)
			new deployable (get_turf(src))
		qdel(src)
		return TRUE

/obj/machinery/plumbing/plunger_act(obj/item/plunger/P, mob/living/user)
	..()
	to_chat(user, "<span class='notice'>You start plunging  \the [src]...</span>")
	if(do_after(user, 50, target = src))
		to_chat(user, "<span class='notice'>You have plunged \the [src].</span>")
		reagents.remove_all(reagents.total_volume)
		return TRUE
	return FALSE

/obj/machinery/plumbing/update_icon()
	. = ..()
	cut_overlay("plumbing_working")
	cut_overlay("plumbing_connection")
	if(stat&NOPOWER)
		return
	if(anchored)
		add_overlay("plumbing_working")
	else
		add_overlay("plumbing_connection")

/obj/machinery/plumbing/power_change()
	. = ..()
	if(powered())
		stat &= ~NOPOWER
	else
		stat |= NOPOWER
	update_icon()

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
		return
	deploying = TRUE
	to_chat(user, "<span class='notice'>You start planting \the [src]...</span>")
	if(do_after(user, 50, target = src))
		to_chat(user, "<span class='notice'>You have activated \the [src].</span>")
		new result (get_turf(src))
		qdel(src)
	deploying = FALSE