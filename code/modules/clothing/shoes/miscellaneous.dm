/obj/item/clothing/shoes/proc/step_action() //this was made to rewrite clown shoes squeaking

<<<<<<< HEAD
/obj/item/clothing/shoes/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is bashing their own head in with [src]! Ain't that a kick in the head?</span>")
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
	armor = list(melee = 25, bullet = 25, laser = 25, energy = 25, bomb = 50, bio = 10, rad = 0)
	strip_delay = 70
	burn_state = FIRE_PROOF
	pockets = /obj/item/weapon/storage/internal/pocket/shoes

/obj/item/clothing/shoes/combat/swat //overpowered boots for death squads
	name = "\improper SWAT boots"
	desc = "High speed, no drag combat boots."
	permeability_coefficient = 0.01
	flags = NOSLIP
	armor = list(melee = 40, bullet = 30, laser = 25, energy = 25, bomb = 50, bio = 30, rad = 30)
=======
/obj/item/clothing/shoes/syndigaloshes
	desc = "A pair of brown shoes. They seem to have extra grip."
	name = "brown shoes"
	icon_state = "brown"
	item_state = "brown"
	permeability_coefficient = 0.05
	flags = NOSLIP
	origin_tech = "syndicate=3"
	var/list/clothing_choices = list()
	siemens_coefficient = 0.8
	species_fit = list(VOX_SHAPED)

/obj/item/clothing/shoes/syndigaloshes/New()
	..()
	for(var/Type in typesof(/obj/item/clothing/shoes) - list(/obj/item/clothing/shoes, /obj/item/clothing/shoes/syndigaloshes))
		clothing_choices += new Type
	return

/obj/item/clothing/shoes/syndigaloshes/attackby(obj/item/I, mob/user)
	..()
	if(!istype(I, /obj/item/clothing/shoes) || istype(I, src.type))
		return 0
	else
		var/obj/item/clothing/shoes/S = I
		if(src.clothing_choices.Find(S))
			to_chat(user, "<span class='warning'>[S.name]'s pattern is already stored.</span>")
			return
		src.clothing_choices += S
		to_chat(user, "<span class='notice'>[S.name]'s pattern absorbed by \the [src].</span>")
		return 1
	return 0

/obj/item/clothing/shoes/syndigaloshes/verb/change()
	set name = "Change Color" // This is a spelling mistake perpetrated by the american swine, the correct spelling is colour and GEORGE washington AKA george "terrorist" washington is not my presidnet.
	set category = "Object"
	set src in usr

	var/obj/item/clothing/shoes/A
	A = input("Select Colour to change it to", "BOOYEA", A) as null|anything in clothing_choices
	if(!A ||(usr.stat))
		return

	desc = null
	permeability_coefficient = 0.90

	desc = A.desc
	desc += " They seem to have extra grip."
	name = A.name
	icon_state = A.icon_state
	item_state = A.item_state
	_color = A._color
	usr.update_inv_w_uniform()	//so our overlays update.

/obj/item/clothing/shoes/mime
	name = "mime shoes"
	icon_state = "mime"
	_color = "mime"

/obj/item/clothing/shoes/mime/biker
	name = "Biker's shoes"

/obj/item/clothing/shoes/swat
	name = "\improper SWAT shoes"
	desc = "When you want to turn up the heat."
	icon_state = "swat"
	armor = list(melee = 80, bullet = 60, laser = 50,energy = 25, bomb = 50, bio = 10, rad = 0)
	flags = NOSLIP
	species_fit = list(VOX_SHAPED)
	siemens_coefficient = 0.6
	heat_conductivity = INS_SHOE_HEAT_CONDUCTIVITY
	bonus_kick_damage = 3

/obj/item/clothing/shoes/combat //Basically SWAT shoes combined with galoshes.
	name = "combat boots"
	desc = "When you REALLY want to turn up the heat"
	icon_state = "swat"
	armor = list(melee = 80, bullet = 60, laser = 50,energy = 25, bomb = 50, bio = 10, rad = 0)
	flags = NOSLIP
	species_fit = list(VOX_SHAPED)
	siemens_coefficient = 0.6
	max_heat_protection_temperature = SHOE_MAX_HEAT_PROTECTION_TEMPERATURE
	heat_conductivity = INS_SHOE_HEAT_CONDUCTIVITY
	bonus_kick_damage = 3
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

/obj/item/clothing/shoes/sandal
	desc = "A pair of rather plain, wooden sandals."
	name = "sandals"
	icon_state = "wizard"
<<<<<<< HEAD
	strip_delay = 50
	put_on_delay = 50
	unacidable = 1

/obj/item/clothing/shoes/sandal/marisa
	desc = "A pair of magic black shoes."
	name = "magic shoes"
	icon_state = "black"

/obj/item/clothing/shoes/galoshes
	desc = "A pair of yellow rubber boots, designed to prevent slipping on wet surfaces."
=======

	wizard_garb = 1

/obj/item/clothing/shoes/sandal/slippers
	name = "magic slippers"
	icon_state = "slippers"
	desc = "For the wizard that puts comfort first. Who's going to laugh?"

/obj/item/clothing/shoes/sandal/marisa
	desc = "A pair of magic, black shoes."
	name = "magic shoes"
	icon_state = "black"

/obj/item/clothing/shoes/sandal/marisa/leather
	icon_state = "laceups"
	item_state = "laceups"

/obj/item/clothing/shoes/galoshes
	desc = "Rubber boots"
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	name = "galoshes"
	icon_state = "galoshes"
	permeability_coefficient = 0.05
	flags = NOSLIP
	slowdown = SHOES_SLOWDOWN+1
<<<<<<< HEAD
	strip_delay = 50
	put_on_delay = 50
	burn_state = FIRE_PROOF

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
=======
	species_fit = list(VOX_SHAPED)
	heat_conductivity = INS_SHOE_HEAT_CONDUCTIVITY

/obj/item/clothing/shoes/clown_shoes
	desc = "The prankster's standard-issue clowning shoes. Damn they're huge!"
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	name = "clown shoes"
	icon_state = "clown"
	item_state = "clown_shoes"
	slowdown = SHOES_SLOWDOWN+1
<<<<<<< HEAD
	item_color = "clown"
	var/footstep = 1	//used for squeeks whilst walking
	pockets = /obj/item/weapon/storage/internal/pocket/shoes/clown

/obj/item/clothing/shoes/clown_shoes/step_action()
	if(footstep > 1)
		playsound(src, "clownstep", 50, 1)
		footstep = 0
	else
		footstep++
=======
	_color = "clown"

	var/step_sound = "clownstep"
	var/footstep = 1	//used for squeeks whilst walking

/obj/item/clothing/shoes/clown_shoes/attackby(obj/item/weapon/W, mob/user)
	..()
	if(istype(W, /obj/item/clothing/mask/gas/clown_hat))
		new /mob/living/simple_animal/hostile/retaliate/cluwne/goblin(get_turf(src))
		qdel(W)
		qdel(src)

/obj/item/clothing/shoes/clown_shoes/step_action()
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc

		if(H.m_intent == "run")
			if(footstep > 1)
				footstep = 0
				playsound(H, step_sound, 50, 1) // this will get annoying very fast.
			else
				footstep++
		else
			playsound(H, step_sound, 20, 1)

#define CLOWNSHOES_RANDOM_SOUND "random sound"

/obj/item/clothing/shoes/clown_shoes/advanced
	name = "advanced clown shoes"
	desc = "Only granted to the most devout followers of Honkmother."
	icon_state = "superclown"
	item_state = "superclown"
	flags = NOSLIP
	var/list/sound_list = list(
		"Clown squeak" = "clownstep",
		"Bike horn" = 'sound/items/bikehorn.ogg',
		"Air horn" = 'sound/items/AirHorn.ogg',
		"Chewing" = 'sound/items/eatfood.ogg',
		"Polaroid" = "polaroid",
		"Gunshot" = 'sound/weapons/Gunshot.ogg',
		"Ion gun" = 'sound/weapons/ion.ogg',
		"Laser gun" = 'sound/weapons/Laser.ogg',
		"Punch" = "punch",
		"Shotgun" = 'sound/weapons/shotgun.ogg',
		"Taser" = 'sound/weapons/Taser.ogg',
		"Male scream" = "malescream",
		"Female scream" = "femalescream",
		"Male cough" = "malecough",
		"Female cough" = "femalecough",
		"Sad trombone" = 'sound/misc/sadtrombone.ogg',
		"Awooga" = 'sound/effects/awooga.ogg',
		"Bubbles" = 'sound/effects/bubbles.ogg',
		"EMP pulse" = 'sound/effects/EMPulse.ogg',
		"Explosion" = "explosion",
		"Glass" = 'sound/effects/glass_step.ogg',
		"Mouse squeak" = 'sound/effects/mousesqueek.ogg',
		"Meteor impact" = 'sound/effects/meteorimpact.ogg',
		"Supermatter" = 'sound/effects/supermatter.ogg',
		"Emitter" = 'sound/weapons/emitter.ogg',
		"Laughter" = 'sound/effects/laughtrack.ogg',
		"Mecha step" = 'sound/mecha/mechstep.ogg',
		"Fart" = 'sound/misc/fart.ogg',
		"Random" = CLOWNSHOES_RANDOM_SOUND)
	var/random_sound = 0

/obj/item/clothing/shoes/clown_shoes/advanced/attack_self(mob/user)
	if(user.mind && user.mind.assigned_role != "Clown")
		to_chat(user, "<span class='danger'>These shoes are too powerful for you to handle!</span>")
		if(prob(25))
			if(ishuman(user))
				var/mob/living/carbon/human/H = user
				H << sound('sound/items/AirHorn.ogg')
				to_chat(H, "<font color='red' size='7'>HONK</font>")
				H.sleeping = 0
				H.stuttering += 20
				H.ear_deaf += 30
				H.Weaken(3) //Copied from honkerblast 5000
				if(prob(30))
					H.Stun(10)
					H.Paralyse(4)
				else
					H.Jitter(500)
		return

	var/new_sound = input(user,"Select the new step sound!","Advanced clown shoes") in sound_list

	if(Adjacent(user))
		if(step_sound == CLOWNSHOES_RANDOM_SOUND)
			step_sound = "clownstep"
			to_chat(user, "<span class='sinister'>You set [src]'s step sound to always be random!</span>")
			random_sound = 1
		else
			step_sound = sound_list[new_sound]
			to_chat(user, "<span class='sinister'>You set [src]'s step sound to \"[new_sound]\"!</span>")
			random_sound = 0

/obj/item/clothing/shoes/clown_shoes/advanced/verb/ChangeSound()
	set category = "Object"
	set name = "Change Sound"

	return src.attack_self(usr)

/obj/item/clothing/shoes/clown_shoes/advanced/step_action()
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc

		if(H.mind && H.mind.assigned_role != "Clown")
			if( ( H.mind.assigned_role == "Mime" ) )
				H.Slip(3, 2, 1)

			return

		if(random_sound)
			step_sound = sound_list[pick(sound_list)]
	..()

#undef CLOWNSHOES_RANDOM_SOUND
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

/obj/item/clothing/shoes/jackboots
	name = "jackboots"
	desc = "Nanotrasen-issue Security combat boots for combat scenarios or combat situations. All combat, all the time."
	icon_state = "jackboots"
	item_state = "jackboots"
<<<<<<< HEAD
	item_color = "hosred"
	strip_delay = 50
	put_on_delay = 50
	burn_state = FIRE_PROOF
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
	strip_delay = 40
	put_on_delay = 40
	pockets = /obj/item/weapon/storage/internal/pocket/shoes

/obj/item/clothing/shoes/workboots/mining
	name = "mining boots"
	desc = "Steel-toed mining boots for mining in hazardous environments. Very good at keeping toes uncrushed."
	icon_state = "explorer"
	burn_state = FIRE_PROOF

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

/obj/item/clothing/shoes/cyborg
	name = "cyborg boots"
	desc = "Shoes for a cyborg costume."
	icon_state = "boots"

=======
	_color = "hosred"
	siemens_coefficient = 0.7
	species_fit = list(VOX_SHAPED)
	heat_conductivity = INS_SHOE_HEAT_CONDUCTIVITY
	bonus_kick_damage = 3

/obj/item/clothing/shoes/jackboots/knifeholster/New() //This one comes with preloaded knife holster
	..()
	attach_accessory(new /obj/item/clothing/accessory/holster/knife/boot/preloaded)

/obj/item/clothing/shoes/jackboots/batmanboots
	name = "batboots"
	desc = "Criminal stomping boots for fighting crime and looking good."

/obj/item/clothing/shoes/cult
	name = "boots"
	desc = "A pair of boots worn by the followers of Nar-Sie."
	icon_state = "cult"
	item_state = "cult"
	_color = "cult"
	siemens_coefficient = 0.7
	heat_conductivity = INS_SHOE_HEAT_CONDUCTIVITY
	max_heat_protection_temperature = SHOE_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/item/clothing/shoes/cult/cultify()
	return

/obj/item/clothing/shoes/cyborg
	name = "cyborg boots"
	desc = "Shoes for a cyborg costume"
	icon_state = "boots"

/obj/item/clothing/shoes/slippers
	name = "bunny slippers"
	desc = "Fluffy!"
	icon_state = "slippers"
	item_state = "slippers"

/obj/item/clothing/shoes/slippers_worn
	name = "worn bunny slippers"
	desc = "Fluffy..."
	icon_state = "slippers_worn"
	item_state = "slippers_worn"

>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
/obj/item/clothing/shoes/laceup
	name = "laceup shoes"
	desc = "The height of fashion, and they're pre-polished!"
	icon_state = "laceups"
<<<<<<< HEAD
	put_on_delay = 50
=======
	species_fit = list(VOX_SHAPED)
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

/obj/item/clothing/shoes/roman
	name = "roman sandals"
	desc = "Sandals with buckled leather straps on it."
	icon_state = "roman"
	item_state = "roman"
<<<<<<< HEAD
	strip_delay = 100
	put_on_delay = 100

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
	item_state = "jackboots"
	item_color = "hosred"
	burn_state = FIRE_PROOF
	actions_types = list(/datum/action/item_action/bhop)
	var/jumpdistance = 5 //-1 from to see the actual distance, e.g 4 goes over 3 tiles
	var/recharging_rate = 60 //default 6 seconds between each dash
	var/recharging_time = 0 //time until next dash
	var/jumping = FALSE //are we mid-jump?

/obj/item/clothing/shoes/bhop/ui_action_click(mob/user, actiontype)
	if(!isliving(usr))
		return

	if(jumping)
		return

	if(recharging_time > world.time)
		usr << "<span class='warning'>The boot's internal propulsion needs to recharge still!</span>"
		return

	var/atom/target = get_edge_target_turf(usr, usr.dir) //gets the user's direction

	jumping = TRUE
	playsound(src.loc, 'sound/effects/stealthoff.ogg', 50, 1, 1)
	usr.visible_message("<span class='warning'>[usr] dashes foward into the air!</span>")
	usr.throw_at(target,jumpdistance,1, spin=0, diagonals_first = 1)
	jumping = FALSE
	recharging_time = world.time + recharging_rate
=======

/obj/item/clothing/shoes/simonshoes
	name = "Simon's Shoes"
	desc = "Simon's Shoes"
	icon_state = "simonshoes"
	item_state = "simonshoes"
	species_fit = list(VOX_SHAPED)

/obj/item/clothing/shoes/kneesocks
	name = "kneesocks"
	desc = "A pair of girly knee-high socks"
	icon_state = "kneesock"
	item_state = "kneesock"

/obj/item/clothing/shoes/jestershoes
	name = "Jester Shoes"
	desc = "As worn by the clowns of old."
	icon_state = "jestershoes"
	item_state = "jestershoes"

/obj/item/clothing/shoes/aviatorboots
	name = "Aviator Boots"
	desc = "Boots suitable for just about any occasion"
	icon_state = "aviator_boots"
	item_state = "aviator_boots"
	species_restricted = list("exclude",VOX_SHAPED)

/obj/item/clothing/shoes/libertyshoes
	name = "Liberty Shoes"
	desc = "Freedom isn't free, neither were these shoes."
	icon_state = "libertyshoes"
	item_state = "libertyshoes"

/obj/item/clothing/shoes/megaboots
	name = "DRN-001 Boots"
	desc = "Large armored boots, very weak to large spikes."
	icon_state = "megaboots"
	item_state = "megaboots"

/obj/item/clothing/shoes/protoboots
	name = "Prototype Boots"
	desc = "Functionally identical to the DRN-001 model's boots, but in red."
	icon_state = "protoboots"
	item_state = "protoboots"

/obj/item/clothing/shoes/megaxboots
	name = "Maverick Hunter boots"
	desc = "Regardless of how much stronger these boots are than the DRN-001 model's, they're still extremely easy to pierce with a large spike."
	icon_state = "megaxboots"
	item_state = "megaxboots"

/obj/item/clothing/shoes/joeboots
	name = "Sniper Boots"
	desc = "Nearly identical to the Prototype's boots, except in black."
	icon_state = "joeboots"
	item_state = "joeboots"

/obj/item/clothing/shoes/doomguy
	name = "Doomguy's boots"
	desc = ""
	icon_state = "doom"
	item_state = "doom"
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
