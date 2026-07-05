/datum/mutation/adaptation
	name = "Adaptation"
	desc = "Странная мутация, которая адаптирует иммунную систему организма к экстремальным температурам. Не защищает от вакуума."
	quality = POSITIVE
	difficulty = 16
	text_gain_indication = span_notice("Твоё тело окутывает тепло!")
	instability = NEGATIVE_STABILITY_MAJOR
	locked = TRUE // fake parent
	conflicts = list(/datum/mutation/adaptation)
	mutation_traits = list(TRAIT_WADDLING)
	offset_location = FULL_BODY

/datum/mutation/adaptation/New(datum/mutation/copymut)
	. = ..()
	conflicts = typesof(/datum/mutation/adaptation)

/datum/mutation/adaptation/cold
	name = "Cold Adaptation"
	desc = "Странная мутация, которая адаптирует иммунную систему организма к низким температурам. Она также предотвращает подсклазьзование на льду."
	text_gain_indication = span_notice("Твое тело наполняет освежающий холод.")
	instability = POSITIVE_INSTABILITY_MODERATE
	mutation_traits = list(TRAIT_RESISTCOLD, TRAIT_NO_SLIP_ICE)
	mutation_icon_state = "cold"
	locked = FALSE

/datum/mutation/adaptation/heat
	name = "Heat Adaptation"
	desc = "Странная мутация, которая адаптирует иммунную систему организма к высоким температурам, а также предотвращает возгорание её обладателя, хотя пламя всё ещё сжигает одежду. Также делает носителя невосприимчивым к пепельным штормам."
	text_gain_indication = span_notice("Твоё тело наполняет лёгкое тепло.")
	instability = POSITIVE_INSTABILITY_MODERATE
	mutation_traits = list(TRAIT_RESISTHEAT, TRAIT_ASHSTORM_IMMUNE)
	mutation_icon_state = "fire"
	locked = FALSE

/datum/mutation/adaptation/thermal
	name = "Thermal Adaptation"
	desc = "Странная мутация, которая даёт невосприимчивость к урону от высокой и низкой температур. Не защищает от высокого и низкого давления."
	difficulty = 32
	text_gain_indication = span_notice("Твоё тело ощущает комфорто-комнатную температуру.")
	instability = POSITIVE_INSTABILITY_MAJOR
	mutation_traits = list(TRAIT_RESISTHEAT, TRAIT_RESISTCOLD)
	mutation_icon_state = "thermal"
	locked = TRUE // recipe

/datum/mutation/adaptation/pressure
	name = "Pressure Adaptation"
	desc = "Странная мутация, которая адаптирует иммунную систему организма к низкому и высокому давлению. Не защищает от температуры и холодного космоса в том числе."
	text_gain_indication = span_notice("Ваше тело испытывает сильное давление.")
	instability = POSITIVE_INSTABILITY_MODERATE
	mutation_icon_state = "pressure"
	mutation_traits = list(TRAIT_RESISTLOWPRESSURE, TRAIT_RESISTHIGHPRESSURE)
	locked = FALSE
