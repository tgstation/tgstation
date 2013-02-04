//original code and idea from Alfie275 (luna era) and ISaidNo (goonservers) - with thanks

#define ARCHAEO_BOWL 1
#define ARCHAEO_URN 2
#define ARCHAEO_CUTLERY 3
#define ARCHAEO_STATUETTE 4
#define ARCHAEO_INSTRUMENT 5
#define ARCHAEO_KNIFE 6
#define ARCHAEO_COIN 7
#define ARCHAEO_HANDCUFFS 8
#define ARCHAEO_BEARTRAP 9
#define ARCHAEO_LIGHTER 10
#define ARCHAEO_BOX 11
#define ARCHAEO_GASTANK 12
#define ARCHAEO_TOOL 13
#define ARCHAEO_METAL 14
#define ARCHAEO_PEN 15
#define ARCHAEO_CRYSTAL 16
#define ARCHAEO_CULTBLADE 17
#define ARCHAEO_TELEBEACON 18
#define ARCHAEO_CLAYMORE 19
#define ARCHAEO_CULTROBES 20
#define ARCHAEO_SOULSTONE 21
#define ARCHAEO_SHARD 22
#define ARCHAEO_RODS 23
#define ARCHAEO_STOCKPARTS 24
#define ARCHAEO_KATANA 25
#define ARCHAEO_LASER 26
#define ARCHAEO_GUN 27
#define ARCHAEO_UNKNOWN 28
#define ARCHAEO_FOSSIL 29
#define ARCHAEO_SHELL 30
#define ARCHAEO_PLANT 31
//alien remains
//plant remains
//eggs
//droppings
//footprints
//alien clothing

//DNA sampling from fossils, or a new archaeo type specifically for it?

//descending order of likeliness to spawn
#define DIGSITE_GARDEN 1
#define DIGSITE_ANIMAL 2
#define DIGSITE_HOUSE 3
#define DIGSITE_TECHNICAL 4
#define DIGSITE_TEMPLE 5
#define DIGSITE_WAR 6

//see /turf/simulated/mineral/New() in code/modules/mining/mine_turfs.dm
/proc/get_random_digsite_type()
	return pick(100;DIGSITE_GARDEN,90;DIGSITE_ANIMAL,80;DIGSITE_HOUSE,70;DIGSITE_TECHNICAL,60;DIGSITE_TEMPLE,50;DIGSITE_WAR)

/proc/get_random_find_type(var/digsite)

	var/find_type = 0
	switch(digsite)
		if(DIGSITE_GARDEN)
			find_type = pick(\
			100;ARCHAEO_PLANT,\
			25;ARCHAEO_SHELL,\
			25;ARCHAEO_FOSSIL,\
			5;ARCHAEO_BEARTRAP\
			)
		if(DIGSITE_ANIMAL)
			find_type = pick(\
			100;ARCHAEO_FOSSIL,\
			25;ARCHAEO_SHELL,\
			25;ARCHAEO_PLANT,\
			25;ARCHAEO_BEARTRAP\
			)
		if(DIGSITE_HOUSE)
			find_type = pick(\
			100;ARCHAEO_UNKNOWN,\
			100;ARCHAEO_BOWL,\
			100;ARCHAEO_URN,\
			100;ARCHAEO_CUTLERY,\
			100;ARCHAEO_STATUETTE,\
			100;ARCHAEO_INSTRUMENT,\
			100;ARCHAEO_PEN,\
			100;ARCHAEO_LIGHTER,\
			100;ARCHAEO_BOX,\
			75;ARCHAEO_COIN,\
			50;ARCHAEO_SHARD,\
			50;ARCHAEO_RODS,\
			25;ARCHAEO_METAL\
			)
		if(DIGSITE_TECHNICAL)
			find_type = pick(\
			100;ARCHAEO_UNKNOWN,\
			100;ARCHAEO_METAL,\
			100;ARCHAEO_GASTANK,\
			100;ARCHAEO_TELEBEACON,\
			100;ARCHAEO_TOOL,\
			100;ARCHAEO_STOCKPARTS,\
			75;ARCHAEO_SHARD,\
			75;ARCHAEO_RODS,\
			50;ARCHAEO_HANDCUFFS,\
			50;ARCHAEO_BEARTRAP\
			)
		if(DIGSITE_TEMPLE)
			find_type = pick(\
			200;ARCHAEO_CULTROBES,\
			100;ARCHAEO_UNKNOWN,\
			100;ARCHAEO_URN,\
			100;ARCHAEO_BOWL,\
			100;ARCHAEO_KNIFE,\
			100;ARCHAEO_CRYSTAL,\
			75;ARCHAEO_CULTBLADE,\
			50;ARCHAEO_SOULSTONE,\
			25;ARCHAEO_HANDCUFFS,\
			25;ARCHAEO_BEARTRAP,\
			10;ARCHAEO_KATANA,\
			10;ARCHAEO_CLAYMORE,\
			10;ARCHAEO_SHARD,\
			10;ARCHAEO_RODS,\
			10;ARCHAEO_METAL\
			)
		if(DIGSITE_WAR)
			find_type = pick(\
			100;ARCHAEO_UNKNOWN,\
			100;ARCHAEO_GUN,\
			100;ARCHAEO_KNIFE,\
			75;ARCHAEO_LASER,\
			75;ARCHAEO_KATANA,\
			75;ARCHAEO_CLAYMORE,\
			50;ARCHAEO_CULTROBES,\
			50;ARCHAEO_CULTBLADE,\
			25;ARCHAEO_HANDCUFFS,\
			25;ARCHAEO_BEARTRAP,\
			25;ARCHAEO_TOOL\
			)
	return find_type

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Xenoarchaeological finds

datum/find
	var/find_type = 0
	var/excavation_required = 0
	var/view_range = 15			//how close excavation has to come to show an overlay on the turf
	var/destruct_range = 2		//how much excavation has to overshoot by to destroy the item
	var/clearance_range= 2		//how close excavation has to come to extract the whole ore instead of just the item inside
								//if excavation hits var/excavation_required exactly, it's contained find is extracted cleanly without the ore

datum/find/New(var/digsite, var/exc_req)
	excavation_required = exc_req
	find_type = get_random_find_type(digsite)

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Rock sliver

/obj/item/weapon/rocksliver
	name = "rock sliver"
	desc = "It looks extremely delicate."
	icon = 'xenoarchaeology.dmi'
	icon_state = "sliver1"	//0-4
	w_class = 1
	//item_state = "electronic"
	var/source_rock = "/turf/simulated/mineral/"
	var/datum/geosample/geological_data

/obj/item/weapon/rocksliver/New()
	icon_state = "sliver[rand(1,3)]"
	pixel_x = rand(0,16)-8
	pixel_y = rand(0,8)-8

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Strange rocks

/obj/item/weapon/ore/strangerock
	name = "Strange rock"
	desc = "Seems to have some unusal strata evident throughout it."
	icon = 'xenoarchaeology.dmi'
	icon_state = "strange"
	var/obj/item/weapon/inside
	var/method = 0// 0 = fire, 1 = brush, 2 = pick
	origin_tech = "materials=5"

/obj/item/weapon/ore/strangerock/New(var/item_type = 0)
	..()
	method = rand(0,2)
	if(item_type)
		inside = new/obj/item/weapon/archaeological_find(src, item_type)

/*/obj/item/weapon/ore/strangerock/ex_act(var/severity)
	if(severity && prob(30))
		src.visible_message("The [src] crumbles away, leaving some dust and gravel behind.")*/

/obj/item/weapon/ore/strangerock/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/weldingtool/))
		var/obj/item/weapon/weldingtool/w = W
		if(w.isOn())
			if(w.get_fuel() >= 4 && !src.method)
				if(inside)
					inside.loc = src.loc
					for(var/mob/M in viewers(world.view, user))
						M.show_message("<span class='info'>[src] burns away revealing [inside].</span>",1)
				else
					for(var/mob/M in viewers(world.view, user))
						M.show_message("<span class='info'>[src] burns away into nothing.</span>",1)
				del(src)
				w.remove_fuel(4)
			else
				for(var/mob/M in viewers(world.view, user))
					M.show_message("<span class='info'>A few sparks fly off [src], but nothing else happens.</span>",1)
				w.remove_fuel(1)
			return

	else if(istype(W,/obj/item/device/core_sampler/))
		var/obj/item/device/core_sampler/S = W
		S.sample_item(src, user)
		return

	..()
	if(prob(33))
		src.visible_message("<span class='warning'>[src] crumbles away, leaving some dust and gravel behind.</span>")
		del(src)

/obj/item/weapon/archaeological_find
	name = "object"
	icon = 'xenoarchaeology.dmi'
	icon_state = "ano01"
	var/find_type = 0

/obj/item/weapon/archaeological_find/New(var/new_item_type)

	if(new_item_type)
		find_type = new_item_type
	else
		find_type = get_random_find_type(0)

	var/item_type = "object"
	icon_state = "unknown[rand(1,4)]"
	var/additional_desc = ""
	var/obj/item/weapon/new_item
	var/source_material = ""
	var/apply_material_decorations = 1
	var/apply_image_decorations = 0
	var/material_descriptor = ""
	if(prob(40))
		material_descriptor = pick("rusted ","dusty ","archaic ","fragile ")
	source_material = pick("cordite","quadrinium","steel","titanium","aluminium","ferritic-alloy","plasteel","duranium")

	var/talkative = 0
	if(prob(5))
		talkative = 1

	//for all items here:
	//icon_state
	//item_state
	switch(find_type)
		if(1)
			item_type = "bowl"
			new_item = new /obj/item/weapon/reagent_containers/glass(src.loc)
			new_item.icon = 'xenoarchaeology.dmi'
			new_item.icon_state = "bowl"
			apply_image_decorations = 1
			if(prob(20))
				additional_desc = "There appear to be [pick("dark","faintly glowing","pungent")] [pick("red","purple","green","blue")] stains inside."
		if(2)
			item_type = "urn"
			new_item = new /obj/item/weapon/reagent_containers/glass(src.loc)
			new_item.icon = 'xenoarchaeology.dmi'
			new_item.icon_state = "urn"
			apply_image_decorations = 1
			if(prob(20))
				additional_desc = "It [pick("whispers faintly","makes a quiet roaring sound","whistles softly","thrums quietly","throbs")] if you put it to your ear."
		if(3)
			item_type = "[pick("fork","spoon","knife")]"
			if(prob(25))
				new_item = new /obj/item/weapon/kitchen/utensil/fork(src.loc)
			else if(prob(50))
				new_item = new /obj/item/weapon/kitchen/utensil/knife(src.loc)
			else
				new_item = new /obj/item/weapon/kitchen/utensil/spoon(src.loc)
			additional_desc = "[pick("It's like no [item_type] you've ever seen before",\
			"It's a mystery how anyone is supposed to eat with this",\
			"You wonder what the creator's mouth was shaped like")]."
		if(4)
			item_type = "statuette"
			icon_state = "statuette"
			additional_desc = "It depicts a [pick("small","ferocious","wild","pleasing","hulking")] \
			[pick("alien figure","rodent-like creature","reptilian alien","primate","unidentifiable object")] \
			[pick("performing unspeakable acts","posing heroically","in a feotal position","cheering","sobbing","making a plaintive gesture","making a rude gesture")]."
		if(5)
			item_type = "instrument"
			icon_state = "instrument"
			if(prob(30))
				apply_image_decorations = 1
				additional_desc = "[pick("You're not sure how anyone could have played this",\
				"You wonder how many mouths the creator had",\
				"You wonder what it sounds like",\
				"You wonder what kind of music was made with it")]."
		if(6)
			item_type = "[pick("bladed knife","serrated blade","sharp cutting implement")]"
			new_item = new /obj/item/weapon/kitchenknife(src.loc)
			additional_desc = "[pick("It doesn't look safe.",\
			"It looks wickedly jagged",\
			"There appear to be [pick("dark red","dark purple","dark green","dark blue")] stains along the edges")]."
		if(7)
			//assuming there are 10 types of coins
			var/chance = 10
			for(var/type in typesof(/obj/item/weapon/coin))
				if(prob(chance))
					new_item = new type(src.loc)
					break
				chance += 10

			item_type = new_item.name
			apply_material_decorations = 0
			apply_image_decorations = 1
		if(8)
			item_type = "chained loops"
			new_item = new /obj/item/weapon/handcuffs(src.loc)
			additional_desc = "[pick("They appear to be for securing two things together","Looks kinky","Doesn't seem like a children's toy")]."
		if(9)
			item_type = "[pick("wicked","evil","byzantine","dangerous")] looking [pick("device","contraption","thing","trap")]"
			new_item = new /obj/item/weapon/legcuffs/beartrap(src.loc)
			additional_desc = "[pick("It looks like it could take a limb off",\
			"Could be some kind of animal trap",\
			"There appear to be [pick("dark red","dark purple","dark green","dark blue")] stains along part of it")]."
		if(10)
			item_type = "small [pick("cylinder","tank","chamber")]"
			new_item = new /obj/item/weapon/lighter(src.loc)
			additional_desc = "There is a tiny device attached."
			if(prob(30))
				apply_image_decorations = 1
		if(11)
			item_type = "box"
			new_item = new /obj/item/weapon/storage/box(src.loc)
			new_item.icon = 'xenoarchaeology.dmi'
			new_item.icon_state = "box"
			if(prob(30))
				apply_image_decorations = 1
		if(12)
			item_type = "[pick("cylinder","tank","chamber")]"
			if(prob(25))
				new_item = new /obj/item/weapon/tank/air(src.loc)
			else if(prob(50))
				new_item = new /obj/item/weapon/tank/anesthetic(src.loc)
			else
				new_item = new /obj/item/weapon/tank/plasma(src.loc)
			icon_state = pick("oxygen","oxygen_fr","oxygen_f","plasma","anesthetic")
			additional_desc = "It [pick("gloops","sloshes")] slightly when you shake it."
		if(13)
			item_type = "strange tool"
			if(prob(25))
				new_item = new /obj/item/weapon/wrench(src.loc)
			else if(prob(25))
				new_item = new /obj/item/weapon/crowbar(src.loc)
			else
				new_item = new /obj/item/weapon/screwdriver(src.loc)
			additional_desc = "[pick("It doesn't look safe.",\
			"You wonder what it was used for",\
			"There appear to be [pick("dark red","dark purple","dark green","dark blue")] stains on it")]."
		if(14)
			apply_material_decorations = 0
			var/list/possible_spawns = list()
			possible_spawns += /obj/item/stack/sheet/metal
			possible_spawns += /obj/item/stack/sheet/plasteel
			possible_spawns += /obj/item/stack/sheet/glass
			possible_spawns += /obj/item/stack/sheet/rglass
			possible_spawns += /obj/item/stack/sheet/mineral/plasma
			possible_spawns += /obj/item/stack/sheet/mineral/mythril
			possible_spawns += /obj/item/stack/sheet/mineral/gold
			possible_spawns += /obj/item/stack/sheet/mineral/silver
			possible_spawns += /obj/item/stack/sheet/mineral/enruranium
			possible_spawns += /obj/item/stack/sheet/mineral/sandstone
			possible_spawns += /obj/item/stack/sheet/mineral/silver

			var/new_type = pick(possible_spawns)
			new_item = new new_type(src.loc)
			new_item:amount = rand(5,45)
			del(src)
			return	//nothing fancy here
		if(15)
			if(prob(75))
				new_item = new /obj/item/weapon/pen(src.loc)
			else
				new_item = new /obj/item/weapon/pen/sleepypen(src.loc)
			if(prob(30))
				apply_image_decorations = 1
		if(16)
			if(prob(50))
				item_type = "smooth green crystal"
				icon_state = "Green lump"
			else
				item_type = "irregular purple crystal"
				icon_state = "Phazon"
			additional_desc = pick("It shines faintly as it catches the light.","It appears to have a faint inner glow.","It seems to draw you inward as you look it at.","Something twinkles faintly as you look at it.","It's mesmerizing to behold.")

			apply_material_decorations = 0
			if(prob(10))
				apply_image_decorations = 1
		if(17)
			//cultblade
			new /obj/item/weapon/melee/cultblade(src.loc)
			del(src)
			return
		if(18)
			new_item = new /obj/item/device/radio/beacon(src.loc)
			talkative = 0
			new_item.icon_state = "unknown[rand(1,4)]"
			new_item.icon = 'xenoarchaeology.dmi'
			new_item.desc = ""
		if(19)
			new_item = new /obj/item/weapon/claymore(src.loc)
			name = new_item.name
			desc = new_item.desc
			apply_material_decorations = 0
		if(20)
			//arcane clothing
			var/list/possible_spawns = list(/obj/item/clothing/head/culthood,
			/obj/item/clothing/head/magus,
			/obj/item/clothing/head/culthood/alt,
			/obj/item/clothing/head/helmet/space/cult)

			var/new_type = pick(possible_spawns)
			new_item = new new_type(src.loc)
			del(src)
			return
		if(21)
			//soulstone
			new_item = new /obj/item/device/soulstone(src.loc)
			del(src)
			return
		if(22)
			new_item = new /obj/item/weapon/shard(src.loc)
			del(src)
			return
		if(23)
			new_item = new /obj/item/stack/rods(src.loc)
			del(src)
			return
		if(24)
			var/list/possible_spawns = typesof(/obj/item/weapon/stock_parts)
			possible_spawns -= /obj/item/weapon/stock_parts
			possible_spawns -= /obj/item/weapon/stock_parts/subspace

			var/new_type = pick(possible_spawns)
			new_item = new new_type(src.loc)
			del(src)
			return
		if(25)
			new_item = new /obj/item/weapon/katana(src.loc)
			name = new_item.name
			desc = new_item.desc
			apply_material_decorations = 0
		if(26)
			//energy gun
			var/spawn_type = pick(\
			/obj/item/weapon/gun/energy/laser/practice;100,\
			/obj/item/weapon/gun/energy/laser;75,\
			/obj/item/weapon/gun/energy/xray;50,\
			/obj/item/weapon/gun/energy/laser/captain;25,\
			)
			var/obj/item/weapon/gun/energy/new_gun = new spawn_type(src.loc)
			new_item = new_gun
			new_item.icon_state = "egun[rand(1,6)]"

			//5% chance to explode when first fired
			//10% chance to have an unchargeable cell
			//15% chance to gain a random amount of starting energy, otherwise start with an empty cell
			if(prob(5))
				new_gun.power_supply.rigged = 1
			if(prob(10))
				new_gun.power_supply.maxcharge = 0
			if(prob(15))
				new_gun.power_supply.charge = rand(0, new_gun.power_supply.maxcharge)
			else
				new_gun.power_supply.charge = 0

			name = new_item.name
			desc = new_item.desc
		if(27)
			//revolver
			var/obj/item/weapon/gun/projectile/new_gun = new (src.loc)
			new_item = new_gun
			new_item.icon_state = "gun[rand(1,4)]"

			//33% chance to be able to reload the gun with human ammunition
			if(prob(66))
				new_gun.caliber = "999"

			//33% chance to fill it with a random amount of bullets
			new_gun.max_shells = rand(1,12)
			if(prob(33))
				var/num_bullets = rand(1,new_gun.max_shells)
				if(num_bullets < new_gun.loaded.len)
					for(var/i = num_bullets, i <= new_gun.loaded.len, i++)
						new_gun.loaded += new new_gun.ammo_type(src)
				else
					for(var/obj/item/I in new_gun)
						if(new_gun.loaded.len > num_bullets)
							if(I in new_gun.loaded)
								new_gun.loaded.Remove(I)
								I.loc = null
						else
							break
			else
				for(var/obj/item/I in new_gun)
					if(I in new_gun.loaded)
						new_gun.loaded.Remove(I)
						I.loc = null

			name = new_item.name
			desc = new_item.desc
		if(28)
			//completely unknown alien device
			if(prob(40))
				apply_image_decorations = 0
		if(29)
			//fossil bone/skull
			new/obj/item/weapon/fossil/base(src.loc)
			del(src)
			return
		if(30)
			//fossil shell
			new/obj/item/weapon/fossil/base(src.loc)
			del(src)
			return
		if(30)
			//fossil plant
			new/obj/item/weapon/fossil/base(src.loc)
			del(src)
			return

	var/decorations = ""
	if(apply_material_decorations)
		source_material = pick("cordite","quadrinium","steel","titanium","aluminium","ferritic-alloy","plasteel","duranium")
		desc = "A [material_descriptor ? "[material_descriptor] " : ""][item_type] made of [source_material], all craftsmanship is of [pick("the lowest","low","average","high","the highest")] quality."

		var/list/descriptors = list()
		if(prob(30))
			descriptors.Add("is encrusted with [pick("","synthetic ","multi-faceted ","uncut ","sparkling ") + pick("rubies","emeralds","diamonds","opals","lapiz lazuli")]")
		if(prob(30))
			descriptors.Add("is studded with [pick("gold","silver","aluminium","titanium")]")
		if(prob(30))
			descriptors.Add("is encircled with bands of [pick("quadrinium","cordite","ferritic-alloy","plasteel","duranium")]")
		if(prob(30))
			descriptors.Add("menaces with spikes of [pick("solid plasma","uranium","white pearl","black steel")]")
		if(descriptors.len > 0)
			decorations = "It "
			for(var/index=1, index <= descriptors.len, index++)
				if(index > 1)
					if(index == descriptors.len)
						decorations += " and "
					else
						decorations += ", "
				decorations += descriptors[index]
			decorations += "."
		if(decorations)
			desc += " " + decorations

	var/engravings = ""
	if(apply_image_decorations)
		engravings = "[pick("Engraved","Carved","Etched")] on the item is [pick("an image of","a frieze of","a depiction of")] \
		[pick("an alien humanoid","an amorphic blob","a short, hairy being","a rodent-like creature","a robot","a primate","a reptilian alien","an unidentifiable object","a statue","a starship","unusual devices","a structure")] \
		[pick("surrounded by","being held aloft by","being struck by","being examined by","communicating with")] \
		[pick("alien humanoids","amorphic blobs","short, hairy beings","rodent-like creatures","robots","primates","reptilian aliens")]"
		if(prob(50))
			engravings += ", [pick("they seem to be enjoying themselves","they seem extremely angry","they look pensive","they are making gestures of supplication","the scene is one of subtle horror","the scene conveys a sense of desperation","the scene is completely bizarre")]"
		engravings += "."

		if(desc)
			desc += " "
		desc += engravings

	name = "[item_type]"
	if(desc)
		desc += " "
	desc += additional_desc
	if(!desc)
		desc = "This item is completely [pick("alien","bizarre")]."

	//icon and icon_state should have already been set
	if(new_item)
		new_item.name = src.name
		new_item.desc = src.desc

		if(talkative)
			new_item.listening_to_players = 1
			if(prob(25))
				new_item.speaking_to_players = 1
				processing_objects.Add(src)
		del(src)

	else if(talkative)
		listening_to_players = 1
		if(prob(25))
			speaking_to_players = 1
			processing_objects.Add(src)

//legacy crystal
/obj/item/weapon/crystal
	name = "Crystal"
	icon = 'mining.dmi'
	icon_state = "crystal"

//large finds
				/*
				/obj/machinery/syndicate_beacon
				/obj/machinery/wish_granter
			if(18)
				item_type = "jagged green crystal"
				additional_desc = pick("It shines faintly as it catches the light.","It appears to have a faint inner glow.","It seems to draw you inward as you look it at.","Something twinkles faintly as you look at it.","It's mesmerizing to behold.")
				icon_state = "crystal"
				apply_material_decorations = 0
				if(prob(10))
					apply_image_decorations = 1
			if(19)
				item_type = "jagged pink crystal"
				additional_desc = pick("It shines faintly as it catches the light.","It appears to have a faint inner glow.","It seems to draw you inward as you look it at.","Something twinkles faintly as you look at it.","It's mesmerizing to behold.")
				icon_state = "crystal2"
				apply_material_decorations = 0
				if(prob(10))
					apply_image_decorations = 1
				*/
			//machinery type artifacts?