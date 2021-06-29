// GENERIC CLASSES

/datum/outfit/ctf
	name = "CTF Rifleman (Solo)"
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
	///Radio frequency to assign players with this outfit
	var/team_radio_freq = FREQ_COMMON // they won't be able to use this on the centcom z-level, so ffa players cannot use radio

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

	var/obj/item/radio/R = H.ears
	R.set_frequency(team_radio_freq)
	R.freqlock = TRUE
	R.independent = TRUE
	H.dna.species.stunmod = 0

/datum/outfit/ctf/instagib
	name = "CTF Instagib (Solo)"
	r_hand = /obj/item/gun/energy/laser/instakill
	shoes = /obj/item/clothing/shoes/jackboots/fast

/datum/outfit/ctf/assault
	name = "CTF Assaulter (Solo)"
	suit = /obj/item/clothing/suit/space/hardsuit/shielded/ctf/light
	r_hand = /obj/item/gun/ballistic/shotgun/ctf
	gloves = /obj/item/clothing/gloves/tackler/rocket
	l_pocket = /obj/item/ammo_box/magazine/recharge/ctf/shotgun
	r_pocket = /obj/item/ammo_box/magazine/recharge/ctf/shotgun
	belt = null

/datum/outfit/ctf/marksman
	name = "CTF Marksman (Solo)"
	r_hand = /obj/item/gun/ballistic/automatic/laser/ctf/marksman
	l_pocket = /obj/item/ammo_box/magazine/recharge/ctf/marksman
	r_pocket = /obj/item/ammo_box/magazine/recharge/ctf/marksman
	belt = null

// RED TEAM CLASSES

/datum/outfit/ctf/red
	name = "CTF Rifleman (Red)"
	suit = /obj/item/clothing/suit/space/hardsuit/shielded/ctf/red
	r_hand = /obj/item/gun/ballistic/automatic/laser/ctf/red
	l_pocket = /obj/item/ammo_box/magazine/recharge/ctf/rifle/red
	r_pocket = /obj/item/ammo_box/magazine/recharge/ctf/rifle/red
	id = /obj/item/card/id/red //it's red
	team_radio_freq = FREQ_CTF_RED

/datum/outfit/ctf/red/instagib
	name = "CTF Instagib (Red)"
	r_hand = /obj/item/gun/energy/laser/instakill/red
	shoes = /obj/item/clothing/shoes/jackboots/fast
	team_radio_freq = FREQ_CTF_RED

/datum/outfit/ctf/assault/red
	name = "CTF Assaulter (Red)"
	suit = /obj/item/clothing/suit/space/hardsuit/shielded/ctf/light/red
	r_hand = /obj/item/gun/ballistic/shotgun/ctf/red
	l_pocket = /obj/item/ammo_box/magazine/recharge/ctf/shotgun/red
	r_pocket = /obj/item/ammo_box/magazine/recharge/ctf/shotgun/red
	id = /obj/item/card/id/red
	team_radio_freq = FREQ_CTF_RED

/datum/outfit/ctf/marksman/red
	name = "CTF Marksman (Red)"
	suit = /obj/item/clothing/suit/space/hardsuit/shielded/ctf/red
	r_hand = /obj/item/gun/ballistic/automatic/laser/ctf/marksman/red
	l_pocket = /obj/item/ammo_box/magazine/recharge/ctf/marksman/red
	r_pocket = /obj/item/ammo_box/magazine/recharge/ctf/marksman/red
	id = /obj/item/card/id/red
	team_radio_freq = FREQ_CTF_RED

// BLUE TEAM CLASSES

/datum/outfit/ctf/blue
	name = "CTF Rifleman (Blue)"
	suit = /obj/item/clothing/suit/space/hardsuit/shielded/ctf/blue
	r_hand = /obj/item/gun/ballistic/automatic/laser/ctf/blue
	l_pocket = /obj/item/ammo_box/magazine/recharge/ctf/rifle/blue
	r_pocket = /obj/item/ammo_box/magazine/recharge/ctf/rifle/blue
	id = /obj/item/card/id/blue //it's blue
	team_radio_freq = FREQ_CTF_BLUE

/datum/outfit/ctf/blue/instagib
	name = "CTF Instagib (Blue)"
	r_hand = /obj/item/gun/energy/laser/instakill/blue
	shoes = /obj/item/clothing/shoes/jackboots/fast
	team_radio_freq = FREQ_CTF_BLUE

/datum/outfit/ctf/assault/blue
	name = "CTF Assaulter (Blue)"
	suit = /obj/item/clothing/suit/space/hardsuit/shielded/ctf/light/blue
	r_hand = /obj/item/gun/ballistic/shotgun/ctf/blue
	l_pocket = /obj/item/ammo_box/magazine/recharge/ctf/shotgun/blue
	r_pocket = /obj/item/ammo_box/magazine/recharge/ctf/shotgun/blue
	id = /obj/item/card/id/blue
	team_radio_freq = FREQ_CTF_BLUE

/datum/outfit/ctf/marksman/blue
	name = "CTF Marksman (Blue)"
	suit = /obj/item/clothing/suit/space/hardsuit/shielded/ctf/blue
	r_hand = /obj/item/gun/ballistic/automatic/laser/ctf/marksman/blue
	l_pocket = /obj/item/ammo_box/magazine/recharge/ctf/marksman/blue
	r_pocket = /obj/item/ammo_box/magazine/recharge/ctf/marksman/blue
	id = /obj/item/card/id/blue
	team_radio_freq = FREQ_CTF_BLUE

// GREEN TEAM CLASSES

/datum/outfit/ctf/green
	name = "CTF Rifleman (Green)"
	suit = /obj/item/clothing/suit/space/hardsuit/shielded/ctf/green
	r_hand = /obj/item/gun/ballistic/automatic/laser/ctf/green
	l_pocket = /obj/item/ammo_box/magazine/recharge/ctf/rifle/green
	r_pocket = /obj/item/ammo_box/magazine/recharge/ctf/rifle/green
	id = /obj/item/card/id/green //it's green
	team_radio_freq = FREQ_CTF_GREEN

/datum/outfit/ctf/green/instagib
	name = "CTF Instagib (Green)"
	r_hand = /obj/item/gun/energy/laser/instakill/green
	shoes = /obj/item/clothing/shoes/jackboots/fast
	team_radio_freq = FREQ_CTF_GREEN

/datum/outfit/ctf/assault/green
	name = "CTF Assaulter (Green)"
	suit = /obj/item/clothing/suit/space/hardsuit/shielded/ctf/light/green
	r_hand = /obj/item/gun/ballistic/shotgun/ctf/green
	l_pocket = /obj/item/ammo_box/magazine/recharge/ctf/shotgun/green
	r_pocket = /obj/item/ammo_box/magazine/recharge/ctf/shotgun/green
	id = /obj/item/card/id/green
	team_radio_freq = FREQ_CTF_GREEN

/datum/outfit/ctf/marksman/green
	name = "CTF Marksman (Blue)"
	suit = /obj/item/clothing/suit/space/hardsuit/shielded/ctf/green
	r_hand = /obj/item/gun/ballistic/automatic/laser/ctf/marksman/green
	l_pocket = /obj/item/ammo_box/magazine/recharge/ctf/marksman/green
	r_pocket = /obj/item/ammo_box/magazine/recharge/ctf/marksman/green
	id = /obj/item/card/id/green
	team_radio_freq = FREQ_CTF_GREEN

// YELLOW TEAM CLASSES

/datum/outfit/ctf/yellow
	name = "CTF Rifleman (Yellow)"
	suit = /obj/item/clothing/suit/space/hardsuit/shielded/ctf/yellow
	r_hand = /obj/item/gun/ballistic/automatic/laser/ctf/yellow
	l_pocket = /obj/item/ammo_box/magazine/recharge/ctf/rifle/yellow
	r_pocket = /obj/item/ammo_box/magazine/recharge/ctf/rifle/yellow
	id = /obj/item/card/id/yellow //it's yellow
	team_radio_freq = FREQ_CTF_YELLOW

/datum/outfit/ctf/yellow/instagib
	name = "CTF Instagib (Yellow)"
	r_hand = /obj/item/gun/energy/laser/instakill/yellow
	shoes = /obj/item/clothing/shoes/jackboots/fast
	team_radio_freq = FREQ_CTF_YELLOW

/datum/outfit/ctf/assault/yellow
	name = "CTF Assaulter (Yellow)"
	suit = /obj/item/clothing/suit/space/hardsuit/shielded/ctf/light/yellow
	r_hand = /obj/item/gun/ballistic/shotgun/ctf/yellow
	l_pocket = /obj/item/ammo_box/magazine/recharge/ctf/shotgun/yellow
	r_pocket = /obj/item/ammo_box/magazine/recharge/ctf/shotgun/yellow
	id = /obj/item/card/id/yellow
	team_radio_freq = FREQ_CTF_YELLOW

/datum/outfit/ctf/marksman/yellow
	name = "CTF Marksman (Blue)"
	suit = /obj/item/clothing/suit/space/hardsuit/shielded/ctf/yellow
	r_hand = /obj/item/gun/ballistic/automatic/laser/ctf/marksman/yellow
	l_pocket = /obj/item/ammo_box/magazine/recharge/ctf/marksman/yellow
	r_pocket = /obj/item/ammo_box/magazine/recharge/ctf/marksman/yellow
	id = /obj/item/card/id/yellow
	team_radio_freq = FREQ_CTF_YELLOW
