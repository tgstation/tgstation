#define OXY_CANDLE_RELEASE_TEMP (T20C + 10) // 30 celsius, it's hot. Will be even hotter with hotspot expose

/obj/item/oxygen_candle
	name = "oxygen candle"
	desc = "A steel tube with the words 'OXYGEN - PULL CORD TO IGNITE' stamped on the side.\nA small label reads <span class='warning'>'WARNING: NOT FOR LIGHTING USE. WILL IGNITE FLAMMABLE GASSES'</span>"
	icon = 'modular_doppler/modular_items/icons/oxygen_candle.dmi'
	icon_state = "oxycandle"
	w_class = WEIGHT_CLASS_SMALL
	light_color = LIGHT_COLOR_LAVA // Very warm chemical burn
	var/pulled = FALSE
	var/processing = FALSE
	var/processes_left = 40

/obj/item/oxygen_candle/attack_self(mob/user)
	if(!pulled)
		playsound(src, 'sound/effects/fuse.ogg', 75, 1)
		balloon_alert(user, "cord pulled")
		icon_state = "oxycandle_burning"
		pulled = TRUE
		processing = TRUE
		START_PROCESSING(SSobj, src)
		set_light(2)

/obj/item/oxygen_candle/process()
	var/turf/pos = get_turf(src)
	if(!pos)
		return
	pos.hotspot_expose(500, 100)
	pos.atmos_spawn_air("o2=5;TEMP=[OXY_CANDLE_RELEASE_TEMP]")
	processes_left--
	if(processes_left <= 0)
		set_light(0)
		STOP_PROCESSING(SSobj, src)
		processing = FALSE
		name = "burnt oxygen candle"
		icon_state = "oxycandle_burnt"
		desc += "\nThis tube has exhausted its chemicals."

/obj/item/oxygen_candle/Destroy()
	if(processing)
		STOP_PROCESSING(SSobj, src)
	return ..()

#undef OXY_CANDLE_RELEASE_TEMP

/obj/item/grenade/chem_grenade/budget_smart_metal
	name = "budget smart metal foam grenade"
	desc = "Used for emergency sealing of hull breaches, while keeping areas accessible. This one came in a bulk pack a few years ago, and some of the ingredients have gone flat."
	stage = GRENADE_READY

/obj/item/grenade/chem_grenade/budget_smart_metal/Initialize(mapload)
	. = ..()
	var/obj/item/reagent_containers/cup/beaker/large/beaker_one = new(src)
	var/obj/item/reagent_containers/cup/beaker/beaker_two = new(src)

	beaker_one.reagents.add_reagent(/datum/reagent/aluminium, 50)
	beaker_two.reagents.add_reagent(/datum/reagent/smart_foaming_agent, 15)
	beaker_two.reagents.add_reagent(/datum/reagent/toxin/acid/fluacid, 15)

	beakers += beaker_one
	beakers += beaker_two
