/obj/item/pod_attachment/primary/projectile

	disruptor/
		name = "disruptor laser"
		overlay_icon_state = "pod_weapon_cbeam"
		power_usage = 500
		cooldown = 100
		use_sound = 'sound/weapons/marauder.ogg'
		projectile = /obj/item/projectile/beam/pulse/heavy
		minimum_pod_size = list(2, 2)
		construction_cost = list("metal" = 6000, "uranium" = 8000, "plasma" = 8000, "gold" = 8000, "diamond" = 8000)
		//origin_tech = "combat=5;materials=5;engineering=5"

	xray/
		name = "x-ray Laser"
		overlay_icon_state = "pod_weapon_xray"
		power_usage = 200
		cooldown = 15
		use_sound = 'sound/weapons/laser3.ogg'
		projectile = /obj/item/projectile/beam/xray
		minimum_pod_size = list(2, 2)
		construction_cost = list("metal" = 4000, "uranium" = 2500, "silver" = 2500)
		//origin_tech = "combat=3;materials=3;engineering=3"

	laser/
		name = "laser carbine Mk I"
		overlay_icon_state = "pod_weapon_laser"
		power_usage = 100
		cooldown = 10
		use_sound = 'sound/weapons/Laser.ogg'
		projectile = /obj/item/projectile/beam/laser
		construction_cost = list("metal" = 4000, "plasma" = 2000)
		//origin_tech = "combat=2;materials=2;engineering=2"

	heavylaser/
		name = "laser carbine Mk II"
		overlay_icon_state = "pod_weapon_emitter"
		power_usage = 300
		cooldown = 15
		use_sound = 'sound/weapons/lasercannonfire.ogg'
		projectile = /obj/item/projectile/beam/laser/heavylaser
		minimum_pod_size = list(2, 2)
		construction_cost = list("metal" = 4000, "plasma" = 2500, "silver" = 2500, "gold" = 2500)
		//origin_tech = "combat=3;materials=3;engineering=3"

	deathlaser/
		name = "laser carbine Mk III"
		overlay_icon_state = "pod_weapon_ltlaser"
		power_usage = 1000
		cooldown = 100
		use_sound = 'sound/weapons/emitter2.ogg'
		projectile = /obj/item/projectile/beam/laser/deathlaser
		minimum_pod_size = list(2, 2)
		construction_cost = list("metal" = 4000, "silver" = 4000, "gold" = 4000, "diamond" = 4000)
		//origin_tech = "combat=4;materials=4;engineering=4"

	taser/
		name = "taser carbine"
		overlay_icon_state = "pod_weapon_taser"
		power_usage = 50
		cooldown = 10
		use_sound = 'sound/weapons/taser.ogg'
		projectile = /obj/item/projectile/energy/electrode
		construction_cost = list("metal" = 4000, "plasma" = 1500)
		//origin_tech = "combat=1;materials=1;engineering=1"

	disabler/
		name = "disabler carbine"
		overlay_icon_state = "pod_weapon_disabler"
		power_usage = 50
		cooldown = 5
		use_sound = 'sound/weapons/taser2.ogg'
		projectile = /obj/item/projectile/beam/disabler
		construction_cost = list("metal" = 4000, "plasma" = 1500)
		//origin_tech = "combat=1;materials=1;engineering=1"

	phaser/
		name = "phaser carbine"
		overlay_icon_state = "pod_weapon_laser"
		power_usage = 50
		cooldown = 10
		use_sound = 'sound/weapons/taser2.ogg'
		projectile = /obj/item/projectile/energy/phaser
		construction_cost = list("metal" = 4000, "plasma" = 1500)
		//origin_tech = "combat=2;materials=2;engineering=2"

	neutron_cannon/
		name = "neutron cannon"
		overlay_icon_state = "pod_weapon_neutron"
		power_usage = 200
		cooldown = 10
		use_sound = 'sound/weapons/Laser3.ogg'
		projectile = /obj/item/projectile/bullet/neutron
		construction_cost = list("metal" = 4000, "silver" = 2300, "plasma" = 2300)
		//origin_tech = "combat=3;materials=3;engineering=3"

	bullet/
		var/mag_type = 0
		power_usage = 0 // Uses ammo.
		projectile = 0
		overlay_icon_state = "pod_weapon_gun"
		use_sound = 'sound/weapons/Gunshot.ogg'

		Use(var/atom/target, var/mob/user, var/flags = 0)
			if(!..(target, user, flags))
				return 0

			if(mag_type)
				var/obj/item/pod_attachment/cargo/cargo = attached_to.GetAttachmentOnHardpoint(P_HARDPOINT_CARGO_HOLD)
				var/list/magazines = cargo.GetListFromType(mag_type)
				var/obj/item/ammo_box/magazine/mag = locate(mag_type) in cargo.GetListFromType(mag_type)
				if(length(magazines) > 1)
					for(var/obj/item/ammo_box/magazine/M in magazines)
						if(length(M.stored_ammo) > length(mag.stored_ammo))
							mag = M

				if(!mag)
					to_chat(user,"<span class='warning'>No magazine found.</span>")
				else
					var/list/directional = attached_to.GetDirectionalTurfs(attached_to.dir)
					var/list/additions[length(directional)]
					spawn(0)
						flick(icon_state + "_fire", src)
					for(var/turf/T in directional)
						var/obj/item/ammo_casing/ammo = mag.get_round()
						if(!ammo)
							to_chat(user,"<span class='warning'>Magazine empty.</span>")
							break
						else
							var/list/under = attached_to.GetDirectionalTurfsUnderPod(attached_to.dir)
							var/turf/under_turf = under[directional.Find(T)]
							additions[directional.Find(T)] = "dir: [dir2text(get_dir(under_turf, T))]"
							ammo.loc = under_turf
							//ammo.fire(T, user)
							ammo.fire_casing(T, user)
							spawn(0)
								playsound(get_turf(src), use_sound, 10, 5, 0)

					attached_to.pod_log.LogUsage(user, src, directional, additions)

		r45/
			name = ".45 repeater"
			cooldown = 5
			mag_type = /obj/item/ammo_box/c45
			construction_cost = list("metal" = 4000, "uranium" = 200)
			//origin_tech = "combat=2;materials=2;engineering=2"

		r9mm/
			name = "9mm repeater"
			cooldown = 7.5
			mag_type = /obj/item/ammo_box/c9mm
			construction_cost = list("metal" = 4000, "silver" = 400, "uranium" = 400)
			//origin_tech = "combat=3;materials=3;engineering=3"

		r10mm/
			name = "10mm repeater"
			cooldown = 10
			minimum_pod_size = list(2, 2)
			mag_type = /obj/item/ammo_box/c10mm
			construction_cost = list("metal" = 4000, "silver" = 600, "uranium" = 600)
			//origin_tech = "combat=4;materials=4;engineering=4"

		r75/
			name = ".75 HE repeater"
			cooldown = 15
			minimum_pod_size = list(2, 2)
			mag_type = /obj/item/ammo_box/magazine/m75
			construction_cost = list("metal" = 4000, "silver" = 800, "uranium" = 800)
			//origin_tech = "combat=5;materials=5;engineering=5;illegal=4"

	missile/
		name = "missile rack"
		use_sound = 'sound/weapons/grenadelaunch.ogg'
		overlay_icon_state = "pod_weapon_bfg"
		projectile = 0
		cooldown = 20
		construction_cost = list("metal" = 4000, "uranium" = 4000, "plasma" = 4000, "silver" = 4000)
		//origin_tech = "combat=4;materials=4;engineering=4"
		var/missile_type = /obj/item/projectile/bullet/srmrocket
		var/missile_amount = 0
		var/max_missile_amount = 8
		var/speed = 3
		var/range = 50

		Use(var/atom/target, var/mob/user, var/flags = P_ATTACHMENT_IGNORE_POWER | P_ATTACHMENT_PLAYSOUND | P_ATTACHMENT_LOG)
			if(!..(target, user, flags))
				return 0

			if(missile_amount <= 0)
				attached_to.PrintSystemAlert("\The [src] is out of missiles.")
				return 0

			var/list/directional_turfs = attached_to.GetDirectionalTurfs(get_dir(get_turf(src), get_turf(target)))
			var/obj/item/projectile/bullet/srmrocket/M = new missile_type(pick(directional_turfs))
			//M.primed = 1
			message_admins("[key_name(user)](<a href='?_src_=holder;adminmoreinfo=\ref[user]'>?</a>) fired \a [M] to {[target.x], [target.y], [target.z]} (<a href='?_src_=holder;adminplayerobservecoodjump=1;X=[target.x];Y=[target.y];Z=[target.z]'>JMP</a>)")
			log_game("[key_name(user)] fired \a [M] to {[target.x], [target.y], [target.z]}")
			M.throw_at(get_turf(target), range, speed)
			missile_amount--

		PodAttackbyAction(var/obj/item/I, var/mob/living/user)
			if(istype(I, missile_type))
				if((missile_amount + 1) <= max_missile_amount)
					missile_amount++
					to_chat(user,"<span class='info'>You place the [I] into the [attached_to].</span>")
					qdel(I)
					return 1
				else
					to_chat(user,"<span class='warning'>\The missile pylon is full.</span>")
					return 0

			return 0
/*
* Projectiles
*/

/obj/item/projectile/energy/phaser
	name = "phaser"
	icon_state = "scatterlaser"
	damage = 10
	damage_type = BURN
	hitsound = 'sound/weapons/sear.ogg'

/obj/item/projectile/bullet/neutron
	name = "neutron bullet"
	icon_state = "neutronbullet"
	damage = 30
	damage_type = BURN

/obj/item/projectile/beam/laser/deathlaser
	name = "death laser"
	icon_state = "heavylaser"
	damage = 60
