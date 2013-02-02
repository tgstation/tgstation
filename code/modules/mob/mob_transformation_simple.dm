
//This proc is the most basic of the procs. All it does is make a new mob on the same tile and transfer over a few variables.
//Returns the new mob
//Note that this proc does NOT do MMI related stuff!
/mob/proc/change_mob_type(var/new_type = null, var/turf/location = null, var/new_name = null as text, var/delete_old_mob = 0 as num)

	if(istype(src,/mob/new_player))
		usr << "\red cannot convert players who have not entered yet."
		return

	if(!new_type)
		new_type = input("Mob type path:", "Mob type") as text|null

	if(istext(new_type))
		new_type = text2path(new_type)

	if( !ispath(new_type) )
		usr << "Invalid type path (new_type = [new_type]) in change_mob_type(). Contact a coder."
		return

	if( new_type == /mob/new_player )
		usr << "\red cannot convert into a new_player mob type."
		return

	var/mob/M
	if(isturf(location))
		M = new new_type( location )
	else
		M = new new_type( src.loc )

	if(!M || !ismob(M))
		usr << "Type path is not a mob (new_type = [new_type]) in change_mob_type(). Contact a coder."
		del(M)
		return

	if( istext(new_name) )
		M.name = new_name
		M.real_name = new_name
	else
		M.name = src.name
		M.real_name = src.real_name

	if(src.dna)
		M.dna = src.dna

	if(mind)
		mind.transfer_to(M)
	else
		M.key = key

	if(delete_old_mob)
		spawn(1)
			del(src)
	return M
