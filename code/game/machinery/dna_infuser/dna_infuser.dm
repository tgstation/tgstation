/// how long it takes to infuse
#define INFUSING_TIME 4 SECONDS
/// we throw in a scream along the way.
#define SCREAM_TIME 3 SECONDS

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

/obj/machinery/dna_infuser/Initialize(mapload)
	. = ..()
	occupant_typecache = typecacheof(/mob/living/carbon/human)

/obj/machinery/dna_infuser/examine(mob/user)
	. = ..()
	var/requires_text = "Requires "
	var/missing_parts = FALSE
	if(!occupant)
		missing_parts = TRUE
		requires_text += span_bold("a subject")
		if(!infusing_from)
			requires_text += " and "
	else
		requires_text += span_bold("[src] reports \"[occupant]\" is inside the infusion chamber.")
	if(!infusing_from)
		missing_parts = TRUE
		requires_text += span_bold("an infusion source")
	else
		. += span_notice("[infusing_from] is in the infusion slot.")
	if(missing_parts)
		requires_text += "."
		. += span_notice(requires_text)
	. += span_notice("You can drag a potential infusion source into the machine to add it.")
	. += span_notice("Alt-click to eject the infusion source, if one is inside.")

/obj/machinery/dna_infuser/interact(mob/user)
	if(occupant && infusing_from)
		start_infuse()
		return
	toggle_open(user)

/obj/machinery/dna_infuser/proc/start_infuse()
	visible_message(span_notice("[src] hums to life, beginning the infusion process!"))
	to_chat(occupant, span_danger("A small trickle of pain"))
	infusing = TRUE
	Shake(5, 5, INFUSING_TIME)
	addtimer(CALLBACK(occupant, TYPE_PROC_REF(/mob, emote), "scream"), INFUSING_TIME - 1 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(end_infuse)), INFUSING_TIME)
	update_appearance()

/obj/machinery/dna_infuser/proc/end_infuse()
	infuse_organ(occupant)
	playsound(src, 'sound/machines/microwave/microwave-end.ogg', 100, FALSE)
	toggle_open()
	update_appearance()

/obj/machinery/dna_infuser/proc/infuse_organ(mob/living/carbon/human/target)
	if(!ishuman(target))
		//already filters humans from entering, but you know, just in case.
		return
	var/datum/infuser_entry/found_entry
	for(var/datum/infuser_entry/entry as anything in GLOB.infuser_entries)
		if(is_type_in_list(infusing_from, entry.input_obj_or_mob))
			found_entry = entry
			break
	if(!found_entry)
		//no valid recipe, so you get a fly mutation
		found_entry = GLOB.infuser_entries[1]
	to_chat(target, span_danger("Little needles repeatedly prick you! And with each prick, you feel yourself becoming more... [found_entry.infusion_desc]?"))
	target.take_overall_damage(10)

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
		if(user)
			balloon_alert(user, "close panel first!")
		return

	if(state_open)
		close_machine()
		return

	else if(infusing)
		if(user)
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

/obj/machinery/dna_infuser/MouseDrop_T(atom/movable/target, mob/user)
	if(user.stat != CONSCIOUS || HAS_TRAIT(user, TRAIT_UI_BLOCKED) || !Adjacent(user) || !user.Adjacent(target) || !ISADVANCEDTOOLUSER(user))
		return
	if(infusing_from)
		balloon_alert(user, "empty the machine first!")
		return
	if(isliving(target))
		var/mob/living/living_target = target
		if(living_target.stat != DEAD)
			balloon_alert(user, "only dead creatures!")
			return
		infusing_from = living_target
	else
		infusing_from = target
	infusing_from.forceMove(src)

/obj/machinery/dna_infuser/AltClick(mob/user)
	. = ..()
	if(!infusing_from)
		balloon_alert(user, "no sample to eject!")
		return
	balloon_alert(user, "ejected sample")
	infusing_from.forceMove(get_turf(src))
	infusing_from = null

#undef INFUSING_TIME
