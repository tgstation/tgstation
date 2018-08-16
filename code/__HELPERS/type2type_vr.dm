/*
// Contains VOREStation based vore description type2type functions
// list2text - takes delimiter and returns text
// text2list - takes delimiter, and creates list
//
*/

// Concatenates a list of strings into a single string.  A seperator may optionally be provided.
/proc/list2text(list/ls, sep)
	if (ls.len <= 1) // Early-out code for empty or singleton lists.
		return ls.len ? ls[1] : ""

	var/l = ls.len // Made local for sanic speed.
	var/i = 0      // Incremented every time a list index is accessed.

	if (sep <> null)
		// Macros expand to long argument lists like so: sep, ls[++i], sep, ls[++i], sep, ls[++i], etc...
		#define S1  sep, ls[++i]
		#define S4  S1,  S1,  S1,  S1
		#define S16 S4,  S4,  S4,  S4
		#define S64 S16, S16, S16, S16

		. = "[ls[++i]]" // Make sure the initial element is converted to text.

		// Having the small concatenations come before the large ones boosted speed by an average of at least 5%.
		if (l-1 & 0x01) // 'i' will always be 1 here.
			. = text("[][][]", ., S1) // Append 1 element if the remaining elements are not a multiple of 2.
		if (l-i & 0x02)
			. = text("[][][][][]", ., S1, S1) // Append 2 elements if the remaining elements are not a multiple of 4.
		if (l-i & 0x04)
			. = text("[][][][][][][][][]", ., S4) // And so on....
		if (l-i & 0x08)
			. = text("[][][][][][][][][][][][][][][][][]", ., S4, S4)
		if (l-i & 0x10)
			. = text("[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]", ., S16)
		if (l-i & 0x20)
			. = text("[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
			          [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]", ., S16, S16)
		if (l-i & 0x40)
			. = text("[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
			          [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
			          [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
			          [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]", ., S64)
		while (l > i) // Chomp through the rest of the list, 128 elements at a time.
			. = text("[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
			          [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
			          [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
			          [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
			          [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
			          [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
			          [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
			          [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]", ., S64, S64)

		#undef S64
		#undef S16
		#undef S4
		#undef S1
	else
		// Macros expand to long argument lists like so: ls[++i], ls[++i], ls[++i], etc...
		#define S1  ls[++i]
		#define S4  S1,  S1,  S1,  S1
		#define S16 S4,  S4,  S4,  S4
		#define S64 S16, S16, S16, S16

		. = "[ls[++i]]" // Make sure the initial element is converted to text.

		if (l-1 & 0x01) // 'i' will always be 1 here.
			. += S1 // Append 1 element if the remaining elements are not a multiple of 2.
		if (l-i & 0x02)
			. = text("[][][]", ., S1, S1) // Append 2 elements if the remaining elements are not a multiple of 4.
		if (l-i & 0x04)
			. = text("[][][][][]", ., S4) // And so on...
		if (l-i & 0x08)
			. = text("[][][][][][][][][]", ., S4, S4)
		if (l-i & 0x10)
			. = text("[][][][][][][][][][][][][][][][][]", ., S16)
		if (l-i & 0x20)
			. = text("[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]", ., S16, S16)
		if (l-i & 0x40)
			. = text("[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
			          [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]", ., S64)
		while (l > i) // Chomp through the rest of the list, 128 elements at a time.
			. = text("[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
			          [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
			          [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
			          [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]", ., S64, S64)

		#undef S64
		#undef S16
		#undef S4
		#undef S1

// Converts a string into a list by splitting the string at each delimiter found. (discarding the seperator)
/proc/text2list(text, delimiter="\n")
	var/delim_len = length(delimiter)
	if (delim_len < 1)
		return list(text)

	. = list()
	var/last_found = 1
	var/found

	do
		found       = findtext(text, delimiter, last_found, 0)
		.          += copytext(text, last_found, found)
		last_found  = found + delim_len
	while (found)

// Returns true if val is from min to max, inclusive.
/proc/IsInRange(val, min, max)
	return (val >= min) && (val <= max)