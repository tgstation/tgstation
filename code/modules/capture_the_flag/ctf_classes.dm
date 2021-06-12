/datum/outfit/ctf
	name = "CTF Rifleman"
	ears = /obj/item/radio/headset
	uniform = /obj/item/clothing/under/syndicate
	suit = /obj/item/clothing/suit/space/hardsuit/shielded/ctf
	toggle_helmet = FALSE // see the whites of their eyes
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	id = /obj/item/card/id/away
	belt = /obj/item/gun/ballistic/automatic/pistol/deagle/ctf
	l_pocket = /obj/item/ammo_box/magazine/recharge/ctf
	r_pocket = /obj/item/ammo_box/magazine/recharge/ctf
	r_hand = /obj/item/gun/ballistic/automatic/laser/ctf

	///Description to be shown in the class selection menu
	var/class_description = "General purpose combat class. Armed with a laser rifle and backup pistol."

/datum/outfit/ctf/post_equip(mob/living/carbon/human/H, visualsOnly=FALSE)
	if(visualsOnly)
		return
	var/list/no_drops = list()
	var/obj/item/card/id/W = H.wear_id
	no_drops += W
	W.registered_name = H.real_name
	W.update_label()
	W.update_icon()

	no_drops += H.get_item_by_slot(ITEM_SLOT_OCLOTHING)
	no_drops += H.get_item_by_slot(ITEM_SLOT_GLOVES)
	no_drops += H.get_item_by_slot(ITEM_SLOT_FEET)
	no_drops += H.get_item_by_slot(ITEM_SLOT_ICLOTHING)
	no_drops += H.get_item_by_slot(ITEM_SLOT_EARS)
	for(var/i in no_drops)
		var/obj/item/I = i
		ADD_TRAIT(I, TRAIT_NODROP, CAPTURE_THE_FLAG_TRAIT)

/datum/outfit/ctf/instagib
	name = "CTF Instagib"
	r_hand = /obj/item/gun/energy/laser/instakill
	shoes = /obj/item/clothing/shoes/jackboots/fast

/datum/outfit/ctf/red
	suit = /obj/item/clothing/suit/space/hardsuit/shielded/ctf/red
	r_hand = /obj/item/gun/ballistic/automatic/laser/ctf/red
	l_pocket = /obj/item/ammo_box/magazine/recharge/ctf/red
	r_pocket = /obj/item/ammo_box/magazine/recharge/ctf/red
	id = /obj/item/card/id/red //it's red

/datum/outfit/ctf/red/instagib
	r_hand = /obj/item/gun/energy/laser/instakill/red
	shoes = /obj/item/clothing/shoes/jackboots/fast

/datum/outfit/ctf/blue
	suit = /obj/item/clothing/suit/space/hardsuit/shielded/ctf/blue
	r_hand = /obj/item/gun/ballistic/automatic/laser/ctf/blue
	l_pocket = /obj/item/ammo_box/magazine/recharge/ctf/blue
	r_pocket = /obj/item/ammo_box/magazine/recharge/ctf/blue
	id = /obj/item/card/id/blue //it's blue

/datum/outfit/ctf/blue/instagib
	r_hand = /obj/item/gun/energy/laser/instakill/blue
	shoes = /obj/item/clothing/shoes/jackboots/fast

/datum/outfit/ctf/green
	suit = /obj/item/clothing/suit/space/hardsuit/shielded/ctf/green
	r_hand = /obj/item/gun/ballistic/automatic/laser/ctf/green
	l_pocket = /obj/item/ammo_box/magazine/recharge/ctf/green
	r_pocket = /obj/item/ammo_box/magazine/recharge/ctf/green
	id = /obj/item/card/id/green //it's green

/datum/outfit/ctf/green/instagib
	r_hand = /obj/item/gun/energy/laser/instakill/green
	shoes = /obj/item/clothing/shoes/jackboots/fast

/datum/outfit/ctf/yellow
	suit = /obj/item/clothing/suit/space/hardsuit/shielded/ctf/yellow
	r_hand = /obj/item/gun/ballistic/automatic/laser/ctf/yellow
	l_pocket = /obj/item/ammo_box/magazine/recharge/ctf/yellow
	r_pocket = /obj/item/ammo_box/magazine/recharge/ctf/yellow
	id = /obj/item/card/id/yellow //it's yellow

/datum/outfit/ctf/yellow/instagib
	r_hand = /obj/item/gun/energy/laser/instakill/yellow
	shoes = /obj/item/clothing/shoes/jackboots/fast

/datum/outfit/ctf/red/post_equip(mob/living/carbon/human/H)
	..()
	var/obj/item/radio/R = H.ears
	R.set_frequency(FREQ_CTF_RED)
	R.freqlock = TRUE
	R.independent = TRUE
	H.dna.species.stunmod = 0

/datum/outfit/ctf/blue/post_equip(mob/living/carbon/human/H)
	..()
	var/obj/item/radio/R = H.ears
	R.set_frequency(FREQ_CTF_BLUE)
	R.freqlock = TRUE
	R.independent = TRUE
	H.dna.species.stunmod = 0

/datum/outfit/ctf/green/post_equip(mob/living/carbon/human/H)
	..()
	var/obj/item/radio/R = H.ears
	R.set_frequency(FREQ_CTF_GREEN)
	R.freqlock = TRUE
	R.independent = TRUE
	H.dna.species.stunmod = 0

/datum/outfit/ctf/yellow/post_equip(mob/living/carbon/human/H)
	..()
	var/obj/item/radio/R = H.ears
	R.set_frequency(FREQ_CTF_YELLOW)
	R.freqlock = TRUE
	R.independent = TRUE
	H.dna.species.stunmod = 0
