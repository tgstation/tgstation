/obj/structure/sign
	icon = 'icons/obj/decals.dmi'
	anchored = TRUE
	opacity = FALSE
	density = FALSE
	layer = SIGN_LAYER
	custom_materials = list(/datum/material/plastic = 2000)
	max_integrity = 100
	armor = list(MELEE = 50, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 50, ACID = 50)
	///Determines if a sign is unwrenchable.
	var/buildable_sign = TRUE
	resistance_flags = FLAMMABLE
	///This determines if you can select this sign type when using a pen on a sign backing. False by default, set to true per sign type to override.
	var/is_editable = FALSE
	///sign_change_name is used to make nice looking, alphebetized and categorized names when you use a pen on any sign item or structure which is_editable.
	var/sign_change_name

/obj/structure/sign/blank //This subtype is necessary for now because some other things (posters, picture frames, paintings) inheret from the parent type.
	icon_state = "backing"
	name = "sign backing"
	desc = "A plastic sign backing, use a pen to change the decal. It can be detached from the wall with a wrench."
	is_editable = TRUE
	sign_change_name = "Blank Sign"

/obj/item/sign
	name = "sign backing"
	desc = "A plastic sign backing, use a pen to change the decal. It can be placed on a wall."
	icon = 'icons/obj/decals.dmi'
	icon_state = "backing"
	inhand_icon_state = "backing"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	custom_materials = list(/datum/material/plastic = 2000)
	armor = list(MELEE = 50, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 50, ACID = 50)
	resistance_flags = FLAMMABLE
	max_integrity = 100
	///The type of sign structure that will be created when placed on a turf, the default looks just like a sign backing item.
	var/sign_path = /obj/structure/sign/blank
	///This determines if you can select this sign type when using a pen on a sign backing. False by default, set to true per sign type to override.
	var/is_editable = TRUE

/obj/item/sign/Initialize(mapload) //Signs not attached to walls are always rotated so they look like they're laying horizontal.
	. = ..()
	var/matrix/M = matrix()
	M.Turn(90)
	transform = M

/obj/structure/sign/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(. || user.is_blind())
		return
	user.examinate(src)

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
		output[initial(potential_sign.sign_change_name)] = potential_sign
	output = sort_list(output) //Alphabetizes the results.
	return output

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
	var/obj/item/sign/unwrenched_sign = new (get_turf(user))
	if(type != /obj/structure/sign/blank) //If it's still just a basic sign backing, we can (and should) skip some of the below variable transfers.
		unwrenched_sign.name = name //Copy over the sign structure variables to the sign item we're creating when we unwrench a sign.
		unwrenched_sign.desc = "[desc] It can be placed on a wall."
		unwrenched_sign.icon_state = icon_state
		unwrenched_sign.sign_path = type
		unwrenched_sign.set_custom_materials(custom_materials) //This is here so picture frames and wooden things don't get messed up.
		unwrenched_sign.is_editable = is_editable
	unwrenched_sign.update_integrity(get_integrity()) //Transfer how damaged it is.
	unwrenched_sign.setDir(dir)
	qdel(src) //The sign structure on the wall goes poof and only the sign item from unwrenching remains.
	return TRUE

/obj/structure/sign/welder_act(mob/living/user, obj/item/I)
	. = ..()
	if(user.combat_mode)
		return FALSE
	if(atom_integrity == max_integrity)
		to_chat(user, span_warning("This sign is already in perfect condition."))
		return TRUE
	if(!I.tool_start_check(user, amount=0))
		return TRUE
	user.visible_message(span_notice("[user] starts repairing [src]..."), \
		span_notice("You start repairing [src]."))
	if(!I.use_tool(src, user, 4 SECONDS, volume =50 ))
		return TRUE
	user.visible_message(span_notice("[user] finishes repairing [src]."), \
		span_notice("You finish repairing [src]."))
	atom_integrity = max_integrity
	return TRUE

/obj/item/sign/welder_act(mob/living/user, obj/item/I)
	. = ..()
	if(user.combat_mode)
		return FALSE
	if(atom_integrity == max_integrity)
		to_chat(user, span_warning("This sign is already in perfect condition."))
		return TRUE
	if(!I.tool_start_check(user, amount=0))
		return TRUE
	user.visible_message(span_notice("[user] starts repairing [src]..."), \
		span_notice("You start repairing [src]."))
	if(!I.use_tool(src, user, 4 SECONDS, volume =50 ))
		return TRUE
	user.visible_message(span_notice("[user] finishes repairing [src]."), \
		span_notice("You finish repairing [src]."))
	atom_integrity = max_integrity
	return TRUE

/obj/structure/sign/attackby(obj/item/I, mob/user, params)
	if(is_editable && istype(I, /obj/item/pen))
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

/obj/item/sign/attackby(obj/item/I, mob/user, params)
	if(is_editable && istype(I, /obj/item/pen))
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

/obj/item/sign/proc/set_sign_type(obj/structure/sign/fake_type)
	name = initial(fake_type.name)
	if(fake_type != /obj/structure/sign/blank)
		desc = "[initial(fake_type.desc)] It can be placed on a wall."
	else
		desc = initial(desc)
	icon_state = initial(fake_type.icon_state)
	sign_path = fake_type

/obj/item/sign/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(!iswallturf(target) || !proximity)
		return
	var/turf/target_turf = target
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
	qdel(src)

/obj/item/sign/random/Initialize(mapload)
	. = ..()
	set_sign_type(GLOB.editable_sign_types[pick(GLOB.editable_sign_types)])

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
