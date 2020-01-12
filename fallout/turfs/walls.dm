//Fallout 13 general destructible walls directory

/turf/closed/wall/f13
	name = "glitch"
	desc = "<font color='#6eaa2c'>You suddenly realize the truth - there is no spoon.<br>Something has caused a glitch in the simulation.</font>"
	icon = 'fallout/icons/turfs/walls.dmi'
	icon_state = "matrix"
	baseturfs = /turf/open/floor/plating/f13

/turf/closed/wall/f13/ReplaceWithLattice()
	ChangeTurf(baseturfs)

/turf/closed/wall/f13/ruins
	name = "ruins"
	desc = "All what has left from the good old days."
	icon = 'fallout/icons/turfs/walls/ruins.dmi'
	icon_state = "ruins0"
	icon_type_smooth = "ruins"
	hardness = 70
	explosion_block = 2
	smooth = SMOOTH_OLD
	//	disasemblable = 0
	girder_type = 0
	baseturfs = /turf/open/floor/plating/f13
	sheet_type = null
	canSmoothWith = list(/turf/closed/wall/f13/ruins, /turf/closed/wall)

/turf/closed/wall/f13/wood
	name = "wooden wall"
	desc = "A traditional wooden wall."
	icon = 'fallout/icons/turfs/walls/wood.dmi'
	icon_state = "wood0"
	icon_type_smooth = "wood"
	hardness = 60
	smooth = SMOOTH_OLD
	baseturfs = /turf/open/floor/wood
	sheet_type = /obj/item/stack/sheet/mineral/wood
	sheet_amount = 2
	girder_type = 0
	canSmoothWith = list(/turf/closed/wall/f13/wood, /turf/closed/wall)

/turf/closed/wall/f13/wood/house
	name = "house wall"
	desc = "A weathered pre-War house wall."
	icon = 'fallout/icons/turfs/walls/house.dmi'
	icon_state = "house0"
	icon_type_smooth = "house"
	hardness = 50
	var/broken = 0
	canSmoothWith = list(/turf/closed/wall/f13/wood/house, /turf/closed/wall/f13/wood/house/broken, /turf/closed/wall)

/turf/closed/wall/f13/wood/house/broken
	broken = 1
	icon_state = "house0-broken"

/turf/closed/wall/f13/wood/house/relative()
	icon_state = "[icon_type_smooth][junction][broken ? "-broken" : ""]"

/turf/closed/wall/f13/wood/house/update_icon()
	if(broken)
		set_opacity(0)
	..()

/turf/closed/wall/f13/wood/interior
	name = "interior wall"
	desc = "Interesting, what kind of material they have used - these wallpapers still look good after all the centuries..."
	icon = 'fallout/icons/turfs/walls/interior.dmi'
	icon_state = "interior0"
	icon_type_smooth = "interior"
	hardness = 10
	smooth = SMOOTH_OLD
	canSmoothWith = list(/turf/closed/wall/f13/wood/interior, /turf/closed/wall)

/turf/closed/wall/f13/store
	name = "store wall"
	desc = "A pre-War store wall made of solid concrete."
	icon = 'fallout/icons/turfs/walls/store.dmi'
	icon_state = "store0"
	icon_type_smooth = "store"
	hardness = 80
	smooth = SMOOTH_OLD
	//	disasemblable = 0
	girder_type = 0
	sheet_type = null
	canSmoothWith = list(/turf/closed/wall/f13/store, /turf/closed/wall)

/turf/closed/wall/f13/supermart
	name = "supermart wall"
	desc = "A pre-War supermart wall made of reinforced concrete."
	icon = 'fallout/icons/turfs/walls/superstore.dmi'
	icon_state = "supermart0"
	icon_type_smooth = "supermart"
	hardness = 90
	explosion_block = 2
	smooth = SMOOTH_OLD
	//	disasemblable = 0
	girder_type = 0
	sheet_type = null
	canSmoothWith = list(/turf/closed/wall/f13/supermart, /turf/closed/wall)

/turf/closed/wall/f13/tunnel
	name = "utility tunnel wall"
	desc = "A sturdy metal wall with various pipes and wiring set inside a special groove."
	icon = 'fallout/icons/turfs/walls/tunnel.dmi'
	icon_state = "tunnel0"
	icon_type_smooth = "tunnel"
	hardness = 100
	smooth = SMOOTH_OLD
	//	disasemblable = 0
	girder_type = 0
	sheet_type = null
	canSmoothWith = list(/turf/closed/wall/f13/tunnel, /turf/closed/wall)

/turf/closed/wall/f13/vault
	name = "vault wall"
	desc = "A sturdy and cold metal wall."
	icon = 'fallout/icons/turfs/walls/vault.dmi'
	icon_state = "vault0"
	icon_type_smooth = "vault"
	hardness = 130
	explosion_block = 5
	smooth = SMOOTH_OLD
	canSmoothWith = list(/turf/closed/wall/f13/vault, /turf/closed/wall/r_wall/f13/vault, /turf/closed/wall)

/turf/closed/wall/r_wall/f13
	name = "glitch"
	desc = "<font color='#6eaa2c'>You suddenly realize the truth - there is no spoon.<br>Something has caused a glitch in the simulation.</font>"
	icon = 'fallout/icons/turfs/walls.dmi'
	icon_state = "matrix"

/turf/closed/wall/r_wall/f13/vault
	name = "vault reinforced wall"
	desc = "A wall built to withstand an atomic explosion."
	icon = 'fallout/icons/turfs/walls/vault_reinforced.dmi'
	icon_state = "vaultrwall0"
	icon_type_smooth = "vaultrwall"
	hardness = 230
	explosion_block = 5
	smooth = SMOOTH_OLD
	canSmoothWith = list(/turf/closed/wall/f13/vault, /turf/closed/wall/r_wall/f13/vault, /turf/closed/wall)

//Fallout 13 indestructible walls

/turf/closed/indestructible/f13
	name = "glitch"
	desc = "<font color='#6eaa2c'>You suddenly realize the truth - there is no spoon.<br>Something has caused a glitch in the simulation.</font>"
	icon = 'fallout/icons/walls.dmi'
	icon_state = "matrix"

/turf/closed/indestructible/f13/subway
	name = "tunnel wall"
	desc = "This wall is made of reinforced concrete.<br>Pre-War engineers knew how to build reliable things."
	icon = 'fallout/icons/turfs/walls/subway.dmi'
	icon_state = "subwaytop"

/turf/closed/indestructible/f13/matrix //The Chosen One from Arroyo!
	name = "matrix"
	desc = "<font color='#6eaa2c'>You suddenly realize the truth - there is no spoon.<br>Digital simulation ends here.</font>"
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

//Splashscreen
/*
/turf/closed/indestructible/f13/splashscreen
	var/tickerPeriod = 300 //in deciseconds
	var/go/fullDark

turf/closed/indestructible/f13/splashscreen/New()
	.=..()
	name = "Fallout 13"
	desc = "The wasteland is calling!"
	icon = 'icons/fallout/misc/lobby.dmi'
	icon_state = "title[rand(1,13)]"
	layer = 60
	plane = 1
	src.fullDark = new/go{
		icon = 'icons/fallout/misc/lobby.dmi' //Replace with actual icon
		icon_state = "transition" //Replace with actual darkness state
		layer = 61;
		alpha = 0;
		}(src)
	src.fullDark.plane = 1
	spawn() src.ticker()
	return

turf/closed/indestructible/f13/splashscreen/proc/ticker()
	while(src && istype(src,/turf/closed/indestructible/f13/splashscreen))
		src.swapImage()
		sleep(src.tickerPeriod)
	to_chat(world, "Badmins spawn shit and the title screen was deleted.<br>You know... I'm out of here!")
	return

//Change the time to determine how short/long the fading animation is.
//Change the easing to determine what interpolation it uses to change the value on a curve: good ones to try are CUBIC, BOUNCE, and ELASTIC as well as CIRCULAR. BOUNCE and ELASTIC both "bounce" or "flicker" a little bit at the end instead of just finishing straight at black.

/turf/closed/indestructible/f13/splashscreen/proc/swapImage()
	animate(src.fullDark,alpha=255,time=10,easing=CUBIC_EASING)
	sleep(12) //buffer of about 1/5 of the time of the animation, since they are not synchronized: the sleep happens on the server, but the animation is played for each client using directX. It's good to leave a buffer, but most of the time the directX will be much faster than the server anyway so you probably wont have any problems.
	src.icon_state = "title[rand(1,13)]"
	animate(src.fullDark,alpha=0,time=10,easing=CUBIC_EASING)
	return
*/
