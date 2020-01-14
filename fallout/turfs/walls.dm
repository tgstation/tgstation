/turf/closed/wall/r_wall/f13vault
	name = "vault wall"
	desc = "A huge chunk of metal used to separate rooms."
	icon = 'fallout/icons/turf/walls/f13vault_reinforced_wall.dmi'

/turf/closed/wall/r_wall/f13vaultrusted
	name = "rusty vault wall"
	desc = "A rusty chunk of metal used to separate rooms."
	icon = 'fallout/icons/turf/walls/f13vault_rusted_wall.dmi'

/turf/closed/wall/r_wall/f13composite
	name = "composite wall"
	desc = "A huge chunk of metal used to separate rooms."
	icon = 'fallout/icons/turf/walls/f13composite.dmi'
	icon_state = "ruins0"

/turf/closed/wall/r_wall/f13superstore
	name = "store wall"
	desc = "A huge chunk of metal used to separate rooms."
	icon = 'fallout/icons/turf/walls/f13superstore.dmi'

/turf/closed/wall/f13wood
	name = "wood wall"
	desc = "A rotting hunk of wood."
	icon = 'fallout/icons/turf/walls/f13wood_wall.dmi'

/turf/closed/indestructible/f13/matrix //The Chosen One from Arroyo!
	name = "matrix"
	desc = "<font color='#6eaa2c'>You suddenly realize the truth - there is no spoon.<br>Digital simulation ends here.</font> If you click and drag your character and release it on this wall, it will allow you to removed from the simulation."
	icon = 'fallout/icons/turf/walls/f13misc.dmi'
	icon_state = "matrix"

/turf/closed/indestructible/f13/matrix/MouseDrop_T(atom/dropping, mob/user)
	. = ..()
	if(!isliving(user) || user.incapacitated())
		return //No ghosts or incapacitated folk allowed to do this.
	if(!ishuman(dropping))
		return //Only humans have job slots to be freed.
	var/mob/living/carbon/human/departing_mob = dropping
	if(departing_mob.stat == DEAD)
		to_chat(user, "<span class='warning'>This one kicked the bucket. Won't be traveling anywhere.</span>")
		return
	if(departing_mob != user && departing_mob.client)
		to_chat(user, "<span class='warning'>This one retains their free will. It's their choice if they want to depart or not.</span>")
		return
	if(alert("Are you sure you want to [departing_mob == user ? "depart the area for good (you" : "send this person away (they"] will be removed from the current round, the job slot freed)?", "Departing the Mojave", "Confirm", "Cancel") != "Confirm")
		return
	if(user.incapacitated() || QDELETED(departing_mob) || departing_mob.stat == DEAD || (departing_mob != user && departing_mob.client) || get_dist(src, dropping) > 2 || get_dist(src, user) > 2)
		return //Things have changed since the alert happened.
	if(departing_mob.logout_time && departing_mob.logout_time + 5 MINUTES > world.time)
		to_chat(user, "<span class='warning'>This mind has only recently departed. Better give it some more time before taking such a drastic measure.</span>")
		return
	var/dat = "[key_name(user)] has despawned [departing_mob == user ? "themselves" : departing_mob], job [departing_mob.job], at [AREACOORD(src)]. Contents despawned along:"
	if(!length(departing_mob.contents))
		dat += " none."
	else
		var/atom/movable/content = departing_mob.contents[1]
		dat += " [content.name]"
		for(var/i in 2 to length(departing_mob.contents))
			content = departing_mob.contents[i]
			dat += ", [content.name]"
		dat += "."
	message_admins(dat)
	log_admin(dat)
	departing_mob.visible_message("<span class='notice'>[departing_mob == user ? "Out of their own volition, " : "Ushered by [user], "][departing_mob] crosses the border and departs the Mojave.</span>")
	qdel(departing_mob)
