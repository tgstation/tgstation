/datum/component/storage/concrete/secret_satchel/can_be_inserted(I,msg,user)
	if(SSpersistence.spawned_objects[I])
		to_chat(user, "<span class='warning'>[I] is unstable after its journey through space and time, it wouldn't survive another trip.</span>")
		return FALSE
	return ..()
