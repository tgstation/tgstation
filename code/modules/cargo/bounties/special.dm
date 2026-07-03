/datum/bounty/item/special
	unique = TRUE

/datum/bounty/item/special/alien_organs
	name = "Инопланетные органы"
	description = "Нанотрейзен заинтересовано в изучении биологии ксеноморфов. Отправьте набор органов для хорошей компенсации."
	reward = CARGO_CRATE_VALUE * 50
	required_count = 3
	wanted_types = list(
		/obj/item/organ/brain/alien = TRUE,
		/obj/item/organ/alien = TRUE,
		/obj/item/organ/body_egg/alien_embryo = TRUE,
		/obj/item/organ/liver/alien = TRUE,
		/obj/item/organ/tongue/alien = TRUE,
		/obj/item/organ/eyes/alien = TRUE,
	)

/datum/bounty/item/special/syndicate_documents
	name = "Документы синдиката"
	description = "Информация о синдикате высоко ценится на ЦК. Если вы найдёте документы синдиката, отправьте их. Вы, может, спасёте жизни."
	reward = CARGO_CRATE_VALUE * 30
	wanted_types = list(
		/obj/item/documents/syndicate = TRUE,
		/obj/item/documents/photocopy = TRUE,
	)

/datum/bounty/item/special/syndicate_documents/applies_to(obj/O)
	if(!..())
		return FALSE
	if(istype(O, /obj/item/documents/photocopy))
		var/obj/item/documents/photocopy/Copy = O
		return (Copy.copy_type && ispath(Copy.copy_type, /obj/item/documents/syndicate))
	return TRUE

/datum/bounty/item/special/adamantine
	name = "Адамантит"
	description = "Отдел аномальных материалов Нанотрейзен отчаянно нуждается в адамантите. Отправьте большую партию, и мы вас щедро вознаградим."
	reward = CARGO_CRATE_VALUE * 70
	required_count = 10
	wanted_types = list(/obj/item/stack/sheet/mineral/adamantine = TRUE)
