///This proc is used to initialize holochips, cash and coins inside our persistent piggy bank.
/datum/controller/subsystem/persistence/proc/load_piggy_bank(obj/item/piggy_bank/piggy)
	if(isnull(piggy_banks_database))
		piggy_banks_database = new("data/piggy_banks.json")

	var/list/data = piggy_banks_database.get_key(piggy.persistence_id)
	if(isnull(data))
		return
	var/total_value = 0
	for(var/iteration in 1 to length(data))
		var/money_path = text2path(data[iteration])
		if(!money_path) //For a reason or another, it was removed.
			continue
		var/obj/item/spawned
		if(ispath(money_path, /obj/item/holochip))
			//We want to safely access the assoc of this position and not that of last key that happened to match this one.
			var/list/key_and_assoc = data.Copy(iteration, iteration + 1)
			var/amount = key_and_assoc["[money_path]"]
			spawned = new money_path (piggy, amount)
		//the operations are identical to those of chips, but they're different items, so I'll keep them separated.
		else if(ispath(money_path, /obj/item/stack/spacecash))
			var/list/key_and_assoc = data.Copy(iteration, iteration + 1)
			var/amount = key_and_assoc["[money_path]"]
			spawned = new money_path (piggy, amount)
		else if(ispath(money_path, /obj/item/coin))
			spawned = new money_path (piggy)
		else
			stack_trace("Unsupported path found in the data of a persistent piggy bank. item: [money_path], id:[piggy.persistence_id]")
			continue
		total_value += spawned.get_item_credit_value()
		if(total_value >= piggy.maximum_value)
			break

///This proc is used to save money stored inside our persistent the piggy bank for the next time it's loaded.
/datum/controller/subsystem/persistence/proc/save_piggy_bank(obj/item/piggy_bank/piggy)
	if(isnull(piggy_banks_database))
		return

	if(queued_broken_piggy_ids)
		for(var/broken_id in queued_broken_piggy_ids)
			piggy_banks_database.remove(broken_id)
		queued_broken_piggy_ids = null

	var/list/data = list()
	for(var/obj/item/item as anything in piggy.contents)
		var/piggy_value = 1
		if(istype(item, /obj/item/holochip))
			var/obj/item/holochip/chip = item
			piggy_value = chip.credits
		else if(istype(item, /obj/item/stack/spacecash))
			var/obj/item/stack/spacecash/cash = item
			piggy_value = cash.amount
		else if(!istype(item, /obj/item/coin))
			continue
		data += list("[item.type]" = piggy_value)
	piggy_banks_database.set_key(piggy.persistence_id, data)
