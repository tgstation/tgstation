/*
 * Holds procs to help with list operations
 * Contains groups:
 * Misc
 * Sorting
 */

/*
 * Misc
 */

///Initialize the lazylist
#define LAZYINITLIST(L) if (!L) { L = list(); }
///If the provided list is empty, set it to null
#define UNSETEMPTY(L) if (L && !length(L)) L = null
///Like LAZYCOPY - copies an input list if the list has entries, If it doesn't the assigned list is nulled
#define LAZYLISTDUPLICATE(L) (L ? L.Copy() : null )
///Remove an item from the list, set the list to null if empty
#define LAZYREMOVE(L, I) if(L) { L -= I; if(!length(L)) { L = null; } }
///Add an item to the list, if the list is null it will initialize it
#define LAZYADD(L, I) if(!L) { L = list(); } L += I;
///Add an item to the list if not already present, if the list is null it will initialize it
#define LAZYOR(L, I) if(!L) { L = list(); } L |= I;
///Returns the key of the submitted item in the list
#define LAZYFIND(L, V) (L ? L.Find(V) : 0)
///returns L[I] if L exists and I is a valid index of L, runtimes if L is not a list
#define LAZYACCESS(L, I) (L ? (isnum(I) ? (I > 0 && I <= length(L) ? L[I] : null) : L[I]) : null)
///Sets the item K to the value V, if the list is null it will initialize it
#define LAZYSET(L, K, V) if(!L) { L = list(); } L[K] = V;
///Sets the length of a lazylist
#define LAZYSETLEN(L, V) if (!L) { L = list(); } L.len = V;
///Returns the lenght of the list
#define LAZYLEN(L) length(L)
///Sets a list to null
#define LAZYNULL(L) L = null
///Adds to the item K the value V, if the list is null it will initialize it
#define LAZYADDASSOC(L, K, V) if(!L) { L = list(); } L[K] += V;
///This is used to add onto lazy assoc list when the value you're adding is a /list/. This one has extra safety over lazyaddassoc because the value could be null (and thus cant be used to += objects)
#define LAZYADDASSOCLIST(L, K, V) if(!L) { L = list(); } L[K] += list(V);
///Removes the value V from the item K, if the item K is empty will remove it from the list, if the list is empty will set the list to null
#define LAZYREMOVEASSOC(L, K, V) if(L) { if(L[K]) { L[K] -= V; if(!length(L[K])) L -= K; } if(!length(L)) L = null; }
///Accesses an associative list, returns null if nothing is found
#define LAZYACCESSASSOC(L, I, K) L ? L[I] ? L[I][K] ? L[I][K] : null : null : null
///Qdel every item in the list before setting the list to null
#define QDEL_LAZYLIST(L) for(var/I in L) qdel(I); L = null;
//These methods don't null the list
///Use LAZYLISTDUPLICATE instead if you want it to null with no entries
#define LAZYCOPY(L) (L ? L.Copy() : list() )
/// Consider LAZYNULL instead
#define LAZYCLEARLIST(L) if(L) L.Cut()
///Returns the list if it's actually a valid list, otherwise will initialize it
#define SANITIZE_LIST(L) ( islist(L) ? L : list() )
#define reverseList(L) reverse_range(L.Copy())

/// Performs an insertion on the given lazy list with the given key and value. If the value already exists, a new one will not be made.
#define LAZYORASSOCLIST(lazy_list, key, value) \
	LAZYINITLIST(lazy_list); \
	LAZYINITLIST(lazy_list[key]); \
	lazy_list[key] |= value;

/// Passed into BINARY_INSERT to compare keys
#define COMPARE_KEY __BIN_LIST[__BIN_MID]
/// Passed into BINARY_INSERT to compare values
#define COMPARE_VALUE __BIN_LIST[__BIN_LIST[__BIN_MID]]

/****
	* Binary search sorted insert
	* INPUT: Object to be inserted
	* LIST: List to insert object into
	* TYPECONT: The typepath of the contents of the list
	* COMPARE: The object to compare against, usualy the same as INPUT
	* COMPARISON: The variable on the objects to compare
	* COMPTYPE: How should the values be compared? Either COMPARE_KEY or COMPARE_VALUE.
	*/
#define BINARY_INSERT(INPUT, LIST, TYPECONT, COMPARE, COMPARISON, COMPTYPE) \
	do {\
		var/list/__BIN_LIST = LIST;\
		var/__BIN_CTTL = length(__BIN_LIST);\
		if(!__BIN_CTTL) {\
			__BIN_LIST += INPUT;\
		} else {\
			var/__BIN_LEFT = 1;\
			var/__BIN_RIGHT = __BIN_CTTL;\
			var/__BIN_MID = (__BIN_LEFT + __BIN_RIGHT) >> 1;\
			var ##TYPECONT/__BIN_ITEM;\
			while(__BIN_LEFT < __BIN_RIGHT) {\
				__BIN_ITEM = COMPTYPE;\
				if(__BIN_ITEM.##COMPARISON <= COMPARE.##COMPARISON) {\
					__BIN_LEFT = __BIN_MID + 1;\
				} else {\
					__BIN_RIGHT = __BIN_MID;\
				};\
				__BIN_MID = (__BIN_LEFT + __BIN_RIGHT) >> 1;\
			};\
			__BIN_ITEM = COMPTYPE;\
			__BIN_MID = __BIN_ITEM.##COMPARISON > COMPARE.##COMPARISON ? __BIN_MID : __BIN_MID + 1;\
			__BIN_LIST.Insert(__BIN_MID, INPUT);\
		};\
	} while(FALSE)

/**
 * Custom binary search sorted insert utilising comparison procs instead of vars.
 * INPUT: Object to be inserted
 * LIST: List to insert object into
 * TYPECONT: The typepath of the contents of the list
 * COMPARE: The object to compare against, usualy the same as INPUT
 * COMPARISON: The plaintext name of a proc on INPUT that takes a single argument to accept a single element from LIST and returns a positive, negative or zero number to perform a comparison.
 * COMPTYPE: How should the values be compared? Either COMPARE_KEY or COMPARE_VALUE.
 */
#define BINARY_INSERT_PROC_COMPARE(INPUT, LIST, TYPECONT, COMPARE, COMPARISON, COMPTYPE) \
	do {\
		var/list/__BIN_LIST = LIST;\
		var/__BIN_CTTL = length(__BIN_LIST);\
		if(!__BIN_CTTL) {\
			__BIN_LIST += INPUT;\
		} else {\
			var/__BIN_LEFT = 1;\
			var/__BIN_RIGHT = __BIN_CTTL;\
			var/__BIN_MID = (__BIN_LEFT + __BIN_RIGHT) >> 1;\
			var ##TYPECONT/__BIN_ITEM;\
			while(__BIN_LEFT < __BIN_RIGHT) {\
				__BIN_ITEM = COMPTYPE;\
				if(__BIN_ITEM.##COMPARISON(COMPARE) <= 0) {\
					__BIN_LEFT = __BIN_MID + 1;\
				} else {\
					__BIN_RIGHT = __BIN_MID;\
				};\
				__BIN_MID = (__BIN_LEFT + __BIN_RIGHT) >> 1;\
			};\
			__BIN_ITEM = COMPTYPE;\
			__BIN_MID = __BIN_ITEM.##COMPARISON(COMPARE) > 0 ? __BIN_MID : __BIN_MID + 1;\
			__BIN_LIST.Insert(__BIN_MID, INPUT);\
		};\
	} while(FALSE)

#define SORT_FIRST_INDEX(list) (list[1])
#define SORT_VAR_NO_TYPE(varname) var/varname
/****
	* Even more custom binary search sorted insert, using defines instead of vars
	* INPUT: Item to be inserted
	* LIST: List to insert INPUT into
	* TYPECONT: A define setting the var to the typepath of the contents of the list
	* COMPARE: The item to compare against, usualy the same as INPUT
	* COMPARISON: A define that takes an item to compare as input, and returns their comparable value
	* COMPTYPE: How should the list be compared? Either COMPARE_KEY or COMPARE_VALUE.
	*/
#define BINARY_INSERT_DEFINE(INPUT, LIST, TYPECONT, COMPARE, COMPARISON, COMPTYPE) \
	do {\
		var/list/__BIN_LIST = LIST;\
		var/__BIN_CTTL = length(__BIN_LIST);\
		if(!__BIN_CTTL) {\
			__BIN_LIST += INPUT;\
		} else {\
			var/__BIN_LEFT = 1;\
			var/__BIN_RIGHT = __BIN_CTTL;\
			var/__BIN_MID = (__BIN_LEFT + __BIN_RIGHT) >> 1;\
			##TYPECONT(__BIN_ITEM);\
			while(__BIN_LEFT < __BIN_RIGHT) {\
				__BIN_ITEM = COMPTYPE;\
				if(##COMPARISON(__BIN_ITEM) <= ##COMPARISON(COMPARE)) {\
					__BIN_LEFT = __BIN_MID + 1;\
				} else {\
					__BIN_RIGHT = __BIN_MID;\
				};\
				__BIN_MID = (__BIN_LEFT + __BIN_RIGHT) >> 1;\
			};\
			__BIN_ITEM = COMPTYPE;\
			__BIN_MID = ##COMPARISON(__BIN_ITEM) > ##COMPARISON(COMPARE) ? __BIN_MID : __BIN_MID + 1;\
			__BIN_LIST.Insert(__BIN_MID, INPUT);\
		};\
	} while(FALSE)

///Returns a list in plain english as a string
/proc/english_list(list/input, nothing_text = "nothing", and_text = " and ", comma_text = ", ", final_comma_text = "" )
	var/total = length(input)
	switch(total)
		if (0)
			return "[nothing_text]"
		if (1)
			return "[input[1]]"
		if (2)
			return "[input[1]][and_text][input[2]]"
		else
			var/output = ""
			var/index = 1
			while (index < total)
				if (index == total - 1)
					comma_text = final_comma_text

				output += "[input[index]][comma_text]"
				index++

			return "[output][and_text][input[index]]"

/**
 * Checks for specific types in a list.
 *
 * If using zebra mode the list should be an assoc list with truthy/falsey values.
 * The check short circuits so earlier entries in the input list will take priority.
 * Ergo, subtypes should come before parent types.
 * Notice that this is the opposite priority of [/proc/typecacheof].
 *
 * Arguments:
 * - [type_to_check][/datum]: An instance to check.
 * - [list_to_check][/list]: A list of typepaths to check the type_to_check against.
 * - zebra: Whether to use the value of the mathing type in the list instead of just returning true when a match is found.
 */
/proc/is_type_in_list(datum/type_to_check, list/list_to_check, zebra = FALSE)
	if(!LAZYLEN(list_to_check) || !type_to_check)
		return FALSE
	for(var/type in list_to_check)
		if(istype(type_to_check, type))
			return !zebra || list_to_check[type] // Subtypes must come first in zebra lists.
	return FALSE

/**
 * Checks for specific paths in a list.
 *
 * If using zebra mode the list should be an assoc list with truthy/falsey values.
 * The check short circuits so earlier entries in the input list will take priority.
 * Ergo, subpaths should come before parent paths.
 * Notice that this is the opposite priority of [/proc/typecacheof].
 *
 * Arguments:
 * - path_to_check: A typepath to check.
 * - [list_to_check][/list]: A list of typepaths to check the path_to_check against.
 * - zebra: Whether to use the value of the mathing path in the list instead of just returning true when a match is found.
 */
/proc/is_path_in_list(path_to_check, list/list_to_check, zebra = FALSE)
	if(!LAZYLEN(list_to_check) || !path_to_check)
		return FALSE
	for(var/path in list_to_check)
		if(ispath(path_to_check, path))
			return !zebra || list_to_check[path]
	return FALSE

///Checks for specific types in specifically structured (Assoc "type" = TRUE|FALSE) lists ('typecaches')
#define is_type_in_typecache(A, L) (A && length(L) && L[(ispath(A) ? A : A:type)])

///returns a new list with only atoms that are in the typecache list
/proc/typecache_filter_list(list/atoms, list/typecache)
	RETURN_TYPE(/list)
	. = list()
	for(var/atom/atom_checked as anything in atoms)
		if (typecache[atom_checked.type])
			. += atom_checked

///return a new list with atoms that are not in the typecache list
/proc/typecache_filter_list_reverse(list/atoms, list/typecache)
	RETURN_TYPE(/list)
	. = list()
	for(var/atom/atom_checked as anything in atoms)
		if(!typecache[atom_checked.type])
			. += atom_checked

///similar to typecache_filter_list and typecache_filter_list_reverse but it supports an inclusion list and and exclusion list
/proc/typecache_filter_multi_list_exclusion(list/atoms, list/typecache_include, list/typecache_exclude)
	. = list()
	for(var/atom/atom_checked as anything in atoms)
		if(typecache_include[atom_checked.type] && !typecache_exclude[atom_checked.type])
			. += atom_checked

/**
 * Like typesof() or subtypesof(), but returns a typecache instead of a list.
 *
 * Arguments:
 * - path: A typepath or list of typepaths.
 * - only_root_path: Whether the typecache should be specifically of the passed types.
 * - ignore_root_path: Whether to ignore the root path when caching subtypes.
 */
/proc/typecacheof(path, only_root_path = FALSE, ignore_root_path = FALSE)
	if(isnull(path))
		return

	if(ispath(path))
		. = list()
		if(only_root_path)
			.[path] = TRUE
			return

		for(var/subtype in (ignore_root_path ? subtypesof(path) : typesof(path)))
			.[subtype] = TRUE
		return

	if(!islist(path))
		CRASH("Tried to create a typecache of [path] which is neither a typepath nor a list.")

	. = list()
	var/list/pathlist = path
	if(only_root_path)
		for(var/current_path in pathlist)
			.[current_path] = TRUE
	else if(ignore_root_path)
		for(var/current_path in pathlist)
			for(var/subtype in subtypesof(current_path))
				.[subtype] = TRUE
	else
		for(var/current_path in pathlist)
			for(var/subpath in typesof(current_path))
				.[subpath] = TRUE

/**
 * Like typesof() or subtypesof(), but returns a typecache instead of a list.
 * This time it also uses the associated values given by the input list for the values of the subtypes.
 *
 * Latter values from the input list override earlier values.
 * Thus subtypes should come _after_ parent types in the input list.
 * Notice that this is the opposite priority of [/proc/is_type_in_list] and [/proc/is_path_in_list].
 *
 * Arguments:
 * - path: A typepath or list of typepaths with associated values.
 * - single_value: The assoc value used if only a single path is passed as the first variable.
 * - only_root_path: Whether the typecache should be specifically of the passed types.
 * - ignore_root_path: Whether to ignore the root path when caching subtypes.
 * - clear_nulls: Whether to remove keys with null assoc values from the typecache after generating it.
 */
/proc/zebra_typecacheof(path, single_value = TRUE, only_root_path = FALSE, ignore_root_path = FALSE, clear_nulls = FALSE)
	if(isnull(path))
		return

	if(ispath(path))
		if (isnull(single_value))
			return

		. = list()
		if(only_root_path)
			.[path] = single_value
			return

		for(var/subtype in (ignore_root_path ? subtypesof(path) : typesof(path)))
			.[subtype] = single_value
		return

	if(!islist(path))
		CRASH("Tried to create a typecache of [path] which is neither a typepath nor a list.")

	. = list()
	var/list/pathlist = path
	if(only_root_path)
		for(var/current_path in pathlist)
			.[current_path] = pathlist[current_path]
	else if(ignore_root_path)
		for(var/current_path in pathlist)
			for(var/subtype in subtypesof(current_path))
				.[subtype] = pathlist[current_path]
	else
		for(var/current_path in pathlist)
			for(var/subpath in typesof(current_path))
				.[subpath] = pathlist[current_path]

	if(!clear_nulls)
		return

	for(var/cached_path in .)
		if (isnull(.[cached_path]))
			. -= cached_path


/**
 * Removes any null entries from the list
 * Returns TRUE if the list had nulls, FALSE otherwise
**/
/proc/list_clear_nulls(list/list_to_clear)
	var/start_len = list_to_clear.len
	var/list/new_list = new(start_len)
	list_to_clear -= new_list
	return list_to_clear.len < start_len

/*
 * Returns list containing all the entries from first list that are not present in second.
 * If skiprep = 1, repeated elements are treated as one.
 * If either of arguments is not a list, returns null
 */
/proc/difflist(list/first, list/second, skiprep=0)
	if(!islist(first) || !islist(second))
		return
	var/list/result = new
	if(skiprep)
		for(var/e in first)
			if(!(e in result) && !(e in second))
				result += e
	else
		result = first - second
	return result

/*
 * Returns list containing entries that are in either list but not both.
 * If skipref = 1, repeated elements are treated as one.
 * If either of arguments is not a list, returns null
 */
/proc/unique_merge_list(list/first, list/second, skiprep=0)
	if(!islist(first) || !islist(second))
		return
	var/list/result = new
	if(skiprep)
		result = difflist(first, second, skiprep)+difflist(second, first, skiprep)
	else
		result = first ^ second
	return result

/**
 * Picks a random element from a list based on a weighting system.
 * For example, given the following list:
 * A = 6, B = 3, C = 1, D = 0
 * A would have a 60% chance of being picked,
 * B would have a 30% chance of being picked,
 * C would have a 10% chance of being picked,
 * and D would have a 0% chance of being picked.
 * You should only pass integers in.
 */
/proc/pick_weight(list/list_to_pick)
	var/total = 0
	var/item
	for(item in list_to_pick)
		if(!list_to_pick[item])
			list_to_pick[item] = 0
		total += list_to_pick[item]

	total = rand(0, total)
	for(item in list_to_pick)
		total -= list_to_pick[item]
		if(total <= 0 && list_to_pick[item])
			return item

	return null

/// Pick a random element from the list and remove it from the list.
/proc/pick_n_take(list/list_to_pick)
	RETURN_TYPE(list_to_pick[_].type)
	if(list_to_pick.len)
		var/picked = rand(1,list_to_pick.len)
		. = list_to_pick[picked]
		list_to_pick.Cut(picked,picked+1) //Cut is far more efficient that Remove()

///Returns the top(last) element from the list and removes it from the list (typical stack function)
/proc/pop(list/L)
	if(L.len)
		. = L[L.len]
		L.len--

/// Returns the top (last) element from the list, does not remove it from the list. Stack functionality.
/proc/peek(list/target_list)
	var/list_length = length(target_list)
	if(list_length != 0)
		return target_list[list_length]

/proc/popleft(list/L)
	if(L.len)
		. = L[1]
		L.Cut(1,2)

/proc/sorted_insert(list/L, thing, comparator)
	var/pos = L.len
	while(pos > 0 && call(comparator)(thing, L[pos]) > 0)
		pos--
	L.Insert(pos+1, thing)

/// Returns the next item in a list
/proc/next_list_item(item, list/inserted_list)
	var/i
	i = inserted_list.Find(item)
	if(i == inserted_list.len)
		i = 1
	else
		i++
	return inserted_list[i]

/// Returns the previous item in a list
/proc/previous_list_item(item, list/inserted_list)
	var/i
	i = inserted_list.Find(item)
	if(i == 1)
		i = inserted_list.len
	else
		i--
	return inserted_list[i]

///Randomize: Return the list in a random order
/proc/shuffle(list/inserted_list)
	if(!inserted_list)
		return
	inserted_list = inserted_list.Copy()

	for(var/i in 1 to inserted_list.len - 1)
		inserted_list.Swap(i, rand(i, inserted_list.len))

	return inserted_list

///same as shuffle, but returns nothing and acts on list in place
/proc/shuffle_inplace(list/inserted_list)
	if(!inserted_list)
		return

	for(var/i in 1 to inserted_list.len - 1)
		inserted_list.Swap(i, rand(i, inserted_list.len))

///Return a list with no duplicate entries
/proc/unique_list(list/inserted_list)
	. = list()
	for(var/i in inserted_list)
		. |= i

///same as unique_list, but returns nothing and acts on list in place (also handles associated values properly)
/proc/unique_list_in_place(list/inserted_list)
	var/temp = inserted_list.Copy()
	inserted_list.len = 0
	for(var/key in temp)
		if (isnum(key))
			inserted_list |= key
		else
			inserted_list[key] = temp[key]

///for sorting clients or mobs by ckey
/proc/sort_key(list/ckey_list, order=1)
	return sortTim(ckey_list, order >= 0 ? /proc/cmp_ckey_asc : /proc/cmp_ckey_dsc)

///Specifically for record datums in a list.
/proc/sort_record(list/record_list, field = "name", order = 1)
	GLOB.cmp_field = field
	return sortTim(record_list, order >= 0 ? /proc/cmp_records_asc : /proc/cmp_records_dsc)

///sort any value in a list
/proc/sort_list(list/list_to_sort, cmp=/proc/cmp_text_asc)
	return sortTim(list_to_sort.Copy(), cmp)

///uses sort_list() but uses the var's name specifically. This should probably be using mergeAtom() instead
/proc/sort_names(list/list_to_sort, order=1)
	return sortTim(list_to_sort.Copy(), order >= 0 ? /proc/cmp_name_asc : /proc/cmp_name_dsc)

///Converts a bitfield to a list of numbers (or words if a wordlist is provided)
/proc/bitfield_to_list(bitfield = 0, list/wordlist)
	var/list/return_list = list()
	if(islist(wordlist))
		var/max = min(wordlist.len, 24)
		var/bit = 1
		for(var/i in 1 to max)
			if(bitfield & bit)
				return_list += wordlist[i]
			bit = bit << 1
	else
		for(var/bit_number = 0 to 23)
			var/bit = 1 << bit_number
			if(bitfield & bit)
				return_list += bit

	return return_list

/// Returns the key based on the index
#define KEYBYINDEX(L, index) (((index <= length(L)) && (index > 0)) ? L[index] : null)

///return the amount of items of the same type inside a list
/proc/count_by_type(list/inserted_list, type)
	var/i = 0
	for(var/item_type in inserted_list)
		if(istype(item_type, type))
			i++
	return i

/// Returns datum/data/record
/proc/find_record(field, value, list/inserted_list)
	for(var/datum/data/record/record_to_check in inserted_list)
		if(record_to_check.fields[field] == value)
			return record_to_check
	return null


/**
 * Move a single element from position from_index within a list, to position to_index
 * All elements in the range [1,to_index) before the move will be before the pivot afterwards
 * All elements in the range [to_index, L.len+1) before the move will be after the pivot afterwards
 * In other words, it's as if the range [from_index,to_index) have been rotated using a <<< operation common to other languages.
 * from_index and to_index must be in the range [1,L.len+1]
 * This will preserve associations ~Carnie
**/
/proc/move_element(list/inserted_list, from_index, to_index)
	if(from_index == to_index || from_index + 1 == to_index) //no need to move
		return
	if(from_index > to_index)
		++from_index //since a null will be inserted before from_index, the index needs to be nudged right by one

	inserted_list.Insert(to_index, null)
	inserted_list.Swap(from_index, to_index)
	inserted_list.Cut(from_index, from_index + 1)


/**
 * Move elements [from_index,from_index+len) to [to_index-len, to_index)
 * Same as moveElement but for ranges of elements
 * This will preserve associations ~Carnie
**/
/proc/move_range(list/inserted_list, from_index, to_index, len = 1)
	var/distance = abs(to_index - from_index)
	if(len >= distance) //there are more elements to be moved than the distance to be moved. Therefore the same result can be achieved (with fewer operations) by moving elements between where we are and where we are going. The result being, our range we are moving is shifted left or right by dist elements
		if(from_index <= to_index)
			return //no need to move
		from_index += len //we want to shift left instead of right

		for(var/i in 1 to distance)
			inserted_list.Insert(from_index, null)
			inserted_list.Swap(from_index, to_index)
			inserted_list.Cut(to_index, to_index + 1)
	else
		if(from_index > to_index)
			from_index += len

		for(var/i in 1 to len)
			inserted_list.Insert(to_index, null)
			inserted_list.Swap(from_index, to_index)
			inserted_list.Cut(from_index, from_index + 1)

///Move elements from [from_index, from_index+len) to [to_index, to_index+len)
///Move any elements being overwritten by the move to the now-empty elements, preserving order
///Note: if the two ranges overlap, only the destination order will be preserved fully, since some elements will be within both ranges ~Carnie
/proc/swap_range(list/inserted_list, from_index, to_index, len=1)
	var/distance = abs(to_index - from_index)
	if(len > distance) //there is an overlap, therefore swapping each element will require more swaps than inserting new elements
		if(from_index < to_index)
			to_index += len
		else
			from_index += len

		for(var/i in 1 to distance)
			inserted_list.Insert(from_index, null)
			inserted_list.Swap(from_index, to_index)
			inserted_list.Cut(to_index, to_index + 1)
	else
		if(to_index > from_index)
			var/a = to_index
			to_index = from_index
			from_index = a

		for(var/i in 1 to len)
			inserted_list.Swap(from_index++, to_index++)

///replaces reverseList ~Carnie
/proc/reverse_range(list/inserted_list, start = 1, end = 0)
	if(inserted_list.len)
		start = start % inserted_list.len
		end = end % (inserted_list.len + 1)
		if(start <= 0)
			start += inserted_list.len
		if(end <= 0)
			end += inserted_list.len + 1

		--end
		while(start < end)
			inserted_list.Swap(start++, end--)

	return inserted_list


///return first thing in L which has var/varname == value
///this is typecaste as list/L, but you could actually feed it an atom instead.
///completely safe to use
/proc/get_element_by_var(list/inserted_list, varname, value)
	varname = "[varname]"
	for(var/datum/checked_datum in inserted_list)
		if(!checked_datum.vars.Find(varname))
			continue
		if(checked_datum.vars[varname] == value)
			return checked_datum

///remove all nulls from a list
/proc/remove_nulls_from_list(list/inserted_list)
	while(inserted_list.Remove(null))
		continue
	return inserted_list

///Copies a list, and all lists inside it recusively
///Does not copy any other reference type
/proc/deep_copy_list(list/inserted_list)
	if(!islist(inserted_list))
		return inserted_list
	. = inserted_list.Copy()
	for(var/i in 1 to inserted_list.len)
		var/key = .[i]
		if(isnum(key))
			// numbers cannot ever be associative keys
			continue
		var/value = .[key]
		if(islist(value))
			value = deep_copy_list(value)
			.[key] = value
		if(islist(key))
			key = deep_copy_list(key)
			.[i] = key
			.[key] = value

///takes an input_key, as text, and the list of keys already used, outputting a replacement key in the format of "[input_key] ([number_of_duplicates])" if it finds a duplicate
///use this for lists of things that might have the same name, like mobs or objects, that you plan on giving to a player as input
/proc/avoid_assoc_duplicate_keys(input_key, list/used_key_list)
	if(!input_key || !istype(used_key_list))
		return
	if(used_key_list[input_key])
		used_key_list[input_key]++
		input_key = "[input_key] ([used_key_list[input_key]])"
	else
		used_key_list[input_key] = 1
	return input_key

///Flattens a keyed list into a list of it's contents
/proc/flatten_list(list/key_list)
	if(!islist(key_list))
		return null
	. = list()
	for(var/key in key_list)
		. |= key_list[key]

///Make a normal list an associative one
/proc/make_associative(list/flat_list)
	. = list()
	for(var/thing in flat_list)
		.[thing] = TRUE

///Picks from the list, with some safeties, and returns the "default" arg if it fails
#define DEFAULTPICK(L, default) ((islist(L) && length(L)) ? pick(L) : default)

/* Definining a counter as a series of key -> numeric value entries

 * All these procs modify in place.
*/

/proc/counterlist_scale(list/L, scalar)
	var/list/out = list()
	for(var/key in L)
		out[key] = L[key] * scalar
	. = out

/proc/counterlist_sum(list/L)
	. = 0
	for(var/key in L)
		. += L[key]

/proc/counterlist_normalise(list/L)
	var/avg = counterlist_sum(L)
	if(avg != 0)
		. = counterlist_scale(L, 1 / avg)
	else
		. = L

/proc/counterlist_combine(list/L1, list/L2)
	for(var/key in L2)
		var/other_value = L2[key]
		if(key in L1)
			L1[key] += other_value
		else
			L1[key] = other_value

/// Turns an associative list into a flat list of keys
/proc/assoc_to_keys(list/input)
	var/list/keys = list()
	for(var/key in input)
		keys += key
	return keys

///compare two lists, returns TRUE if they are the same
/proc/compare_list(list/l,list/d)
	if(!islist(l) || !islist(d))
		return FALSE

	if(l.len != d.len)
		return FALSE

	for(var/i in 1 to l.len)
		if(l[i] != d[i])
			return FALSE

	return TRUE

#define LAZY_LISTS_OR(left_list, right_list)\
	( length(left_list)\
		? length(right_list)\
			? (left_list | right_list)\
			: left_list.Copy()\
		: length(right_list)\
			? right_list.Copy()\
			: null\
	)

///Returns a list with items filtered from a list that can call callback
/proc/special_list_filter(list/list_to_filter, datum/callback/condition)
	if(!islist(list_to_filter) || !length(list_to_filter) || !istype(condition))
		return list()
	. = list()
	for(var/i in list_to_filter)
		if(condition.Invoke(i))
			. |= i

///Returns a list with all weakrefs resolved
/proc/recursive_list_resolve(list/list_to_resolve)
	. = list()
	for(var/element in list_to_resolve)
		if(istext(element))
			. += element
			var/possible_assoc_value = list_to_resolve[element]
			if(possible_assoc_value)
				.[element] = recursive_list_resolve_element(possible_assoc_value)
		else
			. += list(recursive_list_resolve_element(element))

///Helper for /proc/recursive_list_resolve
/proc/recursive_list_resolve_element(element)
	if(islist(element))
		var/list/inner_list = element
		return recursive_list_resolve(inner_list)
	else if(isweakref(element))
		var/datum/weakref/ref = element
		return ref.resolve()
	else
		return element
