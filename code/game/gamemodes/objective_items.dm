GLOBAL_DATUM_INIT(steal_item_handler, /datum/objective_item_handler, new())

/proc/add_item_to_steal(source, type)
	GLOB.steal_item_handler.objectives_by_path[type] += source
	return type

/// Holds references to information about all of the items you might need to steal for objectives
/datum/objective_item_handler
	var/list/list/objectives_by_path
	var/generated_items = FALSE

/datum/objective_item_handler/New()
	. = ..()
	objectives_by_path = list()
	for(var/datum/objective_item/item as anything in subtypesof(/datum/objective_item))
		objectives_by_path[initial(item.targetitem)] = list()
	RegisterSignal(SSatoms, COMSIG_SUBSYSTEM_POST_INITIALIZE, PROC_REF(save_items))
	RegisterSignal(SSdcs, COMSIG_GLOB_NEW_ITEM, PROC_REF(new_item_created))

/datum/objective_item_handler/proc/new_item_created(datum/source, obj/item/item)
	SIGNAL_HANDLER
	if(HAS_TRAIT(item, TRAIT_ITEM_OBJECTIVE_BLOCKED))
		return
	if(!generated_items)
		item.add_stealing_item_objective()
		return
	var/typepath = item.add_stealing_item_objective()
	if(typepath != null)
		register_item(item, typepath)

/// Registers all items that are potentially stealable and removes ones that aren't.
/// We still need to do things this way because on mapload, items may not be on the station until everything has finished loading.
/datum/objective_item_handler/proc/save_items()
	SIGNAL_HANDLER
	for(var/obj/item/typepath as anything in objectives_by_path)
		var/list/obj_by_path_cache = objectives_by_path[typepath].Copy()
		for(var/obj/item/object as anything in obj_by_path_cache)
			register_item(object, typepath)
	generated_items = TRUE

/datum/objective_item_handler/proc/register_item(atom/object, typepath)
	var/turf/place = get_turf(object)
	if(!place || !is_station_level(place.z))
		objectives_by_path[typepath] -= object
		return
	RegisterSignal(object, COMSIG_QDELETING, PROC_REF(remove_item))

/datum/objective_item_handler/proc/remove_item(atom/source)
	SIGNAL_HANDLER
	for(var/typepath in objectives_by_path)
		objectives_by_path[typepath] -= source

//Contains the target item datums for Steal objectives.
/datum/objective_item
	/// How the item is described in the objective
	var/name = "a silly bike horn! Honk!"
	/// Typepath of item
	var/targetitem = /obj/item/bikehorn
	/// Valid containers that the target item can be in.
	var/list/valid_containers = list()
	/// Who CARES if this item goes missing (no stealing unguarded items), often similar but not identical to the next list
	var/list/item_owner = list()
	/// Jobs which cannot generate this objective (no stealing your own stuff)
	var/list/excludefromjob = list()
	/// List of additional items which also count, for things like blueprints
	var/list/altitems = list()
	/// Items to provide to people in order to allow them to acquire the target
	var/list/special_equipment = list()
	/// Defines in which contexts the item can be given as an objective
	var/objective_type = OBJECTIVE_ITEM_TYPE_NORMAL
	/// Whether this item exists on the station map at the start of a round.
	var/exists_on_map = FALSE
	/**
	 * How hard it is to steal this item given normal circumstances, ranked on a scale of 1 to 5.
	 *
	 * 1 - Probably found in a public area
	 * 2 - Likely on someone's person, or in a less-than-public but otherwise unguarded area
	 * 3 - Usually on someone's person, or in a locked locker or otherwise secure area
	 * 4 - Always on someone's person, or in a secure area
	 * 5 - You know it when you see it. Things like the Nuke Disc which have a pointer to it at all times.
	 *
	 * Also accepts 0 as "extremely easy to steal" and >5 as "almost impossible to steal"
	 */
	var/difficulty = 0
	/// A hint explaining how one may find the target item.
	var/steal_hint = "The clown might have one."

	///If the item takes special steps to destroy for an objective (e.g. blackbox)
	var/destruction_method = null

/// For objectives with special checks (does that intellicard have an ai in it? etcetc)
/datum/objective_item/proc/check_special_completion(obj/item/thing)
	return TRUE

/// Takes a list of minds and returns true if this is a valid objective to give to a team of these minds
/datum/objective_item/proc/valid_objective_for(list/potential_thieves, require_owner = FALSE)
	if(!target_exists() || (require_owner && !owner_exists()))
		return FALSE
	for (var/datum/mind/possible_thief as anything in potential_thieves)
		var/datum/job/role = possible_thief.assigned_role
		if(role.title in excludefromjob)
			return FALSE
	return TRUE

/// Returns true if the target item exists
/datum/objective_item/proc/target_exists()
	return (exists_on_map) ? length(GLOB.steal_item_handler.objectives_by_path[targetitem]) : TRUE

/// Returns true if one of the item's owners exists somewhere
/datum/objective_item/proc/owner_exists()
	if (!length(item_owner))
		return TRUE
	for (var/mob/living/player as anything in GLOB.player_list)
		if ((player.mind?.assigned_role.title in item_owner) && player.stat != DEAD && !is_centcom_level(player.z))
			return TRUE
	return FALSE

/datum/objective_item/steal/New()
	. = ..()
	if(target_exists())
		GLOB.possible_items += src
	else
		qdel(src)

/datum/objective_item/steal/Destroy()
	GLOB.possible_items -= src
	return ..()

// Low risk steal objectives
/datum/objective_item/steal/traitor
	objective_type = OBJECTIVE_ITEM_TYPE_TRAITOR

// Unique-ish low risk objectives
/datum/objective_item/steal/traitor/bartender_shotgun
	name = "дробовик бармена"
	targetitem = /obj/item/gun/ballistic/shotgun/doublebarrel
	excludefromjob = list(JOB_BARTENDER)
	item_owner = list(JOB_BARTENDER)
	exists_on_map = TRUE
	difficulty = 2
	steal_hint = "Двуствольный дробовик, обычно находящийся у бармена. Если его нет у бармена, то можете найти в подсобке бара."

/obj/item/gun/ballistic/shotgun/doublebarrel/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/gun/ballistic/shotgun/doublebarrel)

/datum/objective_item/steal/traitor/fireaxe
	name = "пожарный топор"
	targetitem = /obj/item/fireaxe
	excludefromjob = list(
		JOB_ATMOSPHERIC_TECHNICIAN,
		JOB_CAPTAIN,
		JOB_CHIEF_ENGINEER,
		JOB_CHIEF_MEDICAL_OFFICER,
		JOB_HEAD_OF_PERSONNEL,
		JOB_HEAD_OF_SECURITY,
		JOB_QUARTERMASTER,
		JOB_RESEARCH_DIRECTOR,
		JOB_STATION_ENGINEER,
	)
	exists_on_map = TRUE
	difficulty = 3
	steal_hint = "Существует только два пожарных топора - один на мостике, а второй в атмосферном отделе. \
		Вы можете использовать мультитул для открытия камеры хранения, или сломать грубой силой."

/obj/item/fireaxe/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/fireaxe)

/datum/objective_item/steal/traitor/big_crowbar
	name = "инструмент для удаления пилота из меха"
	targetitem = /obj/item/crowbar/mechremoval
	excludefromjob = list(
		JOB_RESEARCH_DIRECTOR,
		JOB_SCIENTIST,
		JOB_ROBOTICIST,
	)
	item_owner = list(JOB_ROBOTICIST)
	exists_on_map = TRUE
	difficulty = 2
	steal_hint = "Специализированный инструмент, что можно найти в лаборатории робототехников. \
		Вы можете использовать мультитул для открытия камеры хранения, или сломать грубой силой."

/obj/item/crowbar/mechremoval/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/crowbar/mechremoval)

/datum/objective_item/steal/traitor/nullrod
	name = "нулевой жезл священника"
	targetitem = /obj/item/nullrod
	excludefromjob = list(JOB_CHAPLAIN)
	item_owner = list(JOB_CHAPLAIN)
	exists_on_map = TRUE
	difficulty = 2
	steal_hint = "Священный артефакт, обычно находящийся у священника. Если нет у священника, то можно найти в комнате священника. \
		Если на станции есть священник, то он, скорее всего, превратится в какое-нибудь священное оружие, некоторые из которых... трудно снять с человека."

/obj/item/nullrod/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/nullrod)

/datum/objective_item/steal/traitor/clown_shoes
	name = "ботинки клоуна"
	targetitem = /obj/item/clothing/shoes/clown_shoes
	excludefromjob = list(JOB_CLOWN, JOB_CARGO_TECHNICIAN, JOB_QUARTERMASTER)
	item_owner = list(JOB_CLOWN)
	exists_on_map = TRUE
	difficulty = 1
	steal_hint = "Огромные яркие ботинки клоуна. Они всегда должны быть на ногах клоуна."

/obj/item/clothing/shoes/clown_shoes/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/clothing/shoes/clown_shoes)

/datum/objective_item/steal/traitor/mime_mask
	name = "маска мима"
	targetitem = /obj/item/clothing/mask/gas/mime
	excludefromjob = list(JOB_MIME, JOB_CARGO_TECHNICIAN, JOB_QUARTERMASTER)
	item_owner = list(JOB_MIME)
	exists_on_map = TRUE
	difficulty = 1
	steal_hint = "Маска мима. Она всегда должна быть на лице мима."

/obj/item/clothing/mask/gas/mime/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/clothing/mask/gas/mime)

/datum/objective_item/steal/traitor/pka
	name = "протокинетический ускоритель"
	targetitem = /obj/item/gun/energy/recharge/kinetic_accelerator
	excludefromjob = list(JOB_SHAFT_MINER, JOB_CARGO_TECHNICIAN, JOB_QUARTERMASTER)
	item_owner = list(JOB_SHAFT_MINER)
	exists_on_map = TRUE
	difficulty = 1
	steal_hint = "Инструмент, который в основном используется шахтерами при добыче полезных ископаемых. Большинство из них носят его с собой (или несколько), \
		но его также можно найти в коморке шахтёров, либо где-то в шахтах."

/obj/item/gun/energy/recharge/kinetic_accelerator/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/gun/energy/recharge/kinetic_accelerator)

/datum/objective_item/steal/traitor/chef_moustache
	name = "модные накладные усы"
	targetitem = /obj/item/clothing/mask/fakemoustache/italian
	excludefromjob = list(JOB_COOK, JOB_HEAD_OF_PERSONNEL, JOB_CARGO_TECHNICIAN, JOB_QUARTERMASTER)
	item_owner = list(JOB_COOK)
	exists_on_map = TRUE
	difficulty = 1
	steal_hint = "Искусственные итальянские усы шеф-повара, найденные либо на лице, либо в мусорном ведре, в зависимости от того, кто за работой."

/obj/item/clothing/mask/fakemoustache/italian/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/clothing/mask/fakemoustache/italian)

/datum/objective_item/steal/traitor/det_revolver
	name = "револьвер детектива"
	targetitem = /obj/item/gun/ballistic/revolver/c38/detective
	excludefromjob = list(JOB_DETECTIVE)
	exists_on_map = TRUE
	difficulty = 3
	steal_hint = "Револьвер калибра .38 special, что может быть у детектива. \
		Если его нет у детектива, то можете найти в его кабинете."

/obj/item/gun/ballistic/revolver/c38/detective/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/gun/ballistic/revolver/c38/detective)

/datum/objective_item/steal/traitor/lawyers_badge
	name = "значок юриста"
	targetitem = /obj/item/clothing/accessory/lawyers_badge
	excludefromjob = list(JOB_LAWYER)
	item_owner = list(JOB_LAWYER)
	exists_on_map = TRUE
	difficulty = 1
	steal_hint = "Значок юриста. Обычно прикрепляется к груди, но запасной можно приобрести в вендормате."

/obj/item/clothing/accessory/lawyers_badge/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/clothing/accessory/lawyers_badge)

/datum/objective_item/steal/traitor/chief_engineer_belt
	name = "пояс главного инженера"
	targetitem = /obj/item/storage/belt/utility/chief
	excludefromjob = list(JOB_CHIEF_ENGINEER)
	exists_on_map = TRUE
	difficulty = 2
	steal_hint = "Пояс с инструментами главного инженера, постоянно носимый им."

/obj/item/storage/belt/utility/chief/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/storage/belt/utility/chief)

/datum/objective_item/steal/traitor/telebaton
	name = "телескопическую дубинку главы отдела"
	targetitem = /obj/item/melee/baton/telescopic
	excludefromjob = list(
		JOB_RESEARCH_DIRECTOR,
		JOB_CAPTAIN,
		JOB_HEAD_OF_SECURITY,
		JOB_HEAD_OF_PERSONNEL,
		JOB_CHIEF_ENGINEER,
		JOB_CHIEF_MEDICAL_OFFICER,
		JOB_QUARTERMASTER,
	)
	exists_on_map = TRUE
	difficulty = 3
	steal_hint = "Оружие самообороны, стандартное для всех глав отделов, за исключением главы службы безопасности. Редко находится не при владельце."

/datum/objective_item/steal/traitor/telebaton/check_special_completion(obj/item/thing)
	return !istype(thing, /obj/item/melee/baton/telescopic/contractor_baton)

/obj/item/melee/baton/telescopic/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/melee/baton/telescopic)

/datum/objective_item/steal/traitor/cargo_budget
	name = "бюджетную карта снабжения"
	targetitem = /obj/item/card/id/departmental_budget/car
	excludefromjob = list(JOB_QUARTERMASTER, JOB_CARGO_TECHNICIAN)
	item_owner = list(JOB_QUARTERMASTER)
	exists_on_map = TRUE
	difficulty = 2
	steal_hint = "Карточка, дающая доступ к фондам отдела снабжения. \
		Обычно она хранится в шкафчике квартирмейстера, но особо внимательные могут носить её при себе или в бумажнике."

/obj/item/card/id/departmental_budget/car/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/card/id/departmental_budget/car)

/datum/objective_item/steal/traitor/captain_modsuit
	name = "капитанский МОД-костюм магнат"
	targetitem = /obj/item/mod/control/pre_equipped/magnate
	excludefromjob = list(JOB_CAPTAIN)
	exists_on_map = TRUE
	difficulty = 3
	steal_hint = "Дорогая модификация ручной работы, изготовленная для капитана станции. \
		Если капитан не носит её, вы можете найти её в блоке хранилища костюмов в его каюте."

/obj/item/mod/control/pre_equipped/magnate/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/mod/control/pre_equipped/magnate)

/datum/objective_item/steal/traitor/captain_spare
	name = "запасную ID-карту капитана"
	targetitem = /obj/item/card/id/advanced/gold/captains_spare
	excludefromjob = list(
		JOB_RESEARCH_DIRECTOR,
		JOB_CAPTAIN,
		JOB_HEAD_OF_SECURITY,
		JOB_HEAD_OF_PERSONNEL,
		JOB_CHIEF_ENGINEER,
		JOB_CHIEF_MEDICAL_OFFICER,
		JOB_QUARTERMASTER,
	)
	exists_on_map = TRUE
	difficulty = 4
	steal_hint = "Запасная ID-карта самого главного на этой станции. \
		Если поблизости нет официального капитана, вы можете найти её на груди исполняющего обязанности капитана - одного из глав отдела."

/obj/item/card/id/advanced/gold/captains_spare/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/card/id/advanced/gold/captains_spare)

// High risk steal objectives

// Will always generate even with no Captain due to its security and temptation to use it
/datum/objective_item/steal/caplaser
	name = "капитанское антикварное лазерное оружие"
	targetitem = /obj/item/gun/energy/laser/captain
	excludefromjob = list(JOB_CAPTAIN)
	exists_on_map = TRUE
	difficulty = 4
	steal_hint = "Самозарядное антикварное лазерное оружие, что может быть найдено в витрине в каюте капитана. \
		Его вскрытие может вызвать тревогу системы безопасности, поэтому будьте осторожны."

/obj/item/gun/energy/laser/captain/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/gun/energy/laser/captain)

/datum/objective_item/steal/hoslaser
	name = "персональное лазерное оружие главы службы безопасности"
	targetitem = /obj/item/gun/energy/e_gun/hos
	excludefromjob = list(JOB_HEAD_OF_SECURITY)
	item_owner = list(JOB_HEAD_OF_SECURITY)
	exists_on_map = TRUE
	difficulty = 4
	steal_hint = "Уникальное трехрежимное лазерное оружие главы службы безопасности. \
		Всегда находится при нём, если он жив, но в противном случае может быть найден в его шкафчике."

/obj/item/gun/energy/e_gun/hos/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/gun/energy/e_gun/hos)

/datum/objective_item/steal/compactshotty
	name = "персональный компактный дробовик смотрителя"
	targetitem = /obj/item/gun/ballistic/shotgun/automatic/combat/compact
	excludefromjob = list(JOB_WARDEN)
	item_owner = list(JOB_WARDEN)
	exists_on_map = TRUE
	difficulty = 4
	steal_hint = "Миниатюрный боевой дробовик. Его можно найти в шкафчике смотрителя или на его спине."

/obj/item/gun/ballistic/shotgun/automatic/combat/compact/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/gun/ballistic/shotgun/automatic/combat/compact)

/datum/objective_item/steal/handtele
	name = "ручной телепортер"
	targetitem = /obj/item/hand_tele
	excludefromjob = list(JOB_CAPTAIN, JOB_RESEARCH_DIRECTOR, JOB_HEAD_OF_PERSONNEL)
	item_owner = list(JOB_CAPTAIN, JOB_RESEARCH_DIRECTOR)
	exists_on_map = TRUE
	difficulty = 3
	steal_hint = "На станции есть только два таких устройства, одно из которых находится в телепортерной \
		для экстренных случаев, а другое - в каюте капитана для личного пользования."

/obj/item/hand_tele/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/hand_tele)

/datum/objective_item/steal/jetpack
	name = "реактивный ранец капитана"
	targetitem = /obj/item/tank/jetpack/captain
	excludefromjob = list(JOB_CAPTAIN)
	item_owner = list(JOB_CAPTAIN)
	exists_on_map = TRUE
	difficulty = 3
	steal_hint = "Специальный жёлтый реактивный ранец может быть найден в блоке хранения костюмов в каюте капитана."

/obj/item/tank/jetpack/captain/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/tank/jetpack/captain)

/datum/objective_item/steal/magboots
	name = "продвинутые магнитные ботинки главного инженера"
	targetitem = /obj/item/clothing/shoes/magboots/advance
	excludefromjob = list(JOB_CHIEF_ENGINEER)
	item_owner = list(JOB_CHIEF_ENGINEER)
	exists_on_map = TRUE
	difficulty = 3
	steal_hint = "Пара магнитных ботинок, что могут быть найдены в блоке хранения костюмов главного инженера. \
		Их также можно найти на нём, спрятанные под МОД-костюмом."

/obj/item/clothing/shoes/magboots/advance/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/clothing/shoes/magboots/advance)

/datum/objective_item/steal/capmedal
	name = "медаль капитанства"
	targetitem = /obj/item/clothing/accessory/medal/gold/captain
	excludefromjob = list(JOB_CAPTAIN)
	item_owner = list(JOB_CAPTAIN)
	exists_on_map = TRUE
	difficulty = 3
	steal_hint = "Золотая медаль, что может быть найдена в коробке с медалями в каюте капитана. \
		У капитана обычно тоже есть такая медаль, приколотая к комбинезону."

/obj/item/clothing/accessory/medal/gold/captain/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/clothing/accessory/medal/gold/captain)

/datum/objective_item/steal/hypo
	name = "гипоспрей"
	targetitem = /obj/item/reagent_containers/hypospray/cmo
	excludefromjob = list(JOB_CHIEF_MEDICAL_OFFICER)
	item_owner = list(JOB_CHIEF_MEDICAL_OFFICER)
	exists_on_map = TRUE
	difficulty = 3
	steal_hint = "Персональный медицинский инжектор главного врача. \
		Обычно находящийся у него в медицинских принадлежностях или на поясе. Также может быть найден в шкафу в его кабинете."

/obj/item/reagent_containers/hypospray/cmo/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/reagent_containers/hypospray/cmo)

/datum/objective_item/steal/nukedisc
	name = "диск ядерной аутентификации"
	targetitem = /obj/item/disk/nuclear
	excludefromjob = list(JOB_CAPTAIN)
	difficulty = 5
	steal_hint = "Вы знаете ЭТОТ диск. Постоянно находится при капитане (возможно). \
		Его трудно не заметить, но если вы не можете его найти, у главы службы безопасности и капитана есть устройства, позволяющие отследить его точное местоположение."

/obj/item/disk/nuclear/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/disk/nuclear)

/datum/objective_item/steal/nukedisc/check_special_completion(obj/item/disk/nuclear/N)
	return !N.fake

/datum/objective_item/steal/ablative
	name = "абляционный плащ"
	targetitem = /obj/item/clothing/suit/hooded/ablative
	excludefromjob = list(JOB_HEAD_OF_SECURITY, JOB_WARDEN)
	item_owner = list(JOB_HEAD_OF_SECURITY)
	exists_on_map = TRUE
	difficulty = 4
	steal_hint = "Абляционный плащ, что может быть найден на полках в оружейной брига."

/obj/item/clothing/suit/hooded/ablative/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/clothing/suit/hooded/ablative)

/datum/objective_item/steal/reactive
	name = "реактивную телепортационную броню"
	targetitem = /obj/item/clothing/suit/armor/reactive/teleport
	excludefromjob = list(JOB_RESEARCH_DIRECTOR)
	item_owner = list(JOB_RESEARCH_DIRECTOR)
	exists_on_map = TRUE
	difficulty = 3
	steal_hint = "Специальная броня, что может быть у директора исследований. \
		Также может быть найдена в шкафчике в кабинете директора исследований."

/obj/item/clothing/suit/armor/reactive/teleport/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/clothing/suit/armor/reactive/teleport)

/datum/objective_item/steal/documents
	name = "любой набор секретных документов любой организации"
	valid_containers = list(/obj/item/folder)
	targetitem = /obj/item/documents
	exists_on_map = TRUE
	difficulty = 3
	steal_hint = "Набор документов, принадлежащих мегаконгломерату. \
		Документы Нанотрейзен можно легко найти в хранилище станции. \
		Что касается других корпораций, то вы можете найти их в странных и отдаленных местах. \
		Также может быть достаточно фотокопии."

/obj/item/documents/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/documents) //Any set of secret documents. Doesn't have to be NT's

/datum/objective_item/steal/nuke_core
	name = "высокорадиоактивный плутониевый сердечник из бортового устройства самоуничтожения"
	valid_containers = list(/obj/item/nuke_core_container)
	targetitem = /obj/item/nuke_core
	exists_on_map = TRUE
	difficulty = 4
	steal_hint = "Ядро устройства самоуничтожения станции. Находится в хранилище."

/obj/item/nuke_core/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/nuke_core)

/datum/objective_item/steal/nuke_core/New()
	special_equipment += /obj/item/storage/box/syndie_kit/nuke
	..()

/datum/objective_item/steal/hdd_extraction
	name = "исходный код Project Goon с мэйнфрейма главного сервера исследований и разработок"
	targetitem = /obj/item/disk/computer/hdd_theft
	excludefromjob = list(JOB_RESEARCH_DIRECTOR, JOB_SCIENTIST, JOB_ROBOTICIST, JOB_GENETICIST)
	item_owner = list(JOB_RESEARCH_DIRECTOR, JOB_SCIENTIST)
	exists_on_map = TRUE
	difficulty = 4
	steal_hint = "Жесткий диск из мастер-сервера исследовательского отдела. Находится в серверной отдела исследований и разработок."

/obj/item/disk/computer/hdd_theft/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/disk/computer/hdd_theft)

/datum/objective_item/steal/hdd_extraction/New()
	special_equipment += /obj/item/paper/guides/antag/hdd_extraction
	return ..()


/datum/objective_item/steal/supermatter
	name = "осколок кристалла суперматерии"
	targetitem = /obj/item/nuke_core/supermatter_sliver
	valid_containers = list(/obj/item/nuke_core_container/supermatter)
	difficulty = 5
	steal_hint = "Маленький осколок станционного двигателя суперматерии."

/datum/objective_item/steal/supermatter/New()
	special_equipment += /obj/item/storage/box/syndie_kit/supermatter
	..()

/datum/objective_item/steal/supermatter/target_exists()
	return GLOB.main_supermatter_engine != null

// Doesn't need item_owner = (JOB_AI) because this handily functions as a murder objective if there isn't one
/datum/objective_item/steal/functionalai
	name = "функционирующий ИИ"
	targetitem = /obj/item/aicard
	difficulty = 5
	steal_hint = "Интелкарта (или МОД-костюм), содержащий активный, функциональный искусственный интеллект."

/datum/objective_item/steal/functionalai/New()
	. = ..()
	altitems += typesof(/obj/item/mod/control) // only here so we can account for AIs tucked away in a MODsuit.

/datum/objective_item/steal/functionalai/check_special_completion(obj/item/potential_storage)
	var/mob/living/silicon/ai/being

	if(istype(potential_storage, /obj/item/aicard))
		var/obj/item/aicard/card = potential_storage
		being = card.AI // why is this one capitalized and the other one not? i wish i knew.
	else if(istype(potential_storage, /obj/item/mod/control))
		var/obj/item/mod/control/suit = potential_storage
		if(isAI(suit.ai_assistant))
			being = suit.ai_assistant
	else
		stack_trace("check_special_completion() called on [src] with [potential_storage] ([potential_storage.type])! That's not supposed to happen!")
		return FALSE

	if(isAI(being) && being.stat != DEAD)
		return TRUE

	return FALSE

/datum/objective_item/steal/blueprints
	name = "чертежи станции"
	targetitem = /obj/item/blueprints
	excludefromjob = list(JOB_CHIEF_ENGINEER)
	item_owner = list(JOB_CHIEF_ENGINEER)
	altitems = list(/obj/item/photo)
	exists_on_map = TRUE
	difficulty = 3
	steal_hint = "Чертежи станции можно найти в шкафчике главного инженера или при нём самом. Может подойти фотография чертежей."

/obj/item/blueprints/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/blueprints)

/datum/objective_item/steal/blueprints/check_special_completion(obj/item/I)
	if(istype(I, /obj/item/blueprints))
		return TRUE
	if(istype(I, /obj/item/photo))
		var/obj/item/photo/P = I
		if(P.picture.has_blueprints) //if the blueprints are in frame
			return TRUE
	return FALSE

/datum/objective_item/steal/blackbox
	name = "чёрный ящик"
	targetitem = /obj/item/blackbox
	excludefromjob = list(JOB_CHIEF_ENGINEER, JOB_STATION_ENGINEER, JOB_ATMOSPHERIC_TECHNICIAN)
	exists_on_map = TRUE
	difficulty = 4
	steal_hint = "Черный ящик данных станции, доступный исключительно в телекоммуникационной."
	destruction_method = "Слишком крепкий, чтобы его можно было уничтожить обычными средствами - его нужно стереть в порошок с помощью суперматерии или сжечь в крематории церкви."

/obj/item/blackbox/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/blackbox)


// A number of special early-game steal objectives intended to be used with the steal-and-destroy objective.
// They're basically items of utility or emotional value that may be found on many players or lying around the station.
/datum/objective_item/steal/traitor/insuls
	name = "пара изоляционных перчаток"
	targetitem = /obj/item/clothing/gloves/color/yellow
	excludefromjob = list(JOB_CARGO_TECHNICIAN, JOB_QUARTERMASTER, JOB_ATMOSPHERIC_TECHNICIAN, JOB_STATION_ENGINEER, JOB_CHIEF_ENGINEER)
	item_owner = list(JOB_STATION_ENGINEER, JOB_CHIEF_ENGINEER)
	exists_on_map = TRUE
	difficulty = 1
	steal_hint = "Обычная пара изоляционных перчаток, которые обычно носят ассистенты, инженеры или грузчики."

/obj/item/clothing/gloves/color/yellow/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/clothing/gloves/color/yellow)

/datum/objective_item/steal/traitor/moth_plush
	name = "милая плюшевая моль"
	targetitem = /obj/item/toy/plush/moth
	excludefromjob = list(JOB_PSYCHOLOGIST, JOB_PARAMEDIC, JOB_CHEMIST, JOB_MEDICAL_DOCTOR, JOB_CHIEF_MEDICAL_OFFICER, JOB_CORONER)
	exists_on_map = TRUE
	difficulty = 1
	steal_hint = "Плюшевая моль. Может быть найдена у психолога, что лечит душевные травмы этой молью."

/obj/item/toy/plush/moth/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/toy/plush/moth)

/datum/objective_item/steal/traitor/lizard_plush
	name = "милая плюшевая ящерица"
	targetitem = /obj/item/toy/plush/lizard_plushie
	exists_on_map = TRUE
	difficulty = 1
	steal_hint = "Плюшевая ящерица. Может быть найдена в технических тоннелях."

/obj/item/toy/plush/lizard_plushie/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/toy/plush/lizard_plushie)

/datum/objective_item/steal/traitor/denied_stamp
	name = "штамп \"отклонено\" отдела снабжения"
	targetitem = /obj/item/stamp/denied
	excludefromjob = list(JOB_CARGO_TECHNICIAN, JOB_QUARTERMASTER, JOB_SHAFT_MINER)
	exists_on_map = TRUE
	difficulty = 1
	steal_hint = "В отделе снабжения часто валяется несколько таких красных штампов для обработки документов."

/obj/item/stamp/denied/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/stamp/denied)

/datum/objective_item/steal/traitor/granted_stamp
	name = "штамп \"одобрено\" отдела снабжения"
	targetitem = /obj/item/stamp/granted
	excludefromjob = list(JOB_CARGO_TECHNICIAN, JOB_QUARTERMASTER, JOB_SHAFT_MINER)
	exists_on_map = TRUE
	difficulty = 1
	steal_hint = "В отделе снабжения часто валяется несколько таких зелёных штампов для обработки документов."

/obj/item/stamp/granted/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/stamp/granted)

/datum/objective_item/steal/traitor/space_law
	name = "книга космического закона"
	targetitem = /obj/item/book/manual/wiki/security_space_law
	excludefromjob = list(JOB_SECURITY_OFFICER, JOB_WARDEN, JOB_HEAD_OF_SECURITY, JOB_LAWYER, JOB_DETECTIVE)
	exists_on_map = TRUE
	difficulty = 1
	steal_hint = "Может быть найдена у офицеров службы безопасности и юристов. \
		Зал суда, бриг и библиотека хорошие места, чтобы найти это."

/obj/item/book/manual/wiki/security_space_law/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/book/manual/wiki/security_space_law)

/datum/objective_item/steal/traitor/rpd
	name = "быстрый раздатчик труб"
	targetitem = /obj/item/pipe_dispenser
	excludefromjob = list(
		JOB_ATMOSPHERIC_TECHNICIAN,
		JOB_STATION_ENGINEER,
		JOB_CHIEF_ENGINEER,
		JOB_SCIENTIST,
		JOB_RESEARCH_DIRECTOR,
		JOB_GENETICIST,
		JOB_ROBOTICIST,
	)
	item_owner = list(JOB_CHIEF_ENGINEER)
	exists_on_map = TRUE
	difficulty = 1
	steal_hint = "Инструмент, используемый инженерами, атмосферными техниками и учёными."

/obj/item/pipe_dispenser/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/pipe_dispenser)

/datum/objective_item/steal/traitor/donut_box
	name = "коробка отборных пончиков"
	targetitem = /obj/item/storage/fancy/donut_box
	excludefromjob = list(
		JOB_CAPTAIN,
		JOB_CHIEF_ENGINEER,
		JOB_HEAD_OF_PERSONNEL,
		JOB_HEAD_OF_SECURITY,
		JOB_QUARTERMASTER,
		JOB_CHIEF_MEDICAL_OFFICER,
		JOB_RESEARCH_DIRECTOR,
		JOB_SECURITY_OFFICER,
		JOB_WARDEN,
		JOB_LAWYER,
		JOB_DETECTIVE,
	)
	exists_on_map = TRUE
	difficulty = 1
	steal_hint = "У всех есть коробки с пончиками. Можно найти на мостике, бриге или в комнате отдыха отделов."

/obj/item/storage/fancy/donut_box/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/storage/fancy/donut_box)

/datum/objective_item/steal/spy
	objective_type = OBJECTIVE_ITEM_TYPE_SPY

/datum/objective_item/steal/spy/lamarr
	name = "хедкраб директора исследований"
	targetitem = /obj/item/clothing/mask/facehugger/lamarr
	excludefromjob = list(JOB_RESEARCH_DIRECTOR)
	exists_on_map = TRUE
	difficulty = 3
	steal_hint = "Ламарр, хедкраб директора исследований. Может быть найден в кабинете директора исследований."

/obj/item/clothing/mask/facehugger/lamarr/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/clothing/mask/facehugger/lamarr)

/datum/objective_item/steal/spy/disabler
	name = "дизейблер"
	targetitem = /obj/item/gun/energy/disabler
	excludefromjob = list(
		JOB_CAPTAIN,
		JOB_DETECTIVE,
		JOB_HEAD_OF_PERSONNEL,
		JOB_HEAD_OF_SECURITY,
		JOB_SECURITY_OFFICER,
		JOB_WARDEN,
	)
	difficulty = 2
	steal_hint = "Ручной дизейблер, часто находящийся в распоряжении офицеров службы безопасности."

/datum/objective_item/steal/spy/energy_gun
	name = "энергетический карабин"
	targetitem = /obj/item/gun/energy/e_gun
	excludefromjob = list(
		JOB_CAPTAIN,
		JOB_CHIEF_ENGINEER,
		JOB_CHIEF_MEDICAL_OFFICER,
		JOB_DETECTIVE,
		JOB_HEAD_OF_PERSONNEL,
		JOB_HEAD_OF_SECURITY,
		JOB_QUARTERMASTER,
		JOB_RESEARCH_DIRECTOR,
		JOB_SECURITY_OFFICER,
		JOB_WARDEN,
	)
	exists_on_map = TRUE
	difficulty = 2
	steal_hint = "Двухрежимный энергетический карабин, что может быть найден в оружейной брига. Также может быть у некоторых глав для их персональной защиты."

/datum/objective_item/steal/spy/energy_gun/check_special_completion(obj/item/thing)
	return thing.type == /obj/item/gun/energy/e_gun

/obj/item/gun/energy/e_gun/add_stealing_item_objective()
	if(type == /obj/item/gun/energy/e_gun)
		return add_item_to_steal(src, /obj/item/gun/energy/e_gun)

/datum/objective_item/steal/spy/laser_gun
	name = "лазерный карабин"
	targetitem = /obj/item/gun/energy/laser
	excludefromjob = list(
		JOB_CAPTAIN,
		JOB_CHIEF_ENGINEER,
		JOB_CHIEF_MEDICAL_OFFICER,
		JOB_DETECTIVE,
		JOB_HEAD_OF_PERSONNEL,
		JOB_HEAD_OF_SECURITY,
		JOB_QUARTERMASTER,
		JOB_RESEARCH_DIRECTOR,
		JOB_SECURITY_OFFICER,
		JOB_WARDEN,
	)
	exists_on_map = TRUE
	difficulty = 3
	steal_hint = "Простой лазерный карабин, что может быть найден в оружейной брига."

/datum/objective_item/steal/spy/laser_gun/check_special_completion(obj/item/thing)
	return thing.type == /obj/item/gun/energy/laser

/obj/item/gun/energy/laser/add_stealing_item_objective()
	if(type == /obj/item/gun/energy/laser)
		return add_item_to_steal(src, /obj/item/gun/energy/laser)

/datum/objective_item/steal/spy/shotgun
	name = "служебный дробовик"
	targetitem = /obj/item/gun/ballistic/shotgun/riot
	excludefromjob = list(
		JOB_DETECTIVE,
		JOB_HEAD_OF_PERSONNEL,
		JOB_HEAD_OF_SECURITY,
		JOB_SECURITY_OFFICER,
		JOB_WARDEN,
	)
	exists_on_map = TRUE
	difficulty = 3
	steal_hint = "Служебный дробовик для подавления бунтов, что может быть найден в оружейной брига."

/obj/item/gun/ballistic/shotgun/riot/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/gun/ballistic/shotgun/riot)

/datum/objective_item/steal/spy/temp_gun
	name = "температурная винтовка СБ"
	targetitem = /obj/item/gun/energy/temperature/security
	excludefromjob = list(
		JOB_DETECTIVE,
		JOB_HEAD_OF_PERSONNEL,
		JOB_HEAD_OF_SECURITY,
		JOB_SECURITY_OFFICER,
		JOB_WARDEN,
	)
	exists_on_map = TRUE
	difficulty = 2 // lowered for the meme
	steal_hint = "Надёжная температурная винтовка службы безопасности, что может быть найдена в оружейной брига."

/obj/item/gun/energy/temperature/security/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/gun/energy/temperature/security)

/datum/objective_item/steal/spy/stamp
	name = "штамп главы"
	targetitem = /obj/item/stamp/head
	excludefromjob = list(
		JOB_CAPTAIN,
		JOB_CHIEF_ENGINEER,
		JOB_CHIEF_MEDICAL_OFFICER,
		JOB_HEAD_OF_PERSONNEL,
		JOB_HEAD_OF_SECURITY,
		JOB_QUARTERMASTER,
		JOB_RESEARCH_DIRECTOR,
	)
	exists_on_map = TRUE
	difficulty = 1
	steal_hint = "Штамп, принадлежащий главе отдела, что может быть найден в их офисе."

/obj/item/stamp/head/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/stamp/head)

/datum/objective_item/steal/spy/sunglasses
	name = "какие-нибудь солнцезащитные очки"
	targetitem = /obj/item/clothing/glasses/sunglasses
	excludefromjob = list(
		JOB_CAPTAIN,
		JOB_CHIEF_ENGINEER,
		JOB_CHIEF_MEDICAL_OFFICER,
		JOB_HEAD_OF_PERSONNEL,
		JOB_HEAD_OF_SECURITY,
		JOB_LAWYER,
		JOB_QUARTERMASTER,
		JOB_RESEARCH_DIRECTOR,
		JOB_SECURITY_OFFICER,
		JOB_WARDEN,
	)
	difficulty = 1
	steal_hint = "Пара солнцезащитных очков. У юристов обычно есть несколько штук, как и у некоторых глав. Также их можно получить, разобрав ИЛС-очки."

/datum/objective_item/steal/spy/ce_modsuit
	name = "продвинутый МОД-костюм главного инженера"
	targetitem = /obj/item/mod/control/pre_equipped/advanced
	excludefromjob = list(JOB_CHIEF_ENGINEER)
	exists_on_map = TRUE
	difficulty = 2
	steal_hint = "Продвинутая версия стандартного инженерного МОД-костюма. Можно найти у главного инженера или в его кабинете."

/obj/item/mod/control/pre_equipped/advanced/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/mod/control/pre_equipped/advanced)

/datum/objective_item/steal/spy/rd_modsuit
	name = "МОД-костюм директора исследований"
	targetitem = /obj/item/mod/control/pre_equipped/research
	excludefromjob = list(JOB_RESEARCH_DIRECTOR)
	exists_on_map = TRUE
	difficulty = 2
	steal_hint = "Громоздкий МОД-костюм директора исследований для работы в опасных условиях. Можно найти у директора исследований или в его кабинете."

/obj/item/mod/control/pre_equipped/research/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/mod/control/pre_equipped/research)

/datum/objective_item/steal/spy/cmo_modsuit
	name = "МОД-костюм главного врача"
	targetitem = /obj/item/mod/control/pre_equipped/rescue
	excludefromjob = list(JOB_CHIEF_MEDICAL_OFFICER)
	exists_on_map = TRUE
	difficulty = 2
	steal_hint = "МОД-костюм, который главный врач иногда использует для спасательных операций в опасных условиях."

/obj/item/mod/control/pre_equipped/rescue/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/mod/control/pre_equipped/rescue)

/datum/objective_item/steal/spy/cmo_defib
	name = "Chief Medical Officer's Compact Defibrillator"
	targetitem = /obj/item/defibrillator/compact/loaded/cmo
	excludefromjob = list(JOB_CHIEF_MEDICAL_OFFICER)
	exists_on_map = TRUE
	difficulty = 2
	steal_hint = "The Compact Defibrillator, found on their person, or in their closet."

/obj/item/defibrillator/compact/loaded/cmo/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/defibrillator/compact/loaded/cmo)

/datum/objective_item/steal/spy/hos_modsuit
	name = "МОД-костюм главы службы безопасности"
	targetitem = /obj/item/mod/control/pre_equipped/safeguard
	excludefromjob = list(JOB_HEAD_OF_SECURITY)
	exists_on_map = TRUE
	difficulty = 2
	steal_hint = "Продвинутый МОД-костюм, который глава службы безопасности иногда использует для задержания враждебно настроенных нарушителей на станции."

/obj/item/mod/control/pre_equipped/safeguard/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/mod/control/pre_equipped/safeguard)

/datum/objective_item/steal/spy/stun_baton
	name = "оглушающая дубинка"
	targetitem = /obj/item/melee/baton/security
	excludefromjob = list(
		JOB_CAPTAIN,
		JOB_DETECTIVE,
		JOB_HEAD_OF_PERSONNEL,
		JOB_HEAD_OF_SECURITY,
		JOB_SECURITY_OFFICER,
		JOB_WARDEN,
	)
	difficulty = 2
	steal_hint = "Украдите любую оглушающую дубинку у офицера службы безопасности. Или найдите в бриге."

/datum/objective_item/steal/spy/stun_baton/check_special_completion(obj/item/thing)
	return !istype(thing, /obj/item/melee/baton/security/cattleprod)

/datum/objective_item/steal/spy/det_baton
	name = "дубинка детектива"
	targetitem = /obj/item/melee/baton
	excludefromjob = list(
		JOB_CAPTAIN,
		JOB_DETECTIVE,
		JOB_HEAD_OF_PERSONNEL,
		JOB_HEAD_OF_SECURITY,
		JOB_SECURITY_OFFICER,
		JOB_WARDEN,
	)
	exists_on_map = TRUE
	difficulty = 2
	steal_hint = "Старая дубинка детектива, обычно при нём для самообороны."

/datum/objective_item/steal/spy/det_baton/check_special_completion(obj/item/thing)
	return thing.type == /obj/item/melee/baton

/obj/item/melee/baton/add_stealing_item_objective()
	if(type == /obj/item/melee/baton)
		return add_item_to_steal(src, /obj/item/melee/baton)

/datum/objective_item/steal/spy/captain_sabre_sheathe
	name = "ножны капитанской сабли"
	targetitem = /obj/item/storage/belt/sheath/sabre
	excludefromjob = list(JOB_CAPTAIN)
	exists_on_map = TRUE
	difficulty = 3
	steal_hint = "Ножны для капитанской сабли. Их можно найти в гардеробе капитана или на его поясе — он носит их постоянно."

/obj/item/storage/belt/sheath/sabre/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/storage/belt/sheath/sabre)
