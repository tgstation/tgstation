/obj/effect/manifest
	name = "manifest"
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "x"
	unacidable = 1//Just to be sure.

/obj/effect/manifest/New()

	src.invisibility = 101
	return

/obj/effect/manifest/proc/manifest()
	var/dat = "<B>Crew Manifest</B>:<BR>"
	for(var/mob/living/carbon/human/M in mob_list)
		dat += text("    <B>[]</B> -  []<BR>", M.name, M.get_assignment())
	var/obj/item/weapon/paper/P = new /obj/item/weapon/paper( src.loc )
	P.info = dat
	P.name = "paper- 'Crew Manifest'"
	//SN src = null
	qdel(src)
	return