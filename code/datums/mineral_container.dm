/*
	This datum should be used for handling mineral contents of machines and whatever else is supposed to hold minerals and make use of them.
	One mineral_container var can only handle one type of mineral.

	Variables:
		amount - raw amount of the mineral this container holds, calculated by the defined value MINERAL_MATERIAL_AMOUNT=2000.
		max_amount - raw amount of mineral this container can hold.
		sheet_type - type of the mineral sheet the container handles, used for output.
		location - location of the object that this container is being used by, used for output.
		sheet_stack_size - size of a stack of sheets. Constant.

	Procs:
		New - new
			Args: 	'obj/O' is the object that uses the mineral container, used to get a location.
					'T' is a type variable.
					'M' is the maximum amount, is 0 by default.
					'A' is an amount, is 0 by default.
					-------------------------------
		insert - Converts a number of sheets to a raw amount and adds it to the container. Don't use this directly.
				 Returns amount of sheets inserted if successful, returns 0 if not successful (container full).
			Args:	'A' is an amount of sheets.
			----------------------------------
		insert_sheet - Inserts sheets into the container. Use this for inserting mineral sheets.
					   Returns the amount of sheets inserted if successful, returns 0 if the container is full,
					   returns -1 if the object inserted is not a mineral sheet of the type the container handles (see 'sheet_type').
				Args:	'obj/S' is a mineral sheet type object.
				-----------------------------------------------
		insert_raw - Inserts a raw amount of mineral into the container. Use this for inserting raw values of mineral.
					 Returns the raw amount of mineral inserted if successful, returns 0 if not successful (container full or negative amount value).
				Args:	'A' is a raw amount value of mineral.
				---------------------------------------------
		use - Consumes an amount of mineral. Use this for consuming raw amounts of mineral.
			  Returns the amount of mineral consumed if successful, returns 0 if not successful (container is empty or negative amount value).
				Args:	'A' is a raw amount value of mineral.
				---------------------------------------------
		useB - Consumes amounts of mineral. Use this for consuming mineral sheets at a time.
			   Returns the amount of sheets consumed if successful, returns 0 if not successful (container is empty or negative amount value).
				Args:	'A' is an amount of sheets.
				-----------------------------------
		retrieve - Spawns mineral sheets at 'location'. Use this to retrieve an amount of sheets.
				   Returns amount of sheets spawned if successful, returns 0 if not successful (not enough mineral or negative amount value).
					Args:	'A' is an amount of sheets.
					-----------------------------------
		retrieveB - Spawns mineral sheets at 'location' based on a raw mineral amount input.
					Returns amount of sheets spawned if successful, returns 0 if not successful.
					Args:	'A' is a raw mineral amount value.
					------------------------------------------
		retrieve_all - Spawns all the mineral inside the container at 'location'. Use this to get all the mineral inside the container easily.
					Returns amount of sheets spawned if successful, returns 0 if not successful.
					Args:	None.
					-------------
		modLoc - Changes 'location' based on an obj input. Only use this if the object using the container is not stationary. All machines are stationary.
				 Returns null if obj input is null.
				Args:	'obj/O' is the object that uses the mineral container.
				--------------------------------------------------------------
		accepts - Checks if the 'obj/O' is a mineral sheet of the same type as 'sheet_type'.
				  Returns 1 if 'obj/O' is a valid mineral sheet object, 0 if otherwise.
				Args:	'obj/O' is any object.
				------------------------------
		isFull - Checks if the container is full.
				 Returns 1 if the container is full, 0 if otherwise.
				Args:	None.
				-------------
		isEmpty - Checks if the container is empty.
				  Returns 1 if the container is empty, 0 if otherwise.
				Args:	None.
				-------------
		amount2sheet - Converts a raw mineral amount to a number of mineral sheets.
					   Returns a positive amount of sheets if successful, 0 if not successful (invalid amount input).
					Args:	'A' is a raw mineral amount.
					------------------------------------
		sheet2amount - Converts a number of sheets to a raw mineral amount.
					   Returns a positive amount of mineral if successful, 0 if not successful (invalid sheet number input).
					Args:	'A' is a number of mineral sheets.
					------------------------------------------

	Self-explanatory procs:
		getAmount ; getMaxAmount ; getType

	Other (might remove):
		cleanup

	WIP (?):
		upgrade - changes max_amount, for machine upgrades.
*/
/datum/mineral_container
	var/amount
	var/max_amount
	var/sheet_type
	var/location
	var/const/sheet_stack_size = 50
	//MINERAL_MATERIAL_AMOUNT = 2000

/datum/mineral_container/New(obj/O, T, M = 0, A = 0)
	if(!O)
		return
	location = get_turf(O.loc)

	sheet_type = T

	if(A < 0)
		amount = 0
	else
		amount = A

	if(M < 0)
		max_amount = 0
	else
		max_amount = M

/datum/mineral_container/proc/insert(A)
	if(A > 0)
		var/rawA = A * MINERAL_MATERIAL_AMOUNT
		if(rawA <= (max_amount - amount))
			amount += rawA
			return A
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

/datum/mineral_container/proc/insert_raw(A)
	if(A > 0 & !isFull())
		if(A <= max_amount - amount)
			amount += A
			return A
	return 0

/datum/mineral_container/proc/use(A)
	if(A > 0 & !isEmpty())
		if(amount >= A)
			amount -= A
			return A
	return 0

/datum/mineral_container/proc/useB(A)
	if(A > 0 & !isEmpty())
		if(amount >= (A * MINERAL_MATERIAL_AMOUNT))
			amount -= A
			return A
	return 0

/datum/mineral_container/proc/retrieve(A)
	if(A > 0 && amount >= (A * MINERAL_MATERIAL_AMOUNT))
		var/count = 0
		var/obj/item/stack/sheet/S

		while(A > sheet_stack_size)
			S = new sheet_type(location)
			S.amount = sheet_stack_size
			count += A
			amount -= A * MINERAL_MATERIAL_AMOUNT
			A -= sheet_stack_size

		if(round(amount / MINERAL_MATERIAL_AMOUNT))
			S = new sheet_type(location)
			S.amount = A
			count += A
			amount -= A * MINERAL_MATERIAL_AMOUNT
		return count
	return 0

/datum/mineral_container/proc/retrieveB(A)
	if(A > 0)
		return retrieve(amount2sheet(A))
	return 0

/datum/mineral_container/proc/retrieve_all()
	return retrieve(amount2sheet(amount))

/datum/mineral_container/proc/modLoc(obj/O)
	if(!O)
		return
	location = get_turf(O.loc)

/datum/mineral_container/proc/accepts(obj/O)
	return(istype(O,sheet_type))

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

/datum/mineral_container/proc/amount2sheet(A)
	if(A >= MINERAL_MATERIAL_AMOUNT)
		return round(A / MINERAL_MATERIAL_AMOUNT)
	return 0

/datum/mineral_container/proc/sheet2amount(A)
	if(A > 0)
		return A * MINERAL_MATERIAL_AMOUNT
	return 0

/datum/mineral_container/proc/cleanup()
	if(!location)
		qdel(src)
	if(!sheet_type || !ispath(sheet_type))
		qdel(src)

	if(amount < 0)
		amount = 0
	else if(amount > max_amount)
		amount = max_amount

/datum/mineral_container/proc/upgrade(M)
	max_amount = M