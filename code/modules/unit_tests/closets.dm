/// Checks that the length of the initial contents of a closet doesn't exceed its storage capacity
/datum/unit_test/closets

/datum/unit_test/closets/Run()
	var/list/all_closets = subtypesof(/obj/structure/closet)
	//Supply pods. They are sent, crashed, opened and never closed again. They also cause exceptions in nullspace.
	all_closets -= typesof(/obj/structure/closet/supplypod)

	for(var/closet_type in all_closets)
		var/obj/structure/closet/closet = allocate(closet_type)
		var/contents_len = length(closet.contents)
		if(contents_len > closet.storage_capacity)
			Fail("Initial Contents of [closet.type] ([contents_len]) exceed its storage capacity ([closet.storage_capacity]).")
