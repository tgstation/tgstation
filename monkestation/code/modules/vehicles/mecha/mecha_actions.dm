//Night vision mode
/datum/action/vehicle/sealed/mecha/light_amplification
	name = "Light Amplification"
	button_icon_state = "mech_nightvision_off"
	//What traits do we use?
	var/list/amplification_traits = list(TRAIT_TRUE_NIGHT_VISION, TRAIT_MESON_VISION, TRAIT_MADNESS_IMMUNE)

/datum/action/vehicle/sealed/mecha/light_amplification/Trigger(trigger_flags)
	if(!owner || !chassis || !(owner in chassis.occupants))
		return
	chassis.light_amplification = !chassis.light_amplification
	button_icon_state = "mech_nightvision_[chassis.light_amplification ? "on" : "off"]"
	chassis.log_message("Toggled light amplification.", LOG_MECHA)
	if(ismob(owner))
		var/mob/user = owner
		if(chassis.light_amplification)
			for(var/trait in amplification_traits)
				ADD_TRAIT(user, trait, MECH_TRAIT)
			SEND_SOUND(owner, sound('monkestation/sound/mecha/light_amp.ogg', volume=50))
			user.update_sight()
		else
			for(var/trait in amplification_traits)
				REMOVE_TRAIT(user, trait, MECH_TRAIT)
			user.update_sight()
	else
		to_chat(owner, "The [src] activates, but you appear to be a mere object!") //oh fuck WHAT
	chassis.balloon_alert(owner, "toggled light amplification [chassis.light_amplification ? "on" : "off"]")
	build_all_button_icons()

/datum/action/vehicle/sealed/mecha/light_amplification/Destroy()
	if(!owner || !chassis || !(owner in chassis.occupants))
		return
	if(ismob(owner))
		var/mob/user = owner
		for(var/trait in amplification_traits)
			REMOVE_TRAIT(user, trait, MECH_TRAIT)
		user.update_sight()
		chassis.light_amplification = FALSE
	return ..()
