//The sanguine sigil is used to call forth the colossus in its lair. You need ten seconds to invoke it.
/obj/structure/colossus_rune
	name = "sanguine sigil"
	desc = "A sickening glyph drawn amongst the ashes in fresh blood."
	icon = 'icons/effects/224x224.dmi'
	icon_state = "huge_rune"
	anchored = TRUE
	density = TRUE
	opacity = 0
	pixel_x = -96
	pixel_y = -96
	bound_x = -96
	bound_y = -96
	burn_state = LAVA_PROOF
	luminosity = 5
	layer = OBJ_LAYER - 0.01
	color = rgb(150, 0, 0)
	var/being_invoked = FALSE

/obj/structure/colossus_rune/New()
	new/obj/item/device/gps/internal/colossus_rune(src)
	poi_list += src
	..()

/obj/structure/colossus_rune/Destroy()
	poi_list -= src
	..()

/obj/structure/colossus_rune/attack_hand(mob/living/user)
	if(!ishuman(user))
		user << "<span class='warning'>You can't read the markings on [src]!</span>"
		return
	if(!user.can_speak_vocal())
		user << "<span class='warning'>You can't speak the markings on [src]!</span>"
		return
	if(being_invoked)
		return
	being_invoked = TRUE
	user.audible_message("<span class='warning'>You begin slowly fumbling over the markings of [src]...</span>", "<span class='userdanger'>You begin reciting the markings of [src]...</span>")
	for(var/i in 1 to 4)
		if(!do_after(user, 25, target = user) || !user.can_speak_vocal())
			being_invoked = FALSE
			return
		var/words = "Ayy lmao"
		switch(i)
			if(1)
				words = "H rtllnm xnt, fnn-zq... fzqczxd... ftzqchzm ne sghr Mdbqnonkhr..."
			if(2)
				words = "Cdedmcdq ne... ne... sgd odnokd?"
			if(3)
				words = "H gzud bnld sn cdex... cdehmd... CDEHKD xntq bqdzs bhsx..."
			if(4)
				words = "Rn bnld enqsg zmc H rgzkk rbqx... rlhkd... rsqhjd xnt cnvm, vgdko!"
		user.say(words)
	visible_message("<span class='cult'><font size=5><b>\"Brave words for someone so idiotic.\"</font></b></span>\n<span class='warning'><b>[src] begins to glow and shrink!</b></span>")
	animate(src, color = rgb(255, 0, 0), transform = matrix() - matrix(), time = 50)
	sleep(50)
	visible_message("<span class='userdanger'>[src] shifts into something horrible!</span>")
	new/mob/living/simple_animal/hostile/megafauna/colossus(get_turf(src))
	playsound(src, 'sound/effects/supermatter.ogg', 50, 0)
	playsound(src, 'sound/effects/tendril_destroyed.ogg', 100, 0)
	qdel(src)
	return 1

/obj/item/device/gps/internal/colossus_rune
	icon_state = null
	gpstag = "Distorted Signal"
	desc = "\"Chd. Chd. Chd. Chd. Chd.\""
	invisibility = 100
