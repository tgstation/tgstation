#define HALFWAYCRIT 50
#define GATEWAYMAX 1

/datum/gang_item
	var/name
	var/item_path
	var/cost
	var/spawn_msg
	var/category
	var/list/gang_whitelist = list()
	var/list/gang_blacklist = list()
	var/id
	var/mode_flags = GANGMAGEDDON | GANGS

/datum/gang_item/proc/purchase(mob/living/carbon/user, datum/team/gang/gang, obj/item/gangtool/gangtool, check_canbuy = TRUE)
	if(check_canbuy && !can_buy(user, gang, gangtool))
		return FALSE
	var/real_cost = get_cost(user, gang, gangtool)
	if(!spawn_item(user, gang, gangtool))
		if(istype(gangtool, /obj/item/gangtool/hell_march))
			var/obj/item/gangtool/hell_march/HM = gangtool
			HM.points -= real_cost
		else
			if(gang)
				gang.adjust_influence(-real_cost)
		to_chat(user, "<span class='notice'>You bought \the [name].</span>")
		gangtool.attack_self(user)
		return TRUE

/datum/gang_item/proc/spawn_item(mob/living/carbon/user, datum/team/gang/gang, obj/item/gangtool/gangtool) // If this returns anything other than null, something fucked up and influence won't lower.
	if(item_path)
		var/obj/item/O = new item_path(user.loc)
		user.put_in_hands(O)
	else
		return TRUE
	if(spawn_msg)
		to_chat(user, spawn_msg)

/datum/gang_item/proc/can_buy(mob/living/carbon/user, datum/team/gang/gang, obj/item/gangtool/gangtool)
	if(istype(gangtool, /obj/item/gangtool/hell_march))
		var/obj/item/gangtool/hell_march/HM = gangtool
		return (HM.points >= get_cost(user, null, HM)) && can_see(user, null, HM)
	return gang && (gang.influence >= get_cost(user, gang, gangtool)) && can_see(user, gang, gangtool)

/datum/gang_item/proc/can_see(mob/living/carbon/user, datum/team/gang/gang, obj/item/gangtool/gangtool)
	return TRUE

/datum/gang_item/proc/get_cost(mob/living/carbon/user, datum/team/gang/gang, obj/item/gangtool/gangtool)
	return cost

/datum/gang_item/proc/get_cost_display(mob/living/carbon/user, datum/team/gang/gang, obj/item/gangtool/gangtool)
	return "([get_cost(user, gang, gangtool)] Influence)"

/datum/gang_item/proc/get_name_display(mob/living/carbon/user, datum/team/gang/gang, obj/item/gangtool/gangtool)
	return name

/datum/gang_item/proc/get_extra_info(mob/living/carbon/user, datum/team/gang/gang, obj/item/gangtool/gangtool)
	return

///////////////////
//CLOTHING
///////////////////

/datum/gang_item/clothing
	category = "Purchase Gang Clothes (Only the jumpsuit and suit give you added influence):"

/datum/gang_item/clothing/under
	name = "Gang Uniform"
	id = "under"
	cost = 1

/datum/gang_item/clothing/under/spawn_item(mob/living/carbon/user, datum/team/gang/gang, obj/item/gangtool/gangtool)
	if(gang.inner_outfits.len)
		var/outfit = pick(gang.inner_outfits)
		if(outfit)
			var/obj/item/O = new outfit(user.loc)
			user.put_in_hands(O)
			to_chat(user, "<span class='notice'> This is your gang's official uniform, wearing it will increase your influence")
			return
	return TRUE

/datum/gang_item/clothing/suit
	name = "Gang Armored Outerwear"
	id = "suit"
	cost = 1

/datum/gang_item/clothing/suit/spawn_item(mob/living/carbon/user, datum/team/gang/gang, obj/item/gangtool/gangtool)
	if(gang.outer_outfits.len)
		var/outfit = pick(gang.outer_outfits)
		if(outfit)
			var/obj/item/O = new outfit(user.loc)
			O.armor = O.armor.setRating(melee = 20, bullet = 35, laser = 10, energy = 10, bomb = 30, bio = 0, rad = 0, fire = 30, acid = 30)
			O.desc += " Tailored for the [gang.name] Gang to offer the wearer moderate protection against ballistics and physical trauma."
			user.put_in_hands(O)
			to_chat(user, "<span class='notice'> This is your gang's official outerwear, wearing it will increase your influence")
			return
	return TRUE


/datum/gang_item/clothing/hat
	name = "Pimp Hat"
	id = "hat"
	cost = 16
	item_path = /obj/item/clothing/head/collectable/petehat/gang


/obj/item/clothing/head/collectable/petehat/gang
	name = "pimpin' hat"
	desc = "The undisputed king of style."

/datum/gang_item/clothing/mask
	name = "Golden Death Mask"
	id = "mask"
	cost = 18
	item_path = /obj/item/clothing/mask/gskull

/obj/item/clothing/mask/gskull
	name = "golden death mask"
	icon_state = "gskull"
	desc = "Strike terror, and envy, into the hearts of your enemies."

/datum/gang_item/clothing/shoes
	name = "Bling Boots"
	id = "boots"
	cost = 22
	item_path = /obj/item/clothing/shoes/gang

/obj/item/clothing/shoes/gang
	name = "blinged-out boots"
	desc = "Stand aside peasants."
	icon_state = "bling"

/datum/gang_item/clothing/neck
	name = "Gold Necklace"
	id = "necklace"
	cost = 9
	item_path = /obj/item/clothing/neck/necklace/dope

/datum/gang_item/clothing/hands
	name = "Decorative Brass Knuckles"
	id = "hand"
	cost = 11
	item_path = /obj/item/clothing/gloves/gang

/obj/item/clothing/gloves/gang
	name = "braggadocio's brass knuckles"
	desc = "Purely decorative, don't find out the hard way."
	icon_state = "knuckles"
	w_class = 3

/datum/gang_item/clothing/belt
	name = "Badass Belt"
	id = "belt"
	cost = 13
	item_path = /obj/item/storage/belt/military/gang

/obj/item/storage/belt/military/gang
	name = "badass belt"
	icon_state = "gangbelt"
	item_state = "gang"
	desc = "The belt buckle simply reads 'BAMF'."

///////////////////
//WEAPONS
///////////////////

/datum/gang_item/weapon
	category = "Purchase Weapons:"

/datum/gang_item/weapon/ammo

/datum/gang_item/weapon/shuriken
	name = "Shuriken"
	id = "shuriken"
	cost = 3
	item_path = /obj/item/throwing_star
	mode_flags = GANGS | GANGMAGEDDON | VIGILANTE

/datum/gang_item/weapon/switchblade
	name = "Switchblade"
	id = "switchblade"
	cost = 5
	item_path = /obj/item/switchblade

/datum/gang_item/weapon/surplus
	name = "Surplus Rifle"
	id = "surplus"
	cost = 8
	item_path = /obj/item/gun/ballistic/automatic/surplus
	mode_flags = GANGS

/datum/gang_item/weapon/ammo/surplus_ammo
	name = "Surplus Rifle Ammo"
	id = "surplus_ammo"
	cost = 5
	item_path = /obj/item/ammo_box/magazine/m10mm/rifle
	mode_flags = GANGS | GANGMAGEDDON | VIGILANTE

/datum/gang_item/weapon/improvised
	name = "Sawn-Off Shotgun"
	id = "sawn"
	cost = 10
	item_path = /obj/item/gun/ballistic/shotgun/doublebarrel/gang
	mode_flags = GANGS | GANGMAGEDDON | VIGILANTE

/obj/item/gun/ballistic/shotgun/doublebarrel/gang
	name = "sawn-off double-barreled shotgun"
	w_class = WEIGHT_CLASS_NORMAL
	slot_flags = ITEM_SLOT_BELT
	mag_type = /obj/item/ammo_box/magazine/internal/shot/dual/gang
	recoil = SAWN_OFF_RECOIL
	sawn_off = TRUE

/obj/item/ammo_box/magazine/internal/shot/dual/gang
	name = "sawn-off double-barrel shotgun internal magazine"
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot

/datum/gang_item/weapon/ammo/improvised_ammo
	name = "Box of Buckshot"
	id = "buckshot"
	cost = 5
	item_path = /obj/item/storage/box/lethalshot
	mode_flags = GANGS

/datum/gang_item/weapon/pistol
	name = "10mm Pistol"
	id = "pistol"
	cost = 30
	item_path = /obj/item/gun/ballistic/automatic/pistol
	mode_flags = GANGS

/datum/gang_item/weapon/ammo/pistol_ammo
	name = "10mm Ammo"
	id = "pistol_ammo"
	cost = 10
	item_path = /obj/item/ammo_box/magazine/m10mm
	mode_flags = GANGS

/datum/gang_item/weapon/machinegun
	name = "Mounted Machine Gun"
	id = "MG"
	cost = 70
	item_path = /obj/machinery/manned_turret
	spawn_msg = "<span class='notice'>The mounted machine gun features enhanced responsiveness. Hold down on the trigger while firing to control where you're shooting.</span>"
	mode_flags = GANGMAGEDDON

/datum/gang_item/weapon/uzi
	name = "Uzi SMG"
	id = "uzi"
	cost = 60
	item_path = /obj/item/gun/ballistic/automatic/mini_uzi
	mode_flags = GANGS | GANGMAGEDDON | VIGILANTE

/datum/gang_item/weapon/ammo/uzi_ammo
	name = "Uzi Ammo"
	id = "uzi_ammo"
	cost = 40
	item_path = /obj/item/ammo_box/magazine/uzim9mm
	mode_flags = GANGS | GANGMAGEDDON | VIGILANTE

/datum/gang_item/weapon/launcher
	name = "PML-9 rocket launcher"
	id = "launcher"
	cost = 60
	item_path = /obj/item/gun/ballistic/rocketlauncher/unrestricted
	mode_flags = GANGMAGEDDON | VIGILANTE

/datum/gang_item/weapon/ammo/launcher
	name = "84mm HE rocket"
	id = "84he"
	cost = 5
	item_path = /obj/item/ammo_casing/caseless/rocket
	mode_flags = GANGMAGEDDON | VIGILANTE

/datum/gang_item/weapon/ammo/launcher2
	name = "84mm HEDP rocket"
	id = "84hedp"
	cost = 10
	item_path = /obj/item/ammo_casing/caseless/rocket/hedp
	mode_flags = GANGMAGEDDON | VIGILANTE

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
	mode_flags = GANGMAGEDDON | VIGILANTE

/datum/gang_item/equipment/medpatch
	name = "Healing Patch"
	id = "heal"
	cost = 4
	item_path = /obj/item/reagent_containers/pill/patch/synthflesh

/datum/gang_item/equipment/spraycan
	name = "Territory Spraycan"
	id = "spraycan"
	cost = 5
	item_path = /obj/item/toy/crayon/spraycan/gang

/datum/gang_item/equipment/spraycan/spawn_item(mob/living/carbon/user, datum/team/gang/gang, obj/item/gangtool/gangtool)
	var/obj/item/O = new item_path(user.loc, gang)
	user.put_in_hands(O)

/datum/gang_item/equipment/shield
	name = "Telescopic Shield"
	id = "shield"
	cost = 10
	item_path = /obj/item/shield/riot/tele
	mode_flags = VIGILANTE

/datum/gang_item/equipment/sandbag
	name = "Sandbags"
	id = "sandbag"
	cost = 6
	item_path = /obj/item/stack/sheet/mineral/sandbags
	mode_flags = GANGMAGEDDON | VIGILANTE

/datum/gang_item/equipment/sharpener
	name = "Sharpener"
	id = "whetstone"
	cost = 3
	item_path = /obj/item/sharpener
	mode_flags = GANGS | GANGMAGEDDON | VIGILANTE

/datum/gang_item/equipment/emp
	name = "EMP Grenade"
	id = "EMP"
	cost = 5
	item_path = /obj/item/grenade/empgrenade

/datum/gang_item/equipment/c4
	name = "C4 Explosive"
	id = "c4"
	cost = 7
	item_path = /obj/item/grenade/c4

/datum/gang_item/equipment/frag
	name = "Fragmentation Grenade"
	id = "frag nade"
	cost = 18
	item_path = /obj/item/grenade/syndieminibomb/concussion/frag

/datum/gang_item/equipment/implant_breaker
	name = "Implant Breaker"
	id = "implant_breaker"
	cost = 10
	item_path = /obj/item/implanter/gang
	spawn_msg = "<span class='notice'>The <b>implant breaker</b> is a single-use device that destroys all implants within the target before trying to recruit them to your gang. Also works on enemy gangsters.</span>"

/datum/gang_item/equipment/implant_breaker/spawn_item(mob/living/carbon/user, datum/team/gang/gang, obj/item/gangtool/gangtool)
	var/obj/item/O = new item_path(user.loc, gang)
	user.put_in_hands(O)

/datum/gang_item/function
	category = "Gangtool Functions:"
	cost = 0

/datum/gang_item/function/backup
	name = "Create Gateway for Reinforcements"
	id = "backup"
	item_path = /obj/machinery/gang/backup
	mode_flags = GANGMAGEDDON

/datum/gang_item/function/backup/can_see(mob/living/carbon/user, datum/team/gang/gang, obj/item/gangtool/gangtool)
	if(!user.mind.has_antag_datum(/datum/antagonist/gang/boss))
		return FALSE
	if(gang.gateways >= GATEWAYMAX)
		return FALSE
	return TRUE

/datum/gang_item/function/backup/can_buy(mob/living/carbon/user, datum/team/gang/gang, obj/item/gangtool/gangtool)
	if(gang.gateways >= GATEWAYMAX)
		return FALSE
	return TRUE

/datum/gang_item/function/backup/spawn_item(mob/living/carbon/user, datum/team/gang/gang, obj/item/gangtool/gangtool)
	var/obj/machinery/gang/backup/gate = new(get_turf(user), gang)
	gate.G = gang

/datum/gang_item/function/backup/purchase(mob/living/carbon/user, datum/team/gang/gang, obj/item/gangtool/gangtool)
	var/area/usrarea = get_area(user.loc)
	if(!(usrarea.type in gang.territories|gang.new_territories))
		to_chat(user, "<span class='warning'>This device can only be spawned in territory controlled by your gang!</span>")
		return FALSE
	var/confirm_final = alert(user, "Your gang can only place ONE gateway, make sure it is in a well-secured location.", "Are you ready to place the gateway?", "This location is secure", "I should wait...")
	if(confirm_final == "I should wait...")
		return FALSE
	return ..()

/obj/machinery/gang/backup
	name = "gang reinforcements gateway"
	desc = "A gateway used by gangs to bring in muscle from other operations."
	anchored = TRUE
	density = TRUE
	icon = 'austation/icons/obj/machines/teleporter.dmi'
	icon_state = "gang_teleporter_on"
	max_integrity = 400
	obj_integrity = 400
	var/final_guard = TRUE
	var/datum/team/gang/G
	var/list/mob/dead/observer/queue

/obj/machinery/gang/backup/Initialize(mapload, datum/team/gang/gang)
	. = ..()
	G = gang
	queue = list()
	name = "[G] reinforcements gateway"
	addtimer(CALLBACK(src, .proc/reinforce), max(10, (4500 - world.time)))
	do_sparks(4, TRUE, src)
	gang.gateways++

/obj/machinery/gang/backup/Destroy(mapload, datum/team/gang/gang)
	for(var/mob/M in contents)
		qdel(M)
	return ..()

/obj/machinery/gang/backup/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = TRUE)
	. = ..()
	if(.)
		if((obj_integrity < 300) && final_guard == TRUE)
			final_guard = FALSE
			reinforce(FALSE)

/obj/machinery/gang/backup/proc/reinforce(repeat = TRUE)
	var/we = 0
	var/rival = 0
	var/cooldown = 0
	queue = list()
	for(var/datum/team/gang/baddies in GLOB.gangs)
		if(baddies == G)
			for(var/datum/mind/M in G.members)
				if(M.current.stat == DEAD)
					var/mob/O = M.get_ghost(TRUE)
					if(O)
						queue += O
					continue
				we++
			for(var/datum/mind/B in G.leaders)
				if(B.current.stat == DEAD)
					var/mob/O = B.get_ghost(TRUE)
					if(O)
						queue += O
					continue
				we++
		else
			for(var/datum/mind/E in G.members)
				if(E.current.stat == DEAD)
					continue
				rival++
			for(var/datum/mind/R in G.members)
				if(R.current.stat == DEAD)
					continue
				rival++
	if(!we)
		we = 1
	if(repeat)
		cooldown = 250+((we/(rival+we))*100)**2
		addtimer(CALLBACK(src, .proc/reinforce), cooldown, TIMER_UNIQUE)
	spawn_gangster()


/obj/machinery/gang/backup/proc/spawn_gangster()
	var/mob/dead/observer/winner
	if(LAZYLEN(queue))
		var/list/mob/dead/observer/finalists = pollCandidates("Would you like to be a [G.name] gang reinforcement?", jobbanType = ROLE_GANG, poll_time = 100, ignore_category = "gang war", group = queue)
		if(LAZYLEN(finalists))
			winner = pick(finalists)
	if(!winner)
		var/list/mob/dead/observer/dead_vigils = list()
		for(var/mob/dead/observer/O in GLOB.player_list)
			if(!O.mind.has_antag_datum(/datum/antagonist/gang))
				dead_vigils += O
		var/list/mob/dead/observer/candidates = pollCandidates("Would you like to be a [G.name] gang reinforcement?", jobbanType = ROLE_GANG, poll_time = 100, ignore_category = "gang war", group = dead_vigils)
		if(LAZYLEN(candidates))
			winner = pick(candidates)
	if(!src || !winner)
		message_admins("No ghosts to serve as a [G.name] gang reinforement")
		return
	var/mob/living/carbon/human/H = new(src)
	var/datum/mind/reinforcement = new /datum/mind(winner.key)
	reinforcement.active = TRUE
	reinforcement.transfer_to(H)
	reinforcement.add_antag_datum(/datum/antagonist/gang, G)
	var/obj/item/clothing/uniform = pick(G.inner_outfits)
	var/obj/item/clothing/suit/OW = pick(G.outer_outfits)
	var/obj/item/clothing/suit/outerwear = new OW(H)
	outerwear.armor = list(melee = 20, bullet = 35, laser = 10, energy = 10, bomb = 30, bio = 0, rad = 0, fire = 30, acid = 30)
	outerwear.body_parts_covered = CHEST|GROIN|LEGS|ARMS
	outerwear.desc += " Tailored for the [G.name] Gang to offer the wearer moderate protection against ballistics and physical trauma."
	H.equip_to_slot_or_del(new uniform(H), ITEM_SLOT_ICLOTHING)
	H.equip_to_slot_or_del(outerwear,  ITEM_SLOT_OCLOTHING)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/jackboots(H), ITEM_SLOT_FEET)
	H.put_in_l_hand(new /obj/item/gun/ballistic/automatic/surplus(H))
	H.equip_to_slot_or_del(new /obj/item/ammo_box/magazine/m10mm/rifle(H), ITEM_SLOT_LPOCKET)
	H.equip_to_slot_or_del(new /obj/item/switchblade(H), ITEM_SLOT_RPOCKET)
	var/equip = SSjob.EquipRank(H, "Assistant", 1)
	H = equip
	do_sparks(4, TRUE, src)
	H.forceMove(get_turf(src))


/datum/gang_item/equipment/wetwork_boots
	name = "Wetwork boots"
	id = "wetwork"
	mode_flags = GANGS | GANGMAGEDDON | VIGILANTE
	cost = 20
	item_path = /obj/item/clothing/shoes/combat/gang

/obj/item/clothing/shoes/combat/gang
	name = "Wetwork boots"
	desc = "A gang's best hitmen are prepared for anything."
	permeability_coefficient = 0.01
	clothing_flags = NOSLIP

/datum/gang_item/equipment/bulletproof_armor
	name = "Bulletproof Armor"
	id = "BPA"
	cost = 20
	item_path = /obj/item/clothing/suit/armor/bulletproof
	mode_flags = GANGS | GANGMAGEDDON | VIGILANTE

/datum/gang_item/equipment/bulletproof_helmet
	name = "Bulletproof Helmet"
	id = "BPH"
	cost = 10
	item_path = /obj/item/clothing/head/helmet/alt
	mode_flags = GANGS | GANGMAGEDDON | VIGILANTE

/datum/gang_item/equipment/pen
	name = "Recruitment Pen"
	id = "pen"
	cost = 10
	item_path = /obj/item/pen/gang
	spawn_msg = "<span class='notice'>More <b>recruitment pens</b> will allow you to recruit gangsters faster. Only gang leaders can recruit with pens.</span>"

/datum/gang_item/equipment/pen/can_see(mob/living/carbon/user, datum/team/gang/gang, obj/item/gangtool/gangtool)
	if(!user.mind.has_antag_datum(/datum/antagonist/gang/boss))
		return FALSE
	return ..()

/datum/gang_item/equipment/pen/purchase(mob/living/carbon/user, datum/team/gang/gang, obj/item/gangtool/gangtool)
	if(..())
		gangtool.free_pen = FALSE
		return TRUE
	return FALSE

/datum/gang_item/equipment/pen/get_cost(mob/living/carbon/user, datum/team/gang/gang, obj/item/gangtool/gangtool)
	if(gangtool && gangtool.free_pen)
		return 0
	return ..()

/datum/gang_item/equipment/pen/get_cost_display(mob/living/carbon/user, datum/team/gang/gang, obj/item/gangtool/gangtool)
	if(gangtool && gangtool.free_pen)
		return "(GET ONE FREE)"
	return ..()


/datum/gang_item/equipment/gangtool
	id = "gangtool"
	cost = 10
	mode_flags = GANGS

/datum/gang_item/equipment/gangtool/spawn_item(mob/living/carbon/user, datum/team/gang/gang, obj/item/gangtool/gangtool)
	var/item_type
	if(gang)
		item_type = /obj/item/gangtool/spare/lt
		if(gang.leaders.len < MAX_LEADERS_GANG)
			to_chat(user, "<span class='notice'><b>Gangtools</b> allow you to promote a gangster to be your Lieutenant, enabling them to recruit and purchase items like you. Simply have them register the gangtool. You may promote up to [MAX_LEADERS_GANG-gang.leaders.len] more Lieutenants</span>")
	else
		item_type = /obj/item/gangtool/spare
	var/obj/item/gangtool/spare/tool = new item_type(user.loc)
	user.put_in_hands(tool)

/datum/gang_item/equipment/gangtool/get_name_display(mob/living/carbon/user, datum/team/gang/gang, obj/item/gangtool/gangtool)
	if(gang && (gang.leaders.len < gang.max_leaders))
		return "Promote a Gangster"
	return "Spare Gangtool"

/datum/gang_item/equipment/dominator
	name = "Station Dominator"
	id = "dominator"
	cost = 30
	item_path = /obj/machinery/dominator
	spawn_msg = "<span class='notice'>The <b>dominator</b> will secure your gang's dominance over the station. Turn it on when you are ready to defend it.</span>"

/datum/gang_item/equipment/dominator/can_see(mob/living/carbon/user, datum/team/gang/gang, obj/item/gangtool/gangtool)
	if(!user.mind.has_antag_datum(/datum/antagonist/gang/boss))
		return FALSE
	return ..()

/datum/gang_item/equipment/dominator/can_buy(mob/living/carbon/user, datum/team/gang/gang, obj/item/gangtool/gangtool)
	if(!gang || !gang.dom_attempts)
		return FALSE
	return ..()

/datum/gang_item/equipment/dominator/get_name_display(mob/living/carbon/user, datum/team/gang/gang, obj/item/gangtool/gangtool)
	if(!gang || !gang.dom_attempts)
		return ..()
	return "<b>[..()]</b>"

/datum/gang_item/equipment/dominator/get_cost_display(mob/living/carbon/user, datum/team/gang/gang, obj/item/gangtool/gangtool)
	if(!gang || !gang.dom_attempts)
		return "(Out of stock)"
	return ..()

/datum/gang_item/equipment/dominator/get_extra_info(mob/living/carbon/user, datum/team/gang/gang, obj/item/gangtool/gangtool)
	if(gang)
		return "This device requires a 5x5 area clear of walls to work. (Estimated Takeover Time: [round(gang.determine_domination_time()/60,0.1)] minutes)"

/datum/gang_item/equipment/dominator/purchase(mob/living/carbon/user, datum/team/gang/gang, obj/item/gangtool/gangtool)
	var/area/userarea = get_area(user)
	if(!(userarea.type in gang.territories|gang.new_territories))
		to_chat(user,"<span class='warning'>The <b>dominator</b> can be spawned only on territory controlled by your gang!</span>")
		return FALSE
	for(var/obj/obj in get_turf(user))
		if(obj.density)
			to_chat(user, "<span class='warning'>There's not enough room here!</span>")
			return FALSE
	var/list/open = list()
	var/list/closed = list()
	for(var/turf/T in view(3, user))
		if(isclosedturf(T))
			closed += T
		else if(isopenturf(T))
			open += T
	if(open.len < DOM_REQUIRED_TURFS)
		var/c_images = list()
		for(var/turf/T in closed)
			var/image/I = image('icons/obj/closet.dmi', T, "cardboard_special")
			I.layer = ABOVE_LIGHTING_LAYER
			I.plane = ABOVE_LIGHTING_PLANE
			c_images += I
			user.client.images += I
		if(alert(user,"Are you sure you wish to place the dominator here?\nThere needs to be [DOM_REQUIRED_TURFS - open.len] more open tiles!","Confirm","Ready","Later") != "Ready")
			for(var/image/I in c_images)
				user.client.images -= I
				qdel(I)
			return
		for(var/image/I in c_images)
			user.client.images -= I
			qdel(I)
	return ..()

/datum/gang_item/equipment/dominator/spawn_item(mob/living/carbon/user, datum/team/gang/gang, obj/item/gangtool/gangtool)
	new item_path(user.loc)
	to_chat(user, spawn_msg)

/datum/gang_item/equipment/reviver
	name = "Outlawed Reviver Serum"
	id = "reviver"
	cost = 50
	item_path = /obj/item/reviver
	mode_flags = GANGMAGEDDON

/obj/item/reviver
	name = "outlawed revivification serum"
	desc = "Banned due to side effects of extreme rage, reduced intelligence, and violence. For gangs, that's just a fringe benefit."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "implanter1"
	item_state = "syringe_0"
	throw_speed = 3
	throw_range = 5
	custom_materials = list(/datum/material/iron = 600, /datum/material/glass = 200)

/obj/item/reviver/attack(mob/living/carbon/human/H, mob/user)
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
			if (H.suiciding || !H.getorgan(/obj/item/organ/heart) || !H.getorgan(/obj/item/organ/brain) || !H.mind)
				H.visible_message("<span class='warning'>[H]'s body falls still again, they're gone for good.")
				return
			if(!H.client)
				var/identity
				var/mob/dead/observer/winner
				H.visible_message("<span class='warning'>[H]'s body twitches as a spirit seeks to return to this broken form.")
				var/datum/antagonist/gang/G = H.mind.has_antag_datum(/datum/antagonist/gang)
				if(G && G.gang)
					identity = "[G.gang.name] gangster"
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
			H.adjustOrganLoss(ORGAN_SLOT_BRAIN, 40)
			icon_state = "implanter0"
			update_icon()


//vigilante crap

/datum/gang_item/equipment/gangbreaker
	name = "Mindshield Implant"
	id = "gangbreaker"
	cost = 15
	item_path = /obj/item/implanter/mindshield
	spawn_msg = "<span class='notice'>Nanotrasen has provided you with a prototype mindshield implant that will both break a gang's control over a person and shield them from further conversion attempts.Gang bosses are immune.</b></u></span>"
	mode_flags = VIGILANTE

/datum/gang_item/equipment/seraph
	name = "Seraph 'Gangbuster' Mech"
	id = "seraph"
	cost = 250
	item_path = /obj/mecha/combat/marauder/gangbuster_seraph
	spawn_msg = "<span class='notice'>For employees who go above and beyond... you know what to do with this. </span>"
	mode_flags = VIGILANTE

/obj/mecha/combat/marauder/gangbuster_seraph
	desc = "Heavy-duty, combat-type exosuit. This is a custom gangbuster model, utilized only by employees who have proven themselves in the line of fire."
	name = "\improper 'Gangbuster' Seraph" // Mostly for theming since this is a Nanotrasen funded initiative
	icon_state = "seraph"

	step_in = 2
	obj_integrity = 300
	max_integrity = 300
	wreckage = /obj/structure/mecha_wreckage/seraph
	internal_damage_threshold = 20
	max_equip = 4
	bumpsmash = FALSE

/obj/mecha/combat/marauder/gangbuster_seraph/Initialize()
	. = ..()
	operation_req_access = list()
	var/obj/item/mecha_parts/mecha_equipment/ME
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/scattershot(src)
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/lmg(src)
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack(src)
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/teleporter(src)
	ME.attach(src)
