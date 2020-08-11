GLOBAL_LIST_EMPTY(bitflag_lists)

/**
  * System for storing bitflags past the 24 limit, making use of an associative list.
  *
  * Proc converts a list of integers into an associative list of bitflag entries for quicker comparison.
  * Example: list(0, 4, 26, 32)) => list( "0" = ( (1<<0) | (1<<4) ), "1" = ( (1<<2) | (1<<8) ) )
  * Lists are cached into a global list of lists to avoid identical duplicates.
  * This system makes value comparisons faster than pairing every element of one list with every element of the other for evaluation.
  *
  * Arguments:
  * * values - List of integers.
  */
/proc/bitflag_list(list/values)
	var/txt_signature = values.Join("-")
	. = GLOB.bitflag_lists[txt_signature]
	if(.)
		return //We already have one such list cached.
	. = list() //Else let's compose one.
	for(var/val in values)
		.["[round(val / 24)]"] |= (1 << (val % 24))
	GLOB.bitflag_lists[txt_signature] = .
