/obj/item/projectile/beam
	name = "laser"
	icon_state = "laser"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 40
	damage_type = BURN
	flag = "laser"
	eyeblur = 4
	var/frequency = 1
	var/ID = 0
	var/main = 0

	fired()
		main = 1
		ID = rand(0,1000)
		var/first = 1
		var/obj/effect/effect/laserdealer/lasor = new /obj/effect/effect/laserdealer(null)
		spawn(0)
			lasor.setup(ID)
		spawn(0)
			while(!bumped)
				step_towards(src, current)
				for(var/mob/living/M in loc)
					Bump(M)
				if((!( current ) || loc == current))
					current = locate(min(max(x + xo, 1), world.maxx), min(max(y + yo, 1), world.maxy), z)
				if((x == 1 || x == world.maxx || y == 1 || y == world.maxy))
					del(src)
					return
				if(!first)
					var/obj/item/projectile/beam/new_beam = new src.type(loc)
					processing_objects.Remove(new_beam)
					new_beam.dir = get_dir(src, current)
					new_beam.ID = ID
					new_beam.icon_state = icon_state
				else
					first = 0
		return

/obj/effect/effect/laserdealer
	name = "laserdealio"

	proc/setup(var/ID = 0)
		sleep(5)
		for(var/obj/item/projectile/beam/beam in world)
			if(ID == beam.ID)
				del(beam)
		spawn(0)
			del(src)

/obj/item/projectile/practice
	name = "laser"
	icon_state = "laser"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 0
	damage_type = BURN
	flag = "laser"
	eyeblur = 2


/obj/item/projectile/beam/heavylaser
	name = "heavy laser"
	icon_state = "heavylaser"
	damage = 60


/obj/item/projectile/beam/pulse
	name = "pulse"
	icon_state = "u_laser"
	damage = 40


/obj/item/projectile/beam/deathlaser
	name = "death laser"
	icon_state = "heavylaser"
	damage = 60

/obj/item/projectile/beam/emitter
	name = "emitter beam"
	icon_state = "emitter"



/obj/item/projectile/bluetag
	name = "lasertag beam"
	icon_state = "ice_2"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 0
	damage_type = BURN
	flag = "laser"

	on_hit(var/atom/target, var/blocked = 0)
		if(istype(target, /mob/living/carbon/human))
			var/mob/living/carbon/human/M = target
			if(istype(M.wear_suit, /obj/item/clothing/suit/redtag))
				M.Weaken(5)
		return 1

/obj/item/projectile/redtag
	name = "lasertag beam"
	icon_state = "laser"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 0
	damage_type = BURN
	flag = "laser"

	on_hit(var/atom/target, var/blocked = 0)
		if(istype(target, /mob/living/carbon/human))
			var/mob/living/carbon/human/M = target
			if(istype(M.wear_suit, /obj/item/clothing/suit/bluetag))
				M.Weaken(5)
		return 1