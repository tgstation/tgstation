#define OBJECTIFY_TIME (5 SECONDS)

/// Turns the target into an object (for instance bread)
/datum/smite/objectify
	name = "Become Object"
	/// What are we going to turn them into?
	var/atom/transform_path = /obj/item/food/bread/plain

/datum/smite/objectify/configure(client/user)
	var/attempted_target_path = input(
		user,
		"Enter typepath of an atom you'd like to turn your victim into.",
		"Typepath",
		"[/obj/item/food/bread/plain]",
	) as null|text

	if (isnull(attempted_target_path))
		return FALSE //The user pressed "Cancel"

	var/desired_object = text2path(attempted_target_path)
	if(!ispath(desired_object))
		desired_object = pick_closest_path(attempted_target_path, get_fancy_list_of_atom_types())
	if(isnull(desired_object) || !ispath(desired_object))
		return FALSE //The user pressed "Cancel"
	if(!ispath(desired_object, /atom))
		tgui_alert(user, "ERROR: Incorrect / improper path given.")
		return FALSE
	transform_path = desired_object

/datum/smite/objectify/effect(client/user, mob/living/target)
	if (!isliving(target))
		return // This doesn't work on ghosts
	. = ..()
	var/mutable_appearance/objectified_player = mutable_appearance(initial(transform_path.icon), initial(transform_path.icon_state))
	objectified_player.pixel_x = initial(transform_path.pixel_x)
	objectified_player.pixel_y = initial(transform_path.pixel_y)
	var/mutable_appearance/transform_scanline = mutable_appearance('icons/effects/effects.dmi', "transform_effect")
	target.transformation_animation(objectified_player, OBJECTIFY_TIME, transform_scanline.appearance)
	target.Immobilize(OBJECTIFY_TIME, ignore_canstun = TRUE)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(objectify), target, transform_path), OBJECTIFY_TIME)

#undef OBJECTIFY_TIME
