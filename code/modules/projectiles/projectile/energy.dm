/obj/item/projectile/energy
	name = "energy"
	icon_state = "spark"
	damage = 0
	damage_type = BURN
	flag = "energy"


/obj/item/projectile/energy/electrode
	name = "electrode"
	icon_state = "spark"
	nodamage = 1
	stun = 10
	weaken = 10
	stutter = 10
/*VG EDIT
	agony = 40
	damage_type = HALLOSS
*/
	//Damage will be handled on the MOB side, to prevent window shattering.



/obj/item/projectile/energy/declone
	name = "declone"
	icon_state = "declone"
	nodamage = 1
	damage_type = CLONE
	irradiate = 40


/obj/item/projectile/energy/dart
	name = "dshell"
	icon_state = "toxin"
	damage = 5
	damage_type = TOX
	weaken = 5


/obj/item/projectile/energy/bolt
	name = "bolt"
	icon_state = "cbbolt"
	damage = 10
	damage_type = TOX
	nodamage = 0
	weaken = 10
	stutter = 10


/obj/item/projectile/energy/bolt/large
	name = "largebolt"
	damage = 20

/obj/item/projectile/energy/plasma
	name = "plasma"
	icon_state = "declone"

/obj/item/projectile/energy/plasma/pistol
	damage = 5

/obj/item/projectile/energy/plasma/light
	damage = 10

/obj/item/projectile/energy/plasma/rifle
	damage = 20

/obj/item/projectile/energy/neurotoxin
	name = "neuro"
	icon_state = "neurotoxin"
	damage = 5
	damage_type = TOX
	weaken = 5

/obj/item/projectile/energy/rad
	name = "rad"
	icon_state = "rad"
	damage = 30
	damage_type = BURN
	nodamage = 0
	weaken = 10
	stutter = 10

	on_hit(var/atom/hit)
		if(ishuman(hit))

			var/mob/living/carbon/human/H = hit

			H.generate_name()

			scramble(1, H, 100) // Scramble all UIs
			scramble(null, H, 5) // Scramble SEs, 5% chance for each block

			H.apply_effect((rand(50, 250)),IRRADIATE)