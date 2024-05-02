/// Helper for the sorting procs. Prevents some code duplication. Returns /datum/sort_instance/sorter
#define CREATE_SORT_INSTANCE(to_sort, cmp, associative, fromIndex, toIndex) \
	if (isnull(to_sort) || length(to_sort) < 2) { \
		return to_sort; \
	} \
	fromIndex = fromIndex % length(to_sort); \
	toIndex = toIndex % (length(to_sort) + 1); \
	if (fromIndex <= 0) { \
		fromIndex += length(to_sort); \
	} \
	if (toIndex <= 0) { \
		toIndex += length(to_sort) + 1; \
	} \
	var/datum/sort_instance/sorter = GLOB.sortInstance; \
	if (isnull(sorter)) { \
		sorter = new; \
	} \
	sorter.L = to_sort; \
	sorter.cmp = cmp; \
	sorter.associative = associative;


/**
 * ### Tim Sort
 * Hybrid sorting algorithm derived from merge sort and insertion sort.
 *
 * @see
 * - https://en.wikipedia.org/wiki/Timsort
 */
/proc/sortTim(list/to_sort, cmp = /proc/cmp_numeric_asc, associative, fromIndex = 1, toIndex = 0) as /list
	CREATE_SORT_INSTANCE(to_sort, cmp, associative, fromIndex, toIndex)

	sorter.timSort(fromIndex, toIndex)

	return to_sort


/**
 * ### Merge Sort
 * Divide and conquer sorting algorithm.
 *
 * @see
 * - https://en.wikipedia.org/wiki/Merge_sort
 */
/proc/sortMerge(list/to_sort, cmp = /proc/cmp_numeric_asc, associative, fromIndex = 1, toIndex = 0) as /list
	CREATE_SORT_INSTANCE(to_sort, cmp, associative, fromIndex, toIndex)

	sorter.mergeSort(fromIndex, toIndex)

	return to_sort


/**
 * ### Insertion Sort
 * Simple sorting algorithm that builds the final sorted list one item at a time.
 *
 * @see
 * - https://en.wikipedia.org/wiki/Insertion_sort
 */
/proc/sortInsert(list/to_sort, cmp = /proc/cmp_numeric_asc, associative, fromIndex = 1, toIndex = 0) as /list
	CREATE_SORT_INSTANCE(to_sort, cmp, associative, fromIndex, toIndex)

	sorter.binarySort(fromIndex, toIndex)

	return to_sort

#undef CREATE_SORT_INSTANCE
