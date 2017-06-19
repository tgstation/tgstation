/obj/item/weapon/gun/magic/staff/staffofrevenant
	name = "staff of revenant"
	desc = "A cursed artifact that starts off weak, but you can drain the souls of dead bodies in order to make it more powerful! Activate the staff in hand to see how many souls you have and, if you have enough, make your staff stronger."
	fire_sound = "sound/magic/WandODeath.ogg"
	ammo_type = /obj/item/ammo_casing/magic/staffofrevenant
	icon_state = "staffofrevenant"
	item_state = "staffofrevenant"
	icon = 'hippiestation/icons/obj/weapons.dmi'
	lefthand_file = 'hippiestation/icons/mob/inhands/lefthand.dmi'
	righthand_file = 'hippiestation/icons/mob/inhands/righthand.dmi'
	w_class = 4
	max_charges = 1
	recharge_rate = 10
	no_den_usage = 1
	var/revenant_level = 0
	var/revenant_souls = 0
	var/list/drained_mobs
	var/chambered_dmg = 20

/obj/item/weapon/gun/magic/staff/staffofrevenant/attack(mob/living/carbon/human/target, mob/living/user)
	if(target.stat & DEAD)
		if(istype(target, /mob/living/carbon/human))
			LAZYINITLIST(drained_mobs)
			if(!(target in drained_mobs))
				playsound(src,'sound/magic/Staff_Chaos.ogg',40,1)
				user.visible_message("<font color=purple>[user] drains [target] their soul with [src]!</font>", "<span class='notice'>You use [src] to drain [target]'s soul, empowering your weapon!</span>")
				revenant_souls++
				LAZYADD(drained_mobs, target)
			else
				to_chat(user, "<span class='warning'>[target]'s soul is dead and empty.</span>")
				return
		else
			to_chat(user, "<span class='warning'>[target] isn't human!</span>")
			return
	..()

/obj/item/weapon/gun/magic/staff/staffofrevenant/attack_self(mob/living/user)
	if(revenant_level == 0)
		if(revenant_souls >= 5)
			to_chat(user, "<font color=purple>As you focus on the staff, you witness the crystal emanating a bright shine, before receeding again. The staff hums at an eerie tone, and has managed to become much stronger...</font>")
			max_charges = 2
			charges = 2
			recharge_rate = 9
			chambered_dmg = 25
			revenant_level = 1
	else if(revenant_level == 1)
		if(revenant_souls >= 10)
			to_chat(user, "<font color=purple>Once again, you glance at the staff, sparks now emanating from it as it begins to grow in power. You hear silent wailing around you, as you begin your descent into madness...</font>")
			max_charges = 3
			charges = 3
			recharge_rate = 8
			chambered_dmg = 30
			chambered = new /obj/item/ammo_casing/magic/staffofrevenant/level2(src)
			revenant_level = 2
			user.playsound_local(user, 'sound/spookoween/ghost_whisper.ogg')
	else if(revenant_level == 2)
		if(revenant_souls >= 15)
			to_chat(user, "<font color=purple>You only give a quick glimpse at the staff, as you hear the screams of the fallen emanating from the staff's crystal. Your powers grow even stronger...</font>")
			max_charges = 4
			charges = 4
			chambered_dmg = 35
			recharge_rate = 7
			chambered = new /obj/item/ammo_casing/magic/staffofrevenant/level3(src)
			revenant_level = 3
			user.playsound_local(user, 'sound/hallucinations/veryfar_noise.ogg')
	else if(revenant_level == 3)
		if(revenant_souls >= 20)
			to_chat(user, "<font color=purple>You only give a quick glimpse at the staff, as you hear the screams of the fallen emanating from the crystal mounted ontop of the staff, echoing throughout the station. Your powers grow even stronger...</font>")
			max_charges = 5
			charges = 5
			chambered_dmg = 40
			recharge_rate = 6
			chambered = new /obj/item/ammo_casing/magic/staffofrevenant/level4(src)
			revenant_level = 4
			playsound_global('sound/hallucinations/i_see_you1.ogg')
			to_chat(world, "<font color=purple><b>\"Your end draws near...\"</b></font>")
	else if(revenant_level == 4)
		if(revenant_souls >= 25) // if you reach this point, you pretty much won already
			to_chat(user, "<font color=purple>Just merely thinking of the power you have acquired is enough to trigger the staff's final evolution... It's destructive powers lets out an even louder wailing than last time, so loud that it echoes throughout the entire station, alerting those still standing that its futile to resist now...</font>")
			max_charges = 6
			charges = 6
			recharge_rate = 5
			chambered = new /obj/item/ammo_casing/magic/staffofrevenant/level5(src)
			revenant_level = 5
			chambered_dmg = 60
			to_chat(world, "<font size=5 color=purple><b>\"UNLIMITED... POWER!\"</b></font>")
			playsound_global('sound/hallucinations/wail.ogg')
	else if(revenant_level == 5)
		if(revenant_souls >= 50) // if you reaaally go the extra mile to cement your victory
			to_chat(user, "<font color=purple>The Staff... Somehow, you managed to do what no necrolord had ever managed, to awaken the staff further than this... It does not even seem to react, but you can feel it! The staff, it has become so much more potent! None can stand in your way!</font>")
			chambered = new /obj/item/ammo_casing/magic/staffofrevenant/level666(src)
			max_charges = 15
			charges = 15
			recharge_rate = 1
			revenant_level = 666
			to_chat(world, "<font size=5 color=purple><b>COWER BEFORE ME MORTALS!</b></font>")
			playsound_global('sound/hallucinations/wail.ogg')

	if(revenant_level <= 4)
		to_chat(user, "<font color=purple><b>Your [name] has [revenant_souls] souls contained within. Your power will grow every fifth soul...</b></font>")
		to_chat(user, "<font color=purple>It has a maximum charge of [max_charges], with a recharge rate of [recharge_rate]. Each projectile deals [chambered_dmg] damage.</font>")
	else if(revenant_level == 5)
		to_chat(user, "<font color=purple><b>Your [name] has [revenant_souls] souls contained within. Your power can only grow if you absorb a total of 50 souls...</b></font>")
		to_chat(user, "<font color=purple>It has a maximum charge of [max_charges], with a recharge rate of [recharge_rate]. Each projectile deals [chambered_dmg] damage.</font>")
	else if(revenant_level == 666)
		to_chat(user, "<font color=purple><b>Your [name] has [revenant_souls] souls contained within. Your power can not possibly grow any further...</b></font>")
		to_chat(user, "<font color=purple>It has a maximum charge of [max_charges], with a recharge rate of [recharge_rate]. Each projectile instantly gibs a target.</font>")

/obj/item/ammo_casing/magic/staffofrevenant
	projectile_type = /obj/item/projectile/magic/revenant

/obj/item/ammo_casing/magic/staffofrevenant/level1
	projectile_type = /obj/item/projectile/magic/revenant/level1

/obj/item/ammo_casing/magic/staffofrevenant/level2
	projectile_type = /obj/item/projectile/magic/revenant/level2

/obj/item/ammo_casing/magic/staffofrevenant/level3
	projectile_type = /obj/item/projectile/magic/revenant/level3

/obj/item/ammo_casing/magic/staffofrevenant/level4
	projectile_type = /obj/item/projectile/magic/revenant/level4

/obj/item/ammo_casing/magic/staffofrevenant/level5
	projectile_type = /obj/item/projectile/magic/revenant/level5

/obj/item/ammo_casing/magic/staffofrevenant/level666
	projectile_type = /obj/item/projectile/magic/revenant/level666

/obj/item/projectile/magic/revenant
	name = "bolt of revenant"
	icon = 'hippiestation/icons/obj/projectiles.dmi'
	icon_state = "darkshard"
	damage = 20
	nodamage = 0
	damage_type = TOX

/obj/item/projectile/magic/revenant/level1
	damage = 25
/obj/item/projectile/magic/revenant/level2
	damage = 30
/obj/item/projectile/magic/revenant/level3
	damage = 35
/obj/item/projectile/magic/revenant/level4
	damage = 40
/obj/item/projectile/magic/revenant/level5
	damage = 60
/obj/item/projectile/magic/revenant/level666
	damage = 200
/obj/item/projectile/magic/revenant/level666/on_hit(mob/living/target)
	..()
	if(ismob(target))
		target.gib()
