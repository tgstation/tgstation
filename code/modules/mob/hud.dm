/obj/hud
	name = "hud"
	unacidable = 1
	var
		mob/mymob = null
		list/adding = null
		list/other = null
		list/intents = null
		list/mov_int = null
		list/mon_blo = null
		list/m_ints = null
		obj/screen/druggy = null
		vimpaired = null
		obj/screen/alien_view = null
		obj/screen/g_dither = null
		obj/screen/blurry = null
		list/darkMask = null
		show_otherinventory = 1
		obj/screen/action_intent
		obj/screen/move_intent

		h_type = /obj/screen		//this is like...the most pointless thing ever. Use a god damn define!

	New(var/type = 0, var/style = "slim")
		mymob = loc
		if(!ismob(mymob)) return
		if(style == "slim" || !ishuman(mymob))//Currently only humans can use the retro, other races only need a bit more work and for the type var to trans properly
			mymob.hud_used = new /obj/hud/slim(type)
			return
		if(style == "retro")
			mymob.hud_used = new /obj/hud/retro(type)
			return
		return

	proc/other_update()
		return

