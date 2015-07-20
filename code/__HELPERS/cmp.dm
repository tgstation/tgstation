/proc/cmp_numeric_dsc(a,b)
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/cmp_numeric_dsc() called tick#: [world.time]")
	return b - a

/proc/cmp_numeric_asc(a,b)
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/cmp_numeric_asc() called tick#: [world.time]")
	return a - b

/proc/cmp_text_asc(a,b)
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/cmp_text_asc() called tick#: [world.time]")
	return sorttext(b,a)

/proc/cmp_text_dsc(a,b)
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/cmp_text_dsc() called tick#: [world.time]")
	return sorttext(a,b)

/proc/cmp_name_asc(atom/a, atom/b)
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/cmp_name_asc() called tick#: [world.time]")
	return sorttext(b.name, a.name)

/proc/cmp_name_dsc(atom/a, atom/b)
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/cmp_name_dsc() called tick#: [world.time]")
	return sorttext(a.name, b.name)

var/cmp_field = "name"
/proc/cmp_records_asc(datum/data/record/a, datum/data/record/b)
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/cmp_records_asc() called tick#: [world.time]")
	return sorttext((b ? b.fields[cmp_field] : ""), (a ? a.fields[cmp_field] : a))

/proc/cmp_records_dsc(datum/data/record/a, datum/data/record/b)
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/cmp_records_dsc() called tick#: [world.time]")
	return sorttext(a.fields[cmp_field], b.fields[cmp_field])

/proc/cmp_ckey_asc(client/a, client/b)
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/cmp_ckey_asc() called tick#: [world.time]")
	return sorttext(b.ckey, a.ckey)

/proc/cmp_ckey_dsc(client/a, client/b)
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/cmp_ckey_dsc() called tick#: [world.time]")
	return sorttext(a.ckey, b.ckey)