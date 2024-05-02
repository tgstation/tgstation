/proc/create_sort_instance(list/to_sort, cmp = /proc/cmp_numeric_asc, associative, fromIndex, toIndex) as /datum/sort_instance
	fromIndex = fromIndex % to_
	toIndex = toIndex % (length(to_sort) + 1)

	if(fromIndex <= 0)
		fromIndex += length(to_sort)

	if(toIndex <= 0)
		toIndex += length(to_sort) + 1

	var/datum/sort_instance/SI = GLOB.sortInstance
	if(isnull(SI))
		SI = new

	SI.L = to_sort
	SI.cmp = cmp
	SI.associative = associative

	return SI


/proc/sortInsert(list/to_sort, cmp = /proc/cmp_numeric_asc, associative = FALSE, fromIndex = 1, toIndex = 0)
	if(length(to_sort) < 2)
		return to_sort

	var/datum/sort_instance/sorter = create_sort_instance(to_sort, cmp, associative, fromIndex, toIndex)

	sorter.binarySort(fromIndex, toIndex)


/proc/sortMerge(list/to_sort, cmp = /proc/cmp_numeric_asc, associative = FALSE, fromIndex = 1, toIndex = 0)
	if(length(to_sort) < 2)
		return to_sort

	var/datum/sort_instance/sorter = create_sort_instance(to_sort, cmp, associative, fromIndex, toIndex)

	sorter.mergeSort(fromIndex, toIndex)


/proc/sortTim(list/to_sort, cmp = /proc/cmp_numeric_asc, associative = FALSE, fromIndex = 1, toIndex = 0)
	if(length(to_sort) < 2)
		return to_sort

	var/datum/sort_instance/sorter = create_sort_instance(to_sort, cmp, associative, fromIndex, toIndex)

	sorter.timSort(fromIndex, toIndex)
