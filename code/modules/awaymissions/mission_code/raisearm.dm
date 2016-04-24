/*
 *Yes, this is literally a mission about the crew fighting mecha-hitler and his army of geo-nazis.
 *No, I have no regrets about making this.
 */

 //now 100% more PC just for cheridan

/*
 *Mecha Hitler himself
 */

/mob/living/simple_animal/hostile/syndicate/mecha_pilot/roboheil //hitler's head in a jar with a spider walker sort of thing
	name = "Hitler's Head in a Jar"
	icon_state = "roboheil"
	icon_living = "roboheil"
	desc = "Don't let it get away!"
	maxHealth = 50
	health = 50
	retreat_distance = 3
	minimum_distance = 2
	faction = list("german")
	projectilesound = 'sound/weapons/Gunshot_smg.ogg'
	deathmessage = "Mecha Hitler's body activates its self-destruct function!"
	loot = list(/obj/effect/gibspawner/robot)
	wanted_objects = list()
	search_objects = 0
	spawn_mecha_type = /obj/mecha/combat/marauder/mauler/roboh

/*
 *Mecha Hitler's Mech
 */

/obj/mecha/combat/marauder/mauler/roboh
	name = "\improper Mecha-Hitler"
	desc = "A heavily modified marauder mech with reinforced reflective plating."
	icon_state = "mauler"
	health = 4000
	deflect_chance = 40
	damage_absorption = list("brute"=0.6,"fire"=0.3,"bullet"=0.7,"laser"=0.4,"energy"=0.5,"bomb"=0.5)
	force = 75
	operation_req_access = list(access_syndicate)
	wreckage = /obj/structure/mecha_wreckage/mauler


/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/missile_rack/tier2
	name = "\improper SRM-16 missile rack"
	desc = "A modified version of the SMR-8, equipped with an additional 8 racks and a more powerful missile."
	icon_state = "mecha_missilerack"
	projectile = /obj/item/missile/tier2
	fire_sound = 'sound/weapons/grenadelaunch.ogg'
	projectiles = 16
	projectile_energy_cost = 1000
	equip_cooldown = 60

/obj/item/missile/tier2
	throwforce = 25

/obj/item/missile/tier2/throw_impact(atom/hit_atom)
	if(primed)
		explosion(hit_atom, 0, 0, 4, 6, 3)
		qdel(src)
	else
		..()


/obj/mecha/combat/marauder/mauler/roboh/New()
	..()
	var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/lmg
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/missile_rack/tier2
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/energy/pulse
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/tesla_energy_relay
	ME.attach(src)
	return

/*
 *Geo-Nazies
 */

/mob/living/simple_animal/hostile/nsoldier
	name = "German World War II Reenactor"
	desc = "A VERY enthusiastic WWII reenactor."
	icon_state = "nsoldier"
	icon_living = "nsoldier"
	speak_chance = 0
	turns_per_move = 5
	response_help = "pokes"
	response_disarm = "shoves"
	response_harm = "hits"
	speed = 0
	stat_attack = 1
	robust_searching = 1
	maxHealth = 100
	health = 100
	harm_intent_damage = 10
	melee_damage_lower = 10
	melee_damage_upper = 15
	attacktext = "punches"
	attack_sound = 'sound/weapons/punch1.ogg'
	a_intent = "harm"
	loot = list(/obj/effect/mob_spawn/human/corpse/nsoldier)
	atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 15
	faction = list("german")
	check_friendly_fire = 1
	status_flags = CANPUSH
	del_on_death = 1

/mob/living/simple_animal/hostile/nsoldier/ranged
	ranged = 1
	rapid = 1
	retreat_distance = 5
	minimum_distance = 5
	icon_state = "nsoldierranged"
	icon_living = "nsoldierranged"
	casingtype = /obj/item/ammo_casing/c45nostamina
	projectilesound = 'sound/weapons/Gunshot_smg.ogg'

/mob/living/simple_animal/hostile/nsoldier/melee //hulk nazi with really buff biceps for added effect
	name = "Hulking German World War II Reenactor"
	icon_state = "nsoldierbuff"
	icon_living = "nsoldierbuff"
	stat_attack = 0 //dumb brutes can't tell the difference between unconcious and dead
	speed = 4
	maxHealth = 200
	health = 200
	force_threshold = 10
	harm_intent_damage = 25
	melee_damage_lower = 25
	melee_damage_upper = 30
	environment_smash = 2
	attacktext = "slams"
	deathmessage = "The Geo-Nazi's body collapses in on itself from the strain!"
	loot = list(/obj/effect/gibspawner/human)

/mob/living/simple_animal/hostile/nsoldier/melee/AttackingTarget()
	..()
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		if(prob(40)) //do not fuck with these guys in CQC
			C.Weaken(3)
			C.adjustBruteLoss(10)
			C.visible_message("<span class='danger'>\The [src] smashes \the [C] into the ground!</span>", \
					"<span class='userdanger'>\The [src] smashes you into the ground!</span>")
			src.say(pick("RAAAAAGGHHHH!!!","AAAARRRGGHHHH!!!","RRRAAUUUGGHH!!!"))


/mob/living/simple_animal/hostile/nsoldier/bomber //think serious sam's kamikazes but with mini-hitlers
	name = "Mini-Führer"
	desc = "A small, robotic recreation of the Führer himself, it seems like he wants to tell you something."
	icon_state = "miniheil"
	icon_living = "miniheil"
	speed = 1
	maxHealth = 25
	health = 25
	harm_intent_damage = 5
	melee_damage_lower = 5
	melee_damage_upper = 7
	attacktext = "heils"
	deathmessage = "The Mini-Führer explodes!"
	loot = list(/obj/effect/gibspawner/robot)

/mob/living/simple_animal/hostile/nsoldier/bomber/AttackingTarget()
	..()
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		if(prob(90))
			C.Weaken(2)
			src.say("HEIL HITLER!")
			explosion(src, 0, 0, 2, 3, 2)
			src.gib()

/mob/living/simple_animal/hostile/spawner/heilfactory
	name = "world war II memorabilia production facility"
	icon = 'icons/obj/mining.dmi'
	icon_state = "bin_full"
	spawn_text = "marches out of"
	max_mobs = 3
	mob_type = /mob/living/simple_animal/hostile/nsoldier/bomber
	faction = list("german")

/*
 *Structure-related stuff
 */

/turf/open/floor/plating/asteroid/moon
	name = "lunar floor"
	baseturf = /turf/open/floor/plating/asteroid/moon
	icon = 'icons/turf/floors.dmi'
	icon_state = "moon"
	icon_plating = "moon"
	environment_type = "moon"

/turf/open/floor/plating/asteroid/moon/airless
	baseturf = /turf/open/floor/plating/asteroid/moon/airless
	oxygen = 0.01
	nitrogen = 0.01
	temperature = TCMB

/turf/open/floor/plating/marble
	name = "marble flooring"
	icon_state = "marble"
	broken_states = list("marblebroken")
	burnt_states = list("marblescorched")


/obj/effect/mob_spawn/human/corpse/nsoldier
	name = "Geo-Nazi"
	uniform =  /obj/item/clothing/under/nsoldier
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	mask = /obj/item/clothing/mask/gas
	helmet = /obj/item/clothing/head/helmet/stalhelm
	has_id = 0


//space billboards

/obj/structure/billboard
	name = "Space billboard"
	desc = "The pinnancle of space-advertisement."
	icon = 'icons/obj//banters/billboard.dmi'
	icon_state = "generic"
	density = 0
	layer = 10
	anchored = 1

/obj/structure/billboard/random

/obj/structure/billboard/random/New()
	..()
	icon_state = "billboard_[rand(1,5)]"


//pillars

/obj/structure/pillar
	name = "pillar"
	desc = "A reaaaaaally tall pillar"
	icon = 'icons/obj/pillar.dmi'
	icon_state = "pillarbottom"
	anchored = 1
	density = 1
	layer = 10

/obj/structure/pillar/broken
	name = "broken pillar"
	desc = "The remains of a pillar."
	icon = 'icons/obj/pillarbroke.dmi'
	icon_state = "pillarbroke"


//banners

/obj/structure/banner
	name = "banner"
	desc = "A piece of cloth hung up on the wall."
	icon = 'icons/obj/banters/banter.dmi'
	icon_state = "generic"
	anchored = 1
	density = 0
	layer = 10.1

/obj/structure/banner/heil
	name = "nazi banner"
	desc = "A banner depicting a rather rude image. Has a strange, smokey smell to it."
	icon_state = "heil"

/obj/structure/banner/cyka
	name = "russian banner"
	desc = "A banner. Smells faintly of vodka."
	icon_state = "cyka"

/obj/structure/banner/assblastusa
	name = "patriotic banner"
	desc = "A banner depicting a bald eagle."
	icon_state = "assblastusa"


//liberty

/obj/structure/displaycase/liberty
	name = "display case"

/obj/structure/displaycase/liberty/New()
	..()
	var/obj/item/weapon/gun/projectile/sniper_rifle/S = new /obj/item/weapon/gun/projectile/sniper_rifle(src)
	S.name = "Liberation"
	S.desc = "A high-powered rifle with the name '<i>liberation</i>' scratched onto the side. Below it are several tally marks."
	showpiece = S
	update_icon()


//flags

/obj/structure/flag
	name = "french flag"
	desc = "A white sheet hung up on the side of a wall."
	icon = 'icons/obj/banters/flags.dmi'
	icon_state = "blank"
	anchored = 1
	density = 0
	burn_state = FLAMMABLE
	burntime = 30
	var/ripped = 0

/obj/structure/flag/assblastusa
	name = "dusty flag"
	desc = "A striped relic of a time long before. You think you hear the screech of an eagle in the distance."
	icon_state = "assblastusa"

/obj/structure/flag/germany
	name = "dusty flag"
	desc = "A striped relic of a time long before. The stripes seem extremely organized."
	icon_state = "germany"

/obj/structure/flag/cyka
	name = "dusty flag"
	desc = "A striped relic of a time long before. Smells faintly of vodka."
	icon_state = "cyka"

/obj/structure/flag/attack_hand(mob/user)
	if(ripped)
		return
	var/temp_loc = user.loc
	if((user.loc != temp_loc) || ripped )
		return
	visible_message("[user] tears [src] in half!" )
	playsound(src.loc, 'sound/items/poster_ripped.ogg', 100, 1)
	ripped = 1
	icon_state = "ripped"
	name = "ripped flag"
	desc = "The poor remains of a desecrated flag."
	add_fingerprint(user)

//portraits

/obj/structure/portrait
	name = "portrait"
	desc = "A framed portrait."
	icon = 'icons/obj/banters/portraits.dmi'
	icon_state = "blank"

/*
 *Areas
 */

/area/awaymission/raisearm
	name = "Lunar Plains"
	icon_state = "away"
	requires_power = 0
	luminosity = 1
	lighting_use_dynamic = DYNAMIC_LIGHTING_ENABLED

/area/awaymission/raisearm/mechahitler
	name = "Führer's Secret Lair"

/area/awaymission/raisearm/ship
	name = "Derelict Ship"
	requires_power = 1

/area/awaymission/raisearm/mainhq
	name = "Reenactment HQ"
	icon_state = "away3"
	requires_power = 1

/area/awaymission/raisearm/outpost
	name = "Outpost"
	icon_state = "away3"
	requires_power = 1

/area/awaymission/raisearm/random
	name = "???"
	icon_state = "away2"
	requires_power = 1

/*
 *Items
 */

/obj/item/weapon/paper/raisearm
	name = "map coordinates"
	icon_state = "docs_generic"
	info = "A detailed layout of the nearby expanse of space and various areas of potential intrest. A section of the map in the lower-right corner is circled several times with some cryllic writing.</i>"

/obj/item/weapon/paper/raisearm/update_icon()
	return


//clothes

//S.S clothing, credit to /vg/station (Heredth made the pull request)
/obj/item/clothing/under/nsoldier
	name = "dusty uniform"
	desc = "A dusty old uniform, a relic from a time before."
	icon_state = "soldieruniform"
	item_state = "soldieruniform"
	item_color = "soldieruniform"
	armor = list(melee = 10, bullet = 5, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	strip_delay = 50

/obj/item/clothing/under/nsoldier/officer
	name = "dusty uniform"
	desc = "A dusty old uniform, a relic from a time before. This one looks more official."
	icon_state = "officeruniform"
	item_state = "officeruniform"
	item_color = "officeruniform"
	armor = list(melee = 15, bullet = 10, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	strip_delay = 60

/obj/item/clothing/head/helmet/stalhelm
	name = "Stalhelm"
	desc = "A hard military helmet, seems dusty."
	icon_state = "stalhelm"
	item_state = "stalhelm"
	armor = list(melee = 15, bullet = 10, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	strip_delay = 30

/obj/item/clothing/head/helmet/panzer
	name = "Panzer Cap"
	desc = "A fancy-looking military cap."
	icon_state = "panzercap"
	item_state = "panzercap"

/obj/item/clothing/head/helmet/naziofficer
	name = "Officer Cap"
	desc = "A cap fit for a commanding officer."
	icon_state = "officercap"
	item_state = "officercap"
	armor = list(melee = 20, bullet = 15, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	strip_delay = 60

//guns

/obj/item/weapon/gun/projectile/automatic/pistol/APS/ra_APS

/obj/item/weapon/gun/projectile/automatic/pistol/APS/ra_APS/New()
	..()
	for(var/ammo in magazine.stored_ammo)
		if(prob(55))
			magazine.stored_ammo -= ammo


/obj/item/weapon/gun/projectile/automatic/pistol/deagle/ra_deagle

/obj/item/weapon/gun/projectile/automatic/pistol/deagle/ra_deagle/New()
	..()
	for(var/ammo in magazine.stored_ammo)
		if(prob(75))
			magazine.stored_ammo -= ammo


/obj/item/weapon/gun/projectile/revolver/nagant/ra_nagant

/obj/item/weapon/gun/projectile/revolver/nagant/ra_nagant/New()
	..()
	for(var/ammo in magazine.stored_ammo)
		if(prob(95))
			magazine.stored_ammo -= ammo