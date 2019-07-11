/*!
This is a net gun, it looks like an inducer, and acts like an inducer, until you use disarm intent on somebody, then it basically works the same as the ninja net.
*/
/obj/item/inducer/netgun
	name = "inducer"
	desc = "A tool for inductively charging internal power cells."
	icon = 'icons/obj/tools.dmi'
	icon_state = "inducer-engi"
	item_state = "inducer-engi"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'

/obj/item/inducer/netgun/attack(mob/M, mob/user)
	
	if(user.a_intent == INTENT_DISARM)
		for(var/turf/T in getline(get_turf(user), get_turf(M)))
			if(T.density)//Don't want them shooting nets through walls. It's kind of cheesy.
				to_chat(user, "<span class='warning'>You may not use an energy net through solid obstacles!</span>")
				return
		M.Beam(M,"n_beam",time=15)
		var/obj/structure/energy_net/E = new /obj/structure/energy_net(M.drop_location())
		E.affecting = M
		E.master = user
		user.visible_message("<span class='danger'>[user] caught [M] with an energy net!</span>","<span class='notice'>You caught [M] with an energy net!</span>")
		E.buckle_mob(M, TRUE) //No moving for you!
		//The person can still try and attack the net when inside.
		START_PROCESSING(SSobj, E)
	else
		..()
	
	
