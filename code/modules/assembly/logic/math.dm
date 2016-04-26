//////////////////////////Math circuit////////////////////////
// * Autism
// * Only works in assembly frames. Performs one of the following operations between all variables/constants: ADD, SUBTRACT, MULTIPLY, DIVIDE, POWER, AVERAGE, MIN, MAX and trigonometric functions
// * Supports any amount of variable (= assembly) and constant (= number) values.
// * AVERAGE operator returns the average value of all values. AVERAGE x y z q = (x+y+z+q)/4
// * MIN and MAX operators return the smallest and the biggest values, respectively. MIN 5 1 4 = 1
// * Order of operations is always left to right. 2 POWER 2 POWER 4 = (2^2)^4 = 256
// * Invalid operations (division by zero) return 0. Come at me you math nerds

// * get_value(): returns result of the calculation

var/global/list/math_circuit_operations_list = list("ADD", "SUBTRACT", "MULTIPLY", "DIVIDE", "POWER", "MOD", "AVERAGE", "MIN", "MAX", "SIN", "COS", "ASIN", "ACOS", "TG", "COTG")

#define VALUE(a) (isnum(a) ? a : a.get_value(values[a]))

/obj/item/device/assembly/math
	name = "math circuit"

	desc = "A tiny circuit intended for use in assembly frames. It performs simple math operations like addition, multiplication, and powers."
	icon_state = "circuit_math"
	starting_materials = list(MAT_IRON = 200, MAT_GLASS = 75)
	w_type = RECYK_ELECTRONIC

	origin_tech = "programming=2"

	connection_text = "connected to"

	var/list/obj/item/device/assembly/values = list() //List of constants (numbers) or variables (assemblies). All assemblies in this list have a string associated with them, which tells this circuit which of the assembly's values to use
	var/operation = "ADD"

	accessible_values = list("Result" = "null;number",\
		"Operation" = "operation;text") //Allow devices to read this circiut's result. First parameter (variable name, which is "null" here) isn't important - the functions are overwritten


/obj/item/device/assembly/math/interact(mob/user as mob)
	var/dat = ""

	dat += "<tt>Math circuit</tt> <small>\[<a href='?src=\ref[src];help=1'>?</a>\]</small><BR><BR>"

	dat += "<b>VALUE</b> = "

	var/operation_sign = ","

	var/last_written_value = values.len //Index of the value that is written last in the interface. Default of values.len means that ALL values are written. Setting it to 1 will cause only the first value to be shown

	switch(operation)
		if("AVERAGE")	dat += "AVERAGE of "
		if("MIN")		dat += "SMALLEST VALUE from "
		if("MAX")		dat += "LARGEST VALUE from "

		if("SIN")		dat += "SIN of "
		if("COS")		dat += "COS of "
		if("ASIN")		dat += "ARCSIN of "
		if("ACOS")		dat += "ARCCOS of "
		if("TG")		dat += "TANGENT of "
		if("COTG")		dat += "COTANGENT of "

		if("ADD")		operation_sign = "+"
		if("SUBTRACT")	operation_sign = "-"
		if("MULTIPLY")	operation_sign = "*"
		if("DIVIDE")	operation_sign = "/"
		if("POWER")		operation_sign = "^"

		if("MOD")		operation_sign = "MOD"

	if(operation in list("SIN","COS","ASIN","ACOS","TG","COTG"))
		last_written_value = 1 //Only the first value is processed when using the functions above

	if(values.len)
		for(var/i = 1 to last_written_value)
			var/A = values[i]

			dat += "<a href='?src=\ref[src];change_value=[i]'><b>[A]"

			if(!isnum(A)) //Variable (assembly) - write which of the assembly's value is used in the calculation (its time, frequency or whatever)
				dat += " ([values[A]])"

			dat += "</b></a>"

			if(i < last_written_value)
				dat += operation_sign //If we're writing the last value, skip the sign (to avoid the extra sign at the end, like VALUE == 6 + 12 + 51 +)

	dat += "<BR>"
	dat += "<p><a href='?src=\ref[src];add_const=1'>Add constant</a></p>"
	dat += "<p>Operation: <a href='?src=\ref[src];change_operation=1'>[operation]</a></p>"
	dat += "<p><a href='?src=\ref[src];output_value=1'>Output value</a></p><BR>"
	dat += "All operations are done left-to-right. All trigonometric functions use degrees."

	var/datum/browser/popup = new(user, "circuit3", "[src]", 500, 300, src)
	popup.set_content(dat)
	popup.open()

	onclose(user, "circuit3")

	return

/obj/item/device/assembly/math/Topic(href, href_list)
	if(..()) return

	if(href_list["output_value"])
		to_chat(usr, "<span class='info'>Result: [get_value("Result")]</span>")
		return

	if(href_list["add_const"])
		spawn()
			var/choice = input(usr, "Please enter the constant's value:", "\The [src]") as null|num

			if(isnull(choice)) return
			if(..()) return

			values += choice
			to_chat(usr, "<span class='info'>Added new constant value <b>[choice]</b> to \the [src].</span>")

			attack_self(usr)
		return

	if(href_list["change_operation"])
		spawn()
			var/choice = input(usr, "Current operation is [operation]. Please select a new operation:", "\The [src]") as null|anything in math_circuit_operations_list

			if(isnull(choice)) return
			if(..()) return

			to_chat(usr, "<span class='info'>Changed operation from [operation] to [choice].</span>")
			operation = choice

			attack_self(usr)
		return

	if(href_list["change_value"])
		var/id = text2num(href_list["change_value"])

		if(id > values.len) return

		var/changed_value = values[id]

		if(isnum(changed_value)) //Constant

			spawn()
				var/choice = input(usr, "Please enter the constant ([changed_value])'s new value. Leave blank to delete the constant from \the [src]'s memory.", "\The [src]", changed_value) as null|num

				if(id > values.len) return
				if(values[id] != changed_value) return
				if(..()) return

				if(isnull(choice)) //Not number
					to_chat(usr, "<span class='info'>Removed the constant [values[id]].")
					values.Remove(changed_value)
				else //Wrote a number - change it
					to_chat(usr, "<span class='info'>Changed the constant [values[id]] to [choice].</span>")
					values[id] = choice

				attack_self(usr)

		else //Assembly (variable)

			spawn()
				var/obj/item/device/assembly/AS = changed_value

				var/choice = input(usr, "Please select which of \the [changed_value]'s values is used in calculations (current: [values[changed_value]]).", "\The [src]") as null|anything in AS.accessible_values

				if(isnull(choice)) return
				if(!values.Find(changed_value)) return
				if(..()) return

				to_chat(usr, "<span class='info'>Changed \the [changed_value]'s used value to [choice].</span>")
				values[changed_value] = choice

				attack_self(usr)

/obj/item/device/assembly/math/get_value(value)
	if(!values.len) return 0

	if(value != "Result")
		return ..(value)

	if(values.len == 1)
		var/obj/item/device/assembly/a = values[1]
		return VALUE(a)

	switch(operation)
		if("AVERAGE")
			. = 0

			for(var/number in values) //Add all values in the list together
				var/obj/item/device/assembly/a = number
				. += VALUE(a)

			. = . / values.len //Divide the resulting value by the length of the list
		if("MIN") //Return minimum value
			var/list/L = list()
			for(var/number in values)
				var/obj/item/device/assembly/a = number
				L += VALUE(a)

			. = min(L)
		if("MAX") //Return maximum value
			var/list/L = list()
			for(var/number in values)
				var/obj/item/device/assembly/a = number
				L += VALUE(a)

			. = max(L)

		if("COS")
			var/obj/item/device/assembly/a = values[1]
			. = cos(VALUE(a))
		if("SIN")
			var/obj/item/device/assembly/a = values[1]
			. = sin(VALUE(a))
		if("TG")
			var/obj/item/device/assembly/a = values[1]

			if(cos(VALUE(a)) == 0) return 0 //Avoid division by 0

			. = sin(VALUE(a)) / cos(VALUE(a))
		if("COTG")
			var/obj/item/device/assembly/a = values[1]

			if(sin(VALUE(a)) == 0) return 0 //Avoid division by 0

			. = cos(VALUE(a)) / sin(VALUE(a))
		if("ACOS")
			var/obj/item/device/assembly/a = values[1]
			. = arccos(VALUE(a))
		if("ASIN")
			var/obj/item/device/assembly/a = values[1]
			. = arcsin(VALUE(a))

		else

			var/obj/item/device/assembly/a = values[1]
			. = VALUE(a)

			for(var/i = 2 to values.len)
				var/number = values[i]

				if(istype(number, /obj/item/device/assembly))
					var/obj/item/device/assembly/A = number

					number = A.get_value(values[A])

				switch(operation)
					if("ADD")
						. += number
					if("SUBTRACT")
						. -= number
					if("MULTIPLY")
						. *= number
					if("DIVIDE")
						if(number == 0) return 0

						. /= number
					if("POWER")
						if(. < 0)
							if(number != round(number)) //No fractions in the exponent if value is negative
								return 0

						. = . ** number
					if("MOD")
						. %= number

	. = round(. , 0.00001) //Round to 5 decimal places (prevent shit like cos(90) = 6.12323e-017)

/obj/item/device/assembly/math/write_to_value(value, new_value)
	if(value == "Result") //Can't write to result
		return
	else if(value == "Operation") //Modifying operation
		new_value = uppertext(new_value)

		if(!math_circuit_operations_list.Find(new_value)) //Not a valid operation
			new_value = "ADD"

	return ..(value, new_value)

/obj/item/device/assembly/math/connected(var/obj/item/device/assembly/A, in_frame)
	..()

	if(istype(A, /obj/item/device/assembly/math))
		var/obj/item/device/assembly/math/M = A

		if(src in M.values)
			return //No infinite loops

	for(var/test_value in A.accessible_values) //Check all accessible values
		var/parameters = A.accessible_values[test_value] //First, grab their parameters

		if(parameters)
			var/list/L = params2list(parameters) //Turn them into a list and check the second value (the one that determines whether the value is number or text).

			if(L[VALUE_VARIABLE_TYPE] == "number")
				values[A] = test_value //Finally, if the added assembly HAS a numeric value that we can use, add the assembly to the list (and use the found numeric value)
				return


/obj/item/device/assembly/math/disconnected(var/obj/item/device/assembly/A, in_frame)
	..()
	values.Remove(A)

#undef VALUE
