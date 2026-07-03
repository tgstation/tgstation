/datum/bounty/item/engineering/emitter
	name = "Эмиттер"
	description = "Мы предполагаем, что в чертежах эмиттеров на вашей станции может быть дефект, так как присутствует чересчур огромное количество взрывов суперматерии в вашем секторе. Отправьте нам один из ваших эмиттеров."
	reward = CARGO_CRATE_VALUE * 5
	wanted_types = list(/obj/machinery/power/emitter = TRUE)

/datum/bounty/item/engineering/hydro_tray
	name = "Гидропонный лоток"
	description = "Лаборанты пытаются понять, как уменьшить электропотребление гидропонных лотков, но мы сожгли последний. Построите для нас один?"
	reward = CARGO_CRATE_VALUE * 4
	wanted_types = list(/obj/machinery/hydroponics/constructable = TRUE)

/datum/bounty/item/engineering/cyborg_charger
	name = "Станция зарядки"
	description = "Нам не хватает зарядников для всех наших MODсьютов. Отправьте нам один из ваших."
	reward = CARGO_CRATE_VALUE * 5
	wanted_types = list(/obj/machinery/recharge_station = TRUE)

/datum/bounty/item/engineering/smes_unit
	name = "Накопитель энергии"
	description = "Нам нужно хранить больше энергии. Отправьте нам СМЕС."
	reward = CARGO_CRATE_VALUE * 6
	wanted_types = list(/obj/machinery/power/smes = TRUE)

/datum/bounty/item/engineering/pacman
	name = "P.A.C.M.A.N. генератор"
	description = "В нашем запасном генераторе сгорел предохранитель, нам нужен новый как можно скорее."
	reward = CARGO_CRATE_VALUE * 5
	wanted_types = list(/obj/machinery/power/port_gen/pacman = TRUE)

/datum/bounty/item/engineering/field_gen
	name = "Генератор поля"
	description = "Одна из гарантий нашего защитного генератора закончилась, нам нужен новый для его замещения."
	reward = CARGO_CRATE_VALUE * 6
	wanted_types = list(/obj/machinery/field/generator = TRUE)

/datum/bounty/item/engineering/tesla_coil
	name = "Тесла катушка"
	description = "Наши счета за электричество высоки, отправьте нам тесла катушку для компенсации."
	reward = CARGO_CRATE_VALUE * 5
	wanted_types = list(/obj/machinery/power/energy_accumulator/tesla_coil = TRUE)

/datum/bounty/item/engineering/welding_tank
	name = "Бак со сварочным топливом"
	description = "Нам нужно больше сварочного топлива для инженерной команды, отправьте нам целый бак."
	reward = CARGO_CRATE_VALUE * 5
	wanted_types = list(/obj/structure/reagent_dispensers/fueltank = TRUE)

/datum/bounty/item/engineering/reflector
	name = "Рефлектор"
	description = "Мы хотим сделать для наших эмиттеров более длинный маршрут, и для этого нам нужен рефлектор. Займитесь этим."
	reward = CARGO_CRATE_VALUE * 7
	wanted_types = list(/obj/structure/reflector = TRUE)
