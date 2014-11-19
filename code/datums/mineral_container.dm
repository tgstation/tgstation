/*
	This datum should be used for handling mineral contents of machines and whatever else is supposed to hold minerals and make use of them.
	One mineral_container var can only handle one type of mineral.

	Variables:
		amount - raw amount of the mineral this container holds, calculated by the defined value MINERAL_MATERIAL_AMOUNT=2000.
		max_amount - raw amount of mineral this container can hold.
		sheet_type - type of the mineral sheet the container handles, used for output.
		location - location of the object that this container is being used by, used for output.
		sheet_stack_size - size of a stack of mineral sheets. Constant.
*/
/datum/mineral_container
	var/amount
	var/max_amount
	var/sheet_type
	var/location
	var/const/sheet_stack_size = 50
	//MINERAL_MATERIAL_AMOUNT = 2000

/datum/mineral_container/New(obj/O, sht_type, max_amt = 0, amt = 0)
	if(!O)
		return
	location = get_turf(O.loc)

	sheet_type = sht_type

	if(amt < 0)
		amount = 0
	else
		amount = amt

	if(max_amt < 0)
		max_amount = 0
	else
		max_amount = max_amt

/datum/mineral_container/proc/insert(sheet_amt)
	if(sheet_amt > 0)
		var/amt = sheet_amt * MINERAL_MATERIAL_AMOUNT
		if(amt <= (max_amount - amount))
			amount += amt
			return sheet_amt
	return 0

/datum/mineral_container/proc/insert_sheet(obj/S)
	if(accepts(S))
		if(!isFull())
			var/obj/item/stack/sheet/sheet = S
			var/sht_amt = amount2sheet(max_amount - amount)
			if(sht_amt >= sheet.amount)
				return insert(sheet.amount)
			else
				return insert(sht_amt)
		return 0
	return -1

/datum/mineral_container/proc/insert_amount(amt)
	if(amt > 0 & !isFull())
		if(amt <= max_amount - amount)
			amount += amt
			return amt
	return 0

/datum/mineral_container/proc/use_amount(amt) //for consuming mineral
	if(amt > 0 & !isEmpty())
		if(amount >= amt)
			amount -= amt
			return amt
	return 0

/datum/mineral_container/proc/use_sheets(sheet_amt) //for consuming mineral
	if(sheet_amt > 0 & !isEmpty())
		if(amount >= (sheet_amt * MINERAL_MATERIAL_AMOUNT))
			amount -= sheet_amt
			return sheet_amt
	return 0

/datum/mineral_container/proc/retrieve(sheet_amt)
	if(sheet_amt > 0 && amount >= (sheet_amt * MINERAL_MATERIAL_AMOUNT))
		var/count = 0
		var/obj/item/stack/sheet/S

		while(sheet_amt > sheet_stack_size)
			S = new sheet_type(location)
			S.amount = sheet_stack_size
			count += sheet_stack_size
			amount -= sheet_stack_size * MINERAL_MATERIAL_AMOUNT
			sheet_amt -= sheet_stack_size

		if(round(amount / MINERAL_MATERIAL_AMOUNT))
			S = new sheet_type(location)
			S.amount = sheet_amt
			count += sheet_amt
			amount -= sheet_amt * MINERAL_MATERIAL_AMOUNT
		return count
	return 0

/datum/mineral_container/proc/retrieve_amount(amt)
	return retrieve(amount2sheet(amt))

/datum/mineral_container/proc/retrieve_all()
	return retrieve(amount2sheet(amount))

/datum/mineral_container/proc/modLoc(obj/O) //obj/O is the object using the container (example: autolathe) ; Use if the object using the container is not stationary or somehow changes place.
	if(!O)
		return
	location = get_turf(O.loc)

/datum/mineral_container/proc/accepts(obj/O)
	return istype(O,sheet_type)

/datum/mineral_container/proc/isFull()
	return amount >= max_amount

/datum/mineral_container/proc/isEmpty()
	return amount <= 0

/datum/mineral_container/proc/getAmount()
	return amount

/datum/mineral_container/proc/getMaxAmount()
	return max_amount

/datum/mineral_container/proc/getType()
	return sheet_type

/datum/mineral_container/proc/amount2sheet(amt)
	if(amt >= MINERAL_MATERIAL_AMOUNT)
		return round(amt / MINERAL_MATERIAL_AMOUNT)
	return 0

/datum/mineral_container/proc/sheet2amount(sheet_amt)
	if(sheet_amt > 0)
		return sheet_amt * MINERAL_MATERIAL_AMOUNT
	return 0

/datum/mineral_container/proc/upgrade(M)
	max_amount = M