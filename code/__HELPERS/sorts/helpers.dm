/proc/create_sort_instance(list/to_sort, cmp = /proc/cmp_numeric_asc, associative, fromIndex, toIndex) as /datum/sort_instance
	fromIndex = fromIndex % length(to_sort)
	toIndex = toIndex % (length(to_sort) + 1)

	if(fromIndex <= 0)
		fromIndex += length(to_sort)

	if(toIndex <= 0)
		toIndex += length(to_sort) + 1

	var/datum/sort_instance/sorter = GLOB.sortInstance
	if(isnull(sorter))
		sorter = new

	sorter.L = to_sort
	sorter.cmp = cmp
	sorter.associative = associative

	return sorter


/proc/sortInsert(list/to_sort, cmp = /proc/cmp_numeric_asc, associative = FALSE, fromIndex = 1, toIndex = 0) as /list
	if(length(to_sort) < 2)
		return to_sort

	var/datum/sort_instance/sorter = create_sort_instance(to_sort, cmp, associative, fromIndex, toIndex)

	sorter.binarySort(fromIndex, toIndex)

	return to_sort


/proc/sortMerge(list/to_sort, cmp = /proc/cmp_numeric_asc, associative = FALSE, fromIndex = 1, toIndex = 0) as /list
	if(length(to_sort) < 2)
		return to_sort

	var/datum/sort_instance/sorter = create_sort_instance(to_sort, cmp, associative, fromIndex, toIndex)

	sorter.mergeSort(fromIndex, toIndex)

	return to_sort


/proc/sortTim(list/to_sort, cmp = /proc/cmp_numeric_asc, associative = FALSE, fromIndex = 1, toIndex = 0) as /list
	if(length(to_sort) < 2)
		return to_sort

	var/datum/sort_instance/sorter = create_sort_instance(to_sort, cmp, associative, fromIndex, toIndex)

	sorter.timSort(fromIndex, toIndex)

	return to_sort
