
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
		body_choice = input("Pick a body.") in list(

		"Callie",
		"Casca",
		"Chaika",
		"Elisabeth",
		"Foxy Granpa",
		"Haruko",
		"Holo",
		"Hotwheels",
		"Ian",
		"Jolyne",
		"Kurisu",
		"Marie",
		"Mugi",
		"Nar'Sie",
		"Patchouli",
		"Plutia",
		"Rei",
		"Reisen",
		"Naga",
		"Squid",
		"Squiggly",
		"Sue Bowchief",
		"Tomoko",
		"Toriel",
		"Umaru",
		"Yaranaika",
		"Yoko")

		icon_state = "daki_[body_choice]"	//Wew
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