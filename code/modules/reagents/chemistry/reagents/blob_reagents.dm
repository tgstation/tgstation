// These can only be applied by blobs. They are what blobs are made out of.
/datum/reagent/blob
	name = "Unknown"
	description = "shouldn't exist and you should adminhelp immediately."
	color = "#FFFFFF"
	var/complementary_color = "#000000" //a color that's complementary to the normal blob color
	var/shortdesc = null //just damage and on_mob effects, doesn't include special, blob-tile only effects
	var/blobbernaut_message = "slams" //blobbernaut attack verb
	var/message = "The blob strikes you" //message sent to any mob hit by the blob
	var/message_living = null //extension to first mob sent to only living mobs i.e. silicons have no skin to be burnt

/datum/reagent/blob/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/O)
	if(M.stat == DEAD)
		return 0 //the dead don't cause reactions
	if(istype(M, /mob/living/simple_animal/hostile/blob))
		return 0 //the blob mobs do not cause effects when hitting themselves or other blob mobs
	return round(reac_volume * min(1.5 - touch_protection, 1), 0.1) //full touch protection means 50% volume, any prot below 0.5 means 100% volume.

/datum/reagent/blob/proc/damage_reaction(obj/effect/blob/B, original_health, damage, damage_type, cause) //when the blob takes damage, do this
	return damage

/datum/reagent/blob/proc/death_reaction(obj/effect/blob/B, cause) //when a blob dies, do this
	return

/datum/reagent/blob/proc/expand_reaction(obj/effect/blob/B, obj/effect/blob/newB, turf/T) //when the blob expands, do this
	return

/datum/reagent/blob/proc/tesla_reaction(obj/effect/blob/B, power) //when the blob is hit by a tesla bolt, do this
	return 1 //return 0 to ignore damage

/datum/reagent/blob/proc/extinguish_reaction(obj/effect/blob/B) //when the blob is hit with water, do this
	return

//does low toxin damage, but creates fragile spores when expanding or killed by weak attacks
/datum/reagent/blob/sporing_pods
	name = "Sporing Pods"
	id = "sporing_pods"
	description = "will do low toxin damage and produce fragile spores when killed or on expanding."
	shortdesc = "will do low toxin damage."
	color = "#E88D5D"
	complementary_color = "#5DB8E8"
	message_living = ", and you feel sick"

/datum/reagent/blob/sporing_pods/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/O)
	reac_volume = ..()
	M.apply_damage(0.2*reac_volume, TOX)

/datum/reagent/blob/sporing_pods/damage_reaction(obj/effect/blob/B, original_health, damage, damage_type, cause)
	if(!isnull(cause) && damage <= 20 && original_health - damage <= 0 && prob(30)) //if the cause isn't fire or a bomb, the damage is less than 21, we're going to die from that damage, 30% chance of a shitty spore.
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
	description = "will do medium brute damage and replicate when damaged, but takes increased brute damage."
	shortdesc = "will do medium brute damage."
	color = "#7B5A57"
	complementary_color = "#57787B"

/datum/reagent/blob/replicating_foam/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/O)
	reac_volume = ..()
	M.apply_damage(0.6*reac_volume, BRUTE)

/datum/reagent/blob/replicating_foam/damage_reaction(obj/effect/blob/B, original_health, damage, damage_type, cause)
	var/effectivedamage = damage
	if(damage_type == BRUTE)
		effectivedamage = damage * 2
	if(effectivedamage > 0 && original_health - effectivedamage > 0 && prob(60))
		var/obj/effect/blob/newB = B.expand(null, null, 0)
		if(newB)
			newB.health = original_health - effectivedamage
			newB.check_health(cause)
			newB.update_icon()
	return effectivedamage

/datum/reagent/blob/replicating_foam/expand_reaction(obj/effect/blob/B, obj/effect/blob/newB, turf/T)
	if(prob(40))
		newB.expand() //do it again!

//does brute damage, shifts away when damaged
/datum/reagent/blob/shifting_fragments
	name = "Shifting Fragments"
	id = "shifting_fragments"
	description = "will do medium brute damage and shift away from damage."
	shortdesc = "will do medium brute damage."
	color = "#C8963C"
	complementary_color = "#3C6EC8"

/datum/reagent/blob/shifting_fragments/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/O)
	reac_volume = ..()
	M.apply_damage(0.6*reac_volume, BRUTE)

/datum/reagent/blob/shifting_fragments/expand_reaction(obj/effect/blob/B, obj/effect/blob/newB, turf/T)
	if(istype(B, /obj/effect/blob/normal) || (istype(B, /obj/effect/blob/shield) && prob(20)))
		newB.forceMove(get_turf(B))
		B.forceMove(T)

/datum/reagent/blob/shifting_fragments/damage_reaction(obj/effect/blob/B, original_health, damage, damage_type, cause)
	if(cause && damage > 0 && original_health - damage > 0 && prob(40))
		var/list/blobstopick = list()
		for(var/obj/effect/blob/OB in orange(1, B))
			if((istype(OB, /obj/effect/blob/normal) || istype(OB, /obj/effect/blob/shield)) && OB.overmind && OB.overmind.blob_reagent_datum.id == B.overmind.blob_reagent_datum.id)
				blobstopick += OB //as long as the blob picked is valid; ie, a normal or shield blob that has the same chemical as we do, we can swap with it
		if(blobstopick.len)
			var/obj/effect/blob/targeted = pick(blobstopick) //randomize the blob chosen, because otherwise it'd tend to the lower left
			var/turf/T = get_turf(targeted)
			targeted.forceMove(get_turf(B))
			B.forceMove(T) //swap the blobs
	return ..()

//does low burn and a lot of stamina damage, immune to tesla bolts
/datum/reagent/blob/energized_fibers
	name = "Energized Fibers"
	id = "energized_fibers"
	description = "will do low burn and high stamina damage and conduct electricity."
	shortdesc = "will do low burn and high stamina damage."
	color = "#EFD65A"
	complementary_color = "#5A73EF"
	blobbernaut_message = "shocks"
	message_living = ", and you feel a strong tingling sensation"

/datum/reagent/blob/energized_fibers/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/O)
	reac_volume = ..()
	M.apply_damage(0.4*reac_volume, BURN)
	if(M)
		M.adjustStaminaLoss(0.8*reac_volume)

/datum/reagent/blob/energized_fibers/tesla_reaction(obj/effect/blob/B, power)
	return 0

//sets you on fire, does burn damage, weak to water
/datum/reagent/blob/boiling_oil
	name = "Boiling Oil"
	id = "boiling_oil"
	description = "will do medium burn damage and set targets on fire, but is weak to water."
	shortdesc = "will do medium burn damage and set targets on fire."
	color = "#B68D00"
	complementary_color = "#0029B6"
	blobbernaut_message = "splashes"
	message = "The blob splashes you with burning oil"
	message_living = ", and you feel your skin char and melt"

/datum/reagent/blob/boiling_oil/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/O)
	reac_volume = ..()
	M.adjust_fire_stacks(round(reac_volume/12))
	M.IgniteMob()
	if(M)
		M.apply_damage(0.5*reac_volume, BURN)
	if(iscarbon(M))
		M.emote("scream")

/datum/reagent/blob/boiling_oil/extinguish_reaction(obj/effect/blob/B)
	B.take_damage(rand(1, 3), BURN)

//does burn and toxin damage, explodes into flame when hit with burn damage
/datum/reagent/blob/flammable_goo
	name = "Flammable Goo"
	id = "flammable_goo"
	description = "will do low burn damage, medium toxin damage, and ignite when burned."
	shortdesc = "will do low burn damage and medium toxin damage."
	color = "#BE5532"
	complementary_color = "#329BBE"
	blobbernaut_message = "splashes"
	message = "The blob splashes you with a thin goo"
	message_living = ", and you smell a faint, sweet scent"

/datum/reagent/blob/flammable_goo/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/O)
	reac_volume = ..()
	M.adjust_fire_stacks(round(reac_volume/10)) //apply, but don't ignite
	M.apply_damage(0.4*reac_volume, TOX)
	if(M)
		M.apply_damage(0.2*reac_volume, BURN)

/datum/reagent/blob/flammable_goo/damage_reaction(obj/effect/blob/B, original_health, damage, damage_type, cause)
	if(cause && damage_type == BURN)
		for(var/turf/T in range(1, B))
			if(!(locate(/obj/effect/blob) in T) && prob(80))
				PoolOrNew(/obj/effect/hotspot, T)
		return damage * 1.5
	return ..()

//does toxin damage, targets think they're not hurt at all
/datum/reagent/blob/regenerative_materia
	name = "Regenerative Materia"
	id = "regenerative_materia"
	description = "will do low toxin damage and cause targets to believe they are fully healed."
	color = "#C8A5DC"
	complementary_color = "#B9DCA5"
	message_living = ", and you feel <i>alive</i>"

/datum/reagent/blob/regenerative_materia/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/O)
	reac_volume = ..()
	if(M.reagents)
		M.reagents.add_reagent("regenerative_materia", 0.2*reac_volume)
	M.apply_damage(0.5*reac_volume, TOX)

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
	complementary_color = "#77CDB0"
	blobbernaut_message = "splashes"
	message = "The blob splashes you with sticky nectar"
	message_living = ", and you feel really good"

/datum/reagent/blob/hallucinogenic_nectar/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/O)
	reac_volume = ..()
	M.hallucination += 0.8*reac_volume
	M.adjust_drugginess(0.8*reac_volume)

	if(M.reagents)
		M.reagents.add_reagent("spore", 0.2*reac_volume)
	M.apply_damage(0.5*reac_volume, TOX)

//kills sleeping targets and turns them into blob zombies
/datum/reagent/blob/zombifying_feelers
	name = "Zombifying Feelers"
	id = "zombifying_feelers"
	description = "will cause medium toxin damage and turn sleeping targets into blob zombies."
	color = "#828264"
	complementary_color = "#646482"
	message_living = ", and you feel tired"

/datum/reagent/blob/zombifying_feelers/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/O)
	reac_volume = ..()
	if(O && ishuman(M) && M.stat == UNCONSCIOUS)
		M.death() //sleeping in a fight? bad plan.
		var/mob/living/simple_animal/hostile/blob/blobspore/BS = new/mob/living/simple_animal/hostile/blob/blobspore/weak(get_turf(M))
		BS.overmind = O
		BS.update_icons()
		O.blob_mobs.Add(BS)
		BS.Zombify(M)
	if(M)
		M.apply_damage(0.6*reac_volume, TOX)

//toxin, stamina, and some bonus spore toxin
/datum/reagent/blob/envenomed_filaments
	name = "Envenomed Filaments"
	id = "envenomed_filaments"
	description = "will cause medium toxin and stamina damage, and inject targets with toxins."
	color = "#9ACD32"
	complementary_color = "#6532CD"
	message_living = ", and you feel sick and nauseated"

/datum/reagent/blob/envenomed_filaments/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/O)
	reac_volume = ..()
	if(M.reagents)
		M.reagents.add_reagent("spore", 0.2*reac_volume)
	M.apply_damage(0.4*reac_volume, TOX)
	if(M)
		M.adjustStaminaLoss(0.4*reac_volume)

//does brute, fire, and toxin over a few seconds
/datum/reagent/blob/poisonous_strands
	name = "Poisonous Strands"
	id = "poisonous_strands"
	description = "will inject targets with poison."
	color = "#7D6EB4"
	complementary_color = "#A5B46E"
	blobbernaut_message = "injects"
	message_living = ", and you feel like your insides are melting"

/datum/reagent/blob/poisonous_strands/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/O)
	reac_volume = ..()
	if(M.reagents)
		M.reagents.add_reagent("poisonous_strands", 0.16*reac_volume)

/datum/reagent/blob/poisonous_strands/on_mob_life(mob/living/M)
	M.adjustBruteLoss(1*REM)
	M.adjustFireLoss(1*REM)
	M.adjustToxLoss(1*REM)
	..()

//does oxygen damage, randomly pushes or pulls targets
/datum/reagent/blob/cyclonic_grid
	name = "Cyclonic Grid"
	id = "cyclonic_grid"
	description = "will cause high oxygen damage and randomly throw targets to or from it."
	color = "#9BCD9B"
	complementary_color = "#CD9BCD"
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
	complementary_color = "#E50034"
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
	complementary_color = "#00668B"
	blobbernaut_message = "blasts"
	message = "The blob blasts you"

/datum/reagent/blob/explosive_lattice/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/O)
	reac_volume = ..()
	if(reac_volume >= 10) //if it's not a spore cloud, bad time incoming
		var/obj/effect/overlay/temp/explosion/E = PoolOrNew(/obj/effect/overlay/temp/explosion, get_turf(M))
		E.alpha = 150
		for(var/mob/living/L in orange(M, 1))
			if("blob" in L.faction) //no friendly fire
				continue
			L.apply_damage(0.6*reac_volume, BRUTE)
		if(M)
			M.apply_damage(0.6*reac_volume, BRUTE)
	else
		M.apply_damage(0.8*reac_volume, BRUTE)

/datum/reagent/blob/explosive_lattice/damage_reaction(obj/effect/blob/B, original_health, damage, damage_type, cause)
	if(isnull(cause))
		if(damage_type == BRUTE)
			return 0 //no-sell the explosion we do not take damage
		if(damage_type == BURN)
			return damage * 1.5 //take more from fire, tesla, and flashbangs
	return ..()

//does semi-random brute damage and reacts to brute damage
/datum/reagent/blob/reactive_gelatin
	name = "Reactive Gelatin"
	id = "reactive_gelatin"
	description = "will do random brute damage and react to brute damage."
	shortdesc = "will do random brute damage."
	color = "#FFA500"
	complementary_color = "#005AFF"
	blobbernaut_message = "pummels"
	message = "The blob pummels you"

/datum/reagent/blob/reactive_gelatin/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/O)
	reac_volume = ..()
	var/damage = rand(0, 30)/25
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
	complementary_color = "#E9CE8B"
	blobbernaut_message = "splashes"
	message = "The blob splashes you with an icy liquid"
	message_living = ", and you feel cold and tired"

/datum/reagent/blob/cryogenic_liquid/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/O)
	reac_volume = ..()
	if(M.reagents)
		M.reagents.add_reagent("frostoil", 0.4*reac_volume)
		M.reagents.add_reagent("ice", 0.4*reac_volume)
	M.apply_damage(0.4*reac_volume, BURN)
	if(M)
		M.adjustStaminaLoss(0.4*reac_volume)

//does burn damage and EMPs, slightly fragile
/datum/reagent/blob/electromagnetic_web
	name = "Electromagnetic Web"
	id = "electromagnetic_web"
	description = "will do low burn damage and EMP targets, but is very fragile."
	shortdesc = "will do low burn damage and EMP targets."
	color = "#83ECEC"
	complementary_color = "#EC8383"
	blobbernaut_message = "lashes"
	message = "The blob lashes you"
	message_living = ", and you hear a faint buzzing"

/datum/reagent/blob/electromagnetic_web/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/O)
	reac_volume = ..()
	if(prob(reac_volume*2))
		M.emp_act(2)
	if(M)
		M.apply_damage(0.6*reac_volume, BURN)

/datum/reagent/blob/electromagnetic_web/damage_reaction(obj/effect/blob/B, original_health, damage, damage_type, cause)
	if(damage_type == BRUTE) //take full brute
		switch(B.brute_resist)
			if(0.5)
				return damage * 2
			if(0.25)
				return damage * 4
			if(0.1)
				return damage * 10
	return damage * 1.25 //a laser will do 25 damage, which will kill any normal blob

/datum/reagent/blob/electromagnetic_web/death_reaction(obj/effect/blob/B, cause)
	if(cause)
		empulse(B.loc, 1, 3) //less than screen range, so you can stand out of range to avoid it

//does brute damage, bonus damage for each nearby blob, and spreads damage out
/datum/reagent/blob/synchronous_mesh
	name = "Synchronous Mesh"
	id = "synchronous_mesh"
	description = "will do brute damage for each nearby blob and spread damage between nearby blobs."
	shortdesc = "will do brute damage for each nearby blob."
	color = "#65ADA2"
	complementary_color = "#AD6570"
	blobbernaut_message = "synchronously strikes"
	message = "The blobs strike you"

/datum/reagent/blob/synchronous_mesh/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/O)
	reac_volume = ..()
	M.apply_damage(0.1*reac_volume, BRUTE)
	if(M && reac_volume)
		for(var/obj/effect/blob/B in range(1, M)) //if the target is completely surrounded, this is 2.4*reac_volume bonus damage, total of 2.5*reac_volume
			if(M)
				B.blob_attack_animation(M) //show them they're getting a bad time
				M.apply_damage(0.3*reac_volume, BRUTE)

/datum/reagent/blob/synchronous_mesh/damage_reaction(obj/effect/blob/B, original_health, damage, damage_type, cause)
	if(!isnull(cause)) //the cause isn't fire or bombs, so split the damage
		var/damagesplit = 1 //maximum split is 9, reducing the damage each blob takes to 11% but doing that damage to 9 blobs
		for(var/obj/effect/blob/C in orange(1, B))
			if(!istype(C, /obj/effect/blob/core) && !istype(C, /obj/effect/blob/node) && C.overmind && C.overmind.blob_reagent_datum.id == B.overmind.blob_reagent_datum.id) //if it doesn't have the same chemical or is a core or node, don't split damage to it
				damagesplit += 1
		for(var/obj/effect/blob/C in orange(1, B))
			if(!istype(C, /obj/effect/blob/core) && !istype(C, /obj/effect/blob/node) && C.overmind && C.overmind.blob_reagent_datum.id == B.overmind.blob_reagent_datum.id) //only hurt blobs that have the same overmind chemical and aren't cores or nodes
				C.take_damage(damage/damagesplit, CLONE, B, 0)
		return damage / damagesplit
	else
		return damage * 1.25

//does brute damage through armor(but not though bio resistance)
/datum/reagent/blob/penetrating_spines
	name = "Penetrating Spines"
	id = "penetrating_spines"
	description = "will do medium brute damage through armor."
	color = "#6E4664"
	complementary_color = "#466E50"
	blobbernaut_message = "stabs"
	message = "The blob stabs you"

/datum/reagent/blob/penetrating_spines/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/O)
	reac_volume = ..()
	M.adjustBruteLoss(0.6*reac_volume)

/datum/reagent/blob/adaptive_nexuses
	name = "Adaptive Nexuses"
	id = "adaptive_nexuses"
	description = "will do medium brute damage and kill unconscious targets, giving you bonus resources."
	shortdesc = "will do medium brute damage and kill unconscious targets, giving your overmind bonus resources."
	color = "#4A64C0"
	complementary_color = "#823ABB"

/datum/reagent/blob/adaptive_nexuses/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/O)
	reac_volume = ..()
	if(O && ishuman(M) && M.stat == UNCONSCIOUS)
		PoolOrNew(/obj/effect/overlay/temp/revenant, get_turf(M))
		var/points = rand(5, 10)
		O.add_points(points)
		O << "<span class='notice'>Gained [points] resources from the death of [M].</span>"
		M.death()
	if(M)
		M.apply_damage(0.6*reac_volume, BRUTE)

//does low brute damage, oxygen damage, and stamina damage and wets tiles when damaged
/datum/reagent/blob/pressurized_slime
	name = "Pressurized Slime"
	id = "pressurized_slime"
	description = "will do low brute, oxygen, and stamina damage, and wet tiles when damaged or killed."
	shortdesc = "will do low brute, oxygen, and stamina damage, and wet tiles under targets."
	color = "#AAAABB"
	complementary_color = "#BBBBAA"
	blobbernaut_message = "emits slime at"
	message = "The blob splashes into you"
	message_living = ", and you gasp for breath"

/datum/reagent/blob/pressurized_slime/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/O)
	reac_volume = ..()
	var/turf/open/T = get_turf(M)
	if(istype(T) && prob(reac_volume))
		T.MakeSlippery(TURF_WET_WATER)
	M.apply_damage(0.2*reac_volume, BRUTE)
	if(M)
		M.apply_damage(0.4*reac_volume, OXY)
	if(M)
		M.adjustStaminaLoss(0.4*reac_volume)

/datum/reagent/blob/pressurized_slime/damage_reaction(obj/effect/blob/B, original_health, damage, damage_type, cause)
	for(var/turf/open/T in range(1, B))
		if(prob(damage))
			T.MakeSlippery(TURF_WET_WATER)
	return ..()

/datum/reagent/blob/pressurized_slime/death_reaction(obj/effect/blob/B, cause)
	if(!isnull(cause))
		B.visible_message("<span class='warning'><b>The blob ruptures, spraying the area with liquid!</b></span>")
	for(var/turf/open/T in range(1, B))
		if(prob(50))
			T.MakeSlippery(TURF_WET_WATER)

//does brute damage and throws or pulls nearby objects at the target
/datum/reagent/blob/dark_matter
	name = "Dark Matter"
	id = "dark_matter"
	description = "will do medium brute damage and pull nearby objects and enemies at the target."
	color = "#61407E"
	complementary_color = "#5D7E40"
	message = "You feel a thrum as the blob strikes you, and everything flies at you"

/datum/reagent/blob/dark_matter/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/O)
	reac_volume = ..()
	reagent_vortex(M, 0, reac_volume)
	M.apply_damage(0.4*reac_volume, BRUTE)

//does brute damage and throws or pushes nearby objects away from the target
/datum/reagent/blob/b_sorium
	name = "Sorium"
	id = "b_sorium"
	description = "will do medium brute damage and throw nearby objects and enemies away from the target."
	color = "#808000"
	complementary_color = "#000080"
	message = "The blob slams into you and sends you flying"

/datum/reagent/blob/b_sorium/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/O)
	reac_volume = ..()
	reagent_vortex(M, 1, reac_volume)
	M.apply_damage(0.4*reac_volume, BRUTE)

/datum/reagent/blob/proc/reagent_vortex(mob/living/M, setting_type, reac_volume)
	if(M && reac_volume)
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