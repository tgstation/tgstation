
//////////////////////////////////
//dakimakuras
//////////////////////////////////

/obj/item/weapon/storage/daki
	name = "dakimakura"
	var/custom_name = null
	desc = "A large pillow depicting a girl in a compromising position. Featuring as many dimensions as you."
	icon = 'icons/obj/daki.dmi'
	icon_state = "daki_base"
	slot_flags = SLOT_BACK
	storage_slots = 3
	w_class = 4
	max_w_class = 3
	max_combined_w_class = 21

/obj/item/weapon/storage/daki/attack_self(mob/living/user)
	var/body_choice
	if(!custom_name)
		body_choice = input("Pick a body.") in list("Callie","Casca","Chaika","Elisabeth","Foxy Granpa","Haruko","Holo","Hotwheels","Ian","Jolyne","Kurisu","Marie","Mugi","Nar'Sie","Patchouli","Plutia","Rei","Reisen","Naga","Squid","Squiggly","Sue Bowchief","Tomoko","Toriel","Umaru","Yaranaika","Yoko")
		switch(body_choice)
			if("Callie")
				icon_state = "daki_callie"
			if("Casca")
				icon_state = "daki_casca"
			if("Chaika")
				icon_state = "daki_chaika"
			if("Elisabeth")
				icon_state = "daki_elisabeth"
			if("Foxy Granpa")
				icon_state = "daki_foxy"
			if("Haruko")
				icon_state = "daki_haruko"
			if("Holo")
				icon_state = "daki_holo"
			if("Hotwheels")
				icon_state = "daki_hot"
			if("Ian")
				icon_state = "daki_ian"
			if("Jolyne")
				icon_state = "daki_jolyne"
			if("Kurisu")
				icon_state = "daki_kurisu"
			if("Marie")
				icon_state = "daki_marie"
			if("Mugi")
				icon_state = "daki_mugi"
			if("Nar'Sie")
				icon_state = "daki_narnar"
			if("Patchouli")
				icon_state = "daki_patch"
			if("Plutia")
				icon_state = "daki_plutia"
			if("Rei")
				icon_state = "daki_rei"
			if("Reisen")
				icon_state = "daki_reisen"
			if("Naga")
				icon_state = "daki_snake"
			if("Squid")
				icon_state = "daki_squid"
			if("Squiggly")
				icon_state = "daki_squigly"
			if("Sue Bowchief")
				icon_state = "daki_sue"
			if("Tomoko")
				icon_state = "daki_tomoko"
			if("Toriel")
				icon_state = "daki_toriel"
			if("Umaru")
				icon_state = "daki_umaru"
			if("Yaranaika")
				icon_state = "daki_yaranaika"
			if("Yoko")
				icon_state = "daki_yoko"

		custom_name = input("What's her name?") as text
		name = custom_name + " " + name
		desc = "A large pillow depicting [custom_name] in a compromising position. Featuring as many dimensions as you."
	else
		if(user.a_intent == "help")
			user.visible_message("<span class='notice'>[user] hugs the [name].</span>")
			playsound(src.loc, "rustle", 50, 1, -5)
		if(user.a_intent == "disarm")
			user.visible_message("<span class='notice'>[user] kisses the [name].</span>")
			playsound(src.loc, "rustle", 50, 1, -5)
		if(user.a_intent == "grab")
			user.visible_message("<span class='warning'>[user] gropes the [name]!</span>")
			playsound(src.loc, 'sound/items/bikehorn.ogg', 50, 1)
		if(user.a_intent == "harm")
			user.visible_message("<span class='danger'>[user] violently humps the [name]!</span>")
			playsound(user.loc, 'sound/effects/shieldbash.ogg', 50, 1)

////////////////////////////