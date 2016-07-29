/obj/item/device/hailer
	name = "hailer"
	desc = "Used by obese officers to save their breath for running."
	icon_state = "voice0"
	item_state = "flashbang"	//looks exactly like a flash (and nothing like a flashbang)
	origin_tech = "magnets=1;combat=1"
	w_class = W_CLASS_TINY
	flags = FPRINT
	siemens_coefficient = 1

	var/nextuse = 0
	var/cooldown = 2 SECONDS
	var/emagged = 0
	var/insults = 0//just in case

/obj/item/device/hailer/proc/say_your_thing()
	if(emagged)
		if(insults)
			return "FUCK YOUR CUNT YOU SHIT EATING COCKSUCKER MAN EAT A DONG FUCKING ASS RAMMING SHITFUCK. EAT PENISES IN YOUR FUCKFACE AND SHIT OUT ABORTIONS OF FUCK AND DO A SHIT IN YOUR ASS YOU COCK FUCK SHIT MONKEY FUCK ASS WANKER FROM THE DEPTHS OF SHIT."
		else
			return "*BZZZZcuntZZZZT*"
	else
		return "HALT! SECURITY!"

/obj/item/device/hailer/proc/do_your_sound(var/mob/user)
	if(emagged && insults)
		playsound(get_turf(src), 'sound/voice/binsult.ogg', 100, 1, vary = 0)
		insults--
	else
		playsound(get_turf(src), 'sound/voice/halt.ogg', 100, 1, vary = 0)
	if(user)
		var/list/bystanders = get_hearers_in_view(world.view, src)
		flick_overlay(image('icons/mob/talk.dmi', user, "hail", MOB_LAYER+1), clients_in_moblist(bystanders), 2 SECONDS)
	nextuse = world.time + cooldown

/obj/item/device/hailer/attack_self(mob/living/carbon/user as mob)
	if(world.time < nextuse)
		return
	if(emagged && !insults)
		to_chat(user, "<span class='warning'>[say_your_thing()]</span>")
		return

	var/message = say_your_thing()
	user.visible_message("<span class='warning'>[user]'s [name] [emagged ? "gurgles" : "rasps"], \"[message]\"</span>", \
						"<span class='warning'>Your [name] [emagged ? "gurgles" : "rasps"], \"[message]\"</span>", \
						"<span class='warning'>You hear the computerized voice of a security hailer: \"[message]\"</span>")
	do_your_sound(user)

/obj/item/device/hailer/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/card/emag) && !emagged)
		to_chat(user, "<span class='warning'>You overload \the [src]'s voice synthesizer.</span>")
		emagged = 1
		insults = rand(1, 3)//to prevent dickflooding
		return
	return

/obj/item/device/hailer/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(world.time < nextuse)
		return
	if(proximity_flag && !ismob(target)) //Don't do anything when being put in a backpack, on a table, or anything within one tile of us like opening an airlock. Exception is when used on people, I guess to rub it in someone's face
		return
	if(emagged && !insults)
		to_chat(user, "<span class='warning'>[say_your_thing()]</span>")
		return

	// ~ getting the suspects ~ //
	var/list/mob/living/suspects = list() //Think of it like aim assist for clicking on people with the hailer:
	if(ismob(target)) //If you clicked right on someone, good, let's hail at them
		suspects += target
	if(!suspects.len)
		for(var/mob/living/M in get_turf(target)) //Okay, maybe you misclicked and hit a chair or something, let's try finding them in the turf
			suspects += M
	if(!suspects.len)
		for(var/mob/living/M in orange(1, target)) //Okay jesus, maybe a 3x3 square
			suspects += M
	if(!suspects.len) //Oh okay you weren't even trying
		attack_self(user) //just do the normal hailer thing I guess
		return

	// ~ drawing the images ~ //
	var/list/bystanders = get_hearers_in_view(world.view, src)
	for(var/mob/living/M in suspects)
		flick_overlay(image('icons/mob/talk.dmi', M, "halt", MOB_LAYER+1), clients_in_moblist(bystanders), 2 SECONDS) //One image for each suspect

	// ~ visible message ~ //
	for(var/mob/living/M in suspects)
		M.show_message("<span class='userdanger'>[bicon(src)][say_your_thing()]</span>", MESSAGE_HEAR)
	var/who = suspects.len <= 3 ? english_list(suspects) : "everyone"
	user.visible_message("<span class='danger'>[user] hails for [who] to halt!</span>", \
						"<span class='warning'>You hail for [who] to halt!</span>", \
						"<span class='warning'>You hear the computerized voice of a security hailer: \"[say_your_thing()]\"</span>")

	// ~ sound and cooldown ~ //
	do_your_sound(user)
