#define HALFWAYCRIT 50
#define GATEWAYMAX 1

/datum/gang_item
	var/name
	var/item_path
	var/cost
	var/spawn_msg
	var/category
	var/id


/datum/gang_item/proc/purchase(mob/living/carbon/user, datum/gang/gang, obj/item/device/gangtool/gangtool, check_canbuy = TRUE)
	if(check_canbuy && !can_buy(user, gang, gangtool))
		return FALSE
	var/real_cost = get_cost(user, gang, gangtool)
	gang.adjust_influence(user.mind, -real_cost)
	spawn_item(user, gang, gangtool)
	return TRUE

/datum/gang_item/proc/spawn_item(mob/living/carbon/user, datum/gang/gang, obj/item/device/gangtool/gangtool)
	if(item_path)
		var/obj/item/O = new item_path(user.loc)
		user.put_in_hands(O)
	if(spawn_msg)
		to_chat(user, spawn_msg)

/datum/gang_item/proc/can_buy(mob/living/carbon/user, datum/gang/gang, obj/item/device/gangtool/gangtool)
	return gang && (gang.get_influence(user.mind) >= get_cost(user, gang, gangtool)) && can_see(user, gang, gangtool)

/datum/gang_item/proc/can_see(mob/living/carbon/user, datum/gang/gang, obj/item/device/gangtool/gangtool)
	return TRUE

/datum/gang_item/proc/get_cost(mob/living/carbon/user, datum/gang/gang, obj/item/device/gangtool/gangtool)
	return cost

/datum/gang_item/proc/get_cost_display(mob/living/carbon/user, datum/gang/gang, obj/item/device/gangtool/gangtool)
	return "([get_cost(user, gang, gangtool)] Influence)"

/datum/gang_item/proc/get_name_display(mob/living/carbon/user, datum/gang/gang, obj/item/device/gangtool/gangtool)
	return name

/datum/gang_item/proc/isboss(mob/living/carbon/user, datum/gang/gang)
	return user && gang && (user.mind == gang.bosses[1])

/datum/gang_item/proc/get_extra_info(mob/living/carbon/user, datum/gang/gang, obj/item/device/gangtool/gangtool)
	return

///////////////////
//FUNCTIONS
///////////////////

/datum/gang_item/function
	category = "Gangtool Functions:"
	cost = 0

/datum/gang_item/function/get_cost_display(mob/living/carbon/user, datum/gang/gang, obj/item/device/gangtool/gangtool)
	return ""

/datum/gang_item/function/gang_ping
	name = "Send Message to Gang"
	id = "gang_ping"

/datum/gang_item/function/gang_ping/spawn_item(mob/living/carbon/user, datum/gang/gang, obj/item/device/gangtool/gangtool)
	if(gangtool)
		gangtool.ping_gang(user)


/datum/gang_item/function/recall
	name = "Recall Emergency Shuttle"
	id = "recall"

/datum/gang_item/function/recall/can_see(mob/living/carbon/user, datum/gang/gang, obj/item/device/gangtool/gangtool)
	return isboss(user, gang)

/datum/gang_item/function/recall/spawn_item(mob/living/carbon/user, datum/gang/gang, obj/item/device/gangtool/gangtool)
	if(gangtool)
		gangtool.recall(user)

/datum/gang_item/function/leadership
	name = "Claim Gang Leadership"
	id = "leader"
	spawn_msg = "<span class='notice'>Use your new gangtool to accept your promotion; your influence has been transferred to the new tool.</span>"

/datum/gang_item/function/leadership/can_see(mob/living/carbon/user, datum/gang/gang, obj/item/device/gangtool/gangtool)
	return !gang.bosses_working

/datum/gang_item/function/leadership/spawn_item(mob/living/carbon/user, datum/gang/gang, obj/item/device/gangtool/gangtool)
	if(!gang || (src in gang.bosses))
		return
	var/obj/item/device/gangtool/O = new /obj/item/device/gangtool/spare/lt(user.loc)
	qdel(gangtool)
	O.register_device(user)
	gang.bosses_working = TRUE
	user.put_in_hands(O)
	if(spawn_msg)
		to_chat(user, spawn_msg)



/datum/gang_item/function/implant
	name = "Influence-Enhancing Mindshield"
	id = "mindshield"
	cost = 10

/datum/gang_item/function/implant/spawn_item(mob/living/carbon/user, datum/gang/gang, obj/item/device/vigilante_tool/VT)
	var/obj/item/weapon/implant/mindshield/MS = new()
	MS.implant(user, user, 0)
	VT.vigilante_items -= /datum/gang_item/function/implant

/datum/gang_item/function/implant/get_cost_display(mob/living/carbon/user, datum/gang/gang, obj/item/device/gangtool/gangtool)
	return "([get_cost(user, gang, gangtool)] Influence)"



/datum/gang_item/function/backup
	name = "Create Gateway for Reinforcements"
	id = "backup"
	item_path = /obj/machinery/gang/backup

/datum/gang_item/function/backup/can_see(mob/living/carbon/user, datum/gang/gang, obj/item/device/gangtool/gangtool)
	if(gang.gateways >= GATEWAYMAX)
		return FALSE
	return TRUE

/datum/gang_item/function/backup/can_buy(mob/living/carbon/user, datum/gang/gang, obj/item/device/gangtool/gangtool)
	if(gang.gateways >= GATEWAYMAX)
		return FALSE
	return TRUE

/datum/gang_item/function/backup/spawn_item(mob/living/carbon/user, datum/gang/gang, obj/item/device/gangtool/gangtool)
	gang.gateways++
	var/obj/machinery/gang/backup/gate = new(get_turf(user), gang)
	gate.G = gang

/datum/gang_item/function/backup/purchase(mob/living/carbon/user, datum/gang/gang, obj/item/device/gangtool/gangtool)
	var/area/usrarea = get_area(user.loc)
	if(!(usrarea.type in gang.territory|gang.territory_new))
		to_chat(user, "<span class='warning'>This device can only be spawned in territory controlled by your gang!</span>")
		return FALSE
	var/confirm_final = alert(user, "Your gang can only place ONE gateway, make sure it is in a well-secured location.", "Are you ready to place the gateway?", "This location is secure", "I should wait...")
	if(confirm_final == "No")
		return FALSE
	return ..()

/obj/machinery/gang/backup
	name = "gang reinforcements gateway"
	desc = "A gateway used by gangs to bring in muscle from other operations."
	anchored = TRUE
	density = TRUE
	icon = 'icons/obj/machines/teleporter.dmi'
	icon_state = "gang_teleporter_on"
	var/datum/gang/G
	var/list/mob/dead/observer/queue = list()
	max_integrity = 400
	obj_integrity = 400
	var/final_guard = TRUE

/obj/machinery/gang/backup/Initialize(mapload, datum/gang/gang)
	. = ..()
	G = gang
	name = "[G] reinforcements gateway"
	addtimer(CALLBACK(src, .proc/reinforce), max(10, (4500 - world.time)))
	do_sparks(4, TRUE, src)

/obj/machinery/gang/backup/Destroy(mapload, datum/gang/gang)
	for(var/mob/M in contents)
		qdel(M)
	return ..()

/obj/machinery/gang/backup/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1)
	. = ..()
	if(.)
		if((obj_integrity < 300) && final_guard == TRUE)
			final_guard = FALSE
			reinforce(FALSE)

/obj/machinery/gang/backup/proc/reinforce(var/repeat = TRUE)
	if(!src)
		return
	var/we = 0
	var/rival = 0
	var/cooldown = 0
	queue = list()
	for(var/datum/gang/baddies in SSticker.mode.gangs)
		if(baddies == G)
			for(var/datum/mind/M in G.gangsters)
				if(M.current.stat == DEAD)
					var/mob/O = M.get_ghost(TRUE)
					if(O)
						queue += O
					continue
				we++
			for(var/datum/mind/B in G.bosses)
				if(B.current.stat == DEAD)
					var/mob/O = B.get_ghost(TRUE)
					if(O)
						queue += O
					continue
				we++
		else
			for(var/datum/mind/E in G.gangsters)
				if(E.current.stat == DEAD)
					continue
				rival++
			for(var/datum/mind/R in G.gangsters)
				if(R.current.stat == DEAD)
					continue
				rival++
	if(!we)
		we = 1
	if(repeat)
		cooldown = 250+((we/(rival+we))*100)**2
		if(!SSticker.mode.vigilantes)
			cooldown += 650
		addtimer(CALLBACK(src, .proc/reinforce), cooldown, TIMER_UNIQUE)
	spawn_gangster()


/obj/machinery/gang/backup/proc/spawn_gangster()
	var/mob/living/carbon/human/H = new(src)
	var/mob/dead/observer/winner
	var/obj/item/clothing/uniform = G.inner_outfit
	var/obj/item/clothing/suit/outerwear = new G.outer_outfit(H)
	outerwear.armor = list(melee = 20, bullet = 35, laser = 10, energy = 10, bomb = 30, bio = 0, rad = 0, fire = 30, acid = 30)
	outerwear.body_parts_covered = CHEST|GROIN|LEGS|ARMS
	outerwear.desc += " Tailored for the [G.name] Gang to offer the wearer moderate protection against ballistics and physical trauma."
	H.equip_to_slot_or_del(new uniform(H), slot_w_uniform)
	H.equip_to_slot_or_del(outerwear, slot_wear_suit)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/jackboots(H), slot_shoes)
	H.put_in_l_hand(new /obj/item/weapon/gun/ballistic/automatic/surplus/gang(H))
	H.equip_to_slot_or_del(new /obj/item/ammo_box/magazine/m10mm/rifle(H),slot_l_store)
	H.equip_to_slot_or_del(new /obj/item/weapon/switchblade(H),slot_r_store)
	var/equip = SSjob.EquipRank(H, "Assistant", 1)
	H = equip
	if(LAZYLEN(queue))
		var/list/mob/dead/observer/finalists = pollCandidates("Would you like to be a [G.name] gang reinforcement?", jobbanType = ROLE_GANG, poll_time = 100, ignore_category = "gang war", group = queue)
		if(LAZYLEN(finalists))
			winner = pick(finalists)
	if(!winner)
		var/list/mob/dead/observer/dead_vigils = list()
		for(var/mob/dead/observer/O in GLOB.player_list)
			if(!O.mind.gang_datum)
				dead_vigils += O
		var/list/mob/dead/observer/candidates = pollCandidates("Would you like to be a [G.name] gang reinforcement?", jobbanType = ROLE_GANG, poll_time = 100, ignore_category = "gang war", group = dead_vigils)
		if(LAZYLEN(candidates))
			winner = pick(candidates)
	if(!src || !winner)
		message_admins("No ghosts to serve as a [G.name] gang reinforement")
		qdel(H)
		return
	var/datum/mind/reinforcement = new /datum/mind(winner.key)
	reinforcement.active = 1
	reinforcement.transfer_to(H)
	SSticker.mode.add_gangster(reinforcement, G, 0)
	do_sparks(4, TRUE, src)
	H.forceMove(get_turf(src))


///////////////////
//CLOTHING
///////////////////

/datum/gang_item/clothing
	category = "Purchase Influence-Enhancing Clothes:"

/datum/gang_item/clothing/under
	name = "Gang Uniform"
	id = "under"
	cost = 1

/datum/gang_item/clothing/under/spawn_item(mob/living/carbon/user, datum/gang/gang, obj/item/device/gangtool/gangtool)
	if(gang.inner_outfit)
		var/obj/item/O = new gang.inner_outfit(user.loc)
		user.put_in_hands(O)
		to_chat(user, "<span class='notice'> This is your gang's official uniform, wearing it will increase your influence")

/datum/gang_item/clothing/suit
	name = "Gang Armored Outerwear"
	id = "suit"
	cost = 1

/datum/gang_item/clothing/suit/spawn_item(mob/living/carbon/user, datum/gang/gang, obj/item/device/gangtool/gangtool)
	if(gang.outer_outfit)
		var/obj/item/O = new gang.outer_outfit(user.loc)
		O.armor = list(melee = 20, bullet = 35, laser = 10, energy = 10, bomb = 30, bio = 0, rad = 0, fire = 30, acid = 30)
		O.body_parts_covered = CHEST|GROIN|LEGS|ARMS
		O.desc += " Tailored for the [gang.name] Gang to offer the wearer moderate protection against ballistics and physical trauma."
		user.put_in_hands(O)
		to_chat(user, "<span class='notice'> This is your gang's official armored outerwear, it provides significant bullet and melee armor and grants influence while you wear it.")


/datum/gang_item/clothing/hat
	name = "Pimp Hat"
	id = "hat"
	cost = 14
	item_path = /obj/item/clothing/head/collectable/petehat/gang

/obj/item/clothing/head/collectable/petehat/gang
	name = "pimpin' hat"
	desc = "Show the station the strength of your pimp hand."

/obj/item/clothing/head/collectable/petehat/gang/gang_contraband_value()
	return 4

/datum/gang_item/clothing/mask
	name = "Golden Death Mask"
	id = "mask"
	cost = 15
	item_path = /obj/item/clothing/mask/gskull

/obj/item/clothing/mask/gskull
	name = "golden death mask"
	icon_state = "gskull"
	desc = "Strike terror, and envy, into the hearts of your enemies."

/obj/item/clothing/mask/gskull/gang_contraband_value()
	return 5

/datum/gang_item/clothing/shoes
	name = "Bling Boots"
	id = "boots"
	cost = 18
	item_path = /obj/item/clothing/shoes/gang

/obj/item/clothing/shoes/gang
	name = "blinged-out boots"
	desc = "Stand aside peasants."
	icon_state = "bling"

/obj/item/clothing/shoes/gang/gang_contraband_value()
	return 6

/datum/gang_item/clothing/neck
	name = "Gold Necklace"
	id = "necklace"
	cost = 6
	item_path = /obj/item/clothing/neck/necklace/dope

/datum/gang_item/clothing/hands
	name = "Decorative Brass Knuckles"
	id = "hand"
	cost = 9
	item_path = /obj/item/clothing/gloves/gang

/obj/item/clothing/gloves/gang
	name = "braggadocio's brass knuckles"
	desc = "Purely decorative, don't find out the hard way."
	icon_state = "knuckles"
	w_class = 3

/obj/item/clothing/gloves/gang/gang_contraband_value()
	return 3

/datum/gang_item/clothing/belt
	name = "Badass Belt"
	id = "belt"
	cost = 13
	item_path = /obj/item/weapon/storage/belt/military/gang

/obj/item/weapon/storage/belt/military/gang
	name = "badass belt"
	icon_state = "gangbelt"
	item_state = "gang"
	desc = "The belt buckle simply reads 'BAMF'."
	storage_slots = 1

/obj/item/weapon/storage/belt/military/gang/gang_contraband_value()
	return 4

///////////////////
//WEAPONS
///////////////////

/datum/gang_item/weapon
	category = "Purchase Weapons:"

/datum/gang_item/weapon/ammo

/datum/gang_item/weapon/ammo/get_cost_display(mob/living/carbon/user, datum/gang/gang, obj/item/device/gangtool/gangtool)
	return "&nbsp;&#8627;" + ..() //this is pretty hacky but it looks nice on the popup

/datum/gang_item/weapon/hatchet
	name = "Heavy Hatchet"
	id = "hatchet"
	cost = 3
	item_path = /obj/item/weapon/hatchet/heavy

/obj/item/weapon/hatchet/heavy
	name = "heavy hatchet"
	desc = "A very sharp axe blade upon a short fibremetal handle; this one has additional weight for a greater impact."
	force = 15
	w_class = WEIGHT_CLASS_SMALL

/datum/gang_item/weapon/shuriken
	name = "Shuriken"
	id = "shuriken"
	cost = 4
	item_path = /obj/item/weapon/throwing_star

/datum/gang_item/weapon/switchblade
	name = "Switchblade"
	id = "switchblade"
	cost = 5
	item_path = /obj/item/weapon/switchblade

/datum/gang_item/weapon/pitchfork
	name = "Premium Pitchfork"
	id = "pitchfork"
	cost = 6
	item_path = /obj/item/weapon/twohanded/pitchfork/gangfork

/datum/gang_item/weapon/surgood
	name = "Surplus Rifle"
	id = "surplus"
	cost = 8
	item_path = /obj/item/weapon/gun/ballistic/automatic/surplus

/datum/gang_item/weapon/surplus
	name = "Surplus Rifle"
	id = "surplus"
	cost = 6
	item_path = /obj/item/weapon/gun/ballistic/automatic/surplus/gang

/obj/item/weapon/gun/ballistic/automatic/surplus/gang
	name = "smuggled surplus rifle"

/datum/gang_item/weapon/ammo/surplus_ammo
	name = "Surplus Rifle Ammo"
	id = "surplus_ammo"
	cost = 5
	item_path = /obj/item/ammo_box/magazine/m10mm/rifle

/datum/gang_item/weapon/improvised
	name = "Sawn-Off Improvised Shotgun"
	id = "sawn"
	cost = 9
	item_path = /obj/item/weapon/gun/ballistic/revolver/doublebarrel/improvised/sawn

/datum/gang_item/weapon/ammo/buckshot_ammo
	name = "Box of Buckshot"
	id = "buckshot"
	cost = 7
	item_path = /obj/item/weapon/storage/box/lethalshot

/datum/gang_item/weapon/pistol
	name = "10mm Pistol"
	id = "pistol"
	cost = 35
	item_path = /obj/item/weapon/gun/ballistic/automatic/pistol

/datum/gang_item/weapon/ammo/pistol_ammo
	name = "10mm Ammo"
	id = "pistol_ammo"
	cost = 12
	item_path = /obj/item/ammo_box/magazine/m10mm

/datum/gang_item/weapon/pump
	name = "Pump Shotgun"
	id = "pump"
	cost = 40
	item_path = /obj/item/weapon/gun/ballistic/shotgun/lethal

/datum/gang_item/weapon/riot
	name = "Riot Shotgun"
	id = "riot"
	cost = 40
	item_path = /obj/item/weapon/gun/ballistic/shotgun/riot/lethal

/obj/item/weapon/gun/ballistic/shotgun/riot/lethal
	mag_type = /obj/item/ammo_box/magazine/internal/shot/lethal

/datum/gang_item/weapon/sniper
	name = "Black Market .50cal Sniper Rifle"
	id = "sniper"
	cost = 45
	item_path = /obj/item/weapon/gun/ballistic/automatic/sniper_rifle/gang

/datum/gang_item/weapon/ammo/sniper_ammo
	name = "Smuggled .50cal Sniper Rounds"
	id = "sniper_ammo"
	cost = 15
	item_path = /obj/item/ammo_box/magazine/sniper_rounds/gang


/datum/gang_item/weapon/ammo/sleeper_ammo
	name = "Illicit Tranquilizer Cartridges"
	id = "sniper_ammo"
	cost = 15
	item_path = /obj/item/ammo_box/magazine/sniper_rounds/gang/sleeper


/datum/gang_item/weapon/auto
	name = "Auto Rifle"
	id = "auto"
	cost = 35
	item_path = /obj/item/weapon/gun/ballistic/automatic/wt550

/datum/gang_item/weapon/ammo/auto_ammo
	name = "Standard Auto Rifle Ammo"
	id = "saber_ammo"
	cost = 12
	item_path = /obj/item/ammo_box/magazine/wt550m9

/datum/gang_item/weapon/ammo/auto_ammo_AP
	name = "Special Operations Auto Rifle Ammo"
	id = "saber_ammo"
	cost = 20
	item_path = /obj/item/ammo_box/magazine/wt550m9/wtap/elite

/obj/item/ammo_box/magazine/wt550m9/wtap/elite
	desc = "An upgrade from previous armor-piercing ammunition; it provides additional piercing and damage."
	ammo_type = /obj/item/ammo_casing/c46x30mmap/elite

/obj/item/ammo_casing/c46x30mmap/elite
	projectile_type = /obj/item/projectile/bullet/midbullet3/ap


/datum/gang_item/weapon/machinegun
	name = "Mounted Machine Gun"
	id = "MG"
	cost = 70
	item_path = /obj/machinery/manned_turret
	spawn_msg = "<span class='notice'>The mounted machine gun features enhanced responsiveness. Hold down on the trigger while firing to control where you're shooting.</span>"

/datum/gang_item/weapon/uzi
	name = "Uzi SMG"
	id = "uzi"
	cost = 65
	item_path = /obj/item/weapon/gun/ballistic/automatic/mini_uzi


/datum/gang_item/weapon/ammo/uzi_ammo
	name = "Uzi Ammo"
	id = "uzi_ammo"
	cost = 40
	item_path = /obj/item/ammo_box/magazine/uzim9mm

/datum/gang_item/weapon/launcher
	name = "88mm high explosive rocket launcher"
	id = "launcher"
	cost = 60
	item_path = /obj/item/weapon/gun/ballistic/automatic/atlauncher/HE
	spawn_msg = "<span class='This weapon is single-use and takes 3 seconds to fire. Aim True!</span>"

/obj/item/weapon/gun/ballistic/automatic/atlauncher/HE
		desc = "A single-use HE rocket launcher designed to neutralize massed enemies without causing critical damage to the ship or station."
		name = "88mm HE rocket launcher"
		mag_type = /obj/item/ammo_box/magazine/internal/rocketlauncher/HE

/obj/item/weapon/gun/ballistic/automatic/atlauncher/HE/process_fire(atom/target as mob|obj|turf, mob/living/user as mob|obj, message = TRUE, params, zone_override, bonus_spread = 0)
	if(!do_after(user, 20, target = user))
		return
	. = ..()

/obj/item/ammo_box/magazine/internal/rocketlauncher/HE
	ammo_type = /obj/item/ammo_casing/caseless/a84mm/HE

/obj/item/ammo_casing/caseless/a84mm/HE
	desc = "An 84mm HE rocket."
	projectile_type = /obj/item/projectile/bullet/HE_rocket

/obj/item/projectile/bullet/HE_rocket
	name = "84mm HE rocket"
	desc = "FWOOSH"
	icon_state= "atrocket"
	damage = 60
	armour_penetration = 100
	dismemberment = 100

/obj/item/projectile/bullet/HE_rocket/on_hit(atom/target, blocked=0)
	explosion(target, 0, 0, 5, 6)
	return 1

///////////////////
//EQUIPMENT
///////////////////

/datum/gang_item/equipment
	category = "Purchase Equipment:"

/datum/gang_item/equipment/brutepack
	name = "Brute Pack"
	id = "brute"
	cost = 4
	item_path = /obj/item/stack/medical/bruise_pack

/datum/gang_item/equipment/medpatch
	name = "Healing Patch"
	id = "heal"
	cost = 4
	item_path = /obj/item/weapon/reagent_containers/pill/patch/gang

/obj/item/weapon/reagent_containers/pill/patch/gang
	name = "unlabeled medical patch"
	desc = "Very popular among the type of people who can't go to a real hospital."
	list_reagents = list("styptic_powder" = 20, "silver_sulfadiazine" = 10, "crank" = 5)
	icon_state = "bandaid_brute"

/datum/gang_item/equipment/spraycan
	name = "Territory Spraycan"
	id = "spraycan"
	cost = 5
	item_path = /obj/item/toy/crayon/spraycan/gang


/datum/gang_item/equipment/shades
	name = "Signature Shades"
	id = "shades"
	cost = 2
	item_path = /obj/item/clothing/glasses/sunglasses/garb

/datum/gang_item/equipment/sechuds
	name = "SecHud Sunglasses"
	id = "sechuds"
	cost = 4
	item_path = /obj/item/clothing/glasses/hud/security/sunglasses

/datum/gang_item/equipment/sharpener
	name = "Sharpener"
	id = "whetstone"
	cost = 3
	item_path = /obj/item/weapon/sharpener


/datum/gang_item/equipment/c4
	name = "C4 Explosive"
	id = "c4"
	cost = 5
	item_path = /obj/item/weapon/grenade/plastic/c4


/datum/gang_item/equipment/shield
	name = "Telescopic Shield"
	id = "shield"
	cost = 10
	item_path = /obj/item/weapon/shield/riot/tele

/datum/gang_item/equipment/sandbag
	name = "Sandbags"
	id = "sandbag"
	cost = 6
	item_path = /obj/item/stack/sheet/mineral/sandbags

/datum/gang_item/equipment/sandbag/can_see(mob/living/carbon/user, datum/gang/gang, obj/item/device/gangtool/gangtool)
	if(!SSticker.mode.vigilantes) // Seems fair when defending against security, probably OP against a disorganized rabble of vigilantes
		return TRUE
	else
		return FALSE


/datum/gang_item/equipment/frag
	name = "Fragmentation Grenade"
	id = "frag nade"
	cost = 18
	item_path = /obj/item/weapon/grenade/syndieminibomb/concussion/frag

/datum/gang_item/equipment/stimpack
	name = "Black Market Stimulants"
	id = "stimpack"
	cost = 12
	item_path = /obj/item/weapon/reagent_containers/syringe/stimulants

/datum/gang_item/equipment/gangbreaker
	name = "Gangbreaker Implant"
	id = "gangbreaker"
	cost = 15
	item_path = /obj/item/weapon/implanter/mindshield
	spawn_msg = "<span class='notice'>Nanotrasen has provided you with a prototype mindshield implant that will both break a gang's control over a person and shield them from further conversion attempts.Gang bosses are immune.</b></u></span>"

/datum/gang_item/equipment/recruiter
	name = "Advanced Recruitment Implant"
	id = "recruitment"
	cost = 15
	item_path = /obj/item/weapon/implanter/gang
	spawn_msg = "<span class='notice'>The <b>Advanced Recruitment Implant</b> is a single-use device that is guaranteed to convert anyone into your gang, only rival gang bosses are immune.</b></u></span>"

/datum/gang_item/equipment/recruiter/spawn_item(mob/living/carbon/user, datum/gang/gang, obj/item/device/gangtool/gangtool)
	if(item_path)
		var/obj/item/O = new item_path(user.loc, gang) //we need to override this whole proc for this one argument
		user.put_in_hands(O)
	if(spawn_msg)
		to_chat(user, spawn_msg)

/datum/gang_item/equipment/wetwork_boots
	name = "Wetwork boots"
	id = "wetwork"
	cost = 15
	item_path = /obj/item/clothing/shoes/combat/gang

//////// REVIVIFICATION SERUM //////////

/datum/gang_item/equipment/reviver
	name = "Outlawed Reviver Serum"
	id = "reviver"
	cost = 50
	item_path = /obj/item/weapon/reviver

/datum/gang_item/equipment/reviver/get_cost(mob/living/carbon/user, datum/gang/gang, obj/item/device/gangtool/gangtool)
	cost = 5
	for(var/datum/mind/M in gang.gangsters)
		if(M.current.stat != DEAD)
			cost += 2
	return cost

/obj/item/weapon/reviver
	name = "outlawed revivification serum"
	desc = "Banned due to side effects of extreme rage, reduced intelligence, and violence. For gangs, that's just a fringe benefit."
	icon = 'icons/obj/items.dmi'
	icon_state = "implanter1"
	item_state = "syringe_0"
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	origin_tech = "materials=2;biotech=5"
	materials = list(MAT_METAL=600, MAT_GLASS=200)


/obj/item/weapon/reviver/attack(mob/living/carbon/human/H, mob/user)
	if(!ishuman(H) || icon_state == "implanter0")
		return ..()
	user.visible_message("<span class='warning'>[user] begins inject [H] with [src].</span>", "<span class='warning'>You begin to inject [H] with [src]...</span>")
	var/total_burn	= 0
	var/total_brute	= 0
	H.notify_ghost_cloning("You're being injected with a revivification serum - return to your body!")
	if(do_after(user, 80, target = H))
		if(H.stat == DEAD && icon_state == "implanter1")
			H.visible_message("<span class='warning'>[H]'s body thrashes violently.")
			playsound(src, "bodyfall", 50, 1)
			H.spin(20, 1)
			if (H.suiciding || (H.disabilities & NOCLONE) || !H.getorgan(/obj/item/organ/heart) || !H.getorgan(/obj/item/organ/brain) || !H.mind)
				H.visible_message("<span class='warning'>[H]'s body falls still again, they're gone for good.")
				return
			if(!H.key)
				var/identity
				var/mob/dead/observer/winner
				H.visible_message("<span class='warning'>[H]'s body twitches as a spirit seeks to return to this broken form.")
				if(H.mind.gang_datum)
					identity = "[H.mind.gang_datum.name] gangster"
				else
					identity = "Vigilante"
				var/list/mob/dead/observer/candidates = pollGhostCandidates("Would you to play the role of a revived [identity]?", "pAI", null, FALSE, 100)
				if(LAZYLEN(candidates) && !QDELETED(src) && icon_state == "implanter1")
					winner = pick(candidates)
					H.key = winner.key
				else
					H.visible_message("<span class='warning'>[H]'s body falls still again, their spirit has moved on.")
					return
			total_brute = H.getBruteLoss()
			total_burn = H.getFireLoss()
			var/overall_damage = total_brute + total_burn + H.getToxLoss() + H.getOxyLoss()
			var/mobhealth = H.health
			H.adjustOxyLoss((mobhealth - HALFWAYCRIT) * (H.getOxyLoss() / overall_damage), 0)
			H.adjustToxLoss((mobhealth - HALFWAYCRIT) * (H.getToxLoss() / overall_damage), 0)
			H.adjustFireLoss((mobhealth - HALFWAYCRIT) * (total_burn / overall_damage), 0)
			H.adjustBruteLoss((mobhealth - HALFWAYCRIT) * (total_brute / overall_damage), 0)
			H.updatehealth()
			H.set_heartattack(FALSE)
			H.grab_ghost()
			H.revive()
			H.emote("gasp")
			H.setBrainLoss(40)
			add_logs(user, H, "revived", src)
			icon_state = "implanter0"


////// Gangbuster Seraph //////

/datum/gang_item/equipment/seraph
	name = "Seraph 'Gangbuster' Mech"
	id = "seraph"
	cost = 250
	item_path = /obj/mecha/combat/marauder/gangbuster_seraph
	spawn_msg = "<span class='notice'>For employees who go above and beyond... you know what to do with this. </span>"


/obj/mecha/combat/marauder/gangbuster_seraph
	desc = "Heavy-duty, combat-type exosuit. This is a custom gangbuster model, utilized only by employees who have proven themselves in the line of fire."
	name = "\improper 'Gangbuster' Seraph" // Mostly for theming since this is a Nanotrasen funded initiative
	icon_state = "seraph"
	operation_req_access = list()
	step_in = 2
	obj_integrity = 300
	max_integrity = 300
	wreckage = /obj/structure/mecha_wreckage/seraph
	internal_damage_threshold = 20
	max_equip = 4
	bumpsmash = 0

/obj/mecha/combat/marauder/gangbuster_seraph/New()
	..()
	var/obj/item/mecha_parts/mecha_equipment/ME
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/scattershot(src)
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/lmg(src)
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack(src)
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/teleporter(src)
	ME.attach(src)

/obj/item/clothing/shoes/combat/gang
	name = "Wetwork boots"
	desc = "A gang's best hitmen are prepared for anything."
	permeability_coefficient = 0.01
	flags = NOSLIP

/datum/gang_item/equipment/bulletproof_armor
	name = "Bulletproof Armor"
	id = "BPA"
	cost = 20
	item_path = /obj/item/clothing/suit/armor/bulletproof

/datum/gang_item/equipment/bulletproof_helmet
	name = "Bulletproof Helmet"
	id = "BPH"
	cost = 10
	item_path = /obj/item/clothing/head/helmet/alt

/datum/gang_item/equipment/pen
	name = "Recruitment Pen"
	id = "pen"
	cost = 20
	item_path = /obj/item/weapon/pen/gang
	spawn_msg = "<span class='notice'>More <b>recruitment pens</b> will allow you to recruit gangsters faster. Only gang leaders can recruit with pens.</span>"

/datum/gang_item/equipment/pen/purchase(mob/living/carbon/user, datum/gang/gang, obj/item/device/gangtool/gangtool)
	if(..())
		gangtool.free_pen = FALSE
		return TRUE
	return FALSE

/datum/gang_item/equipment/pen/get_cost(mob/living/carbon/user, datum/gang/gang, obj/item/device/gangtool/gangtool)
	if(gangtool && gangtool.free_pen)
		return 0
	return ..()

/datum/gang_item/equipment/pen/get_cost_display(mob/living/carbon/user, datum/gang/gang, obj/item/device/gangtool/gangtool)
	if(gangtool && gangtool.free_pen)
		return "(GET ONE FREE)"
	return ..()




/datum/gang_item/equipment/gangtool
	id = "gangtool"
	cost = 10

/datum/gang_item/equipment/gangtool/spawn_item(mob/living/carbon/user, datum/gang/gang, obj/item/device/gangtool/gangtool)
	var/item_type
	if(gang && isboss(user, gang))
		item_type = /obj/item/device/gangtool/spare/lt
		if(gang.bosses.len < 3)
			to_chat(user, "<span class='notice'><b>Gangtools</b> allow you to promote a gangster to be your Lieutenant, enabling them to recruit and purchase items like you. Simply have them register the gangtool. You may promote up to [3-gang.bosses.len] more Lieutenants</span>")
	else
		item_type = /obj/item/device/gangtool/spare
	var/obj/item/device/gangtool/spare/tool = new item_type(user.loc)
	user.put_in_hands(tool)

/datum/gang_item/equipment/gangtool/get_name_display(mob/living/carbon/user, datum/gang/gang, obj/item/device/gangtool/gangtool)
	if(gang && isboss(user, gang) && (gang.bosses.len < 3))
		return "Promote a Gangster"
	return "Spare Gangtool"


/datum/gang_item/equipment/dominator
	name = "Station Dominator"
	id = "dominator"
	cost = 30
	item_path = /obj/machinery/dominator
	spawn_msg = "<span class='notice'>The <b>dominator</b> will secure your gang's dominance over the station. Turn it on when you are ready to defend it.</span>"

/datum/gang_item/equipment/dominator/can_buy(mob/living/carbon/user, datum/gang/gang, obj/item/device/gangtool/gangtool)
	if(!gang || !gang.dom_attempts)
		return FALSE
	return ..()

/datum/gang_item/equipment/dominator/get_name_display(mob/living/carbon/user, datum/gang/gang, obj/item/device/gangtool/gangtool)
	if(!gang || !gang.dom_attempts)
		return ..()
	return "<b>[..()]</b>"

/datum/gang_item/equipment/dominator/get_cost_display(mob/living/carbon/user, datum/gang/gang, obj/item/device/gangtool/gangtool)
	if(!gang || !gang.dom_attempts)
		return "(Out of stock)"
	return ..()

/datum/gang_item/equipment/dominator/get_extra_info(mob/living/carbon/user, datum/gang/gang, obj/item/device/gangtool/gangtool)
	if(gang)
		return "(Estimated Takeover Time: [round(determine_domination_time(gang)/60,0.1)] minutes)"

/datum/gang_item/equipment/dominator/purchase(mob/living/carbon/user, datum/gang/gang, obj/item/device/gangtool/gangtool)
	var/area/usrarea = get_area(user.loc)
	var/usrturf = get_turf(user.loc)
	if(initial(usrarea.name) == "Space" || isspaceturf(usrturf) || usr.z != ZLEVEL_STATION)
		to_chat(user, "<span class='warning'>You can only use this on the station!</span>")
		return FALSE

	for(var/obj/obj in usrturf)
		if(obj.density)
			to_chat(user, "<span class='warning'>There's not enough room here!</span>")
			return FALSE

	if(dominator_excessive_walls(user))
		to_chat(user, "<span class='warning'>The <b>dominator</b> will not function here! The <b>dominator</b> requires a sizable open space within three standard units so that walls do not interfere with the signal.</span>")
		return FALSE

	if(!(usrarea.type in gang.territory|gang.territory_new))
		to_chat(user, "<span class='warning'>The <b>dominator</b> can be spawned only on territory controlled by your gang!</span>")
		return FALSE
	return ..()

/datum/gang_item/equipment/dominator/spawn_item(mob/living/carbon/user, datum/gang/gang, obj/item/device/gangtool/gangtool)
	new item_path(user.loc)
