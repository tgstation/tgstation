/obj/item/implant/abductor
	name = "recall implant"
	desc = "Returns you to the mothership."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "implant"
	var/obj/machinery/abductor/pad/home
	var/cooldown = 60 SECONDS
	var/on_cooldown

/obj/item/implant/abductor/activate()
	. = ..()
	if(on_cooldown)
		to_chat(imp_in, span_warning("You must wait [timeleft(on_cooldown)*0.1] seconds to use [src] again!"))
		return

	if(!home)
		if(!link_pad(imp_in))
			imp_in.balloon_alert(imp_in, "no teleport pads detected!")
			return

	home.Retrieve(imp_in)
	on_cooldown = addtimer(VARSET_CALLBACK(src, on_cooldown, null), cooldown , TIMER_STOPPABLE)

/obj/item/implant/abductor/implant(mob/living/target, mob/user, silent = FALSE, force = FALSE)
	if(..())
		link_pad(target)
		return TRUE

/obj/item/implant/abductor/proc/link_pad(mob/living/mob_to_link)
	var/obj/machinery/abductor/console/console
	if(ishuman(mob_to_link))
		var/datum/antagonist/abductor/A = mob_to_link.mind.has_antag_datum(/datum/antagonist/abductor)
		if(A)
			console = get_abductor_console(A.team.team_number)
			if(!console)
				WARNING("Attempted to link [name] within [mob_to_link] to a pad using their abductor antagonist datum, however no associated machinery exists for their team.")
				return FALSE
			home = console.pad

	if(!home) //If we still cannot find a home associated with our team, we just pick a random pad and make it our own.
		var/list/consoles = list()
		for(var/obj/machinery/abductor/console/C in GLOB.machines)
			consoles += C
		console = pick(consoles)
		if(console)
			home = console.pad

	if(home)
		return TRUE

	return FALSE //We somehow couldn't find any pads (maybe they're not loaded in yet)
