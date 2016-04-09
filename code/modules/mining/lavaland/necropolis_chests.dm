//The chests dropped by mob spawner tendrils. Also contains associated loot.

/obj/structure/closet/crate/necropolis
	name = "necropolis chest"
	desc = "It's watching you closely."
	icon_state = "necrocrate"

/obj/structure/closet/crate/necropolis/tendril
	desc = "It's watching you suspiciously."

/obj/structure/closet/crate/necropolis/tendril/New()
	..()
	var/loot = rand(1,25)
	switch(loot)
		if(1)
			new /obj/item/device/shared_storage/red(src)
		if(2)
			new /obj/item/clothing/suit/space/cult(src)
			new /obj/item/clothing/head/helmet/space/cult(src)
		if(3)
			new /obj/item/device/soulstone/anybody(src)
		if(4)
			new /obj/item/weapon/katana/cursed(src)
		if(5)
			new /obj/item/weapon/dnainjector/xraymut(src)
		if(6)
			new /obj/item/seeds/kudzu(src)
		if(7)
			new /obj/item/weapon/pickaxe/diamond(src)
		if(8)
			new /obj/item/clothing/head/culthood(src)
			new /obj/item/clothing/suit/cultrobes(src)
			new /obj/item/weapon/bedsheet/cult(src)
		if(9)
			new /obj/item/organ/internal/brain/alien(src)
		if(10)
			new /obj/item/organ/internal/heart/cursed(src)
		if(11)
			new /obj/item/weapon/reagent_containers/food/drinks/bottle/rum(src)
			new /obj/item/weapon/reagent_containers/food/snacks/grown/ambrosia/deus(src)
			new /obj/item/weapon/reagent_containers/food/drinks/bottle/whiskey(src)
			new /obj/item/weapon/lighter(src)
		if(12)
			new /obj/item/upgradescroll(src)
		if(13)
			new /obj/item/weapon/sord(src)
		if(14)
			new /obj/item/weapon/nullrod/claymore/darkblade
		if(15)
			new /obj/item/weapon/nullrod/armblade(src)
		if(16)
			new /obj/item/weapon/guardiancreator(src)
		if(17)
			new /obj/item/stack/sheet/runed_metal/fifty(src)
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
			new /obj/item/weapon/spellbook/oneuse/smoke(src)


//Spooky special loot

/obj/item/device/wisp_lantern
	name = "spooky lantern"
	desc = "This lantern gives off no light, but is home to a friendly wisp."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "lantern-blue"
	var/obj/effect/wisp/wisp

/obj/item/device/wisp_lantern/attack_self(mob/user)
	if(!wisp)
		user << "The wisp has gone missing!"
		return
	if(wisp.loc == src)
		user << "You release the wisp. It begins to bob around your head."
		user.sight |= SEE_MOBS
		icon_state = "lantern"
		wisp.orbit(user, 20)

	else
		if(wisp.orbiting)
			var/atom/A = wisp.orbiting
			if(istype(A, /mob/living))
				var/mob/living/M = A
				M.sight &= ~SEE_MOBS
				M << "The wisp has returned to it's latern. Your vision returns to normal."

			wisp.stop_orbit()
			wisp.loc = src
			user << "You return the wisp to the latern."
			icon_state = "lantern-blue"

/obj/item/device/wisp_lantern/New()
	..()
	var/obj/effect/wisp/W = new(src)
	wisp = W
	W.home = src

/obj/item/device/wisp_lantern/Destroy()
	if(wisp)
		if(wisp.loc == src)
			qdel(wisp)
		else
			wisp.home = null //stuck orbiting your head now
	..()

//Wisp Lantern
/obj/effect/wisp
	name = "friendly wisp"
	desc = "Happy to light your way."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "orb"
	var/obj/item/device/wisp_lantern/home
	luminosity = 7
	layer = FLY_LAYER - 0.3

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

/obj/item/ammo_casing/magic/hook/ready_proj(atom/target, mob/living/user, quiet, zone_override = "")
	..()
	var/obj/item/projectile/hook/P = BB
	spawn(1)
		P.chain = P.Beam(user,icon_state="chain",icon = 'icons/obj/lavaland/artefacts.dmi',time=1000, maxdistance = 30)

/obj/item/projectile/hook/on_hit(atom/target)
	. = ..()
	if(isliving(target))
		var/mob/living/L = target
		L.visible_message("<span class='danger'>[L] is snagged by [firer]'s hook!</span>")
		L.forceMove(get_turf(firer))
		qdel(chain)

//Immortality Talisman
/obj/item/device/immortality_talisman
	name = "Immortality Talisman"
	desc = "A dread talisman that can render you completely invulnerable."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "talisman"
	var/cooldown = 0

/obj/item/device/immortality_talisman/Destroy()
	return QDEL_HINT_LETMELIVE

/obj/item/device/immortality_talisman/attack_self(mob/user)
	if(cooldown < world.time)
		cooldown = world.time + 600
		user.visible_message("<span class='danger'>[user] vanishes from reality, leaving a a hole in their place!</span>")
		var/obj/effect/immortality_talisman/Z = new(get_turf(src.loc))
		Z.name = "hole in reality"
		Z.desc = "It's shaped an awful lot like [user.name]."
		Z.dir = user.dir
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
	burn_state = LAVA_PROOF
	var/can_destroy = FALSE

/obj/effect/immortality_talisman/attackby()
	return

/obj/effect/immortality_talisman/ex_act()
	return

/obj/effect/immortality_talisman/singularity_pull()
	return 0

/obj/effect/immortality_talisman/Destroy()
	if(!can_destroy)
		return QDEL_HINT_LETMELIVE
	else
		..()


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
				switch(H.slot_id)
					if(slot_r_hand)
						M.put_in_r_hand(src)
					if(slot_l_hand)
						M.put_in_l_hand(src)

			add_fingerprint(usr)
