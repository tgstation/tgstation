GENERAL_PROTECT_DATUM(/mob/admin_module_holder)

/// Exists to hold admin verbs. Should never be directly created or accessed
/mob/admin_module_holder

/mob/admin_module_holder/proc/dynamic_map_generate()
	return

/mob/admin_module_holder/Read(F)
	del(src)

/mob/admin_module_holder/Write(F)
	return null
