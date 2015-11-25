/mob/dead/observer/Login()
	..()

	if(src.check_rights(R_ADMIN|R_FUN))
		to_chat(src, "<span class='warning'>You are now an admin ghost.  Think of yourself as an AI that doesn't show up anywhere and cannot speak.  You can access any console or machine by standing next to it and clicking on it.  Abuse of this privilege may result in hilarity or removal of your flags, so caution is recommended.</span>")
	if(istype(canclone) && canclone.mind == mind)
		if(can_reenter_corpse && istype(canclone.loc, /obj/machinery/dna_scannernew))
			for(dir in list(NORTH, EAST, SOUTH, WEST))
				if(locate(/obj/machinery/computer/cloning, get_step(canclone.loc, dir)))
					src << 'sound/effects/adminhelp.ogg'
					to_chat(src, "<span class='interface'><b><font size = 3>Your corpse has been placed into a cloning scanner. Return to your body if you want to be resurrected/cloned!</b> \
						(Verbs -> Ghost -> Re-enter corpse, or <a href='?src=\ref[src];reentercorpse=1'>click here!</a>)</font></span>")
	canclone = null

/mob/dead/observer/MouseDrop(atom/over)
	if(!usr || !over)
		return

	if (isobserver(usr) && usr.client.holder && isliving(over))
		if (usr.client.holder.cmd_ghost_drag(src,over))
			return

	return ..()
