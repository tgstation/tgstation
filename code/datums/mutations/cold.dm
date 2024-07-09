/datum/mutation/human/geladikinesis
	name = "Geladikinesis"
	desc = "Allows the user to concentrate moisture and sub-zero forces into snow."
	quality = POSITIVE
	text_gain_indication = span_notice("Your hand feels cold.")
	instability = POSITIVE_INSTABILITY_MINOR
	difficulty = 10
	synchronizer_coeff = 1
	power_path = /datum/action/cooldown/spell/conjure_item/snow

/datum/action/cooldown/spell/conjure_item/snow
	name = "Create Snow"
	desc = "Concentrates cryokinetic forces to create snow, useful for snow-like construction."
	button_icon_state = "snow"

	cooldown_time = 5 SECONDS
	spell_requirements = NONE

	item_type = /obj/item/stack/sheet/mineral/snow
	delete_old = FALSE
	delete_on_failure = FALSE

/datum/mutation/human/cryokinesis
	name = "Cryokinesis"
	desc = "Draws negative energy from the sub-zero void to freeze surrounding temperatures at subject's will."
	quality = POSITIVE //upsides and downsides
	text_gain_indication = span_notice("Your hand feels cold.")
	instability = POSITIVE_INSTABILITY_MODERATE
	difficulty = 12
	synchronizer_coeff = 1
	energy_coeff = 1
	power_path = /datum/action/cooldown/spell/pointed/projectile/cryo

/datum/action/cooldown/spell/pointed/projectile/cryo
	name = "Cryobeam"
	desc = "This power fires a frozen bolt at a target."
	button_icon_state = "icebeam"
	base_icon_state = "icebeam"
	active_overlay_icon_state = "bg_spell_border_active_blue"
	cooldown_time = 16 SECONDS
	spell_requirements = NONE
	antimagic_flags = NONE

	active_msg = "You focus your cryokinesis!"
	deactive_msg = "You relax."
	projectile_type = /obj/projectile/temp/cryo
