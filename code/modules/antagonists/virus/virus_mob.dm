
/mob/camera/virus
	name = "Sentient Virus"
	real_name = "Sentient Virus"
	desc = ""
	icon = 'icons/mob/blob.dmi'
	icon_state = "marker"
	mouse_opacity = MOUSE_OPACITY_ICON
	move_on_shuttle = 1
	see_in_dark = 8
	invisibility = INVISIBILITY_OBSERVER
	layer = FLY_LAYER
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	sight = SEE_SELF

	var/mob/living/following_host
	var/list/virus_instances

/mob/camera/virus/Initialize(mapload)
	virus_instances = list()
	.= ..()

/mob/camera/virus/Life()
	..()
	if(!following_host && virus_instances.len)
		var/datum/disease/sentient_virus/V = virus_instances[1]
		following_host = V.affected_mob
	var/turf/host_turf = get_turf(following_host)
	if(host_turf)
		forceMove(host_turf)

/mob/camera/virus/Destroy()

	return ..()

/mob/camera/virus/Login()
	..()

/mob/camera/virus/say(message)

/*
/mob/camera/virus/emote(act,m_type=1,message = null)
	return
*/
/mob/camera/virus/Stat()
	..()
	//if(statpanel("Status"))


/mob/camera/virus/Move(NewLoc, Dir = 0)
	return

/mob/camera/virus/mind_initialize()
	. = ..()
	var/datum/antagonist/virus/A = mind.has_antag_datum(/datum/antagonist/virus)
	if(!A)
		mind.add_antag_datum(/datum/antagonist/virus)

/mob/camera/virus/get_language_holder()
	return ..()

/mob/camera/virus/proc/force_infect(mob/living/L)
	var/datum/disease/sentient_virus/V = new /datum/disease/sentient_virus()
	L.ForceContractDisease(V)
	qdel(V)

/mob/camera/virus/proc/add_infection(datum/disease/sentient_virus/V)
	virus_instances += V

/mob/camera/virus/proc/remove_infection(datum/disease/sentient_virus/V)
	virus_instances -= V
	if(virus_instances.len)
		var/datum/disease/sentient_virus/newV = virus_instances[1]
		set_following(newV.affected_mob)
	else
		to_chat(src, "<span class='userdanger'>The last of your infection has disappeared.</span>")
		qdel(src)

/mob/camera/virus/proc/set_following(mob/living/L)
	following_host = L
	var/turf/host_turf = get_turf(following_host)
	if(host_turf)
		forceMove(host_turf)
