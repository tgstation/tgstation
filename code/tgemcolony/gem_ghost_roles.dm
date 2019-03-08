//Gems

/obj/effect/mob_spawn/human/gem
	name = "Ruby Deposit"
	icon = 'icons/turf/mining.dmi'
	icon_state = "rock_lowchance"
	desc = "It feels as if there's life inside this rock."
	mob_name = "Ruby"
	assignedrole = "Gem"
	mob_species = /datum/species/gem
	density = TRUE
	roundstart = FALSE
	death = FALSE
	move_resist = MOVE_FORCE_NORMAL
	banType = "gem"
	id = /obj/item/gemid
	var/status = "Normal"
	var/kindergarten = TRUE
	var/gemcut = "000"
	uniform = /obj/item/clothing/under/chameleon/gem
	shoes = /obj/item/clothing/shoes/chameleon/gem
	flavour_text = "<span class='big bold'>You are a ruby,</span><b><br>You are a highly replacable Soldier,\
	<br>This makes you an amazing bodyguard due to placing your protected's life above your own.\
	<br>Feel free to use your body as a meat-shield to block attacks.</b>"

/obj/effect/mob_spawn/human/gem/homeworld
	name = "Homeworld Ruby"
	mob_name = "Ruby"
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "ruby"
	kindergarten = FALSE
	density = FALSE
	uniform = /obj/item/clothing/under/chameleon/gem/yellow
	flavour_text = "<span class='big bold'>You are a homeworld ruby,</span><b><br>You are a highly replacable Soldier,\
	<br>This makes you an amazing bodyguard due to placing your protected's life above your own.\
	<br>Feel free to use your body as a meat-shield to block attacks.</b>"

/obj/effect/mob_spawn/human/gem/peridot/homeworld
	name = "Homeworld Peridot"
	kindergarten = FALSE
	density = FALSE
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "peridot"
	uniform = /obj/item/clothing/under/chameleon/gem/yellow
	back = /obj/item/storage/backpack/colonykit
	belt = /obj/item/storage/belt/utility/full/engi
	flavour_text = "<span class='big bold'>You are a homeworld peridot,</span><b><br>You run R&D and the Kindergartens,\
	<br>Your goal is to create more Gems and more Tech for homeworld and the colony.\
	<br>You can summon a toolbox.\
	<br>You also start with a Colony Kit containing everything you'll need.</b>"

/obj/item/storage/backpack/colonykit/PopulateContents()
	new /obj/item/handheldinjector(src)
	new /obj/item/circuitboard/machine/geminjector(src)
	new /obj/item/circuitboard/machine/geminjector(src)
	new /obj/item/stack/cable_coil(src,10,"red")
	new /obj/item/stack/sheet/metal/ten(src)
	new /obj/item/storage/box/colonyparts(src)

/obj/item/storage/box/colonyparts
	name = "Colony Stock Parts"

/obj/item/storage/box/colonyparts/PopulateContents()
	new /obj/item/stock_parts/micro_laser(src)
	new /obj/item/stock_parts/scanning_module(src)
	new /obj/item/stock_parts/manipulator(src)
	new /obj/item/stock_parts/micro_laser(src)
	new /obj/item/stock_parts/scanning_module(src)
	new /obj/item/stock_parts/manipulator(src)

//obj/effect/mob_spawn/human/gem/jade
//	name = "Jade Deposit"
//	id = /obj/item/gemid/jade
//	mob_species = /datum/species/gem/jade
//	flavour_text = "<span class='big bold'>You are a jade,</span><b><br>You must run the science lab,\
//	<br>Your goal is to further the progress of Homeworld and your Colony through upgrades.</b>"

//obj/effect/mob_spawn/human/gem/jade/homeworld //Jade has been used as a gemstone and a tool-making material for for 1000s of years.
//	name = "Homeworld Jade"
//	mob_name = "Jade"
//	icon = 'icons/obj/items_and_weapons.dmi'
//	icon_state = "jade"
//	density = FALSE
//	kindergarten = FALSE
//	uniform = /obj/item/clothing/under/chameleon/gem/white
//	flavour_text = "<span class='big bold'>You are a homeworld jade,</span><b><br>You must start a science lab,\
//	<br>Your goal is to further the progress of Homeworld and your Colony through upgrades.</b>"


/obj/effect/mob_spawn/human/gem/pearl
	name = "Pearl Deposit"
	mob_name = "Pearl"
	mob_species = /datum/species/gem/pearl
	id = /obj/item/gemid/pearl
	flavour_text = "<span class='big bold'>You are a pearl,</span><b><br>You serve high-class gems,\
	<br>Carry their stuff, play music, whatever your master asks of you.\
	<br>You can summon a Spear to fight, but you should avoid doing so.</b>"

/obj/effect/mob_spawn/human/gem/pearl/homeworld
	name = "Homeworld Pearl"
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "pearl"
	density = FALSE
	kindergarten = FALSE
	uniform = /obj/item/clothing/under/chameleon/gem/blue
	mob_species = /datum/species/gem/pearl/homeworld
	flavour_text = "<span class='big bold'>You are a homeworld pearl,</span><b><br>You belong to the Colony Captain,\
	<br>Carry their stuff, play music, whatever the Agate asks of you.\
	<br>You can summon a Spear to fight, but you should avoid doing so.</b>"

/obj/effect/mob_spawn/human/gem/agate
	name = "Agate Deposit"
	mob_name = "Agate"
	id = /obj/item/gemid/agate
	mob_species = /datum/species/gem/agate
	flavour_text = "<span class='big bold'>You are an agate,</span><b><br>You act as a leader,\
	<br>The Homeworld Agate is your boss however, and you must listen to them.\
	<br>You can summon an Electric Whip that deals burn damage.</b>"

/obj/effect/mob_spawn/human/gem/rosequartz
	name = "Rose Quartz Deposit"
	mob_name = "Rose Quartz"
	id = /obj/item/gemid/rosequartz
	mob_species = /datum/species/gem/rosequartz
	flavour_text = "<span class='big bold'>You are a rose quartz,</span><b><br>You are a healer,\
	<br>You can produce healing tears, as well as summon a shield.</b>"

/obj/effect/mob_spawn/human/gem/agate/homeworld
	name = "Homeworld Agate"
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "agate"
	density = FALSE
	kindergarten = FALSE
	mob_species = /datum/species/gem/agate/homeworld
	uniform = /obj/item/clothing/under/chameleon/gem/blue
	flavour_text = "<span class='big bold'>You are a homeworld agate,</span><b><br>You are the Colony Captain,\
	<br>You follow the direct orders of the Diamonds.\
	<br>You can summon an Electric Whip that deals burn damage.</b>"

/obj/effect/mob_spawn/human/gem/bismuth/homeworld
	name = "Homeworld Bismuth"
	mob_name = "Bismuth"
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "bismuth"
	kindergarten = FALSE
	density = FALSE
	id = /obj/item/gemid/bismuth
	mob_species = /datum/species/gem/bismuth
	uniform = /obj/item/clothing/under/chameleon/gem/yellow
	flavour_text = "<span class='big bold'>You are a homeworld Bismuth,</span><b><br>You mine and build,\
	<br>Your goal is to create structures for the Empire.\
	<br>You can smelt ores in your hand!</b>"

/obj/structure/fluff/gem
	name = "Kindergarden Hole"
	desc = "It use to be full, now it's just a person shaped hole."
	icon = 'icons/turf/mining.dmi'
	icon_state = "gemhole"
	var/ispawnedthisgem = "Unknown"
	var/status = "Normal"
	var/specialtext = 0

/obj/structure/fluff/gem/examine(mob/user)
	. = ..()
	if(isgem(user))
		var/mob/living/carbon/human/H = user
		var/datum/species/gem/G = H.dna.species
		if(G.id == "peridot")
			if(status == "Prime")
				to_chat(user, "<span class='notice'>This belongs to [ispawnedthisgem]!</span>")
				if(specialtext == 0)
					specialtext = pick("It's glass all the way to the back","It's the perfect depth","The silhouette is clean and strong")
				to_chat(user, "<span class='notice'>[specialtext]!</span>")
			if(status == "Normal")
				to_chat(user, "<span class='notice'>This belongs to [ispawnedthisgem]!</span>")
			if(status == "OffColor")
				to_chat(user, "<span class='notice'>This belongs to [ispawnedthisgem]!</span>")
				if(specialtext == 0)
					specialtext = pick("It's way too shallow","It's crooked","The shape is inconsistent from back going out")
				to_chat(user, "<span class='notice'>[specialtext]!</span>")
		if(H.name == ispawnedthisgem)
			if(status == "Prime")
				to_chat(user, "<span class='notice'>This is your hole, you feel pride just looking at it.</span>")
			else
				to_chat(user, "<span class='notice'>This is your hole.</span>")

/obj/effect/mob_spawn/human/gem/proc/randompick()
	var/result = pick("A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","0","1","2","3","4","5","6","7","8","9")
	return(result)

/obj/effect/mob_spawn/human/gem/Initialize(mapload)
	notify_ghosts("A [mob_name] is ready to emerge from the ground!", source = src, action=NOTIFY_ATTACK, flashwindow = FALSE, ignore_key = POLL_IGNORE_GOLEM)
	gemspawners.Add(src)
	gemcut = "[randompick()][randompick()][randompick()]"
	if(prob(10) && kindergarten == TRUE)
		//OH BOY! A SPECIAL GEM!
		status = pick("Rebel","Prime","OffColor")
		for(var/mob/living/carbon/human/H in world)
			var/datum/species/gem/G = H.dna.species
			if(G.id == "sapphire" || G.id == "fusion_garnet")
				if(H.gemstatus != "offcolor")//Off color sapphires can't predict the future.
					if(status == "Rebel")
						to_chat(H, "<span class='unconscious'>[mob_name] Cut-[gemcut] is going to betray Homeworld!")
					else if(status == "Prime")
						to_chat(H, "<span class='unconscious'>[mob_name] Cut-[gemcut] is going to emerge as a Prime Gem!")
					else if(status == "OffColor")
						to_chat(H, "<span class='unconscious'>[mob_name] Cut-[gemcut] is going to emerge as a Defective Gem!")
	..()

/obj/effect/mob_spawn/human/gem/special(mob/living/new_spawn, name)
	log_game("[key_name(new_spawn)] has spawned in as a [mob_name].")
	log_admin("[key_name(new_spawn)] has spawned in as a [mob_name].")
	new_spawn.mind.assigned_role = "Homeworld"
	if(ishuman(new_spawn))
		var/mob/living/carbon/human/H = new_spawn
		var/datum/species/gem/G = H.dna.species
		H.gender = "female"
		H.gemcut = src.gemcut
		H.lastname = G.name
		if(G.height == "big")
			H.resize = 1.2
		if(G.height == "small")
			H.resize = 0.8
		if(!name)
			H.fully_replace_character_name(null, "[mob_name] Cut-[src.gemcut]")
		else
			H.fully_replace_character_name(null, name)
		if(status != "Normal")
			//OH BOY! A SPECIAL GEM!
			if(status == "Rebel")
				var/rebelflavor = pick("rosequartz","revolution") //Good, Neutral.
				if(G.id == "peridot")
					H.say("I'm a traitorous clod!")
				if(rebelflavor == "rosequartz")
					var/datum/action/recruit = new/datum/action/innate/gem/recruitcrystalgem
					recruit.Grant(H)
					to_chat(new_spawn, "<span class='notice'>You emerge from the ground, seeing the Life that's already here... You must protect it.</span>")
					new_spawn.mind.assigned_role = "Crystal Gem"
					log_game("[key_name(new_spawn)] as [mob_name] is a Crystal Gem (Antag Role).")
					log_admin("[key_name(new_spawn)] as [mob_name] is a Crystal Gem (Antag Role).")
					to_chat(new_spawn, "<span class='notice'>You are a <b>Crystal Gem</b>, find others to join your cause!</span>")
					to_chat(new_spawn, "<span class='notice'>Keep homeworld from destroying the life native to this planet.</span>")
				if(rebelflavor == "revolution")
					var/datum/action/recruit = new/datum/action/innate/gem/recruitfreemason
					recruit.Grant(H)
					to_chat(new_spawn, "<span class='notice'>You emerge from the ground, seeing the Oppression of the common gem by Tyrants. You must become an independant Colony.</span>")
					new_spawn.mind.assigned_role = "Freemason"
					log_game("[key_name(new_spawn)] as [mob_name] is a Freemason (Antag Role).")
					log_admin("[key_name(new_spawn)] as [mob_name] is a Freemason (Antag Role).")
					to_chat(new_spawn, "<span class='notice'>You are a <b>Freemason</b>, find others to join your cause!</span>")
					to_chat(new_spawn, "<span class='notice'>Take over the Colony for you and your fellow Freemasons.</span>")
			else if(status == "Prime")
				new_spawn.mind.assigned_role = "Prime [mob_name]"
				new_spawn.visible_message("<span class='danger'>[new_spawn] shines bright as they punch their way out of the ground!</span>")
				new_spawn.maxHealth = new_spawn.maxHealth*3
				new_spawn.mind.unconvertable = TRUE
				H.gemstatus = "prime"
				H.resize = 1.2
				new_spawn.equip_to_slot_or_del(new/obj/item/clothing/neck/cloak/prime(null), SLOT_NECK)
				log_game("[key_name(new_spawn)] as [mob_name] is a Prime Gem.")
				log_admin("[key_name(new_spawn)] as [mob_name] is a Prime Gem.")
				to_chat(new_spawn, "<span class='notice'>You are a <b>Prime Gem</b>, You came out of the ground perfectly!</span>")
				to_chat(new_spawn, "<span class='notice'>You shall not betray the Homeworld that gave you your perfection!</span>")
			else if(status == "OffColor")
				new_spawn.mind.assigned_role = "Defective [mob_name]"
				new_spawn.visible_message("<span class='danger'>[new_spawn] shines dimly as they struggle to leave the ground!</span>")
				new_spawn.maxHealth = new_spawn.maxHealth/2
				log_game("[key_name(new_spawn)] as [mob_name] is a Defective Gem.")
				log_admin("[key_name(new_spawn)] as [mob_name] is a Defective Gem.")
				H.gemstatus = "offcolor"
				H.resize = 0.8
				to_chat(new_spawn, "<span class='notice'>You are an <b>Off Color</b>, You came out of the ground all wrong!</span>")
				to_chat(new_spawn, "<span class='notice'>You'll be treated like Dirt by Homeworld, if not out right shattered!</span>")
		if(status != "OffColor")
			H.hair_style = G.hairstyle
			H.hair_color = G.hair_color
		allgems.Add(H)
		if(kindergarten == TRUE)
			var/obj/structure/fluff/gem/hole = new/obj/structure/fluff/gem(get_turf(src))
			hole.status = status
			hole.ispawnedthisgem = new_spawn.name
			if(status == "Prime")
				new/turf/open/floor/plating/rocksmelt(locate(src.x,src.y,src.z))
			else
				new/turf/open/floor/plating/kindergarden(locate(src.x,src.y,src.z))
		sleep(1)
		H.revive(full_heal = TRUE, admin_revive = TRUE)

/obj/effect/mob_spawn/human/gem/peridot
	name = "Peridot Deposit"
	mob_name = "Peridot"
	id = /obj/item/gemid/peridot
	mob_species = /datum/species/gem/peridot
	flavour_text = "<span class='big bold'>You are a peridot,</span><b><br>You help run the kindergarden,\
	<br>Your goal is to create more Gems for homeworld and the colony.</b>"

/obj/effect/mob_spawn/human/gem/bismuth
	name = "Bismuth Deposit"
	mob_name = "Bismuth"
	id = /obj/item/gemid/bismuth
	mob_species = /datum/species/gem/bismuth
	flavour_text = "<span class='big bold'>You are a Bismuth,</span><b><br>You mine and build,\
	<br>Your goal is to create structures for the Empire.\
	<br>You can smelt ores in your hand!</b>"

/obj/effect/mob_spawn/human/gem/sapphire
	name = "Sapphire Deposit"
	mob_name = "Sapphire"
	id = /obj/item/gemid/sapphire
	mob_species = /datum/species/gem/sapphire
	flavour_text = "<span class='big bold'>You are a sapphire,</span><b><br>You can predict the Future,\
	<br>This'll let you pinpoint Traitors, Offcolors, and Prime Gems before they even Emerge.\
	<br>You can also get the coordinates of any mob anywhere.\
	<br>You can also predict Random Events 1 minute 30 seconds before they even happen.</b>"

/obj/effect/mob_spawn/human/gem/amethyst
	name = "Amethyst Deposit"
	mob_name = "Amethyst"
	id = /obj/item/gemid/amethyst
	mob_species = /datum/species/gem/amethyst
	flavour_text = "<span class='big bold'>You are an Amethyst,</span><b><br>You are a Quartz Soldier,\
	<br>You disarm your opponents with your whip and are tough to poof.</b>"