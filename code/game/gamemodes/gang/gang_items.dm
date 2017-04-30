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
	if(gang && real_cost)
		gang.message_gangtools("A [get_name_display(user, gang, gangtool)] was purchased by [user.real_name] for [real_cost] Influence.")
		log_game("A [id] was purchased by [key_name(user)] ([gang.name] Gang) for [real_cost] Influence.")
	gang.points -= real_cost
	spawn_item(user, gang, gangtool)
	return TRUE

/datum/gang_item/proc/spawn_item(mob/living/carbon/user, datum/gang/gang, obj/item/device/gangtool/gangtool)
	if(item_path)
		var/obj/item/O = new item_path(user.loc)
		user.put_in_hands(O)
	if(spawn_msg)
		to_chat(user, spawn_msg)

/datum/gang_item/proc/can_buy(mob/living/carbon/user, datum/gang/gang, obj/item/device/gangtool/gangtool)
	return gang && (gang.points >= get_cost(user, gang, gangtool)) && can_see(user, gang, gangtool)

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



/datum/gang_item/function/outfit
	name = "Create Armored Gang Outfit"
	id = "outfit"

/datum/gang_item/function/outfit/can_buy(mob/living/carbon/user, datum/gang/gang, obj/item/device/gangtool/gangtool)
	return gangtool && (gangtool.outfits > 0) && ..()

/datum/gang_item/function/outfit/get_cost_display(mob/living/carbon/user, datum/gang/gang, obj/item/device/gangtool/gangtool)
	if(gangtool && !gangtool.outfits)
		return "(Restocking)"
	return ..()

/datum/gang_item/function/outfit/spawn_item(mob/living/carbon/user, datum/gang/gang, obj/item/device/gangtool/gangtool)
	if(gang && gang.gang_outfit(user, gangtool))
		to_chat(user, "<span class='notice'><b>Gang Outfits</b> can act as armor with moderate protection against ballistic and melee attacks. Every gangster wearing one will also help grow your gang's influence.</span>")
		if(gangtool)
			gangtool.outfits -= 1

///////////////////
//WEAPONS
///////////////////

/datum/gang_item/weapon
	category = "Purchase Weapons:"

/datum/gang_item/weapon/ammo

/datum/gang_item/weapon/ammo/get_cost_display(mob/living/carbon/user, datum/gang/gang, obj/item/device/gangtool/gangtool)
	return "&nbsp;&#8627;" + ..() //this is pretty hacky but it looks nice on the popup

/datum/gang_item/weapon/switchblade
	name = "Switchblade"
	id = "switchblade"
	cost = 10
	item_path = /obj/item/weapon/switchblade

/datum/gang_item/weapon/pistol
	name = "10mm Pistol"
	id = "pistol"
	cost = 25
	item_path = /obj/item/weapon/gun/ballistic/automatic/pistol

/datum/gang_item/weapon/ammo/pistol_ammo
	name = "10mm Ammo"
	id = "pistol_ammo"
	cost = 10
	item_path = /obj/item/ammo_box/magazine/m10mm

/datum/gang_item/weapon/uzi
	name = "Uzi SMG"
	id = "uzi"
	cost = 60
	item_path = /obj/item/weapon/gun/ballistic/automatic/mini_uzi
	id = "uzi"

/datum/gang_item/weapon/ammo/uzi_ammo
	name = "Uzi Ammo"
	id = "uzi_ammo"
	cost = 40
	item_path = /obj/item/ammo_box/magazine/uzim9mm

//SLEEPING CARP

/datum/gang_item/weapon/bostaff
	name = "Bo Staff"
	id = "bostaff"
	cost = 10
	item_path = /obj/item/weapon/twohanded/bostaff

/datum/gang_item/weapon/sleeping_carp_scroll
	name = "Sleeping Carp Scroll (one-use)"
	id = "sleeping_carp_scroll"
	cost = 30
	item_path = /obj/item/weapon/sleeping_carp_scroll
	spawn_msg = "<span class='notice'>Anyone who reads the <b>sleeping carp scroll</b> will learn secrets of the sleeping carp martial arts style.</span>"

/datum/gang_item/weapon/wrestlingbelt
	name = "Wrestling Belt"
	id = "wrastling_belt"
	cost = 20
	item_path = /obj/item/weapon/storage/belt/champion/wrestling
	spawn_msg = "<span class='notice'>Anyone wearing the <b>wresting belt</b> will know how to be effective with wrestling.</span>"


///////////////////
//EQUIPMENT
///////////////////

/datum/gang_item/equipment
	category = "Purchase Equipment:"


/datum/gang_item/equipment/spraycan
	name = "Territory Spraycan"
	id = "spraycan"
	cost = 5
	item_path = /obj/item/toy/crayon/spraycan/gang

/datum/gang_item/equipment/necklace
	name = "Gold Necklace"
	id = "necklace"
	cost = 1
	item_path = /obj/item/clothing/neck/necklace/dope

/datum/gang_item/equipment/c4
	name = "C4 Explosive"
	id = "c4"
	cost = 10
	item_path = /obj/item/weapon/grenade/plastic/c4

/datum/gang_item/equipment/implant_breaker
	name = "Implant Breaker"
	id = "implant_breaker"
	cost = 10
	item_path = /obj/item/weapon/implanter/gang
	spawn_msg = "<span class='notice'>The <b>implant breaker</b> is a single-use device that destroys all implants within the target before trying to recruit them to your gang. Also works on enemy gangsters.</span>"

/datum/gang_item/equipment/implant_breaker/spawn_item(mob/living/carbon/user, datum/gang/gang, obj/item/device/gangtool/gangtool)
	if(item_path)
		var/obj/item/O = new item_path(user.loc, gang) //we need to override this whole proc for this one argument
		user.put_in_hands(O)
	if(spawn_msg)
		to_chat(user, spawn_msg)

/datum/gang_item/equipment/pen
	name = "Recruitment Pen"
	id = "pen"
	cost = 50
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
	if(initial(usrarea.name) == "Space" || isspaceturf(usrturf) || usr.z != 1)
		to_chat(user, "<span class='warning'>You can only use this on the station!</span>")
		return FALSE

	for(var/obj/obj in usrturf)
		if(obj.density)
			to_chat(user, "<span class='warning'>There's not enough room here!</span>")
			return FALSE

	if(!(usrarea.type in gang.territory|gang.territory_new))
		to_chat(user, "<span class='warning'>The <b>dominator</b> can be spawned only on territory controlled by your gang!</span>")
		return FALSE
	return ..()

/datum/gang_item/equipment/dominator/spawn_item(mob/living/carbon/user, datum/gang/gang, obj/item/device/gangtool/gangtool)
	new item_path(user.loc)

/* *************** Place a Hit *************** */

/datum/gang_item/equipment/place_hit
	name = "Hit contract"
	id = "hit"
	cost = 40
	item_path = /obj/item/weapon/gang_hitman
	spawn_msg = "Allows you to place a hit on someone other than your gang for points. \n \
				If they are not a gang head or the gang head body is destroyed, you will receive 10 points with a full refund by default. \n \
				If the target is a gang head or lieutenant, you will receive 35 points and a full refund. "

/datum/gang_item/equipment/place_hit/spawn_item(mob/living/carbon/user, datum/gang/gang, obj/item/device/gangtool/gangtool)
	if(item_path)
		var/obj/item/weapon/gang_hitman/O = new item_path(user.loc)
		user.put_in_hands(O)
		O.gang_ref = gang // this bugger right here is why we have to overwrite proc
	if(spawn_msg)
		to_chat(user, spawn_msg)

/obj/item/weapon/gang_hitman
	name = "contract"
	desc = "A nice complement to life insurance."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "paperslip"
	var/used = FALSE
	var/datum/gang/gang_ref = null
	var/mob/living/target = null
	var/points_for_kill = 50 // (Assuming Cost is 40 and this var is default) +10 for killing the poor sod, +25 if enemy gang, +35 if they're a ganghead

/obj/item/weapon/gang_hitman/examine(mob/user)
	..()
	if(target)
		to_chat(user, "You see [target]'s name appear several times throughout the paper. Probably not a good sign for them.")

/obj/item/weapon/gang_hitman/process()

	if(target.stat == DEAD || QDELETED(target) )
		if(target.mind.gang_datum == null || target == null )
			gang_ref.points += points_for_kill
		if(target.mind.gang_datum != null)
			if( (target in SSticker.mode.get_gang_bosses()) )
				gang_ref.points += Floor(points_for_kill * 1.5, 1)
			else
				gang_ref.points += Floor(points_for_kill * 1.3, 1)

		STOP_PROCESSING(SSobj, src)
		used = TRUE


/obj/item/weapon/gang_hitman/attack_self(mob/user)
	if(used)
		to_chat(user, "This contract has been used.")
		return

	if( gang_ref == null )
		to_chat(user, "This contract is not associated with a gang and therefore cannot be redeemed!")
		return

	var/list/mind2bodylist = list()
	for(var/datum/mind/M in gang_ref.gangsters) // You can only target people outside the gang that spawned the contract.
		var/mob/mind2body = M.current
		mind2bodylist += mind2body
	for(var/datum/mind/PT in gang_ref.prev_targets) // CHEATER CHEATER PUMPKIN EATER
		var/mob/prev_targ2body = PT.current
		mind2bodylist += prev_targ2body

	var/list/selection = GLOB.player_list - mind2bodylist

	var/choice = input(user,"Who do you want dead?","Choose Your Victim") as null|anything in selection

	if(!(isliving(choice)))
		to_chat(user, "[choice] is already dead!")
		used = FALSE
		return
	if(choice == user)
		to_chat(user, "A modest sacrifice, but we prefer to not indulge in assisted suicide.")
		used = FALSE
		return
	else
		target = choice
		used = TRUE
		gang_ref.prev_targets += target
		START_PROCESSING(SSobj, src)
