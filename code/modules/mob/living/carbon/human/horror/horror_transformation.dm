/mob/living/carbon/human/proc/Horrorize()
	if (monkeyizing)
		return
	for(var/obj/item/W in src)
		usr.u_equip(W)
	monkeyizing = 1
	canmove = 0
	icon = null
	invisibility = 101


	var/atom/movable/overlay/animation = new /atom/movable/overlay( loc )
	animation.icon_state = "blank"
	animation.icon = 'mob.dmi'
	animation.master = src
	flick("h2monkey", animation)
	sleep(48)
	//animation = null
	var/mob/living/carbon/human/horror/O = new /mob/living/carbon/human/horror( loc )
	del(animation)

	O.real_name = real_name
	O.name = name
	O.dna = dna
	updateappearance(O,O.dna.uni_identity)
	O.loc = loc
	O.viruses = viruses
	viruses = list()
	for(var/datum/disease/D in O.viruses)
		D.affected_mob = O
	O.universal_speak = 1 //hacky fix until someone can figure out how to make them only understand humans

	if (client)
		client.mob = O
	if(mind)
		mind.transfer_to(O)

	O << "<B>You are now an otherworld horror.</B>"
	spawn(0)//To prevent the proc from returning null.
		del(src)
	return