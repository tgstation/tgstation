//The chests dropped by mob spawner tendrils. Also contains associated loot.

/obj/structure/closet/crate/necropolis
	name = "necropolis chest"
	desc = "It's watching you closely."
	icon_state = "necrocrate"
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/structure/closet/crate/necropolis/tendril
	desc = "It's watching you suspiciously."

/obj/structure/closet/crate/necropolis/tendril/New()
	..()
	var/loot = rand(1,25)
	switch(loot)
		if(1)
			new /obj/item/device/shared_storage/red(src)
		if(2)
			new /obj/item/clothing/suit/space/hardsuit/cult(src)
		if(3)
			new /obj/item/device/soulstone/anybody(src)
		if(4)
			new /obj/item/weapon/katana/cursed(src)
		if(5)
			new /obj/item/clothing/glasses/godeye(src)
		if(6)
			new /obj/item/weapon/reagent_containers/glass/bottle/potion/flight(src)
		if(7)
			new /obj/item/weapon/pickaxe/diamond(src)
		if(8)
			new /obj/item/clothing/head/culthood(src)
			new /obj/item/clothing/suit/cultrobes(src)
			new /obj/item/weapon/bedsheet/cult(src)
		if(9)
			new /obj/item/organ/brain/alien(src)
		if(10)
			new /obj/item/organ/heart/cursed(src)
		if(11)
			new /obj/item/ship_in_a_bottle(src)
		if(12)
			new /obj/item/clothing/suit/space/hardsuit/ert/paranormal/beserker(src)
		if(13)
			new /obj/item/weapon/sord(src)
		if(14)
			new /obj/item/weapon/nullrod/scythe/talking(src)
		if(15)
			new /obj/item/weapon/nullrod/armblade(src)
		if(16)
			new /obj/item/weapon/guardiancreator(src)
		if(17)
			new /obj/item/borg/upgrade/modkit/aoe/turfs/andmobs(src)
		if(18)
			new /obj/item/device/warp_cube/red(src)
		if(19)
			new /obj/item/device/wisp_lantern(src)
		if(20)
			new /obj/item/device/immortality_talisman(src)
		if(21)
			new /obj/item/weapon/gun/magic/hook(src)
		if(22)
			new /obj/item/voodoo(src)
		if(23)
			new /obj/item/weapon/grenade/clusterbuster/inferno(src)
		if(24)
			new /obj/item/weapon/reagent_containers/food/drinks/bottle/holywater/hell(src)
			new /obj/item/clothing/suit/space/hardsuit/ert/paranormal/inquisitor(src)
		if(25)
			new /obj/item/weapon/spellbook/oneuse/summonitem(src)



//Spooky special loot

/obj/item/device/wisp_lantern
	name = "spooky lantern"
	desc = "This lantern gives off no light, but is home to a friendly wisp."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "lantern-blue"
	var/obj/effect/wisp/wisp

/obj/item/device/wisp_lantern/attack_self(mob/user)
	if(!wisp)
		user << "<span class='warning'>The wisp has gone missing!</span>"
		return
	if(wisp.loc == src)
		user << "<span class='notice'>You release the wisp. It begins to bob around your head.</span>"
		user.sight |= SEE_MOBS
		icon_state = "lantern"
		wisp.orbit(user, 20)
		feedback_add_details("wisp_lantern","F") // freed

	else
		user << "<span class='notice'>You return the wisp to the lantern.</span>"

		if(wisp.orbiting)
			var/atom/A = wisp.orbiting.orbiting
			if(isliving(A))
				var/mob/living/M = A
				M.sight &= ~SEE_MOBS
				M << "<span class='notice'>Your vision returns to normal.</span>"

		wisp.stop_orbit()
		wisp.loc = src
		icon_state = "lantern-blue"
		feedback_add_details("wisp_lantern","R") // returned

/obj/item/device/wisp_lantern/New()
	..()
	wisp = new(src)

/obj/item/device/wisp_lantern/Destroy()
	if(wisp)
		if(wisp.loc == src)
			qdel(wisp)
		else
			wisp.visible_message("<span class='notice'>[wisp] has a sad feeling for a moment, then it passes.</span>")
	..()

//Wisp Lantern
/obj/effect/wisp
	name = "friendly wisp"
	desc = "Happy to light your way."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "orb"
	luminosity = 7
	layer = ABOVE_ALL_MOB_LAYER

/obj/item/device/warp_cube
	name = "blue cube"
	desc = "A mysterious blue cube."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "blue_cube"
	var/obj/item/device/warp_cube/linked


//Red/Blue Cubes

/obj/item/device/warp_cube/attack_self(mob/user)
	if(!linked)
		user << "[src] fizzles uselessly."
	if(linked.z == CENTCOMM)
		user << "[linked] is somewhere you can't go."

	PoolOrNew(/obj/effect/particle_effect/smoke, user.loc)
	user.forceMove(get_turf(linked))
	feedback_add_details("warp_cube","[src.type]")
	PoolOrNew(/obj/effect/particle_effect/smoke, user.loc)

/obj/item/device/warp_cube/red
	name = "red cube"
	desc = "A mysterious red cube."
	icon_state = "red_cube"

/obj/item/device/warp_cube/red/New()
	..()
	if(!linked)
		var/obj/item/device/warp_cube/blue = new(src.loc)
		linked = blue
		blue.linked = src

//Meat Hook
/obj/item/weapon/gun/magic/hook
	name = "meat hook"
	desc = "Mid or feed."
	ammo_type = /obj/item/ammo_casing/magic/hook
	icon_state = "hook"
	item_state = "chain"
	fire_sound = 'sound/weapons/batonextend.ogg'
	max_charges = 1
	flags = NOBLUDGEON
	force = 18

/obj/item/ammo_casing/magic/hook
	name = "hook"
	desc = "a hook."
	projectile_type = /obj/item/projectile/hook
	caliber = "hook"
	icon_state = "hook"

/obj/item/projectile/hook
	name = "hook"
	icon_state = "hook"
	icon = 'icons/obj/lavaland/artefacts.dmi'
	pass_flags = PASSTABLE
	damage = 25
	armour_penetration = 100
	damage_type = BRUTE
	hitsound = 'sound/effects/splat.ogg'
	weaken = 3
	var/chain

/obj/item/projectile/hook/fire(setAngle)
	if(firer)
		chain = firer.Beam(src, icon_state = "chain", time = INFINITY, maxdistance = INFINITY)
	..()

/obj/item/projectile/hook/on_hit(atom/target)
	. = ..()
	if(isliving(target))
		var/mob/living/L = target
		if(!L.anchored)
			L.visible_message("<span class='danger'>[L] is snagged by [firer]'s hook!</span>")
			L.forceMove(get_turf(firer))

/obj/item/projectile/hook/Destroy()
	qdel(chain)
	return ..()


//Immortality Talisman
/obj/item/device/immortality_talisman
	name = "Immortality Talisman"
	desc = "A dread talisman that can render you completely invulnerable."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "talisman"
	actions_types = list(/datum/action/item_action/immortality)
	var/cooldown = 0

/datum/action/item_action/immortality
	name = "Immortality"

/obj/item/device/immortality_talisman/Destroy(force)
	if(force)
		. = ..()
	else
		return QDEL_HINT_LETMELIVE

/obj/item/device/immortality_talisman/attack_self(mob/user)
	if(cooldown < world.time)
		feedback_add_details("immortality_talisman","U") // usage
		cooldown = world.time + 600
		user.visible_message("<span class='danger'>[user] vanishes from reality, leaving a a hole in [user.p_their()] place!</span>")
		var/obj/effect/immortality_talisman/Z = new(get_turf(src.loc))
		Z.name = "hole in reality"
		Z.desc = "It's shaped an awful lot like [user.name]."
		Z.setDir(user.dir)
		user.forceMove(Z)
		user.notransform = 1
		user.status_flags |= GODMODE
		spawn(100)
			user.status_flags &= ~GODMODE
			user.notransform = 0
			user.forceMove(get_turf(Z))
			user.visible_message("<span class='danger'>[user] pops back into reality!</span>")
			Z.can_destroy = TRUE
			qdel(Z)

/obj/effect/immortality_talisman
	icon_state = "blank"
	icon = 'icons/effects/effects.dmi'
	var/can_destroy = FALSE

/obj/effect/immortality_talisman/attackby()
	return

/obj/effect/immortality_talisman/ex_act()
	return

/obj/effect/immortality_talisman/singularity_pull()
	return 0

/obj/effect/immortality_talisman/Destroy(force)
	if(!can_destroy && !force)
		return QDEL_HINT_LETMELIVE
	else
		. = ..()


//Shared Bag

//Internal

/obj/item/weapon/storage/backpack/shared
	name = "paradox bag"
	desc = "Somehow, it's in two places at once."
	max_combined_w_class = 60
	max_w_class = 3


//External

/obj/item/device/shared_storage
	name = "paradox bag"
	desc = "Somehow, it's in two places at once."
	icon = 'icons/obj/storage.dmi'
	icon_state = "cultpack"
	slot_flags = SLOT_BACK
	var/obj/item/weapon/storage/backpack/shared/bag


/obj/item/device/shared_storage/red
	name = "paradox bag"
	desc = "Somehow, it's in two places at once."

/obj/item/device/shared_storage/red/New()
	..()
	if(!bag)
		var/obj/item/weapon/storage/backpack/shared/S = new(src)
		var/obj/item/device/shared_storage/blue = new(src.loc)

		src.bag = S
		blue.bag = S


/obj/item/device/shared_storage/attackby(obj/item/W, mob/user, params)
	if(bag)
		bag.loc = user
		bag.attackby(W, user, params)


/obj/item/device/shared_storage/attack_hand(mob/living/carbon/user)
	if(!iscarbon(user))
		return
	if(loc == user && user.back && user.back == src)
		if(bag)
			bag.loc = user
			bag.attack_hand(user)
	else
		..()


/obj/item/device/shared_storage/MouseDrop(atom/over_object)
	if(iscarbon(usr) || isdrone(usr))
		var/mob/M = usr

		if(!over_object)
			return

		if (istype(usr.loc,/obj/mecha))
			return

		if(!M.restrained() && !M.stat)
			playsound(loc, "rustle", 50, 1, -5)


			if(istype(over_object, /obj/screen/inventory/hand))
				var/obj/screen/inventory/hand/H = over_object
				if(!M.unEquip(src))
					return
				M.put_in_hand(src, H.held_index)

			add_fingerprint(usr)


//Boat

/obj/vehicle/lavaboat
	name = "lava boat"
	desc = "A boat used for traversing lava."
	icon_state = "goliath_boat"
	icon = 'icons/obj/lavaland/dragonboat.dmi'
	keytype = /obj/item/weapon/oar
	resistance_flags = LAVA_PROOF | FIRE_PROOF

/obj/vehicle/lavaboat/relaymove(mob/user, direction)
	var/turf/next = get_step(src, direction)
	var/turf/current = get_turf(src)

	if(istype(next, /turf/open/floor/plating/lava) || istype(current, /turf/open/floor/plating/lava)) //We can move from land to lava, or lava to land, but not from land to land
		..()
	else
		user << "Boats don't go on land!"
		return 0

/obj/item/weapon/oar
	name = "oar"
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "oar"
	item_state = "rods"
	desc = "Not to be confused with the kind Research hassles you for."
	force = 12
	w_class = 3
	resistance_flags = LAVA_PROOF | FIRE_PROOF

/datum/crafting_recipe/oar
	name = "goliath bone oar"
	result = /obj/item/weapon/oar
	reqs = list(/obj/item/stack/sheet/bone = 2)
	time = 15
	category = CAT_PRIMAL

/datum/crafting_recipe/boat
	name = "goliath hide boat"
	result = /obj/vehicle/lavaboat
	reqs = list(/obj/item/stack/sheet/animalhide/goliath_hide = 3)
	time = 50
	category = CAT_PRIMAL

//Dragon Boat


/obj/item/ship_in_a_bottle
	name = "ship in a bottle"
	desc = "A tiny ship inside a bottle."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "ship_bottle"

/obj/item/ship_in_a_bottle/attack_self(mob/user)
	user << "You're not sure how they get the ships in these things, but you're pretty sure you know how to get it out."
	playsound(user.loc, 'sound/effects/Glassbr1.ogg', 100, 1)
	new /obj/vehicle/lavaboat/dragon(get_turf(src))
	qdel(src)

/obj/vehicle/lavaboat/dragon
	name = "mysterious boat"
	desc = "This boat moves where you will it, without the need for an oar."
	keytype = null
	icon_state = "dragon_boat"
	generic_pixel_y = 2
	generic_pixel_x = 1
	vehicle_move_delay = 1

//Potion of Flight
/obj/item/weapon/reagent_containers/glass/bottle/potion
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "potionflask"

/obj/item/weapon/reagent_containers/glass/bottle/potion/flight
	name = "strange elixir"
	desc = "A flask with an almost-holy aura emitting from it. The label on the bottle says: 'erqo'hyy tvi'rf lbh jv'atf'."
	list_reagents = list("flightpotion" = 5)

/obj/item/weapon/reagent_containers/glass/bottle/potion/update_icon()
	if(reagents.total_volume)
		icon_state = "potionflask"
	else
		icon_state = "potionflask_empty"

/datum/reagent/flightpotion
	name = "Flight Potion"
	id = "flightpotion"
	description = "Strange mutagenic compound of unknown origins."
	reagent_state = LIQUID
	color = "#FFEBEB"

/datum/reagent/flightpotion/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message = 1)
	if(iscarbon(M) && M.stat != DEAD)
		if(!ishumanbasic(M) || reac_volume < 5) // implying xenohumans are holy
			if(method == INGEST && show_message)
				M << "<span class='notice'><i>You feel nothing but a terrible aftertaste.</i></span>"
			return ..()

		M << "<span class='userdanger'>A terrible pain travels down your back as wings burst out!</span>"
		M.set_species(/datum/species/angel)
		playsound(M.loc, 'sound/items/poster_ripped.ogg', 50, 1, -1)
		M.adjustBruteLoss(20)
		M.emote("scream")
	..()




///Bosses




//Dragon

/obj/structure/closet/crate/necropolis/dragon
	name = "dragon chest"

/obj/structure/closet/crate/necropolis/dragon/New()
	..()
	var/loot = rand(1,4)
	switch(loot)
		if(1)
			new /obj/item/weapon/melee/ghost_sword(src)
		if(2)
			new /obj/item/weapon/lava_staff(src)
		if(3)
			new /obj/item/weapon/spellbook/oneuse/sacredflame(src)
			new /obj/item/weapon/gun/magic/wand/fireball(src)
		if(4)
			new /obj/item/weapon/dragons_blood(src)

/obj/item/weapon/melee/ghost_sword
	name = "spectral blade"
	desc = "A rusted and dulled blade. It doesn't look like it'd do much damage. It glows weakly."
	icon_state = "spectral"
	item_state = "spectral"
	flags = CONDUCT
	sharpness = IS_SHARP
	w_class = 4
	force = 1
	throwforce = 1
	hitsound = 'sound/effects/ghost2.ogg'
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "rended")
	var/summon_cooldown = 0
	var/list/mob/dead/observer/spirits

/obj/item/weapon/melee/ghost_sword/New()
	..()
	spirits = list()
	START_PROCESSING(SSobj, src)
	poi_list |= src

/obj/item/weapon/melee/ghost_sword/Destroy()
	for(var/mob/dead/observer/G in spirits)
		G.invisibility = initial(G.invisibility)
	spirits.Cut()
	STOP_PROCESSING(SSobj, src)
	poi_list -= src
	. = ..()

/obj/item/weapon/melee/ghost_sword/attack_self(mob/user)
	if(summon_cooldown > world.time)
		user << "You just recently called out for aid. You don't want to annoy the spirits."
		return
	user << "You call out for aid, attempting to summon spirits to your side."

	notify_ghosts("[user] is raising [user.p_their()] [src], calling for your help!",
		enter_link="<a href=?src=\ref[src];orbit=1>(Click to help)</a>",
		source = user, action=NOTIFY_ORBIT)

	summon_cooldown = world.time + 600

/obj/item/weapon/melee/ghost_sword/Topic(href, href_list)
	if(href_list["orbit"])
		var/mob/dead/observer/ghost = usr
		if(istype(ghost))
			ghost.ManualFollow(src)

/obj/item/weapon/melee/ghost_sword/process()
	ghost_check()

/obj/item/weapon/melee/ghost_sword/proc/ghost_check()
	var/ghost_counter = 0
	var/turf/T = get_turf(src)
	var/list/contents = T.GetAllContents()
	var/mob/dead/observer/current_spirits = list()
	var/list/orbiters = list()
	for(var/thing in contents)
		var/atom/A = thing
		if (A.orbiters)
			orbiters += A.orbiters

	for(var/thing in orbiters)
		var/datum/orbit/O = thing
		if (isobserver(O.orbiter))
			var/mob/dead/observer/G = O.orbiter
			ghost_counter++
			G.invisibility = 0
			current_spirits |= G

	for(var/mob/dead/observer/G in spirits - current_spirits)
		G.invisibility = initial(G.invisibility)

	spirits = current_spirits

	return ghost_counter

/obj/item/weapon/melee/ghost_sword/attack(mob/living/target, mob/living/carbon/human/user)
	force = 0
	var/ghost_counter = ghost_check()

	force = Clamp((ghost_counter * 4), 0, 75)
	user.visible_message("<span class='danger'>[user] strikes with the force of [ghost_counter] vengeful spirits!</span>")
	..()

/obj/item/weapon/melee/ghost_sword/hit_reaction(mob/living/carbon/human/owner, attack_text, final_block_chance, damage, attack_type)
	var/ghost_counter = ghost_check()
	final_block_chance += Clamp((ghost_counter * 5), 0, 75)
	owner.visible_message("<span class='danger'>[owner] is protected by a ring of [ghost_counter] ghosts!</span>")
	return ..()

//Blood

/obj/item/weapon/dragons_blood
	name = "bottle of dragons blood"
	desc = "You're not actually going to drink this, are you?"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "vial"

/obj/item/weapon/dragons_blood/attack_self(mob/living/carbon/human/user)
	if(!istype(user))
		return

	var/mob/living/carbon/human/H = user
	var/random = rand(1,4)

	switch(random)
		if(1)
			user << "<span class='danger'>Your appearence morphs to that of a very small humanoid ash dragon! You get to look like a freak without the cool abilities.</span>"
			H.dna.features = list("mcolor" = "A02720", "tail_lizard" = "Dark Tiger", "tail_human" = "None", "snout" = "Sharp", "horns" = "Curled", "ears" = "None", "wings" = "None", "frills" = "None", "spines" = "Long", "body_markings" = "Dark Tiger Body", "legs" = "Digitigrade Legs")
			H.eye_color = "fee5a3"
			H.set_species(/datum/species/lizard)
		if(2)
			user << "<span class='danger'>Your flesh begins to melt! Miraculously, you seem fine otherwise.</span>"
			H.set_species(/datum/species/skeleton)
		if(3)
			user << "<span class='danger'>Power courses through you! You can now shift your form at will."
			if(user.mind)
				var/obj/effect/proc_holder/spell/targeted/shapeshift/dragon/D = new
				user.mind.AddSpell(D)
		if(4)
			user << "<span class='danger'>You feel like you could walk straight through lava now.</span>"
			H.weather_immunities |= "lava"

	playsound(user.loc,'sound/items/drink.ogg', rand(10,50), 1)
	qdel(src)

/datum/disease/transformation/dragon
	name = "dragon transformation"
	cure_text = "nothing"
	cures = list("adminordrazine")
	agent = "dragon's blood"
	desc = "What do dragons have to do with Space Station 13?"
	stage_prob = 20
	severity = BIOHAZARD
	visibility_flags = 0
	stage1	= list("Your bones ache.")
	stage2	= list("Your skin feels scaley.")
	stage3	= list("<span class='danger'>You have an overwhelming urge to terrorize some peasants.</span>", "<span class='danger'>Your teeth feel sharper.</span>")
	stage4	= list("<span class='danger'>Your blood burns.</span>")
	stage5	= list("<span class='danger'>You're a fucking dragon. However, any previous allegiances you held still apply. It'd be incredibly rude to eat your still human friends for no reason.</span>")
	new_form = /mob/living/simple_animal/hostile/megafauna/dragon/lesser


//Lava Staff

/obj/item/weapon/lava_staff
	name = "staff of lava"
	desc = "The ability to fill the emergency shuttle with lava. What more could you want out of life?"
	icon_state = "staffofstorms"
	item_state = "staffofstorms"
	icon = 'icons/obj/guns/magic.dmi'
	slot_flags = SLOT_BACK
	w_class = 4
	force = 25
	damtype = BURN
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	hitsound = 'sound/weapons/sear.ogg'
	var/turf_type = /turf/open/floor/plating/lava/smooth
	var/transform_string = "lava"
	var/reset_turf_type = /turf/open/floor/plating/asteroid/basalt
	var/reset_string = "basalt"
	var/create_cooldown = 100
	var/create_delay = 30
	var/reset_cooldown = 50
	var/timer = 0
	var/banned_turfs

/obj/item/weapon/lava_staff/New()
	. = ..()
	banned_turfs = typecacheof(list(/turf/open/space/transit, /turf/closed))

/obj/item/weapon/lava_staff/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	..()
	if(timer > world.time)
		return

	if(is_type_in_typecache(target, banned_turfs))
		return

	if(target in view(user.client.view, get_turf(user)))

		var/turf/open/T = get_turf(target)
		if(!istype(T))
			return
		if(!istype(T, turf_type))
			var/obj/effect/overlay/temp/lavastaff/L = PoolOrNew(/obj/effect/overlay/temp/lavastaff, T)
			L.alpha = 0
			animate(L, alpha = 255, time = create_delay)
			user.visible_message("<span class='danger'>[user] points [src] at [T]!</span>")
			timer = world.time + create_delay + 1
			if(do_after(user, create_delay, target = T))
				user.visible_message("<span class='danger'>[user] turns \the [T] into [transform_string]!</span>")
				message_admins("[key_name_admin(user)] fired the lava staff at [get_area(target)]. [ADMIN_COORDJMP(T)]")
				log_game("[key_name(user)] fired the lava staff at [get_area(target)] [COORD(T)].")
				T.ChangeTurf(turf_type)
				timer = world.time + create_cooldown
				qdel(L)
			else
				timer = world.time
				qdel(L)
				return
		else
			user.visible_message("<span class='danger'>[user] turns \the [T] into [reset_string]!</span>")
			T.ChangeTurf(reset_turf_type)
			timer = world.time + reset_cooldown
		playsound(T,'sound/magic/Fireball.ogg', 200, 1)

/obj/effect/overlay/temp/lavastaff
	icon_state = "lavastaff_warn"
	duration = 50

///Bubblegum

/obj/item/mayhem
	name = "mayhem in a bottle"
	desc = "A magically infused bottle of blood, the scent of which will drive anyone nearby into a murderous frenzy."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "vial"

/obj/item/mayhem/attack_self(mob/user)
	for(var/mob/living/carbon/human/H in range(7,user))
		spawn()
			var/obj/effect/mine/pickup/bloodbath/B = new(H)
			B.mineEffect(H)
	user << "<span class='notice'>You shatter the bottle!</span>"
	playsound(user.loc, 'sound/effects/Glassbr1.ogg', 100, 1)
	qdel(src)

/obj/structure/closet/crate/necropolis/bubblegum
	name = "bubblegum chest"

/obj/structure/closet/crate/necropolis/bubblegum/New()
	..()
	var/loot = rand(1,3)
	switch(loot)
		if(1)
			new /obj/item/mayhem(src)
		if(2)
			new /obj/item/blood_contract(src)
		if(3)
			new /obj/item/weapon/gun/magic/staff/spellblade(src)

/obj/item/blood_contract
	name = "blood contract"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scroll2"
	color = "#FF0000"
	desc = "Mark your target for death. "
	var/used = FALSE

/obj/item/blood_contract/attack_self(mob/user)
	if(used)
		return
	used = TRUE
	var/choice = input(user,"Who do you want dead?","Choose Your Victim") as null|anything in player_list

	if(!(isliving(choice)))
		user << "[choice] is already dead!"
		used = FALSE
		return
	else

		var/mob/living/L = choice

		message_admins("<span class='adminnotice'>[L] has been marked for death!</span>")

		var/datum/objective/survive/survive = new
		survive.owner = L.mind
		L.mind.objectives += survive
		L << "<span class='userdanger'>You've been marked for death! Don't let the demons get you!</span>"
		L.add_atom_colour("#FF0000", ADMIN_COLOUR_PRIORITY)
		spawn()
			var/obj/effect/mine/pickup/bloodbath/B = new(L)
			B.mineEffect(L)

		for(var/mob/living/carbon/human/H in player_list)
			if(H == L)
				continue
			H << "<span class='userdanger'>You have an overwhelming desire to kill [L]. [L.p_they(TRUE)] [L.p_have()] been marked red! Go kill [L.p_them()]!</span>"
			H.put_in_hands_or_del(new /obj/item/weapon/kitchen/knife/butcher(H))

	qdel(src)

//Hierophant

/obj/item/weapon/hierophant_staff
	name = "Hierophant's staff"
	desc = "A large club with intense magic power infused into it."
	icon_state = "hierophant_staff"
	item_state = "hierophant_staff"
	icon = 'icons/obj/guns/magic.dmi'
	slot_flags = SLOT_BACK
	w_class = 4
	force = 20
	hitsound = "swing_hit"
	//hitsound = 'sound/weapons/sonic_jackhammer.ogg'
	actions_types = list(/datum/action/item_action/vortex_recall, /datum/action/item_action/toggle_unfriendly_fire)
	var/cooldown_time = 20 //how long the cooldown between non-melee ranged attacks is
	var/chaser_cooldown = 101 //how long the cooldown between firing chasers at mobs is
	var/chaser_timer = 0 //what our current chaser cooldown is
	var/timer = 0 //what our current cooldown is
	var/blast_range = 3 //how long the cardinal blast's walls are
	var/obj/effect/hierophant/rune //the associated rune we teleport to
	var/teleporting = FALSE //if we ARE teleporting
	var/friendly_fire_check = FALSE //if the blasts we make will consider our faction against the faction of hit targets

/obj/item/weapon/hierophant_staff/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	..()
	var/turf/T = get_turf(target)
	if(!T || timer > world.time)
		return
	timer = world.time + CLICK_CD_MELEE //by default, melee attacks only cause melee blasts, and have an accordingly short cooldown
	if(proximity_flag)
		addtimer(src, "aoe_burst", 0, FALSE, T, user)
		add_logs(user, target, "fired 3x3 blast at", src)
	else
		if(ismineralturf(target) && get_dist(user, target) < 6) //target is minerals, we can hit it(even if we can't see it)
			addtimer(src, "cardinal_blasts", 0, FALSE, T, user)
			timer = world.time + cooldown_time
		else if(target in view(5, get_turf(user))) //if the target is in view, hit it
			timer = world.time + cooldown_time
			if(isliving(target) && chaser_timer <= world.time) //living and chasers off cooldown? fire one!
				chaser_timer = world.time + chaser_cooldown
				PoolOrNew(/obj/effect/overlay/temp/hierophant/chaser, list(get_turf(user), user, target, 1.5, friendly_fire_check))
				add_logs(user, target, "fired a chaser at", src)
			else
				addtimer(src, "cardinal_blasts", 0, FALSE, T, user) //otherwise, just do cardinal blast
				add_logs(user, target, "fired cardinal blast at", src)
		else
			user << "<span class='warning'>That target is out of range!</span>" //too far away

/obj/item/weapon/hierophant_staff/ui_action_click(mob/user, action)
	if(istype(action, /datum/action/item_action/toggle_unfriendly_fire)) //toggle friendly fire...
		friendly_fire_check = !friendly_fire_check
		user << "<span class='warning'>You toggle friendly fire [friendly_fire_check ? "off":"on"]!</span>"
		return
	if(!user.is_holding(src)) //you need to hold the staff to teleport
		user << "<span class='warning'>You need to hold the staff in your hands to [rune ? "teleport with it":"create a rune"]!</span>"
		return
	if(!rune)
		if(isturf(user.loc))
			user.visible_message("<span class='hierophant_warning'>[user] holds [src] carefully in front of [user.p_them()], moving it in a strange pattern...</span>", \
			"<span class='notice'>You start creating a hierophant rune to teleport to...</span>")
			timer = world.time + 51
			if(do_after(user, 50, target = user))
				var/turf/T = get_turf(user)
				playsound(T,'sound/magic/Blind.ogg', 200, 1, -4)
				PoolOrNew(/obj/effect/overlay/temp/hierophant/telegraph/teleport, list(T, user))
				var/obj/effect/hierophant/H = new/obj/effect/hierophant(T)
				rune = H
				user.update_action_buttons_icon()
				user.visible_message("<span class='hierophant_warning'>[user] creates a strange rune beneath [user.p_them()]!</span>", \
				"<span class='hierophant'>You create a hierophant rune, which you can teleport yourself and any allies to at any time!</span>\n\
				<span class='notice'>You can remove the rune to place a new one by striking it with the staff.</span>")
			else
				timer = world.time
		else
			user << "<span class='warning'>You need to be on solid ground to produce a rune!</span>"
		return
	if(get_dist(user, rune) <= 2) //rune too close abort
		user << "<span class='warning'>You are too close to the rune to teleport to it!</span>"
		return
	if(is_blocked_turf(get_turf(rune)))
		user << "<span class='warning'>The rune is blocked by something, preventing teleportation!</span>"
		return
	teleporting = TRUE //start channel
	user.update_action_buttons_icon()
	user.visible_message("<span class='hierophant_warning'>[user] starts to glow faintly...</span>")
	timer = world.time + 50
	if(do_after(user, 40, target = user) && rune)
		var/turf/T = get_turf(rune)
		var/turf/source = get_turf(user)
		if(is_blocked_turf(T))
			teleporting = FALSE
			user << "<span class='warning'>The rune is blocked by something, preventing teleportation!</span>"
			user.update_action_buttons_icon()
			return
		PoolOrNew(/obj/effect/overlay/temp/hierophant/telegraph, list(T, user))
		PoolOrNew(/obj/effect/overlay/temp/hierophant/telegraph, list(source, user))
		playsound(T,'sound/magic/blink.ogg', 200, 1)
		//playsound(T,'sound/magic/Wand_Teleport.ogg', 200, 1)
		playsound(source,'sound/magic/blink.ogg', 200, 1)
		//playsound(source,'sound/machines/AirlockOpen.ogg', 200, 1)
		if(!do_after(user, 3, target = user) || !rune) //no walking away shitlord
			teleporting = FALSE
			if(user)
				user.update_action_buttons_icon()
			return
		if(is_blocked_turf(T))
			teleporting = FALSE
			user << "<span class='warning'>The rune is blocked by something, preventing teleportation!</span>"
			user.update_action_buttons_icon()
			return
		add_logs(user, rune, "teleported self from ([source.x],[source.y],[source.z]) to")
		PoolOrNew(/obj/effect/overlay/temp/hierophant/telegraph/teleport, list(T, user))
		PoolOrNew(/obj/effect/overlay/temp/hierophant/telegraph/teleport, list(source, user))
		for(var/t in RANGE_TURFS(1, T))
			var/obj/effect/overlay/temp/hierophant/blast/B = PoolOrNew(/obj/effect/overlay/temp/hierophant/blast, list(t, user, TRUE)) //blasts produced will not hurt allies
			B.damage = 30
		for(var/t in RANGE_TURFS(1, source))
			var/obj/effect/overlay/temp/hierophant/blast/B = PoolOrNew(/obj/effect/overlay/temp/hierophant/blast, list(t, user, TRUE)) //but absolutely will hurt enemies
			B.damage = 30
		for(var/mob/living/L in range(1, source))
			addtimer(src, "teleport_mob", 0, FALSE, source, L, T, user) //regardless, take all mobs near us along
		sleep(6) //at this point the blasts detonate
	else
		timer = world.time
	teleporting = FALSE
	if(user)
		user.update_action_buttons_icon()

/obj/item/weapon/hierophant_staff/proc/teleport_mob(turf/source, mob/M, turf/target, mob/user)
	var/turf/turf_to_teleport_to = get_step(target, get_dir(source, M)) //get position relative to caster
	if(!turf_to_teleport_to || is_blocked_turf(turf_to_teleport_to))
		return
	animate(M, alpha = 0, time = 2, easing = EASE_OUT) //fade out
	sleep(1)
	if(!M)
		return
	M.visible_message("<span class='hierophant_warning'>[M] fades out!</span>")
	sleep(2)
	if(!M)
		return
	M.forceMove(turf_to_teleport_to)
	sleep(1)
	if(!M)
		return
	animate(M, alpha = 255, time = 2, easing = EASE_IN) //fade IN
	sleep(1)
	if(!M)
		return
	M.visible_message("<span class='hierophant_warning'>[M] fades in!</span>")
	if(user != M)
		add_logs(user, M, "teleported", null, "from ([source.x],[source.y],[source.z])")

/obj/item/weapon/hierophant_staff/proc/cardinal_blasts(turf/T, mob/living/user) //fire cardinal cross blasts with a delay
	if(!T)
		return
	PoolOrNew(/obj/effect/overlay/temp/hierophant/telegraph/cardinal, list(T, user))
	playsound(T,'sound/magic/blink.ogg', 200, 1)
	//playsound(T,'sound/effects/bin_close.ogg', 200, 1)
	sleep(2)
	PoolOrNew(/obj/effect/overlay/temp/hierophant/blast, list(T, user, friendly_fire_check))
	for(var/d in cardinal)
		addtimer(src, "blast_wall", 0, FALSE, T, d, user)

/obj/item/weapon/hierophant_staff/proc/blast_wall(turf/T, dir, mob/living/user) //make a wall of blasts blast_range tiles long
	if(!T)
		return
	var/range = blast_range
	var/turf/previousturf = T
	var/turf/J = get_step(previousturf, dir)
	for(var/i in 1 to range)
		if(!J)
			return
		PoolOrNew(/obj/effect/overlay/temp/hierophant/blast, list(J, user, friendly_fire_check))
		previousturf = J
		J = get_step(previousturf, dir)

/obj/item/weapon/hierophant_staff/proc/aoe_burst(turf/T, mob/living/user) //make a 3x3 blast around a target
	if(!T)
		return
	PoolOrNew(/obj/effect/overlay/temp/hierophant/telegraph, list(T, user))
	playsound(T,'sound/magic/blink.ogg', 200, 1)
	//playsound(T,'sound/effects/bin_close.ogg', 200, 1)
	sleep(2)
	for(var/t in RANGE_TURFS(1, T))
		PoolOrNew(/obj/effect/overlay/temp/hierophant/blast, list(t, user, friendly_fire_check))
