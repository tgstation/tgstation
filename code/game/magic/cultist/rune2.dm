/obj/rune/proc/tomesummon()
	usr.say("N'ath reth sh'yro eth d'raggathnor!")
	for (var/mob/V in viewers(src))
		V.show_message("\red There's a flash of red light. The [src] disappears, and in its place a book lies", 3, "\red You hear a pop and smell ozone.", 2)
	new /obj/item/weapon/tome(src.loc)
	del(src)
	return