/obj/item/disk/surgery
	name = "диск хирургических процедур"
	desc = "Диск с продвинутыми хирургическими операциями, его нужно загрузить в хирургическую консоль."
	icon_state = "datadisk1"
	custom_materials = list(/datum/material/iron=SMALL_MATERIAL_AMOUNT * 3, /datum/material/glass=SMALL_MATERIAL_AMOUNT)
	/// List of surgical operations contained on this disk
	var/list/surgeries

/obj/item/disk/surgery/debug
	name = "debug surgery disk"
	desc = "A disk that contains all existing surgery procedures."
	icon_state = "datadisk1"
	custom_materials = list(/datum/material/iron=SMALL_MATERIAL_AMOUNT * 3, /datum/material/glass=SMALL_MATERIAL_AMOUNT)

/obj/item/disk/surgery/debug/Initialize(mapload)
	. = ..()
	surgeries = list()
	for(var/datum/surgery_operation/operation as anything in GLOB.operations.get_instances_from(subtypesof(/datum/surgery_operation)))
		surgeries += operation.type

/obj/item/disk/surgery/advanced_plastic_surgery
	name = "диск продвинутой пластической хирургии"
	desc = "Содержит инструкции по проведению более сложных пластических операций."

	surgeries = list(
		/datum/surgery_operation/limb/add_plastic,
	)

/obj/item/disk/surgery/advanced_plastic_surgery/examine(mob/user)
	. = ..()
	. += span_info("Открывает хирургическую операцию <b>[/datum/surgery_operation/limb/add_plastic::name]</b>.")
	. += span_info("Если выполнить её перед <i>[/datum/surgery_operation/limb/plastic_surgery::name]</i>, операция улучшается, \
		позволяя копировать внешность любого человека - \
		при условии, что во второй руке у вас есть его фотография во время операции.")

/obj/item/disk/surgery/advanced_plastic_surgery/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/examine_lore, \
		lore = "Большинство видов пластической хирургии устарели во многом из‑за прогресса в области генетики. \
			Самые простые методы всё ещё используются, но редко и в основном для устранения обезображиваний пациентов. \
			В результате этот предмет стал антиквариатом для многих коллекционеров - \
			хотя некоторые подпольные хирурги до сих пор охотятся за ним ради его редких знаний." \
	)

/obj/item/disk/surgery/brainwashing
	name = "диск операции по промыванию мозгов"
	desc = "Содержит инструкции по закреплению приказа в мозге, делая его основной целью пациента."
	surgeries = list(
		/datum/surgery_operation/organ/brainwash,
		/datum/surgery_operation/organ/brainwash/mechanic,
	)

/obj/item/disk/surgery/sleeper_protocol
	name = "подозрительный хирургический диск"
	desc = "Содержит инструкции по превращению пациента в спящего агента Синдиката."
	surgeries = list(
		/datum/surgery_operation/organ/brainwash/sleeper,
		/datum/surgery_operation/organ/brainwash/sleeper/mechanic,
	)
