/// Switches between mouse buttons for MODsuit active modules
/datum/preference/choiced/mod_select
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "mod_select"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/choiced/mod_select/init_possible_values()
	return list(MIDDLE_CLICK, ALT_CLICK)

/datum/preference/choiced/mod_select/create_default_value()
	return MIDDLE_CLICK

/datum/preference/choiced/mod_select/apply_to_client_updated(client/client, value)
	if(!ishuman(client.mob))
		return
	var/mob/living/carbon/human/client_owner = client.mob
	if(!istype(client_owner.back, /obj/item/mod/control))
		return
	var/obj/item/mod/control/mod = client_owner.back
	if(!mod.selected_module)
		return
	mod.selected_module.UnregisterSignal(mod.wearer, mod.selected_module.used_signal)
	switch(value)
		if(MIDDLE_CLICK)
			mod.selected_module.used_signal = COMSIG_MOB_MIDDLECLICKON
		if(ALT_CLICK)
			mod.selected_module.used_signal = COMSIG_MOB_ALTCLICKON
	mod.selected_module.RegisterSignal(mod.wearer, mod.selected_module.used_signal, /obj/item/mod/module.proc/on_special_click)
