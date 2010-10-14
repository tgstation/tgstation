/obj/rune/proc/tomesummon()
	if(istype(src,/obj/rune))
		usr.say("N'ath reth sh'yro eth d'raggathnor!")
	else
		usr.whisper("N'ath reth sh'yro eth d'raggathnor!")
	for (var/mob/V in viewers(src))
		V.show_message("\red There's a flash of red light. The rune disappears, and in its place a book lies", 3, "\red You hear a pop and smell ozone.", 2)
	if(istype(src,/obj/rune))
		new /obj/item/weapon/tome(src.loc)
	else
		new /obj/item/weapon/tome(usr.loc)
	del(src)
	return