//////////////////////////////////
//dakimakuras
//////////////////////////////////

/obj/item/weapon/storage/daki
	name = "dakimakura" 
	desc = "A large pillow depicting a girl in a compromising position. Featuring as many dimensions as you."
	icon = 'icons/obj/daki.dmi'
	icon_state = "daki_base"
	slot_flags = SLOT_BACK
	storage_slots = 3
	w_class = 4
	max_w_class = 3
	max_combined_w_class = 21
	var/spam_flag = FALSE
	var/cooldowntime = 20
	var/static/list/dakimakura_options = list("Callie","Casca","Chaika","Elisabeth","Foxy Grandpa","Haruko","Holo","Ian","Jolyne","Kurisu","Marie","Mugi","Nar'Sie","Patchouli","Plutia","Rei","Reisen","Naga","Squid","Squigly","Tomoko","Toriel","Umaru","Yaranaika","Yoko") //Kurisu is the ideal girl." - Me, Logos.

/obj/item/weapon/storage/daki/attack_self(mob/living/user)
	var/body_choice
	var/custom_name
	
	if(icon_state == "daki_base")
		body_choice = input("Pick a body.") in dakimakura_options
		icon_state = "daki_[body_choice]"
		custom_name = stripped_input(user, "What's her name?")
		if(length(custom_name) > MAX_NAME_LEN)
			to_chat(user,"<span class='danger'>Name is too long!</span>")
			return FALSE
		if(custom_name)
			name = custom_name
			desc = "A large pillow depicting [custom_name] in a compromising position. Featuring as many dimensions as you."
	else
		if(!spam_flag)
			spam_flag = FALSE
			if("help")
				user.visible_message("<span class='notice'>[user] hugs the [name].</span>")
				playsound(src, "rustle", 50, 1, -5)
			if("disarm")
				user.visible_message("<span class='notice'>[user] kisses the [name].</span>")
				playsound(src, "rustle", 50, 1, -5)
			if("grab")
				user.visible_message("<span class='warning'>[user] holds the [name]!</span>")
				playsound(src, 'sound/items/bikehorn.ogg', 50, 1)
			if("harm")
				user.visible_message("<span class='danger'>[user] punches the [name]!</span>")
				playsound(src, 'sound/effects/shieldbash.ogg', 50, 1)
			spawn(cooldowntime)
				spam_flag = TRUE

////////////////////////////
