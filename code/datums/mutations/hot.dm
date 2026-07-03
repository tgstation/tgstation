/datum/mutation/cindikinesis
	name = "Cindikinesis"
	desc = "Позволяет обладателю мутации сконцентрировать рядом находящееся тепло в кучу пепла. Вау. Очень интересно."
	quality = POSITIVE
	text_gain_indication = span_notice("Твоя рука кажется тёплой.")
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

/datum/mutation/pyrokinesis
	name = "Pyrokinesis"
	desc = "Притягивает положительную энергию окружения для повышения температуры вокруг субъекта."
	quality = POSITIVE
	text_gain_indication = span_notice("Твоя рука кажется горячей!")
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
