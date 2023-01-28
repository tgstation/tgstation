/* Pens!
 * Contains:
 * Pens
 * Sleepy Pens
 * Parapens
 * Edaggers
 */


/*
 * Pens
 */
/obj/item/pen
	desc = "It's a normal black ink pen."
	name = "pen"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "pen"
	inhand_icon_state = "pen"
	worn_icon_state = "pen"
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_EARS
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	custom_materials = list(/datum/material/iron=10)
	pressure_resistance = 2
	grind_results = list(/datum/reagent/iron = 2, /datum/reagent/iodine = 1)
	var/colour = "#000000" //what colour the ink is!
	var/degrees = 0
	var/font = PEN_FONT
	var/requires_gravity = TRUE // can you use this to write in zero-g
	embedding = list(embed_chance = 50)
	sharpness = SHARP_POINTY

/obj/item/pen/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is scribbling numbers all over [user.p_them()]self with [src]! It looks like [user.p_theyre()] trying to commit sudoku..."))
	return BRUTELOSS

/obj/item/pen/blue
	desc = "It's a normal blue ink pen."
	icon_state = "pen_blue"
	colour = "#0000FF"

/obj/item/pen/red
	desc = "It's a normal red ink pen."
	icon_state = "pen_red"
	colour = "#FF0000"
	throw_speed = 4 // red ones go faster (in this case, fast enough to embed!)

/obj/item/pen/invisible
	desc = "It's an invisible pen marker."
	icon_state = "pen"
	colour = "#FFFFFF"

/obj/item/pen/fourcolor
	desc = "It's a fancy four-color ink pen, set to black."
	name = "four-color pen"
	icon_state = "pen_4color"
	colour = "#000000"

/obj/item/pen/fourcolor/attack_self(mob/living/carbon/user)
	. = ..()
	var/chosen_color = "black"
	switch(colour)
		if("#000000")
			colour = "#FF0000"
			chosen_color = "red"
			throw_speed++
		if("#FF0000")
			colour = "#00FF00"
			chosen_color = "green"
			throw_speed = initial(throw_speed)
		if("#00FF00")
			colour = "#0000FF"
			chosen_color = "blue"
		else
			colour = "#000000"
	to_chat(user, span_notice("\The [src] will now write in [chosen_color]."))
	desc = "It's a fancy four-color ink pen, set to [chosen_color]."

/obj/item/pen/fountain
	name = "fountain pen"
	desc = "It's a common fountain pen, with a faux wood body. Rumored to work in zero gravity situations."
	icon_state = "pen-fountain"
	font = FOUNTAIN_PEN_FONT
	requires_gravity = FALSE // fancy spess pens

/obj/item/pen/charcoal
	name = "charcoal stylus"
	desc = "It's just a wooden stick with some compressed ash on the end. At least it can write."
	icon_state = "pen-charcoal"
	colour = "#696969"
	font = CHARCOAL_FONT
	custom_materials = null
	grind_results = list(/datum/reagent/ash = 5, /datum/reagent/cellulose = 10)
	requires_gravity = FALSE // this is technically a pencil

/datum/crafting_recipe/charcoal_stylus
	name = "Charcoal Stylus"
	result = /obj/item/pen/charcoal
	reqs = list(/obj/item/stack/sheet/mineral/wood = 1, /datum/reagent/ash = 30)
	time = 3 SECONDS
	category = CAT_TOOLS

/obj/item/pen/fountain/captain
	name = "captain's fountain pen"
	desc = "It's an expensive Oak fountain pen. The nib is quite sharp."
	icon_state = "pen-fountain-o"
	force = 5
	throwforce = 5
	throw_speed = 4
	colour = "#DC143C"
	custom_materials = list(/datum/material/gold = 750)
	sharpness = SHARP_EDGED
	resistance_flags = FIRE_PROOF
	unique_reskin = list("Oak" = "pen-fountain-o",
						"Gold" = "pen-fountain-g",
						"Rosewood" = "pen-fountain-r",
						"Black and Silver" = "pen-fountain-b",
						"Command Blue" = "pen-fountain-cb"
						)
	embedding = list("embed_chance" = 75)

/obj/item/pen/fountain/captain/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/butchering, \
	speed = 20 SECONDS, \
	effectiveness = 115, \
	)
	//the pen is mightier than the sword

/obj/item/pen/fountain/captain/reskin_obj(mob/M)
	..()
	if(current_skin)
		desc = "It's an expensive [current_skin] fountain pen. The nib is quite sharp."

/obj/item/pen/attack_self(mob/living/carbon/user)
	. = ..()
	if(.)
		return
	if(loc != user)
		to_chat(user, span_warning("You must be holding the pen to continue!"))
		return
	var/deg = tgui_input_number(user, "What angle would you like to rotate the pen head to? (0-360)", "Rotate Pen Head", max_value = 360)
	if(isnull(deg) || QDELETED(user) || QDELETED(src) || !user.canUseTopic(src, be_close = TRUE, no_dexterity = FALSE, no_tk = TRUE) || loc != user)
		return
	degrees = deg
	to_chat(user, span_notice("You rotate the top of the pen to [deg] degrees."))
	SEND_SIGNAL(src, COMSIG_PEN_ROTATED, deg, user)

/obj/item/pen/attack(mob/living/M, mob/user, params)
	if(force) // If the pen has a force value, call the normal attack procs. Used for e-daggers and captain's pen mostly.
		return ..()
	if(!M.try_inject(user, injection_flags = INJECT_TRY_SHOW_ERROR_MESSAGE))
		return FALSE
	to_chat(user, span_warning("You stab [M] with the pen."))
	to_chat(M, span_danger("You feel a tiny prick!"))
	log_combat(user, M, "stabbed", src)
	return TRUE

/obj/item/pen/afterattack(obj/O, mob/living/user, proximity)
	. = ..()

	if (!proximity)
		return .

	. |= AFTERATTACK_PROCESSED_ITEM

	//Changing name/description of items. Only works if they have the UNIQUE_RENAME object flag set
	if(isobj(O) && (O.obj_flags & UNIQUE_RENAME))
		var/penchoice = tgui_input_list(user, "What would you like to edit?", "Pen Setting", list("Rename", "Description", "Reset"))
		if(QDELETED(O) || !user.canUseTopic(O, be_close = TRUE))
			return
		if(penchoice == "Rename")
			var/input = tgui_input_text(user, "What do you want to name [O]?", "Object Name", "[O.name]", MAX_NAME_LEN)
			var/oldname = O.name
			if(QDELETED(O) || !user.canUseTopic(O, be_close = TRUE))
				return
			if(input == oldname || !input)
				to_chat(user, span_notice("You changed [O] to... well... [O]."))
			else
				O.AddComponent(/datum/component/rename, input, O.desc)
				var/datum/component/label/label = O.GetComponent(/datum/component/label)
				if(label)
					label.remove_label()
					label.apply_label()
				to_chat(user, span_notice("You have successfully renamed \the [oldname] to [O]."))
				O.renamedByPlayer = TRUE

		if(penchoice == "Description")
			var/input = tgui_input_text(user, "Describe [O]", "Description", "[O.desc]", 140)
			var/olddesc = O.desc
			if(QDELETED(O) || !user.canUseTopic(O, be_close = TRUE))
				return
			if(input == olddesc || !input)
				to_chat(user, span_notice("You decide against changing [O]'s description."))
			else
				O.AddComponent(/datum/component/rename, O.name, input)
				to_chat(user, span_notice("You have successfully changed [O]'s description."))
				O.renamedByPlayer = TRUE

		if(penchoice == "Reset")
			if(QDELETED(O) || !user.canUseTopic(O, be_close = TRUE))
				return

			qdel(O.GetComponent(/datum/component/rename))

			//reapply any label to name
			var/datum/component/label/label = O.GetComponent(/datum/component/label)
			if(label)
				label.remove_label()
				label.apply_label()

			to_chat(user, span_notice("You have successfully reset [O]'s name and description."))
			O.renamedByPlayer = FALSE

/obj/item/pen/get_writing_implement_details()
	return list(
		interaction_mode = MODE_WRITING,
		font = font,
		color = colour,
		use_bold = FALSE,
	)

/*
 * Sleepypens
 */

/obj/item/pen/sleepy/attack(mob/living/M, mob/user, params)
	. = ..()
	if(!.)
		return
	if(!reagents.total_volume)
		return
	if(!M.reagents)
		return
	reagents.trans_to(M, reagents.total_volume, transfered_by = user, methods = INJECT)


/obj/item/pen/sleepy/Initialize(mapload)
	. = ..()
	create_reagents(45, OPENCONTAINER)
	reagents.add_reagent(/datum/reagent/toxin/chloralhydrate, 20)
	reagents.add_reagent(/datum/reagent/toxin/mutetoxin, 15)
	reagents.add_reagent(/datum/reagent/toxin/staminatoxin, 10)

/*
 * (Alan) Edaggers
 */
/obj/item/pen/edagger
	attack_verb_continuous = list("slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "cuts") //these won't show up if the pen is off
	attack_verb_simple = list("slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "cut")
	sharpness = SHARP_POINTY
	armour_penetration = 20
	bare_wound_bonus = 10
	item_flags = NO_BLOOD_ON_ITEM
	light_system = MOVABLE_LIGHT
	light_range = 1.5
	light_power = 0.75
	light_color = COLOR_SOFT_RED
	light_on = FALSE
	/// The real name of our item when extended.
	var/hidden_name = "energy dagger"
	/// The real desc of our item when extended.
	var/hidden_desc = "It's a normal black ink pe- Wait. That's a thing used to stab people!"
	/// The real icons used when extended.
	var/hidden_icon = "edagger"
	/// Whether or pen is extended
	var/extended = FALSE

/obj/item/pen/edagger/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/butchering, \
	speed = 6 SECONDS, \
	butcher_sound = 'sound/weapons/blade1.ogg', \
	)
	AddComponent(/datum/component/transforming, \
		force_on = 18, \
		throwforce_on = 35, \
		throw_speed_on = 4, \
		sharpness_on = SHARP_EDGED, \
		w_class_on = WEIGHT_CLASS_NORMAL)
	RegisterSignal(src, COMSIG_TRANSFORMING_ON_TRANSFORM, PROC_REF(on_transform))
	RegisterSignal(src, COMSIG_DETECTIVE_SCANNED, PROC_REF(on_scan))

/obj/item/pen/edagger/suicide_act(mob/living/user)
	if(extended)
		user.visible_message(span_suicide("[user] forcefully rams the pen into their mouth!"))
	else
		user.visible_message(span_suicide("[user] is holding a pen up to their mouth! It looks like [user.p_theyre()] trying to commit suicide!"))
		attack_self(user)
	return BRUTELOSS

/*
 * Signal proc for [COMSIG_TRANSFORMING_ON_TRANSFORM].
 *
 * Handles swapping their icon files to edagger related icon files -
 * as they're supposed to look like a normal pen.
 */
/obj/item/pen/edagger/proc/on_transform(obj/item/source, mob/user, active)
	SIGNAL_HANDLER

	extended = active
	if(active)
		name = hidden_name
		desc = hidden_desc
		icon_state = hidden_icon
		inhand_icon_state = hidden_icon
		lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
		righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
		embedding = list(embed_chance = 100) // Rule of cool
	else
		name = initial(name)
		desc = initial(desc)
		icon_state = initial(icon_state)
		inhand_icon_state = initial(inhand_icon_state)
		lefthand_file = initial(lefthand_file)
		righthand_file = initial(righthand_file)
		embedding = list(embed_chance = EMBED_CHANCE)

	updateEmbedding()
	balloon_alert(user, "[hidden_name] [active ? "active":"concealed"]")
	playsound(user ? user : src, active ? 'sound/weapons/saberon.ogg' : 'sound/weapons/saberoff.ogg', 5, TRUE)
	set_light_on(active)
	return COMPONENT_NO_DEFAULT_MESSAGE

/obj/item/pen/edagger/proc/on_scan(datum/source, mob/user, list/extra_data)
	SIGNAL_HANDLER
	LAZYADD(extra_data[DETSCAN_CATEGORY_ILLEGAL], "Hard-light generator detected.")

/obj/item/pen/survival
	name = "survival pen"
	desc = "The latest in portable survival technology, this pen was designed as a miniature diamond pickaxe. Watchers find them very desirable for their diamond exterior."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "digging_pen"
	inhand_icon_state = "pen"
	worn_icon_state = "pen"
	force = 3
	w_class = WEIGHT_CLASS_TINY
	custom_materials = list(/datum/material/iron=10, /datum/material/diamond=100, /datum/material/titanium = 10)
	pressure_resistance = 2
	grind_results = list(/datum/reagent/iron = 2, /datum/reagent/iodine = 1)
	tool_behaviour = TOOL_MINING //For the classic "digging out of prison with a spoon but you're in space so this analogy doesn't work" situation.
	toolspeed = 10 //You will never willingly choose to use one of these over a shovel.
	font = FOUNTAIN_PEN_FONT
	colour = "#0000FF"

/obj/item/pen/destroyer
	name = "Fine Tipped Pen"
	desc = "A pen with an infinitly sharpened tip. Capable of striking the weakest point of a strucutre or robot and annihilating it instantly. Good at putting holes in people too."
	force = 5
	wound_bonus = 100
	demolition_mod = 9000

// screwdriver pen!

/obj/item/pen/screwdriver
	desc = "A pen with an extendable screwdriver tip. This one has a yellow cap."
	icon_state = "pendriver"
	toolspeed = 1.2  // gotta have some downside
	/// whether the pen is extended
	var/extended = FALSE

/obj/item/pen/screwdriver/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/transforming, \
		throwforce_on = 5, \
		w_class_on = WEIGHT_CLASS_SMALL, \
		sharpness_on = TRUE)

	RegisterSignal(src, COMSIG_TRANSFORMING_ON_TRANSFORM, PROC_REF(toggle_screwdriver))
	AddElement(/datum/element/update_icon_updates_onmob)


/obj/item/pen/screwdriver/vv_edit_var(var_name, var_value)
	if(var_name == NAMEOF(src, extended))
		if(var_value != extended)
			var/datum/component/transforming/transforming_comp = GetComponent(/datum/component/transforming)
			transforming_comp.on_attack_self(src)
			datum_flags |= DF_VAR_EDITED
			return
	return ..()

/obj/item/pen/screwdriver/proc/toggle_screwdriver(obj/item/source, mob/user, active)
	SIGNAL_HANDLER
	extended = active
	if(user)
		balloon_alert(user, "[extended ? "extended" : "retracted"]!")

	if(!extended)
		tool_behaviour = initial(tool_behaviour)
		RemoveElement(/datum/element/eyestab)
	else
		tool_behaviour = TOOL_SCREWDRIVER
		AddElement(/datum/element/eyestab)

	update_appearance(UPDATE_ICON)
	return COMPONENT_NO_DEFAULT_MESSAGE

/obj/item/pen/screwdriver/update_icon_state()
	. = ..()
	icon_state = "[initial(icon_state)][extended ? "_out":null]"
	inhand_icon_state = initial(inhand_icon_state) //since transforming component switches the icon.
