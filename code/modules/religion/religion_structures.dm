/obj/structure/altar_of_gods
	name = "\improper Altar of the Gods"
	desc = "An altar which allows the head of the church to choose a sect of religious teachings as well as provide sacrifices to earn favor."
	icon = 'icons/obj/hand_of_god_structures.dmi'
	icon_state = "convertaltar"
	density = TRUE
	anchored = TRUE
	var/datum/religion_sect/sect_to_altar // easy access!

/obj/structure/altar_of_gods/Initialize(mapload)
	. = ..()
	if(GLOB.religious_sect)
		sect_to_altar = GLOB.religious_sect

/obj/structure/altar_of_gods/attackby(obj/item/C, mob/user, params)
	. = ..()
	if(sect_to_altar?.can_sacrifice(C,user))
		sect_to_altar.on_sacrifice(C,user)
		return
	if(!istype(C, /obj/item/storage/book/bible))
		return //everything below is assumed you're bibling it up
	if(GLOB.religious_sect)
		to_chat(user, "<span class='notice'>There is already a selected sect for your religion.")
		return
	if(user.mind.holy_role != HOLY_ROLE_HIGHPRIEST)
		to_chat(user, "<span class='warning'>You are not the high priest, and therefore cannot select a religious sect.")
		return

	var/list/available_options = generate_available_sects(user)
	if(!available_options)
		return

	var/sect_select = input(user,"Select a sect (You CANNOT revert this decision!)","Select a Sect",null) in available_options
	if(!sect_select || !user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		to_chat(user,"<span class ='warning'>You cannot select a sect at this time.</span>")
		return
	var/type_selected = available_options[sect_select]
	GLOB.religious_sect = new type_selected()
	for(var/i in GLOB.player_list)
		if(!isliving(i))
			continue
		var/mob/living/am_i_holy_living = i
		if(!am_i_holy_living.mind?.holy_role)
			continue
		GLOB.religious_sect.on_conversion(am_i_holy_living)
	sect_to_altar = GLOB.religious_sect



/obj/structure/altar_of_gods/proc/generate_available_sects(mob/user) //eventually want to add sects you get from unlocking certain achievements
	. = list()
	for(var/i in subtypesof(/datum/religion_sect))
		var/datum/religion_sect/not_a_real_instance_rs = i
		if(initial(not_a_real_instance_rs.starter))
			. += list(initial(not_a_real_instance_rs.name) = i)
