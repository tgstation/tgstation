/atom/proc/effective_contents(list/typecache = null)
	var/static/list/default_typecache
	if(!typecache)
		default_typecache ||= typecacheof(list(/obj/effect, /atom/movable/screen))
		typecache = default_typecache
	return typecache_filter_list_reverse(src.contents, typecache)
