/obj/item/implant/empprotection
	name = "EMP absorber"
	actions_types = null

/obj/item/implant/empprotection/implant(mob/living/target, mob/user, silent, force)
	. = ..()
	if(!.)
		return
	target.AddElement(/datum/element/empprotection, EMP_PROTECT_ALL)


/obj/item/implant/empprotection/removed(mob/living/source, silent, special)
	. = ..()
	source.RemoveElement(/datum/element/empprotection, EMP_PROTECT_ALL)

/obj/item/implant/empprotection/get_data()
	return {"
		<b>Характеристики импланта:</b>

		<b>Название:</b> Имплант подавления импульсных возмущений

		<b>Срок службы:</b> Практически неограниченный

		<b>Важные замечания:</b> <font color='red'>Совместимость с устройствами несертифицированного происхождения не гарантируется</font>

		<HR>
		<b>Подробности об импланте:</b>

		<b>Функция:</b> Обеспечивает защиту нейроинтерфейсов и встроенных компонентов пользователя от электромагнитных импульсов высокой мощности.
		В момент обнаружения резкого скачка электромагнитной активности активирует многоуровневую защитную схему, предотвращающую перегорание элементов и сбои в когнитивных функциях.

		<b>Отказ от ответственности:</b> Имплант не гарантирует сохранность внешних устройств, подключённых к организму пользователя во время воздействия.
		Эффективность может быть снижена при чрезмерной перегрузке защитных контуров в течение короткого времени.
	"}

/obj/item/implanter/empprotection
	name = "implanter (EMP absorber)"
	imp_type = /obj/item/implant/empprotection

/obj/item/implantcase/empprotection
	name = "EMP absorber implant case"
	desc =  "Стеклянный футляр, содержащий имплант подавления импульсных возмущений"
	imp_type = /obj/item/implant/empprotection
