/*
	This datum should be used for handling mineral contents of machines and whatever else is supposed to hold minerals and make use of them.
	One mineral_container var can only handle one type of mineral.

	Variables:
		amount - raw amount of the mineral this container holds, calculated by the defined value MINERAL_MATERIAL_AMOUNT=2000.
		max_amount - raw amount of mineral this container can hold.
		sheet_type - type of the mineral sheet the container handles, used for output.
		owner - object that this container is being used by, used for output.
		sheet_stack_size - size of a stack of mineral sheets. Constant.
*/
/datum/mineral_container
	var/amount
	var/max_amount
	var/sheet_type
	var/obj/owner
	var/const/sheet_stack_size = 50
	//MINERAL_MATERIAL_AMOUNT = 2000

/datum/mineral_container/New(obj/O, sht_type, max_amt = 0, amt = 0)
	if(!O)	return
	owner = O

	sheet_type = sht_type

	amount = max(0, amt)
	max_amount = max(0, max_amt)

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
			S = new sheet_type(get_turf(owner))
			S.amount = sheet_stack_size
			count += sheet_stack_size
			amount -= sheet_stack_size * MINERAL_MATERIAL_AMOUNT
			sheet_amt -= sheet_stack_size

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
	if(amt)	return amt + amount > max_amount
	return amount >= max_amount

/datum/mineral_container/proc/isEmpty()
	return amount <= 0

/datum/mineral_container/proc/amount2sheet(amt)
	if(amt >= MINERAL_MATERIAL_AMOUNT)
		return round(amt / MINERAL_MATERIAL_AMOUNT)
	return 0

/datum/mineral_container/proc/sheet2amount(sheet_amt)
	if(sheet_amt > 0)
		return sheet_amt * MINERAL_MATERIAL_AMOUNT
	return 0

/*
/datum/mineral_container_combo
	var/datum/mineral_container/m_cont
	var/datum/mineral_container/g_cont
	var/obj/owner

/datum/mineral_container_combo/New(obj/O,max_amt = 0, amt = 0)
	m_cont = new /datum/mineral_container(O,/obj/item/stack/sheet/metal,max_amt,amt)
	g_cont = new /datum/mineral_container(O,/obj/item/stack/sheet/glass,max_amt,amt)

/datum/mineral_container_combo/proc/insert_stack(obj/item/stack/S)
	var/m_amt = S.m_amt * S.amount
	var/g_amt = S.g_amt * S.amount

	if(!(m_cont.isFull(m_amt) || g_cont.isFull(g_amt)))
		m_cont.insert_amount(m_amt)
		g_cont.insert_amount(g_amt)
		return m_amt + g_amt
	return 0

/datum/mineral_container_combo/proc/insert(obj/item/O)
	var/m_amt = O.m_amt
	var/g_amt = O.g_amt

	if(!(m_cont.isFull(m_amt) || g_cont.isFull(g_amt)))
		m_cont.insert_amount(m_amt)
		g_cont.insert_amount(g_amt)
		return m_amt + g_amt
	return 0

/datum/mineral_container_combo/proc/insert_sheet(obj/item/stack/sheet/S)
	var/a = sheet2num(S)
	switch(a)
		if(1)
			return m_cont.insert_sheet(S)
		if(2)
			return g_cont.insert_sheet(S)
		else
			return -99

/datum/mineral_container_combo/proc/isFull()
	return m_cont.isFull() | (g_cont.isFull() * 2) //returns 0 if neither is full, 1 if only metal is full, 2 if only glass is full, 3 if both are full

/datum/mineral_container_combo/proc/isEmpty()
	return m_cont.isEmpty() | (g_cont.isEmpty() * 2)
*/

/proc/sheet2num(obj/item/stack/sheet/S)
	if(istype(S,/obj/item/stack/sheet/metal) && !istype(S,/obj/item/stack/sheet/metal/cyborg))
		return 1
	if(istype(S,/obj/item/stack/sheet/glass) && !istype(S,/obj/item/stack/sheet/glass/cyborg))
		return 2
	if(istype(S,/obj/item/stack/sheet/mineral/plasma))		return 3
	if(istype(S,/obj/item/stack/sheet/plasteel))			return 4
	if(istype(S,/obj/item/stack/sheet/mineral/silver))		return 5
	if(istype(S,/obj/item/stack/sheet/mineral/gold))		return 6
	if(istype(S,/obj/item/stack/sheet/mineral/diamond))		return 7
	if(istype(S,/obj/item/stack/sheet/mineral/bananium))	return 8
	if(istype(S,/obj/item/stack/sheet/mineral/wood))		return 9
	return 0
