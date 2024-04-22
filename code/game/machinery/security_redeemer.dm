/obj/machinery/sec_redeemer
	name = "Redeemer"
	desc = "A large crushing machine used to recycle small items inefficiently. There are lights on the side."
	icon = 'icons/obj/machines/recycling.dmi'
	icon_state = "grinder-o0"
	layer = ABOVE_ALL_MOB_LAYER
	plane = ABOVE_GAME_PLANE
	density = TRUE
	circuit = /obj/item/circuitboard/machine/redeemer


/obj/machinery/sec_redeemer/post_machine_initialize()
	. = ..()

	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)


/obj/machinery/sec_redeemer/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(!anchored)
		return
	if(border_dir == dir)
		return TRUE


/obj/machinery/sec_redeemer/proc/on_entered(datum/source, atom/movable/enterer, old_loc)
	SIGNAL_HANDLER

	grind(enterer)


/obj/machinery/sec_redeemer/proc/grind(mob/living/victim)
	use_energy(active_power_usage)
	audible_message(span_hear("You hear a loud squelchy grinding sound."))
	playsound(loc, 'sound/machines/juicer.ogg', 50, TRUE)

	victim.Paralyze(3)
	if(prob(10))
		INVOKE_ASYNC(victim, TYPE_PROC_REF(/mob/living, emote), "scream")

	var/offset = prob(50) ? -5 : 5
	animate(src, pixel_x = pixel_x + offset, time = 0.2, loop = 250)

	addtimer(CALLBACK(src, PROC_REF(vaporize), victim), 2 SECONDS)


/obj/machinery/sec_redeemer/proc/vaporize(mob/living/victim)
	DSsecurity.add_new_criminal(victim)
	log_combat(victim, occupant, "gibbed")
	victim.investigate_log("has been gibbed by [src].", INVESTIGATE_DEATHS)
	victim.death(TRUE)
	victim.ghostize()
	qdel(victim)
