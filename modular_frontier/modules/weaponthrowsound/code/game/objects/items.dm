/obj/item/after_throw()
	. = ..()
	if(throwforce)
		playsound(loc, 'sound/weapons/punchmiss.ogg', 50, TRUE, -1, SOUND_FALLOFF_EXPONENT)
