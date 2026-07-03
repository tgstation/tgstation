// MARK: On-station statues
/obj/structure/statue/themis
	name = "Фемида"
	desc = "Статуя древнегреческой богини правосудия."
	icon = 'modular_bandastation/objects/icons/obj/structures/statuelarge.dmi'
	icon_state = "themis"
	layer = ABOVE_MOB_LAYER
	pixel_y = 7
	anchored = TRUE
	max_integrity = 1000
	impressiveness = 50
	abstract_type = /obj/structure/statue/themis

// Station statues
/obj/structure/statue/station_map
	anchored = TRUE
	impressiveness = 80
	max_integrity = 500

/obj/structure/statue/station_map/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/seethrough, get_seethrough_map())

/obj/structure/statue/station_map/proc/get_seethrough_map()
	return

/obj/structure/statue/station_map/wrench_act(mob/living/user, obj/item/tool)
	return FALSE

/obj/structure/statue/station_map/Destroy()
	for(var/obj/structure/statue/station_map/self in orange(3, src))
		if(!QDELETED(self))
			qdel(self)
	return ..()

/obj/structure/statue/station_map/atom_deconstruct(disassembled = TRUE)
	for(var/obj/structure/statue/station_map/self in orange(3, src))
		if(!QDELETED(self))
			qdel(self)
	return ..()

// Cyberiad statue
/obj/structure/statue/station_map/cyberiad
	name = "статуя Кибериады"
	desc = "Гигантская модель научной станции «Кибериада». Судя по отличиям в конструкции, станцию несколько раз перестраивали."
	icon = 'modular_bandastation/objects/icons/obj/structures/cyberiad.dmi'

/obj/structure/statue/station_map/cyberiad/nw
	icon_state = "nw"
	density = FALSE
	layer = ABOVE_ALL_MOB_LAYER

/obj/structure/statue/station_map/cyberiad/north
	icon_state = "north"
	density = FALSE
	layer = ABOVE_ALL_MOB_LAYER

/obj/structure/statue/station_map/cyberiad/ne
	icon_state = "ne"
	density = FALSE
	layer = ABOVE_ALL_MOB_LAYER

// Adds transparency when the player gets behind an object, or is near it
/obj/structure/statue/station_map/cyberiad/nw/get_seethrough_map()
	return SEE_THROUGH_MAP_STATION_STATUE

/obj/structure/statue/station_map/cyberiad/north/get_seethrough_map()
	return SEE_THROUGH_MAP_STATION_STATUE

/obj/structure/statue/station_map/cyberiad/ne/get_seethrough_map()
	return SEE_THROUGH_MAP_STATION_STATUE

/obj/structure/statue/station_map/cyberiad/w
	icon_state = "west"

/obj/structure/statue/station_map/cyberiad/c
	icon_state = "center"

/obj/structure/statue/station_map/cyberiad/e
	icon_state = "east"

/obj/structure/statue/station_map/cyberiad/w/get_seethrough_map()
	return SEE_THROUGH_MAP_STATION_STATUE

/obj/structure/statue/station_map/cyberiad/c/get_seethrough_map()
	return SEE_THROUGH_MAP_STATION_STATUE

/obj/structure/statue/station_map/cyberiad/e/get_seethrough_map()
	return SEE_THROUGH_MAP_STATION_STATUE

/obj/structure/statue/station_map/cyberiad/sw
	icon_state = "sw"

/obj/structure/statue/station_map/cyberiad/s
	icon_state = "south"

/obj/structure/statue/station_map/cyberiad/se
	icon_state = "se"

// Delta statue
/obj/structure/statue/station_map/delta
	name = "статуя Кербероса"
	desc = "Гигантская модель научной станции «Керберос». Судя по отличиям в конструкции, станцию несколько раз перестраивали."
	icon = 'modular_bandastation/objects/icons/obj/structures/delta.dmi'

/obj/structure/statue/station_map/delta/nw
	icon_state = "nw"
	density = FALSE
	layer = ABOVE_ALL_MOB_LAYER

/obj/structure/statue/station_map/delta/north
	icon_state = "north"
	density = FALSE
	layer = ABOVE_ALL_MOB_LAYER

/obj/structure/statue/station_map/delta/ne
	icon_state = "ne"
	density = FALSE
	layer = ABOVE_ALL_MOB_LAYER

// Adds transparency when the player gets behind an object, or is near it
/obj/structure/statue/station_map/delta/nw/get_seethrough_map()
	return SEE_THROUGH_MAP_STATION_STATUE

/obj/structure/statue/station_map/delta/north/get_seethrough_map()
	return SEE_THROUGH_MAP_STATION_STATUE

/obj/structure/statue/station_map/delta/ne/get_seethrough_map()
	return SEE_THROUGH_MAP_STATION_STATUE

/obj/structure/statue/station_map/delta/w
	icon_state = "west"

/obj/structure/statue/station_map/delta/c
	icon_state = "center"

/obj/structure/statue/station_map/delta/e
	icon_state = "east"

/obj/structure/statue/station_map/delta/w/get_seethrough_map()
	return SEE_THROUGH_MAP_STATION_STATUE

/obj/structure/statue/station_map/delta/c/get_seethrough_map()
	return SEE_THROUGH_MAP_STATION_STATUE

/obj/structure/statue/station_map/delta/e/get_seethrough_map()
	return SEE_THROUGH_MAP_STATION_STATUE

/obj/structure/statue/station_map/delta/sw
	icon_state = "sw"

/obj/structure/statue/station_map/delta/s
	icon_state = "south"

/obj/structure/statue/station_map/delta/se
	icon_state = "se"

// MARK: Off-station statues
/obj/structure/statue/mooniverse
	name = "Неизвестный агент"
	desc = "Информация на табличке под статуей исцарапана и нечитабельна... Поверх написано невнятное словосочетание из слов \"Moon\" и \"Universe\"."
	icon = 'modular_bandastation/objects/icons/obj/structures/statuelarge.dmi'
	icon_state = "mooniverse"
	pixel_y = 7
	anchored = TRUE
	max_integrity = 1000
	impressiveness = 100
	abstract_type = /obj/structure/statue/mooniverse

/obj/structure/statue/ell_good
	name = "Mr.Буум"
	desc = "Загадочный клоун с жёлтым оттенком кожи и выразительными зелёными глазами. Лучший двойной агент синдиката, получивший власть над множеством фасилити. \
			Его имя часто произносят неправильно из-за чего его заслуги по документам принадлежат сразу нескольким Буумам. \
			Так же знаменит тем, что убедил руководство НТ тратить время, силы и средства, на золотой унитаз."
	icon = 'modular_bandastation/objects/icons/obj/structures/statuelarge.dmi'
	icon_state = "ell_good"
	pixel_y = 7
	anchored = TRUE
	max_integrity = 1000
	impressiveness = 100
	abstract_type = /obj/structure/statue/ell_good

/obj/structure/statue/heinrich_treisen
	name = "Генрих Трейзен Третий"
	desc = "Золотая статуя текущего главы семьи Трейзен. Его успешная агрессивная политика в отношении конкурентов, \
			формирование окончательной монополии на рынке и мудрое распоряжение имеющимися активами привели к получению Корпорацией исключительных прав на разработку, \
			переработку и продажу плазмы во многих известных мирах. Именно благодаря Генриху Трейзену Третьему мы сегодня знаем Компанию Нанотрейзен такой, какая она есть."
	icon = 'modular_bandastation/objects/icons/obj/structures/statue.dmi'
	icon_state = "heinrich_treisen"
	anchored = TRUE
	abstract_type = /obj/structure/statue/heinrich_treisen
	layer = ABOVE_MOB_LAYER

/obj/structure/statue/elwycco
	name = "Camper Hunter"
	desc = "Похоже это какой-то очень важный человек, или очень значимый для многих людей. Вы замечаете огроменный топор в его руках, с выгравированным числом 220. \
			Что это число значит? Каждый понимает по своему, однако по слухам оно означает количество его жертв. \n Надпись на табличке - Мы с тобой, Шустрила! Аве, Легион!"
	icon = 'modular_bandastation/objects/icons/obj/structures/statue.dmi'
	icon_state = "elwycco"
	anchored = TRUE
	abstract_type = /obj/structure/statue/elwycco

/obj/structure/statue/normandy_soo
	name = "Офицер специальных операций"
	desc = "Статуя одного из офицеров специальных операций. Подобной почести удостоены лишь самые верные..."
	icon = 'modular_bandastation/objects/icons/obj/structures/statue.dmi'
	icon_state = "mooniverse_soo"
	anchored = TRUE
	abstract_type = /obj/structure/statue/normandy_soo

/obj/structure/statue/sandstone/venus/pure
	name = "Венера"
	desc = "Эта мраморная реплика античной статуи восхлавляет женскую красоту и грацию, привлекая внимание своими изящными формами. \
			Скульптура создает величественный образ, который восхищает своим великолепием."
	icon = 'modular_bandastation/objects/icons/obj/structures/statuelarge.dmi'
	icon_state = "venus_pure"
	layer = ABOVE_MOB_LAYER
	pixel_y = 7
	anchored = TRUE
	max_integrity = 1000
	impressiveness = 50
	abstract_type = /obj/structure/statue/themis

/obj/structure/statue/statue_holoplanet
	name = "планетарная голограмма"
	desc = "Установка, позволяющая показывать подробные голографические карты известных миров."
	icon = 'modular_bandastation/objects/icons/obj/structures/statue.dmi'
	icon_state = "statue_holoplanet"
	anchored = TRUE
	layer = ABOVE_MOB_LAYER
	abstract_type = /obj/structure/statue/statue_holoplanet


// Dummies
/**
 *	It is used as decorative element, or for shitspawn/events
 *	DO NOT use these icons for PvE NPCs! TGs NPCs made different.
 */
/obj/structure/statue/dummy
	name = "Unknown"
	desc = null
	icon = 'modular_bandastation/mobs/icons/dummies.dmi'
	icon_state = null
	pixel_y = 7
	anchored = TRUE
	max_integrity = 1000
	impressiveness = 0
	abstract_type = /obj/structure/statue/dummy
