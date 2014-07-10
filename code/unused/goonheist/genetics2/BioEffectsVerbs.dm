/datum/bioEffect/cryokinesis
	name = "Cryokinesis"
	desc = "Allows the subject to lower the body temperature of others."
	id = "cryokinesis"
	effectType = effectTypePower
	probability = 33
	blockCount = 3
	blockGaps = 2
	cooldown = 600
	msgGain = "You notice a strange cold tingle in your fingertips."
	msgLose = "Your fingers feel warmer."

	OnAdd()
		owner:verbs += /proc/bioproc_cryokinesis
		return

	OnRemove()
		owner:verbs -= /proc/bioproc_cryokinesis
		owner:verbs -= /proc/bioproc_cryokinesis_cd
		return

	OnLife()
		return

/proc/bioproc_cryokinesis_cd()
	set name = "Cryokinesis (c)"
	set desc = "Drops the bodytemperature of another person. Currently on cooldown, ironically enough."
	set category = "Mutant Abilities"

	usr << "\red Your cryokinetic ability is recharging."

/proc/bioproc_cryokinesis(var/mob/living/carbon/C in view())
	set name = "Cryokinesis"
	set desc = "Drops the bodytemperature of another person."
	set category = "Mutant Abilities"

	if(!iscarbon(C))
		usr << "\red This will only work on normal organic beings."
		return

	if(!can_act(usr)) return

	usr.verbs -= /proc/bioproc_cryokinesis
	usr.verbs += /proc/bioproc_cryokinesis_cd
	spawn(usr:bioHolder.GetCooldownForEffect("cryokinesis"))
		if (usr:bioHolder.HasEffect("cryokinesis"))
			usr.verbs += /proc/bioproc_cryokinesis
		usr.verbs -= /proc/bioproc_cryokinesis_cd

	C.bodytemperature = -1500
	if(C.burning) C.burning = 0

	C.visible_message("\red A cloud of fine ice crystals engulfs [C]!")

	playsound(usr.loc, 'bamf.ogg', 50, 0)

	new/obj/effects/self_deleting(C.loc, icon('genetics.dmi', "cryokinesis"))

	return

/obj/effects/self_deleting
	density = 0
	opacity = 0
	anchored = 1
	icon = null
	desc = ""
	layer = 15

	New(var/atom/location, var/icon/I, var/duration = 20, var/oname = "something")
		src.name = oname
		src.set_loc(location)
		src.icon = I
		spawn(duration)
			qdel(src)
///////////////////////////////////////////////////////////////////////////////////////////

/datum/bioEffect/mattereater
	name = "Matter Eater"
	desc = "Allows the subject to eat just about anything without harm."
	id = "mattereater"
	effectType = effectTypePower
	probability = 40
	blockCount = 4
	blockGaps = 2
	cooldown = 300
	msgGain = "You feel hungry."
	msgLose = "You don't feel quite so hungry anymore."

	OnAdd()
		owner:verbs += /proc/bioproc_mattereater
		return

	OnRemove()
		owner:verbs -= /proc/bioproc_mattereater
		owner:verbs -= /proc/bioproc_mattereater_cd
		return

	OnLife()
		return

/proc/bioproc_mattereater_cd()
	set name = "Eat (c)"
	set desc = "Eat just about anything! Currently on cooldown."
	set category = "Mutant Abilities"

	usr << "\red Your Matter Eating ability is recharging."

/proc/bioproc_mattereater()
	set name = "Eat"
	set desc = "Eat just about anything!"
	set category = "Mutant Abilities"

	if(!can_act(usr)) return

	usr.verbs -= /proc/bioproc_mattereater
	usr.verbs += /proc/bioproc_mattereater_cd
	spawn(usr:bioHolder.GetCooldownForEffect("mattereater"))
		if (usr:bioHolder.HasEffect("mattereater"))
			usr.verbs += /proc/bioproc_mattereater
		usr.verbs -= /proc/bioproc_mattereater_cd

	var/list/edible_items = list()
	for(var/obj/item/C in range(1,usr))
		edible_items += C
	if (!edible_items.len)
		usr << "/red You can't find anything nearby that's small enough to eat."
		return

	var/obj/item/the_item = input("Which item do you want to eat?","Matter Eater") as null|obj in edible_items
	if (!the_item)
		usr.verbs += /proc/bioproc_mattereater
		usr.verbs -= /proc/bioproc_mattereater_cd
		return

	spawn(300)
		if (usr:bioHolder.HasEffect("mattereater"))
			usr.verbs += /proc/bioproc_mattereater
		usr.verbs -= /proc/bioproc_mattereater_cd

	usr.visible_message("\red [usr] eats [the_item].")
	playsound(usr.loc, 'eatfood.ogg', 50, 0)

	qdel(the_item)

	if(ishuman(usr))
		for(var/A in usr.organs)
			var/datum/organ/external/affecting = null
			if(!usr.organs[A])    continue
			affecting = usr.organs[A]
			if(!istype(affecting, /datum/organ/external))    continue
			affecting.heal_damage(4, 0)
		usr:UpdateDamageIcon()
		usr:updatehealth()

	return

////////////////////////////////////////////////////////////////////////

/datum/bioEffect/jumpy
	name = "Jumpy"
	desc = "Allows the subject to leap great distances."
	id = "jumpy"
	effectType = effectTypePower
	probability = 75
	blockCount = 4
	blockGaps = 2
	cooldown = 30
	msgGain = "Your leg muscles feel taut and strong."
	msgLose = "Your leg muscles shrink back to normal."

	OnAdd()
		owner:verbs += /proc/bioproc_jumpy
		return

	OnRemove()
		owner:verbs -= /proc/bioproc_jumpy
		owner:verbs -= /proc/bioproc_jumpy_cd
		return

	OnLife()
		return

/proc/bioproc_jumpy_cd()
	set name = "Jump (c)"
	set desc = "Leap great distances! Currently on cooldown."
	set category = "Mutant Abilities"

	usr << "\red Your Jumping ability is recharging."

/proc/bioproc_jumpy()
	set name = "Jump"
	set desc = "Leap great distances!"
	set category = "Mutant Abilities"

	if(!can_act(usr)) return
	if (istype(usr.loc,/mob/))
		usr << "\red You can't jump right now!"
		return

	usr.verbs -= /proc/bioproc_jumpy
	usr.verbs += /proc/bioproc_jumpy_cd
	spawn(usr:bioHolder.GetCooldownForEffect("jumpy"))
		if (usr:bioHolder.HasEffect("jumpy"))
			usr.verbs += /proc/bioproc_jumpy
		usr.verbs -= /proc/bioproc_jumpy_cd

	if (istype(usr.loc,/turf/))
		usr.visible_message("\red <b>[usr.name]</b> takes a huge leap!")
		playsound(usr.loc, 'thudswoosh.ogg', 50, 1)
		var/prevLayer = usr.layer
		usr.layer = 15

		for(var/i=0, i<10, i++)
			step(usr, usr.dir)
			if(i < 5) usr.pixel_y += 8
			else usr.pixel_y -= 8
			sleep(1)

		if (usr:bioHolder.HasEffect("fat") && prob(66))
			usr.visible_message("\red <b>[usr.name]</b> crashes due to their heavy weight!")
			playsound(usr.loc, 'zhit.wav', 50, 1)
			usr.weakened += 10
			usr.stunned += 5

		usr.layer = prevLayer

	if (istype(usr.loc,/obj/))
		var/obj/container = usr.loc
		usr << "\red You leap and slam your head against the inside of [container]! Ouch!"
		usr.paralysis += 3
		usr.weakened += 5
		container.visible_message("\red <b>[usr.loc]</b> emits a loud thump and rattles a bit.")
		playsound(usr.loc, 'bang.ogg', 50, 1)
		var/wiggle = 6
		while(wiggle > 0)
			wiggle--
			container.pixel_x = rand(-3,3)
			container.pixel_y = rand(-3,3)
			sleep(1)
		container.pixel_x = 0
		container.pixel_y = 0


	return

////////////////////////////////////////////////////////////////////////

/datum/bioEffect/polymorphism
	name = "Polymorphism"
	desc = "Enables the subject to reconfigure their appearance to mimic that of others."
	id = "polymorphism"
	effectType = effectTypePower
	probability = 20
	blockCount = 4
	blockGaps = 4
	cooldown = 1800
	msgGain = "You don't feel entirely like yourself somehow."
	msgLose = "You feel secure in your identity."

	OnAdd()
		owner:verbs += /proc/bioproc_polymorphism
		return

	OnRemove()
		owner:verbs -= /proc/bioproc_polymorphism
		owner:verbs -= /proc/bioproc_polymorphism_cd
		return

	OnLife()
		return

/proc/bioproc_polymorphism_cd()
	set name = "Polymorph (c)"
	set desc = "Mimic the appearance of others! Currently on cooldown."
	set category = "Mutant Abilities"

	usr << "\red Your Polymorphing ability is recharging."

/proc/bioproc_polymorphism(var/mob/M in view())
	set name = "Polymorph"
	set desc = "Mimic the appearance of others!"
	set category = "Mutant Abilities"

	if(!ishuman(M))
		usr << "\red You can only change your appearance to that of another human."
		return

	if(!ishuman(usr)) return

	if(!can_act(usr)) return

	usr.verbs -= /proc/bioproc_polymorphism
	usr.verbs += /proc/bioproc_polymorphism_cd
	spawn(usr:bioHolder.GetCooldownForEffect("polymorphism"))
		if (usr:bioHolder.HasEffect("polymorphism"))
			usr.verbs += /proc/bioproc_polymorphism
		usr.verbs -= /proc/bioproc_polymorphism_cd

	playsound(usr.loc, 'blobattack.ogg', 50, 1)

	usr.visible_message("\red [usr]'s body shifts and contorts.")

	spawn(10)
		if(M && usr)
			playsound(usr.loc, 'gib.ogg', 50, 1)
			usr:bioHolder.CopyOther(M:bioHolder, copyAppearance = 1, copyPool = 0, copyEffectBlocks = 0, copyActiveEffects = 0)
			usr:real_name = M:real_name
			usr:name = M:name

	return

////////////////////////////////////////////////////////////////////////

/datum/bioEffect/telepathy
	name = "Telepathy"
	desc = "Allows the subject to project their thoughts into the minds of other organics."
	id = "telepathy"
	effectType = effectTypePower
	probability = 90
	blockCount = 4
	blockGaps = 2
	msgGain = "You can hear your own voice echoing in your mind."
	msgLose = "Your mental voice fades away."

	OnAdd()
		owner:verbs += /proc/bioproc_telepathy
		return

	OnRemove()
		owner:verbs -= /proc/bioproc_telepathy
		return

	OnLife()
		return

/proc/bioproc_telepathy(var/mob/living/carbon/M in range(7,usr))
	set name = "Telepathy"
	set desc = "Project your thoughts into the minds of other organics!"
	set category = "Mutant Abilities"

	if(!iscarbon(M))
		usr << "\red You may only use this on other organic beings."
		return

	if(!can_act(usr))
		return

	if (M:bioHolder.HasEffect("psy_resist"))
		usr << "\red You can't contact [M.name]'s mind at all!"
		return

	if(!M.client || M.stat)
		M << "\red You can't seem to get through to [M.name] mentally."
		return

	var/msg = input(usr, "Message to [M.name]:","Telepathy")
	if (!msg)
		return

	var/psyname = "A psychic voice"
	if (M:bioHolder.HasOneOfTheseEffects("telepathy","empath"))
		psyname = "[usr.name]"

	M << {"<span style='color: #BD33D9'><b>[psyname]</b> echoes, \"<i>[msg]</i>\"</span>"}
	usr << {"<span style='color: #BD33D9'>You echo \"<i>[msg]</i>\" to <b>[M.name]</b>.</span>"}

	telepathy_log.Add("<b>[round(((world.time / 10) / 60))]M: [usr.real_name] ([usr.key])</b> to [M.name]: [msg]")

	return
////////////////////////////////////////////////////////////////////////

/datum/bioEffect/empath
	name = "Empathic Thought"
	desc = "The subject becomes able to read the minds of others for certain information."
	id = "empath"
	effectType = effectTypePower
	probability = 33
	blockCount = 3
	blockGaps = 2
	msgGain = "You suddenly notice more about others than you did before."
	msgLose = "You no longer feel able to sense intentions."

	OnAdd()
		owner:verbs += /proc/bioproc_empath
		return

	OnRemove()
		owner:verbs -= /proc/bioproc_empath
		return

	OnLife()
		return

/proc/bioproc_empath(var/mob/living/carbon/M in range(7,usr))
	set name = "Read Mind"
	set desc = "Read the minds of others for information."
	set category = "Mutant Abilities"

	if(!iscarbon(M))
		usr << "\red You may only use this on other organic beings."
		return

	if(!can_act(usr))
		return

	if (M:bioHolder.HasEffect("psy_resist"))
		usr << "\red You can't see into [M.name]'s mind at all!"
		return

	if (M.stat == 2)
		usr << "\red [M.name] is dead and cannot have their mind read."
		return
	if (M.health < 0)
		usr << "\red [M.name] is dying, and their thoughts are too scrambled to read."
		return

	usr << "\blue Mind Reading of [M.name]:</b>"
	var/pain_condition = M.health
	// lower health means more pain
	var/list/randomthoughts = list("what to have for lunch","the future","the past","money",
	"their hair","what to do next","their job","space","amusing things","sad things",
	"annoying things","happy things","something incoherent","something they did wrong")
	var/thoughts = "thinking about [pick(randomthoughts)]"
	if (M.burning)
		pain_condition -= 50
		thoughts = "preoccupied with the fire"
	if (M.radiation)
		pain_condition -= 25

	switch(pain_condition)
		if (81 to INFINITY)
			usr << "\blue <b>Condition</b>: [M.name] feels good."
		if (61 to 80)
			usr << "\blue <b>Condition</b>: [M.name] is suffering mild pain."
		if (41 to 60)
			usr << "\blue <b>Condition</b>: [M.name] is suffering significant pain."
		if (21 to 40)
			usr << "\blue <b>Condition</b>: [M.name] is suffering severe pain."
		else
			usr << "\blue <b>Condition</b>: [M.name] is suffering excruciating pain."
			thoughts = "haunted by their own mortality"

	switch(M.a_intent)
		if ("help")
			usr << "\blue <b>Mood</b>: You sense benevolent thoughts from [M.name]."
		if ("disarm")
			usr << "\blue <b>Mood</b>: You sense cautious thoughts from [M.name]."
		if ("grab")
			usr << "\blue <b>Mood</b>: You sense hostile thoughts from [M.name]."
		if ("harm")
			usr << "\blue <b>Mood</b>: You sense cruel thoughts from [M.name]."
			for(var/mob/living/L in view(7,M))
				if (L == M)
					continue
				thoughts = "thinking about punching [L.name]"
				break
		else
			usr << "\blue <b>Mood</b>: You sense strange thoughts from [M.name]."

	if (istype(M,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		usr << "\blue <b>Numbers</b>: You sense the number [H.pin] is important to [M.name]."
	usr << "\blue <b>Thoughts</b>: [M.name] is currently [thoughts]."

	if (M:bioHolder.HasEffect("empath"))
		M << "\red You sense [usr.name] reading your mind."
	else if (prob(5) || M:bioHolder.HasEffect("training_chaplain"))
		M << "\red You sense someone intruding upon your thoughts..."
	return

////////////////////////////////////////////////////////////////////////
/datum/bioEffect/immolate
	name = "Incendiary Mitochondria"
	desc = "The subject becomes able to convert excess cellular energy into thermal energy."
	id = "immolate"
	effectType = effectTypePower
	probability = 33
	blockCount = 3
	blockGaps = 2
	cooldown = 600
	msgGain = "You suddenly feel rather hot."
	msgLose = "You no longer feel uncomfortably hot."

	OnAdd()
		owner:verbs += /proc/bioproc_immolate
		return

	OnRemove()
		owner:verbs -= /proc/bioproc_immolate
		owner:verbs -= /proc/bioproc_immolate_cd
		return

	OnLife()
		return

/proc/bioproc_immolate_cd()
	set name = "Immolate (c)"
	set desc = "Wreath yourself in burning flames. Currently on cooldown."
	set category = "Mutant Abilities"

	usr << "\red Your Immolation ability is recharging."

/proc/bioproc_immolate()
	set name = "Immolate"
	set desc = "Wreath yourself in burning flames."
	set category = "Mutant Abilities"

	if(!can_act(usr)) return

	if (istype(usr,/mob/living/))
		var/mob/living/L = usr

		L.set_burning(100)
		L.visible_message("\red <b>[L.name]</b> suddenly bursts into flames!")
		playsound(L.loc, 'mag_fireballlaunch.ogg', 50, 0)

		usr.verbs -= /proc/bioproc_immolate
		usr.verbs += /proc/bioproc_immolate_cd
		spawn(usr:bioHolder.GetCooldownForEffect("immolate"))
			if (usr:bioHolder.HasEffect("immolate"))
				usr.verbs += /proc/bioproc_immolate
			usr.verbs -= /proc/bioproc_immolate_cd

	return

////////////////////////////////////////////////////////////////////////

/datum/bioEffect/melt
	name = "Self Biomass Manipulation"
	desc = "The subject becomes able to transform the matter of their cells into a liquid state."
	id = "melt"
	effectType = effectTypePower
	probability = 33
	blockCount = 3
	blockGaps = 2
	msgGain = "You feel strange and jiggly."
	msgLose = "You feel more solid."

	OnAdd()
		owner:verbs += /proc/bioproc_melt
		return

	OnRemove()
		owner:verbs -= /proc/bioproc_melt
		return

	OnLife()
		return

/proc/bioproc_melt()
	set name = "Dissolve"
	set desc = "Transform yourself into a liquified state."
	set category = "Mutant Abilities"

	if(!can_act(usr)) return

	if (istype(usr,/mob/living/carbon/human/))
		var/mob/living/carbon/human/H = usr

		H.visible_message("\red <b>[H.name]'s flesh melts right off! Holy shit!</b>")
		if (H.gender == "female")
			playsound(H.loc, 'female_fallscream.ogg', 50, 0)
		else
			playsound(H.loc, 'male_fallscream.ogg', 50, 0)
		playsound(H.loc, 'bubbles.ogg', 50, 0)
		playsound(H.loc, 'loudcrunch2.ogg', 50, 0)
		gibs(H.loc)
		H.mutantrace = new /datum/mutantrace/skeleton(H)
		H.decomp_stage = 4
		H.brain_op_stage = 4
	else
		usr.visible_message("\red <b>[usr.name] melts into a pile of bloody viscera!</b>")
		usr.gib(1)

	return

////////////////////////////////////////////////////////////////////////

/datum/bioEffect/superfart
	name = "High-Pressure Intestines"
	desc = "Vastly increases the gas capacity of the subject's digestive tract."
	id = "superfart"
	effectType = effectTypePower
	probability = 25
	blockCount = 4
	blockGaps = 3
	cooldown = 900
	msgGain = "You feel bloated and gassy."
	msgLose = "You no longer feel gassy. What a relief!"

	OnAdd()
		owner:verbs += /proc/bioproc_superfart
		return

	OnRemove()
		owner:verbs -= /proc/bioproc_superfart
		owner:verbs -= /proc/bioproc_superfart_cd
		return

	OnLife()
		return

/proc/bioproc_superfart_cd()
	set name = "Super Fart (c)"
	set desc = "Unleash a gigantic fart! Currently on cooldown."
	set category = "Mutant Abilities"

	usr << "\red Your Super Fart ability is recharging."

/proc/bioproc_superfart()
	set name = "Super Fart"
	set desc = "Unleash a gigantic fart!"
	set category = "Mutant Abilities"

	if(!can_act(usr)) return

	if (istype(usr,/mob/living/))
		var/mob/living/L = usr

		if (L.stat || !can_act(L))
			L << "\red You can't do that while incapacitated."
			return

		L.visible_message("\red <b>[L.name]</b> hunches down and grits their teeth!")
		usr.verbs -= /proc/bioproc_superfart
		usr.verbs += /proc/bioproc_superfart_cd
		sleep(30)
		if (can_act(L))
			L.visible_message("\red <b>[L.name]</b> unleashes a [pick("tremendous","gigantic","colossal")] fart!")
			playsound(L.loc, 'superfart.ogg', 50, 0)
			for(var/mob/living/V in range(get_turf(L),6))
				shake_camera(V,10,5)
				if (V == L)
					continue
				V << "\red You are sent flying!"
				V.weakened += 5 // why the hell was this set to 12 christ
				step_away(V,get_turf(L),15)
				step_away(V,get_turf(L),15)
				step_away(V,get_turf(L),15)
			 if(L.bioHolder.HasEffect("toxic_farts"))
			 	for(var/turf/T in view(get_turf(L),2))
			 		new /obj/effects/fart_cloud(T,L)
		else
			L << "\red You were interrupted and couldn't fart! Rude!"
			usr.verbs += /proc/bioproc_superfart
			usr.verbs -= /proc/bioproc_superfart_cd
			return

		spawn(usr:bioHolder.GetCooldownForEffect("superfart"))
			if (usr:bioHolder.HasEffect("superfart"))
				usr.verbs += /proc/bioproc_superfart
			usr.verbs -= /proc/bioproc_superfart_cd

	return

////////////////////////////////////////////////////////////////////////

/datum/bioEffect/eyebeams
	name = "Optic Energizer"
	desc = "Imbues the subject's eyes with the potential to project concentrated thermal energy."
	id = "eyebeams"
	effectType = effectTypePower
	probability = 15
	blockCount = 3
	blockGaps = 5
	cooldown = 80
	msgGain = "Your eyes ache and burn."
	msgLose = "Your eyes stop aching."

	OnAdd()
		owner:verbs += /proc/bioproc_eyebeams
		return

	OnRemove()
		owner:verbs -= /proc/bioproc_eyebeams
		owner:verbs -= /proc/bioproc_eyebeams_cd
		return

	OnLife()
		return

/proc/bioproc_eyebeams_cd()
	set name = "Eye Beams (c)"
	set desc = "Shoot lasers from your eyes. Currently on cooldown."
	set category = "Mutant Abilities"

	usr << "\red Your Eye Beams ability is recharging."

/proc/bioproc_eyebeams()
	set name = "Eye Beams"
	set desc = "Shoot lasers from your eyes."
	set category = "Mutant Abilities"

	if(!can_act(usr)) return

	var/mob/living/L = usr
	var/turf/T = null
	switch(L.dir)
		if (NORTH) T = locate(L.x,L.y+1,L.z)
		if (SOUTH) T = locate(L.x,L.y-1,L.z)
		if (WEST) T = locate(L.x-1,L.y,L.z)
		if (EAST) T = locate(L.x+1,L.y,L.z)

	if (!istype(T,/turf/))
		return
	L.visible_message("\red <b>[L.name]</b> shoots eye beams!")
	var/datum/projectile/laser/eyebeams/PJ = new /datum/projectile/laser/eyebeams
	var/obj/projectile/P = unpool("projectile", /obj/projectile)
	if(!P)	return
	P.set_loc(usr.loc)
	if(PJ.shot_sound)
		playsound(usr, PJ.shot_sound, 50)
	P.projectile = new PJ.type
	P.set_icon()
	P.target = T
	P.yo = T.y - usr.loc.y
	P.xo = T.x - usr.loc.x
	P.projectile.shooter = L
	spawn( 0 )
		P.process()

	usr.verbs -= /proc/bioproc_eyebeams
	usr.verbs += /proc/bioproc_eyebeams_cd
	spawn(usr:bioHolder.GetCooldownForEffect("eyebeams"))
		if (usr:bioHolder.HasEffect("eyebeams"))
			usr.verbs += /proc/bioproc_eyebeams
		usr.verbs -= /proc/bioproc_eyebeams_cd

/datum/projectile/laser/eyebeams
	name = "optic laser"
	icon_state = "eyebeam"
	power = 20
	cost = 20
	sname = "phaser bolt"
	dissipation_delay = 5
	shot_sound = 'TaserOLD.ogg'
	color_red = 1
	color_green = 0
	color_blue = 1