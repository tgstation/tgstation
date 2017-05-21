/datum/outfit/space
	name = "Standard Space Gear"

	uniform = /obj/item/clothing/under/color/grey
	shoes = /obj/item/clothing/shoes/sneakers/black
	suit = /obj/item/clothing/suit/space
	head = /obj/item/clothing/head/helmet/space
	back = /obj/item/weapon/tank/jetpack/oxygen
	mask = /obj/item/clothing/mask/breath

/datum/outfit/tournament
	name = "tournament standard red"

	uniform = /obj/item/clothing/under/color/red
	shoes = /obj/item/clothing/shoes/sneakers/black
	suit = /obj/item/clothing/suit/armor/vest
	head = /obj/item/clothing/head/helmet/thunderdome
	r_hand = /obj/item/weapon/gun/energy/pulse/destroyer
	l_hand = /obj/item/weapon/kitchen/knife
	r_pocket = /obj/item/weapon/grenade/smokebomb

/datum/outfit/tournament/green
	name = "tournament standard green"

	uniform = /obj/item/clothing/under/color/green

/datum/outfit/tournament/gangster
	name = "tournament gangster"

	uniform = /obj/item/clothing/under/rank/det
	suit = /obj/item/clothing/suit/det_suit
	glasses = /obj/item/clothing/glasses/thermal/monocle
	head = /obj/item/clothing/head/det_hat
	r_hand = /obj/item/weapon/gun/ballistic
	l_hand = null
	r_pocket = /obj/item/ammo_box/c10mm

/datum/outfit/tournament/janitor
	name = "tournament janitor"

	uniform = /obj/item/clothing/under/rank/janitor
	back = /obj/item/weapon/storage/backpack
	suit = null
	head = null
	r_hand = /obj/item/weapon/mop
	l_hand = /obj/item/weapon/reagent_containers/glass/bucket
	r_pocket = /obj/item/weapon/grenade/chem_grenade/cleaner
	l_pocket = /obj/item/weapon/grenade/chem_grenade/cleaner
	backpack_contents = list(/obj/item/stack/tile/plasteel=6)

/datum/outfit/tournament/janitor/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return

	var/obj/item/weapon/reagent_containers/glass/bucket/bucket = H.get_item_for_held_index(1)
	bucket.reagents.add_reagent("water",70)

/datum/outfit/laser_tag
	name = "Laser Tag Red"

	uniform = /obj/item/clothing/under/color/red
	shoes = /obj/item/clothing/shoes/sneakers/red
	head = /obj/item/clothing/head/helmet/redtaghelm
	gloves = /obj/item/clothing/gloves/color/red
	ears = /obj/item/device/radio/headset
	suit = /obj/item/clothing/suit/redtag
	back = /obj/item/weapon/storage/backpack
	suit_store = /obj/item/weapon/gun/energy/laser/redtag
	backpack_contents = list(/obj/item/weapon/storage/box=1)

/datum/outfit/laser_tag/blue
	name = "Laser Tag Blue"
	uniform = /obj/item/clothing/under/color/blue
	shoes = /obj/item/clothing/shoes/sneakers/blue
	head = /obj/item/clothing/head/helmet/bluetaghelm
	gloves = /obj/item/clothing/gloves/color/blue
	suit = /obj/item/clothing/suit/bluetag
	suit_store = /obj/item/weapon/gun/energy/laser/bluetag

/datum/outfit/pirate
	name = "Pirate"

	uniform = /obj/item/clothing/under/pirate
	shoes = /obj/item/clothing/shoes/sneakers/brown
	head = /obj/item/clothing/head/bandana
	glasses = /obj/item/clothing/glasses/eyepatch
	r_hand = /obj/item/weapon/melee/energy/sword/pirate

/datum/outfit/pirate/space
	name = "Space Pirate"

	suit = /obj/item/clothing/suit/space/pirate
	head = /obj/item/clothing/head/helmet/space/pirate

/datum/outfit/tunnel_clown
	name = "Tunnel Clown"

	uniform = /obj/item/clothing/under/rank/clown
	shoes = /obj/item/clothing/shoes/clown_shoes
	gloves = /obj/item/clothing/gloves/color/black
	mask = /obj/item/clothing/mask/gas/clown_hat
	ears = /obj/item/device/radio/headset
	glasses = /obj/item/clothing/glasses/thermal/monocle
	suit = /obj/item/clothing/suit/hooded/chaplain_hoodie
	l_pocket = /obj/item/weapon/reagent_containers/food/snacks/grown/banana
	r_pocket = /obj/item/weapon/bikehorn
	id = /obj/item/weapon/card/id
	r_hand = /obj/item/weapon/twohanded/fireaxe

/datum/outfit/tunnel_clown/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return

	var/obj/item/weapon/card/id/W = H.wear_id
	W.access = get_all_accesses()
	W.assignment = "Tunnel Clown!"
	W.registered_name = H.real_name
	W.update_label(H.real_name)

/datum/outfit/psycho
	name = "Masked Killer"

	uniform = /obj/item/clothing/under/overalls
	shoes = /obj/item/clothing/shoes/sneakers/white
	gloves = /obj/item/clothing/gloves/color/latex
	mask = /obj/item/clothing/mask/surgical
	head = /obj/item/clothing/head/welding
	ears = /obj/item/device/radio/headset
	glasses = /obj/item/clothing/glasses/thermal/monocle
	suit = /obj/item/clothing/suit/apron
	l_pocket = /obj/item/weapon/kitchen/knife
	r_pocket = /obj/item/weapon/scalpel
	r_hand = /obj/item/weapon/twohanded/fireaxe

/datum/outfit/psycho/post_equip(mob/living/carbon/human/H)
	for(var/obj/item/carried_item in H.get_equipped_items())
		carried_item.add_mob_blood(H)//Oh yes, there will be blood...
	for(var/obj/item/I in H.held_items)
		I.add_mob_blood(H)
	H.regenerate_icons()

/datum/outfit/assassin
	name = "Assassin"

	uniform = /obj/item/clothing/under/suit_jacket
	shoes = /obj/item/clothing/shoes/sneakers/black
	gloves = /obj/item/clothing/gloves/color/black
	ears = /obj/item/device/radio/headset
	glasses = /obj/item/clothing/glasses/sunglasses
	l_pocket = /obj/item/weapon/melee/energy/sword/saber
	l_hand = /obj/item/weapon/storage/secure/briefcase
	id = /obj/item/weapon/card/id/syndicate
	belt = /obj/item/device/pda/heads

/datum/outfit/assassin/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	var/obj/item/clothing/under/U = H.w_uniform
	U.attachTie(new /obj/item/clothing/tie/waistcoat(H))

	if(visualsOnly)
		return

	//Could use a type
	var/obj/item/weapon/storage/secure/briefcase/sec_briefcase = H.get_item_for_held_index(1)
	for(var/obj/item/briefcase_item in sec_briefcase)
		qdel(briefcase_item)
	for(var/i = 3 to 0 step -1)
		sec_briefcase.handle_item_insertion(new /obj/item/stack/spacecash/c1000,1)
	sec_briefcase.handle_item_insertion(new /obj/item/weapon/gun/energy/kinetic_accelerator/crossbow,1)
	sec_briefcase.handle_item_insertion(new /obj/item/weapon/gun/ballistic/revolver/mateba,1)
	sec_briefcase.handle_item_insertion(new /obj/item/ammo_box/a357,1)
	sec_briefcase.handle_item_insertion(new /obj/item/weapon/grenade/plastic/x4,1)

	var/obj/item/device/pda/heads/pda = H.belt
	pda.owner = H.real_name
	pda.ownjob = "Reaper"
	pda.update_label()

	var/obj/item/weapon/card/id/syndicate/W = H.wear_id
	W.access = get_all_accesses()
	W.assignment = "Reaper"
	W.registered_name = H.real_name
	W.update_label(H.real_name)

/datum/outfit/centcom_commander
	name = "Centcom Commander"

	uniform = /obj/item/clothing/under/rank/centcom_commander
	suit = /obj/item/clothing/suit/armor/bulletproof
	shoes = /obj/item/clothing/shoes/combat/swat
	gloves = /obj/item/clothing/gloves/combat
	ears = /obj/item/device/radio/headset/headset_cent/commander
	glasses = /obj/item/clothing/glasses/eyepatch
	mask = /obj/item/clothing/mask/cigarette/cigar/cohiba
	head = /obj/item/clothing/head/centhat
	belt = /obj/item/weapon/gun/ballistic/revolver/mateba
	r_pocket = /obj/item/weapon/lighter
	l_pocket = /obj/item/ammo_box/a357
	back = /obj/item/weapon/storage/backpack/satchel/leather
	id = /obj/item/weapon/card/id

/datum/outfit/centcom_commander/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return

	var/obj/item/weapon/card/id/W = H.wear_id
	W.icon_state = "centcom"
	W.access = get_all_accesses()
	W.access += get_centcom_access("Centcom Commander")
	W.assignment = "Centcom Commander"
	W.registered_name = H.real_name
	W.update_label()

/datum/outfit/spec_ops
	name = "Special Ops Officer"

	uniform = /obj/item/clothing/under/syndicate
	suit = /obj/item/clothing/suit/space/officer
	shoes = /obj/item/clothing/shoes/combat/swat
	gloves = /obj/item/clothing/gloves/combat
	glasses = /obj/item/clothing/glasses/thermal/eyepatch
	ears = /obj/item/device/radio/headset/headset_cent/commander
	mask = /obj/item/clothing/mask/cigarette/cigar/havana
	head = /obj/item/clothing/head/helmet/space/beret
	belt = /obj/item/weapon/gun/energy/pulse/pistol/m1911
	r_pocket = /obj/item/weapon/lighter
	back = /obj/item/weapon/storage/backpack/satchel/leather
	id = /obj/item/weapon/card/id

/datum/outfit/spec_ops/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return

	var/obj/item/weapon/card/id/W = H.wear_id
	W.icon_state = "centcom"
	W.access = get_all_accesses()
	W.access += get_centcom_access("Special Ops Officer")
	W.assignment = "Special Ops Officer"
	W.registered_name = H.real_name
	W.update_label()

	var/obj/item/device/radio/headset/R = H.ears
	R.set_frequency(GLOB.CENTCOM_FREQ)
	R.freqlock = 1

/datum/outfit/ghost_cultist
	name = "Cultist Ghost"

	uniform = /obj/item/clothing/under/color/black/ghost
	suit = /obj/item/clothing/suit/cultrobes/alt/ghost
	shoes = /obj/item/clothing/shoes/cult/alt/ghost
	head = /obj/item/clothing/head/culthood/alt/ghost
	r_hand = /obj/item/weapon/melee/cultblade/ghost

/datum/outfit/wizard
	name = "Blue Wizard"

	uniform = /obj/item/clothing/under/color/lightpurple
	suit = /obj/item/clothing/suit/wizrobe
	shoes = /obj/item/clothing/shoes/sandal/magic
	ears = /obj/item/device/radio/headset
	head = /obj/item/clothing/head/wizard
	r_pocket = /obj/item/weapon/teleportation_scroll
	r_hand = /obj/item/weapon/spellbook
	l_hand = /obj/item/weapon/staff
	back = /obj/item/weapon/storage/backpack
	backpack_contents = list(/obj/item/weapon/storage/box=1)

/datum/outfit/wizard/red
	name = "Red Wizard"

	suit = /obj/item/clothing/suit/wizrobe/red
	head = /obj/item/clothing/head/wizard/red

/datum/outfit/wizard/weeb
	name = "Marisa Wizard"

	suit = /obj/item/clothing/suit/wizrobe/marisa
	shoes = /obj/item/clothing/shoes/sandal/marisa
	head = /obj/item/clothing/head/wizard/marisa

/datum/outfit/soviet
	name = "Soviet Admiral"

	uniform = /obj/item/clothing/under/soviet
	head = /obj/item/clothing/head/pirate/captain
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	ears = /obj/item/device/radio/headset/headset_cent
	glasses = /obj/item/clothing/glasses/thermal/eyepatch
	suit = /obj/item/clothing/suit/pirate/captain
	back = /obj/item/weapon/storage/backpack/satchel/leather
	belt = /obj/item/weapon/gun/ballistic/revolver/mateba

	id = /obj/item/weapon/card/id

/datum/outfit/soviet/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return

	var/obj/item/weapon/card/id/W = H.wear_id
	W.icon_state = "centcom"
	W.access = get_all_accesses()
	W.access += get_centcom_access("Admiral")
	W.assignment = "Admiral"
	W.registered_name = H.real_name
	W.update_label()

/datum/outfit/mobster
	name = "Mobster"

	uniform = /obj/item/clothing/under/suit_jacket/really_black
	head = /obj/item/clothing/head/fedora
	shoes = /obj/item/clothing/shoes/laceup
	gloves = /obj/item/clothing/gloves/color/black
	ears = /obj/item/device/radio/headset
	glasses = /obj/item/clothing/glasses/sunglasses
	r_hand = /obj/item/weapon/gun/ballistic/automatic/tommygun
	id = /obj/item/weapon/card/id

/datum/outfit/mobster/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return

	var/obj/item/weapon/card/id/W = H.wear_id
	W.assignment = "Assistant"
	W.registered_name = H.real_name
	W.update_label()

/datum/outfit/plasmaman
	name = "Plasmaman"

	head = /obj/item/clothing/head/helmet/space/plasmaman
	uniform = /obj/item/clothing/under/plasmaman
	r_hand= /obj/item/weapon/tank/internals/plasmaman/belt/full
	mask = /obj/item/clothing/mask/breath

/datum/outfit/death_commando
	name = "Death Commando"

	uniform = /obj/item/clothing/under/color/green
	suit = /obj/item/clothing/suit/space/hardsuit/shielded/swat
	shoes = /obj/item/clothing/shoes/combat/swat
	gloves = /obj/item/clothing/gloves/combat
	mask = /obj/item/clothing/mask/gas/sechailer/swat
	glasses = /obj/item/clothing/glasses/hud/toggle/thermal
	back = /obj/item/weapon/storage/backpack/security
	l_pocket = /obj/item/weapon/melee/energy/sword/saber
	r_pocket = /obj/item/weapon/shield/energy
	suit_store = /obj/item/weapon/tank/internals/emergency_oxygen
	belt = /obj/item/weapon/gun/ballistic/revolver/mateba
	r_hand = /obj/item/weapon/gun/energy/pulse/loyalpin
	id = /obj/item/weapon/card/id
	ears = /obj/item/device/radio/headset/headset_cent/alt

	backpack_contents = list(/obj/item/weapon/storage/box=1,\
		/obj/item/ammo_box/a357=1,\
		/obj/item/weapon/storage/firstaid/regular=1,\
		/obj/item/weapon/storage/box/flashbangs=1,\
		/obj/item/device/flashlight=1,\
		/obj/item/weapon/grenade/plastic/x4=1)

/datum/outfit/death_commando/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return

	var/obj/item/device/radio/R = H.ears
	R.set_frequency(GLOB.CENTCOM_FREQ)
	R.freqlock = 1

	var/obj/item/weapon/implant/mindshield/L = new/obj/item/weapon/implant/mindshield(H)//Here you go Deuryn
	L.implant(H, null, 1)


	var/obj/item/weapon/card/id/W = H.wear_id
	W.icon_state = "centcom"
	W.access = get_all_accesses()//They get full station access.
	W.access += get_centcom_access("Death Commando")//Let's add their alloted Centcom access.
	W.assignment = "Death Commando"
	W.registered_name = H.real_name
	W.update_label(W.registered_name, W.assignment)

/datum/outfit/death_commando/officer
	name = "Death Commando Officer"
	head = /obj/item/clothing/head/helmet/space/beret

/datum/outfit/chrono_agent
	name = "Timeline Eradication Agent"
	uniform = /obj/item/clothing/under/color/white
	suit = /obj/item/clothing/suit/space/chronos
	back = /obj/item/weapon/chrono_eraser
	head = /obj/item/clothing/head/helmet/space/chronos
	mask = /obj/item/clothing/mask/breath
	suit_store = /obj/item/weapon/tank/internals/oxygen




