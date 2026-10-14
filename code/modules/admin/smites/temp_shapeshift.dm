/// Turns the target into another mob (while being easily revertable)
/datum/smite/temp_shapeshift
	name = "Temporary Shapeshift"
	/// Who shall you be... pick a face, any face :]
	var/mob/living/transform_path = /mob/living/basic/pet/dog/corgi
	/// How long until they revert, 0 is indefinitely
	var/duration = 30

/datum/smite/temp_shapeshift/configure(client/user)
	var/attempted_target_path = input(
		user,
		"Enter typepath of a mob you'd like to turn your victim into.",
		"Typepath",
		"[/mob/living/basic/pet/dog/corgi]",
	) as null|text

	if (isnull(attempted_target_path))
		return FALSE //The user pressed "Cancel"

	var/desired_mob = text2path(attempted_target_path)
	if(!ispath(desired_mob))
		desired_mob = pick_closest_path(attempted_target_path, make_types_fancy(subtypesof(/mob/living)))
	if(isnull(desired_mob) || !ispath(desired_mob))
		return FALSE //The user pressed "Cancel"
	if(!ispath(desired_mob, /mob/living))
		tgui_alert(user, "ERROR: Incorrect / improper path given.")
		return FALSE
	transform_path = desired_mob

	var/desired_duration = tgui_input_number(user, "How long should they stay shapeshifted, in seconds? 0 means indefinitely.", "Duration", default = 30)
	if (isnull(desired_duration))
		return FALSE
	duration = desired_duration

/datum/smite/temp_shapeshift/effect(client/user, mob/living/target)
	if (!isliving(target))
		return // This doesn't work on ghosts
	. = ..()
	var/mob/living/new_shape = target.do_shapeshift(transform_path)
	if (!new_shape || !duration)
		return
	// Timer is on the new shape, so this is to clean up if killed or deleted before then
	addtimer(CALLBACK(new_shape, TYPE_PROC_REF(/mob/living, do_unshapeshift)), duration SECONDS)
