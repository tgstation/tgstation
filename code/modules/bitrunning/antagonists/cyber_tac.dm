/datum/antagonist/bitrunning_glitch/cyber_tac
	name = ROLE_CYBER_TAC
	preview_outfit = /datum/outfit/cyber_police/tactical
	threat = 50
	show_in_antagpanel = TRUE

/datum/antagonist/bitrunning_glitch/cyber_tac/on_gain()
	. = ..()

	if(!ishuman(owner.current))
		stack_trace("humans only for this position")
		return

	convert_agent()

/datum/outfit/cyber_police/tactical
	name = ROLE_CYBER_TAC
	back = /obj/item/mod/control/pre_equipped/glitch
	l_hand = /obj/item/gun/ballistic/automatic/m90

	backpack_contents = list(
		/obj/item/ammo_box/magazine/m223,
		/obj/item/ammo_box/magazine/m223,
		/obj/item/ammo_box/magazine/m223,
	)

/datum/outfit/cyber_police/tactical/post_equip(mob/living/carbon/human/user, visualsOnly)
	. = ..()

	var/obj/item/implant/weapons_auth/auth = new(user)
	auth.implant(user)
