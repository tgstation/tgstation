/datum/round_event_control/wizard/greentext //Gotta have it!
	name = "Greentext"
	weight = 4
	typepath = /datum/round_event/wizard/greentext/
	max_occurrences = 1
	earliest_start = 0

/datum/round_event/wizard/greentext/start()

	var/list/holder_canadates = player_list.Copy()
	for(var/mob/M in holder_canadates)
		if(!ishuman(M))
			holder_canadates -= M
	if(!holder_canadates) //Very unlikely, but just in case
		return 0

	var/mob/living/carbon/human/H = pick(holder_canadates)
	new /obj/item/weapon/greentext(H.loc)
	H << "<font color='green'>The mythical greentext appear at your feet! Pick it up if you dare...</font>"


/obj/item/weapon/greentext/
	name = "greentext"
	desc = "No one knows what this massive tome does, but it feels <i><font color='green'>desirable</font></i> all the same..."
	w_class = 4.0
	icon = 'icons/obj/wizard.dmi'
	icon_state = "greentext"
	var/mob/living/last_holder
	var/mob/living/new_holder
	var/list/color_altered_mobs = list()

/obj/item/weapon/greentext/equipped(mob/living/user as mob)
	user << "<font color='green'>So long as you leave this place with greentext in hand you know will be happy...</font>"
	if(user.mind && user.mind.objectives.len > 0)
		user << "<span class='warning'>... so long as you still perform your other objectives that is!</span>"
	new_holder = user
	if(!last_holder)
		last_holder = user
	if(!(user in color_altered_mobs))
		color_altered_mobs += user
	user.color = "#00FF00"
	SSobj.processing |= src
	..()

/obj/item/weapon/greentext/dropped(mob/living/user as mob)
	if(user in color_altered_mobs)
		user << "<span class='warning'>A sudden wave of failure washes over you...</span>"
		user.color = "#FF0000" //ya blew it
	last_holder 	= null
	new_holder 		= null
	SSobj.processing.Remove(src)
	..()

/obj/item/weapon/greentext/process()
	if(new_holder && new_holder.z == ZLEVEL_CENTCOM)//you're winner!
		new_holder << "<font color='green'>At last it feels like victory is assured!</font>"
		if(!(new_holder in ticker.mode.traitors))
			ticker.mode.traitors += new_holder.mind
		new_holder.mind.special_role = "winner"
		var/datum/objective/O = new /datum/objective("Succeed")
		O.completed = 1 //YES!
		O.owner = new_holder.mind
		new_holder.mind.objectives += O
		new_holder.attack_log += "\[[time_stamp()]\] <font color='green'>Won with greentext!!!</font>"
		color_altered_mobs -= new_holder
		qdel(src)

	if(last_holder && last_holder != new_holder) //Somehow it was swiped without ever getting dropped
		last_holder << "<span class='warning'>A sudden wave of failure washes over you...</span>"
		last_holder.color = "#FF0000"
		last_holder = new_holder //long live the king

/obj/item/weapon/greentext/Destroy()
	for(var/mob/M in mob_list)
		var/message = "<span class='warning'>A dark temptation has passed from this world"
		if(M in color_altered_mobs)
			message += " and you're finally able to forgive yourself"
			M.color = initial(M.color)
		message += "...</span>"
		M << message
	return ..()