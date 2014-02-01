

// WAS: /datum/bioEffect/alcres
/datum/dna/gene/basic/sober
	name="Sober"
	activation_messages=list("You feel unusually sober.")
	deactivation_messages = list("You feel like you could use a stiff drink.")

	mutation=M_SOBER

	New()
		block=SOBERBLOCK

//WAS: /datum/bioEffect/psychic_resist
/datum/dna/gene/basic/psychic_resist
	name="Psy-Resist"
	desc = "Boosts efficiency in sectors of the brain commonly associated with meta-mental energies."
	activation_messages = list("Your mind feels closed.")
	deactivation_messages = list("You feel oddly exposed.")

	mutation=M_PSY_RESIST

	New()
		block=PSYRESISTBLOCK

/////////////////////////
// Stealth Enhancers
/////////////////////////

/datum/dna/gene/basic/stealth
	can_activate(var/mob/M, var/flags)
		// Can only activate one of these at a time.
		if(is_type_in_list(/datum/dna/gene/basic/stealth,M.active_genes))
			testing("Cannot activate [type]: /datum/dna/gene/basic/stealth in M.active_genes.")
			return 0
		return ..(M,flags)

	deactivate(var/mob/M)
		..(M)
		M.alpha=255

// WAS: /datum/bioEffect/darkcloak
/datum/dna/gene/basic/stealth/darkcloak
	name = "Cloak of Darkness"
	desc = "Enables the subject to bend low levels of light around themselves, creating a cloaking effect."
	activation_messages = list("You begin to fade into the shadows.")
	deactivation_messages = list("You become fully visible.")

	New()
		block=SHADOWBLOCK

	OnMobLife(var/mob/M)
		var/turf/simulated/T = get_turf(M)
		if(!istype(T))
			return
		if(T.lighting_lumcount <= 2)
			M.alpha = 0
		else
			M.alpha = round(255 * 0.80)

//WAS: /datum/bioEffect/chameleon
/datum/dna/gene/basic/stealth/chameleon
	name = "Chameleon"
	desc = "The subject becomes able to subtly alter light patterns to become invisible, as long as they remain still."
	activation_messages = list("You feel one with your surroundings.")
	deactivation_messages = list("You feel oddly exposed.")

	New()
		block=CHAMELEONBLOCK

	OnMobLife(var/mob/M)
		if((world.time - M.last_movement) >= 30 && !M.stat && M.canmove && !M.restrained())
			M.alpha = round(255 * 0.10)
		else
			M.alpha = round(255 * 0.80)

/////////////////////////////////////////////////////////////////////////////////////////

/datum/dna/gene/basic/grant_spell
	var/obj/effect/proc_holder/spell/spelltype

	activate(var/mob/M, var/connected, var/flags)
		..()
		M.spell_list += spelltype
		return 1

	deactivate(var/mob/M, var/connected, var/flags)
		..()
		M.spell_list -= spelltype
/datum/dna/gene/basic/grant_verb
	var/verbtype

	activate(var/mob/M, var/connected, var/flags)
		..()
		M.verbs += verbtype
		return 1

	deactivate(var/mob/M, var/connected, var/flags)
		..()
		M.verbs -= verbtype

// WAS: /datum/bioEffect/cryokinesis
/datum/dna/gene/basic/grant_spell/cryo
	name = "Cryokinesis"
	desc = "Allows the subject to lower the body temperature of others."
	activation_messages = list("You notice a strange cold tingle in your fingertips.")
	deactivation_messages = list("Your fingers feel warmer.")

	spelltype = /obj/effect/proc_holder/spell/targeted/cryokinesis

	New()
		..()
		block = CRYOBLOCK

/obj/effect/proc_holder/spell/targeted/cryokinesis
	name = "Cryokinesis"
	desc = "Drops the bodytemperature of another person."
	panel = "Mutant Powers"

	charge_type = "recharge"
	charge_max = 600

	clothes_req = 0
	stat_allowed = 0
	invocation_type = "none"
	range = 7
	selection_type = "range"
	var/list/compatible_mobs = list(/mob/living/carbon/human, /mob/living/carbon/monkey)

/obj/effect/proc_holder/spell/targeted/cryokinesis/cast(list/targets)
	if(!targets.len)
		usr << "<span class='notice'>No target found in range.</span>"
		return

	var/mob/living/carbon/C = targets[1]

	if(!iscarbon(C))
		usr << "\red This will only work on normal organic beings."
		return

	C.bodytemperature = -1500
	C.ExtinguishMob()

	C.visible_message("\red A cloud of fine ice crystals engulfs [C]!")

	//playsound(usr.loc, 'bamf.ogg', 50, 0)

	new/obj/effects/self_deleting(C.loc, icon('icons/effects/genetics.dmi', "cryokinesis"))

	return

/obj/effects/self_deleting
	density = 0
	opacity = 0
	anchored = 1
	icon = null
	desc = ""
	//layer = 15

	New(var/atom/location, var/icon/I, var/duration = 20, var/oname = "something")
		src.name = oname
		loc=location
		src.icon = I
		spawn(duration)
			qdel(src)

///////////////////////////////////////////////////////////////////////////////////////////

// WAS: /datum/bioEffect/mattereater
/datum/dna/gene/basic/grant_spell/mattereater
	name = "Matter Eater"
	desc = "Allows the subject to eat just about anything without harm."
	activation_messages = list("You feel hungry.")
	deactivation_messages = list("You don't feel quite so hungry anymore.")

	spelltype=/obj/effect/proc_holder/spell/targeted/eat

	New()
		..()
		block = EATBLOCK

/obj/effect/proc_holder/spell/targeted/eat
	name = "Eat"
	desc = "Eat just about anything!"
	panel = "Mutant Powers"

	charge_type = "recharge"
	charge_max = 300

	clothes_req = 0
	stat_allowed = 0
	invocation_type = "none"
	range = 1
	selection_type = "range"

/obj/effect/proc_holder/spell/targeted/eat/choose_targets(mob/user = usr)
	var/list/targets = list()
	var/list/possible_targets = list()

	for(var/obj/item/O in view_or_range(range, user, selection_type))
		possible_targets += O

	targets += input("Choose the target for the spell.", "Targeting") as mob in possible_targets

	if(!targets.len) //doesn't waste the spell
		revert_cast(user)
		return

	perform(targets)

/obj/effect/proc_holder/spell/targeted/eat/cast(list/targets)
	if(!targets.len)
		usr << "<span class='notice'>No target found in range.</span>"
		return

	var/obj/item/the_item = targets[1]

	usr.visible_message("\red [usr] eats [the_item].")
	playsound(usr.loc, 'sound/items/eatfood.ogg', 50, 0)

	del(the_item)

	if(ishuman(usr))
		var/mob/living/carbon/human/H=usr
		for(var/name in H.organs_by_name)
			var/datum/organ/external/affecting = null
			if(!H.organs[name])
				continue
			affecting = H.organs[name]
			if(!istype(affecting, /datum/organ/external))
				continue
			affecting.heal_damage(4, 0)
		usr:UpdateDamageIcon()
		usr:updatehealth()

	return

////////////////////////////////////////////////////////////////////////

//WAS: /datum/bioEffect/jumpy
/datum/dna/gene/basic/grant_spell/jumpy
	name = "Jumpy"
	desc = "Allows the subject to leap great distances."
	//cooldown = 30
	activation_messages = list("Your leg muscles feel taut and strong.")
	deactivation_messages = list("Your leg muscles shrink back to normal.")

	spelltype =/obj/effect/proc_holder/spell/targeted/leap

	New()
		..()
		block = JUMPBLOCK

/obj/effect/proc_holder/spell/targeted/leap
	name = "Jump"
	desc = "Leap great distances!"
	panel = "Mutant Powers"
	range = -1
	include_user = 1

	charge_type = "recharge"
	charge_max = 30

	clothes_req = 0
	stat_allowed = 0
	invocation_type = "none"

/obj/effect/proc_holder/spell/targeted/leap/cast(list/targets)
	if (istype(usr.loc,/mob/))
		usr << "\red You can't jump right now!"
		return

	if (istype(usr.loc,/turf/))
		usr.visible_message("\red <b>[usr.name]</b> takes a huge leap!")
		playsound(usr.loc, 'sound/weapons/thudswoosh.ogg', 50, 1)
		var/prevLayer = usr.layer
		usr.layer = 15

		for(var/i=0, i<10, i++)
			step(usr, usr.dir)
			if(i < 5) usr.pixel_y += 8
			else usr.pixel_y -= 8
			sleep(1)

		if (M_FAT in usr.mutations && prob(66))
			usr.visible_message("\red <b>[usr.name]</b> crashes due to their heavy weight!")
			//playsound(usr.loc, 'zhit.wav', 50, 1)
			usr.weakened += 10
			usr.stunned += 5

		usr.layer = prevLayer

	if (istype(usr.loc,/obj/))
		var/obj/container = usr.loc
		usr << "\red You leap and slam your head against the inside of [container]! Ouch!"
		usr.paralysis += 3
		usr.weakened += 5
		container.visible_message("\red <b>[usr.loc]</b> emits a loud thump and rattles a bit.")
		playsound(usr.loc, 'sound/effects/bang.ogg', 50, 1)
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

// WAS: /datum/bioEffect/polymorphism

/datum/dna/gene/basic/grant_spell/polymorph
	name = "Polymorphism"
	desc = "Enables the subject to reconfigure their appearance to mimic that of others."

	spelltype =/obj/effect/proc_holder/spell/targeted/polymorph
	//cooldown = 1800
	activation_messages = list("You don't feel entirely like yourself somehow.")
	deactivation_messages = list("You feel secure in your identity.")

	New()
		..()
		block = POLYMORPHBLOCK

/obj/effect/proc_holder/spell/targeted/polymorph
	name = "Polymorph"
	desc = "Mimic the appearance of others!"
	panel = "Mutant Powers"
	charge_max = 1800

	clothes_req = 0
	stat_allowed = 0
	invocation_type = "none"
	range = 1
	selection_type = "range"

/obj/effect/proc_holder/spell/targeted/polymorph/cast(list/targets)
	var/mob/living/M=targets[1]
	if(!ishuman(M))
		usr << "\red You can only change your appearance to that of another human."
		return

	if(!ishuman(usr)) return


	//playsound(usr.loc, 'blobattack.ogg', 50, 1)

	usr.visible_message("\red [usr]'s body shifts and contorts.")

	spawn(10)
		if(M && usr)
			//playsound(usr.loc, 'gib.ogg', 50, 1)
			usr.UpdateAppearance(M.dna.UI)
			usr:real_name = M:real_name
			usr:name = M:name
////////////////////////////////////////////////////////////////////////

// WAS: /datum/bioEffect/empath
/datum/dna/gene/basic/grant_verb/empath
	name = "Empathic Thought"
	desc = "The subject becomes able to read the minds of others for certain information."

	verbtype = /proc/bioproc_empath
	activation_messages = list("You suddenly notice more about others than you did before.")
	deactivation_messages = list("You no longer feel able to sense intentions.")

	New()
		..()
		block = EMPATHBLOCK

/proc/bioproc_empath(var/mob/living/carbon/M in range(7,usr))
	set name = "Read Mind"
	set desc = "Read the minds of others for information."
	set category = "Mutant Abilities"

	if(!iscarbon(M))
		usr << "\red You may only use this on other organic beings."
		return

	if(usr.stat)
		return

	if (M_PSY_RESIST in M.mutations)
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
	if (M.fire_stacks)
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
		var/numbers[0]
		var/mob/living/carbon/human/H = M
		if(H.mind && H.mind.initial_account)
			numbers += H.mind.initial_account.account_number
			numbers += H.mind.initial_account.remote_access_pin
		if(numbers.len>0)
			usr << "\blue <b>Numbers</b>: You sense the number[numbers.len>1?"s":""] [english_list(numbers)] [numbers.len>1?"are":"is"] important to [M.name]."
	usr << "\blue <b>Thoughts</b>: [M.name] is currently [thoughts]."

	if (/datum/dna/gene/basic/grant_verb/empath in M.active_genes)
		M << "\red You sense [usr.name] reading your mind."
	else if (prob(5) || M.mind.assigned_role=="Chaplain")
		M << "\red You sense someone intruding upon your thoughts..."
	return

////////////////////////////////////////////////////////////////////////

// WAS: /datum/bioEffect/superfart
/datum/dna/gene/basic/superfart
	name = "High-Pressure Intestines"
	desc = "Vastly increases the gas capacity of the subject's digestive tract."
	activation_messages = list("You feel bloated and gassy.")
	deactivation_messages = list("You no longer feel gassy. What a relief!")

	mutation = M_SUPER_FART

	New()
		..()
		block = SUPERFARTBLOCK