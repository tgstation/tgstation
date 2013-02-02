//original code and idea from Alfie275 (luna era) and ISaidNo (goonservers) - with thanks




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// samples

/obj/item/weapon/rocksliver
	name = "rock sliver"
	desc = "It looks extremely delicate."
	icon = 'mining.dmi'
	icon_state = "sliver0"	//0-4
	w_class = 1
	//item_state = "electronic"
	var/source_rock = "/turf/simulated/mineral/archaeo"
	item_state = ""
	var/datum/geosample/geological_data

/obj/item/weapon/rocksliver/New()
	icon_state = "ore2"//"sliver[rand(0,4)]"




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// strange rocks

/obj/item/weapon/ore/strangerock/New()
	..()
	//var/datum/reagents/r = new/datum/reagents(50)
	//src.reagents = r
	if(rand(3))
		method = 0 // 0 = fire, 1+ = acid
	else
		method = 0 //currently always fire
		//	method = 1 //removed due to acid melting strange rocks to gooey grey -Mij
	inside = pick(150;"", 50;"/obj/item/weapon/crystal", 25;"/obj/item/weapon/talkingcrystal", "/obj/item/weapon/fossil/base")

/obj/item/weapon/ore/strangerock/bullet_act(var/obj/item/projectile/P)

/obj/item/weapon/ore/strangerock/ex_act(var/severity)
	src.visible_message("The [src] crumbles away, leaving some dust and gravel behind.")

/obj/item/weapon/ore/strangerock/attackby(obj/item/weapon/W as obj, mob/user as mob)

	if(istype(W,/obj/item/weapon/weldingtool/))
		var/obj/item/weapon/weldingtool/w = W
		if(w.isOn() && (w.get_fuel() > 3))
			if(!src.method) //0 = fire, 1+ = acid
				if(inside)
					var/obj/A = new src.inside(get_turf(src))
					for(var/mob/M in viewers(world.view, user))
						M.show_message("\blue The rock burns away revealing a [A.name].",1)
				else
					for(var/mob/M in viewers(world.view, user))
						M.show_message("\blue The rock burns away into nothing.",1)
				del src
			else
				for(var/mob/M in viewers(world.view, user))
					M.show_message("\blue A few sparks fly off the rock, but otherwise nothing else happens.",1)
		w.remove_fuel(4)

	else if(istype(W,/obj/item/device/core_sampler/))
		var/obj/item/device/core_sampler/S = W
		S.sample_item(src, user)

/*Code does not work, likely due to removal/change of acid_act proc
//Strange rocks currently melt to gooey grey w/ acid application (see reactions)
//will fix when I get a chance to fiddle with it -Mij
/obj/item/weapon/ore/strangerock/acid_act(var/datum/reagent/R)
	if(src.method)
		if(inside)
			var/obj/A = new src.inside(get_turf(src))
			for(var/mob/M in viewers(world.view, get_turf(src)))
				M.show_message("\blue The rock fizzes away revealing a [A.name].",1)
		else
			for(var/mob/M in viewers(world.view, get_turf(src)))
				M.show_message("\blue The rock fizzes away into nothing.",1)
		del src
	else
		for(var/mob/M in viewers(world.view, get_turf(src)))
			M.show_message("\blue The acid splashes harmlessly off the rock, nothing else interesting happens.",1)
	return 1
*/

/obj/item/weapon/archaeological_find
	name = "object"
	icon = 'xenoarchaeology.dmi'
	icon_state = "ano01"
	var/find_type = 0

/obj/item/weapon/archaeological_find/New()
	if(find_type < 1 || find_type > 25)
		find_type = 0
	if(!find_type)
		find_type = rand(1, 25)

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
	if(prob(90))
		switch(find_type)
			if(1)
				item_type = "bowl"
				new_item = new /obj/item/weapon/reagent_containers/glass(src.loc)
				new_item.icon = 'xenoarchaeology.dmi'
				new_item.icon_state = "bowl"
				apply_image_decorations = 1
				if(prob(20))
					additional_desc = "There appear to be [pick("dark red","dark purple","dark green","dark blue")] stains inside."
			if(2)
				item_type = "urn"
				new_item = new /obj/item/weapon/reagent_containers/glass(src.loc)
				new_item.icon = 'xenoarchaeology.dmi'
				new_item.icon_state = "urn"
				apply_image_decorations = 1
				if(prob(20))
					additional_desc = "It [pick("whispers faintly","makes a quiet roaring sound","whistles softly","thrums quietly"<"throbs")] if you put it to your ear."
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
				[pick("alien humanoid figure","rodent-like creature","reptilian alien","primate","unidentifiable object")] \
				[pick("performing unspeakable acts","posing heroically","in a feotal position","cheering","sobbing","making a plaintive gesture","making a rude gesture")]."
			if(5)
				item_type = "instrument"
				icon_state = "instrument"
				additional_desc = "[pick("You're not sure how anyone could have played this",\
				"You wonder how many mouths the creator had",\
				"You wonder what it sounds like",\
				"You wonder what kind of music was made with it")]."
				if(prob(30))
					apply_image_decorations = 1
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
				item_type = "smooth green crystal"
				additional_desc = pick("It shines faintly as it catches the light.","It appears to have a faint inner glow.","It seems to draw you inward as you look it at.","Something twinkles faintly as you look at it.","It's mesmerizing to behold.")
				icon_state = "Green lump"
				apply_material_decorations = 0
				if(prob(10))
					apply_image_decorations = 1
			if(17)
				item_type = "irregular purple crystal"
				additional_desc = pick("It shines faintly as it catches the light.","It appears to have a faint inner glow.","It seems to draw you inward as you look it at.","Something twinkles faintly as you look at it.","It's mesmerizing to behold.")
				icon_state = "Phazon"
				apply_material_decorations = 0
				if(prob(10))
					apply_image_decorations = 1
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
				//the dangerous stuff: low chance of turning up
				var/list/possible_spawns = list(/obj/item/weapon/veilrender,
				/obj/item/device/soulstone,
				/obj/item/weapon/melee/cultblade)

				var/new_type = pick(possible_spawns)
				new_item = new new_type(src.loc)
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
				var/list/possible_spawns = list()
				possible_spawns += typesof(/obj/item/weapon/stock_parts)
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

	else if(prob(40))
		apply_image_decorations = 1

	var/decorations = ""
	source_material = pick("cordite","quadrinium","steel","titanium","aluminium","ferritic-alloy","plasteel","duranium")
	if(apply_material_decorations)
		desc = "A [material_descriptor ? "[material_descriptor] " : ""][item_type] made of [source_material], all craftsmanship is of [pick("the lowest","low","average","high","the highest")] quality."

		var/list/descriptors = list()
		if(prob(30))
			descriptors.Add("is encrusted with [pick("","synthetic ","multi-faceted ","uncut ","sparkling ") + pick("rubies","emeralds","diamonds","crystals","lapiz lazuli")]")
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
			spawn(100)
				new_item.process_talking()
		del(src)

	else if(talkative)
		listening_to_players = 1
		if(prob(25))
			speaking_to_players = 1
		spawn(100)
			process_talking()

//legacy crystal
/obj/item/weapon/crystal
	name = "Crystal"
	icon = 'mining.dmi'
	icon_state = "crystal"

//large finds
				/*
				/obj/item/clothing/suit/cultrobes
				/obj/item/clothing/suit/cultrobes/alt
				/obj/item/clothing/suit/magusred
				/obj/item/clothing/suit/space/cult
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