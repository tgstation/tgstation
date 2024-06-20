/datum/log_category
	/// If non-admin debuggers (+DEBUG without +ADMIN) can see logs from this category or not.
	/// When set to null, it will assume the value of the parent category (which will default to FALSE if not set).
	var/debugger_visible = null

/datum/log_category/debug
	debugger_visible = TRUE

/datum/log_category/debug_sql
	debugger_visible = FALSE

/datum/log_category/debug_href
	debugger_visible = FALSE

/datum/log_category/debug_runtime
	debugger_visible = TRUE

/// Recursively checks to see if a log category or any of its parent categories is marked as "debugger_visible" or not.
/// Caches the result.
/proc/is_category_debug_visible(datum/log_category/category)
	var/static/list/cached_visibility
	if(!cached_visibility)
		cached_visibility = list(/datum/log_category = FALSE)
	var/datum/log_category/category_path = ispath(category) ? category : (istext(category) ? logger.log_categories[category]?.type : category?.type)
	if(!category)
		return FALSE
	if(!isnull(cached_visibility[category_path]))
		. = cached_visibility[category_path]
	else if(!isnull(category_path::debugger_visible))
		. = cached_visibility[category_path] = category_path::debugger_visible
	else if(!isnull(category_path::master_category) && category_path::master_category != category_path) // safety check to prevent infinite recursion, prolly not needed but better safe than sorry
		. = cached_visibility[category_path] = is_category_debug_visible(category_path::master_category)
	else
		. = cached_visibility[category_path] = FALSE

/proc/get_category_logfile(datum/log_category/category)
	var/static/list/cached_filenames
	if(!cached_filenames)
		cached_filenames = list()
	if(!category)
		return FALSE
	var/datum/log_category/category_path = ispath(category) ? category : (istext(category) ? logger.log_categories[category].type : category.type)
	if(!isnull(cached_filenames[category_path]))
		. = cached_filenames[category_path]
	else if(!isnull(category_path::master_category))
		var/datum/log_category/master_category = category_path::master_category
		. = cached_filenames[master_category] = cached_filenames[category_path] = master_category::category
	else
		. = cached_filenames[category_path] = category_path::category
