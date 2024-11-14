/datum/mutation/human/cindikinesis
	name = "Cindikinesis"
	desc = "Allows the user to concentrate nearby heat into a pile of ash. Wow. Very interesting."
	quality = POSITIVE
	text_gain_indication = span_notice("Your hand feels warm.")
	instability = POSITIVE_INSTABILITY_MINOR
	difficulty = 10
	synchronizer_coeff = 1
	locked = TRUE
	power_path = /datum/action/cooldown/spell/conjure_item/ash

/datum/action/cooldown/spell/conjure_item/ash
	name = "Create Ash"
	desc = "Concentrates pyrokinetic forces to create ash, useful for basically nothing."
	button_icon_state = "ash"

	cooldown_time = 5 SECONDS
	spell_requirements = NONE

	item_type = /obj/effect/decal/cleanable/ash
	delete_old = FALSE
	delete_on_failure = FALSE

/datum/mutation/human/pyrokinesis
	name = "Pyrokinesis"
	desc = "Draws positive energy from the surroundings to heat surrounding temperatures at subject's will."
	quality = POSITIVE
	text_gain_indication = span_notice("Your hand feels hot!")
	instability = POSITIVE_INSTABILITY_MODERATE
	difficulty = 12
	synchronizer_coeff = 1
	energy_coeff = 1
	locked = TRUE
	power_path = /datum/action/cooldown/spell/pointed/projectile/pyro

/datum/action/cooldown/spell/pointed/projectile/pyro
	name = "Pyrobeam"
	desc = "This power fires a heated bolt at a target."
	button_icon_state = "firebeam"
	base_icon_state = "firebeam"
	active_overlay_icon_state = "bg_spell_border_active_blue"
	cast_range = 9
	cooldown_time = 30 SECONDS
	spell_requirements = NONE
	antimagic_flags = NONE

	active_msg = "You focus your pyrokinesis!"
	deactive_msg = "You cool down."
	projectile_type = /obj/projectile/temp/pyro
