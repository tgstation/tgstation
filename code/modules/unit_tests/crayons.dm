/// Makes sure that crayons have their crayon_color in their initial name (to differentiate them in the crafting menu).
/datum/unit_test/crayon_naming

/datum/unit_test/crayon_naming/Run()
	for(var/obj/item/toy/crayon/crayon_path as anything in typesof(/obj/item/toy/crayon))
		if(is_path_in_list(crayon_path, list(/obj/item/toy/crayon/spraycan, /obj/item/toy/crayon)))
			continue
		var/obj/item/toy/crayon/real_crayon = new crayon_path
		if(!findtext(initial(real_crayon.name),real_crayon.crayon_color))
			TEST_FAIL("[real_crayon] does not have its crayon_color ([real_crayon.crayon_color]) in its initial name ([initial(real_crayon.name)]).")
		qdel(real_crayon)
