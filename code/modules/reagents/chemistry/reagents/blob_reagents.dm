// These can only be applied by blobs. They are what blobs are made out of.
/datum/reagent/blob
	name = "Unknown"
	description = "shouldn't exist and you should adminhelp immediately."
	color = "#FFFFFF"
	var/shortdesc = null //just damage and on_mob effects, doesn't include special, blob-tile only effects
	var/blobbernaut_message = "slams" //blobbernaut attack verb
	var/message = "The blob strikes you" //message sent to any mob hit by the blob
	var/message_living = null //extension to first mob sent to only living mobs i.e. silicons have no skin to be burnt

/datum/reagent/blob/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/O)
	return round(reac_volume * min(1.5 - touch_protection, 1), 0.1) //full touch protection means 50% volume, any prot below 0.5 means 100% volume.

/datum/reagent/blob/proc/damage_reaction(obj/effect/blob/B, original_health, damage, damage_type, cause) //when the blob takes damage, do this
	return damage

/datum/reagent/blob/proc/death_reaction(obj/effect/blob/B, cause) //when a blob dies, do this
	return

/datum/reagent/blob/proc/expand_reaction(obj/effect/blob/B, obj/effect/blob/newB, turf/T) //when the blob expands, do this
	return

//does brute and a little stamina damage
/datum/reagent/blob/ripping_tendrils
	name = "Ripping Tendrils"
	id = "ripping_tendrils"
	description = "will do medium brute and stamina damage."
	color = "#991010"
	blobbernaut_message = "rips"
	message_living = ", and you feel your skin ripping and tearing off"

/datum/reagent/blob/ripping_tendrils/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/O)
	reac_volume = ..()
	M.apply_damage(0.7*reac_volume, BRUTE)
	if(M)
		M.adjustStaminaLoss(0.5*reac_volume)
	if(iscarbon(M))
		M.emote("scream")

//does low toxin damage, but creates fragile spores when expanding or killed by weak attacks
/datum/reagent/blob/sporing_pods
	name = "Sporing Pods"
	id = "sporing_pods"
	description = "will do low toxin damage and produce fragile spores when killed or on expanding."
	shortdesc = "will do low toxin damage."
	color = "#E88D5D"
	message_living = ", and you feel sick"

/datum/reagent/blob/sporing_pods/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/O)
	reac_volume = ..()
	M.apply_damage(0.5*reac_volume, TOX)

/datum/reagent/blob/sporing_pods/damage_reaction(obj/effect/blob/B, original_health, damage, damage_type, cause)
	if(!isnull(cause) && damage <= 20 && original_health - damage <= 0 && prob(50)) //if the cause isn't fire or a bomb, the damage is less than 21, we're going to die from that damage, 50% chance of a shitty spore.
		B.visible_message("<span class='warning'><b>A spore floats free of the blob!</b></span>")
		var/mob/living/simple_animal/hostile/blob/blobspore/weak/BS = new/mob/living/simple_animal/hostile/blob/blobspore/weak(B.loc)
		BS.overmind = B.overmind
		BS.update_icons()
		B.overmind.blob_mobs.Add(BS)
	return ..()

/datum/reagent/blob/sporing_pods/expand_reaction(obj/effect/blob/B, obj/effect/blob/newB, turf/T)
	if(prob(10))
		var/mob/living/simple_animal/hostile/blob/blobspore/weak/BS = new/mob/living/simple_animal/hostile/blob/blobspore/weak(T)
		BS.overmind = B.overmind
		BS.update_icons()
		newB.overmind.blob_mobs.Add(BS)

//does brute damage but can replicate when damaged and has a chance of expanding again
/datum/reagent/blob/replicating_foam
	name = "Replicating Foam"
	id = "replicating_foam"
	description = "will do medium brute damage and replicate when damaged."
	shortdesc = "will do medium brute damage."
	color = "#7B5A57"

/datum/reagent/blob/replicating_foam/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/O)
	reac_volume = ..()
	M.apply_damage(0.6*reac_volume, BRUTE)

/datum/reagent/blob/replicating_foam/damage_reaction(obj/effect/blob/B, original_health, damage, damage_type, cause)
	if(damage > 0 && original_health - damage > 0)
		var/obj/effect/blob/newB = B.expand()
		if(newB)
			newB.health = original_health - damage
			newB.check_health(cause)
			newB.update_icon()
	return ..()

/datum/reagent/blob/replicating_foam/expand_reaction(obj/effect/blob/B, obj/effect/blob/newB, turf/T)
	if(prob(50))
		newB.expand() //do it again!

//does low burn and a lot of stamina damage, reacts to stamina damage
/datum/reagent/blob/energized_fibers
	name = "Energized Fibers"
	id = "energized_fibers"
	description = "will do low burn and high stamina damage, and react to stamina damage."
	shortdesc = "will do low burn and high stamina damage."
	color = "#EFD65A"
	blobbernaut_message = "shocks"
	message_living = ", and you feel a strong tingling sensation"

/datum/reagent/blob/energized_fibers/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/O)
	reac_volume = ..()
	M.apply_damage(0.5*reac_volume, BURN)
	if(M)
		M.adjustStaminaLoss(0.8*reac_volume)

/datum/reagent/blob/energized_fibers/damage_reaction(obj/effect/blob/B, original_health, damage, damage_type, cause)
	if(damage_type == STAMINA)
		B.visible_message("<span class='warning'><b>The blob abruptly regenerates!</b></span>")
		B.health = B.maxhealth //stop disabling the blob!
	return ..()

//sets you on fire, does burn damage
/datum/reagent/blob/boiling_oil
	name = "Boiling Oil"
	id = "boiling_oil"
	description = "will do medium burn damage and set targets on fire."
	color = "#B68D00"
	blobbernaut_message = "splashes"
	message = "The blob splashes you with burning oil"
	message_living = ", and you feel your skin char and melt"

/datum/reagent/blob/boiling_oil/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/O)
	reac_volume = ..()
	M.adjust_fire_stacks(round(reac_volume/12))
	M.IgniteMob()
	if(M)
		M.apply_damage(0.6*reac_volume, BURN)
	if(iscarbon(M))
		M.emote("scream")

/datum/reagent/blob/regenerative_materia
	name = "Regenerative Materia"
	id = "regenerative_materia"
	description = "will do low toxin damage and cause targets to believe they are fully healed."
	color = "#C8A5DC"
	message_living = ", and you feel <i>alive</i>"

/datum/reagent/blob/regenerative_materia/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/O)
	reac_volume = ..()
	if(M.reagents)
		M.reagents.add_reagent("regenerative_materia", 0.2*reac_volume)
	M.apply_damage(0.6*reac_volume, TOX)

/datum/reagent/blob/regenerative_materia/on_mob_life(mob/living/M)
	M.adjustToxLoss(1*REM)
	if(iscarbon(M))
		var/mob/living/carbon/N = M
		N.hal_screwyhud = 5 //fully healed, honest
	..()

/datum/reagent/blob/regenerative_materia/on_mob_delete(mob/living/M)
	if(iscarbon(M))
		var/mob/living/carbon/N = M
		N.hal_screwyhud = 0
	..()

//toxin, hallucination, and some bonus spore toxin
/datum/reagent/blob/hallucinogenic_nectar
	name = "Hallucinogenic Nectar"
	id = "hallucinogenic_nectar"
	description = "will do low toxin damage, vivid hallucinations, and inject targets with toxins."
	color = "#CD7794"
	blobbernaut_message = "splashes"
	message = "The blob splashes you with sticky nectar"
	message_living = ", and you feel really good"

/datum/reagent/blob/hallucinogenic_nectar/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/O)
	reac_volume = ..()
	M.hallucination += 0.8*reac_volume
	M.adjust_drugginess(0.8*reac_volume)

	if(M.reagents)
		M.reagents.add_reagent("spore", 0.2*reac_volume)
	M.apply_damage(0.6*reac_volume, TOX)

//kills sleeping targets and turns them into blob zombies
/datum/reagent/blob/zombifying_feelers
	name = "Zombifying Feelers"
	id = "zombifying_feelers"
	description = "will cause medium toxin damage and turn sleeping targets into blob zombies."
	color = "#828264"
	message_living = ", and you feel tired"

/datum/reagent/blob/zombifying_feelers/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/O)
	reac_volume = ..()
	M.apply_damage(0.6*reac_volume, TOX)
	if(O && ishuman(M) && M.stat == UNCONSCIOUS)
		M.death() //sleeping in a fight? bad plan.
		var/mob/living/simple_animal/hostile/blob/blobspore/BS = new/mob/living/simple_animal/hostile/blob/blobspore/weak(get_turf(M))
		BS.overmind = O
		BS.update_icons()
		O.blob_mobs.Add(BS)
		BS.Zombify(M)

//toxin, stamina, and some bonus spore toxin
/datum/reagent/blob/envenomed_filaments
	name = "Envenomed Filaments"
	id = "envenomed_filaments"
	description = "will cause medium toxin and stamina damage, and inject targets with toxins."
	color = "#9ACD32"
	message_living = ", and you feel sick and nauseated"

/datum/reagent/blob/envenomed_filaments/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/O)
	reac_volume = ..()
	if(M.reagents)
		M.reagents.add_reagent("spore", 0.2*reac_volume)
	M.apply_damage(0.6*reac_volume, TOX)
	if(M)
		M.adjustStaminaLoss(0.4*reac_volume)

//does oxygen damage, randomly pushes or pulls targets
/datum/reagent/blob/cyclonic_grid
	name = "Cyclonic Grid"
	id = "cyclonic_grid"
	description = "will cause high oxygen damage and randomly throw targets to or from it."
	color = "#9BCD9B"
	message = "The blob blasts you with a gust of air"
	message_living = ", and you can't catch your breath"

/datum/reagent/blob/cyclonic_grid/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/O)
	reac_volume = ..()
	reagent_vortex(M, rand(0, 1), reac_volume)
	M.losebreath += round(0.05*reac_volume)
	M.apply_damage(0.6*reac_volume, OXY)

//does tons of oxygen damage and a little brute
/datum/reagent/blob/lexorin_jelly
	name = "Lexorin Jelly"
	id = "lexorin_jelly"
	description = "will cause low brute and high oxygen damage, and cause targets to be unable to breathe."
	color = "#00E5B1"
	message_living = ", and your lungs feel heavy and weak"

/datum/reagent/blob/lexorin_jelly/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/O)
	reac_volume = ..()
	M.losebreath += round(0.2*reac_volume)
	M.apply_damage(0.2*reac_volume, BRUTE)
	if(M)
		M.apply_damage(0.6*reac_volume, OXY)

//does aoe brute damage when hitting targets, is immune to explosions
/datum/reagent/blob/explosive_lattice
	name = "Explosive Lattice"
	id = "explosive_lattice"
	description = "will do brute damage in an area around targets and is resistant to explosions."
	shortdesc = "will do brute damage in an area around targets."
	color = "#8B2500"
	blobbernaut_message = "blasts"
	message = "The blob blasts you"

/datum/reagent/blob/explosive_lattice/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/O)
	if(reac_volume >= 15) //if it's not a spore cloud, bad time incoming
		reac_volume = ..()
		var/obj/effect/overlay/temp/explosion/E = PoolOrNew(/obj/effect/overlay/temp/explosion, get_turf(M))
		E.alpha = 150
		for(var/mob/living/L in range(M, 1))
			if("blob" in L.faction) //no friendly fire
				continue
			L.apply_damage(0.6*reac_volume, BRUTE)
		if(M)
			M.apply_damage(0.1*reac_volume, BRUTE)
	else
		reac_volume = ..()
		M.apply_damage(0.8*reac_volume, BRUTE)

/datum/reagent/blob/explosive_lattice/damage_reaction(obj/effect/blob/B, original_health, damage, damage_type, cause)
	if(isnull(cause) && damage_type == BRUTE)
		return 0 //no-sell the explosion we do not take damage
	return ..()

//does semi-random brute damage and reacts to brute damage
/datum/reagent/blob/reactive_gelatin
	name = "Reactive Gelatin"
	id = "reactive_gelatin"
	description = "will do high brute damage and react to brute damage."
	shortdesc = "will do high brute damage."
	color = "#FFA500"
	blobbernaut_message = "pummels"
	message = "The blob pummels you"

/datum/reagent/blob/reactive_gelatin/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/O)
	reac_volume = ..()
	var/damage = rand(10, 30)/25
	M.apply_damage(damage*reac_volume, BRUTE)

/datum/reagent/blob/reactive_gelatin/damage_reaction(obj/effect/blob/B, original_health, damage, damage_type, cause)
	if(damage && damage_type == BRUTE && original_health - damage > 0) //is there any damage, is it brute, and will we be alive
		if(isliving(cause))
			B.visible_message("<span class='warning'><b>The blob retaliates, lashing out!</b></span>")
		for(var/atom/A in range(1, B))
			A.blob_act()
	return ..()

//does low burn damage and stamina damage and cools targets down
/datum/reagent/blob/cryogenic_liquid
	name = "Cryogenic Liquid"
	id = "cryogenic_liquid"
	description = "will do low burn and stamina damage, and cause targets to freeze."
	color = "#8BA6E9"
	blobbernaut_message = "splashes"
	message = "The blob splashes you with an icy liquid"
	message_living = ", and you feel cold and tired"

/datum/reagent/blob/cryogenic_liquid/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/O)
	reac_volume = ..()
	if(M.reagents)
		M.reagents.add_reagent("frostoil", 0.4*reac_volume)
		M.reagents.add_reagent("ice", 0.4*reac_volume)
	M.apply_damage(0.6*reac_volume, BURN)
	if(M)
		M.adjustStaminaLoss(0.4*reac_volume)

//does burn damage and EMPs, slightly fragile
/datum/reagent/blob/electromagnetic_web
	name = "Electromagnetic Web"
	id = "electromagnetic_web"
	description = "will do low burn damage and EMP targets, but is somewhat fragile."
	shortdesc = "will do low burn damage and EMP targets."
	color = "#83ECEC"
	blobbernaut_message = "lashes"
	message = "The blob lashes you"
	message_living = ", and you hear a faint buzzing"

/datum/reagent/blob/electromagnetic_web/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/O)
	reac_volume = ..()
	M.emp_act(2)
	if(M)
		M.apply_damage(0.6*reac_volume, BURN)

/datum/reagent/blob/electromagnetic_web/damage_reaction(obj/effect/blob/B, original_health, damage, damage_type, cause)
	return damage * 1.2 //a laser will do 24 damage, which will kill any recently-made normal blob

/datum/reagent/blob/electromagnetic_web/death_reaction(obj/effect/blob/B, cause)
	if(!isnull(cause))
		empulse(B.loc, 2, 3) //less than screen range, so you can stand out of range to avoid it

//does brute damage, bonus damage for each nearby blob, and spreads damage out
/datum/reagent/blob/synchronous_mesh
	name = "Synchronous Mesh"
	id = "synchronous_mesh"
	description = "will do brute damage for each nearby blob and spread damage between nearby blobs."
	shortdesc = "will do brute damage for each nearby blob."
	color = "#65ADA2"
	blobbernaut_message = "synchronously strikes"
	message = "The blobs strike you"

/datum/reagent/blob/synchronous_mesh/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/O)
	reac_volume = ..()
	M.apply_damage(0.1*reac_volume, BRUTE)
	if(M)
		for(var/obj/effect/blob/B in range(1, M)) //if the target is completely surrounded, this is 2.4*reac_volume bonus damage, total of 2.5*reac_volume
			if(M)
				var/obj/effect/overlay/temp/blob/OV = PoolOrNew(/obj/effect/overlay/temp/blob, B.loc)
				if(B.overmind)
					OV.color = B.overmind.blob_reagent_datum.color
				OV.do_attack_animation(M) //show them they're getting a bad time
				M.apply_damage(0.3*reac_volume, BRUTE)

/datum/reagent/blob/synchronous_mesh/damage_reaction(obj/effect/blob/B, original_health, damage, damage_type, cause)
	if(!isnull(cause)) //the cause isn't fire or bombs, so split the damage
		var/damagesplit = 0.8 //maximum split is 7.2, reducing the damage each blob takes to 14% but doing that damage to 9 blobs
		for(var/obj/effect/blob/C in orange(1, B))
			if(C.overmind && C.overmind.blob_reagent_datum == B.overmind.blob_reagent_datum) //if it doesn't have the same chemical, don't split damage to it
				damagesplit += 0.8
		for(var/obj/effect/blob/C in orange(1, B))
			if(C.overmind && C.overmind.blob_reagent_datum == B.overmind.blob_reagent_datum && !istype(C, /obj/effect/blob/core)) //only hurt blobs that have the same overmind chemical and aren't cores
				C.take_damage(damage/damagesplit, CLONE, B, 0)
		return damage / damagesplit
	else
		return damage * 1.25

//does brute damage through armor(but not though bio resistance)
/datum/reagent/blob/penetrating_spines
	name = "Penetrating Spines"
	id = "penetrating_spines"
	description = "will do medium brute damage through armor."
	color = "#408B80"
	blobbernaut_message = "stabs"
	message = "The blob stabs you"

/datum/reagent/blob/penetrating_spines/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/O)
	reac_volume = ..()
	M.adjustBruteLoss(0.6*reac_volume)

//does low brute damage, oxygen damage, and stamina damage and wets tiles when damaged
/datum/reagent/blob/pressurized_slime
	name = "Pressurized Slime"
	id = "pressurized_slime"
	description = "will do low brute, oxygen, and stamina damage, and wet tiles when damaged or killed."
	shortdesc = "will do low brute, oxygen, and stamina damage, and wet tiles under targets."
	color = "#AAAABB"
	blobbernaut_message = "emits slime at"
	message = "The blob splashes into you"
	message_living = ", and you gasp for breath"

/datum/reagent/blob/pressurized_slime/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/O)
	reac_volume = ..()
	var/turf/simulated/T = get_turf(M)
	if(istype(T, /turf/simulated) && prob(reac_volume))
		T.MakeSlippery(TURF_WET_WATER)
	M.apply_damage(0.4*reac_volume, BRUTE)
	if(M)
		M.apply_damage(0.4*reac_volume, OXY)
	if(M)
		M.adjustStaminaLoss(0.4*reac_volume)

/datum/reagent/blob/pressurized_slime/damage_reaction(obj/effect/blob/B, original_health, damage, damage_type, cause)
	for(var/turf/simulated/T in range(1, B))
		if(prob(damage))
			T.MakeSlippery(TURF_WET_WATER)
	return ..()

/datum/reagent/blob/pressurized_slime/death_reaction(obj/effect/blob/B, cause)
	if(!isnull(cause))
		B.visible_message("<span class='warning'><b>The blob ruptures, spraying the area with liquid!</b></span>")
	for(var/turf/simulated/T in range(1, B))
		if(prob(50))
			T.MakeSlippery(TURF_WET_WATER)

//does brute damage and throws or pulls nearby objects at the target
/datum/reagent/blob/dark_matter
	name = "Dark Matter"
	id = "dark_matter"
	description = "will do medium brute damage and pull nearby objects and enemies at the target."
	color = "#61407E"
	message = "You feel a thrum as the blob strikes you, and everything flies at you"

/datum/reagent/blob/dark_matter/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/O)
	reagent_vortex(M, 0, reac_volume)
	reac_volume = ..()
	M.apply_damage(0.4*reac_volume, BRUTE)

//does brute damage and throws or pushes nearby objects away from the target
/datum/reagent/blob/b_sorium
	name = "Sorium"
	id = "b_sorium"
	description = "will do medium brute damage and throw nearby objects and enemies away from the target."
	color = "#808000"
	message = "The blob slams into you and sends you flying"

/datum/reagent/blob/b_sorium/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/O)
	reagent_vortex(M, 1, reac_volume)
	reac_volume = ..()
	M.apply_damage(0.5*reac_volume, BRUTE)

/datum/reagent/blob/proc/reagent_vortex(mob/living/M, setting_type, reac_volume)
	if(M)
		var/turf/pull = get_turf(M)
		var/range_power = Clamp(round(reac_volume/5, 1), 1, 5)
		for(var/atom/movable/X in range(range_power,pull))
			if(istype(X, /obj/effect))
				continue
			if(isliving(X))
				var/mob/living/L = X
				if("blob" in L.faction) //no friendly throwpulling
					continue
			if(!X.anchored)
				var/distance = get_dist(X, pull)
				var/moving_power = max(range_power - distance, 1)
				if(moving_power > 2) //if the vortex is powerful and we're close, we get thrown
					if(setting_type)
						var/atom/throw_target = get_edge_target_turf(X, get_dir(X, get_step_away(X, pull)))
						var/throw_range = 5 - distance
						X.throw_at_fast(throw_target, throw_range, 1)
					else
						X.throw_at_fast(pull, distance, 1)
				else
					spawn(0)
						if(setting_type)
							for(var/i in 0 to moving_power-1)
								sleep(2)
								if(!step_away(X, pull))
									break
						else
							for(var/i in 0 to moving_power-1)
								sleep(2)
								if(!step_towards(X, pull))
									break


/datum/reagent/blob/proc/send_message(mob/living/M)
	var/totalmessage = message
	if(message_living && !issilicon(M))
		totalmessage += message_living
	totalmessage += "!"
	M << "<span class='userdanger'>[totalmessage]</span>"