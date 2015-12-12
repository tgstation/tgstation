
/obj/item/weapon/gun/projectile/sniper_rifle
	name = "sniper rifle"
	desc = "the kind of gun that will leave you crying for mummy before you even realise your leg's missing"
	icon_state = "moistnugget"
	item_state = "moistnugget"
	recoil = 2
	heavy_weapon = 1
	mag_type = /obj/item/ammo_box/magazine/sniper_rounds
	fire_delay = 40
	origin_tech = "combat=8"
	can_unsuppress = 1
	can_suppress = 1
	w_class = 3
	zoomable = TRUE
	zoom_amt = 7 //Long range, enough to see in front of you, but no tiles behind you.


/obj/item/weapon/gun/projectile/sniper_rifle/syndicate
	name = "syndicate sniper rifle"
	desc = "syndicate flavoured sniper rifle, it packs quite a punch, a punch to your face"
	pin = /obj/item/device/firing_pin/implant/pindicate
	origin_tech = "combat=8;syndicate=4"





//Normal Boolets
/obj/item/ammo_box/magazine/sniper_rounds
	name = "sniper rounds (.50)"
	icon_state = ".50"
	origin_tech = "combat=6;syndicate=2"
	ammo_type = /obj/item/ammo_casing/point50
	max_ammo = 6
	caliber = ".50"

/obj/item/ammo_casing/point50
	desc = "A .50 bullet casing."
	caliber = ".50"
	projectile_type = /obj/item/projectile/bullet/sniper

/obj/item/projectile/bullet/sniper
	damage = 70
	stun = 5
	weaken = 5
	var/breakthings = TRUE

/obj/item/projectile/bullet/sniper/on_hit(atom/target, blocked = 0, hit_zone)
	if((blocked != 100) && (!ismob(target) && breakthings))
		target.ex_act(rand(1,2))

	return ..()


//Sleepy ammo
/obj/item/ammo_box/magazine/sniper_rounds/soporific
	name = "sniper rounds (Zzzzz)"
	desc = "Soporific sniper rounds, designed for happy days and dead quiet nights..."
	icon_state = "soporific"
	origin_tech = "combat=6;syndicate=3"
	ammo_type = /obj/item/ammo_casing/soporific
	max_ammo = 3
	caliber = ".50"

/obj/item/ammo_casing/soporific
	desc = "A .50 bullet casing, specialised in sending the target to sleep, instead of hell."
	caliber = ".50"
	projectile_type = /obj/item/projectile/bullet/sniper/soporific

/obj/item/projectile/bullet/sniper/soporific
	nodamage = 1
	stun = 0
	weaken = 0
	breakthings = FALSE

/obj/item/projectile/bullet/sniper/soporific/on_hit(atom/target, blocked = 0, hit_zone)
	if((blocked != 100) && istype(target, /mob/living))
		var/mob/living/L = target
		L.SetSleeping(20)

	return ..()



//hemorrhage ammo
/obj/item/ammo_box/magazine/sniper_rounds/haemorrhage
	name = "sniper rounds (Bleed)"
	desc = "Haemorrhage sniper rounds, leaves your target in a pool of crimson pain"
	icon_state = "haemorrhage"
	origin_tech = "combat=7;syndicate=5"
	ammo_type = /obj/item/ammo_casing/haemorrhage
	max_ammo = 5
	caliber = ".50"

/obj/item/ammo_casing/haemorrhage
	desc = "A .50 bullet casing, specialised in causing massive bloodloss"
	caliber = ".50"
	projectile_type = /obj/item/projectile/bullet/sniper/haemorrhage

/obj/item/projectile/bullet/sniper/haemorrhage
	damage = 15
	stun = 0
	weaken = 0
	breakthings = FALSE

/obj/item/projectile/bullet/sniper/haemorrhage/on_hit(atom/target, blocked = 0, hit_zone)
	if((blocked != 100) && istype(target, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = target
		H.drip(100)

	return ..()