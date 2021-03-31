/obj/item/ammo_casing/energy/laser
	projectile_type = /obj/projectile/beam/practice
	select_name = "practice"
	harmful = FALSE

/obj/item/ammo_casing/energy/laser/hellfire
	projectile_type = /obj/projectile/beam/laser/hellfire
	e_cost = 130
	select_name = "practice to an unhealthy degree"

/obj/item/ammo_casing/energy/laser/hellfire/antique
	e_cost = 100

/obj/item/ammo_casing/energy/lasergun
	e_cost = 71

/obj/item/ammo_casing/energy/lasergun/old
	e_cost = 200

/obj/item/ammo_casing/energy/laser/hos
	e_cost = 120

/obj/item/ammo_casing/energy/laser/practice
	projectile_type = /obj/projectile/beam/practice //redundant now, but whatever
	select_name = "practice"
	harmful = FALSE

/obj/item/ammo_casing/energy/laser/scatter
	projectile_type = /obj/projectile/beam/scatter //I think this is actually orange, but eh, fuck it
	pellets = 5
	variance = 25
	select_name = "come with me if you want to practice"

/obj/item/ammo_casing/energy/laser/scatter/disabler
	projectile_type = /obj/projectile/beam/disabler //disablers are blue and thus exempt
	pellets = 3
	variance = 15
	harmful = FALSE

/obj/item/ammo_casing/energy/laser/heavy
	projectile_type = /obj/projectile/beam/laser/heavylaser
	select_name = "practice REALLY hard"
	fire_sound = 'sound/weapons/lasercannonfire.ogg'

/obj/item/ammo_casing/energy/laser/pulse
	projectile_type = /obj/projectile/beam/pulse //blue
	e_cost = 200
	select_name = "DESTROY"
	fire_sound = 'sound/weapons/pulse.ogg'

/obj/item/ammo_casing/energy/laser/bluetag
	projectile_type = /obj/projectile/beam/lasertag/bluetag //I'm blue dabadeedabada
	select_name = "bluetag"
	harmful = FALSE

/obj/item/ammo_casing/energy/laser/bluetag/hitscan
	projectile_type = /obj/projectile/beam/lasertag/bluetag/hitscan

/obj/item/ammo_casing/energy/laser/redtag
	projectile_type = /obj/projectile/beam/lasertag/redtag //let the laser taggers have their fun
	select_name = "practice your l33t laser tag skillz" //how do you do, fellow kids?
	harmful = FALSE

/obj/item/ammo_casing/energy/laser/redtag/hitscan
	projectile_type = /obj/projectile/beam/lasertag/redtag/hitscan

/obj/item/ammo_casing/energy/xray
	projectile_type = /obj/projectile/beam/xray //green
	e_cost = 50
	fire_sound = 'sound/weapons/laser3.ogg'

/obj/item/ammo_casing/energy/mindflayer
	projectile_type = /obj/projectile/beam/mindflayer //Brian from Family Guy
	select_name = "MINDFUCK"
	fire_sound = 'sound/weapons/laser.ogg'

/obj/item/ammo_casing/energy/laser/minigun
	select_name = "practice your Rambo cosplay"
	variance = 0.8
