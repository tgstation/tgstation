/datum/component/storage/concrete/tilebound
	var/base_tile

/datum/component/storage/concrete/tilebound/real_location()
	return base_tile

/datum/component/storage/concrete/tilebound/do_quick_empty(atom/_target)
	if(!_target)
		_target = real_location()
	return ..(_target)
