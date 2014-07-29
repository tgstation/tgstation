//Return a randomly picked element in a weighted list.
//
//structure: elem1,weight1,elem2,weight2,...,elemN,weightN
//
/proc/weighted_pick(var/list/weightedlist)
	if(!weightedlist.len)
		return

	var/list/picktable
	for(var/i = 1, i <= weightedlist.len, i+=2)
		var/entry =  weightedlist[i]
		var/weight = weightedlist[i+1]

		if(weight > 0)
			for(var/j = 0, j < weight, j++)
				picktable += list(entry)

	return pick(picktable)