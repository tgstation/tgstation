/obj/structure/sign
	icon = 'icons/obj/signs.dmi'
	anchored = TRUE
	opacity = FALSE
	density = FALSE
	layer = SIGN_LAYER
	custom_materials = list(/datum/material/plastic =SHEET_MATERIAL_AMOUNT)
	max_integrity = 100
	armor_type = /datum/armor/structure_sign
	resistance_flags = FLAMMABLE
	///Determines if a sign is unwrenchable.
	var/buildable_sign = TRUE
	///This determines if you can select this sign type when using a pen on a sign backing. False by default, set to true per sign type to override.
	var/is_editable = FALSE
	///sign_change_name is used to make nice looking, alphabetized and categorized names when you use a pen on any sign item or structure which is_editable.
	var/sign_change_name
	///Callback to the knock down proc for wallmounting behavior.
	var/knock_down_callback

/datum/armor/structure_sign
	melee = 50
	fire = 50
	acid = 50

/obj/structure/sign/Initialize(mapload)
	. = ..()
	register_context()
	knock_down_callback = CALLBACK(src, PROC_REF(knock_down))
	find_and_hang_on_wall(custom_drop_callback = knock_down_callback)

/obj/structure/sign/Destroy()
	. = ..()
	knock_down_callback = null

/obj/structure/sign/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	switch (held_item?.tool_behaviour)
		if (TOOL_WELDER)
			context[SCREENTIP_CONTEXT_LMB] = "Repair"
			return CONTEXTUAL_SCREENTIP_SET
		if (TOOL_WRENCH)
			if(!buildable_sign)
				return ///Cannot be unfastened regardless.
			context[SCREENTIP_CONTEXT_LMB] = "Unfasten"
			return CONTEXTUAL_SCREENTIP_SET
	return NONE

/obj/structure/sign/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(. || user.is_blind())
		return
	user.examinate(src)

/obj/structure/sign/wrench_act(mob/living/user, obj/item/wrench/I)
	. = ..()
	if(!buildable_sign)
		return TRUE
	user.visible_message(span_notice("[user] starts removing [src]..."), \
		span_notice("You start unfastening [src]."))
	I.play_tool_sound(src)
	if(!I.use_tool(src, user, 4 SECONDS))
		return TRUE
	playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
	user.visible_message(span_notice("[user] unfastens [src]."), \
		span_notice("You unfasten [src]."))
	knock_down(user)
	return TRUE

/obj/structure/sign/welder_act(mob/living/user, obj/item/I)
	. = ..()
	if(user.combat_mode)
		return FALSE
	if(atom_integrity == max_integrity)
		to_chat(user, span_warning("This sign is already in perfect condition."))
		return TRUE
	if(!I.tool_start_check(user, amount=1))
		return TRUE
	user.visible_message(span_notice("[user] starts repairing [src]..."), \
		span_notice("You start repairing [src]."))
	if(!I.use_tool(src, user, 4 SECONDS, volume =50 ))
		return TRUE
	user.visible_message(span_notice("[user] finishes repairing [src]."), \
		span_notice("You finish repairing [src]."))
	atom_integrity = max_integrity
	return TRUE

/obj/structure/sign/attackby(obj/item/I, mob/user, list/modifiers)
	if(is_editable && IS_WRITING_UTENSIL(I))
		if(!length(GLOB.editable_sign_types))
			CRASH("GLOB.editable_sign_types failed to populate")
		var/choice = tgui_input_list(user, "Select a sign type", "Sign Customization", GLOB.editable_sign_types)
		if(isnull(choice))
			return
		if(!Adjacent(user)) //Make sure user is adjacent still.
			to_chat(user, span_warning("You need to stand next to the sign to change it!"))
			return
		user.visible_message(span_notice("[user] begins changing [src]."), \
			span_notice("You begin changing [src]."))
		if(!do_after(user, 4 SECONDS, target = src)) //Small delay for changing signs instead of it being instant, so somebody could be shoved or stunned to prevent them from doing so.
			return
		var/sign_type = GLOB.editable_sign_types[choice]
		//It's import to clone the pixel layout information.
		//Otherwise signs revert to being on the turf and
		//move jarringly.
		var/obj/structure/sign/changedsign = new sign_type(get_turf(src))
		changedsign.pixel_x = pixel_x
		changedsign.pixel_y = pixel_y
		changedsign.atom_integrity = atom_integrity
		qdel(src)
		user.visible_message(span_notice("[user] finishes changing the sign."), \
			span_notice("You finish changing the sign."))
		return
	return ..()

/**
 * This is called when a sign is removed from a wall, either through deconstruction or being knocked down.
 * @param mob/living/user The user who removed the sign, if it was knocked down by a mob.
 */
/obj/structure/sign/proc/knock_down(mob/living/user)
	var/turf/drop_turf
	if(user)
		drop_turf = get_turf(user)
	else
		drop_turf = drop_location()
	var/obj/item/sign/unwrenched_sign = new (drop_turf)
	if(type != /obj/structure/sign/blank) //If it's still just a basic sign backing, we can (and should) skip some of the below variable transfers.
		unwrenched_sign.name = name //Copy over the sign structure variables to the sign item we're creating when we unwrench a sign.
		unwrenched_sign.desc = "[desc] It can be placed on a wall."
		unwrenched_sign.icon = icon
		unwrenched_sign.icon_state = icon_state
		unwrenched_sign.sign_path = type
		unwrenched_sign.set_custom_materials(custom_materials) //This is here so picture frames and wooden things don't get messed up.
		unwrenched_sign.is_editable = is_editable
	unwrenched_sign.update_integrity(get_integrity()) //Transfer how damaged it is.
	unwrenched_sign.setDir(dir)
	qdel(src) //The sign structure on the wall goes poof and only the sign item from unwrenching remains.

/obj/structure/sign/blank //This subtype is necessary for now because some other things (posters, picture frames, paintings) inherit from the parent type.
	icon_state = "backing"
	name = "sign backing"
	desc = "A plastic sign backing, use a pen to change the decal. It can be detached from the wall with a wrench."
	is_editable = TRUE
	sign_change_name = "Blank Sign"

/obj/structure/sign/nanotrasen
	name = "\improper Nanotrasen logo sign"
	sign_change_name = "Corporate Logo - Nanotrasen"
	desc = "A sign with the Nanotrasen logo on it. Glory to Nanotrasen!"
	icon_state = "nanotrasen"
	is_editable = TRUE

/obj/structure/sign/logo
	name = "\improper Nanotrasen logo sign"
	desc = "The Nanotrasen corporate logo."
	icon_state = "nanotrasen_sign1"
	buildable_sign = FALSE

/obj/item/sign
	name = "sign backing"
	desc = "A plastic sign backing, use a pen to change the decal. It can be placed on a wall."
	icon = 'icons/obj/signs.dmi'
	icon_state = "backing"
	inhand_icon_state = "backing"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	custom_materials = list(/datum/material/plastic =SHEET_MATERIAL_AMOUNT)
	armor_type = /datum/armor/item_sign
	resistance_flags = FLAMMABLE
	max_integrity = 100
	///The type of sign structure that will be created when placed on a turf, the default looks just like a sign backing item.
	var/sign_path = /obj/structure/sign/blank
	///This determines if you can select this sign type when using a pen on a sign backing. False by default, set to true per sign type to override.
	var/is_editable = TRUE

/datum/armor/item_sign
	melee = 50
	fire = 50
	acid = 50

/obj/item/sign/Initialize(mapload) //Signs not attached to walls are always rotated so they look like they're laying horizontal.
	. = ..()
	var/matrix/M = matrix()
	M.Turn(90)
	transform = M
	register_context()

/obj/item/sign/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if(is_editable && IS_WRITING_UTENSIL(held_item))
		context[SCREENTIP_CONTEXT_LMB] = "Change design"
		return CONTEXTUAL_SCREENTIP_SET

/obj/item/sign/attackby(obj/item/I, mob/user, list/modifiers)
	if(is_editable && IS_WRITING_UTENSIL(I))
		if(!length(GLOB.editable_sign_types))
			CRASH("GLOB.editable_sign_types failed to populate")
		var/choice = tgui_input_list(user, "Select a sign type", "Sign Customization", GLOB.editable_sign_types)
		if(isnull(choice))
			return
		if(!Adjacent(user)) //Make sure user is adjacent still.
			to_chat(user, span_warning("You need to stand next to the sign to change it!"))
			return
		user.visible_message(span_notice("You begin changing [src]."))
		if(!do_after(user, 4 SECONDS, target = src))
			return
		set_sign_type(GLOB.editable_sign_types[choice])
		user.visible_message(span_notice("You finish changing the sign."))
		return
	return ..()

/obj/item/sign/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!iswallturf(interacting_with) && !istype(interacting_with, /obj/structure/tram))
		return NONE
	var/turf/target_turf = interacting_with
	var/turf/user_turf = get_turf(user)
	var/obj/structure/sign/placed_sign = new sign_path(user_turf) //We place the sign on the turf the user is standing, and pixel shift it to the target wall, as below.
	//This is to mimic how signs and other wall objects are usually placed by mappers, and so they're only visible from one side of a wall.
	var/dir = get_dir(user_turf, target_turf)
	if(dir & NORTH)
		placed_sign.pixel_y = 32
	else if(dir & SOUTH)
		placed_sign.pixel_y = -32
	if(dir & EAST)
		placed_sign.pixel_x = 32
	else if(dir & WEST)
		placed_sign.pixel_x = -32
	user.visible_message(span_notice("[user] fastens [src] to [target_turf]."), \
		span_notice("You attach the sign to [target_turf]."))
	playsound(target_turf, 'sound/items/deconstruct.ogg', 50, TRUE)
	placed_sign.update_integrity(get_integrity())
	placed_sign.setDir(dir)
	placed_sign.find_and_hang_on_wall(TRUE, placed_sign.knock_down_callback)
	qdel(src)
	return ITEM_INTERACT_SUCCESS

/obj/item/sign/welder_act(mob/living/user, obj/item/I)
	. = ..()
	if(user.combat_mode)
		return FALSE
	if(atom_integrity == max_integrity)
		to_chat(user, span_warning("This sign is already in perfect condition."))
		return TRUE
	if(!I.tool_start_check(user, amount=1))
		return TRUE
	user.visible_message(span_notice("[user] starts repairing [src]..."), \
		span_notice("You start repairing [src]."))
	if(!I.use_tool(src, user, 4 SECONDS, volume =50 ))
		return TRUE
	user.visible_message(span_notice("[user] finishes repairing [src]."), \
		span_notice("You finish repairing [src]."))
	atom_integrity = max_integrity
	return TRUE

/obj/item/sign/proc/set_sign_type(obj/structure/sign/fake_type)
	name = initial(fake_type.name)
	if(fake_type != /obj/structure/sign/blank)
		desc = "[initial(fake_type.desc)] It can be placed on a wall."
	else
		desc = initial(desc)
	icon_state = initial(fake_type.icon_state)
	sign_path = fake_type

/obj/item/sign/random/Initialize(mapload)
	. = ..()
	set_sign_type(GLOB.editable_sign_types[pick(GLOB.editable_sign_types)])
/**
 * This proc populates GLOBAL_LIST_EMPTY(editable_sign_types)
 *
 * The first time a pen is used on any sign, this populates GLOBAL_LIST_EMPTY(editable_sign_types), creating a global list of all the signs that you can set a sign backing to with a pen.
 */
/proc/populate_editable_sign_types()
	var/list/output = list()
	for(var/s in subtypesof(/obj/structure/sign))
		var/obj/structure/sign/potential_sign = s
		if(!initial(potential_sign.is_editable))
			continue
		var/shown_name = initial(potential_sign.sign_change_name) || capitalize(format_text(initial(potential_sign.name)))
		if(output[shown_name])
			if(!ispath(potential_sign, output[shown_name]))
				stack_trace("Two signs share the same sign_change_name: [output[shown_name]] and [potential_sign]")
			continue
		output[shown_name] = potential_sign
	output = sort_list(output) //Alphabetizes the results.
	return output
