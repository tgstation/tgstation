/// Returns TRUE if this is a mod control module, a mod core, or a piece of mod clothing. FALSE otherwise.
/obj/item/proc/is_mod_shell_component()
	return FALSE

/obj/item/mod/is_mod_shell_component()
	return TRUE

/obj/item/clothing/shoes/mod/is_mod_shell_component()
	return TRUE

/obj/item/clothing/gloves/mod/is_mod_shell_component()
	return TRUE

/obj/item/clothing/suit/mod/is_mod_shell_component()
	return TRUE

/obj/item/clothing/head/mod/is_mod_shell_component()
	return TRUE
