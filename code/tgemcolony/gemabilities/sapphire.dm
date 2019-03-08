/datum/action/innate/gem/findmob
	name = "Find Mob"
	desc = "Get the coordinates of any living creature within the same Z-level."
	icon_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "findmob"
	background_icon_state = "bg_spell"

/datum/action/innate/gem/findmob/Activate()
	var/list/onzlevel = list()
	for(var/mob/living/M in world)
		if(M.z == owner.z && M != owner && M.health > 0) //no detecting self
			onzlevel.Add(M)
	var/mob/living/target = input("Who do you want to find?") as null|anything in onzlevel
	if(target != null)
		var/direction = uppertext(dir2text(get_dir(owner, target)))
		to_chat(usr, "<span class='warning'>[target] is at [target.x],[target.y] ([direction]).</span>")
		to_chat(usr, "<span class='warning'>You are at [owner.x],[owner.y].</span>")