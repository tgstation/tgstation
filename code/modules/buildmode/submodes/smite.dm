/datum/buildmode_mode/smite
	key = "smite"
	var/datum/smite/selected_smite

/datum/buildmode_mode/smite/Destroy()
	selected_smite = null
	return ..()

/datum/buildmode_mode/smite/show_help(client/user)
	to_chat(user, "<span class='notice'>***********************************************************\n\
		Right Mouse Button on buildmode button = Select smite to use.\n\
		Left Mouse Button on mob/living = Smite the mob.\n\
		***********************************************************</span>")

/datum/buildmode_mode/smite/change_settings(client/user)
	var/punishment = input(user, "Choose a punishment", "DIVINE SMITING") as null|anything in GLOB.smites
	var/smite_path = GLOB.smites[punishment]
	var/datum/smite/picking_smite = new smite_path
	var/configuration_success = picking_smite.configure(user)
	if (configuration_success == FALSE)
		return
	selected_smite = picking_smite

/datum/buildmode_mode/smite/handle_click(client/user, params_string, object)
	var/list/params = params2list(params_string)

	if (!check_rights(R_ADMIN | R_FUN))
		return

	if (!params.Find("left"))
		return

	if (!isliving(object))
		return

	if (selected_smite == null)
		to_chat(user, "<span class='notice'>No smite selected.</span>")
		return

	selected_smite.effect(user, object)
