
/proc/overwrite_field_if_available(datum/record/base, datum/record/other, field_name)
	if(other[field_name])
		base[field_name] = other[field_name]


