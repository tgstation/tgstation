/obj/effect/manifest
	name = "manifest"
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "x"

/obj/effect/manifest/New()
	src.invisibility = INVISIBILITY_ABSTRACT

/obj/effect/manifest/proc/manifest()
	var/dat = "<B>Crew Manifest</B>:<BR>"
	for(var/mob/living/carbon/human/M in GLOB.mob_list)
		dat += text("    <B>[]</B> -  []<BR>", M.name, M.get_assignment())
	var/obj/item/weapon/paper/P = new /obj/item/weapon/paper( src.loc )
	P.info = dat
	P.name = "paper- 'Crew Manifest'"
	//SN src = null
	qdel(src)
