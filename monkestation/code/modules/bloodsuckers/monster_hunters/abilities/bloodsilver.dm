/datum/action/cooldown/spell/conjure_item/blood_silver
	name = "Create bloodsilver bullet"
	desc = "Wield your blood and mold it into a bloodsilver bullet"
	button_icon = 'monkestation/icons/bloodsuckers/weapons.dmi'
	button_icon_state = "bloodsilver"
	cooldown_time = 2 MINUTES
	item_type = /obj/item/ammo_casing/silver
	spell_requirements = NONE
	delete_old = FALSE

/datum/action/cooldown/spell/blood_silver/conjure_item/cast(mob/living/carbon/cast_on)
	if(cast_on.blood_volume < BLOOD_VOLUME_NORMAL)
		to_chat(cast_on, span_warning ("Using this ability would put our health at risk!"))
		return
	. = ..()
	cast_on.blood_volume -= 20
