///Makes sure that crayons have their crayon_color in their initial name.

/datum/unit_test/crayon_naming/Run()
	for(var/obj/item/toy/crayon/this_crayon as anything in typesof(/obj/item/toy/crayon))
		if(is_type(this_crayon, /obj/item/toy/crayon/spraycan))
			continue
		if(!findtext("[this_crayon]","[this_crayon.crayon_color]"))
			Fail("[this_crayon.type] does not have its crayon_color ([crayon_color]) in its initial name ([this_crayon]).")
