/obj/item/weapon/picket_sign
	name = "black picket sign"
	desc = "It's blank."
	icon_state = "picket_sign"
	item_state = "picket_sign"
	force = 5
	w_class = 4.0
	attack_verb = list("bashed", "smacked")

	var/label = ""
	var/spam_flag

/obj/item/weapon/picket_sign/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/weapon/pen) || istype(W, /obj/item/toy/crayon))
		var/txt = stripped_input(user, "What would you like to write on the sign?", "Sign Label", null , 30)
		if(txt)
			label = txt
			src.name = "[label] sign"
			desc =	"It reads: [label]"
		else
			label = ""
			src.name = "blank picket sign"
			desc = "It's blank."
	..()

/obj/item/weapon/picket_sign/attack_self(mob/living/carbon/human/user)
	if(spam_flag + 40 < world.timeofday)
		if(label)
			user.visible_message("<span class='warning'>[user] waves the \"[label]\" sign around.</span>")
		else
			user.visible_message("<span class='warning'>[user] waves a blank sign around.</span>")

		spam_flag = world.timeofday

		return 1
