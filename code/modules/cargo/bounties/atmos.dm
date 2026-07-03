/datum/bounty/item/atmospherics
	name = "Gas Parent"
	description = "Shit's broken if you see this."
	reward = CARGO_CRATE_VALUE * 15
	wanted_types = list(/obj/item/tank = TRUE)
	/// How many moles are needed to fufill the bounty?
	var/moles_required = 20
	/// Typepath of the gas datum required to fufill the bounty
	var/gas_type

/datum/bounty/item/atmospherics/applies_to(obj/applied_obj)
	if(!..())
		return FALSE
	var/obj/item/tank/applied_tank = applied_obj
	var/datum/gas_mixture/our_mix = applied_tank.return_air()
	if(!our_mix.gases[gas_type])
		return FALSE
	return our_mix.gases[gas_type][MOLES] >= moles_required

/datum/bounty/item/atmospherics/contribution_amount(obj/shipped)
	var/obj/item/tank/shipped_tank = shipped
	var/datum/gas_mixture/our_mix = shipped_tank.return_air()
	return our_mix.gases[gas_type][MOLES]

/datum/bounty/item/atmospherics/pluox_tank
	name = "Полный баллон Pluoxium"
	description = "НИО ЦК изучает сверхкомпактные баллоны. Отправьте нам полный баллон Pluoxium и вам будет отправлена компенсация. (20 молей)"
	gas_type = /datum/gas/pluoxium

/datum/bounty/item/atmospherics/nitrium_tank
	name = "Полный баллон Nitrium"
	description = "Нечеловеческий персонал станции 88 вызвался волонтёрами в тестировании препаратов, повышающих работоспособность. Отправьте им полный баллон Nitrium, чтобы они смогли начать. (20 молей)"
	gas_type = /datum/gas/nitrium

/datum/bounty/item/atmospherics/freon_tank
	name = "Полный баллон фреона"
	description = "Суперматтерия на станции 33 начала процесс расслоения. Доставьте баллон Freon, чтобы помочь им остановить это! (20 молей)"
	gas_type = /datum/gas/freon

/datum/bounty/item/atmospherics/tritium_tank
	name = "Полный баллон Tritium"
	description = "Станция 49 ищет кикстарт для их исследовательской программы. Отправьте им полный баллон Tritium. (20 молей)"
	gas_type = /datum/gas/tritium

/datum/bounty/item/atmospherics/hydrogen_tank
	name = "Полный баллон Hydrogen"
	description = "Наш научный департамент работает над созданием более электроэффективных батареек, использующих водород в качестве катализатора. Отправьте нам полный баллон Hydrogen. (20 молей)"
	gas_type = /datum/gas/hydrogen

/datum/bounty/item/atmospherics/zauker_tank
	name = "Полный баллон Zauker"
	description = "Основная планета \[REDACTED] была выбрана в качестве тестового полигона для нового оружия, что использует газ Zauker. Отправьте полный баллон Zauker. (20 молей)"
	reward = CARGO_CRATE_VALUE * 20
	gas_type = /datum/gas/zauker
