/obj/item/picket_sign
	icon_state = "picket"
	name = "blank picket sign"
	desc = "It's blank"
	force = 5
	w_class = WEIGHT_CLASS_BULKY
	attack_verb = list("bashed","smacked")
	resistance_flags = FLAMMABLE

	var/label = ""
	var/last_wave = 0

/obj/item/picket_sign/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/pen) || istype(W, /obj/item/toy/crayon))
		var/txt = stripped_input(user, "What would you like to write on the sign?", "Sign Label", null , 30)
		if(txt)
			label = txt
			src.name = "[label] sign"
			desc =	"It reads: [label]"
	else
		return ..()

/obj/item/picket_sign/attack_self(mob/living/carbon/human/user)
	if( last_wave + 20 < world.time )
		last_wave = world.time
		if(label)
			user.visible_message("<span class='warning'>[user] waves around \the \"[label]\" sign.</span>")
		else
			user.visible_message("<span class='warning'>[user] waves around blank sign.</span>")
		user.changeNext_move(CLICK_CD_MELEE)

/datum/crafting_recipe/picket_sign
	name = "Picket Sign"
	result = /obj/item/picket_sign
	reqs = list(/obj/item/stack/rods = 1,
				/obj/item/stack/sheet/cardboard = 2)
	time = 80
	category = CAT_MISC