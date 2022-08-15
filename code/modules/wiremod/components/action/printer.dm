/**
 * # Printer Component
 *
 * Allows for text strings to be printed on a paper. Requires a shell.
 */
/obj/item/circuit_component/printer
	display_name = "Printer"
	desc = "A component that prints a string input on a paper. Requires a shell and paper. \
		Attack with paper to load them in the circuit. Use in hand to dump the bottom-most paper."
	category = "Action"
	circuit_flags = CIRCUIT_FLAG_REFUSE_MODULE

	/// Prints stuff on the leftmost paper in the loaded_papers list.
	var/datum/port/input/print
	/// The selected font-family used when printing text on paper
	var/datum/port/input/option/typeface
	/// The RGB values of the color used when printing text on paper
	var/datum/port/input/text_color_red
	var/datum/port/input/text_color_green
	var/datum/port/input/text_color_blue
	/// Used to eject the leftmost paper on the loaded_papers list.
	var/datum/port/input/eject
	/// The signature that'll replace any %s and %sign used when printing text on paper.
	var/datum/port/input/signature

	/// The list of papers currently loaded on the component
	var/list/obj/item/paper/loaded_papers
	/// The maximum paper capacity of the component
	var/max_paper_capacity = 10

/obj/item/circuit_component/printer/populate_ports()
	print = add_input_port("Print", PORT_TYPE_STRING, trigger = .proc/print_on_paper)
	text_color_red = add_input_port("Color (Red)", PORT_TYPE_NUMBER, trigger = null, default = 0)
	text_color_green = add_input_port("Color (Green)", PORT_TYPE_NUMBER, trigger = null, default = 0)
	text_color_blue = add_input_port("Color (Blue)", PORT_TYPE_NUMBER, trigger = null, default = 0)
	signature = add_input_port("Signature", PORT_TYPE_STRING, trigger = null, default = "signature")
	eject = add_input_port("Eject", PORT_TYPE_SIGNAL, trigger = .proc/eject_paper, order = 2)

/obj/item/circuit_component/printer/populate_options()
	var/static/typeface_options = list(
		PRINTER_FONT,
		PEN_FONT,
		FOUNTAIN_PEN_FONT,
		CRAYON_FONT,
		"Impact",
		"Webdings",
	)
	typeface = add_option_port("Typeface", typeface_options, trigger = null)

/obj/item/circuit_component/printer/Destroy()
	QDEL_LIST(loaded_papers)
	return ..()

/obj/item/circuit_component/printer/add_to(obj/item/integrated_circuit/add_to)
	. = ..()
	if(HAS_TRAIT(add_to, TRAIT_COMPONENT_PRINTER))
		return FALSE
	ADD_TRAIT(add_to, TRAIT_COMPONENT_PRINTER, REF(src))

/obj/item/circuit_component/printer/removed_from(obj/item/integrated_circuit/removed_from)
	REMOVE_TRAIT(removed_from, TRAIT_COMPONENT_PRINTER, REF(src))
	return ..()

/obj/item/circuit_component/printer/register_shell(atom/movable/shell)
	RegisterSignal(shell, COMSIG_PARENT_ATTACKBY_SECONDARY, .proc/handle_secondary_attackby)
	RegisterSignal(shell, COMSIG_PARENT_EXAMINE, .proc/on_examine)

/obj/item/circuit_component/printer/unregister_shell(atom/movable/shell)
	UnregisterSignal(shell, list(COMSIG_PARENT_ATTACKBY_SECONDARY, COMSIG_PARENT_EXAMINE))

/obj/item/circuit_component/printer/get_ui_notices()
	. = ..()
	. += create_ui_notice("Papers Stored: [length(loaded_papers)]/[max_paper_capacity]", "orange", "info")

///Allows for paper to be loaded while inside the shell.
/obj/item/circuit_component/printer/proc/handle_secondary_attackby(atom/movable/shell, obj/item/item, mob/living/attacker)
	SIGNAL_HANDLER
	if(istype(item, /obj/item/paper))
		load_paper(item, attacker)
		return COMPONENT_SECONDARY_CANCEL_ATTACK_CHAIN

/obj/item/circuit_component/printer/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	examine_list += span_notice("It's a printer component installed in. Right-click with paper to reload it.")

/obj/item/circuit_component/printer/attackby(obj/item/item, mob/living/user, params)
	if(istype(item, /obj/item/paper))
		load_paper(item, user)
	else
		return ..()

/obj/item/circuit_component/printer/proc/load_paper(obj/item/paper/paper, mob/living/user)
	if(length(loaded_papers) >= max_paper_capacity)
		to_chat(user, span_warning("[src] can't hold any more paper."))
	else if(user.transferItemToLoc(paper, src))
		LAZYADD(loaded_papers, paper)
		to_chat(user, span_notice("You load [paper] in [src]."))
	else
		to_chat(user, span_warning("[paper] seems to be stuck to your hand."))

/obj/item/circuit_component/printer/attack_self(mob/living/user)
	. = ..()
	var/obj/item/paper/paper = loaded_papers?[1]
	if(paper)
		user.put_in_hands(paper)
		to_chat(user, span_notice("You remove [paper] from [src]."))

/obj/item/circuit_component/printer/Exited(atom/movable/movable)
	. = ..()
	if(movable in loaded_papers)
		LAZYREMOVE(loaded_papers, movable)

/obj/item/circuit_component/printer/pre_input_received(datum/port/input/port)
	if(port != print)
		return
	text_color_red.set_value(clamp(text_color_red.value, 0, 255))
	text_color_green.set_value(clamp(text_color_green.value, 0, 255))
	text_color_blue.set_value(clamp(text_color_blue.value, 0, 255))
	signature.set_value(reject_bad_text(signature.value, MAX_NAME_LEN, FALSE) || "signature")

/obj/item/circuit_component/printer/proc/print_on_paper(datum/port/input/port)
	if(!print.value)
		return
	var/obj/item/paper/paper = loaded_papers?[1]
	if(!paper)
		return
	paper.add_info(print.value, rgb(text_color_red, text_color_green, text_color_blue), typeface.value, signature.value)
	log_paper("Printer component wrote to [paper.name]: \"[print.value]\", authored by [parent.get_creator()].")

/obj/item/circuit_component/printer/proc/eject_paper(datum/port/input/port, list/return_values)
	var/obj/item/paper/paper = loaded_papers?[1]
	if(!paper)
		return
	playsound(src, "sound/machines/dotprinter.ogg", 30, TRUE)
	if(isliving(parent?.shell?.loc))
		var/mob/living/living_loc = parent.shell.loc
		living_loc.put_in_hands(paper)
	else
		paper.forceMove(drop_location())
