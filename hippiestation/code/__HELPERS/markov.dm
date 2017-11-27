#define MAXIMUM_MARKOV_LENGTH 25000

/proc/markov_chain(var/text, var/order = 4, var/length = 250)
	if(!text || order < 0 || order > 20 || length < 1 || length > MAXIMUM_MARKOV_LENGTH)
		return

	var/table = markov_table(text, order)
	var/markov = markov_text(length, table, order)
	return markov

/proc/markov_table(var/text, var/look_forward = 4)
	if(!text)
		return
	var/list/table = list()

	for(var/i = 1, i <= length(text), i++)
		var/char = copytext(text, i, look_forward+i)
		if(!table[char])
			table[char] = list()

	for(var/i = 1, i <= (length(text) - look_forward), i++)
		var/char_index = copytext(text, i, look_forward+i)
		var/char_count = copytext(text, i+look_forward, (look_forward*2)+i)

		if(table[char_index][char_count])
			table[char_index][char_count]++
		else
			table[char_index][char_count] = 1

	return table

/proc/markov_text(var/length = 250, var/table, var/look_forward = 4)
	if(!table)
		return
	var/char = pick(table)
	var/o = char

	for(var/i = 0, i <= (length / look_forward), i++)
		var/newchar = markov_weighted_char(table[char])

		if(newchar)
			char = newchar
			o += "[newchar]"
		else
			char = pick(table)

	return o

/proc/markov_weighted_char(var/list/array)
	if(!array || !array.len)
		return

	var/total = 0
	for(var/i in array)
		total += array[i]
	var/r = rand(1, total)
	for(var/i in array)
		var/weight = array[i]
		if(r <= weight)
			return i
		r -= weight