/proc/__solve_operations_list(list/operations, list/numbers)
	for(var/list/subop in operations)
		var/idx = operations.Find(subop)
		operations[idx] = __solve_operations_list(subop, numbers)

	var/lhs = popleft(operations)
	if(istext(lhs)) // %NUMX%
		lhs = numbers[text2num(lhs[5])]

	do
		var/operation = popleft(operations)
		var/rhs = popleft(operations)

		if(istext(rhs)) // %NUMX%
			rhs = numbers[text2num(rhs[5])]

		switch(operation)
			if("+")
				lhs += rhs
			if("-")
				lhs -= rhs
			if("*")
				lhs *= rhs
			if("/")
				lhs /= rhs
	while(length(operations))

	return lhs

/proc/do_admin_math(client/client)
	var/ckey = client.ckey

	var/static/list/in_math_problem = list()
	if(ckey in in_math_problem)
		return FALSE
	in_math_problem += ckey

	var/static/list/failure_timers = list()
	if(ckey in failure_timers)
		var/allow_at = failure_timers[ckey]
		if(allow_at > world.time)
			in_math_problem -= ckey
			return FALSE
		failure_timers -= ckey

	/**
	 * This is a list of problems that the admin can solve.
	 * The format is as follows:
	 * - The key is the problem string.
	 * - The value is a list of operations used to solve the problem. LISTS ARE PROCESSED IN ORDER, USE SUB-LISTS TO GROUP OPERATIONS.
	 *
	 * Valid substrings:
	 * - %NAMEX%: A random name, where X is the number of the name.
	 * - %NUMX%: A random number, where X is the number of the number.
	 * - %OBJECTX%: A random object, where X is the number of the object.
	 *
	 * X is only valid up to 4 for reasons. Cope.
	 */
	var/static/list/problem_strings = list(
		"%NAME1% has %NUM1% %OBJECT1%. %NAME1% gives %NUM2% %OBJECT1% to %NAME2%. How many %OBJECT1% does %NAME1% have now?" = list("%NUM1%", "-", "%NUM2%"),
		"%NAME1% is driving at %NUM1% mph. How long will it take %NAME1% to drive %NUM2% miles?" = list("%NUM2%", "/", "%NUM1%"),
		"%NAME1% has %NUM1% %OBJECT1%. %NAME2% has %NUM2% %OBJECT1%. How many %OBJECT1% do they have together?" = list("%NUM1%", "+", "%NUM2%"),
		"%NAME1% has %NUM1% %OBJECT1%. %NAME2% has %NUM2% %OBJECT1%. %NAME3% has %NUM3% %OBJECT1%. How many %OBJECT1% do they have together?" = list("%NUM1%", "+", "%NUM2%", "+", "%NUM3%"),
		"$NAME1% has %NUM1% %OBJECT1% and %NUM2% %OBJECT2%. %NAME2% has %NUM3% %OBJECT1% and %NUM4% %OBJECT2%. How many %OBJECT1% do they have together?" = list("%NUM1%", "+", "%NUM3%"),
		"$NAME1% has %NUM1% %OBJECT1% and %NUM2% %OBJECT2%. %NAME2% has %NUM3% %OBJECT1% and %NUM4% %OBJECT2%. How many %OBJECT2% do they have together?" = list("%NUM2%", "+", "%NUM4%"),
		// now some gemoetry problems
		"%NAME1% has a rectangle that is %NUM1% by %NUM2%. What is the area of the rectangle?" = list("%NUM1%", "*", "%NUM2%"),
		"%NAME1% has a rectangle that is %NUM1% by %NUM2%. What is the perimeter of the rectangle?" = list("%NUM1%", "+", "%NUM1%", "+", "%NUM2%", "+", "%NUM2%"),
		"%NAME1% has a square that is %NUM1% by %NUM1%. What is the area of the square?" = list("%NUM1%", "*", "%NUM1%"),
		"%NAME1% has a square that is %NUM1% by %NUM1%. What is the perimeter of the square?" = list("%NUM1%", "*", 4),
		"%NAME1% has a triangle that is %NUM1% by %NUM2%. What is the area of the triangle?" = list("%NUM1%", "*", "%NUM2%", "/", 2),
		// now some algebra problems
		"If X=%NUM1% and Y=%NUM2%, what is X+Y?" = list("%NUM1%", "+", "%NUM2%"),
		"If X=%NUM1% and Y=%NUM2%, what is X-Y?" = list("%NUM1%", "-", "%NUM2%"),
		"If X=%NUM1% and Y=%NUM2%, what is X*Y?" = list("%NUM1%", "*", "%NUM2%"),
		"If X=%NUM1% and Y=%NUM2%, what is X/Y?" = list("%NUM1%", "/", "%NUM2%"),
	)

	var/problem_string = problem_strings[rand(1, problem_strings.len)]
	var/operations = problem_strings[problem_string]

	var/list/names = list()
	var/list/numbers = list()
	var/list/objects = list()

	for(var/idx in 1 to 4)
		var/chosen_name
		do
			chosen_name = pick(GLOB.first_names)
		while(chosen_name in names)
		names += chosen_name

		var/chosen_number
		do
			chosen_number = rand(1, 1000)
		while(chosen_number in numbers)
		numbers += chosen_number

		var/chosen_object
		do
			var/obj/item/random_item = pick(subtypesof(/obj/item))
			chosen_object = random_item::name
		while(chosen_object in objects)
		objects += chosen_object

	var/problem = problem_string
	for(var/idx in 1 to 4)
		problem = replacetext(problem, "%NAME[idx]%", names[idx])
		problem = replacetext(problem, "%NUM[idx]%", numbers[idx])
		problem = replacetext(problem, "%OBJECT[idx]%", objects[idx])

	var/answer = __solve_operations_list(operations, numbers)

	to_chat(client, span_adminhelp("You must solve this problem to continue: '[problem]'"))
	var/their_response = tgui_input_number(client, "Answer", "Math Problem")

	if(their_response != answer)
		to_chat(client, span_adminhelp("Incorrect. You must wait 30 seconds before trying again."))
		failure_timers[ckey] = world.time + 30 SECONDS
		in_math_problem -= ckey
		return FALSE

	to_chat(client, span_adminhelp("Correct!"))
	in_math_problem -= ckey
	return TRUE
