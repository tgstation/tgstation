/**
 * returns the arguments given to a generator and manually extracts them from the internal byond object
 * returns:
 * * flat list of strings for args given to the generator.
 * * Note: this means things like "list(1,2,3)" will need to be processed
 */
/proc/return_generator_args(generator/target)
	var/string_repr = "[target]" //the name of the generator is the string representation of its _binobj, which also contains its args
	string_repr = copytext(string_repr, 11, length(string_repr)) // strips extraneous data
	string_repr = replacetext(string_repr, "\"", "") // removes the " around the type
	return splittext(string_repr, ", ")

/generator/proc/RandList()
	var/possible_vector = Rand()
	var/vector_length = length(possible_vector)
	if(vector_length == 0)
		return possible_vector
	. = list()
	for(var/i in 1 to vector_length)
		. += possible_vector[i]
	return .
