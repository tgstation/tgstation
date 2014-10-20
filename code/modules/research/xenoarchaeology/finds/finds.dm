//original code and idea from Alfie275 (luna era) and ISaidNo (goonservers) - with thanks

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Xenoarchaeological finds

/datum/find
	var/find_type = 0				//random according to the digsite type
	var/excavation_required = 0		//random 5-95%
	var/view_range = 20				//how close excavation has to come to show an overlay on the turf
	var/clearance_range = 3			//how close excavation has to come to extract the item
									//if excavation hits var/excavation_required exactly, it's contained find is extracted cleanly without the ore
	var/prob_delicate = 90			//probability it requires an active suspension field to not insta-crumble
	var/dissonance_spread = 1		//proportion of the tile that is affected by this find
									//used in conjunction with analysis machines to determine correct suspension field type

/datum/find/New(var/digsite, var/exc_req)
	excavation_required = exc_req
	find_type = get_random_find_type(digsite)
	clearance_range = rand(2,6)
	dissonance_spread = rand(1500,2500) / 100

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Strange rocks

//have all strange rocks be cleared away using welders for now
/obj/item/weapon/ore/strangerock
	name = "Strange rock"
	desc = "Seems to have some unusal strata evident throughout it."
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "strange"
	var/obj/item/weapon/inside
	var/method = 0// 0 = fire, 1 = brush, 2 = pick
	origin_tech = "materials=5"

/obj/item/weapon/ore/strangerock/New(loc, var/inside_item_type = 0)
	..(loc)

	//method = rand(0,2)
	if(inside_item_type)
		inside = new/obj/item/weapon/archaeological_find(src, new_item_type = inside_item_type)
		if(!inside)
			inside = locate() in contents

/*/obj/item/weapon/ore/strangerock/ex_act(var/severity)
	if(severity && prob(30))
		src.visible_message("The [src] crumbles away, leaving some dust and gravel behind.")*/

/obj/item/weapon/ore/strangerock/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/weldingtool/))
		var/obj/item/weapon/weldingtool/w = W
		if(w.isOn())
			if(w.get_fuel() >= 4 && !src.method)
				if(inside)
					inside.loc = get_turf(src)
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

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Archaeological finds

/obj/item/weapon/archaeological_find
	name = "object"
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "ano01"
	var/find_type = 0

/obj/item/weapon/archaeological_find/New(loc, var/new_item_type)
	if(new_item_type)
		find_type = new_item_type
	else
		find_type = rand(1,34)	//update this when you add new find types

	var/item_type = "object"
	icon_state = "unknown[rand(1,4)]"
	var/additional_desc = ""
	var/obj/item/weapon/new_item
	var/source_material = ""
	var/apply_material_decorations = 1
	var/apply_image_decorations = 0
	var/material_descriptor = ""
	var/apply_prefix = 1
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
			new_item.icon = 'icons/obj/xenoarchaeology.dmi'
			new_item.icon_state = "bowl"
			apply_image_decorations = 1
			if(prob(20))
				additional_desc = "There appear to be [pick("dark","faintly glowing","pungent","bright")] [pick("red","purple","green","blue")] stains inside."
		if(2)
			item_type = "urn"
			new_item = new /obj/item/weapon/reagent_containers/glass(src.loc)
			new_item.icon = 'icons/obj/xenoarchaeology.dmi'
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
			[pick("performing unspeakable acts","posing heroically","in a fetal position","cheering","sobbing","making a plaintive gesture","making a rude gesture")]."
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
			apply_prefix = 0
			apply_material_decorations = 0
			apply_image_decorations = 1
		if(8)
			item_type = "handcuffs"
			new_item = new /obj/item/weapon/handcuffs(src.loc)
			additional_desc = "[pick("They appear to be for securing two things together","Looks kinky","Doesn't seem like a children's toy")]."
		if(9)
			item_type = "[pick("wicked","evil","byzantine","dangerous")] looking [pick("device","contraption","thing","trap")]"
			apply_prefix = 0
			new_item = new /obj/item/weapon/legcuffs/beartrap(src.loc)
			additional_desc = "[pick("It looks like it could take a limb off",\
			"Could be some kind of animal trap",\
			"There appear to be [pick("dark red","dark purple","dark green","dark blue")] stains along part of it")]."
		if(10)
			item_type = "[pick("cylinder","tank","chamber")]"
			new_item = new /obj/item/weapon/lighter(src.loc)
			additional_desc = "There is a tiny device attached."
			if(prob(30))
				apply_image_decorations = 1
		if(11)
			item_type = "box"
			new_item = new /obj/item/weapon/storage/box(src.loc)
			new_item.icon = 'icons/obj/xenoarchaeology.dmi'
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
			item_type = "tool"
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
			new_item = new new_type(get_turf(src))
			new_item:amount = rand(5,45)
		if(15)
			if(prob(75))
				new_item = new /obj/item/weapon/pen(src.loc)
			else
				new_item = new /obj/item/weapon/pen/sleepypen(src.loc)
			if(prob(30))
				apply_image_decorations = 1
		if(16)
			apply_prefix = 0
			if(prob(25))
				item_type = "smooth green crystal"
				icon_state = "Green lump"
			else if(prob(33))
				item_type = "irregular purple crystal"
				icon_state = "Phazon"
			else if(prob(50))
				item_type = "rough red crystal"
				icon_state = "changerock"
			else
				item_type = "smooth red crystal"
				icon_state = "ore"
			additional_desc = pick("It shines faintly as it catches the light.","It appears to have a faint inner glow.","It seems to draw you inward as you look it at.","Something twinkles faintly as you look at it.","It's mesmerizing to behold.")

			apply_material_decorations = 0
			if(prob(10))
				apply_image_decorations = 1
		if(17)
			//cultblade
			apply_prefix = 0
			new_item = new /obj/item/weapon/melee/cultblade(src.loc)
			apply_material_decorations = 0
			apply_image_decorations = 0
		if(18)
			new_item = new /obj/item/device/radio/beacon(src.loc)
			talkative = 0
			new_item.icon_state = "unknown[rand(1,4)]"
			new_item.icon = 'icons/obj/xenoarchaeology.dmi'
			new_item.desc = ""
		if(19)
			apply_prefix = 0
			new_item = new /obj/item/weapon/claymore(src.loc)
			new_item.force = 10
			item_type = new_item.name
		if(20)
			//arcane clothing
			apply_prefix = 0
			var/list/possible_spawns = list(/obj/item/clothing/head/culthood,
			/obj/item/clothing/head/magus,
			/obj/item/clothing/head/culthood/alt,
			/obj/item/clothing/head/helmet/space/cult)

			var/new_type = pick(possible_spawns)
			new_item = new new_type(src.loc)
		if(21)
			//soulstone
			apply_prefix = 0
			new_item = new /obj/item/device/soulstone(src.loc)
			item_type = new_item.name
			apply_material_decorations = 0
		if(22)
			if(prob(50))
				new_item = getFromPool(/obj/item/weapon/shard, loc)
			else
				new_item = getFromPool(/obj/item/weapon/shard/plasma, loc)

			apply_prefix = 0
			apply_image_decorations = 0
			apply_material_decorations = 0
		if(23)
			apply_prefix = 0
			new_item = new /obj/item/stack/rods(src.loc)
			apply_image_decorations = 0
			apply_material_decorations = 0
		if(24)
			var/list/possible_spawns = typesof(/obj/item/weapon/stock_parts)
			possible_spawns -= /obj/item/weapon/stock_parts
			possible_spawns -= /obj/item/weapon/stock_parts/subspace

			var/new_type = pick(possible_spawns)
			new_item = new new_type(src.loc)
			item_type = new_item.name
			apply_material_decorations = 0
		if(25)
			apply_prefix = 0
			new_item = new /obj/item/weapon/katana(src.loc)
			new_item.force = 10
			item_type = new_item.name
		if(26)
			//energy gun
			var/spawn_type = pick(\
			/obj/item/weapon/gun/energy/laser/practice,\
			/obj/item/weapon/gun/energy/laser,\
			/obj/item/weapon/gun/energy/xray,\
			/obj/item/weapon/gun/energy/laser/captain)
			if(spawn_type)
				var/obj/item/weapon/gun/energy/new_gun = new spawn_type(src.loc)
				new_item = new_gun
				new_item.icon = 'icons/obj/xenoarchaeology.dmi'
				new_item.icon_state = "egun[rand(1,6)]"
				new_gun.desc = "This is an antique energy weapon, you're not sure if it will fire or not."
				new_gun.charge_states = 0 //let's prevent it from losing that great icon if we charge it

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

			item_type = "gun"
		if(27)
			//revolver
			var/obj/item/weapon/gun/projectile/new_gun = new /obj/item/weapon/gun/projectile(src.loc)
			new_item = new_gun
			new_item.icon_state = "gun[rand(1,4)]"
			new_item.icon = 'icons/obj/xenoarchaeology.dmi'

			//33% chance to be able to reload the gun with human ammunition
			if(prob(66))
				new_gun.caliber = list("999" = 1)
			else
				new_gun.caliber = pick(50;list("357" = 1),
									   10;list("75" = 1),
									   30;list("38" = 1),
									   10;list("12mm" = 1))

			//33% chance to fill it with a random amount of bullets
			new_gun.max_shells = rand(1,12)
			if(prob(33))
				var/num_bullets = rand(1,new_gun.max_shells)
				if(num_bullets < new_gun.loaded.len)
					new_gun.loaded.Cut()
					for(var/i = 1, i <= num_bullets, i++)
						var/A = text2path(new_gun.ammo_type)
						new_gun.loaded += new A(new_gun)
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

			item_type = "gun"
		if(28)
			//completely unknown alien device
			if(prob(50))
				apply_image_decorations = 0
		if(29)
			//fossil bone/skull
			//new_item = new /obj/item/weapon/fossil/base(src.loc)

			//the replacement item propogation isn't working, and it's messy code anyway so just do it here
			var/list/candidates = list("/obj/item/weapon/fossil/bone"=9,"/obj/item/weapon/fossil/skull"=3,
			"/obj/item/weapon/fossil/skull/horned"=2)
			var/spawn_type = pickweight(candidates)
			new_item = new spawn_type(src.loc)

			apply_prefix = 0
			additional_desc = "A fossilised part of an alien, long dead."
			apply_image_decorations = 0
			apply_material_decorations = 0
		if(30)
			//fossil shell
			new_item = new /obj/item/weapon/fossil/shell(src.loc)
			apply_prefix = 0
			additional_desc = "A fossilised, pre-Stygian alien crustacean."
			apply_image_decorations = 0
			apply_material_decorations = 0
			if(prob(10))
				apply_image_decorations = 1
		if(31)
			//fossil plant
			new_item = new /obj/item/weapon/fossil/plant(src.loc)
			item_type = new_item.name
			additional_desc = "A fossilised shred of alien plant matter."
			apply_image_decorations = 0
			apply_material_decorations = 0
			apply_prefix = 0
		if(32)
			//humanoid remains
			apply_prefix = 0
			item_type = "humanoid [pick("remains","skeleton")]"
			icon = 'icons/effects/blood.dmi'
			icon_state = "remains"
			additional_desc = pick("They appear almost human.",\
			"They are contorted in a most gruesome way.",\
			"They look almost peaceful.",\
			"The bones are yellowing and old, but remarkably well preserved.",\
			"The bones are scored by numerous burns and partially melted.",\
			"The are battered and broken, in some cases less than splinters are left.",\
			"The mouth is wide open in a death rictus, the victim would appear to have died screaming.")
			apply_image_decorations = 0
			apply_material_decorations = 0
		if(33)
			//robot remains
			apply_prefix = 0
			item_type = "[pick("mechanical","robotic","cyborg")] [pick("remains","chassis","debris")]"
			icon = 'icons/effects/blood.dmi'
			icon_state = "remainsrobot"
			additional_desc = pick("Almost mistakeable for the remains of a modern cyborg.",\
			"They are barely recognisable as anything other than a pile of waste metals.",\
			"It looks like the battered remains of an ancient robot chassis.",\
			"The chassis is rusting and old, but remarkably well preserved.",\
			"The chassis is scored by numerous burns and partially melted.",\
			"The chassis is battered and broken, in some cases only chunks of metal are left.",\
			"A pile of wires and crap metal that looks vaguely robotic.")
			apply_image_decorations = 0
			apply_material_decorations = 0
		if(34)
			//xenos remains
			apply_prefix = 0
			item_type = "alien [pick("remains","skeleton")]"
			icon = 'icons/effects/blood.dmi'
			icon_state = "remainsxeno"
			additional_desc = pick("It looks vaguely reptilian, but with more teeth.",\
			"They are faintly unsettling.",\
			"There is a faint aura of unease about them.",\
			"The bones are yellowing and old, but remarkably well preserved.",\
			"The bones are scored by numerous burns and partially melted.",\
			"The are battered and broken, in some cases less than splinters are left.",\
			"This creature would have been twisted and monstrous when it was alive.",\
			"It doesn't look human.")
			apply_image_decorations = 0
			apply_material_decorations = 0
		if(35)
			//masks
			apply_material_decorations = 0
			var/list/possible_spawns = list()
			possible_spawns += /obj/item/clothing/mask/happy
			//possible_spawns += /obj/item/clothing/mask/stone WHEN I CODE IT
			var/new_type = pick(possible_spawns)
			new_item = new new_type(src.loc)

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

	if(apply_prefix)
		name = "[pick("Strange","Ancient","Alien","")] [item_type]"
	else
		name = item_type

	if(desc)
		desc += " "
	desc += additional_desc
	if(!desc)
		desc = "This item is completely [pick("alien","bizarre")]."

	//icon and icon_state should have already been set
	if(new_item)
		new_item.name = name
		new_item.desc = src.desc

		if(talkative && istype(new_item,/obj/item/weapon))
			new_item.listening_to_players = 1
			if(prob(25))
				new_item.speaking_to_players = 1
				processing_objects.Add(src)
		var/turf/T = get_turf(src)
		if(istype(T, /turf/unsimulated/mineral))
			T:last_find = new_item
		del(src)

	else if(talkative)
		listening_to_players = 1
		if(prob(25))
			speaking_to_players = 1
			processing_objects.Add(src)
