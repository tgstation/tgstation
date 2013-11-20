//*****************
//**Cham Jumpsuit**
//*****************

/obj/item/clothing/under/chameleon
//starts off as black
	name = "black jumpsuit"
	icon_state = "black"
	item_state = "bl_suit"
	item_color = "black"
	desc = "It's a plain jumpsuit. It seems to have a small dial on the wrist."
	origin_tech = "syndicate=3"
	var/list/clothing_choices = list()

	New()
		..()
		var/blocked = list(/obj/item/clothing/under/chameleon, /obj/item/clothing/under/cloud,
			/obj/item/clothing/under/golem, /obj/item/clothing/under/gimmick)//Prevent infinite loops and bad jumpsuits.
		for(var/U in typesof(/obj/item/clothing/under)-blocked)
			var/obj/item/clothing/under/V = new U
			src.clothing_choices += V
		return

	emp_act(severity)
		name = "psychedelic"
		desc = "Groovy!"
		icon_state = "psyche"
		item_color = "psyche"

	verb/change()
		set name = "Change Jumpsuit Appearance"
		set category = "Object"
		set src in usr

		var/obj/item/clothing/suit/A
		A = input("Select jumpsuit to change it to", "Chameleon Jumpsuit")as null|anything in clothing_choices
		if(!A)
			return

		desc = null
		permeability_coefficient = 0.90

		desc = A.desc
		name = A.name
		icon_state = A.icon_state
		item_state = A.item_state
		item_color = A.item_color
		usr.update_inv_w_uniform()	//so our overlays update.

//*****************
//**Chameleon Hat**
//*****************

/obj/item/clothing/head/chameleon
	name = "grey cap"
	icon_state = "greysoft"
	item_state = "greysoft"
	item_color = "grey"
	desc = "It looks like a plain hat, but upon closer inspection, there's an advanced holographic array installed inside. It seems to have a small dial inside."
	origin_tech = "syndicate=3"
	var/list/clothing_choices = list()

	New()
		..()
		var/blocked = list(/obj/item/clothing/head/chameleon, /obj/item/clothing/head/helmet/space/space_ninja,
			/obj/item/clothing/head/space/golem, /obj/item/clothing/head/justice,)//Prevent infinite loops and bad hats.
		for(var/U in typesof(/obj/item/clothing/head)-blocked)
			var/obj/item/clothing/head/V = new U
			src.clothing_choices += V
		return

	emp_act(severity) //Because we don't have psych for all slots right now but still want a downside to EMP.  In this case your cover's blown.
		name = "grey cap"
		desc = "It's a baseball hat in a tasteful grey colour."
		icon_state = "greysoft"
		item_color = "grey"
		update_icon()

	verb/change()
		set name = "Change Hat/Helmet Appearance"
		set category = "Object"
		set src in usr

		var/obj/item/clothing/suit/A
		A = input("Select headwear to change it to", "Chameleon Hat")as null|anything in clothing_choices
		if(!A)
			return

		desc = null
		permeability_coefficient = 0.90

		desc = A.desc
		name = A.name
		icon_state = A.icon_state
		item_state = A.item_state
		item_color = A.item_color
		flags_inv = A.flags_inv
		usr.update_inv_head()	//so our overlays update.

//******************
//**Chameleon Suit**
//******************

/obj/item/clothing/suit/chameleon
	name = "armor"
	icon_state = "armor"
	item_state = "armor"
	desc = "It appears to be a vest of standard armor, except this is embedded with a hidden holographic cloaker, allowing it to change it's appearance, but offering no protection.. It seems to have a small dial inside."
	origin_tech = "syndicate=3"
	var/list/clothing_choices = list()

	New()
		..()
		var/blocked = list(/obj/item/clothing/suit/chameleon, /obj/item/clothing/suit/space/space_ninja,
			/obj/item/clothing/suit/golem, /obj/item/clothing/suit/suit, /obj/item/clothing/suit/cyborg_suit, /obj/item/clothing/suit/justice,
			/obj/item/clothing/suit/greatcoat)//Prevent infinite loops and bad suits.
		for(var/U in typesof(/obj/item/clothing/suit)-blocked)
			var/obj/item/clothing/suit/V = new U
			src.clothing_choices += V
		return

	emp_act(severity) //Because we don't have psych for all slots right now but still want a downside to EMP.  In this case your cover's blown.
		name = "armor"
		desc = "An armored vest that protects against some damage."
		icon_state = "armor"
		item_color = "armor"
		update_icon()

	verb/change()
		set name = "Change Exosuit Appearance"
		set category = "Object"
		set src in usr

		var/obj/item/clothing/suit/A
		A = input("Select footwear to change it to", "Chameleon Exosuit")as null|anything in clothing_choices
		if(!A)
			return

		desc = null
		permeability_coefficient = 0.90

		desc = A.desc
		name = A.name
		icon_state = A.icon_state
		item_state = A.item_state
		item_color = A.item_color
		flags_inv = A.flags_inv
		usr.update_inv_wear_suit()	//so our overlays update.

//*******************
//**Chameleon Shoes**
//*******************
/obj/item/clothing/shoes/chameleon
	name = "black shoes"
	icon_state = "black"
	item_state = "black"
	item_color = "black"
	desc = "They're comfy black shoes, with clever Syndicate cloaking technology built in. It seems to have a small dial on the back of each shoe."
	origin_tech = "syndicate=3"
	var/list/clothing_choices = list()

	New()
		..()
		var/blocked = list(/obj/item/clothing/shoes/chameleon, /obj/item/clothing/shoes/space_ninja,
			/obj/item/clothing/shoes/golem, /obj/item/clothing/shoes/syndigaloshes, /obj/item/clothing/shoes/cyborg)//prevent infinite loops and bad shoes.
		for(var/U in typesof(/obj/item/clothing/shoes)-blocked)
			var/obj/item/clothing/shoes/V = new U
			src.clothing_choices += V
		return

	emp_act(severity) //Because we don't have psych for all slots right now but still want a downside to EMP.  In this case your cover's blown.
		name = "black shoes"
		desc = "A pair of black shoes."
		icon_state = "black"
		item_state = "black"
		item_color = "black"
		update_icon()

	verb/change()
		set name = "Change Footwear Appearance"
		set category = "Object"
		set src in usr

		var/obj/item/clothing/shoes/A
		A = input("Select footwear to change it to", "Chameleon Shoes")as null|anything in clothing_choices
		if(!A)
			return

		desc = null
		permeability_coefficient = 0.90

		desc = A.desc
		name = A.name
		icon_state = A.icon_state
		item_state = A.item_state
		item_color = A.item_color
		usr.update_inv_shoes()	//so our overlays update.

//**********************
//**Chameleon Backpack**
//**********************
/obj/item/weapon/storage/backpack/chameleon
	name = "backpack"
	icon_state = "backpack"
	item_state = "backpack"
	desc = "A backpack outfitted with cloaking tech. It seems to have a small dial inside, kept away from the storage."
	origin_tech = "syndicate=3"
	var/list/clothing_choices = list()

	New()
		..()
		var/blocked = list(/obj/item/weapon/storage/backpack/chameleon, /obj/item/weapon/storage/backpack/satchel/withwallet,)
		for(var/U in typesof(/obj/item/weapon/storage/backpack)-blocked)//Prevent infinite loops and bad backpacks.
			var/obj/item/weapon/storage/backpack/V = new U
			src.clothing_choices += V
		return

	emp_act(severity) //Because we don't have psych for all slots right now but still want a downside to EMP.  In this case your cover's blown.
		name = "backpack"
		desc = "You wear this on your back and put items into it."
		icon_state = "backpack"
		item_state = "backpack"
		update_icon()

	verb/change()
		set name = "Change Backpack Appearance"
		set category = "Object"
		set src in usr

		var/obj/item/weapon/storage/backpack/A
		A = input("Select backpack to change it to", "Chameleon Backpack")as null|anything in clothing_choices
		if(!A)
			return

		desc = null
		permeability_coefficient = 0.90

		desc = A.desc
		name = A.name
		icon_state = A.icon_state
		item_state = A.item_state
		item_color = A.item_color
		usr.update_inv_back()	//so our overlays update.