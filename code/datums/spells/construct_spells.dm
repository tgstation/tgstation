//////////////////////////////Construct Spells/////////////////////////

/obj/effect/proc_holder/spell/aoe_turf/conjure/construct/lesser
	charge_max = 1800
	summon_type = list(/obj/structure/constructshell/cult)

/obj/effect/proc_holder/spell/aoe_turf/conjure/floor
	name = "Floor Construction"
	desc = "This spell constructs a cult floor"

	school = "conjuration"
	charge_max = 20
	clothes_req = 0
	invocation = "none"
	invocation_type = "none"
	range = 0
	summon_type = list(/turf/simulated/floor/engine/cult)
	centcomm_cancast = 0 //Stop crashing the server by spawning turfs on transit tiles

/obj/effect/proc_holder/spell/aoe_turf/conjure/floor/conjure_animation(var/atom/movable/overlay/animation, var/turf/target)
	animation.icon_state = "cultfloor"
	flick("cultfloor",animation)
	spawn(10)
		del(animation)

/obj/effect/proc_holder/spell/aoe_turf/conjure/wall
	name = "Lesser Construction"
	desc = "This spell constructs a cult wall"

	school = "conjuration"
	charge_max = 100
	clothes_req = 0
	invocation = "none"
	invocation_type = "none"
	range = 0
	summon_type = list(/turf/simulated/wall/cult)
	centcomm_cancast = 0 //Stop crashing the server by spawning turfs on transit tiles

/obj/effect/proc_holder/spell/aoe_turf/conjure/wall/conjure_animation(var/atom/movable/overlay/animation, var/turf/target)
	animation.icon_state = "cultwall"
	flick("cultwall",animation)
	spawn(10)
		del(animation)

/obj/effect/proc_holder/spell/aoe_turf/conjure/wall/reinforced
	name = "Greater Construction"
	desc = "This spell constructs a reinforced metal wall"

	school = "conjuration"
	charge_max = 300
	clothes_req = 0
	invocation = "none"
	invocation_type = "none"
	range = 0
	centcomm_cancast = 0 //Stop crashing the server by spawning turfs on transit tiles
	delay = 50

	summon_type = list(/turf/simulated/wall/r_wall)

/obj/effect/proc_holder/spell/aoe_turf/conjure/soulstone
	name = "Summon Soulstone"
	desc = "This spell reaches into Nar-Sie's realm, summoning one of the legendary fragments across time and space"

	school = "conjuration"
	charge_max = 3000
	clothes_req = 0
	invocation = "none"
	invocation_type = "none"
	range = 0

	summon_type = list(/obj/item/device/soulstone)

/obj/effect/proc_holder/spell/aoe_turf/conjure/pylon
	name = "Red Pylon"
	desc = "This spell conjures a fragile crystal from Nar-Sie's realm. Makes for a convenient light source."

	school = "conjuration"
	charge_max = 200
	clothes_req = 0
	invocation = "none"
	invocation_type = "none"
	range = 0

	summon_type = list(/obj/structure/cult/pylon)

/obj/effect/proc_holder/spell/aoe_turf/conjure/pylon/cast(list/targets)
	for(var/turf/T in targets)
		if(T.density && !summon_ignore_density)
			targets -= T

	playsound(get_turf(src), cast_sound, 50, 1)

	if(do_after(usr,delay))
		for(var/i=0,i<summon_amt,i++)
			if(!targets.len)
				break
			var/summoned_object_type = pick(summon_type)
			var/turf/spawn_place = pick(targets)
			if(summon_ignore_prev_spawn_points)
				targets -= spawn_place

			for(var/obj/structure/cult/pylon/P in spawn_place.contents)
				if(P.isbroken)
					P.repair(usr)
				return

			var/atom/summoned_object = new summoned_object_type(spawn_place)

			for(var/varName in newVars)
				if(varName in summoned_object.vars)
					summoned_object.vars[varName] = newVars[varName]

	else
		switch(charge_type)
			if("recharge")
				charge_counter = charge_max - 5//So you don't lose charge for a failed spell(Also prevents most over-fill)
			if("charges")
				charge_counter++//Ditto, just for different spell types


	return


/obj/effect/proc_holder/spell/aoe_turf/conjure/lesserforcewall
	name = "Shield"
	desc = "Allows you to pull up a shield to protect yourself and allies from incoming threats"

	school = "conjuration"
	charge_max = 300
	clothes_req = 0
	invocation = "none"
	invocation_type = "none"
	range = 0
	summon_type = list(/obj/effect/forcefield/cult)
	summon_lifespan = 200


/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/shift
	name = "Phase Shift"
	desc = "This spell allows you to pass through walls"

	school = "transmutation"
	charge_max = 200
	clothes_req = 0
	invocation = "none"
	invocation_type = "none"
	range = -1
	include_user = 1
	jaunt_duration = 50 //in deciseconds
	centcomm_cancast = 0 //Stop people from getting to centcom

/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/shift/jaunt_disappear(var/atom/movable/overlay/animation, var/mob/living/target)
	animation.icon_state = "phase_shift"
	animation.dir = target.dir
	flick("phase_shift",animation)

/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/shift/jaunt_reappear(var/atom/movable/overlay/animation, var/mob/living/target)
	animation.icon_state = "phase_shift2"
	animation.dir = target.dir
	flick("phase_shift2",animation)

/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/shift/jaunt_steam(var/mobloc)
	return

/obj/effect/proc_holder/spell/targeted/projectile/magic_missile/lesser
	name = "Lesser Magic Missile"
	desc = "This spell fires several, slow moving, magic projectiles at nearby targets."

	school = "evocation"
	charge_max = 400
	clothes_req = 0
	invocation = "none"
	invocation_type = "none"
	proj_lifespan = 10
	max_targets = 6


/mob/living/simple_animal/construct/harvester/verb/harvesterharvest()//because harvest is already a proc
	set name = "Harvest"
	set desc = "Back to where I come from, and you're coming with me."
	set category = "Harvester"
	var/destination = null
	for(var/obj/machinery/singularity/narsie/large/N in world)
		destination = N.loc
		break
	if(destination)
		for(var/mob/living/M in src.loc)
			if(M != src)//to ensure that the harvester travels last
				var/obj/item/weapon/nullrod/N = locate() in M
				if(!N)
					M.loc = destination
		var/atom/movable/overlay/c_animation = new /atom/movable/overlay(src.loc)
		c_animation.name = "harvesting"
		c_animation.density = 0
		c_animation.anchored = 1
		c_animation.icon = 'icons/effects/effects.dmi'
		c_animation.layer = 5
		c_animation.master = src.loc
		c_animation.icon_state = "rune_teleport"
		flick("harvesting",c_animation)
		spawn(10)
			del(c_animation)
		src.loc = destination
	else
		src << "<span class='danger'>...something's wrong!</span>"

/mob/living/simple_animal/construct/harvester/verb/harvesterknock()
	set name = "Disintegrate Doors"
	set desc = "No door shall stop you."
	set category = "Harvester"
	if(doorcooldown >= 10)
		for(var/turf/T in range(3, src))
			for(var/obj/machinery/door/door in T.contents)
				spawn()
					door.cultify()
		doorcooldown = 0
	else
		src << "<span class='warning'>You aren't ready to disintegrate doors again just yet.</span>"

/mob/living/simple_animal/construct/harvester/verb/harvesterune()
	set name = "Scribe a Rune"
	set desc = "Let's you instantly manifest a working rune."
	set category = "Harvester"
	var/mob/living/simple_animal/construct/harvester/user = src
	if(!cultwords["travel"])
		runerandom()
	var/r											//shamelessly copied from /obj/item/weapon/tome/imbued
	if(user.runecooldown >= 10)
		if (!istype(user.loc,/turf))
			user << "<span class='warning'> You do not have enough space to write a proper rune.</span>"
			return
		var/list/runes = list("Teleport", "Teleport Other", "Spawn a Tome", "Change Construct Type", "Convert", "EMP", "Drain Blood", "See Invisible", "Resurrect", "Hide Runes", "Reveal Runes", "Astral Journey", "Manifest a Ghost", "Imbue Talisman", "Sacrifice", "Wall", "Free Cultist", "Summon Cultist", "Deafen", "Blind", "BloodBoil", "Communicate", "Stun")
		r = input("Choose a rune to scribe", "Rune Scribing") in runes //not cancellable.
		var/obj/effect/rune/R = new /obj/effect/rune(user.loc)
		switch(r)
			if("Teleport")
				if(user.runecooldown >= 10)
					user.runecooldown = 0
					var/list/words = list("ire", "ego", "nahlizet", "certum", "veri", "jatkaa", "balaq", "mgar", "karazet", "geeri")
					var/beacon
					if(usr)
						beacon = input("Select the last rune", "Rune Scribing") in words
					R.word1=cultwords["travel"]
					R.word2=cultwords["self"]
					R.word3=beacon
					R.check_icon()
			if("Teleport Other")
				if(user.runecooldown >= 10)
					user.runecooldown = 0
					var/list/words = list("ire", "ego", "nahlizet", "certum", "veri", "jatkaa", "balaq", "mgar", "karazet", "geeri")
					var/beacon
					if(usr)
						beacon = input("Select the last rune", "Rune Scribing") in words
					R.word1=cultwords["travel"]
					R.word2=cultwords["other"]
					R.word3=beacon
					R.check_icon()
			if("Spawn a Tome")
				if(user.runecooldown >= 10)
					user.runecooldown = 0
					R.word1=cultwords["see"]
					R.word2=cultwords["blood"]
					R.word3=cultwords["hell"]
					R.check_icon()
			if("Change Construct Type")
				if(user.runecooldown >= 10)
					user.runecooldown = 0
					R.word1=cultwords["hell"]
					R.word2=cultwords["destroy"]
					R.word3=cultwords["other"]
					R.check_icon()
			if("Convert")
				if(user.runecooldown >= 10)
					user.runecooldown = 0
					R.word1=cultwords["join"]
					R.word2=cultwords["blood"]
					R.word3=cultwords["self"]
					R.check_icon()
			if("EMP")
				if(user.runecooldown >= 10)
					user.runecooldown = 0
					R.word1=cultwords["destroy"]
					R.word2=cultwords["see"]
					R.word3=cultwords["technology"]
					R.check_icon()
			if("Drain Blood")
				if(user.runecooldown >= 10)
					user.runecooldown = 0
					R.word1=cultwords["travel"]
					R.word2=cultwords["blood"]
					R.word3=cultwords["self"]
					R.check_icon()
			if("See Invisible")
				if(user.runecooldown >= 10)
					user.runecooldown = 0
					R.word1=cultwords["see"]
					R.word2=cultwords["hell"]
					R.word3=cultwords["join"]
					R.check_icon()
			if("Resurrect")
				if(user.runecooldown >= 10)
					user.runecooldown = 0
					R.word1=cultwords["blood"]
					R.word2=cultwords["join"]
					R.word3=cultwords["hell"]
					R.check_icon()
			if("Hide Runes")
				if(user.runecooldown >= 10)
					user.runecooldown = 0
					R.word1=cultwords["hide"]
					R.word2=cultwords["see"]
					R.word3=cultwords["blood"]
					R.check_icon()
			if("Astral Journey")
				if(user.runecooldown >= 10)
					user.runecooldown = 0
					R.word1=cultwords["hell"]
					R.word2=cultwords["travel"]
					R.word3=cultwords["self"]
					R.check_icon()
			if("Manifest a Ghost")
				if(user.runecooldown >= 10)
					user.runecooldown = 0
					R.word1=cultwords["blood"]
					R.word2=cultwords["see"]
					R.word3=cultwords["travel"]
					R.check_icon()
			if("Imbue Talisman")
				if(user.runecooldown >= 10)
					user.runecooldown = 0
					R.word1=cultwords["hell"]
					R.word2=cultwords["technology"]
					R.word3=cultwords["join"]
					R.check_icon()
			if("Sacrifice")
				if(user.runecooldown >= 10)
					user.runecooldown = 0
					R.word1=cultwords["hell"]
					R.word2=cultwords["blood"]
					R.word3=cultwords["join"]
					R.check_icon()
			if("Reveal Runes")
				if(user.runecooldown >= 10)
					user.runecooldown = 0
					R.word1=cultwords["blood"]
					R.word2=cultwords["see"]
					R.word3=cultwords["hide"]
					R.check_icon()
			if("Wall")
				if(user.runecooldown >= 10)
					user.runecooldown = 0
					R.word1=cultwords["destroy"]
					R.word2=cultwords["travel"]
					R.word3=cultwords["self"]
					R.check_icon()
			if("Freedom")
				if(user.runecooldown >= 10)
					user.runecooldown = 0
					R.word1=cultwords["travel"]
					R.word2=cultwords["technology"]
					R.word3=cultwords["other"]
					R.check_icon()
			if("Cultsummon")
				if(user.runecooldown >= 10)
					user.runecooldown = 0
					R.word1=cultwords["join"]
					R.word2=cultwords["other"]
					R.word3=cultwords["self"]
					R.check_icon()
			if("Deafen")
				if(user.runecooldown >= 10)
					user.runecooldown = 0
					R.word1=cultwords["hide"]
					R.word2=cultwords["other"]
					R.word3=cultwords["see"]
					R.check_icon()
			if("Blind")
				if(user.runecooldown >= 10)
					user.runecooldown = 0
					R.word1=cultwords["destroy"]
					R.word2=cultwords["see"]
					R.word3=cultwords["other"]
					R.check_icon()
			if("BloodBoil")
				if(user.runecooldown >= 10)
					user.runecooldown = 0
					R.word1=cultwords["destroy"]
					R.word2=cultwords["see"]
					R.word3=cultwords["blood"]
					R.check_icon()
			if("Communicate")
				if(user.runecooldown >= 10)
					user.runecooldown = 0
					R.word1=cultwords["self"]
					R.word2=cultwords["other"]
					R.word3=cultwords["technology"]
					R.check_icon()
			if("Stun")
				if(user.runecooldown >= 10)
					user.runecooldown = 0
					R.word1=cultwords["join"]
					R.word2=cultwords["hide"]
					R.word3=cultwords["technology"]
					R.check_icon()
	else
		user << "<span class='warning'>You aren't ready to write another rune just yet.</span>"

