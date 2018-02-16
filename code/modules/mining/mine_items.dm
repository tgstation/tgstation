/**********************Light************************/

//this item is intended to give the effect of entering the mine, so that light gradually fades
/obj/effect/light_emitter
	name = "Light emitter"
	anchored = TRUE
	invisibility = 101
	var/set_luminosity = 8
	var/set_cap = 0

/obj/effect/light_emitter/Initialize()
	. = ..()
	set_light(set_luminosity, set_cap)

/obj/effect/light_emitter/singularity_pull()
	return

/obj/effect/light_emitter/singularity_act()
	return

/**********************Miner Lockers**************************/

/obj/structure/closet/wardrobe/miner
	name = "mining wardrobe"
	icon_door = "mixed"

/obj/structure/closet/wardrobe/miner/PopulateContents()
	new /obj/item/storage/backpack/duffelbag(src)
	new /obj/item/storage/backpack/explorer(src)
	new /obj/item/storage/backpack/satchel/explorer(src)
	new /obj/item/clothing/under/rank/miner/lavaland(src)
	new /obj/item/clothing/under/rank/miner/lavaland(src)
	new /obj/item/clothing/under/rank/miner/lavaland(src)
	new /obj/item/clothing/shoes/workboots/mining(src)
	new /obj/item/clothing/shoes/workboots/mining(src)
	new /obj/item/clothing/shoes/workboots/mining(src)
	new /obj/item/clothing/gloves/color/black(src)
	new /obj/item/clothing/gloves/color/black(src)
	new /obj/item/clothing/gloves/color/black(src)

/obj/structure/closet/secure_closet/miner
	name = "miner's equipment"
	icon_state = "mining"
	req_access = list(ACCESS_MINING)

/obj/structure/closet/secure_closet/miner/unlocked
	locked = FALSE

/obj/structure/closet/secure_closet/miner/PopulateContents()
	..()
	new /obj/item/stack/sheet/mineral/sandbags(src, 5)
	new /obj/item/storage/box/emptysandbags(src)
	new /obj/item/shovel(src)
	new /obj/item/pickaxe/mini(src)
	new /obj/item/device/radio/headset/headset_cargo/mining(src)
	new /obj/item/device/flashlight/seclite(src)
	new /obj/item/storage/bag/plants(src)
	new /obj/item/storage/bag/ore(src)
	new /obj/item/device/t_scanner/adv_mining_scanner/lesser(src)
	new /obj/item/gun/energy/kinetic_accelerator(src)
	new /obj/item/clothing/glasses/meson(src)
	new /obj/item/survivalcapsule(src)
	new /obj/item/device/assault_pod/mining(src)


/**********************Shuttle Computer**************************/

/obj/machinery/computer/shuttle/mining
	name = "mining shuttle console"
	desc = "Used to call and send the mining shuttle."
	circuit = /obj/item/circuitboard/computer/mining_shuttle
	shuttleId = "mining"
	possible_destinations = "mining_home;mining_away;landing_zone_dock;mining_public"
	no_destination_swap = 1
	var/global/list/dumb_rev_heads = list()

/obj/machinery/computer/shuttle/mining/attack_hand(mob/user)
	if(is_station_level(user.z) && user.mind && is_head_revolutionary(user) && !(user.mind in dumb_rev_heads))
		to_chat(user, "<span class='warning'>You get a feeling that leaving the station might be a REALLY dumb idea...</span>")
		dumb_rev_heads += user.mind
		return
	..()

/**********************Mining car (Crate like thing, not the rail car)**************************/

/obj/structure/closet/crate/miningcar
	desc = "A mining car. This one doesn't work on rails, but has to be dragged."
	name = "Mining car (not for rails)"
	icon_state = "miningcar"

// ************************* Barometer! ******************************

/obj/item/device/barometer
	name = "barometer"
	desc = "A persistent device used for tracking weather and storm patterns."
	icon_state = "barometer"
	var/cooldown = FALSE
	var/cooldown_time = 250
	var/accuracy // 0 is the best accuracy.

/obj/item/device/barometer/proc/ping()
	if(isliving(loc))
		var/mob/living/L = loc
		to_chat(L, "<span class='notice'>[src] is ready!</span>")
	playsound(get_turf(src), 'sound/machines/click.ogg', 100)
	cooldown = FALSE

/obj/item/device/barometer/attack_self(mob/user)
	var/turf/T = get_turf(user)
	if(!T)
		return

	playsound(get_turf(src), 'sound/effects/pop.ogg', 100)
	if(cooldown)
		to_chat(user, "<span class='warning'>[src] is prepraring itself.</span>")
		return

	var/area/user_area = T.loc
	var/datum/weather/ongoing_weather = null
	for(var/V in SSweather.processing)
		var/datum/weather/W = V
		if(W.barometer_predictable && (T.z in W.impacted_z_levels) && W.area_type == user_area.type && !(W.stage == END_STAGE))
			ongoing_weather = W
			break

	if(ongoing_weather)
		if((ongoing_weather.stage == MAIN_STAGE) || (ongoing_weather.stage == WIND_DOWN_STAGE))
			to_chat(user, "<span class='warning'>[src] can't trace anything while the storm is [ongoing_weather.stage == MAIN_STAGE ? "already here!" : "winding down."]</span>")
			return

		var/time = butchertime((ongoing_weather.next_hit_time - world.time)/10)
		to_chat(user, "<span class='notice'>The next [ongoing_weather] will hit in [round(time)] seconds.</span>")
		if(ongoing_weather.aesthetic)
			to_chat(user, "<span class='warning'>[src] says that the next storm will breeze on by.</span>")
	else if(user_area.outdoors)
		var/next_hit = SSweather.next_hit_by_zlevel["[T.z]"]
		var/fixed = next_hit ? next_hit - world.time : -1
		if(fixed < 0)
			to_chat(user, "<span class='warning'>[src] was unable to trace any weather patterns.</span>")
		else
			fixed = butchertime(round(fixed / 10))
			to_chat(user, "<span class='warning'>A storm will land in approximately [fixed] seconds.</span>")
	else
		to_chat(user, "<span class='warning'>[src] won't work indoors!</span>")
	cooldown = TRUE
	addtimer(src, /obj/item/device/barometer/proc/ping, cooldown_time)

/obj/item/device/barometer/proc/butchertime(amount)
	if(!amount)
		return
	if(accuracy)
		var/time = amount
		var/inaccurate = round(accuracy*(1/3))
		if(prob(50))
			time -= inaccurate
		if(prob(50))
			time += inaccurate
		return time
	else
		return amount


