//////////////////////////////Construct Spells/////////////////////////

/mob/living/simple_animal/construct/proc/findNullRod(var/atom/target)
	if(istype(target,/obj/item/weapon/nullrod))
		var/turf/T = get_turf(target)
		nullblock = 1
		T.turf_animation('icons/effects/96x96.dmi',"nullding",-32,-32,MOB_LAYER+1,'sound/piano/Ab7.ogg')
		return 1
	else if(target.contents)
		for(var/atom/A in target.contents)
			findNullRod(A)
	return 0

/mob/living/simple_animal/construct/harvester/verb/harvesterharvest()//because harvest is already a proc
	set name = "Harvest"
	set desc = "Back to where I come from, and you're coming with me."
	set category = "Harvester"
	var/destination = null
	for(var/obj/machinery/singularity/narsie/large/N in world)
		destination = N.loc
		break
	if(destination)
		var/prey = 0
		for(var/mob/living/M in src.loc)
			nullblock = 0
			if(M != src)//to ensure that the harvester travels last
				for(var/turf/T in range(M,1))
					findNullRod(T)
				if(!nullblock)
					M.loc = destination
					prey = 1
		if(!nullblock)
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
				qdel(c_animation)
			src.loc = destination
			src << "<span class='warning'>You warp back to Nar-Sie[prey ? " along with your prey":""].</span>"
		else
			src << "<span class='warning'>Something is blocking the harvest.</span>"
			nullblock = 0
	else
		src << "<span class='danger'>...something's wrong!</span>"//There shouldn't be an instance of Harvesters when Nar-Sie isn't in the world.

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
