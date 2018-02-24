
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
	layer = BELOW_MOB_LAYER
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	sight = SEE_SELF
	call_life = TRUE

	var/following_index = 0
	var/list/virus_instances
	var/last_move_tick = 0
	var/const/move_delay = 5

/mob/camera/virus/Initialize(mapload)
	virus_instances = list()
	.= ..()

/mob/camera/virus/Life()
	..()
	follow_tick()

/mob/camera/virus/Destroy()
	for(var/V in virus_instances)
		var/datum/disease/advance/sentient_virus/S = V
		qdel(S)
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
	if(following_index && (world.time > (last_move_tick + move_delay)) )
		set_following(following_index % virus_instances.len + 1)
		last_move_tick = world.time

/mob/camera/virus/mind_initialize()
	. = ..()
	var/datum/antagonist/virus/A = mind.has_antag_datum(/datum/antagonist/virus)
	if(!A)
		mind.add_antag_datum(/datum/antagonist/virus)

/mob/camera/virus/get_language_holder()
	return ..()

/mob/camera/virus/proc/infect_patient_zero()
	var/list/possible_hosts = list()
	var/datum/disease/advance/sentient_virus/V = new /datum/disease/advance/sentient_virus(src)
	for(var/mob/living/carbon/human/H in GLOB.carbon_list)
		if(H.CanContractDisease(V))
			possible_hosts += H
	if(!possible_hosts.len)
		to_chat(src, "Cannot infect host")
		return
	var/mob/living/carbon/human/H = pick(possible_hosts)
	H.ForceContractDisease(V, FALSE)

/mob/camera/virus/proc/force_infect(mob/living/L)
	var/datum/disease/advance/sentient_virus/V = new /datum/disease/advance/sentient_virus(null, null, src)
	L.ForceContractDisease(V, FALSE)

/mob/camera/virus/proc/add_infection(datum/disease/advance/sentient_virus/V)
	virus_instances += V
	if(!following_index)
		set_following(1)

/mob/camera/virus/proc/remove_infection(datum/disease/advance/sentient_virus/V)
	virus_instances -= V
	if(virus_instances.len)
		set_following(virus_instances.len)
	else
		to_chat(src, "<span class='userdanger'>The last of your infection has disappeared.</span>")
		set_following()
		qdel(src)

/mob/camera/virus/proc/set_following(index = 0)
	following_index = index
	follow_tick()

/mob/camera/virus/proc/follow_tick()
	if(following_index)
		var/datum/disease/advance/sentient_virus/V = virus_instances[following_index]
		var/mob/living/following_host = V.affected_mob
		var/turf/host_turf = get_turf(following_host)
		if(host_turf)
			forceMove(host_turf)
