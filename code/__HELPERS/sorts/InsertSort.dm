//simple insertion sort - generally faster than merge for runs of 7 or smaller
/proc/sortInsert(list/L, cmp=/proc/cmp_numeric_asc, associative, fromIndex=1, toIndex=0)
	if(L && L.len >= 2)
		fromIndex = fromIndex % L.len
		toIndex = toIndex % (L.len+1)
		if(fromIndex <= 0)
			fromIndex += L.len
		if(toIndex <= 0)
			toIndex += L.len + 1

		sortInstance.L = L
		sortInstance.cmp = cmp
		sortInstance.associative = associative

		//sortInstance.binarySort(fromIndex, toIndex, fromIndex)
		test_bs(L, cmp, fromIndex, toIndex, fromIndex)

	return L

proc/test_bs(list/L, cmp, lo, hi, start)
	//world << "binarySort: [lo] [hi] [start]: "

	ASSERT(lo <= start && start <= hi)
	if(start == lo)
		++start

	for(,start < hi, ++start)
		var/pivot = L[start]

		//set left and right to the index where pivot belongs
		var/left = lo
		var/right = start
		ASSERT(left <= right)

		//[lo, left) elements <= pivot < [right, start) elements
		//in other words, find where the pivot element should go using bisection search
		while(left < right)
			var/mid = (left + right) >> 1	//round((left+right)/2)
			if(call(cmp)(pivot, L[mid]) < 0)
				right = mid
			else
				left = mid+1

		ASSERT(left == right)
		moveElement(L, start, left)	//move pivot element to correct location in the sorted range