/// Sorts the list in place with timSort, default settings.
#define SORT_TIM(to_sort, associative) if(length(to_sort) >= 2) { \
	var/datum/sort_instance/sorter = GLOB.sortInstance; \
	if (isnull(sorter)) { \
		sorter = new; \
	} \
	sorter.L = to_sort; \
	sorter.cmp = GLOBAL_PROC_REF(cmp_numeric_asc); \
	sorter.associative = associative; \
	sorter.timSort(1, 0); \
}


/// Helper for the sorting procs. Prevents some code duplication. Creates /datum/sort_instance/sorter
#define CREATE_SORT_INSTANCE(to_sort, cmp, associative, fromIndex, toIndex) \
	if(length(to_sort) < 2) { \
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
 * ## Tim Sort
 * Hybrid sorting algorithm derived from merge sort and insertion sort.
 *
 * **Sorts in place**.
 * You might not need to get the return value.
 *
 * @see
 * https://en.wikipedia.org/wiki/Timsort
 *
 * @param {list} to_sort - The list to sort.
 *
 * @param {proc} cmp - The comparison proc to use. Default: Numeric ascending.
 *
 * @param {boolean} associative - Whether the list is associative. Default: FALSE.
 *
 * @param {int} fromIndex - The index to start sorting from. Default: 1.
 *
 * @param {int} toIndex - The index to stop sorting at. Default: 0.
 */
/proc/sortTim(list/to_sort, cmp = GLOBAL_PROC_REF(cmp_numeric_asc), associative = FALSE, fromIndex = 1, toIndex = 0) as /list
	CREATE_SORT_INSTANCE(to_sort, cmp, associative, fromIndex, toIndex)

	sorter.timSort(fromIndex, toIndex)

	return to_sort


/**
 * ## Merge Sort
 * Divide and conquer sorting algorithm.
 *
 * @see
 * - https://en.wikipedia.org/wiki/Merge_sort
 */
/proc/sortMerge(list/to_sort, cmp = GLOBAL_PROC_REF(cmp_numeric_asc), associative = FALSE, fromIndex = 1, toIndex = 0) as /list
	CREATE_SORT_INSTANCE(to_sort, cmp, associative, fromIndex, toIndex)

	sorter.mergeSort(fromIndex, toIndex)

	return to_sort


/**
 * ## Insertion Sort
 * Simple sorting algorithm that builds the final sorted list one item at a time.
 *

 * @see
 * - https://en.wikipedia.org/wiki/Insertion_sort
 */
/proc/sortInsert(list/to_sort, cmp = GLOBAL_PROC_REF(cmp_numeric_asc), associative = FALSE, fromIndex = 1, toIndex = 0) as /list
	CREATE_SORT_INSTANCE(to_sort, cmp, associative, fromIndex, toIndex)

	sorter.binarySort(fromIndex, toIndex)

	return to_sort


#undef CREATE_SORT_INSTANCE
