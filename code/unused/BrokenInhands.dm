/proc/getbrokeninhands()
	var/icon/IL = new('icons/mob/items_lefthand.dmi')
	var/list/Lstates = IL.IconStates()
	var/icon/IR = new('icons/mob/items_righthand.dmi')
	var/list/Rstates = IR.IconStates()


	var/text
	for(var/A in typesof(/obj/item))
		var/obj/item/O = new A( locate(1,1,1) )
		if(!O) continue
		var/icon/J = new(O.icon)
		var/list/istates = J.IconStates()
		if(!Lstates.Find(O.icon_state) && !Lstates.Find(O.item_state))
			if(O.icon_state)
				text += "[O.type] WANTS IN LEFT HAND CALLED\n\"[O.icon_state]\".\n"
		if(!Rstates.Find(O.icon_state) && !Rstates.Find(O.item_state))
			if(O.icon_state)
				text += "[O.type] WANTS IN RIGHT HAND CALLED\n\"[O.icon_state]\".\n"


		if(O.icon_state)
			if(!istates.Find(O.icon_state))
				text += "[O.type] MISSING NORMAL ICON CALLED\n\"[O.icon_state]\" IN \"[O.icon]\"\n"
		if(O.item_state)
			if(!istates.Find(O.item_state))
				text += "[O.type] MISSING NORMAL ICON CALLED\n\"[O.item_state]\" IN \"[O.icon]\"\n"
		text+="\n"
		del(O)
	if(text)
		var/F = file("broken_icons.txt")
		fdel(F)
		F << text
		world << "Completely successfully and written to [F]"


