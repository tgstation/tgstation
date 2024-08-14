/obj/structure/plaque //This is a plaque you can craft with gold, then permanently engrave a title and description on, with a fountain pen.
	icon = 'icons/obj/signs.dmi'
	icon_state = "blankplaque"
	name = "blank plaque"
	desc = "A blank plaque, use a fancy pen to engrave it. It can be detatched from the wall with a wrench."
	anchored = TRUE
	opacity = FALSE
	density = FALSE
	layer = SIGN_LAYER
	custom_materials = list(/datum/material/gold =SHEET_MATERIAL_AMOUNT)
	max_integrity = 200 //Twice as durable as regular signs.
	armor_type = /datum/armor/structure_plaque
	///Custom plaque structures and items both start "unengraved", once engraved with a fountain pen their text can't be altered again. Static plaques are already engraved.
	var/engraved = FALSE

WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/plaque)

/datum/armor/structure_plaque
	melee = 50
	fire = 50
	acid = 50

/obj/structure/plaque/Initialize(mapload)
	. = ..()
	if(mapload)
		find_and_hang_on_wall(custom_drop_callback = CALLBACK(src, PROC_REF(drop_plaque)))
	register_context()

/obj/structure/plaque/find_and_hang_on_wall(directional = TRUE, custom_drop_callback)
	if(iswallturf(loc))
		SET_PLANE_EXPLICIT(src, OVER_FRILL_PLANE, loc)
		AddComponent(/datum/component/wall_mounted, loc, custom_drop_callback)
		return //A mapped-in plaque embedded into the wall turf, visible from both sides of it.
	if(!iswallturf(get_step(src, REVERSE_DIR(dir))))
		SET_PLANE_EXPLICIT(src, FLOOR_PLANE, loc)
		return //floor plaques are a thing, messieur.
	return ..()

/obj/structure/plaque/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	switch (held_item?.tool_behaviour)
		if (TOOL_WELDER)
			context[SCREENTIP_CONTEXT_LMB] = "Repair"
			return CONTEXTUAL_SCREENTIP_SET
		if (TOOL_WRENCH)
			context[SCREENTIP_CONTEXT_LMB] = "Unfasten"
			return CONTEXTUAL_SCREENTIP_SET
	if(istype(held_item, /obj/item/pen/fountain) && !engraved)
		context[SCREENTIP_CONTEXT_LMB] = "Engrave"
		return CONTEXTUAL_SCREENTIP_SET

/obj/structure/plaque/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(. || user.is_blind())
		return
	user.examinate(src)

/obj/structure/plaque/wrench_act(mob/living/user, obj/item/wrench/I)
	. = ..()
	user.visible_message(span_notice("[user] starts removing [src]..."), \
		span_notice("You start unfastening [src]."))
	I.play_tool_sound(src)
	if(!I.use_tool(src, user, 4 SECONDS))
		return TRUE
	playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
	user.visible_message(span_notice("[user] unfastens [src]."), \
		span_notice("You unfasten [src]."))
	var/obj/item/plaque/unwrenched_plaque = drop_plaque()
	unwrenched_plaque.forceMove(get_turf(user))
	return TRUE

/obj/structure/plaque/proc/drop_plaque()
	var/obj/item/plaque/unwrenched_plaque = new(drop_location())
	if(engraved) //If it's still just a basic unengraved plaque, we can (and should) skip some of the below variable transfers.
		unwrenched_plaque.name = name //Copy over the plaque structure variables to the plaque item we're creating when we unwrench it.
		unwrenched_plaque.desc = desc
		unwrenched_plaque.engraved = engraved
	unwrenched_plaque.icon_state = icon_state
	unwrenched_plaque.update_integrity(get_integrity())
	unwrenched_plaque.set_custom_materials(custom_materials)
	unwrenched_plaque.set_armor(armor_type)
	unwrenched_plaque.setDir(dir)
	qdel(src) //The plaque structure on the wall goes poof and only the plaque item from unwrenching remains.
	return unwrenched_plaque

/obj/structure/plaque/welder_act(mob/living/user, obj/item/I)
	. = ..()
	if(user.combat_mode)
		return FALSE
	if(atom_integrity == max_integrity)
		to_chat(user, span_warning("This plaque is already in perfect condition."))
		return TRUE
	if(!I.tool_start_check(user, amount=1))
		return TRUE
	user.visible_message(span_notice("[user] starts repairing [src]..."), \
		span_notice("You start repairing [src]."))
	if(!I.use_tool(src, user, 4 SECONDS, volume = 50))
		return TRUE
	user.visible_message(span_notice("[user] finishes repairing [src]."), \
			span_notice("You finish repairing [src]."))
	atom_integrity = max_integrity
	return TRUE

/obj/structure/plaque/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/pen/fountain))
		if(engraved)
			to_chat(user, span_warning("This plaque has already been engraved."))
			return
		var/namechoice = tgui_input_text(user, "Title this plaque. (e.g. 'Best HoP Award', 'Great Ashwalker War Memorial')", "Plaque Customization", max_length = MAX_NAME_LEN)
		if(!namechoice)
			return
		var/descriptionchoice = tgui_input_text(user, "Engrave this plaque's text", "Plaque Customization")
		if(!descriptionchoice)
			return
		if(!Adjacent(user)) //Make sure user is adjacent still
			to_chat(user, span_warning("You need to stand next to the plaque to engrave it!"))
			return
		user.visible_message(span_notice("[user] begins engraving [src]."), \
			span_notice("You begin engraving [src]."))
		if(!do_after(user, 4 SECONDS, target = src)) //This spits out a visible message that somebody is engraving a plaque, then has a delay.
			return
		name = "\improper [namechoice]" //We want improper here so examine doesn't get weird if somebody capitalizes the plaque title.
		desc = "The plaque reads: '[descriptionchoice]'"
		engraved = TRUE //The plaque now has a name, description, and can't be altered again.
		user.visible_message(span_notice("[user] engraves [src]."), \
			span_notice("You engrave [src]."))
		icon_state = "goldenplaque"
		return
	if(istype(I, /obj/item/pen))
		if(engraved)
			to_chat(user, span_warning("This plaque has already been engraved, and your pen isn't fancy enough to engrave it anyway! Find a fountain pen."))
			return
		to_chat(user, span_warning("Your pen isn't fancy enough to engrave this! Find a fountain pen.")) //Go steal the Curator's.
		return
	return ..()

/obj/item/plaque //The item version of the above.
	icon = 'icons/obj/signs.dmi'
	icon_state = "blankplaque"
	inhand_icon_state = "blankplaque"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	name = "blank plaque"
	desc = "A blank plaque, use a fancy pen to engrave it. It can be placed on a wall."
	w_class = WEIGHT_CLASS_NORMAL
	custom_materials = list(/datum/material/gold =SHEET_MATERIAL_AMOUNT)
	max_integrity = 200
	armor_type = /datum/armor/item_plaque
	///Custom plaque structures and items both start "unengraved", once engraved with a fountain pen their text can't be altered again.
	var/engraved = FALSE

/datum/armor/item_plaque
	melee = 50
	fire = 50
	acid = 50

/obj/item/plaque/welder_act(mob/living/user, obj/item/I)
	. = ..()
	if(user.combat_mode)
		return FALSE
	if(atom_integrity == max_integrity)
		to_chat(user, span_warning("This plaque is already in perfect condition."))
		return TRUE
	if(!I.tool_start_check(user, amount=1))
		return TRUE
	user.visible_message(span_notice("[user] starts repairing [src]..."), \
		span_notice("You start repairing [src]."))
	if(!I.use_tool(src, user, 4 SECONDS, volume = 50))
		return TRUE
	user.visible_message(span_notice("[user] finishes repairing [src]."), \
		span_notice("You finish repairing [src]."))
	atom_integrity = max_integrity
	return TRUE


/obj/item/plaque/attackby(obj/item/I, mob/user, params) //Same as part of the above, except for the item in hand instead of the structure.
	if(istype(I, /obj/item/pen/fountain))
		if(engraved)
			to_chat(user, span_warning("This plaque has already been engraved."))
			return
		var/namechoice = tgui_input_text(user, "Title this plaque. (e.g. 'Best HoP Award', 'Great Ashwalker War Memorial')", "Plaque Customization", max_length = MAX_NAME_LEN)
		if(!namechoice)
			return
		var/descriptionchoice = tgui_input_text(user, "Engrave this plaque's text", "Plaque Customization")
		if(!descriptionchoice)
			return
		if(!Adjacent(user)) //Make sure user is adjacent still
			to_chat(user, span_warning("You need to stand next to the plaque to engrave it!"))
			return
		user.visible_message(span_notice("[user] begins engraving [src]."), \
			span_notice("You begin engraving [src]."))
		if(!do_after(user, 4 SECONDS, target = src)) //This spits out a visible message that somebody is engraving a plaque, then has a delay.
			return
		name = "\improper [namechoice]" //We want improper here so examine doesn't get weird if somebody capitalizes the plaque title.
		desc = "The plaque reads: '[descriptionchoice]'"
		engraved = TRUE //The plaque now has a name, description, and can't be altered again.
		user.visible_message(span_notice("[user] engraves [src]."), \
			span_notice("You engrave [src]."))
		return
	if(istype(I, /obj/item/pen))
		if(engraved)
			to_chat(user, span_warning("This plaque has already been engraved, and your pen isn't fancy enough to engrave it anyway! Find a fountain pen."))
			return
		to_chat(user, span_warning("Your pen isn't fancy enough to engrave this! Find a fountain pen.")) //Go steal the Curator's.
		return
	return ..()

/obj/item/plaque/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	var/place_on_wall = FALSE
	if(!isturf(interacting_with))
		return NONE
	if(iswallturf(interacting_with))
		if(user.loc != interacting_with && !(get_dir(user, interacting_with) in GLOB.cardinals))
			balloon_alert(user, "cannot place diagonally!")
			return ITEM_INTERACT_BLOCKING
		place_on_wall = TRUE
	var/turf/target_turf = interacting_with
	var/turf/user_turf = get_turf(user)
	var/obj/structure/plaque/placed_plaque = new (user_turf) //We place the plaque on the turf the user is standing, and pixel shift it to the target wall, as below.
	user.visible_message(span_notice("[user] fastens [src] to [target_turf]."), \
		span_notice("You attach [src] to [target_turf]."))
	playsound(target_turf, 'sound/items/deconstruct.ogg', 50, TRUE)
	if(engraved)
		placed_plaque.name = name
		placed_plaque.desc = desc
		placed_plaque.engraved = engraved
	placed_plaque.icon_state = icon_state
	placed_plaque.update_integrity(get_integrity())
	placed_plaque.set_custom_materials(custom_materials)
	placed_plaque.set_armor(armor_type)
	if(place_on_wall)
		var/dir = get_dir(target_turf, user_turf)
		placed_plaque.setDir(dir)
		placed_plaque.find_and_hang_on_wall()
	else
		SET_PLANE_EXPLICIT(placed_plaque, FLOOR_PLANE, interacting_with)
	qdel(src)
	return ITEM_INTERACT_SUCCESS
