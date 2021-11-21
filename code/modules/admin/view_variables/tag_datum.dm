/client/proc/tag_datum(datum/D)
	if(!holder || !D)
		return
	holder.add_tagged_datum(D)

/client/proc/tag_datum_mapview(datum/D as mob|obj|turf|area in view(view))
	set category = "Debug"
	set name = "Tag Object"
	tag_datum(D)
