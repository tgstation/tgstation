//Objects that spawn ghosts in as a certain role when they click on it, i.e. away mission bartenders.

//Preserved terrarium/seed vault: Spawns in seed vault structures in lavaland. Ghosts become plantpeople and are advised to begin growing plants in the room near them.
/obj/effect/mob_spawn/human/seed_vault
	name = "preserved terrarium"
	desc = "An ancient machine that seems to be used for storing plant matter. The glass is obstructed by a mat of vines."
	mob_name = "a lifebringer"
	icon = 'icons/obj/lavaland/spawners.dmi'
	icon_state = "terrarium"
	density = TRUE
	roundstart = FALSE
	death = FALSE
	mob_species = /datum/species/pod
	flavour_text = "<span class='big bold'>You are a sentient ecosystem,</span><b> an example of the mastery over life that your creators possessed. Your masters, benevolent as they were, created uncounted \
	seed vaults and spread them across the universe to every planet they could chart. You are in one such seed vault. Your goal is to cultivate and spread life wherever it will go while waiting \
	for contact from your creators. Estimated time of last contact: Deployment, 5x10^3 millennia ago.</b>"
	assignedrole = "Lifebringer"

/obj/effect/mob_spawn/human/seed_vault/special(mob/living/new_spawn)
	var/plant_name = pick("Tomato", "Potato", "Broccoli", "Carrot", "Ambrosia", "Pumpkin", "Ivy", "Kudzu", "Banana", "Moss", "Flower", "Bloom", "Root", "Bark", "Glowshroom", "Petal", "Leaf", \
	"Venus", "Sprout","Cocoa", "Strawberry", "Citrus", "Oak", "Cactus", "Pepper", "Juniper")
	new_spawn.fully_replace_character_name(null,plant_name)
	if(ishuman(new_spawn))
		var/mob/living/carbon/human/H = new_spawn
		H.underwear = "Nude" //You're a plant, partner
		H.update_body()

/obj/effect/mob_spawn/human/seed_vault/Destroy()
	new/obj/structure/fluff/empty_terrarium(get_turf(src))
	return ..()

//Ash walker eggs: Spawns in ash walker dens in lavaland. Ghosts become unbreathing lizards that worship the Necropolis and are advised to retrieve corpses to create more ash walkers.

/obj/effect/mob_spawn/human/ash_walker
	name = "ash walker egg"
	desc = "A man-sized yellow egg, spawned from some unfathomable creature. A humanoid silhouette lurks within."
	mob_name = "an ash walker"
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "large_egg"
	mob_species = /datum/species/lizard/ashwalker
	outfit = /datum/outfit/ashwalker
	roundstart = FALSE
	death = FALSE
	anchored = FALSE
	move_resist = MOVE_FORCE_NORMAL
	density = FALSE
	flavour_text = "<span class='big bold'>You are an ash walker.</span><b> Your tribe worships <span class='danger'>the Necropolis</span>. The wastes are sacred ground, its monsters a blessed bounty. \
	You have seen lights in the distance... they foreshadow the arrival of outsiders that seek to tear apart the Necropolis and its domain. Fresh sacrifices for your nest.</b>"
	assignedrole = "Ash Walker"

/obj/effect/mob_spawn/human/ash_walker/special(mob/living/new_spawn)
	new_spawn.fully_replace_character_name(null,random_unique_lizard_name(gender))
	to_chat(new_spawn, "<b>Drag the corpses of men and beasts to your nest. It will absorb them to create more of your kind. Glory to the Necropolis!</b>")

	new_spawn.grant_language(/datum/language/draconic)
	var/datum/language_holder/holder = new_spawn.get_language_holder()
	holder.selected_default_language = /datum/language/draconic

	if(ishuman(new_spawn))
		var/mob/living/carbon/human/H = new_spawn
		H.underwear = "Nude"
		H.update_body()

/obj/effect/mob_spawn/human/ash_walker/Initialize(mapload)
	. = ..()
	var/area/A = get_area(src)
	if(A)
		notify_ghosts("An ash walker egg is ready to hatch in \the [A.name].", source = src, action=NOTIFY_ATTACK, flashwindow = FALSE, ignore_key = POLL_IGNORE_ASHWALKER)

/datum/outfit/ashwalker
	name ="Ashwalker"
	head = /obj/item/clothing/head/helmet/gladiator
	uniform = /obj/item/clothing/under/gladiator/ash_walker


//Timeless prisons: Spawns in Wish Granter prisons in lavaland. Ghosts become age-old users of the Wish Granter and are advised to seek repentance for their past.
/obj/effect/mob_spawn/human/exile
	name = "timeless prison"
	desc = "Although this stasis pod looks medicinal, it seems as though it's meant to preserve something for a very long time."
	mob_name = "a penitent exile"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	roundstart = FALSE
	death = FALSE
	mob_species = /datum/species/shadow
	flavour_text = "<span class='big bold'>You are cursed.</span><b> Years ago, you sacrificed the lives of your trusted friends and the humanity of yourself to reach the Wish Granter. Though you \
	did so, it has come at a cost: your very body rejects the light, dooming you to wander endlessly in this horrible wasteland.</b>"
	assignedrole = "Exile"

/obj/effect/mob_spawn/human/exile/Destroy()
	new/obj/structure/fluff/empty_sleeper(get_turf(src))
	return ..()

/obj/effect/mob_spawn/human/exile/special(mob/living/new_spawn)
	new_spawn.fully_replace_character_name(null,"Wish Granter's Victim ([rand(1,999)])")
	var/wish = rand(1,4)
	switch(wish)
		if(1)
			to_chat(new_spawn, "<b>You wished to kill, and kill you did. You've lost track of how many, but the spark of excitement that murder once held has winked out. You feel only regret.</b>")
		if(2)
			to_chat(new_spawn, "<b>You wished for unending wealth, but no amount of money was worth this existence. Maybe charity might redeem your soul?</b>")
		if(3)
			to_chat(new_spawn, "<b>You wished for power. Little good it did you, cast out of the light. You are the [gender == MALE ? "king" : "queen"] of a hell that holds no subjects. You feel only remorse.</b>")
		if(4)
			to_chat(new_spawn, "<b>You wished for immortality, even as your friends lay dying behind you. No matter how many times you cast yourself into the lava, you awaken in this room again within a few days. There is no escape.</b>")

//Golem shells: Spawns in Free Golem ships in lavaland. Ghosts become mineral golems and are advised to spread personal freedom.
/obj/effect/mob_spawn/human/golem
	name = "inert free golem shell"
	desc = "A humanoid shape, empty, lifeless, and full of potential."
	mob_name = "a free golem"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "construct"
	mob_species = /datum/species/golem
	roundstart = FALSE
	death = FALSE
	anchored = FALSE
	move_resist = MOVE_FORCE_NORMAL
	density = FALSE
	var/has_owner = FALSE
	var/can_transfer = TRUE //if golems can switch bodies to this new shell
	var/mob/living/owner = null //golem's owner if it has one
	flavour_text = "<span class='big bold'>You are a Free Golem.</span><b> Your family worships <span class='danger'>The Liberator</span>. In his infinite and divine wisdom, he set your clan free to \
	travel the stars with a single declaration: \"Yeah go do whatever.\" Though you are bound to the one who created you, it is customary in your society to repeat those same words to newborn \
	golems, so that no golem may ever be forced to serve again.</b>"

/obj/effect/mob_spawn/human/golem/Initialize(mapload, datum/species/golem/species = null, mob/creator = null)
	if(species) //spawners list uses object name to register so this goes before ..()
		name += " ([initial(species.prefix)])"
		mob_species = species
	. = ..()
	var/area/A = get_area(src)
	if(!mapload && A)
		notify_ghosts("\A [initial(species.prefix)] golem shell has been completed in \the [A.name].", source = src, action=NOTIFY_ATTACK, flashwindow = FALSE, ignore_key = POLL_IGNORE_GOLEM)
	if(has_owner && creator)
		flavour_text = "<span class='big bold'>You are a Golem.</span><b> You move slowly, but are highly resistant to heat and cold as well as blunt trauma. You are unable to wear clothes, but can still use most tools. \
		Serve [creator], and assist [creator.p_them()] in completing [creator.p_their()] goals at any cost.</b>"
		owner = creator

/obj/effect/mob_spawn/human/golem/special(mob/living/new_spawn, name)
	var/datum/species/golem/X = mob_species
	to_chat(new_spawn, "[initial(X.info_text)]")
	if(!owner)
		to_chat(new_spawn, "Build golem shells in the autolathe, and feed refined mineral sheets to the shells to bring them to life! You are generally a peaceful group unless provoked.")
	else
		new_spawn.mind.store_memory("<b>Serve [owner.real_name], your creator.</b>")
		new_spawn.mind.enslave_mind_to_creator(owner)
		log_game("[key_name(new_spawn)] possessed a golem shell enslaved to [key_name(owner)].")
		log_admin("[key_name(new_spawn)] possessed a golem shell enslaved to [key_name(owner)].")
	if(ishuman(new_spawn))
		var/mob/living/carbon/human/H = new_spawn
		if(has_owner)
			var/datum/species/golem/G = H.dna.species
			G.owner = owner
		H.set_cloned_appearance()
		if(!name)
			if(has_owner)
				H.fully_replace_character_name(null, "[initial(X.prefix)] Golem ([rand(1,999)])")
			else
				H.fully_replace_character_name(null, H.dna.species.random_name())
		else
			H.fully_replace_character_name(null, name)
	if(has_owner)
		new_spawn.mind.assigned_role = "Servant Golem"
	else
		new_spawn.mind.assigned_role = "Free Golem"

/obj/effect/mob_spawn/human/golem/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(isgolem(user) && can_transfer)
		var/transfer_choice = alert("Transfer your soul to [src]? (Warning, your old body will die!)",,"Yes","No")
		if(transfer_choice != "Yes")
			return
		if(QDELETED(src) || uses <= 0)
			return
		log_game("[key_name(user)] golem-swapped into [src]")
		user.visible_message("<span class='notice'>A faint light leaves [user], moving to [src] and animating it!</span>","<span class='notice'>You leave your old body behind, and transfer into [src]!</span>")
		show_flavour = FALSE
		create(ckey = user.ckey,name = user.real_name)
		user.death()
		return

/obj/effect/mob_spawn/human/golem/servant
	has_owner = TRUE
	name = "inert servant golem shell"
	mob_name = "a servant golem"


/obj/effect/mob_spawn/human/golem/adamantine
	name = "dust-caked free golem shell"
	desc = "A humanoid shape, empty, lifeless, and full of potential."
	mob_name = "a free golem"
	can_transfer = FALSE
	mob_species = /datum/species/golem/adamantine

//Malfunctioning cryostasis sleepers: Spawns in makeshift shelters in lavaland. Ghosts become hermits with knowledge of how they got to where they are now.
/obj/effect/mob_spawn/human/hermit
	name = "malfunctioning cryostasis sleeper"
	desc = "A humming sleeper with a silhouetted occupant inside. Its stasis function is broken and it's likely being used as a bed."
	mob_name = "a stranded hermit"
	icon = 'icons/obj/lavaland/spawners.dmi'
	icon_state = "cryostasis_sleeper"
	roundstart = FALSE
	death = FALSE
	random = TRUE
	mob_species = /datum/species/human
	flavour_text = "<span class='big bold'>You've been stranded in this godless prison of a planet for longer than you can remember.</span><b> Each day you barely scrape by, and between the terrible \
	conditions of your makeshift shelter, the hostile creatures, and the ash drakes swooping down from the cloudless skies, all you can wish for is the feel of soft grass between your toes and \
	the fresh air of Earth. These thoughts are dispelled by yet another recollection of how you got here... "
	assignedrole = "Hermit"

/obj/effect/mob_spawn/human/hermit/Initialize(mapload)
	. = ..()
	var/arrpee = rand(1,4)
	switch(arrpee)
		if(1)
			flavour_text += "you were a [pick("arms dealer", "shipwright", "docking manager")]'s assistant on a small trading station several sectors from here. Raiders attacked, and there was \
			only one pod left when you got to the escape bay. You took it and launched it alone, and the crowd of terrified faces crowding at the airlock door as your pod's engines burst to \
			life and sent you to this hell are forever branded into your memory.</b>"
			outfit.uniform = /obj/item/clothing/under/assistantformal
			outfit.shoes = /obj/item/clothing/shoes/sneakers/black
			outfit.back = /obj/item/storage/backpack
		if(2)
			flavour_text += "you're an exile from the Tiger Cooperative. Their technological fanaticism drove you to question the power and beliefs of the Exolitics, and they saw you as a \
			heretic and subjected you to hours of horrible torture. You were hours away from execution when a high-ranking friend of yours in the Cooperative managed to secure you a pod, \
			scrambled its destination's coordinates, and launched it. You awoke from stasis when you landed and have been surviving - barely - ever since.</b>"
			outfit.uniform = /obj/item/clothing/under/rank/prisoner
			outfit.shoes = /obj/item/clothing/shoes/sneakers/orange
			outfit.back = /obj/item/storage/backpack
		if(3)
			flavour_text += "you were a doctor on one of Nanotrasen's space stations, but you left behind that damn corporation's tyranny and everything it stood for. From a metaphorical hell \
			to a literal one, you find yourself nonetheless missing the recycled air and warm floors of what you left behind... but you'd still rather be here than there.</b>"
			outfit.uniform = /obj/item/clothing/under/rank/medical
			outfit.suit = /obj/item/clothing/suit/toggle/labcoat
			outfit.back = /obj/item/storage/backpack/medic
			outfit.shoes = /obj/item/clothing/shoes/sneakers/black
		if(4)
			flavour_text += "you were always joked about by your friends for \"not playing with a full deck\", as they so <i>kindly</i> put it. It seems that they were right when you, on a tour \
			at one of Nanotrasen's state-of-the-art research facilities, were in one of the escape pods alone and saw the red button. It was big and shiny, and it caught your eye. You pressed \
			it, and after a terrifying and fast ride for days, you landed here. You've had time to wisen up since then, and you think that your old friends wouldn't be laughing now.</b>"
			outfit.uniform = /obj/item/clothing/under/color/grey/glorf
			outfit.shoes = /obj/item/clothing/shoes/sneakers/black
			outfit.back = /obj/item/storage/backpack

/obj/effect/mob_spawn/human/hermit/Destroy()
	new/obj/structure/fluff/empty_cryostasis_sleeper(get_turf(src))
	return ..()

//Broken rejuvenation pod: Spawns in animal hospitals in lavaland. Ghosts become disoriented interns and are advised to search for help.
/obj/effect/mob_spawn/human/doctor/alive/lavaland
	name = "broken rejuvenation pod"
	desc = "A small sleeper typically used to instantly restore minor wounds. This one seems broken, and its occupant is comatose."
	mob_name = "a translocated vet"
	flavour_text = "<span class='big bold'>What...?</span><b> Where are you? Where are the others? This is still the animal hospital - you should know, you've been an intern here for weeks - but \
	everyone's gone. One of the cats scratched you just a few minutes ago. That's why you were in the pod - to heal the scratch. The scabs are still fresh; you see them right now. So where is \
	everyone? Where did they go? What happened to the hospital? And is that <i>smoke</i> you smell? You need to find someone else. Maybe they can tell you what happened.</b>"
	assignedrole = "Translocated Vet"

/obj/effect/mob_spawn/human/doctor/alive/lavaland/Destroy()
	var/obj/structure/fluff/empty_sleeper/S = new(drop_location())
	S.setDir(dir)
	return ..()

//Prisoner containment sleeper: Spawns in crashed prison ships in lavaland. Ghosts become escaped prisoners and are advised to find a way out of the mess they've gotten themselves into.
/obj/effect/mob_spawn/human/prisoner_transport
	name = "prisoner containment sleeper"
	desc = "A sleeper designed to put its occupant into a deep coma, unbreakable until the sleeper turns off. This one's glass is cracked and you can see a pale, sleeping face staring out."
	mob_name = "an escaped prisoner"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper_s"
	outfit = /datum/outfit/lavalandprisoner
	roundstart = FALSE
	death = FALSE
	flavour_text = "<b>Good. It seems as though your ship crashed. <span class='big bold'>You're a prisoner,</span> sentenced to hard work in one of Nanotrasen's labor camps, but it seems as \
	though fate has other plans for you. You remember that you were convicted of "
	assignedrole = "Escaped Prisoner"

/obj/effect/mob_spawn/human/prisoner_transport/special(mob/living/L)
	L.fully_replace_character_name(null,"NTP #LL-0[rand(111,999)]") //Nanotrasen Prisoner #Lavaland-(numbers)

/obj/effect/mob_spawn/human/prisoner_transport/Initialize(mapload)
	. = ..()
	var/list/crimes = list("murder", "larceny", "embezzlement", "unionization", "dereliction of duty", "kidnapping", "gross incompetence", "grand theft", "collaboration with the Syndicate", \
	"worship of a forbidden deity", "interspecies relations", "mutiny")
	flavour_text += "[pick(crimes)]. but regardless of that, it seems like your crime doesn't matter now. You don't know where you are, but you know that it's out to kill you, and you're not going \
	to lose this opportunity. Find a way to get out of this mess and back to where you rightfully belong - your [pick("house", "apartment", "spaceship", "station")]</b>."

/datum/outfit/lavalandprisoner
	name = "Lavaland Prisoner"
	uniform = /obj/item/clothing/under/rank/prisoner
	mask = /obj/item/clothing/mask/breath
	shoes = /obj/item/clothing/shoes/sneakers/orange
	r_pocket = /obj/item/tank/internals/emergency_oxygen


/obj/effect/mob_spawn/human/prisoner_transport/Destroy()
	new/obj/structure/fluff/empty_sleeper/syndicate(get_turf(src))
	return ..()

//Space Hotel Staff
/obj/effect/mob_spawn/human/hotel_staff //not free antag u little shits
	name = "staff sleeper"
	desc = "A sleeper designed for long-term stasis between guest visits."
	mob_name = "hotel staff member"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper_s"
	objectives = "Cater to visiting guests with your fellow staff. Do not leave your assigned hotel and always remember: The customer is always right!"
	death = FALSE
	roundstart = FALSE
	random = TRUE
	outfit = /datum/outfit/hotelstaff
	flavour_text = "<span class='big bold'>You are a staff member of a top-of-the-line space hotel!</span><b> Cater to guests and <font size=6><b>DON'T</b></font> leave the hotel, lest the manager fire you for\
		dereliction of duty!</b>"
	assignedrole = "Hotel Staff"

/datum/outfit/hotelstaff
	name = "Hotel Staff"
	uniform = /obj/item/clothing/under/assistantformal
	shoes = /obj/item/clothing/shoes/laceup
	r_pocket = /obj/item/radio/off
	back = /obj/item/storage/backpack
	implants = list(/obj/item/implant/mindshield)

/obj/effect/mob_spawn/human/hotel_staff/security
	name = "hotel security sleeper"
	mob_name = "hotel security member"
	outfit = /datum/outfit/hotelstaff/security
	flavour_text = "<span class='big bold'>You are a peacekeeper</span><b> assigned to this hotel to protect the interests of the company while keeping the peace between \
		guests and the staff. Do <font size=6>NOT</font> leave the hotel, as that is grounds for contract termination.</b>"
	objectives = "Do not leave your assigned hotel. Try and keep the peace between staff and guests, non-lethal force heavily advised if possible."

/datum/outfit/hotelstaff/security
	name = "Hotel Security"
	uniform = /obj/item/clothing/under/rank/security/blueshirt
	shoes = /obj/item/clothing/shoes/jackboots
	suit = /obj/item/clothing/suit/armor/vest/blueshirt
	head = /obj/item/clothing/head/helmet/blueshirt
	back = /obj/item/storage/backpack/security
	belt = /obj/item/storage/belt/security/full

/obj/effect/mob_spawn/human/hotel_staff/Destroy()
	new/obj/structure/fluff/empty_sleeper/syndicate(get_turf(src))
	..()

/obj/effect/mob_spawn/human/demonic_friend
	name = "Essence of friendship"
	desc = "Oh boy! Oh boy! A friend!"
	mob_name = "Demonic friend"
	icon = 'icons/obj/cardboard_cutout.dmi'
	icon_state = "cutout_basic"
	outfit = /datum/outfit/demonic_friend
	death = FALSE
	roundstart = FALSE
	random = TRUE
	id_job = "SuperFriend"
	id_access = "assistant"
	var/obj/effect/proc_holder/spell/targeted/summon_friend/spell
	var/datum/mind/owner
	assignedrole = "SuperFriend"

/obj/effect/mob_spawn/human/demonic_friend/Initialize(mapload, datum/mind/owner_mind, obj/effect/proc_holder/spell/targeted/summon_friend/summoning_spell)
	. = ..()
	owner = owner_mind
	flavour_text = "<span class='big bold'>You have been given a reprieve from your eternity of torment, to be [owner.name]'s friend for [owner.p_their()] short mortal coil.</span><b> Be aware that if you do not live up to [owner.name]'s expectations, they can send you back to hell with a single thought.  [owner.name]'s death will also return you to hell.</b>"
	var/area/A = get_area(src)
	if(!mapload && A)
		notify_ghosts("\A friendship shell has been completed in \the [A.name].", source = src, action=NOTIFY_ATTACK, flashwindow = FALSE)
	objectives = "Be [owner.name]'s friend, and keep [owner.name] alive, so you don't get sent back to hell."
	spell = summoning_spell


/obj/effect/mob_spawn/human/demonic_friend/special(mob/living/L)
	if(!QDELETED(owner.current) && owner.current.stat != DEAD)
		L.fully_replace_character_name(null,"[owner.name]'s best friend")
		soullink(/datum/soullink/oneway, owner.current, L)
		spell.friend = L
		spell.charge_counter = spell.charge_max
		L.mind.hasSoul = FALSE
		var/mob/living/carbon/human/H = L
		var/obj/item/worn = H.wear_id
		var/obj/item/card/id/id = worn.GetID()
		id.registered_name = L.real_name
		id.update_label()
	else
		to_chat(L, "<span class='userdanger'>Your owner is already dead!  You will soon perish.</span>")
		addtimer(CALLBACK(L, /mob.proc/dust, 150)) //Give em a few seconds as a mercy.

/datum/outfit/demonic_friend
	name = "Demonic Friend"
	uniform = /obj/item/clothing/under/assistantformal
	shoes = /obj/item/clothing/shoes/laceup
	r_pocket = /obj/item/radio/off
	back = /obj/item/storage/backpack
	implants = list(/obj/item/implant/mindshield) //No revolutionaries, he's MY friend.
	id = /obj/item/card/id

/obj/effect/mob_spawn/human/syndicate
	name = "Syndicate Operative"
	roundstart = FALSE
	death = FALSE
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper_s"
	outfit = /datum/outfit/syndicate_empty
	assignedrole = "Space Syndicate"	//I know this is really dumb, but Syndicate operative is nuke ops

/datum/outfit/syndicate_empty
	name = "Syndicate Operative Empty"
	uniform = /obj/item/clothing/under/syndicate
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	ears = /obj/item/radio/headset/syndicate/alt
	back = /obj/item/storage/backpack
	implants = list(/obj/item/implant/weapons_auth)
	id = /obj/item/card/id/syndicate

/datum/outfit/syndicate_empty/post_equip(mob/living/carbon/human/H)
	H.faction |= ROLE_SYNDICATE

/obj/effect/mob_spawn/human/syndicate/battlecruiser
	name = "Syndicate Battlecruiser Ship Operative"
	flavour_text = "<span class='big bold'>You are a crewmember aboard the syndicate flagship: the SBC Starfury.</span><span class='big'> <span class='danger'><b>Your job is to follow your captain's orders, maintain the ship, and keep the engine running.</b></span> If you are not familiar with how the supermatter engine functions: <b>do not attempt to start it.</b><br>\
	<br>\
	<span class='danger'><b>The armory is not a candy store, and your role is not to assault the station directly, leave that work to the assault operatives.</b></span></font>"
	outfit = /datum/outfit/syndicate_empty/SBC

/datum/outfit/syndicate_empty/SBC
	name = "Syndicate Battlecruiser Ship Operative"
	l_pocket = /obj/item/gun/ballistic/automatic/pistol
	r_pocket = /obj/item/kitchen/knife/combat/survival
	belt = /obj/item/storage/belt/military/assault

/obj/effect/mob_spawn/human/syndicate/battlecruiser/assault
	name = "Syndicate Battlecruiser Assault Operative"
	flavour_text = "<span class='big bold'>You are an assault operative aboard the syndicate flagship: the SBC Starfury.</span><span class='big'> <span class='danger'><b>Your job is to follow your captain's orders, keep intruders out of the ship, and assault Space Station 13.</b></span> There is an armory, multiple assault ships, and beam cannons to attack the station with.<br>\
	<br>\
	<span class='danger'><b>Work as a team with your fellow operatives and work out a plan of attack. If you are overwhelmed, escape back to your ship!</b></span></span>"
	outfit = /datum/outfit/syndicate_empty/SBC/assault

/datum/outfit/syndicate_empty/SBC/assault
	name = "Syndicate Battlecruiser Assault Operative"
	uniform = /obj/item/clothing/under/syndicate/combat
	l_pocket = /obj/item/ammo_box/magazine/m10mm
	r_pocket = /obj/item/kitchen/knife/combat/survival
	belt = /obj/item/storage/belt/military
	suit = /obj/item/clothing/suit/armor/vest
	suit_store = /obj/item/gun/ballistic/automatic/pistol
	back = /obj/item/storage/backpack/security
	mask = /obj/item/clothing/mask/gas/syndicate

/obj/effect/mob_spawn/human/syndicate/battlecruiser/captain
	name = "Syndicate Battlecruiser Captain"
	flavour_text = "<span class='big bold'>You are the captain aboard the syndicate flagship: the SBC Starfury.</span><span class='big'> <span class='danger'><b>Your job is to oversee your crew, defend the ship, and destroy Space Station 13.</b></span> The ship has an armory, multiple ships, beam cannons, and multiple crewmembers to accomplish this goal.<br>\
	<br>\
	<span class='danger'><b>As the captain, this whole operation falls on your shoulders.</b></span> You do not need to nuke the station, causing sufficient damage and preventing your ship from being destroyed will be enough.</span>"
	outfit = /datum/outfit/syndicate_empty/SBC/assault/captain
	id_access_list = list(150,151)

/datum/outfit/syndicate_empty/SBC/assault/captain
	name = "Syndicate Battlecruiser Captain"
	l_pocket = /obj/item/melee/transforming/energy/sword/saber/red
	r_pocket = /obj/item/melee/classic_baton/telescopic
	suit = /obj/item/clothing/suit/armor/vest/capcarapace/syndicate
	suit_store = /obj/item/gun/ballistic/revolver/mateba
	back = /obj/item/storage/backpack/satchel/leather
	head = /obj/item/clothing/head/HoS/syndicate
	mask = /obj/item/clothing/mask/cigarette/cigar/havana
	glasses = /obj/item/clothing/glasses/thermal/eyepatch

//Ancient cryogenic sleepers. Players become NT crewmen from a hundred year old space station, now on the verge of collapse.
/obj/effect/mob_spawn/human/oldsec
	name = "old cryogenics pod"
	desc = "A humming cryo pod. You can barely recognise a security uniform underneath the built up ice. The machine is attempting to wake up its occupant."
	mob_name = "a security officer"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	roundstart = FALSE
	death = FALSE
	random = TRUE
	mob_species = /datum/species/human
	flavour_text = "<span class='big bold'>You are a security officer working for Nanotrasen,</span><b> stationed onboard a state of the art research station. You vaguely recall rushing into a \
	cryogenics pod due to an oncoming radiation storm. The last thing you remember is the station's Artificial Program telling you that you would only be asleep for eight hours. As you open \
	your eyes, everything seems rusted and broken, a dark feeling swells in your gut as you climb out of your pod. \
	Work as a team with your fellow survivors and do not abandon them.</b>"
	uniform = /obj/item/clothing/under/rank/security
	shoes = /obj/item/clothing/shoes/jackboots
	id = /obj/item/card/id/away/old/sec
	r_pocket = /obj/item/restraints/handcuffs
	l_pocket = /obj/item/assembly/flash/handheld
	assignedrole = "Ancient Crew"

/obj/effect/mob_spawn/human/oldsec/Destroy()
	new/obj/structure/showcase/machinery/oldpod/used(drop_location())
	return ..()

/obj/effect/mob_spawn/human/oldeng
	name = "old cryogenics pod"
	desc = "A humming cryo pod. You can barely recognise an engineering uniform underneath the built up ice. The machine is attempting to wake up its occupant."
	mob_name = "an engineer"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	roundstart = FALSE
	death = FALSE
	random = TRUE
	mob_species = /datum/species/human
	flavour_text = "<span class='big bold'>You are an engineer working for Nanotrasen,</span><b> stationed onboard a state of the art research station. You vaguely recall rushing into a \
	cryogenics pod due to an oncoming radiation storm. The last thing you remember is the station's Artificial Program telling you that you would only be asleep for eight hours. As you open \
	your eyes, everything seems rusted and broken, a dark feeling swells in your gut as you climb out of your pod. \
	Work as a team with your fellow survivors and do not abandon them.</b>"
	uniform = /obj/item/clothing/under/rank/engineer
	shoes = /obj/item/clothing/shoes/workboots
	id = /obj/item/card/id/away/old/eng
	gloves = /obj/item/clothing/gloves/color/fyellow/old
	l_pocket = /obj/item/tank/internals/emergency_oxygen
	assignedrole = "Ancient Crew"

/obj/effect/mob_spawn/human/oldeng/Destroy()
	new/obj/structure/showcase/machinery/oldpod/used(drop_location())
	return ..()

/obj/effect/mob_spawn/human/oldsci
	name = "old cryogenics pod"
	desc = "A humming cryo pod. You can barely recognise a science uniform underneath the built up ice. The machine is attempting to wake up its occupant."
	mob_name = "a scientist"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	roundstart = FALSE
	death = FALSE
	random = TRUE
	mob_species = /datum/species/human
	flavour_text = "<span class='big bold'>You are a scientist working for Nanotrasen,</span><b> stationed onboard a state of the art research station. You vaguely recall rushing into a \
	cryogenics pod due to an oncoming radiation storm. The last thing you remember is the station's Artificial Program telling you that you would only be asleep for eight hours. As you open \
	your eyes, everything seems rusted and broken, a dark feeling swells in your gut as you climb out of your pod. \
	Work as a team with your fellow survivors and do not abandon them.</b>"
	uniform = /obj/item/clothing/under/rank/scientist
	shoes = /obj/item/clothing/shoes/laceup
	id = /obj/item/card/id/away/old/sci
	l_pocket = /obj/item/stack/medical/bruise_pack
	assignedrole = "Ancient Crew"

/obj/effect/mob_spawn/human/oldsci/Destroy()
	new/obj/structure/showcase/machinery/oldpod/used(drop_location())
	return ..()

/obj/effect/mob_spawn/human/pirate
	name = "space pirate sleeper"
	desc = "A cryo sleeper smelling faintly of rum."
	random = TRUE
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	mob_name = "a space pirate"
	mob_species = /datum/species/skeleton
	outfit = /datum/outfit/pirate/space
	roundstart = FALSE
	death = FALSE
	anchored = TRUE
	density = FALSE
	show_flavour = FALSE //Flavour only exists for spawners menu
	flavour_text = "<span class='big bold'>You are a space pirate.</span><b> The station refused to pay for your protection, protect the ship, siphon the credits from the station and raid it for even more loot.</b>"
	assignedrole = "Space Pirate"
	var/rank = "Mate"

/obj/effect/mob_spawn/human/pirate/special(mob/living/new_spawn)
	new_spawn.fully_replace_character_name(new_spawn.real_name,generate_pirate_name())
	new_spawn.mind.add_antag_datum(/datum/antagonist/pirate)

/obj/effect/mob_spawn/human/pirate/proc/generate_pirate_name()
	var/beggings = strings(PIRATE_NAMES_FILE, "beginnings")
	var/endings = strings(PIRATE_NAMES_FILE, "endings")
	return "[rank] [pick(beggings)][pick(endings)]"

/obj/effect/mob_spawn/human/pirate/Destroy()
	new/obj/structure/showcase/machinery/oldpod/used(drop_location())
	return ..()

/obj/effect/mob_spawn/human/pirate/captain
	rank = "Captain"
	outfit = /datum/outfit/pirate/space/captain

/obj/effect/mob_spawn/human/pirate/gunner
	rank = "Gunner"

//Humans

/obj/effect/mob_spawn/human/tribal
	name = "human infant"
	desc = "A tiny Human waiting to grow up."
	mob_name = "Human"
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "humanbaby"
	mob_species = /datum/species/human
	roundstart = FALSE
	death = FALSE
	anchored = FALSE
	uniform = /obj/item/clothing/under/tribal
	move_resist = MOVE_FORCE_NORMAL
	density = FALSE
	flavour_text = "<span class='big bold'>You are a Human.</span><b><br>Provide for your tribe with Food\
	<br>You can get this through hunting and foraging, You are at a heavy disadvantage against the Gems.</b>"
	assignedrole = "Human"
	var/firstname = "Hoomayn"
	var/lastname = "Guiyz"

/obj/effect/mob_spawn/human/tribal/zooman
	uniform = /obj/item/clothing/under/zooman
	ears = /obj/item/clothing/ears/zooman
	name = "zooman infant" //pink diamond's human zoo!
	flavour_text = "<span class='big bold'>You are a Zooman.</span><b><br>You belong to Pink Diamond\
	<br>Live out your life within the Zoo.</b>"
	assignedrole = "Zooman"
	lastname = "Zooman"

/obj/effect/mob_spawn/human/tribal/attack_hand(mob/user)
	..()
	if(ishuman(user) && assignedrole != "Zooman")
		var/mob/living/carbon/human/H = user
		if(H.lastname != "Guiyz")
			if(isgem(H)) //Freemasons and Homeworld gems can put humans in a zoo, crystal gems can not.
				if(H.mind.assigned_role != "Crystal Gem")
					to_chat(H, "<span class='notice'>You claim the infant for the zoo.</span>")
					new /obj/effect/mob_spawn/human/tribal/zooman(src.loc)
					del(src)
				else
					to_chat(H, "<span class='notice'>You can't tear this child away from their family.</span>")

/obj/effect/mob_spawn/human/tribal/Initialize(mapload)
	if(firstname == "Human")
		notify_ghosts("A [mob_name] is ready to grow up!", source = src, action=NOTIFY_ATTACK, flashwindow = FALSE, ignore_key = POLL_IGNORE_GOLEM)
	else if(lastname == "Zooman")
		notify_ghosts("A [mob_name] was captured by Homeworld!", source = src, action=NOTIFY_ATTACK, flashwindow = FALSE, ignore_key = POLL_IGNORE_GOLEM)
	..()

/obj/effect/mob_spawn/human/tribal/special(mob/living/new_spawn)
	if(ishuman(new_spawn))
		var/mob/living/carbon/human/H = new_spawn
		H.underwear = "Nude" //You're a Tribal, partner
		if(H.gender == "female")
			H.facial_hair_style = "Shaved"
			if(firstname == "Hoomayn")
				firstname = pick("Huyana", "Tansy", "Nijlon","Hachi","Odina","Soyala","Wakanda","Sipatu","Lenmana","Chlumani",\
				"Taipa","Ayashe","Weayaya","Watseka","Tadita","Memdi","Taa","Hiawassee","Tsomah","Taini")
		else
			if(firstname == "Hoomayn")
				firstname = pick("Yahto", "Dohosan","Gawonii","Apiatan","Nixkamich","Maza Blaska","Elsu","Abornazine","Bisahalani","Ahuli",\
				"Hania","Sugmuk","Tahkeome","Mingan","Enapay","Masichuvio","Tsoai","Mikasi","Kele","Shilah","George")
		if(lastname == "Guiyz")
			lastname = pick("Miwok","Cheyenne","Sioux","Potawatomi","Omaha","Henna","Zuni","Cherokee","Kiowa","Omaha",\
			"Sioux","Kiowa","Cherokee","Kiowa","Algonquin","Dakota","Miwok","Abnaki","Navajo","Hopi","Potawatomi","Cheyenne",\
			"Melon","Doe")
		H.update_body()
		H.update_hair()
		H.fully_replace_character_name(null,"[firstname] [lastname]")
		H.lastname = lastname
		log_game("[key_name(new_spawn)] has spawned in as a [H].")
		log_admin("[key_name(new_spawn)] has spawned in as a [H].")

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
	id = /obj/item/gem
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
	flavour_text = "<span class='big bold'>You are a homeworld peridot,</span><b><br>You must start a kindergarten,\
	<br>Your goal is to create more Gems for homeworld and the colony.\
	<br>You also start with a Colony Kit containing everything you'll need.\
	<br>You also start with a Toolbelt</b>"

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

/obj/effect/mob_spawn/human/gem/jade
	name = "Jade Deposit"
	id = /obj/item/gem/jade
	mob_species = /datum/species/gem/jade
	flavour_text = "<span class='big bold'>You are a jade,</span><b><br>You must run the science lab,\
	<br>Your goal is to further the progress of Homeworld and your Colony through upgrades.</b>"

/obj/effect/mob_spawn/human/gem/jade/homeworld //Jade has been used as a gemstone and a tool-making material for for 1000s of years.
	name = "Homeworld Jade"
	mob_name = "Jade"
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "jade"
	density = FALSE
	kindergarten = FALSE
	uniform = /obj/item/clothing/under/chameleon/gem/white
	back = /obj/item/storage/backpack/duffelbag/sciencekit
	flavour_text = "<span class='big bold'>You are a homeworld jade,</span><b><br>You must start a science lab,\
	<br>Your goal is to further the progress of Homeworld and your Colony through upgrades.\
	<br>You start with a Science Kit containing the basics of R&D.</b>"

/obj/item/storage/backpack/duffelbag/sciencekit/PopulateContents()
	new /obj/item/storage/box/rndboards(src)
	new /obj/item/storage/box/rndpartsA(src)
	new /obj/item/storage/box/rndpartsB(src)
	new /obj/item/stack/cable_coil(src,30,"red")
	new /obj/item/stack/sheet/metal/fifty(src)
	new /obj/item/stack/sheet/metal/fifty(src)
	new /obj/item/stack/sheet/glass/fifty(src)
	new /obj/item/screwdriver(src)
	new /obj/item/wrench(src)

/obj/item/storage/box/rndboards
	name = "R&D Boards"

/obj/item/storage/box/rndboards/PopulateContents()
	new /obj/item/circuitboard/machine/rdserver(src)
	new /obj/item/circuitboard/machine/protolathe(src)
	new /obj/item/circuitboard/machine/destructive_analyzer(src)
	new /obj/item/circuitboard/machine/circuit_imprinter(src)
	new /obj/item/circuitboard/computer/rdconsole(src)

/obj/item/storage/box/rndpartsA
	name = "R&D Stock Parts A"

/obj/item/storage/box/rndpartsA/PopulateContents()
	new /obj/item/stock_parts/matter_bin(src)
	new /obj/item/stock_parts/matter_bin(src)
	new /obj/item/stock_parts/matter_bin(src)
	new /obj/item/stock_parts/manipulator(src)
	new /obj/item/stock_parts/manipulator(src)
	new /obj/item/stock_parts/manipulator(src)
	new /obj/item/stock_parts/manipulator(src)

/obj/item/storage/box/rndpartsB
	name = "R&D Stock Parts B"

/obj/item/storage/box/rndpartsB/PopulateContents()
	new /obj/item/stock_parts/scanning_module(src)
	new /obj/item/reagent_containers/glass/beaker(src)
	new /obj/item/reagent_containers/glass/beaker(src)
	new /obj/item/stock_parts/scanning_module(src)
	new /obj/item/stock_parts/micro_laser(src)
	new /obj/item/reagent_containers/glass/beaker(src)
	new /obj/item/reagent_containers/glass/beaker(src)

/obj/effect/mob_spawn/human/gem/pearl
	name = "Pearl Deposit"
	mob_name = "Pearl"
	mob_species = /datum/species/gem/pearl
	id = /obj/item/gem/pearl
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
	id = /obj/item/gem/agate
	mob_species = /datum/species/gem/agate
	flavour_text = "<span class='big bold'>You are an agate,</span><b><br>You act as a leader,\
	<br>The Homeworld Agate is your boss however, and you must listen to them.\
	<br>You can summon an Electric Whip that deals burn damage.</b>"

/obj/effect/mob_spawn/human/gem/rosequartz
	name = "Rose Quartz Deposit"
	mob_name = "Rose Quartz"
	id = /obj/item/gem/rosequartz
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
	id = /obj/item/gem/bismuth
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
			if(G.id == "sapphire" && H.gemstatus != "offcolor") //Off color sapphires can't predict the future.
				if(status == "Rebel")
					to_chat(H, "<span class='userdanger'>[mob_name] Cut-[gemcut] is going to betray Homeworld!")
				else if(status == "Prime")
					to_chat(H, "<span class='userdanger'>[mob_name] Cut-[gemcut] is going to emerge as a Prime Gem!")
				else if(status == "OffColor")
					to_chat(H, "<span class='userdanger'>[mob_name] Cut-[gemcut] is going to emerge as a Defective Gem!")
	..()

/obj/effect/mob_spawn/human/gem/special(mob/living/new_spawn, name)
	log_game("[key_name(new_spawn)] has spawned in as a [mob_name].")
	log_admin("[key_name(new_spawn)] has spawned in as a [mob_name].")
	new_spawn.mind.assigned_role = mob_name
	if(ishuman(new_spawn))
		var/mob/living/carbon/human/H = new_spawn
		var/datum/species/gem/G = H.dna.species
		H.gender = "female"
		H.lastname = G.name
		//if(G.height == "big")
		//	H.resize = 1.2
		//if(G.height == "small")
		//	H.resize = 0.8
		if(!name)
			H.fully_replace_character_name(null, "[mob_name] Cut-[gemcut]")
		else
			H.fully_replace_character_name(null, name)
		if(status != "Normal")
			//OH BOY! A SPECIAL GEM!
			if(status == "Rebel")
				var/rebelflavor = pick("rosequartz","revolution") //Good, Neutral.
				if(G.id == "peridot")
					H.say("I'm a traitorous clod!")
				if(rebelflavor == "rosequartz")
					to_chat(new_spawn, "<span class='notice'>You emerge from the ground, seeing the Life that's already here... You must protect it.</span>")
					new_spawn.mind.assigned_role = "Crystal Gem"
					log_game("[key_name(new_spawn)] as [mob_name] is a Crystal Gem (Antag Role).")
					log_admin("[key_name(new_spawn)] as [mob_name] is a Crystal Gem (Antag Role).")
					to_chat(new_spawn, "<span class='notice'>You are a <b>Crystal Gem</b>, find others to join your cause!</span>")
					to_chat(new_spawn, "<span class='notice'>Keep homeworld from destroying the life native to this planet.</span>")
				if(rebelflavor == "revolution")
					to_chat(new_spawn, "<span class='notice'>You emerge from the ground, seeing the Oppression of the common gem by Tyrants. You must become an independant Colony.</span>")
					new_spawn.mind.assigned_role = "Freemason"
					log_game("[key_name(new_spawn)] as [mob_name] is a Freemason (Antag Role).")
					log_admin("[key_name(new_spawn)] as [mob_name] is a Freemason (Antag Role).")
					to_chat(new_spawn, "<span class='notice'>You are a <b>Freemason</b>, find others to join your cause!</span>")
					to_chat(new_spawn, "<span class='notice'>Take over the Colony for you and your fellow Freemasons.</span>")
			if(status == "Prime")
				new_spawn.mind.assigned_role = "Prime [mob_name]"
				new_spawn.visible_message("<span class='danger'>[new_spawn] shines bright as they punch their way out of the ground!</span>")
				new_spawn.maxHealth = new_spawn.maxHealth*3
				new_spawn.mind.unconvertable = TRUE
				H.gemstatus = "prime"
				new_spawn.equip_to_slot_or_del(new/obj/item/clothing/neck/cloak/prime(null), SLOT_NECK)
				log_game("[key_name(new_spawn)] as [mob_name] is a Prime Gem.")
				log_admin("[key_name(new_spawn)] as [mob_name] is a Prime Gem.")
				to_chat(new_spawn, "<span class='notice'>You are a <b>Prime Gem</b>, You came out of the ground perfectly!</span>")
				to_chat(new_spawn, "<span class='notice'>You shall not betray the Homeworld that gave you your perfection!</span>")
			if(status == "OffColor")
				new_spawn.mind.assigned_role = "Defective [mob_name]"
				new_spawn.visible_message("<span class='danger'>[new_spawn] shines dimly as they struggle to leave the ground!</span>")
				new_spawn.maxHealth = new_spawn.maxHealth/2
				log_game("[key_name(new_spawn)] as [mob_name] is a Defective Gem.")
				log_admin("[key_name(new_spawn)] as [mob_name] is a Defective Gem.")
				H.gemstatus = "offcolor"
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
	id = /obj/item/gem/peridot
	mob_species = /datum/species/gem/peridot
	flavour_text = "<span class='big bold'>You are a peridot,</span><b><br>You help run the kindergarden,\
	<br>Your goal is to create more Gems for homeworld and the colony.</b>"

/obj/effect/mob_spawn/human/gem/bismuth
	name = "Bismuth Deposit"
	mob_name = "Bismuth"
	id = /obj/item/gem/bismuth
	mob_species = /datum/species/gem/bismuth
	flavour_text = "<span class='big bold'>You are a Bismuth,</span><b><br>You mine and build,\
	<br>Your goal is to create structures for the Empire.\
	<br>You can smelt ores in your hand!</b>"

/obj/effect/mob_spawn/human/gem/sapphire
	name = "Sapphire Deposit"
	mob_name = "Sapphire"
	id = /obj/item/gem/sapphire
	mob_species = /datum/species/gem/sapphire
	flavour_text = "<span class='big bold'>You are a sapphire,</span><b><br>You can predict the Future,\
	<br>This'll let you pinpoint Traitors, Offcolors, and Prime Gems before they even Emerge.\
	<br>You can also get the coordinates of any mob anywhere.</b>"

/obj/effect/mob_spawn/human/gem/amethyst
	name = "Amethyst Deposit"
	mob_name = "Amethyst"
	id = /obj/item/gem/amethyst
	mob_species = /datum/species/gem/amethyst
	flavour_text = "<span class='big bold'>You are an Amethyst,</span><b><br>You are a Quartz Soldier,\
	<br>You disarm your opponents with your whip and are tough to poof.</b>"