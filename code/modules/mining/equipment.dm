/****************Explorer's Suit**************************/

/obj/item/clothing/suit/hooded/explorer
	name = "explorer suit"
	desc = "An armoured suit for exploring harsh environments."
	icon_state = "explorer"
	item_state = "explorer"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	cold_protection = CHEST|GROIN|LEGS|ARMS
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	heat_protection = CHEST|GROIN|LEGS|ARMS
	hoodtype = /obj/item/clothing/head/hooded/explorer
	armor = list(melee = 30, bullet = 20, laser = 20, energy = 20, bomb = 50, bio = 100, rad = 50, fire = 50, acid = 50)
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank/internals, /obj/item/weapon/resonator, /obj/item/device/mining_scanner, /obj/item/device/t_scanner/adv_mining_scanner, /obj/item/weapon/gun/energy/kinetic_accelerator, /obj/item/weapon/pickaxe)
	resistance_flags = FIRE_PROOF

/obj/item/clothing/head/hooded/explorer
	name = "explorer hood"
	desc = "An armoured hood for exploring harsh environments."
	icon_state = "explorer"
	body_parts_covered = HEAD
	flags_inv = HIDEHAIR|HIDEFACE|HIDEEARS
	min_cold_protection_temperature = FIRE_HELM_MIN_TEMP_PROTECT
	max_heat_protection_temperature = FIRE_HELM_MAX_TEMP_PROTECT
	armor = list(melee = 30, bullet = 20, laser = 20, energy = 20, bomb = 50, bio = 100, rad = 50, fire = 50, acid = 50)
	resistance_flags = FIRE_PROOF

/obj/item/clothing/mask/gas/explorer
	name = "explorer gas mask"
	desc = "A military-grade gas mask that can be connected to an air supply."
	icon_state = "gas_mining"
	visor_flags = BLOCK_GAS_SMOKE_EFFECT | MASKINTERNALS
	visor_flags_inv = HIDEFACIALHAIR
	visor_flags_cover = MASKCOVERSMOUTH
	actions_types = list(/datum/action/item_action/adjust)
	armor = list(melee = 10, bullet = 5, laser = 5, energy = 5, bomb = 0, bio = 50, rad = 0, fire = 20, acid = 40)
	resistance_flags = FIRE_PROOF

/obj/item/clothing/mask/gas/explorer/attack_self(mob/user)
	adjustmask(user)

/obj/item/clothing/mask/gas/explorer/adjustmask(user)
	..()
	w_class = mask_adjusted ? WEIGHT_CLASS_NORMAL : WEIGHT_CLASS_SMALL

/obj/item/clothing/mask/gas/explorer/folded/New()
	..()
	adjustmask()


/**********************Mining Equipment Vendor Items**************************/

/**********************Jaunter**********************/

/obj/item/device/wormhole_jaunter
	name = "wormhole jaunter"
	desc = "A single use device harnessing outdated wormhole technology, Nanotrasen has since turned its eyes to blue space for more accurate teleportation. The wormholes it creates are unpleasant to travel through, to say the least.\nThanks to modifications provided by the Free Golems, this jaunter can be worn on the belt to provide protection from chasms."
	icon = 'icons/obj/mining.dmi'
	icon_state = "Jaunter"
	item_state = "electronic"
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 5
	origin_tech = "bluespace=2"
	slot_flags = SLOT_BELT

/obj/item/device/wormhole_jaunter/attack_self(mob/user)
	user.visible_message("<span class='notice'>[user.name] activates the [src.name]!</span>")
	feedback_add_details("jaunter", "U") // user activated
	activate(user)

/obj/item/device/wormhole_jaunter/proc/turf_check(mob/user)
	var/turf/device_turf = get_turf(user)
	if(!device_turf||device_turf.z==2||device_turf.z>=7)
		to_chat(user, "<span class='notice'>You're having difficulties getting the [src.name] to work.</span>")
		return FALSE
	return TRUE

/obj/item/device/wormhole_jaunter/proc/get_destinations(mob/user)
	var/list/destinations = list()

	if(isgolem(user))
		for(var/obj/item/device/radio/beacon/B in teleportbeacons)
			var/turf/T = get_turf(B)
			if(istype(T.loc, /area/ruin/powered/golem_ship))
				destinations += B

	// In the event golem beacon is destroyed, send to station instead
	if(destinations.len)
		return destinations

	for(var/obj/item/device/radio/beacon/B in teleportbeacons)
		var/turf/T = get_turf(B)
		if(T.z == ZLEVEL_STATION)
			destinations += B

	return destinations

/obj/item/device/wormhole_jaunter/proc/activate(mob/user)
	if(!turf_check(user))
		return

	var/list/L = get_destinations(user)
	if(!L.len)
		to_chat(user, "<span class='notice'>The [src.name] found no beacons in the world to anchor a wormhole to.</span>")
		return
	var/chosen_beacon = pick(L)
	var/obj/effect/portal/wormhole/jaunt_tunnel/J = new /obj/effect/portal/wormhole/jaunt_tunnel(get_turf(src), chosen_beacon, lifespan=100)
	J.target = chosen_beacon
	try_move_adjacent(J)
	playsound(src,'sound/effects/sparks4.ogg',50,1)
	qdel(src)

/obj/item/device/wormhole_jaunter/emp_act(power)
	var/triggered = FALSE

	if(usr.get_item_by_slot(slot_belt) == src)
		if(power == 1)
			triggered = TRUE
		else if(power == 2 && prob(50))
			triggered = TRUE

	if(triggered)
		usr.visible_message("<span class='warning'>The [src] overloads and activates!</span>")
		feedback_add_details("jaunter","E") // EMP accidental activation
		activate(usr)

/obj/item/device/wormhole_jaunter/proc/chasm_react(mob/user)
	if(user.get_item_by_slot(slot_belt) == src)
		to_chat(user, "Your [src] activates, saving you from the chasm!</span>")
		feedback_add_details("jaunter","C") // chasm automatic activation
		activate(user)
	else
		to_chat(user, "The [src] is not attached to your belt, preventing it from saving you from the chasm. RIP.</span>")


/obj/effect/portal/wormhole/jaunt_tunnel
	name = "jaunt tunnel"
	icon = 'icons/effects/effects.dmi'
	icon_state = "bhole3"
	desc = "A stable hole in the universe made by a wormhole jaunter. Turbulent doesn't even begin to describe how rough passage through one of these is, but at least it will always get you somewhere near a beacon."
	mech_sized = TRUE //save your ripley

/obj/effect/portal/wormhole/jaunt_tunnel/teleport(atom/movable/M)
	if(istype(M, /obj/effect))
		return

	if(M.anchored)
		if(!(istype(M, /obj/mecha) && mech_sized))
			return

	if(istype(M, /atom/movable))
		if(do_teleport(M, target, 6))
			// KERPLUNK
			playsound(M,'sound/weapons/resonator_blast.ogg',50,1)
			if(iscarbon(M))
				var/mob/living/carbon/L = M
				L.Weaken(3)
				if(ishuman(L))
					shake_camera(L, 20, 1)
					addtimer(CALLBACK(L, /mob/living/carbon.proc/vomit), 20)

/**********************Resonator**********************/

/obj/item/weapon/resonator
	name = "resonator"
	icon = 'icons/obj/mining.dmi'
	icon_state = "resonator"
	item_state = "resonator"
	desc = "A handheld device that creates small fields of energy that resonate until they detonate, crushing rock. It can also be activated without a target to create a field at the user's location, to act as a delayed time trap. It's more effective in a vacuum."
	w_class = WEIGHT_CLASS_NORMAL
	force = 15
	throwforce = 10
	var/burst_time = 30
	var/fieldlimit = 4
	var/list/fields = list()
	var/quick_burst_mod = 0.8
	origin_tech = "magnets=3;engineering=3"

/obj/item/weapon/resonator/upgraded
	name = "upgraded resonator"
	desc = "An upgraded version of the resonator that can produce more fields at once, as well as having no damage penalty for bursting a resonance field early."
	icon_state = "resonator_u"
	item_state = "resonator_u"
	origin_tech = "materials=4;powerstorage=3;engineering=3;magnets=3"
	fieldlimit = 6
	quick_burst_mod = 1

/obj/item/weapon/resonator/proc/CreateResonance(target, creator)
	var/turf/T = get_turf(target)
	var/obj/effect/resonance/R = locate(/obj/effect/resonance) in T
	if(R)
		R.resonance_damage *= quick_burst_mod
		R.burst()
		return
	if(fields.len < fieldlimit)
		playsound(src,'sound/weapons/resonator_fire.ogg',50,1)
		var/obj/effect/resonance/RE = new(T, creator, burst_time, src)
		fields += RE

/obj/item/weapon/resonator/attack_self(mob/user)
	if(burst_time == 50)
		burst_time = 30
		to_chat(user, "<span class='info'>You set the resonator's fields to detonate after 3 seconds.</span>")
	else
		burst_time = 50
		to_chat(user, "<span class='info'>You set the resonator's fields to detonate after 5 seconds.</span>")

/obj/item/weapon/resonator/afterattack(atom/target, mob/user, proximity_flag)
	if(proximity_flag)
		if(!check_allowed_items(target, 1))
			return
		user.changeNext_move(CLICK_CD_MELEE)
		CreateResonance(target, user)

/obj/effect/resonance
	name = "resonance field"
	desc = "A resonating field that significantly damages anything inside of it when the field eventually ruptures. More damaging in low pressure environments."
	icon = 'icons/effects/effects.dmi'
	icon_state = "shield1"
	layer = ABOVE_ALL_MOB_LAYER
	anchored = TRUE
	mouse_opacity = 0
	var/resonance_damage = 20
	var/creator
	var/obj/item/weapon/resonator/res

/obj/effect/resonance/New(loc, set_creator, timetoburst, set_resonator)
	..()
	creator = set_creator
	res = set_resonator
	check_pressure()
	addtimer(CALLBACK(src, .proc/burst), timetoburst)

/obj/effect/resonance/Destroy()
	if(res)
		res.fields -= src
	. = ..()

/obj/effect/resonance/proc/check_pressure()
	var/turf/proj_turf = get_turf(src)
	if(!istype(proj_turf))
		return
	var/datum/gas_mixture/environment = proj_turf.return_air()
	var/pressure = environment.return_pressure()
	if(pressure < 50)
		name = "strong [initial(name)]"
		resonance_damage = 60
	else
		name = initial(name)
		resonance_damage = initial(resonance_damage)

/obj/effect/resonance/proc/burst()
	check_pressure()
	var/turf/T = get_turf(src)
	playsound(src,'sound/weapons/resonator_blast.ogg',50,1)
	if(ismineralturf(T))
		var/turf/closed/mineral/M = T
		M.gets_drilled(creator)
	for(var/mob/living/L in T)
		if(creator)
			add_logs(creator, L, "used a resonator field on", "resonator")
		to_chat(L, "<span class='userdanger'>[src] ruptured with you in it!</span>")
		L.apply_damage(resonance_damage, BRUTE)
	qdel(src)

/**********************Facehugger toy**********************/

/obj/item/clothing/mask/facehugger/toy
	item_state = "facehugger_inactive"
	desc = "A toy often used to play pranks on other miners by putting it in their beds. It takes a bit to recharge after latching onto something."
	throwforce = 0
	real = 0
	sterile = 1
	tint = 3 //Makes it feel more authentic when it latches on

/obj/item/clothing/mask/facehugger/toy/Die()
	return

/**********************Lazarus Injector**********************/

/obj/item/weapon/lazarus_injector
	name = "lazarus injector"
	desc = "An injector with a cocktail of nanomachines and chemicals, this device can seemingly raise animals from the dead, making them become friendly to the user. Unfortunately, the process is useless on higher forms of life and incredibly costly, so these were hidden in storage until an executive thought they'd be great motivation for some of their employees."
	icon = 'icons/obj/syringe.dmi'
	icon_state = "lazarus_hypo"
	item_state = "hypo"
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 5
	var/loaded = 1
	var/malfunctioning = 0
	var/revive_type = SENTIENCE_ORGANIC //So you can't revive boss monsters or robots with it
	origin_tech = "biotech=4;magnets=6"

/obj/item/weapon/lazarus_injector/afterattack(atom/target, mob/user, proximity_flag)
	if(!loaded)
		return
	if(isliving(target) && proximity_flag)
		if(istype(target, /mob/living/simple_animal))
			var/mob/living/simple_animal/M = target
			if(M.sentience_type != revive_type)
				to_chat(user, "<span class='info'>[src] does not work on this sort of creature.</span>")
				return
			if(M.stat == DEAD)
				M.faction = list("neutral")
				M.revive(full_heal = 1, admin_revive = 1)
				if(ishostile(target))
					var/mob/living/simple_animal/hostile/H = M
					if(malfunctioning)
						H.faction |= list("lazarus", "\ref[user]")
						H.robust_searching = 1
						H.friends += user
						H.attack_same = 1
						log_game("[user] has revived hostile mob [target] with a malfunctioning lazarus injector")
					else
						H.attack_same = 0
				loaded = 0
				user.visible_message("<span class='notice'>[user] injects [M] with [src], reviving it.</span>")
				feedback_add_details("lazarus_injector", "[M.type]")
				playsound(src,'sound/effects/refill.ogg',50,1)
				icon_state = "lazarus_empty"
				return
			else
				to_chat(user, "<span class='info'>[src] is only effective on the dead.</span>")
				return
		else
			to_chat(user, "<span class='info'>[src] is only effective on lesser beings.</span>")
			return

/obj/item/weapon/lazarus_injector/emp_act()
	if(!malfunctioning)
		malfunctioning = 1

/obj/item/weapon/lazarus_injector/examine(mob/user)
	..()
	if(!loaded)
		to_chat(user, "<span class='info'>[src] is empty.</span>")
	if(malfunctioning)
		to_chat(user, "<span class='info'>The display on [src] seems to be flickering.</span>")

/**********************Mining Scanners**********************/

/obj/item/device/mining_scanner
	desc = "A scanner that checks surrounding rock for useful minerals; it can also be used to stop gibtonite detonations. Wear material scanners for optimal results."
	name = "manual mining scanner"
	icon_state = "mining1"
	item_state = "analyzer"
	w_class = WEIGHT_CLASS_SMALL
	flags = CONDUCT
	slot_flags = SLOT_BELT
	var/cooldown = 0
	origin_tech = "engineering=1;magnets=1"

/obj/item/device/mining_scanner/attack_self(mob/user)
	if(!user.client)
		return
	if(!cooldown)
		cooldown = TRUE
		addtimer(CALLBACK(src, .proc/clear_cooldown), 40)
		var/list/mobs = list()
		mobs |= user
		mineral_scan_pulse(mobs, get_turf(user))

/obj/item/device/mining_scanner/proc/clear_cooldown()
	cooldown = FALSE


//Debug item to identify all ore spread quickly
/obj/item/device/mining_scanner/admin

/obj/item/device/mining_scanner/admin/attack_self(mob/user)
	for(var/turf/closed/mineral/M in world)
		if(M.scan_state)
			M.icon_state = M.scan_state
	qdel(src)

/obj/item/device/t_scanner/adv_mining_scanner
	desc = "A scanner that automatically checks surrounding rock for useful minerals; it can also be used to stop gibtonite detonations. Wear meson scanners for optimal results. This one has an extended range."
	name = "advanced automatic mining scanner"
	icon_state = "mining0"
	item_state = "analyzer"
	w_class = WEIGHT_CLASS_SMALL
	flags = CONDUCT
	slot_flags = SLOT_BELT
	var/cooldown = 35
	var/on_cooldown = 0
	var/range = 7
	var/meson = TRUE
	origin_tech = "engineering=3;magnets=3"

/obj/item/device/t_scanner/adv_mining_scanner/material
	meson = FALSE
	desc = "A scanner that automatically checks surrounding rock for useful minerals; it can also be used to stop gibtonite detonations. Wear material scanners for optimal results. This one has an extended range."

/obj/item/device/t_scanner/adv_mining_scanner/lesser
	name = "automatic mining scanner"
	desc = "A scanner that automatically checks surrounding rock for useful minerals; it can also be used to stop gibtonite detonations. Wear meson scanners for optimal results."
	range = 4
	cooldown = 50

/obj/item/device/t_scanner/adv_mining_scanner/lesser/material
	desc = "A scanner that automatically checks surrounding rock for useful minerals; it can also be used to stop gibtonite detonations. Wear material scanners for optimal results."
	meson = FALSE

/obj/item/device/t_scanner/adv_mining_scanner/scan()
	if(!on_cooldown)
		on_cooldown = 1
		spawn(cooldown)
			on_cooldown = 0
		var/turf/t = get_turf(src)
		var/list/mobs = recursive_mob_check(t, 1,0,0)
		if(!mobs.len)
			return
		if(meson)
			mineral_scan_pulse(mobs, t, range)
		else
			mineral_scan_pulse_material(mobs, t, range)

//For use with mesons
/proc/mineral_scan_pulse(list/mobs, turf/T, range = world.view)
	var/list/minerals = list()
	for(var/turf/closed/mineral/M in range(range, T))
		if(M.scan_state)
			minerals += M
	if(minerals.len)
		for(var/mob/user in mobs)
			if(user.client)
				var/client/C = user.client
				for(var/turf/closed/mineral/M in minerals)
					var/turf/F = get_turf(M)
					var/image/I = image('icons/turf/smoothrocks.dmi', loc = F, icon_state = M.scan_state, layer = FLASH_LAYER)
					I.plane = FULLSCREEN_PLANE
					C.images += I
					spawn(30)
						if(C)
							C.images -= I

//For use with material scanners
/proc/mineral_scan_pulse_material(list/mobs, turf/T, range = world.view)
	var/list/minerals = list()
	for(var/turf/closed/mineral/M in range(range, T))
		if(M.scan_state)
			minerals += M
	if(minerals.len)
		for(var/turf/closed/mineral/M in minerals)
			var/obj/effect/overlay/temp/mining_overlay/C = new /obj/effect/overlay/temp/mining_overlay(M)
			C.icon_state = M.scan_state

/obj/effect/overlay/temp/mining_overlay
	layer = FLASH_LAYER
	icon = 'icons/turf/smoothrocks.dmi'
	anchored = 1
	mouse_opacity = 0
	duration = 30
	pixel_x = -4
	pixel_y = -4


/**********************Xeno Warning Sign**********************/
/obj/structure/sign/xeno_warning_mining
	name = "DANGEROUS ALIEN LIFE"
	desc = "A sign that warns would be travellers of hostile alien life in the vicinity."
	icon = 'icons/obj/mining.dmi'
	icon_state = "xeno_warning"

/*********************Hivelord stabilizer****************/

/obj/item/weapon/hivelordstabilizer
	name = "stabilizing serum"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle19"
	desc = "Inject certain types of monster organs with this stabilizer to preserve their healing powers indefinitely."
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "biotech=3"

/obj/item/weapon/hivelordstabilizer/afterattack(obj/item/organ/M, mob/user)
	var/obj/item/organ/hivelord_core/C = M
	if(!istype(C, /obj/item/organ/hivelord_core))
		to_chat(user, "<span class='warning'>The stabilizer only works on certain types of monster organs, generally regenerative in nature.</span>")
		return ..()

	C.preserved()
	to_chat(user, "<span class='notice'>You inject the [M] with the stabilizer. It will no longer go inert.</span>")
	qdel(src)

/*********************Mining Hammer****************/
/obj/item/weapon/twohanded/required/mining_hammer
	icon = 'icons/obj/mining.dmi'
	icon_state = "mining_hammer1"
	item_state = "mining_hammer1"
	name = "proto-kinetic crusher"
	desc = "An early design of the proto-kinetic accelerator, it is little more than an combination of various mining tools cobbled together, forming a high-tech club. \
	While it is an effective mining tool, it did little to aid any but the most skilled and/or suicidal miners against local fauna.\
	\n<span class='info'>Mark a mob with the destabilizing force, then hit them in melee to activate it for extra damage. Extra damage if backstabbed in this fashion. \
	This weapon is only particularly effective against large creatures.</span>"
	force = 20 //As much as a bone spear, but this is significantly more annoying to carry around due to requiring the use of both hands at all times
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = SLOT_BACK
	force_unwielded = 20 //It's never not wielded so these are the same
	force_wielded = 20
	throwforce = 5
	throw_speed = 4
	luminosity = 4
	armour_penetration = 10
	materials = list(MAT_METAL=1150, MAT_GLASS=2075)
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("smashed", "crushed", "cleaved", "chopped", "pulped")
	sharpness = IS_SHARP
	var/charged = 1
	var/charge_time = 16
	var/atom/mark = null
	var/marked_image = null

/obj/item/projectile/destabilizer
	name = "destabilizing force"
	icon_state = "pulse1"
	damage = 0 //We're just here to mark people. This is still a melee weapon.
	damage_type = BRUTE
	flag = "bomb"
	range = 6
	var/obj/item/weapon/twohanded/required/mining_hammer/hammer_synced =  null
	log_override = TRUE

/obj/item/projectile/destabilizer/on_hit(atom/target, blocked = 0)
	if(hammer_synced)
		if(hammer_synced.mark == target)
			return ..()
		if(isliving(target))
			if(hammer_synced.mark && hammer_synced.marked_image)
				hammer_synced.mark.underlays -= hammer_synced.marked_image
				hammer_synced.marked_image = null
			var/mob/living/L = target
			if(L.mob_size >= MOB_SIZE_LARGE)
				hammer_synced.mark = L
				var/image/I = image('icons/effects/effects.dmi', loc = L, icon_state = "shield2",pixel_y = (-L.pixel_y),pixel_x = (-L.pixel_x))
				L.underlays += I
				hammer_synced.marked_image = I
		var/target_turf = get_turf(target)
		if(ismineralturf(target_turf))
			var/turf/closed/mineral/M = target_turf
			new /obj/effect/overlay/temp/kinetic_blast(M)
			M.gets_drilled(firer)
	..()

/obj/item/weapon/twohanded/required/mining_hammer/afterattack(atom/target, mob/user, proximity_flag)
	if(!proximity_flag && charged)//Mark a target, or mine a tile.
		var/turf/proj_turf = get_turf(src)
		if(!isturf(proj_turf))
			return
		var/datum/gas_mixture/environment = proj_turf.return_air()
		var/pressure = environment.return_pressure()
		if(pressure > 50)
			playsound(user, 'sound/weapons/empty.ogg', 100, 1)
			return
		var/obj/item/projectile/destabilizer/D = new /obj/item/projectile/destabilizer(user.loc)
		D.preparePixelProjectile(target,get_turf(target), user)
		D.hammer_synced = src
		playsound(user, 'sound/weapons/plasma_cutter.ogg', 100, 1)
		D.fire()
		charged = 0
		icon_state = "mining_hammer1_uncharged"
		addtimer(CALLBACK(src, .proc/Recharge), charge_time)
		return
	if(proximity_flag && target == mark && isliving(target))
		var/mob/living/L = target
		new /obj/effect/overlay/temp/kinetic_blast(get_turf(L))
		mark = 0
		if(L.mob_size >= MOB_SIZE_LARGE)
			L.underlays -= marked_image
			qdel(marked_image)
			marked_image = null
			var/backstab_dir = get_dir(user, L)
			var/def_check = L.getarmor(type = "bomb")
			if((user.dir & backstab_dir) && (L.dir & backstab_dir))
				L.apply_damage(80, BRUTE, blocked = def_check)
				playsound(user, 'sound/weapons/Kenetic_accel.ogg', 100, 1) //Seriously who spelled it wrong
			else
				L.apply_damage(50, BRUTE, blocked = def_check)

/obj/item/weapon/twohanded/required/mining_hammer/proc/Recharge()
	if(!charged)
		charged = 1
		icon_state = "mining_hammer1"
		playsound(src.loc, 'sound/weapons/kenetic_reload.ogg', 60, 1)
