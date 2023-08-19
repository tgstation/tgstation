/obj/item/implant/abductor
	name = "recall implant"
	desc = "Returns you to the mothership."
	icon = 'icons/obj/antags/abductor.dmi'
	icon_state = "implant"
	var/obj/machinery/abductor/pad/home
	var/cooldown = 60 SECONDS
	var/on_cooldown

/obj/item/implant/abductor/activate()
	. = ..()
	if(on_cooldown)
		to_chat(imp_in, span_warning("You must wait [timeleft(on_cooldown)*0.1] seconds to use [src] again!"))
		return

	if(isnull(home) && !link_pad())
		imp_in.balloon_alert(imp_in, "no teleport pads detected!")
		return

	home.Retrieve(imp_in)
	on_cooldown = addtimer(VARSET_CALLBACK(src, on_cooldown, null), cooldown , TIMER_STOPPABLE)

/obj/item/implant/abductor/implant(mob/living/target, mob/user, silent = FALSE, force = FALSE)
	if(!..())
		return FALSE

	link_pad()
	return TRUE

/**
 * Manages the process of linking a recall implant to an abductor pad
 *
 * Attempts to link the abductor implant to an abductor console. First, it tries to do so through the abductor's antag datum
 * If not, a random teleport pad will be defaulted to. Returns TRUE if a home is found, and FALSE is one somehow is not.
 */

/obj/item/implant/abductor/proc/link_pad()
	if(home)
		return TRUE

	var/obj/machinery/abductor/console/console
	if(ishuman(imp_in))
		var/datum/antagonist/abductor/new_abductor = imp_in.mind.has_antag_datum(/datum/antagonist/abductor)
		if(new_abductor)
			console = get_abductor_console(new_abductor.team.team_number)
			if(!console)
				WARNING("Attempted to link [name] within [imp_in] to a pad using their abductor antagonist datum, however no associated machinery exists for their team.")
				return FALSE
			home = console.pad

	if(home)
		return TRUE

	else //If we still cannot find a home associated with our team, we just pick a random pad and make it our own.
		var/list/consoles = list()
		for(var/obj/machinery/abductor/console/found_console as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/abductor/console))
			consoles += found_console
		console = pick(consoles)
		if(console)
			home = console.pad

	if(home)
		return TRUE

	stack_trace("[name] within [imp_in] failed to find any abductor machinery to connect to.")

	return FALSE //We somehow couldn't find any pads (maybe they're not loaded in yet)
