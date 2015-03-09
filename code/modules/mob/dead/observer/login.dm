/mob/dead/observer/Login()
	..()

	if(src.check_rights(R_ADMIN|R_FUN))
		src << "<span class='warning'>You are now an admin ghost.  Think of yourself as an AI that doesn't show up anywhere and cannot speak.  You can access any console or machine by standing next to it and clicking on it.  Abuse of this privilege may result in hilarity or removal of your flags, so caution is recommended.</span>"
	if(istype(canclone) && canclone.mind == mind)
		if(istype(canclone.loc, /obj/machinery/dna_scannernew))
			for(dir in list(NORTH, EAST, SOUTH, WEST))
				if(locate(/obj/machinery/computer/cloning, get_step(canclone.loc, dir)))
					src << 'sound/effects/adminhelp.ogg'
					src << "<b><font color = #330033><font size = 3>Your corpse has been placed into a cloning scanner. Return to your body if you want to be resurrected/cloned!</b> (Verbs -> Ghost -> Re-enter corpse)</font color>"
	canclone = null