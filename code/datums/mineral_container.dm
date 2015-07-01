/*
	This datum should be used for handling mineral contents of machines and whatever else is supposed to hold minerals and make use of them.

	Variables:
		amount - raw amount of the mineral this container is holding, calculated by the defined value MINERAL_MATERIAL_AMOUNT=2000.
		max_amount - max raw amount of mineral this container can hold.
		sheet_type - type of the mineral sheet the container handles, used for output.
		owner - object that this container is being used by, used for output.
		MAX_STACK_SIZE - size of a stack of mineral sheets. Constant.
*/

#define TYPE_METAL		1
#define TYPE_GLASS		2
#define TYPE_SILVER		4
#define TYPE_GOLD		8
#define TYPE_DIAMOND	16
#define TYPE_URANIUM	32
#define TYPE_PLASMA		64
#define TYPE_BANANIUM	128

/datum/material_container
	var/amount
	var/total_amount = 0
	var/max_amount
	var/sheet_type
	var/obj/owner
	var/list/materials = list(MAT_METAL=0, MAT_GLASS=0, MAT_SILVER=0, MAT_GOLD=0, MAT_DIAMOND=0, MAT_URANIUM=0, MAT_PLASMA=0, MAT_BANANIUM=0)
	var/valid_minerals = 0
	//MAX_STACK_SIZE = 50
	//MINERAL_MATERIAL_AMOUNT = 2000

/datum/material_container/New(obj/O, valid_m = 0, max_amt = 0)
	owner = O
	max_amount = max(0, max_amt)
	valid_minerals = valid_m

//For inserting an amount of mineral sheets
/datum/material_container/proc/insert(sheet_amt)
	if(sheet_amt > 0)
		var/amt = sheet_amt * MINERAL_MATERIAL_AMOUNT
		if(amt <= (max_amount - amount))
			amount += amt
			return sheet_amt
	return 0

//For inserting a mineral sheet
/datum/material_container/proc/insert_sheet(obj/S)
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
/datum/material_container/proc/insert_amount(amt)
	if(amt > 0 & !isFull())
		if(amt <= max_amount - amount)
			amount += amt
			return amt
	return 0

/datum/material_container/proc/insert_stack(obj/item/stack/S, amt = 0)
	if(!amt)
		amt = S.amount
	var/material_amt = S.get_item_materials_amount()

	while(isFull(material_amt * amt))
		amt--

	if(!amt)
		return 0

	for(var/i=0, i < amt, i++)
		insert_materials(S)
	S.use(amt)
	return amt

/datum/material_container/proc/insert_item(obj/item/I)
	if(!I)
		return 0
	if(istype(I,/obj/item/stack))
		return insert_stack(I)

	var/amt = I.get_item_materials_amount()
	if(!amt || isFull(amt))
		return 0

	insert_materials(I)
	return amt

/datum/material_container/proc/insert_materials(obj/item/I) //for internal usage only
	if(valid_minerals & TYPE_METAL)
		materials[MAT_METAL] += I.materials[MAT_METAL]
		total_amount += I.materials[MAT_METAL]

	if(valid_minerals & TYPE_GLASS)
		materials[MAT_GLASS] += I.materials[MAT_GLASS]
		total_amount += I.materials[MAT_GLASS]

	if(valid_minerals & TYPE_SILVER)
		materials[MAT_SILVER] += I.materials[MAT_SILVER]
		total_amount += I.materials[MAT_SILVER]

	if(valid_minerals & TYPE_GOLD)
		materials[MAT_GOLD] += I.materials[MAT_GOLD]
		total_amount += I.materials[MAT_GOLD]

	if(valid_minerals & TYPE_DIAMOND)
		materials[MAT_DIAMOND] += I.materials[MAT_DIAMOND]
		total_amount += I.materials[MAT_DIAMOND]

	if(valid_minerals & TYPE_URANIUM)
		materials[MAT_URANIUM] += I.materials[MAT_URANIUM]
		total_amount += I.materials[MAT_URANIUM]

	if(valid_minerals & TYPE_PLASMA)
		materials[MAT_PLASMA] += I.materials[MAT_PLASMA]
		total_amount += I.materials[MAT_PLASMA]

	if(valid_minerals & TYPE_BANANIUM)
		materials[MAT_BANANIUM] += I.materials[MAT_BANANIUM]
		total_amount += I.materials[MAT_BANANIUM]

//For consuming material
/datum/material_container/proc/use_amount(list/mats)
	if(!mats || !mats.len)
		return 0
	if(materials[MAT_METAL] < mats[MAT_METAL])
		return 0
	if(materials[MAT_GLASS] < mats[MAT_GLASS])
		return 0
	if(materials[MAT_SILVER] < mats[MAT_SILVER])
		return 0
	if(materials[MAT_GOLD] < mats[MAT_GOLD])
		return 0
	if(materials[MAT_DIAMOND] < mats[MAT_DIAMOND])
		return 0
	if(materials[MAT_URANIUM] < mats[MAT_URANIUM])
		return 0
	if(materials[MAT_PLASMA] < mats[MAT_PLASMA])
		return 0
	if(materials[MAT_BANANIUM] < mats[MAT_BANANIUM])
		return 0

	var/total_amount_save = total_amount
	materials[MAT_METAL] -= mats[MAT_METAL]
	total_amount -= mats[MAT_METAL]

	materials[MAT_GLASS] -= mats[MAT_GLASS]
	total_amount -= mats[MAT_GLASS]

	materials[MAT_SILVER] -= mats[MAT_SILVER]
	total_amount -= mats[MAT_SILVER]

	materials[MAT_GOLD] -= mats[MAT_GOLD]
	total_amount -= mats[MAT_GOLD]

	materials[MAT_DIAMOND] -= mats[MAT_DIAMOND]
	total_amount -= mats[MAT_DIAMOND]

	materials[MAT_URANIUM] -= mats[MAT_URANIUM]
	total_amount -= mats[MAT_URANIUM]

	materials[MAT_PLASMA] -= mats[MAT_PLASMA]
	total_amount -= mats[MAT_PLASMA]

	materials[MAT_BANANIUM] -= mats[MAT_BANANIUM]
	total_amount -= mats[MAT_BANANIUM]
	return total_amount_save - total_amount


/datum/material_container/proc/use_amount_type(amt, material_type)
	if(materials[material_type] < amt)
		return 0
	materials[material_type] -= amt
	total_amount -= amt
	return amt

//For consuming material (sheet_amt = amount of material equivalent to a number of sheets)
/datum/material_container/proc/use_sheets(sheet_amt)
	if(sheet_amt > 0 & !isEmpty())
		if(amount >= (sheet_amt * MINERAL_MATERIAL_AMOUNT))
			amount -= sheet_amt
			return sheet_amt
	return 0

//For spawning mineral sheets
/datum/material_container/proc/retrieve(sheet_amt, sheet_type, MAT)
	if(sheet_amt > 0 && materials[MAT] >= (sheet_amt * MINERAL_MATERIAL_AMOUNT))
		var/count = 0
		var/obj/item/stack/sheet/S

		while(sheet_amt > MAX_STACK_SIZE)
			S = new sheet_type(get_turf(owner))
			S.amount = MAX_STACK_SIZE
			count += MAX_STACK_SIZE
			materials[MAT] -= MAX_STACK_SIZE * MINERAL_MATERIAL_AMOUNT
			total_amount -= MAX_STACK_SIZE * MINERAL_MATERIAL_AMOUNT
			sheet_amt -= MAX_STACK_SIZE

		if(round(materials[MAT] / MINERAL_MATERIAL_AMOUNT))
			S = new sheet_type(get_turf(owner))
			S.amount = sheet_amt
			count += sheet_amt
			materials[MAT] -= sheet_amt * MINERAL_MATERIAL_AMOUNT
			total_amount -= sheet_amt * MINERAL_MATERIAL_AMOUNT
		return count
	return 0

/datum/material_container/proc/retrieve_sheets(sheet_amt, material_type)
	switch(material_type)
		if(MAT_METAL)
			return retrieve(sheet_amt, /obj/item/stack/sheet/metal, MAT_METAL)
		if(MAT_GLASS)
			return retrieve(sheet_amt, /obj/item/stack/sheet/glass, MAT_GLASS)
		if(MAT_SILVER)
			return retrieve(sheet_amt, /obj/item/stack/sheet/mineral/silver, MAT_SILVER)
		if(MAT_GOLD)
			return retrieve(sheet_amt, /obj/item/stack/sheet/mineral/gold, MAT_GOLD)
		if(MAT_DIAMOND)
			return retrieve(sheet_amt, /obj/item/stack/sheet/mineral/diamond, MAT_DIAMOND)
		if(MAT_URANIUM)
			return retrieve(sheet_amt, /obj/item/stack/sheet/mineral/uranium, MAT_URANIUM)
		if(MAT_PLASMA)
			return retrieve(sheet_amt, /obj/item/stack/sheet/mineral/plasma, MAT_PLASMA)
		if(MAT_BANANIUM)
			return retrieve(sheet_amt, /obj/item/stack/sheet/mineral/bananium, MAT_BANANIUM)
		else
			return 0

/datum/material_container/proc/retrieve_amount(amt, material_type)
	return retrieve_sheets(amount2sheet(amt),material_type)

/datum/material_container/proc/retrieve_all()
	var/result = 0
	result += retrieve_sheets(amount2sheet(materials[MAT_METAL]), MAT_METAL)
	result += retrieve_sheets(amount2sheet(materials[MAT_GLASS]), MAT_GLASS)
	result += retrieve_sheets(amount2sheet(materials[MAT_SILVER]), MAT_SILVER)
	result += retrieve_sheets(amount2sheet(materials[MAT_GOLD]), MAT_GOLD)
	result += retrieve_sheets(amount2sheet(materials[MAT_DIAMOND]), MAT_DIAMOND)
	result += retrieve_sheets(amount2sheet(materials[MAT_URANIUM]), MAT_URANIUM)
	result += retrieve_sheets(amount2sheet(materials[MAT_PLASMA]), MAT_PLASMA)
	result += retrieve_sheets(amount2sheet(materials[MAT_BANANIUM]), MAT_BANANIUM)
	return result

/datum/material_container/proc/accepts(obj/O)
	return istype(O,sheet_type)

/datum/material_container/proc/isFull(amt = 0)
	return (total_amount + amt) > max_amount

/datum/material_container/proc/isEmpty(amt = 0)
	return (amount - amt) <= 0

/datum/material_container/proc/amount2sheet(amt)
	if(amt >= MINERAL_MATERIAL_AMOUNT)
		return round(amt / MINERAL_MATERIAL_AMOUNT)
	return 0

/datum/material_container/proc/sheet2amount(sheet_amt)
	if(sheet_amt > 0)
		return sheet_amt * MINERAL_MATERIAL_AMOUNT
	return 0

/datum/material_container/proc/amount(material_type)
	return materials[material_type]

/datum/material_container/proc/can_insert(obj/item/I)
	var/result = 0
	result += valid_minerals & TYPE_METAL ? I.materials[MAT_METAL] : 0
	result += valid_minerals & TYPE_GLASS ? I.materials[MAT_GLASS] : 0
	result += valid_minerals & TYPE_SILVER ? I.materials[MAT_SILVER] : 0
	result += valid_minerals & TYPE_GOLD ? I.materials[MAT_GOLD] : 0
	result += valid_minerals & TYPE_DIAMOND ? I.materials[MAT_DIAMOND] : 0
	result += valid_minerals & TYPE_URANIUM ? I.materials[MAT_URANIUM] : 0
	result += valid_minerals & TYPE_PLASMA ? I.materials[MAT_PLASMA] : 0
	result += valid_minerals & TYPE_BANANIUM ? I.materials[MAT_BANANIUM] : 0
	return result