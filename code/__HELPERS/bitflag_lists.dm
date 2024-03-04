GLOBAL_LIST_EMPTY(bitflag_lists)

/**
 * System for storing bitflags past the 24 limit, making use of an associative list.
 *
 * Macro converts a list of integers into an associative list of bitflag entries for quicker comparison.
 * Example: list(0, 4, 26, 32)) => list( "0" = ( (1<<0) | (1<<4) ), "1" = ( (1<<2) | (1<<8) ) )
 * Lists are cached into a global list of lists to avoid identical duplicates.
 * This system makes value comparisons faster than pairing every element of one list with every element of the other for evaluation.
 *
 * Arguments:
 * * target - List of integers.
 */
#define SET_SMOOTHING_GROUPS(target) \
	do { \
		var/txt_signature = target; \
		if(isnull((target = GLOB.bitflag_lists[txt_signature]))) { \
			var/list/new_bitflag_list = list(); \
			var/list/decoded = UNWRAP_SMOOTHING_GROUPS(txt_signature, decoded); \
			for(var/value in decoded) { \
				if (value < 0) { \
					value = MAX_S_TURF + 1 + abs(value); \
				} \
				new_bitflag_list["[round(value / 24)]"] |= (1 << (value % 24)); \
			}; \
			target = GLOB.bitflag_lists[txt_signature] = new_bitflag_list; \
		}; \
	} while (FALSE)
