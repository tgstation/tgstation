/obj/item/clothing/under/chameleon
//starts off as black
	name = "black jumpsuit"
	icon_state = "black"
	item_state = "bl_suit"
	color = "black"
	desc = "It's a plain jumpsuit. It seems to have a small dial on the wrist."
	origin_tech = "syndicate=3"
	var/list/clothing_choices = list()

	New()
		..()
		for(var/U in typesof(/obj/item/clothing/under/color)-(/obj/item/clothing/under/color))
			var/obj/item/clothing/under/V = new U
			src.clothing_choices += V

		for(var/U in typesof(/obj/item/clothing/under/rank)-(/obj/item/clothing/under/rank))
			var/obj/item/clothing/under/V = new U
			src.clothing_choices += V
		return


	attackby(obj/item/clothing/under/U as obj, mob/user as mob)
		..()
		if(istype(U, /obj/item/clothing/under/chameleon))
			user << "\red Nothing happens."
			return
		if(istype(U, /obj/item/clothing/under))
			if(src.clothing_choices.Find(U))
				user << "\red Pattern is already recognised by the suit."
				return
			src.clothing_choices += U
			user << "\red Pattern absorbed by the suit."


	emp_act(severity)
		name = "psychedelic"
		desc = "Groovy!"
		icon_state = "psyche"
		color = "psyche"
		spawn(200)
			name = "Black Jumpsuit"
			icon_state = "bl_suit"
			color = "black"
			desc = null
		..()


	verb/change()
		set name = "Change Color"
		set category = "Object"
		set src in usr

		if(icon_state == "psyche")
			usr << "\red Your suit is malfunctioning"
			return

		var/obj/item/clothing/under/A
		A = input("Select Colour to change it to", "BOOYEA", A) in clothing_choices
		if(!A)
			return

		desc = null
		permeability_coefficient = 0.90

		desc = A.desc
		name = A.name
		icon_state = A.icon_state
		item_state = A.item_state
		color = A.color
		usr.update_inv_w_uniform()	//so our overlays update.



/obj/item/clothing/under/chameleon/all/New()
	..()
	var/blocked = list(/obj/item/clothing/under/chameleon, /obj/item/clothing/under/chameleon/all)
	//to prevent an infinite loop
	for(var/U in typesof(/obj/item/clothing/under)-blocked)
		var/obj/item/clothing/under/V = new U
		src.clothing_choices += V
