/datum/uplink_category/contractor
	name = "Contractor"
	weight = 10

/datum/uplink_item/bundles_tc/contract_kit
	name = "Contract Kit"
	desc = "Синдикат предложил вам стать контрактником и взять на себя контракты на похищение людей за TК \
		и денежные выплаты. После покупке вам будет предоставлен собственный аплинк контрактора, встроенный в прилагаемый \
		планшет. Кроме того, вам будет предоставлено стандартное снаряжение контрактника, которое поможет вам в выполнении вашей миссии - \
		планшет, специализированный скафандр, комбинезон и маска-хамелеон, карточка агента, \
		и специализированная дубинка контрактника."
	item = /obj/item/storage/box/syndicate/contract_kit
	category = /datum/uplink_category/contractor
	cost = 20
	purchasable_from = UPLINK_TRAITORS
	population_minimum = TRAITOR_POPULATION_LOWPOP

/datum/uplink_item/bundles_tc/contract_kit/purchase(mob/user, datum/uplink_handler/uplink_handler, atom/movable/source)
	. = ..()
	for(var/uplink_items in subtypesof(/datum/uplink_item/contractor))
		var/datum/uplink_item/uplink_item = new uplink_items
		uplink_handler.extra_purchasable += uplink_item

/datum/uplink_item/contractor
	restricted = TRUE
	category = /datum/uplink_category/contractor
	purchasable_from = NONE //they will be added to extra_purchasable

//prevents buying contractor stuff before you make an account.
/datum/uplink_item/contractor/can_be_bought(datum/uplink_handler/uplink_handler)
	if(!uplink_handler.contractor_hub)
		return FALSE
	return ..()

/datum/uplink_item/contractor/reroll
	name = "Contract Reroll"
	desc = "Запросите обновление вашего текущего списка контрактов. Создаст новую цель, \
		оплату и места для транспортировки ваших текущих доступных контрактов."
	item = ABSTRACT_UPLINK_ITEM
	limited_stock = 2
	cost = 0

/datum/uplink_item/contractor/reroll/spawn_item(spawn_path, mob/user, datum/uplink_handler/uplink_handler, atom/movable/source)
	//We're not regenerating already completed/aborted/extracting contracts, but we don't want to repeat their targets.
	var/list/new_target_list = list()
	for(var/datum/syndicate_contract/contract_check in uplink_handler.contractor_hub.assigned_contracts)
		if (contract_check.status != CONTRACT_STATUS_ACTIVE && contract_check.status != CONTRACT_STATUS_INACTIVE)
			if (contract_check.contract.target)
				new_target_list.Add(contract_check.contract.target)
			continue

	//Reroll contracts without duplicates
	for(var/datum/syndicate_contract/rerolling_contract in uplink_handler.contractor_hub.assigned_contracts)
		if (rerolling_contract.status != CONTRACT_STATUS_ACTIVE && rerolling_contract.status != CONTRACT_STATUS_INACTIVE)
			continue

		rerolling_contract.generate(new_target_list)
		new_target_list.Add(rerolling_contract.contract.target)

	//Set our target list with the new set we've generated.
	uplink_handler.contractor_hub.assigned_targets = new_target_list
	return source //for log icon

/datum/uplink_item/contractor/pinpointer
	name = "Contractor Pinpointer"
	desc = "Пинпоинтер, который находит цели даже без активных датчиков костюма. \
		Из-за использования эксплойта внутри системы он не может точно определять \
		с той же точностью, что и традиционные модели. \
		Становится навсегда заблокированным для пользователя, который первым его активировал."
	item = /obj/item/pinpointer/crew/contractor
	limited_stock = 2
	cost = 1

/datum/uplink_item/contractor/extraction_kit
	name = "Fulton Extraction Kit"
	desc = "Для того, чтобы доставлять вашу цель через станцию ​​к этим трудным зонам отправки. \
		Установите маяк в безопасное место и соедините устройство. \
		Активация устройства на вашей цели отправит ее к маяку - \
		убедитесь, что они не смогут просто убежать!"
	item = /obj/item/storage/box/contractor/fulton_extraction
	limited_stock = 1
	cost = 1

/datum/uplink_item/contractor/partner
	name = "Contractor Reinforcement"
	desc = "Подкрепление в виде оперативника будет отправлено для помощи в достижении ваших целей - \
		они оплачиваются отдельно и не отнимают часть вашей прибыли."
	item = /obj/item/antag_spawner/loadout/contractor
	limited_stock = 1
	cost = 2
