/*
	This datum should be used for handling mineral contents of machines and whatever else is supposed to hold minerals and make use of them.

	Variables:
		amount - raw amount of the mineral this container is holding, calculated by the defined value MINERAL_MATERIAL_AMOUNT=2000.
		max_amount - max raw amount of mineral this container can hold.
		sheet_type - type of the mineral sheet the container handles, used for output.
		owner - object that this container is being used by, used for output.
		MAX_STACK_SIZE - size of a stack of mineral sheets. Constant.
*/

/datum/material_container
	var/total_amount = 0
	var/max_amount
	var/sheet_type
	var/obj/owner
	var/list/materials = list()
	//MAX_STACK_SIZE = 50
	//MINERAL_MATERIAL_AMOUNT = 2000

/datum/material_container/New(obj/O, list/mat_list, max_amt = 0)
	owner = O
	max_amount = max(0, max_amt)

	if(mat_list[MAT_METAL])
		materials += new /datum/material/metal(MAT_METAL)
	if(mat_list[MAT_GLASS])
		materials += new /datum/material/glass(MAT_GLASS)
	if(mat_list[MAT_SILVER])
		materials += new /datum/material/silver(MAT_SILVER)
	if(mat_list[MAT_GOLD])
		materials += new /datum/material/gold(MAT_GOLD)
	if(mat_list[MAT_DIAMOND])
		materials += new /datum/material/diamond(MAT_DIAMOND)
	if(mat_list[MAT_URANIUM])
		materials += new /datum/material/uranium(MAT_URANIUM)
	if(mat_list[MAT_PLASMA])
		materials += new /datum/material/plasma(MAT_PLASMA)
	if(mat_list[MAT_BANANIUM])
		materials += new /datum/material/bananium(MAT_BANANIUM)

//For inserting an amount of material
/datum/material_container/proc/insert_amount(amt, material_type = null)
	if(amt > 0 && has_space(amt))
		var/total_amount_saved = total_amount
		if(material_type)
			for(var/datum/material/M in materials)
				if(M.material_type == material_type)
					M.amount += amt
					total_amount += amt
		else
			for(var/datum/material/M in materials)
				M.amount += amt
				total_amount += amt
		return (total_amount - total_amount_saved)
	return 0

/datum/material_container/proc/insert_stack(obj/item/stack/S, amt = 0)
	if(!amt)
		amt = S.amount
	var/material_amt = get_item_material_amount(S)
	while(!has_space(material_amt * amt))
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

	var/material_amount = get_item_material_amount(I)
	if(!material_amount || !has_space(material_amount))
		return 0

	insert_materials(I)
	return material_amount

/datum/material_container/proc/insert_materials(obj/item/I) //for internal usage only
	for(var/datum/material/M in materials)
		M.amount += I.materials[M.material_type]
		total_amount += I.materials[M.material_type]

//For consuming material
/datum/material_container/proc/use_amount(list/mats)
	if(!mats || !mats.len)
		return 0

	for(var/datum/material/M in materials)
		if(M.amount < mats[M.material_type])
			return 0

	var/total_amount_save = total_amount
	for(var/datum/material/M in materials)
		M.amount -= mats[M.material_type]
		total_amount -= mats[M.material_type]

	return total_amount_save - total_amount


/datum/material_container/proc/use_amount_type(amt, material_type)
	for(var/datum/material/M in materials)
		if(M.material_type == material_type)
			if(M.amount >= amt)
				M.amount -= amt
				total_amount -= amt
				return amt
	return 0

//For spawning mineral sheets
/datum/material_container/proc/retrieve(sheet_amt, datum/material/M)
	if(sheet_amt > 0 && M.amount >= (sheet_amt * MINERAL_MATERIAL_AMOUNT))
		var/count = 0
		var/obj/item/stack/sheet/S

		while(sheet_amt > MAX_STACK_SIZE)
			S = new M.sheet_type(get_turf(owner))
			S.amount = MAX_STACK_SIZE
			count += MAX_STACK_SIZE
			M.amount -= MAX_STACK_SIZE * MINERAL_MATERIAL_AMOUNT
			total_amount -= MAX_STACK_SIZE * MINERAL_MATERIAL_AMOUNT
			sheet_amt -= MAX_STACK_SIZE

		if(round(M.amount / MINERAL_MATERIAL_AMOUNT))
			S = new M.sheet_type(get_turf(owner))
			S.amount = sheet_amt
			count += sheet_amt
			M.amount -= sheet_amt * MINERAL_MATERIAL_AMOUNT
			total_amount -= sheet_amt * MINERAL_MATERIAL_AMOUNT
		return count
	return 0

/datum/material_container/proc/retrieve_sheets(sheet_amt, material_type)
	for(var/datum/material/M in materials)
		if(M.material_type == material_type)
			return retrieve(sheet_amt, M)
	return 0

/datum/material_container/proc/retrieve_amount(amt, material_type)
	return retrieve_sheets(amount2sheet(amt),material_type)

/datum/material_container/proc/retrieve_all()
	var/result = 0
	for(var/datum/material/M in materials)
		result += retrieve_sheets(amount2sheet(M.amount), M.material_type)
	return result

/datum/material_container/proc/has_space(amt = 0)
	return (total_amount + amt) <= max_amount

/datum/material_container/proc/amount2sheet(amt)
	if(amt >= MINERAL_MATERIAL_AMOUNT)
		return round(amt / MINERAL_MATERIAL_AMOUNT)
	return 0

/datum/material_container/proc/sheet2amount(sheet_amt)
	if(sheet_amt > 0)
		return sheet_amt * MINERAL_MATERIAL_AMOUNT
	return 0

/datum/material_container/proc/amount(material_type)
	for(var/datum/material/M in materials)
		if(M.material_type == material_type)
			return M.amount

/datum/material_container/proc/can_insert(obj/item/I)
	return get_item_material_amount(I)

//returns the amount of material relevant to this container;
//if this container does not support glass, any glass in 'I' will not be taken into account
/datum/material_container/proc/get_item_material_amount(obj/item/I)
	if(!istype(I))
		return 0
	var/material_amount
	for(var/datum/material/M in materials)
		material_amount += I.materials[M.material_type]
	return material_amount


/datum/material
	var/amount = 0
	var/material_type = null
	var/sheet_type = null

/datum/material/New(var/mat_type)
	material_type = mat_type

/datum/material/metal

/datum/material/metal/New(var/mat_type)
	..()
	sheet_type = /obj/item/stack/sheet/metal

/datum/material/glass

/datum/material/glass/New(var/mat_type)
	..()
	sheet_type = /obj/item/stack/sheet/glass

/datum/material/silver

/datum/material/silver/New(var/mat_type)
	..()
	sheet_type = /obj/item/stack/sheet/mineral/silver

/datum/material/gold

/datum/material/gold/New(var/mat_type)
	..()
	sheet_type = /obj/item/stack/sheet/mineral/gold

/datum/material/diamond

/datum/material/diamond/New(var/mat_type)
	..()
	sheet_type = /obj/item/stack/sheet/mineral/diamond

/datum/material/uranium

/datum/material/uranium/New(var/mat_type)
	..()
	sheet_type = /obj/item/stack/sheet/mineral/uranium

/datum/material/plasma

/datum/material/plasma/New(var/mat_type)
	..()
	sheet_type = /obj/item/stack/sheet/mineral/plasma

/datum/material/bananium

/datum/material/bananium/New(var/mat_type)
	..()
	sheet_type = /obj/item/stack/sheet/mineral/bananium