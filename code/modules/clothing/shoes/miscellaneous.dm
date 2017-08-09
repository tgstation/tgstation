/obj/item/clothing/shoes/proc/step_action() //this was made to rewrite clown shoes squeaking

/obj/item/clothing/shoes/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is bashing [user.p_their()] own head in with [src]! Ain't that a kick in the head?</span>")
	for(var/i = 0, i < 3, i++)
		sleep(3)
		playsound(user, 'sound/weapons/genhit2.ogg', 50, 1)
	return(BRUTELOSS)

/obj/item/clothing/shoes/sneakers/mime
	name = "mime shoes"
	icon_state = "mime"
	item_color = "mime"

/obj/item/clothing/shoes/combat //basic syndicate combat boots for nuke ops and mob corpses
	name = "combat boots"
	desc = "High speed, low drag combat boots."
	icon_state = "jackboots"
	item_state = "jackboots"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	armor = list(melee = 25, bullet = 25, laser = 25, energy = 25, bomb = 50, bio = 10, rad = 0, fire = 70, acid = 50)
	strip_delay = 70
	resistance_flags = 0
	pockets = /obj/item/weapon/storage/internal/pocket/shoes

/obj/item/clothing/shoes/combat/swat //overpowered boots for death squads
	name = "\improper SWAT boots"
	desc = "High speed, no drag combat boots."
	permeability_coefficient = 0.01
	flags = NOSLIP
	armor = list(melee = 40, bullet = 30, laser = 25, energy = 25, bomb = 50, bio = 30, rad = 30, fire = 90, acid = 50)

/obj/item/clothing/shoes/sandal
	desc = "A pair of rather plain, wooden sandals."
	name = "sandals"
	icon_state = "wizard"
	strip_delay = 50
	equip_delay_other = 50

/obj/item/clothing/shoes/sandal/marisa
	desc = "A pair of magic black shoes."
	name = "magic shoes"
	icon_state = "black"
	resistance_flags = FIRE_PROOF |  ACID_PROOF

/obj/item/clothing/shoes/sandal/magic
	name = "magical sandals"
	desc = "A pair of sandals imbued with magic"
	resistance_flags = FIRE_PROOF |  ACID_PROOF

/obj/item/clothing/shoes/galoshes
	desc = "A pair of yellow rubber boots, designed to prevent slipping on wet surfaces."
	name = "galoshes"
	icon_state = "galoshes"
	permeability_coefficient = 0.05
	flags = NOSLIP
	slowdown = SHOES_SLOWDOWN+1
	strip_delay = 50
	equip_delay_other = 50
	resistance_flags = 0
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0, fire = 40, acid = 75)

/obj/item/clothing/shoes/galoshes/dry
	name = "absorbent galoshes"
	desc = "A pair of orange rubber boots, designed to prevent slipping on wet surfaces while also drying them."
	icon_state = "galoshes_dry"

/obj/item/clothing/shoes/galoshes/dry/step_action()
	var/turf/open/t_loc = get_turf(src)
	if(istype(t_loc) && t_loc.wet)
		t_loc.MakeDry(TURF_WET_WATER)
		t_loc.wet_time = 0

/obj/item/clothing/shoes/clown_shoes
	desc = "The prankster's standard-issue clowning shoes. Damn, they're huge!"
	name = "clown shoes"
	icon_state = "clown"
	item_state = "clown_shoes"
	slowdown = SHOES_SLOWDOWN+1
	item_color = "clown"
	var/footstep = 1	//used for squeeks whilst walking
	pockets = /obj/item/weapon/storage/internal/pocket/shoes/clown

/obj/item/clothing/shoes/clown_shoes/step_action()
	if(footstep > 1)
		playsound(src, "clownstep", 50, 1)
		footstep = 0
	else
		footstep++

/obj/item/clothing/shoes/clown_shoes/jester
	name = "jester shoes"
	desc = "A court jesters shoes, updated with modern squeaking technology."
	icon_state = "jester_shoes"

/obj/item/clothing/shoes/jackboots
	name = "jackboots"
	desc = "Nanotrasen-issue Security combat boots for combat scenarios or combat situations. All combat, all the time."
	icon_state = "jackboots"
	item_state = "jackboots"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	item_color = "hosred"
	strip_delay = 50
	equip_delay_other = 50
	resistance_flags = 0
	pockets = /obj/item/weapon/storage/internal/pocket/shoes

/obj/item/clothing/shoes/jackboots/fast
	slowdown = -1

/obj/item/clothing/shoes/winterboots
	name = "winter boots"
	desc = "Boots lined with 'synthetic' animal fur."
	icon_state = "winterboots"
	item_state = "winterboots"
	cold_protection = FEET|LEGS
	min_cold_protection_temperature = SHOES_MIN_TEMP_PROTECT
	heat_protection = FEET|LEGS
	max_heat_protection_temperature = SHOES_MAX_TEMP_PROTECT
	pockets = /obj/item/weapon/storage/internal/pocket/shoes

/obj/item/clothing/shoes/workboots
	name = "work boots"
	desc = "Nanotrasen-issue Engineering lace-up work boots for the especially blue-collar."
	icon_state = "workboots"
	item_state = "jackboots"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	strip_delay = 40
	equip_delay_other = 40
	pockets = /obj/item/weapon/storage/internal/pocket/shoes

/obj/item/clothing/shoes/workboots/mining
	name = "mining boots"
	desc = "Steel-toed mining boots for mining in hazardous environments. Very good at keeping toes uncrushed."
	icon_state = "explorer"
	resistance_flags = FIRE_PROOF

/obj/item/clothing/shoes/cult
	name = "nar-sian invoker boots"
	desc = "A pair of boots worn by the followers of Nar-Sie."
	icon_state = "cult"
	item_state = "cult"
	item_color = "cult"
	cold_protection = FEET
	min_cold_protection_temperature = SHOES_MIN_TEMP_PROTECT
	heat_protection = FEET
	max_heat_protection_temperature = SHOES_MAX_TEMP_PROTECT

/obj/item/clothing/shoes/cult/alt
	name = "cultist boots"
	icon_state = "cultalt"

/obj/item/clothing/shoes/cult/alt/ghost
	flags = NODROP|DROPDEL

/obj/item/clothing/shoes/cyborg
	name = "cyborg boots"
	desc = "Shoes for a cyborg costume."
	icon_state = "boots"

/obj/item/clothing/shoes/laceup
	name = "laceup shoes"
	desc = "The height of fashion, and they're pre-polished!"
	icon_state = "laceups"
	equip_delay_other = 50

/obj/item/clothing/shoes/roman
	name = "roman sandals"
	desc = "Sandals with buckled leather straps on it."
	icon_state = "roman"
	item_state = "roman"
	strip_delay = 100
	equip_delay_other = 100

/obj/item/clothing/shoes/griffin
	name = "griffon boots"
	desc = "A pair of costume boots fashioned after bird talons."
	icon_state = "griffinboots"
	item_state = "griffinboots"
	pockets = /obj/item/weapon/storage/internal/pocket/shoes

/obj/item/clothing/shoes/bhop
	name = "jump boots"
	desc = "A specialized pair of combat boots with a built-in propulsion system for rapid foward movement."
	icon_state = "jetboots"
	item_state = "jetboots"
	item_color = "hosred"
	resistance_flags = FIRE_PROOF
	pockets = /obj/item/weapon/storage/internal/pocket/shoes
	actions_types = list(/datum/action/item_action/bhop)
	var/jumpdistance = 5 //-1 from to see the actual distance, e.g 4 goes over 3 tiles
	var/jumpspeed = 3
	var/recharging_rate = 60 //default 6 seconds between each dash
	var/recharging_time = 0 //time until next dash
	var/jumping = FALSE //are we mid-jump?

/obj/item/clothing/shoes/bhop/ui_action_click(mob/user, action)
	if(!isliving(usr))
		return

	if(jumping)
		return

	if(recharging_time > world.time)
		to_chat(usr, "<span class='warning'>The boot's internal propulsion needs to recharge still!</span>")
		return

	var/atom/target = get_edge_target_turf(usr, usr.dir) //gets the user's direction

	jumping = TRUE
	playsound(src.loc, 'sound/effects/stealthoff.ogg', 50, 1, 1)
	usr.visible_message("<span class='warning'>[usr] dashes forward into the air!</span>")
	usr.throw_at(target, jumpdistance, jumpspeed, spin=0, diagonals_first = 1, callback = CALLBACK(src, .proc/hop_end))

/obj/item/clothing/shoes/bhop/proc/hop_end()
	jumping = FALSE
	recharging_time = world.time + recharging_rate

/obj/item/clothing/shoes/singery
	name = "yellow performer's boots"
	desc = "These boots were made for dancing."
	icon_state = "ysing"
	equip_delay_other = 50

/obj/item/clothing/shoes/singerb
	name = "blue performer's boots"
	desc = "These boots were made for dancing."
	icon_state = "bsing"
	equip_delay_other = 50
