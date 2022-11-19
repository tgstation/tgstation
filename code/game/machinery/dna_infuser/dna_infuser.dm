/obj/machinery/dna_infuser
	name = "\improper DNA infuser"
	desc = "A defunct genetics machine for merging foreign DNA with a subject's own."
	icon = 'icons/obj/machines/cloning.dmi'
	icon_state = "infuser"
	base_icon_state = "infuser"
	density = TRUE
	obj_flags = NO_BUILD // Becomes undense when the door is open
	circuit = /obj/item/circuitboard/machine/dna_infuser
	///currently infusing a vict- subject
	var/infusing = FALSE
	///what we're infusing with
	var/atom/movable/infusing_from

/obj/machinery/dna_infuser/examine(mob/user)
	. = ..()
	var/requires_text = "Requires "
	var/missing_parts = FALSE
	if(!occupant)
		missing_parts = TRUE
		requires_text += span_bold("a subject")
		if(!infusing_from)
			requires_text += " and "
	if(!infusing_from)
		missing_parts = TRUE
		requires_text += span_bold("an infusion source")
	if(missing_parts)
		requires_text += "."
		. += span_notice(requires_text)
	. += span_notice("You can drag a potential infusion source into the machine to add it.")

/obj/machinery/dna_infuser/interact(mob/user)
	toggle_open(user)

/obj/machinery/dna_infuser/update_icon_state()
	//out of order
	if(machine_stat & (NOPOWER | BROKEN))
		icon_state = base_icon_state
		return ..()
	//maintenance
	if((machine_stat & MAINT) || panel_open)
		icon_state = "[base_icon_state]_panel"
		return ..()
	//actively running
	if(infusing)
		icon_state = "[base_icon_state]_on"
		return ..()
	//open or not
	icon_state = "[base_icon_state][state_open ? "_open" : null]"
	return ..()

/obj/machinery/dna_infuser/proc/toggle_open(mob/user)
	if(panel_open)
		balloon_alert(user, "close panel first!")
		return

	if(state_open)
		close_machine()
		return

	else if(infusing)
		balloon_alert(user, "not while it's on!")
		return

	open_machine()

/obj/machinery/dna_infuser/attackby(obj/item/used, mob/user, params)
	if(infusing)
		return
	if(!occupant && default_deconstruction_screwdriver(user, icon_state, icon_state, used))//sent icon_state is irrelevant...
		update_appearance()//..since we're updating the icon here, since the scanner can be unpowered when opened/closed
		return
	if(default_pry_open(used))
		return
	if(default_deconstruction_crowbar(used))
		return
	return ..()

/obj/machinery/dna_infuser/MouseDrop_T(mob/target, mob/user)
	if(!isliving(target))
		return
	var/mob/living/living_target = target

	if(living_target.stat != DEAD || user.stat != CONSCIOUS || HAS_TRAIT(user, TRAIT_UI_BLOCKED) || !Adjacent(user) || !user.Adjacent(target) || !iscarbon(target) || !ISADVANCEDTOOLUSER(user))
		return

	infusing_from = living_target
	target.forceMove(infusing_from)
