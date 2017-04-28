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

	var/list/possible_mats = list()
	for(var/mat_type in subtypesof(/datum/material))
		var/datum/material/MT = mat_type
		possible_mats[initial(MT.id)] = mat_type
	for(var/id in mat_list)
		if(possible_mats[id])
			var/mat_path = possible_mats[id]
			materials[id] = new mat_path()

/datum/material_container/Destroy()
	owner = null
	return ..()

//For inserting an amount of material
/datum/material_container/proc/insert_amount(amt, id = null)
	if(amt > 0 && has_space(amt))
		var/total_amount_saved = total_amount
		if(id)
			var/datum/material/M = materials[id]
			if(M)
				M.amount += amt
				total_amount += amt
		else
			for(var/i in materials)
				var/datum/material/M = materials[i]
				M.amount += amt
				total_amount += amt
		return (total_amount - total_amount_saved)
	return 0

/datum/material_container/proc/insert_stack(obj/item/stack/S, amt = 0)
	if(amt <= 0)
		return 0
	if(amt > S.amount)
		amt = S.amount

	var/material_amt = get_item_material_amount(S)
	if(!material_amt)
		return 0

	amt = min(amt, round(((max_amount - total_amount) / material_amt)))
	if(!amt)
		return 0

	insert_materials(S,amt)
	S.use(amt)
	return amt

/datum/material_container/proc/insert_item(obj/item/I, multiplier = 1)
	if(!I)
		return 0
	if(istype(I,/obj/item/stack))
		var/obj/item/stack/S = I
		return insert_stack(I, S.amount)

	var/material_amount = get_item_material_amount(I)
	if(!material_amount || !has_space(material_amount))
		return 0

	insert_materials(I, multiplier)
	return material_amount

/datum/material_container/proc/insert_materials(obj/item/I, multiplier = 1) //for internal usage only
	var/datum/material/M
	for(var/MAT in materials)
		M = materials[MAT]
		M.amount += I.materials[MAT] * multiplier
		total_amount += I.materials[MAT] * multiplier

//For consuming material
//mats is a list of types of material to use and the corresponding amounts, example: list(MAT_METAL=100, MAT_GLASS=200)
/datum/material_container/proc/use_amount(list/mats, multiplier=1)
	if(!mats || !mats.len)
		return 0

	var/datum/material/M
	for(var/MAT in materials)
		M = materials[MAT]
		if(M.amount < (mats[MAT] * multiplier))
			return 0

	var/total_amount_save = total_amount
	for(var/MAT in materials)
		M = materials[MAT]
		M.amount -= mats[MAT] * multiplier
		total_amount -= mats[MAT] * multiplier

	return total_amount_save - total_amount


/datum/material_container/proc/use_amount_type(amt, id)
	var/datum/material/M = materials[id]
	if(M)
		if(M.amount >= amt)
			M.amount -= amt
			total_amount -= amt
			return amt
	return 0

/datum/material_container/proc/can_use_amount(amt, id, list/mats)
	if(amt && id)
		var/datum/material/M = materials[id]
		if(M && M.amount >= amt)
			return TRUE
	else if(istype(mats))
		for(var/M in mats)
			if(materials[M] && (mats[M] <= materials[M]))
				continue
			else
				return FALSE
		return TRUE
	return FALSE

//For spawning mineral sheets; internal use only
/datum/material_container/proc/retrieve(sheet_amt, datum/material/M)
	if(!M.sheet_type)
		return 0
	if(sheet_amt > 0)
		if(M.amount < (sheet_amt * MINERAL_MATERIAL_AMOUNT))
			sheet_amt = round(M.amount / MINERAL_MATERIAL_AMOUNT)
		var/count = 0
		while(sheet_amt > MAX_STACK_SIZE)
			new M.sheet_type(get_turf(owner), MAX_STACK_SIZE)
			count += MAX_STACK_SIZE
			use_amount_type(sheet_amt * MINERAL_MATERIAL_AMOUNT, M.id)
			sheet_amt -= MAX_STACK_SIZE
		if(round((sheet_amt * MINERAL_MATERIAL_AMOUNT) / MINERAL_MATERIAL_AMOUNT))
			new M.sheet_type(get_turf(owner), sheet_amt)
			count += sheet_amt
			use_amount_type(sheet_amt * MINERAL_MATERIAL_AMOUNT, M.id)
		return count
	return 0

/datum/material_container/proc/retrieve_sheets(sheet_amt, id)
	if(materials[id])
		return retrieve(sheet_amt, materials[id])
	return 0

/datum/material_container/proc/retrieve_amount(amt, id)
	return retrieve_sheets(amount2sheet(amt), id)

/datum/material_container/proc/retrieve_all()
	var/result = 0
	var/datum/material/M
	for(var/MAT in materials)
		M = materials[MAT]
		result += retrieve_sheets(amount2sheet(M.amount), MAT)
	return result

/datum/material_container/proc/has_space(amt = 0)
	return (total_amount + amt) <= max_amount

/datum/material_container/proc/has_materials(list/mats, multiplier=1)
	if(!mats || !mats.len)
		return 0

	var/datum/material/M
	for(var/MAT in mats)
		M = materials[MAT]
		if(M.amount < (mats[MAT] * multiplier))
			return 0
	return 1

/datum/material_container/proc/amount2sheet(amt)
	if(amt >= MINERAL_MATERIAL_AMOUNT)
		return round(amt / MINERAL_MATERIAL_AMOUNT)
	return 0

/datum/material_container/proc/sheet2amount(sheet_amt)
	if(sheet_amt > 0)
		return sheet_amt * MINERAL_MATERIAL_AMOUNT
	return 0

/datum/material_container/proc/amount(id)
	var/datum/material/M = materials[id]
	return M ? M.amount : 0

//returns the amount of material relevant to this container;
//if this container does not support glass, any glass in 'I' will not be taken into account
/datum/material_container/proc/get_item_material_amount(obj/item/I)
	if(!istype(I))
		return 0
	var/material_amount = 0
	for(var/MAT in materials)
		material_amount += I.materials[MAT]
	return material_amount


/datum/material
	var/name
	var/amount = 0
	var/id = null
	var/sheet_type = null
	var/coin_type = null

/datum/material/metal
	name = "Metal"
	id = MAT_METAL
	sheet_type = /obj/item/stack/sheet/metal
	coin_type = /obj/item/weapon/coin/iron

/datum/material/glass
	name = "Glass"
	id = MAT_GLASS
	sheet_type = /obj/item/stack/sheet/glass

/datum/material/silver
	name = "Silver"
	id = MAT_SILVER
	sheet_type = /obj/item/stack/sheet/mineral/silver
	coin_type = /obj/item/weapon/coin/silver

/datum/material/gold
	name = "Gold"
	id = MAT_GOLD
	sheet_type = /obj/item/stack/sheet/mineral/gold
	coin_type = /obj/item/weapon/coin/gold

/datum/material/diamond
	name = "Diamond"
	id = MAT_DIAMOND
	sheet_type = /obj/item/stack/sheet/mineral/diamond
	coin_type = /obj/item/weapon/coin/diamond

/datum/material/uranium
	name = "Uranium"
	id = MAT_URANIUM
	sheet_type = /obj/item/stack/sheet/mineral/uranium
	coin_type = /obj/item/weapon/coin/uranium

/datum/material/plasma
	name = "Solid Plasma"
	id = MAT_PLASMA
	sheet_type = /obj/item/stack/sheet/mineral/plasma
	coin_type = /obj/item/weapon/coin/plasma

/datum/material/bluespace
	name = "Bluespace Mesh"
	id = MAT_BLUESPACE
	sheet_type = /obj/item/stack/sheet/bluespace_crystal

/datum/material/bananium
	name = "Bananium"
	id = MAT_BANANIUM
	sheet_type = /obj/item/stack/sheet/mineral/bananium
	coin_type = /obj/item/weapon/coin/clown

/datum/material/titanium
	name = "Titanium"
	id = MAT_TITANIUM
	sheet_type = /obj/item/stack/sheet/mineral/titanium

/datum/material/biomass
	name = "Biomass"
	id = MAT_BIOMASS
