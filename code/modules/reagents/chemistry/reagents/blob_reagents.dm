// These can only be applied by blobs. They are what blobs are made out of.
/datum/reagent/blob
	name = "Unknown"
	description = "shouldn't exist and you should adminhelp immediately."
	color = "#FFFFFF"
	taste_description = "slime and errors"
	var/complementary_color = "#000000" //a color that's complementary to the normal blob color
	var/shortdesc = null //just damage and on_mob effects, doesn't include special, blob-tile only effects
	var/effectdesc = null //any long, blob-tile specific effects
	var/analyzerdescdamage = "Unknown. Report this bug to a coder, or just adminhelp."
	var/analyzerdesceffect = "N/A"
	var/blobbernaut_message = "slams" //blobbernaut attack verb
	var/message = "The blob strikes you" //message sent to any mob hit by the blob
	var/message_living = null //extension to first mob sent to only living mobs i.e. silicons have no skin to be burnt
	can_synth = 0

/datum/reagent/blob/proc/send_message(mob/living/M)
	var/totalmessage = message
	if(message_living && !issilicon(M))
		totalmessage += message_living
	totalmessage += "!"
	to_chat(M, "<span class='userdanger'>[totalmessage]</span>")

/datum/reagent/blob/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/O)
	if(M.stat == DEAD || istype(M, /mob/living/simple_animal/hostile/blob))
		return 0 //the dead, and blob mobs, don't cause reactions
	return round(reac_volume * min(1.5 - touch_protection, 1), 0.1) //full touch protection means 50% volume, any prot below 0.5 means 100% volume.

/datum/reagent/blob/proc/damage_reaction(obj/structure/blob/B, damage, damage_type, damage_flag) //when the blob takes damage, do this
	return damage

/datum/reagent/blob/proc/death_reaction(obj/structure/blob/B, damage_flag) //when a blob dies, do this
	return

/datum/reagent/blob/proc/expand_reaction(obj/structure/blob/B, obj/structure/blob/newB, turf/T, mob/camera/blob/O) //when the blob expands, do this
	return

/datum/reagent/blob/proc/tesla_reaction(obj/structure/blob/B, power) //when the blob is hit by a tesla bolt, do this
	return 1 //return 0 to ignore damage

/datum/reagent/blob/proc/extinguish_reaction(obj/structure/blob/B) //when the blob is hit with water, do this
	return

/datum/reagent/blob/proc/emp_reaction(obj/structure/blob/B, severity) //when the blob is hit with an emp, do this
	return

//does brute damage but can replicate when damaged and has a chance of expanding again
/datum/reagent/blob/replicating_foam
	name = "Replicating Foam"
	id = "replicating_foam"
	description = "will do medium brute damage and occasionally expand again when expanding."
	shortdesc = "will do medium brute damage."
	effectdesc = "will also expand when attacked with burn damage, but takes more brute damage."
	analyzerdescdamage = "Does medium brute damage."
	analyzerdesceffect = "Expands when attacked with burn damage, will occasionally expand again when expanding, and is fragile to brute damage."
	color = "#7B5A57"
	complementary_color = "#57787B"

/datum/reagent/blob/replicating_foam/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/O)
	reac_volume = ..()
	M.apply_damage(0.7*reac_volume, BRUTE)

/datum/reagent/blob/replicating_foam/damage_reaction(obj/structure/blob/B, damage, damage_type, damage_flag)
	if(damage_type == BRUTE)
		damage = damage * 2
	else if(damage_type == BURN && damage > 0 && B.obj_integrity - damage > 0 && prob(60))
		var/obj/structure/blob/newB = B.expand(null, null, 0)
		if(newB)
			newB.obj_integrity = B.obj_integrity - damage
			newB.update_icon()
	return ..()

/datum/reagent/blob/replicating_foam/expand_reaction(obj/structure/blob/B, obj/structure/blob/newB, turf/T, mob/camera/blob/O)
	if(prob(30))
		newB.expand(null, null, 0) //do it again!

//does massive brute and burn damage, but can only expand manually
/datum/reagent/blob/networked_fibers
	name = "Networked Fibers"
	id = "networked_fibers"
	description = "will do high brute and burn damage but non-manual expansion will only generate resources."
	shortdesc = "will do high brute and burn damage."
	effectdesc = "will move your core when manually expanding near it."
	analyzerdescdamage = "Does high brute and burn damage."
	analyzerdesceffect = "Is highly mobile and generates resources rapidly."
	color = "#CDC0B0"
	complementary_color = "#FFF68F"

/datum/reagent/blob/networked_fibers/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/O)
	reac_volume = ..()
	M.apply_damage(0.6*reac_volume, BRUTE)
	if(M)
		M.apply_damage(0.6*reac_volume, BURN)

/datum/reagent/blob/networked_fibers/expand_reaction(obj/structure/blob/B, obj/structure/blob/newB, turf/T, mob/camera/blob/O)
	if(!O && newB.overmind)
		if(!istype(B, /obj/structure/blob/node))
			newB.overmind.add_points(1)
			qdel(newB)
	else
		var/area/A = get_area(T)
		if(!isspaceturf(T) && !istype(A, /area/shuttle))
			for(var/obj/structure/blob/core/C in range(1, newB))
				if(C.overmind == O)
					newB.forceMove(get_turf(C))
					C.forceMove(T)
					C.setDir(get_dir(newB, C))
					O.add_points(1)

//does brute damage, shifts away when damaged
/datum/reagent/blob/shifting_fragments
	name = "Shifting Fragments"
	id = "shifting_fragments"
	description = "will do medium brute damage."
	effectdesc = "will also cause blob parts to shift away when attacked."
	analyzerdescdamage = "Does medium brute damage."
	analyzerdesceffect = "When attacked, may shift away from the attacker."
	color = "#C8963C"
	complementary_color = "#3C6EC8"

/datum/reagent/blob/shifting_fragments/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/O)
	reac_volume = ..()
	M.apply_damage(0.7*reac_volume, BRUTE)

/datum/reagent/blob/shifting_fragments/expand_reaction(obj/structure/blob/B, obj/structure/blob/newB, turf/T, mob/camera/blob/O)
	if(istype(B, /obj/structure/blob/normal) || (istype(B, /obj/structure/blob/shield) && prob(25)))
		newB.forceMove(get_turf(B))
		B.forceMove(T)

/datum/reagent/blob/shifting_fragments/damage_reaction(obj/structure/blob/B, damage, damage_type, damage_flag)
	if((damage_flag == "melee" || damage_flag == "bullet" || damage_flag == "laser") && damage > 0 && B.obj_integrity - damage > 0 && prob(60-damage))
		var/list/blobstopick = list()
		for(var/obj/structure/blob/OB in orange(1, B))
			if((istype(OB, /obj/structure/blob/normal) || (istype(OB, /obj/structure/blob/shield) && prob(25))) && OB.overmind && OB.overmind.blob_reagent_datum.id == B.overmind.blob_reagent_datum.id)
				blobstopick += OB //as long as the blob picked is valid; ie, a normal or shield blob that has the same chemical as we do, we can swap with it
		if(blobstopick.len)
			var/obj/structure/blob/targeted = pick(blobstopick) //randomize the blob chosen, because otherwise it'd tend to the lower left
			var/turf/T = get_turf(targeted)
			targeted.forceMove(get_turf(B))
			B.forceMove(T) //swap the blobs
	return ..()

//sets you on fire, does burn damage, explodes into flame when burnt, weak to water
/datum/reagent/blob/blazing_oil
	name = "Blazing Oil"
	id = "blazing_oil"
	description = "will do medium burn damage and set targets on fire."
	effectdesc = "will also release bursts of flame when burnt, but takes damage from water."
	analyzerdescdamage = "Does medium burn damage and sets targets on fire."
	analyzerdesceffect = "Releases fire when burnt, but takes damage from water and other extinguishing liquids."
	color = "#B68D00"
	complementary_color = "#BE5532"
	blobbernaut_message = "splashes"
	message = "The blob splashes you with burning oil"
	message_living = ", and you feel your skin char and melt"

/datum/reagent/blob/blazing_oil/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/O)
	reac_volume = ..()
	M.adjust_fire_stacks(round(reac_volume/10))
	M.IgniteMob()
	if(M)
		M.apply_damage(0.8*reac_volume, BURN)
	if(iscarbon(M))
		M.emote("scream")

/datum/reagent/blob/blazing_oil/extinguish_reaction(obj/structure/blob/B)
	B.take_damage(1.5, BURN, "energy")

/datum/reagent/blob/blazing_oil/damage_reaction(obj/structure/blob/B, damage, damage_type, damage_flag)
	if(damage_type == BURN && damage_flag != "energy")
		for(var/turf/open/T in range(1, B))
			var/obj/structure/blob/C = locate() in T
			if(!(C && C.overmind && C.overmind.blob_reagent_datum.id == B.overmind.blob_reagent_datum.id) && prob(80))
				new /obj/effect/hotspot(T)
	if(damage_flag == "fire")
		return 0
	return ..()

//does toxin damage, hallucination, targets think they're not hurt at all
/datum/reagent/blob/regenerative_materia
	name = "Regenerative Materia"
	id = "regenerative_materia"
	description = "will do toxin damage and cause targets to believe they are fully healed."
	analyzerdescdamage = "Does toxin damage and injects a toxin that causes the target to believe they are fully healed."
	color = "#C8A5DC"
	complementary_color = "#CD7794"
	message_living = ", and you feel <i>alive</i>"

/datum/reagent/blob/regenerative_materia/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/O)
	reac_volume = ..()
	M.adjust_drugginess(reac_volume)
	if(M.reagents)
		M.reagents.add_reagent("regenerative_materia", 0.2*reac_volume)
		M.reagents.add_reagent("spore", 0.2*reac_volume)
	M.apply_damage(0.7*reac_volume, TOX)

/datum/reagent/blob/regenerative_materia/on_mob_life(mob/living/M)
	M.adjustToxLoss(1*REM)
	if(iscarbon(M))
		var/mob/living/carbon/N = M
		N.hal_screwyhud = SCREWYHUD_HEALTHY //fully healed, honest
	..()

/datum/reagent/blob/regenerative_materia/on_mob_delete(mob/living/M)
	if(iscarbon(M))
		var/mob/living/carbon/N = M
		N.hal_screwyhud = 0
	..()

//kills sleeping targets and turns them into blob zombies, produces fragile spores when killed or on expanding
/datum/reagent/blob/zombifying_pods
	name = "Zombifying Pods"
	id = "zombifying_pods"
	description = "will do very low toxin damage and harvest sleeping targets for additional resources and a blob zombie."
	effectdesc = "will also produce fragile spores when killed and on expanding."
	shortdesc = "will do very low toxin damage and harvest sleeping targets for additional resources(for your overmind) and a blob zombie."
	analyzerdescdamage = "Does very low toxin damage and kills unconscious humans, turning them into blob zombies."
	analyzerdesceffect = "Produces spores when expanding and when killed."
	color = "#E88D5D"
	complementary_color = "#823ABB"
	message_living = ", and you feel tired"

/datum/reagent/blob/zombifying_pods/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/O)
	reac_volume = ..()
	M.apply_damage(0.6*reac_volume, TOX)
	if(O && ishuman(M) && M.stat == UNCONSCIOUS)
		M.death() //sleeping in a fight? bad plan.
		var/points = rand(5, 10)
		var/mob/living/simple_animal/hostile/blob/blobspore/BS = new/mob/living/simple_animal/hostile/blob/blobspore/weak(get_turf(M))
		BS.overmind = O
		BS.update_icons()
		O.blob_mobs.Add(BS)
		BS.Zombify(M)
		O.add_points(points)
		to_chat(O, "<span class='notice'>Gained [points] resources from the zombification of [M].</span>")

/datum/reagent/blob/zombifying_pods/damage_reaction(obj/structure/blob/B, damage, damage_type, damage_flag)
	if((damage_flag == "melee" || damage_flag == "bullet" || damage_flag == "laser") && damage <= 20 && B.obj_integrity - damage <= 0 && prob(30)) //if the cause isn't fire or a bomb, the damage is less than 21, we're going to die from that damage, 20% chance of a shitty spore.
		B.visible_message("<span class='warning'><b>A spore floats free of the blob!</b></span>")
		var/mob/living/simple_animal/hostile/blob/blobspore/weak/BS = new/mob/living/simple_animal/hostile/blob/blobspore/weak(B.loc)
		BS.overmind = B.overmind
		BS.update_icons()
		B.overmind.blob_mobs.Add(BS)
	return ..()

/datum/reagent/blob/zombifying_pods/expand_reaction(obj/structure/blob/B, obj/structure/blob/newB, turf/T, mob/camera/blob/O)
	if(prob(10))
		var/mob/living/simple_animal/hostile/blob/blobspore/weak/BS = new/mob/living/simple_animal/hostile/blob/blobspore/weak(T)
		BS.overmind = B.overmind
		BS.update_icons()
		newB.overmind.blob_mobs.Add(BS)

//does tons of oxygen damage and a little stamina, immune to tesla bolts, weak to EMP
/datum/reagent/blob/energized_jelly
	name = "Energized Jelly"
	id = "energized_jelly"
	description = "will cause low stamina and high oxygen damage, and cause targets to be unable to breathe."
	effectdesc = "will also conduct electricity, but takes damage from EMPs."
	analyzerdescdamage = "Does low stamina damage, high oxygen damage, and prevents targets from breathing."
	analyzerdesceffect = "Is immune to electricity and will easily conduct it, but is weak to EMPs."
	color = "#EFD65A"
	complementary_color = "#00E5B1"
	message_living = ", and you feel a horrible tingling sensation"

/datum/reagent/blob/energized_jelly/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/O)
	reac_volume = ..()
	M.losebreath += round(0.2*reac_volume)
	M.adjustStaminaLoss(0.4*reac_volume)
	if(M)
		M.apply_damage(0.6*reac_volume, OXY)

/datum/reagent/blob/energized_jelly/damage_reaction(obj/structure/blob/B, damage, damage_type, damage_flag)
	if((damage_flag == "melee" || damage_flag == "bullet" || damage_flag == "laser") && B.obj_integrity - damage <= 0 && prob(10))
		do_sparks(rand(2, 4), FALSE, B)
	return ..()

/datum/reagent/blob/energized_jelly/tesla_reaction(obj/structure/blob/B, power)
	return 0

/datum/reagent/blob/energized_jelly/emp_reaction(obj/structure/blob/B, severity)
	var/damage = rand(30, 50) - severity * rand(10, 15)
	B.take_damage(damage, BURN, "energy")

//does aoe brute damage when hitting targets, is immune to explosions
/datum/reagent/blob/explosive_lattice
	name = "Explosive Lattice"
	id = "explosive_lattice"
	description = "will do brute damage in an area around targets."
	effectdesc = "will also resist explosions, but takes increased damage from fire and other energy sources."
	analyzerdescdamage = "Does medium brute damage and causes damage to everyone near its targets."
	analyzerdesceffect = "Is highly resistant to explosions, but takes increased damage from fire and other energy sources."
	color = "#8B2500"
	complementary_color = "#00668B"
	blobbernaut_message = "blasts"
	message = "The blob blasts you"

/datum/reagent/blob/explosive_lattice/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/O)
	var/initial_volume = reac_volume
	reac_volume = ..()
	if(reac_volume >= 10) //if it's not a spore cloud, bad time incoming
		var/obj/effect/overlay/temp/explosion/fast/E = new /obj/effect/overlay/temp/explosion/fast(get_turf(M))
		E.alpha = 150
		for(var/mob/living/L in orange(get_turf(M), 1))
			if("blob" in L.faction) //no friendly fire
				continue
			var/aoe_volume = ..(L, TOUCH, initial_volume, 0, L.get_permeability_protection(), O)
			L.apply_damage(0.4*aoe_volume, BRUTE)
		if(M)
			M.apply_damage(0.6*reac_volume, BRUTE)
	else
		M.apply_damage(0.6*reac_volume, BRUTE)

/datum/reagent/blob/explosive_lattice/damage_reaction(obj/structure/blob/B, damage, damage_type, damage_flag)
	if(damage_flag == "bomb")
		return 0
	else if(damage_flag != "melee" || damage_flag != "bullet" || damage_flag != "laser")
		return damage * 1.5
	return ..()

//does brute, burn, and toxin damage, and cools targets down
/datum/reagent/blob/cryogenic_poison
	name = "Cryogenic Poison"
	id = "cryogenic_poison"
	description = "will inject targets with a freezing poison that does high damage over time."
	analyzerdescdamage = "Injects targets with a freezing poison that will gradually solidify the target's internal organs."
	color = "#8BA6E9"
	complementary_color = "#7D6EB4"
	blobbernaut_message = "injects"
	message = "The blob stabs you"
	message_living = ", and you feel like your insides are solidifying"

/datum/reagent/blob/cryogenic_poison/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/O)
	reac_volume = ..()
	if(M.reagents)
		M.reagents.add_reagent("frostoil", 0.3*reac_volume)
		M.reagents.add_reagent("ice", 0.3*reac_volume)
		M.reagents.add_reagent("cryogenic_poison", 0.3*reac_volume)
	M.apply_damage(0.2*reac_volume, BRUTE)

/datum/reagent/blob/cryogenic_poison/on_mob_life(mob/living/M)
	M.adjustBruteLoss(0.3*REM, 0)
	M.adjustFireLoss(0.3*REM, 0)
	M.adjustToxLoss(0.3*REM, 0)
	. = 1
	..()

//does burn damage and EMPs, slightly fragile
/datum/reagent/blob/electromagnetic_web
	name = "Electromagnetic Web"
	id = "electromagnetic_web"
	description = "will do high burn damage and EMP targets."
	effectdesc = "will also take massively increased damage and release an EMP when killed."
	analyzerdescdamage = "Does low burn damage and EMPs targets."
	analyzerdesceffect = "Is fragile to all types of damage, but takes massive damage from brute. In addition, releases a small EMP when killed."
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
		M.apply_damage(reac_volume, BURN)

/datum/reagent/blob/electromagnetic_web/damage_reaction(obj/structure/blob/B, damage, damage_type, damage_flag)
	if(damage_type == BRUTE) //take full brute
		switch(B.brute_resist)
			if(0.5)
				return damage * 2
			if(0.25)
				return damage * 4
			if(0.1)
				return damage * 10
	return damage * 1.25 //a laser will do 25 damage, which will kill any normal blob

/datum/reagent/blob/electromagnetic_web/death_reaction(obj/structure/blob/B, damage_flag)
	if(damage_flag == "melee" || damage_flag == "bullet" || damage_flag == "laser")
		empulse(B.loc, 1, 3) //less than screen range, so you can stand out of range to avoid it

//does brute damage, bonus damage for each nearby blob, and spreads damage out
/datum/reagent/blob/synchronous_mesh
	name = "Synchronous Mesh"
	id = "synchronous_mesh"
	description = "will do massively increased brute damage for each blob near the target."
	effectdesc = "will also spread damage between each blob near the attacked blob."
	analyzerdescdamage = "Does brute damage, increasing for each blob near the target."
	analyzerdesceffect = "When attacked, spreads damage between all blobs near the attacked blob."
	color = "#65ADA2"
	complementary_color = "#AD6570"
	blobbernaut_message = "synchronously strikes"
	message = "The blobs strike you"

/datum/reagent/blob/synchronous_mesh/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/O)
	reac_volume = ..()
	M.apply_damage(0.2*reac_volume, BRUTE)
	if(M && reac_volume)
		for(var/obj/structure/blob/B in range(1, M)) //if the target is completely surrounded, this is 2.4*reac_volume bonus damage, total of 2.6*reac_volume
			if(M)
				B.blob_attack_animation(M) //show them they're getting a bad time
				M.apply_damage(0.3*reac_volume, BRUTE)

/datum/reagent/blob/synchronous_mesh/damage_reaction(obj/structure/blob/B, damage, damage_type, damage_flag)
	if(damage_flag == "melee" || damage_flag == "bullet" || damage_flag == "laser") //the cause isn't fire or bombs, so split the damage
		var/damagesplit = 1 //maximum split is 9, reducing the damage each blob takes to 11% but doing that damage to 9 blobs
		for(var/obj/structure/blob/C in orange(1, B))
			if(!istype(C, /obj/structure/blob/core) && !istype(C, /obj/structure/blob/node) && C.overmind && C.overmind.blob_reagent_datum.id == B.overmind.blob_reagent_datum.id) //if it doesn't have the same chemical or is a core or node, don't split damage to it
				damagesplit += 1
		for(var/obj/structure/blob/C in orange(1, B))
			if(!istype(C, /obj/structure/blob/core) && !istype(C, /obj/structure/blob/node) && C.overmind && C.overmind.blob_reagent_datum.id == B.overmind.blob_reagent_datum.id) //only hurt blobs that have the same overmind chemical and aren't cores or nodes
				C.take_damage(damage/damagesplit, CLONE, 0, 0)
		return damage / damagesplit
	else
		return damage * 1.25

//does brute damage through armor and bio resistance
/datum/reagent/blob/reactive_spines
	name = "Reactive Spines"
	id = "reactive_spines"
	description = "will do medium brute damage through armor and bio resistance."
	effectdesc = "will also react when attacked with brute damage, attacking all near the attacked blob."
	analyzerdescdamage = "Does medium brute damage, ignoring armor and bio resistance."
	analyzerdesceffect = "When attacked with brute damage, will lash out, attacking everything near it."
	color = "#9ACD32"
	complementary_color = "#FFA500"
	blobbernaut_message = "stabs"
	message = "The blob stabs you"

/datum/reagent/blob/reactive_spines/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/O)
	if(M.stat == DEAD || istype(M, /mob/living/simple_animal/hostile/blob))
		return 0 //the dead, and blob mobs, don't cause reactions
	M.adjustBruteLoss(0.8*reac_volume)

/datum/reagent/blob/reactive_spines/damage_reaction(obj/structure/blob/B, damage, damage_type, damage_flag)
	if(damage && damage_type == BRUTE && B.obj_integrity - damage > 0) //is there any damage, is it brute, and will we be alive
		if(damage_flag == "melee")
			B.visible_message("<span class='boldwarning'>The blob retaliates, lashing out!</span>")
		for(var/atom/A in range(1, B))
			A.blob_act(B)
	return ..()

//does low brute damage, oxygen damage, and stamina damage and wets tiles when damaged
/datum/reagent/blob/pressurized_slime
	name = "Pressurized Slime"
	id = "pressurized_slime"
	description = "will do low brute, oxygen, and stamina damage, and wet tiles under targets."
	effectdesc = "will also wet tiles near blobs that are attacked or killed."
	analyzerdescdamage = "Does low brute damage, low oxygen damage, drains stamina, and wets tiles under targets, extinguishing them."
	analyzerdesceffect = "When attacked or killed, wets nearby tiles, extinguishing anything on them."
	color = "#AAAABB"
	complementary_color = "#BBBBAA"
	blobbernaut_message = "emits slime at"
	message = "The blob splashes into you"
	message_living = ", and you gasp for breath"

/datum/reagent/blob/pressurized_slime/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/O)
	reac_volume = ..()
	var/turf/open/T = get_turf(M)
	if(istype(T) && prob(reac_volume))
		T.MakeSlippery(min_wet_time = 10, wet_time_to_add = 5)
		M.adjust_fire_stacks(-(reac_volume / 10))
		M.ExtinguishMob()
	M.apply_damage(0.4*reac_volume, BRUTE)
	if(M)
		M.apply_damage(0.4*reac_volume, OXY)
	if(M)
		M.adjustStaminaLoss(0.2*reac_volume)

/datum/reagent/blob/pressurized_slime/damage_reaction(obj/structure/blob/B, damage, damage_type, damage_flag)
	if((damage_flag == "melee" || damage_flag == "bullet" || damage_flag == "laser") || damage_type != BURN)
		extinguisharea(B, damage)
	return ..()

/datum/reagent/blob/pressurized_slime/death_reaction(obj/structure/blob/B, damage_flag)
	if(damage_flag == "melee" || damage_flag == "bullet" || damage_flag == "laser")
		B.visible_message("<span class='boldwarning'>The blob ruptures, spraying the area with liquid!</span>")
		extinguisharea(B, 50)

/datum/reagent/blob/pressurized_slime/proc/extinguisharea(obj/structure/blob/B, probchance)
	for(var/turf/open/T in range(1, B))
		if(prob(probchance))
			T.MakeSlippery(min_wet_time = 10, wet_time_to_add = 5)
			for(var/obj/O in T)
				O.extinguish()
			for(var/mob/living/L in T)
				L.adjust_fire_stacks(-2.5)
				L.ExtinguishMob()
