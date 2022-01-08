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
	atom_size = ITEM_SIZE_TINY
	throw_speed = 3
	throw_range = 7
	custom_materials = list(/datum/material/iron=10)
	pressure_resistance = 2
	grind_results = list(/datum/reagent/iron = 2, /datum/reagent/iodine = 1)
	var/colour = "black" //what colour the ink is!
	var/degrees = 0
	var/font = PEN_FONT
	embedding = list(embed_chance = 50)
	sharpness = SHARP_POINTY

/obj/item/pen/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] is scribbling numbers all over [user.p_them()]self with [src]! It looks like [user.p_theyre()] trying to commit sudoku..."))
	return(BRUTELOSS)

/obj/item/pen/blue
	desc = "It's a normal blue ink pen."
	icon_state = "pen_blue"
	colour = "blue"

/obj/item/pen/red
	desc = "It's a normal red ink pen."
	icon_state = "pen_red"
	colour = "red"
	throw_speed = 4 // red ones go faster (in this case, fast enough to embed!)

/obj/item/pen/invisible
	desc = "It's an invisible pen marker."
	icon_state = "pen"
	colour = "white"

/obj/item/pen/fourcolor
	desc = "It's a fancy four-color ink pen, set to black."
	name = "four-color pen"
	icon_state = "pen_4color"
	colour = "black"

/obj/item/pen/fourcolor/attack_self(mob/living/carbon/user)
	switch(colour)
		if("black")
			colour = "red"
			throw_speed++
		if("red")
			colour = "green"
			throw_speed = initial(throw_speed)
		if("green")
			colour = "blue"
		else
			colour = "black"
	to_chat(user, span_notice("\The [src] will now write in [colour]."))
	desc = "It's a fancy four-color ink pen, set to [colour]."

/obj/item/pen/fountain
	name = "fountain pen"
	desc = "It's a common fountain pen, with a faux wood body."
	icon_state = "pen-fountain"
	font = FOUNTAIN_PEN_FONT

/obj/item/pen/charcoal
	name = "charcoal stylus"
	desc = "It's just a wooden stick with some compressed ash on the end. At least it can write."
	icon_state = "pen-charcoal"
	colour = "dimgray"
	font = CHARCOAL_FONT
	custom_materials = null
	grind_results = list(/datum/reagent/ash = 5, /datum/reagent/cellulose = 10)

/datum/crafting_recipe/charcoal_stylus
	name = "Charcoal Stylus"
	result = /obj/item/pen/charcoal
	reqs = list(/obj/item/stack/sheet/mineral/wood = 1, /datum/reagent/ash = 30)
	time = 30
	category = CAT_PRIMAL

/obj/item/pen/fountain/captain
	name = "captain's fountain pen"
	desc = "It's an expensive Oak fountain pen. The nib is quite sharp."
	icon_state = "pen-fountain-o"
	force = 5
	throwforce = 5
	throw_speed = 4
	colour = "crimson"
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
	AddComponent(/datum/component/butchering, 200, 115) //the pen is mightier than the sword

/obj/item/pen/fountain/captain/reskin_obj(mob/M)
	..()
	if(current_skin)
		desc = "It's an expensive [current_skin] fountain pen. The nib is quite sharp."

/obj/item/pen/attack_self(mob/living/carbon/user)
	. = ..()
	if(.)
		return

	var/deg = tgui_input_number(user, "What angle would you like to rotate the pen head to? (1-360)", "Rotate Pen Head", max_value = 360)
	if(isnull(deg))
		return
	degrees = round(deg)
	to_chat(user, span_notice("You rotate the top of the pen to [degrees] degrees."))
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
	//Changing name/description of items. Only works if they have the UNIQUE_RENAME object flag set
	if(isobj(O) && proximity && (O.obj_flags & UNIQUE_RENAME))
		var/penchoice = tgui_alert(user, "What would you like to edit?", "Pen Setting", list("Rename","Description","Reset"))
		if(QDELETED(O) || !user.canUseTopic(O, BE_CLOSE))
			return
		if(penchoice == "Rename")
			var/input = tgui_input_text(user, "What do you want to name [O]?", "Object Name", "[O.name]", MAX_NAME_LEN)
			var/oldname = O.name
			if(QDELETED(O) || !user.canUseTopic(O, BE_CLOSE))
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
			if(QDELETED(O) || !user.canUseTopic(O, BE_CLOSE))
				return
			if(input == olddesc || !input)
				to_chat(user, span_notice("You decide against changing [O]'s description."))
			else
				O.AddComponent(/datum/component/rename, O.name, input)
				to_chat(user, span_notice("You have successfully changed [O]'s description."))
				O.renamedByPlayer = TRUE

		if(penchoice == "Reset")
			if(QDELETED(O) || !user.canUseTopic(O, BE_CLOSE))
				return

			qdel(O.GetComponent(/datum/component/rename))

			//reapply any label to name
			var/datum/component/label/label = O.GetComponent(/datum/component/label)
			if(label)
				label.remove_label()
				label.apply_label()

			to_chat(user, span_notice("You have successfully reset [O]'s name and description."))
			O.renamedByPlayer = FALSE

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
	/// The real name of our item when extended.
	var/hidden_name = "energy dagger"
	/// Whether or pen is extended
	var/extended = FALSE

/obj/item/pen/edagger/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/butchering, _speed = 6 SECONDS, _butcher_sound = 'sound/weapons/blade1.ogg')
	AddComponent(/datum/component/transforming, \
		force_on = 18, \
		throwforce_on = 35, \
		throw_speed_on = 4, \
		sharpness_on = SHARP_EDGED, \
		size_on = ITEM_SIZE_NORMAL)
	RegisterSignal(src, COMSIG_TRANSFORMING_ON_TRANSFORM, .proc/on_transform)

/obj/item/pen/edagger/suicide_act(mob/user)
	. = BRUTELOSS
	if(extended)
		user.visible_message(span_suicide("[user] forcefully rams the pen into their mouth!"))
	else
		user.visible_message(span_suicide("[user] is holding a pen up to their mouth! It looks like [user.p_theyre()] trying to commit suicide!"))
		attack_self(user)

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
		icon_state = "edagger"
		inhand_icon_state = "edagger"
		lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
		righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
		embedding = list(embed_chance = 100) // Rule of cool
	else
		name = initial(name)
		icon_state = initial(icon_state)
		inhand_icon_state = initial(inhand_icon_state)
		lefthand_file = initial(lefthand_file)
		righthand_file = initial(righthand_file)
		embedding = list(embed_chance = EMBED_CHANCE)

	updateEmbedding()
	balloon_alert(user, "[hidden_name] [active ? "active":"concealed"]")
	playsound(user ? user : src, active ? 'sound/weapons/saberon.ogg' : 'sound/weapons/saberoff.ogg', 5, TRUE)
	return COMPONENT_NO_DEFAULT_MESSAGE

/obj/item/pen/survival
	name = "survival pen"
	desc = "The latest in portable survival technology, this pen was designed as a miniature diamond pickaxe. Watchers find them very desirable for their diamond exterior."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "digging_pen"
	inhand_icon_state = "pen"
	worn_icon_state = "pen"
	force = 3
	atom_size = ITEM_SIZE_TINY
	custom_materials = list(/datum/material/iron=10, /datum/material/diamond=100, /datum/material/titanium = 10)
	pressure_resistance = 2
	grind_results = list(/datum/reagent/iron = 2, /datum/reagent/iodine = 1)
	tool_behaviour = TOOL_MINING //For the classic "digging out of prison with a spoon but you're in space so this analogy doesn't work" situation.
	toolspeed = 10 //You will never willingly choose to use one of these over a shovel.
	font = FOUNTAIN_PEN_FONT
	colour = "blue"
