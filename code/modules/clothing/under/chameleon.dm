/obj/item/clothing/under/chameleon
//starts off as black
	name = "black jumpsuit"
	icon_state = "black"
	item_state = "bl_suit"
	item_color = "black"
	desc = "It's a plain jumpsuit. It has a small dial on the wrist."
	action_button_name = "Change"
	origin_tech = "syndicate=3"
	sensor_mode = 0 //Hey who's this guy on the Syndicate Shuttle??
	random_sensor = 0
	var/list/clothing_choices = list()
	var/malfunctioning = 0
	burn_state = -1 //Won't burn in fires

/obj/item/clothing/under/chameleon/New()
	..()
	for(var/U in typesof(/obj/item/clothing/under/color)-(/obj/item/clothing/under/color))
		var/obj/item/clothing/under/V = new U
		src.clothing_choices += V

	for(var/U in typesof(/obj/item/clothing/under/rank)-(/obj/item/clothing/under/rank))
		var/obj/item/clothing/under/V = new U
		src.clothing_choices += V
	return


/obj/item/clothing/under/chameleon/attackby(obj/item/clothing/under/U, mob/user, params)
	..()
	if(istype(U, /obj/item/clothing/under/chameleon))
		user << "\<span class='notice'>Nothing happens.</span>"
		return
	if(istype(U, /obj/item/clothing/under))
		if(src.clothing_choices.Find(U))
			user << "<span class='notice'>Pattern is already recognised by the suit.</span>"
			return
		src.clothing_choices += U
		user << "<span class='notice'>Pattern absorbed by the suit.</span>"


/obj/item/clothing/under/chameleon/emp_act(severity)
	name = "psychedelic"
	desc = "Groovy!"
	icon_state = "psyche"
	item_color = "psyche"
	malfunctioning = 1
	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_w_uniform()
		M << "<span class='danger'>Your jumpsuit malfunctions!</span>"
	spawn(200)
		name = "Black Jumpsuit"
		icon_state = "black"
		item_state = "bl_suit"
		item_color = "black"
		malfunctioning = 0
		if(ismob(loc))
			var/mob/M = loc
			M.update_inv_w_uniform()
			M << "<span class='notice'>Your jumpsuit is functioning normally again.</span>"
	..()

/obj/item/clothing/under/chameleon/attack_self()
	set src in usr

	var/obj/item/clothing/under/A
	A = input("Select Colour to change it to", "BOOYEA", A) in clothing_choices
	if(!A)
		return

	if(usr.stat != CONSCIOUS)
		return

	if(malfunctioning)
		usr << "<span class='danger'>Your jumpsuit is malfunctioning!</span>"
		return

	desc = null
	permeability_coefficient = 0.90

	desc = A.desc
	name = A.name
	icon_state = A.icon_state
	item_state = A.item_state
	item_color = A.item_color
	suit_color = A.suit_color
	usr.update_inv_w_uniform()	//so our overlays update.



/obj/item/clothing/under/chameleon/all/New()
	..()
	var/blocked = list(/obj/item/clothing/under/chameleon, /obj/item/clothing/under/chameleon/all)	//to prevent an infinite loop
	for(var/U in typesof(/obj/item/clothing/under)-blocked)
		var/obj/item/clothing/under/V = new U
		src.clothing_choices += V
