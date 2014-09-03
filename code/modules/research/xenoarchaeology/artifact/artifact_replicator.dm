
/obj/machinery/replicator
	name = "alien machine"
	desc = "It's some kind of pod with strange wires and gadgets all over it."
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "borgcharger0(old)"
	density = 1

	idle_power_usage = 100
	active_power_usage = 1000
	use_power = 1

	var/spawn_progress = 0
	var/max_spawn_ticks = 5
	var/list/construction = list()
	var/list/spawning_types = list()

/obj/machinery/replicator/New()
	..()

	var/list/viables = list(\
	/obj/item/roller,\
	/obj/structure/closet/crate,\
	/obj/structure/closet/acloset,\
	/mob/living/simple_animal/hostile/mimic,\
	/mob/living/simple_animal/hostile/viscerator,\
	/mob/living/simple_animal/hostile/hivebot,\
	/obj/item/device/analyzer,\
	/obj/item/device/camera,\
	/obj/item/device/flash,\
	/obj/item/device/flashlight,\
	/obj/item/device/healthanalyzer,\
	/obj/item/device/multitool,\
	/obj/item/device/paicard,\
	/obj/item/device/radio,\
	/obj/item/device/radio/headset,\
	/obj/item/device/radio/beacon,\
	/obj/item/weapon/autopsy_scanner,\
	/obj/item/weapon/bikehorn,\
	/obj/item/weapon/bonesetter,\
	/obj/item/weapon/butch,\
	/obj/item/weapon/caution,\
	/obj/item/weapon/caution/cone,\
	/obj/item/weapon/crowbar,\
	/obj/item/weapon/clipboard,\
	/obj/item/weapon/cell,\
	/obj/item/weapon/circular_saw,\
	/obj/item/weapon/hatchet,\
	/obj/item/weapon/handcuffs,\
	/obj/item/weapon/hemostat,\
	/obj/item/weapon/kitchenknife,\
	/obj/item/weapon/lighter,\
	/obj/item/weapon/lighter,\
	/obj/item/weapon/light/bulb,\
	/obj/item/weapon/light/tube,\
	/obj/item/weapon/pickaxe,\
	/obj/item/weapon/shovel,\
	/obj/item/weapon/table_parts,\
	/obj/item/weapon/weldingtool,\
	/obj/item/weapon/wirecutters,\
	/obj/item/weapon/wrench,\
	/obj/item/weapon/screwdriver,\
	/obj/item/weapon/grenade/chem_grenade/cleaner,\
	/obj/item/weapon/grenade/chem_grenade/metalfoam\
	)

	var/quantity = rand(5,15)
	for(var/i=0, i<quantity, i++)
		var/button_desc = "[pick("a yellow","a purple","a green","a blue","a red","an orange","a white")], "
		button_desc += "[pick("round","square","diamond","heart","dog","human")] shaped "
		button_desc += "[pick("toggle","switch","lever","button","pad","hole")]"
		var/type = pick(viables)
		viables.Remove(type)
		construction[button_desc] = type

/obj/machinery/replicator/process()
	if(spawning_types.len && powered())
		spawn_progress++
		if(spawn_progress > max_spawn_ticks)
			src.visible_message("\blue \icon[src] [src] pings!")
			var/spawn_type = spawning_types[1]
			new spawn_type(src.loc)

			spawning_types.Remove(spawning_types[1])
			spawn_progress = 0
			max_spawn_ticks = rand(5,30)

			if(!spawning_types.len)
				use_power = 1
				icon_state = "borgcharger0(old)"

		else if(prob(5))
			src.visible_message("\blue \icon[src] [src] [pick("clicks","whizzes","whirrs","whooshes","clanks","clongs","clonks","bangs")].")

/obj/machinery/replicator/attack_hand(mob/user as mob)
	interact(user)

/obj/machinery/replicator/interact(mob/user)
	var/dat = "The control panel displays an incomprehensible selection of controls, many with unusual markings or text around them.<br>"
	dat += "<br>"
	for(var/index=1, index<=construction.len, index++)
		dat += "<A href='?src=\ref[src];activate=[index]'>\[[construction[index]]\]</a><br>"

	user << browse(dat, "window=alien_replicator")

/obj/machinery/replicator/Topic(href, href_list)

	if(href_list["activate"])
		var/index = text2num(href_list["activate"])
		if(index > 0 && index <= construction.len)
			if(spawning_types.len)
				src.visible_message("\blue \icon[src] a [pick("light","dial","display","meter","pad")] on [src]'s front [pick("blinks","flashes")] [pick("red","yellow","blue","orange","purple","green","white")].")
			else
				src.visible_message("\blue \icon[src] [src]'s front compartment slides shut.")

			spawning_types.Add(construction[construction[index]])
			spawn_progress = 0
			use_power = 2
			icon_state = "borgcharger1(old)"
