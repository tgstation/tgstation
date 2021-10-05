/**
 * # Printer Component
 *
 * Allows for text strings to be written on a paper. Requires a shell.
 */
/obj/item/circuit_component/writer
	display_name = "Writer"
	desc = "A component that writes a string input on a paper. Requires a shell, pen and paper. \
		Attack with a pen or paper to load them in the circuit. Use in hand to dump the bottom-most paper. \
		Attack with an empty while in hand to remove the pen."

	///Used to write on the leftmost paper on the loaded_papers list.
	var/datum/port/input/write
	///Used to eject the leftmost paper on the loaded_papers list.
	var/datum/port/input/eject
	///A signature the component uses for signing papers.
	var/datum/port/input/signature
	///Output a paper atom reference when eject is triggered.
	var/datum/port/output/ejected_paper

	/// The list of papers currently loaded on the component
	var/list/obj/item/paper/loaded_papers
	/// The maximum paper capacity of the component
	var/max_paper_capacity = 10
	/// Originally intended to be a toner. But they aren't easy to come by without cargo or by exploiting airlock painters.
	var/obj/item/pen/internal_pen

/obj/item/circuit_component/writer/populate_ports()
	write = add_input_port("Write", PORT_TYPE_STRING, trigger = .proc/write_on_paper)
	eject = add_input_port("Eject", PORT_TYPE_SIGNAL, trigger = .proc/eject_paper)
	signature = add_input_port("Signature", PORT_TYPE_STRING, trigger = null)
	ejected_paper = add_output_port("Ejected Paper", PORT_TYPE_ATOM)

/obj/item/circuit_component/writer/Destroy()
	write = null
	eject = null
	signature = null
	ejected_paper = null

/obj/item/circuit_component/writer/register_shell(atom/movable/shell)
	RegisterSignal(shell, COMSIG_PARENT_ATTACKBY, .proc/handle_attack_by)

/obj/item/circuit_component/writer/unregister_shell(atom/movable/shell)
	UnregisterSignal(shell, COMSIG_PARENT_ATTACKBY)

///Allows for paper to be loaded while inside the shell.
/obj/item/circuit_component/writer/proc/handle_attack_by(atom/movable/shell, obj/item/item, mob/living/attacker)
	SIGNAL_HANDLER
	if(istype(item, /obj/item/paper))
		load_paper(item, attacker)
		return COMPONENT_NO_AFTERATTACK
	if(istype(item, /obj/item/pen))
		load_pen(item, attacker)
		return COMPONENT_NO_AFTERATTACK

/obj/item/circuit_component/writer/attackby(obj/item/item, mob/living/user, params)
	if(istype(item, /obj/item/paper))
		load_paper(item, user)
	else if(istype(item, /obj/item/pen))
		load_pen(item, user)
	else
		return ..()

/obj/item/circuit_component/writer/proc/load_paper(obj/item/paper/paper, mob/living/user)
	if(length(loaded_papers) >= max_paper_capacity)
		to_chat(user, span_warning("[src] can't hold any more paper."))
	else if(user.transferItemToLoc(paper, src))
		LAZYREMOVE(loaded_papers, paper)
		to_chat(user, span_notice("You load [paper] in [src]."))
	else
		to_chat(user, span_warning("[paper] seems to be stuck to your hand."))

/obj/item/circuit_component/writer/attack_self(mob/living/user)
	. = ..()
	var/obj/item/paper/paper = loaded_papers?[1]
	if(paper)
		user.put_in_hands(paper)
		to_chat(user, span_notice("You remove [paper] from [src]."))

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/circuit_component/writer/attack_hand(mob/living/user, list/modifiers)
	if(user.is_holding(src) && internal_pen)
		to_chat(user, span_notice("You remove [internal_pen] from [src]."))
		user.put_in_hands(internal_pen)
		return
	return ..()

/obj/item/circuit_component/writer/proc/load_pen(obj/item/pen/pen, mob/living/user)
	if(user.transferItemToLoc(pen, src))
		if(internal_pen)
			to_chat(user, span_notice("You switch the internal pen of [src] with [pen]."))
			internal_pen.forceMove(drop_location())
		else
			to_chat(user, span_notice("You load [pen] in [src] as its internal pen."))
		internal_pen = pen
	else
		to_chat(user, span_warning("[pen] seems to be stuck to your hand."))

/obj/item/circuit_component/writer/Exited(atom/movable/movable)
	. = ..()
	if(movable == internal_pen)
		internal_pen = null
	else if(movable in loaded_papers)
		LAZYREMOVE(loaded_papers, movable)

/obj/item/circuit_component/writer/proc/write_on_paper(datum/port/input/port, list/return_values)
	if(!!internal_pen)
		return
	var/trimmed_text = trim(write.value)
	if(!trimmed_text) // It's whitespaces all along.
		return
	//Enforces a newline each time this is triggered
	trimmed_text += (copytext_char(write.value, -2) == "\n") ? " \n" : "\n \n"
	var/obj/item/paper/paper = loaded_papers?[1]
	if(!paper)
		return
	var/output = parsemarkdown_paper(trimmed_text, FALSE, internal_pen.colour, internal_pen.font, FALSE, signature || "N/A", paper)
	paper.info += SET_FONT_TEXT(output, internal_pen.font, internal_pen.colour, FALSE)

	////TODO MARKDOWN PASTA FROM JS

#define SET_FONT_TEXT(text, font, color, bold) \
	"<span style=\"color:'[color]';font-family:'[font]';[bold ? "font-weight: bold;" : ""]\">[text]</span>"

// hardset font size for input fields on the tgui
#define INPUT_FIELD_FONTSIZE 12

// placeholder
#define HOW_WIDE_UNDERSCORE 4

GLOBAL_LIST(input_field_parameters_cache)
/proc/parsemarkdown_paper(text, limited = FALSE, color, font, trim = TRUE, signature, obj/item/paper/paper)
	// check if we are adding to paper, if not
	// we still have to check if someone entered something
	// into the fields
	text = trim(text)
	if (!text)
		return
	// First, we sanitize the text of html
//	text = sanitizeText(text)
	if(!limited) // Second we replace the [__] with fields and %s with the user's real name.
		var/static/regex/sign_regex =  regex("%s(?:ign)?(?=\\s|$)?", "igm")
		text = sign_regex.Replace(text, sign_regex, signature ? SET_FONT_TEXT(signature, "Times New Roman", color, TRUE) : "")
		var/static/regex/field_regex = regex("\[(_+)\]", "g")
		if(paper)
			GLOB.input_field_parameters_cache = list("counter" = paper.field_counter, "color" = color, "font" = font)
		text = field_regex.Replace(text, field_regex, paper ? /proc/create_input_field : "")
		if(paper)
			paper.field_counter = GLOB.input_field_parameters_cache["counter"]
		GLOB.input_field_parameters_cache = null

	// Third, parse the text using markup
// const formatted_text = run_marked_default(fielded_text.text)

	return text

/proc/create_input_field(match, underscores)
	var/list/params = GLOB.input_field_parameters_cache
	var/length = length(underscores)
	var/width = "[HOW_WIDE_UNDERSCORE * length]px"
	. = "\[<input type=\"text\" style=\"font:'[INPUT_FIELD_FONTSIZE]x [params["font"]]';"
	. += "color:'[params["color"]]';min-width:[width];max-width:[width];\" "
	. += "id=\"["paperfield_[params["counter"]]"]\" maxlength=[length] size=[length] />]"
	GLOB.input_field_parameters_cache["counter"] += 1

/obj/item/circuit_component/writer/proc/eject_paper(datum/port/input/port, list/return_values)
	var/obj/item/paper/paper = loaded_papers?[1]
	if(!paper)
		return
	if(isliving(parent?.shell?.loc))
		var/mob/living/living_loc = parent.shell.loc
		living_loc.put_in_hands(paper)
	else
		paper.forceMove(drop_location())
		ejected_paper.set_output(paper)
