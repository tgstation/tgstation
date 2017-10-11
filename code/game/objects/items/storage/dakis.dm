//////////////////////////////////
 //dakimakuras
 //////////////////////////////////

/obj/item/storage/daki
	name = "dakimakura"
	desc = "A large pillow depicting a girl in a compromising position. Featuring as many dimensions as you."
	icon = 'icons/obj/daki.dmi'
	icon_state = "daki_base"
	lefthand_file = "icons/mob/inhands/misc/daki_lefthand.dmi"
	righthand_file = "icons/mob/inhands/misc/daki_righthand.dmi"
	slot_flags = SLOT_BACK
	storage_slots = 3
	w_class = WEIGHT_CLASS_NORMAL
	var/cooldowntime = 20
	var/static/list/dakimakura_options = list("Operative","Fruit","CMO","Clown", "Mime", "Nar'Sie", "Ian", "Catgirl") //Kurisu is the ideal girl." - Me, Logos. //how could someone make something so good then say some retarded shit like this

/obj/item/storage/daki/attack_self(mob/living/user)
	var/body_choice
	var/custom_name

	if(icon_state == "daki_base")
		body_choice = input("Pick a body.") in dakimakura_options
		if(!user.is_holding(src))
			to_chat(user,"<span class='userdanger'>Where did she go?!</span>")
			return FALSE
		icon_state = "daki_[body_choice]"
		custom_name = stripped_input(user, "What's her name?")
		if(!user.is_holding(src))
			to_chat(user,"<span class='userdanger'>Where did she go?!</span>")
			return FALSE
		if(length(custom_name) > MAX_NAME_LEN)
			to_chat(user,"<span class='danger'>Name is too long!</span>")
			return FALSE
		if(custom_name)
			name = "\proper [custom_name]"
			desc = "A large pillow depicting [custom_name] in a compromising position. Featuring as many dimensions as you."
	else
		switch(user.a_intent)
			if(INTENT_HELP)
				user.visible_message("<span class='notice'>[user] hugs [src].</span>" / "<span class='notice'>You hug [src].</span>")
				playsound(src, "rustle", 50, 1, -5)
			if(INTENT_DISARM)
				user.visible_message("<span class='notice'>[user] kisses [src].</span>" / "<span class='notice'>You kiss [src].</span>")
				playsound(src, "rustle", 50, 1, -5)
			if(INTENT_GRAB)
				user.visible_message("<span class='warning'>[user] holds [src]!</span>" / "<span class='danger'>You hold [src]!</span>")
				playsound(src, 'sound/items/bikehorn.ogg', 50, 1)
			if(INTENT_HARM)
				user.visible_message("<span class='danger'>[user] punches [src]!</span>" / "<span class='danger'>You punch [src]!</span>")
				playsound(src, 'sound/effects/shieldbash.ogg', 50, 1)
		user.changeNext_move(CLICK_CD_MELEE)
