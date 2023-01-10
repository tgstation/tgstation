/datum/action/innate/pai
	name = "PAI Action"
	button_icon = 'icons/mob/actions/actions_silicon.dmi'
	var/mob/living/silicon/pai/pai_owner

/datum/action/innate/pai/Trigger(trigger_flags)
	if(!ispAI(owner))
		return FALSE
	pai_owner = owner

/datum/action/innate/pai/software
	name = "Software Interface"
	button_icon_state = "pai"
	background_icon_state = "bg_tech"
	overlay_icon_state = "bg_tech_border"

/datum/action/innate/pai/software/Trigger(trigger_flags)
	..()
	pai_owner.ui_act()

/datum/action/innate/pai/shell
	name = "Toggle Holoform"
	button_icon_state = "pai_holoform"
	background_icon_state = "bg_tech"
	overlay_icon_state = "bg_tech_border"

/datum/action/innate/pai/shell/Trigger(trigger_flags)
	..()
	if(pai_owner.holoform)
		pai_owner.fold_in(0)
	else
		pai_owner.fold_out()

/datum/action/innate/pai/chassis
	name = "Holochassis Appearance Composite"
	button_icon_state = "pai_chassis"
	background_icon_state = "bg_tech"
	overlay_icon_state = "bg_tech_border"

/datum/action/innate/pai/chassis/Trigger(trigger_flags)
	..()
	pai_owner.choose_chassis()

/datum/action/innate/pai/rest
	name = "Rest"
	button_icon_state = "pai_rest"
	background_icon_state = "bg_tech"
	overlay_icon_state = "bg_tech_border"

/datum/action/innate/pai/rest/Trigger(trigger_flags)
	..()
	pai_owner.toggle_resting()

/datum/action/innate/pai/light
	name = "Toggle Integrated Lights"
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "emp"
	background_icon_state = "bg_tech"
	overlay_icon_state = "bg_tech_border"

/datum/action/innate/pai/light/Trigger(trigger_flags)
	..()
	pai_owner.toggle_integrated_light()
