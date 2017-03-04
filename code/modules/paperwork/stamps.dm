/obj/item/weapon/stamp
	name = "\improper GRANTED rubber stamp"
	desc = "A rubber stamp for stamping important documents."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "stamp-ok"
	item_state = "stamp"
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	materials = list(MAT_METAL=60)
	item_color = "cargo"
	pressure_resistance = 2
	attack_verb = list("stamped")

/obj/item/weapon/stamp/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] stamps 'VOID' on [user.p_their()] forehead, then promptly falls over, dead.</span>")
	return (OXYLOSS)

/obj/item/weapon/stamp/qm
	name = "quartermaster's rubber stamp"
	icon_state = "stamp-qm"
	item_color = "qm"

/obj/item/weapon/stamp/law
	name = "law office's rubber stamp"
	icon_state = "stamp-law"
	item_color = "cargo"

/obj/item/weapon/stamp/captain
	name = "captain's rubber stamp"
	icon_state = "stamp-cap"
	item_color = "captain"

/obj/item/weapon/stamp/hop
	name = "head of personnel's rubber stamp"
	icon_state = "stamp-hop"
	item_color = "hop"

/obj/item/weapon/stamp/hos
	name = "head of security's rubber stamp"
	icon_state = "stamp-hos"
	item_color = "hosred"

/obj/item/weapon/stamp/ce
	name = "chief engineer's rubber stamp"
	icon_state = "stamp-ce"
	item_color = "chief"

/obj/item/weapon/stamp/rd
	name = "research director's rubber stamp"
	icon_state = "stamp-rd"
	item_color = "director"

/obj/item/weapon/stamp/cmo
	name = "chief medical officer's rubber stamp"
	icon_state = "stamp-cmo"
	item_color = "cmo"

/obj/item/weapon/stamp/denied
	name = "\improper DENIED rubber stamp"
	icon_state = "stamp-deny"
	item_color = "redcoat"

/obj/item/weapon/stamp/clown
	name = "clown's rubber stamp"
	icon_state = "stamp-clown"
	item_color = "clown"

/obj/item/weapon/stamp/attack_paw(mob/user)
	return attack_hand(user)

// Syndicate stamp to forge documents.

/obj/item/weapon/stamp/chameleon
	actions_types = list(/datum/action/item_action/toggle)

	var/list/stamp_types
	var/list/stamp_names

/obj/item/weapon/stamp/chameleon/New()
	stamp_types = typesof(/obj/item/weapon/stamp) - src.type // Get all stamp types except our own

	stamp_names = list()
	// Generate them into a list
	for(var/i in stamp_types)
		var/obj/item/weapon/stamp/stamp_type = i
		stamp_names += initial(stamp_type.name)

	stamp_names = sortList(stamp_names)

/obj/item/weapon/stamp/chameleon/emp_act(severity)
	change_to(pick(stamp_types))

/obj/item/weapon/stamp/chameleon/proc/change_to(obj/item/weapon/stamp/stamp_type)
	name = initial(stamp_type.name)
	icon_state = initial(stamp_type.icon_state)
	item_color = initial(stamp_type.item_color)

/obj/item/weapon/stamp/chameleon/attack_self(mob/user)
	var/input_stamp = input(user, "Choose a stamp to disguise as.",
		"Choose a stamp.") as null|anything in stamp_names

	if(user && (src in user.contents) && input_stamp)
		var/obj/item/weapon/stamp/stamp_type
		for(var/i in stamp_types)
			stamp_type = i
			if(initial(stamp_type.name) == input_stamp)
				break
		change_to(stamp_type)
