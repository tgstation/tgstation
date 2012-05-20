/mob/living/carbon/human/proc/Tajaraize()
	if (monkeyizing)
		return
	monkeyizing = 1
	canmove = 0
	icon = null
	invisibility = 101
	overlays = list()

	var/atom/movable/overlay/animation = new /atom/movable/overlay( loc )
	animation.icon_state = "blank"
	animation.icon = 'mob.dmi'
	animation.master = src
	flick("h2monkey", animation)
	sleep(18)
	//animation = null
	var/mob/living/carbon/human/tajaran/O = new /mob/living/carbon/human/tajaran( loc )
	del(animation)
	del(O.organs)
	O.organs = organs
	for(var/name in O.organs) //Ensuring organ trasnfer
		var/datum/organ/external/organ = O.organs[name]
		organ.owner = O
		for(var/obj/item/weapon/implant/implant in organ.implant)
			implant.imp_in = O
	for(var/obj/hud/H in contents) //Lets not get a duplicate hud
		del(H)
	for(var/named in vars) //Making them keep their crap.
		if(istype(vars[named], /obj/item))
			O.vars[named] = vars[named]
		else if (named == "contents")
			O.vars[named] = vars[named]

	O.real_name = real_name
	O.name = name
	O.dna = dna
	updateappearance(O,O.dna.uni_identity)
	O.loc = loc
	O.viruses = viruses
	viruses = list()
	for(var/datum/disease/D in O.viruses)
		D.affected_mob = O
	O.flavor_text = flavor_text
	O.universal_speak = 1 //hacky fix until someone can figure out how to make them only understand humans

	if (client)
		client.mob = O
	if(mind)
		mind.transfer_to(O)
	O.update_body()
	O.update_face()
	spawn(1)
		O.update_clothing()
	O << "<B>You are now a Tajara.</B>"
	spawn(0)//To prevent the proc from returning null.
		del(src)
	return

/client/proc/make_tajaran(mob/living/carbon/human/H as mob)
	set category = "Fun"
	set name = "Make Tajaran"
	set desc = "Make (mob) into a tajaran."

	if (!holder)
		src << "Only administrators may use this command."
		return

	if(istype(H))
		H:Tajaraize()