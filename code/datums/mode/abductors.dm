/datum/role/abductor //Generic, not for direct use
	name = "abductor"
	antag_flag = ROLE_ABDUCTOR
	threat = 2 //wip

/datum/role/abductor/equip()
	if(!ishuman(owner.current))
		return
	var/mob/living/carbon/human/H = owner.current
	var/radio_freq = SYND_FREQ

	var/obj/item/device/radio/R = new /obj/item/device/radio/headset/syndicate/alt(H)
	R.set_frequency(radio_freq)
	H.equip_to_slot_or_del(R, slot_ears)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/combat(H), slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/color/grey(H), slot_w_uniform) //they're greys gettit
	H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack(H), slot_back)
	..()

/datum/role/abductor/enpower()
	if(!ishuman(owner.current))
		return
	var/mob/living/carbon/human/H = owner.current
	H.set_species(/datum/species/abductor)
	..()



/datum/role/abductor/scientist
	name = "abductor scientist"
	id = "abductorscientist"
	starting_location = /obj/effect/landmark/abductor/scientist_landmarks

/datum/role/abductor/scientist/equip()
	if(!ishuman(owner.current))
		return
	var/mob/living/carbon/human/H = owner.current

	var/obj/item/device/abductor/gizmo/G = new /obj/item/device/abductor/gizmo(H)
	if(console!=null)
		console.gizmo = G
		G.console = console
	H.equip_to_slot_or_del(G, slot_in_backpack)

	var/obj/item/weapon/implant/abductor/beamplant = new /obj/item/weapon/implant/abductor(H)
	beamplant.implant(H)
	..()



/datum/role/abductor/agent
	name = "abductor agent"
	id = "abductoragent"
	starting_location = /obj/effect/landmark/abductor/agent_landmarks

/datum/role/abductor/agent/equip()
	if(!ishuman(owner.current))
		return
	var/mob/living/carbon/human/H = owner.current

	var/obj/item/clothing/suit/armor/abductor/vest/V = new /obj/item/clothing/suit/armor/abductor/vest(H)
	if(console!=null)
		console.vest = V
		V.flags |= NODROP
	H.equip_to_slot_or_del(V, slot_wear_suit)
	H.equip_to_slot_or_del(new /obj/item/weapon/abductor_baton(H), slot_in_backpack)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/alien(H), slot_belt)
	H.equip_to_slot_or_del(new /obj/item/device/abductor/silencer(H), slot_in_backpack)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/abductor(H), slot_head)
	..()


/datum/group/abductorteam
	name	= "Abductor Team"
	id 		= "abductorteam"
	objectives	= list()	//In groups objectives are shared with all members, it's possible for someone to have both personal and group objectives.