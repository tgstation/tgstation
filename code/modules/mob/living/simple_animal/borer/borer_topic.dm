
/mob/living/simple_animal/borer/Topic(href, href_list, hsrc)
	if(href_list["borer_use_chem"])
		locate(href_list["src"])
		if(!istype(src, /mob/living/simple_animal/borer))
			return

		var/topic_chem = href_list["borer_use_chem"]
		var/datum/borer_chem/C

		for(var/datum in typesof(/datum/borer_chem))
			var/datum/borer_chem/test = new datum()
			if(test.chemname == topic_chem)
				C = test
				break

		if(!istype(C, /datum/borer_chem))
			return

		if(!C || !victim || controlling || !src || stat)
			return

		if(!istype(C, /datum/borer_chem))
			return

		if(chemicals < C.chemuse)
			src << "<span class='boldnotice'>You need [C.chemuse] chemicals stored to use this chemical!</span>"
			return

		src << "<span class='userdanger'>You squirt a measure of [C.chemname] from your reservoirs into [victim]'s bloodstream.</span>"
		victim.reagents.add_reagent(C.chemname, C.quantity)
		chemicals -= C.chemuse
		log_game("[src]/([src.ckey]) has injected [C.chemname] into their host [victim]/([victim.ckey])")

		src << output(chemicals, "ViewBorer\ref[src]Chems.browser:update_chemicals")

	..()