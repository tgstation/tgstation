/**
  * # Destructive scanner
  *
  * Placed machine that handles destructive experiments (but can also do the normal ones)
  */
/obj/machinery/destructive_scanner
	name = "Experi-Scanner"
	desc = "A handheld scanner used for completing the many experiments of modern science."
	icon = 'icons/obj/machines/experisci.dmi'
	icon_state = "tube_closed"
	var/scanning = FALSE

/obj/machinery/destructive_scanner/Initialize()
	. = ..()
	AddComponent(/datum/component/experiment_handler, \
		allowed_experiments = list(/datum/experiment/scanning),\
		config_mode = EXPERIMENT_CONFIG_ALTCLICK)


///Activates the machine; checks if it can actually scan, then starts.
/obj/machinery/destructive_scanner/proc/activate()
	var/atom/L = drop_location()
	var/agressive = FALSE
	for(var/mob/living/living_mob in L)
		if(!(obj_flags & EMAGGED) && ishuman(living_mob)) //Can only kill humans when emaggedishuman(living_mob))
			playsound(src, 'sound/machines/buzz-sigh.ogg', 25)
			say("Cannot scan with humans inside.")
			return
		agressive = TRUE
	start_closing(agressive)

///Closes the machine to kidnap everything in the turf into it.
/obj/machinery/destructive_scanner/proc/start_closing(var/agressive)
	if(scanning)
		return
	var/atom/L = drop_location()
	for(var/atom/movable/AM in L)
		AM.forceMove(src)
	flick("tube_down", src)
	scanning = TRUE
	update_icon()
	playsound(src, 'sound/machines/destructive_scanner/TubeDown.ogg', 100)
	addtimer(CALLBACK(src, .proc/start_scanning, agressive), 1.2 SECONDS)

///Starts scanning the fancy scanning effects
/obj/machinery/destructive_scanner/proc/start_scanning(var/agressive)

	if(agressive)
		playsound(src, 'sound/machines/destructive_scanner/ScanDangerous.ogg', 100, extrarange = 5)
	else
		playsound(src, 'sound/machines/destructive_scanner/ScanSafe.ogg', 100)
	addtimer(CALLBACK(src, .proc/finish_scanning, agressive), 6 SECONDS)


///Performs the actual scan, happens once the tube effects are done
/obj/machinery/destructive_scanner/proc/finish_scanning(var/agressive)
	flick("tube_up", src)
	scanning = FALSE
	update_icon()
	playsound(src, 'sound/machines/destructive_scanner/TubeUp.ogg', 100)
	addtimer(CALLBACK(src, .proc/open, agressive), 1.2 SECONDS)

///Opens the machine to let out any contents. If the scan had mobs it'll gib them.
/obj/machinery/destructive_scanner/proc/open(var/agressive)
	var/turf/this_turf = get_turf(src)
	var/list/scanned_atoms = list()

	for(var/atom/movable/movable_atom in contents)
		if(movable_atom in component_parts)
			continue
		scanned_atoms += movable_atom
		movable_atom.forceMove(this_turf)



	SEND_SIGNAL(src, COMSIG_MACHINERY_DESTRUCTIVE_SCAN, scanned_atoms)



/obj/machinery/destructive_scanner/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	obj_flags |= EMAGGED
	playsound(src, "sparks", 75, TRUE, SILENCED_SOUND_EXTRARANGE)
	to_chat(user, "<span class='notice'>You use the cryptographic sequencer on [src].</span>")

/obj/machinery/destructive_scanner/update_icon_state()
	. = ..()
	if(scanning)
		icon_state = "tube_on"
	else
		icon_state = "tube_open"
