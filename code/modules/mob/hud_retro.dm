/obj/hud/retro

	New(var/type = 0)
		instantiate(type)
		//..()
		return


	other_update()

		if(!mymob) return
		if(show_otherinventory)
			if(mymob:shoes) mymob:shoes:screen_loc = ui_shoes
			if(mymob:gloves) mymob:gloves:screen_loc = ui_gloves
			if(mymob:ears) mymob:ears:screen_loc = ui_ears
			if(mymob:s_store) mymob:s_store:screen_loc = ui_sstore1
			if(mymob:glasses) mymob:glasses:screen_loc = ui_glasses
		else
			if(ishuman(mymob))
				if(mymob:shoes) mymob:shoes:screen_loc = null
				if(mymob:gloves) mymob:gloves:screen_loc = null
				if(mymob:ears) mymob:ears:screen_loc = null
				if(mymob:s_store) mymob:s_store:screen_loc = null
				if(mymob:glasses) mymob:glasses:screen_loc = null



	proc/instantiate(var/type = 0)

		mymob = loc
		if(!istype(mymob, /mob)) return 0
		if(ishuman(mymob))
			human_hud(mymob.UI) // Pass the player the UI style chosen in preferences

		else if(ismonkey(mymob))
			monkey_hud(mymob.UI)

		else if(isbrain(mymob))
			brain_hud(mymob.UI)

		else if(islarva(mymob))
			larva_hud()

		else if(isalien(mymob))
			alien_hud()

		else if(isAI(mymob))
			ai_hud()

		else if(isrobot(mymob))
			robot_hud()

		else if(isobserver(mymob))
			ghost_hud()

		return