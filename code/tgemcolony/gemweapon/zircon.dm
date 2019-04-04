/datum/action/innate/gem/weapon/zircon
	name = "Summon Library"
	desc = "Knowing is half the battle."
	weapon_type = /obj/item/zirconlibrary

/obj/item/zirconlibrary
	name = "Library"
	desc = "In the hands of a Zircon, it can create and print books."
	icon = 'icons/obj/library.dmi'
	icon_state = "scanner"
	w_class = 2

/obj/item/zirconlibrary/interact(mob/user)
	if(!user.can_read(src))
		to_chat(user, "<span class='notice'>You can't read.</span>")
		return FALSE
	if(iscarbon(user))
		var/mob/living/carbon/H = user
		if(H.dna.species.id == "zircon" || H.dna.species.id == "pinkzircon")
			var/dat
			dat += "<br><h1>SELECT A BOOK TO PRINT</h1><br>"
			dat += "<br><h1>----------------------</h1><br>"
			for(var/i in 1 to GLOB.cachedbooks.len)
				var/datum/cachedbook/C = GLOB.cachedbooks[i]
				dat += "<<A href='?src=[REF(src)];targetid=[REF(C.id)]'>[C.author] - [C.title] - [C.id]</A></h1><br>"
			user << browse(dat, "window=pda;size=450x520;border=1;can_resize=1;can_minimize=0")

			//var/datum/browser/popup = new(user, "print book", name, 450, 520)
			//popup.set_content(dat)
			//popup.open()
		else
			to_chat(H, "<span class='notice'>This seems to be useless to you.</span>")
	else
		to_chat(user, "<span class='notice'>This seems to be useless to you.</span>")