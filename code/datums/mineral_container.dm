/*
	This datum should be used for handling mineral contents of machines and whatever else is supposed to hold minerals and make use of them.
	One mineral_container var can only handle one type of mineral.

	Variables:
		amount - raw amount of the mineral this container is holding, calculated by the defined value MINERAL_MATERIAL_AMOUNT=2000.
		max_amount - max raw amount of mineral this container can hold.
		sheet_type - type of the mineral sheet the container handles, used for output.
		owner - object that this container is being used by, used for output.
		MAX_STACK_SIZE - size of a stack of mineral sheets. Constant.
*/
/datum/mineral_container
	var/amount
	var/max_amount
	var/sheet_type
	var/obj/owner
	//MAX_STACK_SIZE = 50
	//MINERAL_MATERIAL_AMOUNT = 2000

/datum/mineral_container/New(obj/O, type, max_amt = 0, amt = 0)
	if(!O)	return
	owner = O
	sheet_type = type
	amount = max(0, amt)
	max_amount = max(0, max_amt)

//For inserting an amount of mineral sheets
/datum/mineral_container/proc/insert(sheet_amt)
	if(sheet_amt > 0)
		var/amt = sheet_amt * MINERAL_MATERIAL_AMOUNT
		if(amt <= (max_amount - amount))
			amount += amt
			return sheet_amt
	return 0

//For inserting a mineral sheet
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

//For inserting an amount of material
/datum/mineral_container/proc/insert_amount(amt)
	if(amt > 0 & !isFull())
		if(amt <= max_amount - amount)
			amount += amt
			return amt
	return 0

//For consuming material (amt = amount of material)
/datum/mineral_container/proc/use_amount(amt)
	if(amt > 0 & !isEmpty())
		if(amount >= amt)
			amount -= amt
			return amt
	return 0

//For consuming material (sheet_amt = amount of material equivalent to a number of sheets)
/datum/mineral_container/proc/use_sheets(sheet_amt)
	if(sheet_amt > 0 & !isEmpty())
		if(amount >= (sheet_amt * MINERAL_MATERIAL_AMOUNT))
			amount -= sheet_amt
			return sheet_amt
	return 0

//For spawning mineral sheets
/datum/mineral_container/proc/retrieve(sheet_amt)
	if(sheet_amt > 0 && amount >= (sheet_amt * MINERAL_MATERIAL_AMOUNT))
		var/count = 0
		var/obj/item/stack/sheet/S

		while(sheet_amt > MAX_STACK_SIZE)
			S = new sheet_type(get_turf(owner))
			S.amount = MAX_STACK_SIZE
			count += MAX_STACK_SIZE
			amount -= MAX_STACK_SIZE * MINERAL_MATERIAL_AMOUNT
			sheet_amt -= MAX_STACK_SIZE

		if(round(amount / MINERAL_MATERIAL_AMOUNT))
			S = new sheet_type(get_turf(owner))
			S.amount = sheet_amt
			count += sheet_amt
			amount -= sheet_amt * MINERAL_MATERIAL_AMOUNT
		return count
	return 0

/datum/mineral_container/proc/retrieve_amount(amt)
	return retrieve(amount2sheet(amt))

/datum/mineral_container/proc/retrieve_all()
	return retrieve(amount2sheet(amount))

/datum/mineral_container/proc/accepts(obj/O)
	return istype(O,sheet_type)

/datum/mineral_container/proc/isFull(amt = 0)
	return (amount + amt) >= max_amount

/datum/mineral_container/proc/isEmpty(amt = 0)
	return (amount - amt) <= 0

/datum/mineral_container/proc/amount2sheet(amt)
	if(amt >= MINERAL_MATERIAL_AMOUNT)
		return round(amt / MINERAL_MATERIAL_AMOUNT)
	return 0

/datum/mineral_container/proc/sheet2amount(sheet_amt)
	if(sheet_amt > 0)
		return sheet_amt * MINERAL_MATERIAL_AMOUNT
	return 0
