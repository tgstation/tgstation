#define EAT_MOB_DELAY 300 // 30s

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

	deactivate(var/mob/M, var/connected, var/flags)
		if(..(M,connected,flags))
			M.alphas -= "chameleon_stealth"
			M.handle_alpha()

// WAS: /datum/bioEffect/darkcloak
/*/datum/dna/gene/basic/stealth/darkcloak
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
			M.alpha -= 25
		else
			M.alpha = round(255 * 0.80)
*/
//WAS: /datum/bioEffect/chameleon
/datum/dna/gene/basic/stealth/chameleon
	name = "Chameleon"
	desc = "The subject becomes able to subtly alter light patterns to become invisible, as long as they remain still."
	activation_messages = list("You feel one with your surroundings.")
	deactivation_messages = list("You feel oddly exposed.")

	New()
		block=CHAMELEONBLOCK

	OnMobLife(var/mob/M)
		if((world.time - M.last_movement) >= 30 && !M.isUnconscious() && M.canmove && !M.restrained())
			M.alphas["chameleon_stealth"] = max(M.alphas["chameleon_stealth"] - 25, 0)
		else
			M.alphas["chameleon_stealth"] = round(255 * 0.80)

/////////////////////////////////////////////////////////////////////////////////////////

/datum/dna/gene/basic/grant_spell
	var/spell/spelltype
	var/list/granted_spells

	activate(var/mob/M, var/connected, var/flags)
		..(M,connected,flags)
		var/spell/granted = new spelltype
		M.add_spell(granted, "genetic_spell_ready", /obj/screen/movable/spell_master/genetic)
		if(!granted_spells)
			granted_spells = list()
		granted_spells += granted
		//testing("[M] added [granted.name] from [name]")
		return 1

	deactivate(var/mob/M, var/connected, var/flags)
		if(..(M,connected,flags))
			for(var/spell/S in M.spell_list)
				if(S in granted_spells)
					M.remove_spell(S)
					granted_spells -= S
					//testing("[M] removed [S.name] from [name]")
					qdel(S)
			return 1
		return 0

/datum/dna/gene/basic/grant_verb
	var/verbtype

	activate(var/mob/M, var/connected, var/flags)
		..(M,connected,flags)
		M.verbs += verbtype
		//testing("[M] added [verbtype] from [name]")
		return 1

	deactivate(var/mob/M, var/connected, var/flags)
		if(..(M,connected,flags))
			M.verbs -= verbtype
			//testing("[M] removed [verbtype] from [name]")
			return 1
		return 0

// WAS: /datum/bioEffect/cryokinesis
/datum/dna/gene/basic/grant_spell/cryo
	name = "Cryokinesis"
	desc = "Allows the subject to lower the body temperature of others."
	activation_messages = list("You notice a strange cold tingle in your fingertips.")
	deactivation_messages = list("Your fingers feel warmer.")

	drug_activation_messages=list("Your skin is icy to the touch.")
	drug_deactivation_messages=list("Your skin stops feeling icy.")

	spelltype = /spell/targeted/cryokinesis

	New()
		..()
		block = CRYOBLOCK

/spell/targeted/cryokinesis
	name = "Cryokinesis"
	desc = "Drops the bodytemperature of another person."
	panel = "Mutant Powers"

	charge_type = Sp_RECHARGE
	charge_max = 600

	spell_flags = WAIT_FOR_CLICK
	invocation_type = SpI_NONE
	range = 7
	max_targets = 1
	selection_type = "range"

	override_base = "genetic"
	hud_state = "gen_ice"
	compatible_mobs = list(/mob/living/carbon/human, /mob/living/carbon/monkey)

/spell/targeted/cryokinesis/cast(list/targets)
	..()
	for(var/mob/living/carbon/target in targets)
		if (M_RESIST_COLD in target.mutations)
			target.visible_message("<span class='warning'>A cloud of fine ice crystals engulfs [target.name], but disappears almost instantly!</span>")
			return
		var/handle_suit = 0
		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			if(istype(H.head, /obj/item/clothing/head/helmet/space))
				if(istype(H.wear_suit, /obj/item/clothing/suit/space))
					handle_suit = 1
					if(H.internal)
						H.visible_message("<span class='warning'>A cloud of fine ice crystals engulfs [H]!</span>",
											"<span class='notice'>A cloud of fine ice crystals cover your [H.head]'s visor.</span>")
					else
						H.visible_message("<span class='warning'>A cloud of fine ice crystals engulfs [H]!</span>",
											"<span class='warning'>A cloud of fine ice crystals cover your [H.head]'s visor and make it into your air vents!.</span>")
						H.bodytemperature = max(T0C + 31, H.bodytemperature - 3)
						H.adjustFireLoss(5)
		if(!handle_suit)
			target.bodytemperature = max(T0C + 29, target.bodytemperature - 5)
			target.adjustFireLoss(10)
			target.ExtinguishMob()

			target.visible_message("<span class='warning'>A cloud of fine ice crystals engulfs [target]!</span>")

		anim(target = target, a_icon = 'icons/effects/genetics.dmi', flick_anim = "cryokinesis")

///////////////////////////////////////////////////////////////////////////////////////////

// WAS: /datum/bioEffect/mattereater
/datum/dna/gene/basic/grant_spell/mattereater
	name = "Matter Eater"
	desc = "Allows the subject to eat just about anything without harm."
	activation_messages = list("You feel hungry.")
	deactivation_messages = list("You don't feel quite so hungry anymore.")

	drug_activation_messages=list("You are getting the munchies.")
	drug_deactivation_messages=list("You no longer getting the munchies.")

	spelltype=	/spell/targeted/eat

	New()
		..()
		block = EATBLOCK

/spell/targeted/eat
	name = "Eat"
	desc = "Eat just about anything!"
	panel = "Mutant Powers"

	charge_type = Sp_RECHARGE
	charge_max = 300

	invocation_type = SpI_NONE
	range = 1
	max_targets = 1
	selection_type = "view"
	spell_flags = WAIT_FOR_CLICK

	override_base = "genetic"
	hud_state = "gen_eat"

	cast_sound = 'sound/items/eatfood.ogg'
	compatible_mobs = list(
		/obj/item,
		/mob/living/simple_animal/hostile,
		/mob/living/simple_animal/parrot,
		/mob/living/simple_animal/cat,
		/mob/living/simple_animal/corgi,
		/mob/living/simple_animal/crab,
		/mob/living/simple_animal/mouse,
		/mob/living/carbon/monkey,
		/mob/living/carbon/human,
		/mob/living/carbon/slime,
		/mob/living/carbon/alien/larva,
		/mob/living/simple_animal/slime,
		/mob/living/simple_animal/adultslime,
		/mob/living/simple_animal/tomato,
		/mob/living/simple_animal/chick,
		/mob/living/simple_animal/chicken,
		/mob/living/simple_animal/lizard,
		/mob/living/simple_animal/cow,
		/mob/living/simple_animal/spiderbot
		)

/spell/targeted/eat/proc/doHeal(var/mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H=user
		for(var/name in H.organs_by_name)
			var/datum/organ/external/affecting = null
			if(!H.organs[name])
				continue
			affecting = H.organs[name]
			if(!istype(affecting, /datum/organ/external))
				continue
			affecting.heal_damage(4, 0)
		H.UpdateDamageIcon()
		H.updatehealth()

/spell/targeted/eat/is_valid_target(var/target)
	if(!(spell_flags & INCLUDEUSER) && target == usr)
		return 0
	if(get_dist(usr, target) > range)
		return 0
	return is_type_in_list(target, compatible_mobs)

/spell/targeted/eat/choose_targets(mob/user = usr)
	var/list/targets = list()

	if(max_targets == 0) //unlimited
		for(var/atom/movable/target in view_or_range(range, user, selection_type))
			if(!is_type_in_list(target, compatible_mobs) && !istype(target, /obj/item))
				continue
			if(istype(target, /obj/item/weapon/implant))
				var/obj/item/weapon/implant/implant = target
				if(implant.imp_in) //Implanted implant, don't eat that
					continue
			targets += target
	else if(max_targets == 1) //single target can be picked
		if(range <= 0 && spell_flags & INCLUDEUSER)
			targets += user
		else
			var/list/possible_targets = list()

			for(var/atom/movable/M in view_or_range(range, user, selection_type))
				if(!(spell_flags & INCLUDEUSER) && M == user)
					continue
				if(!is_type_in_list(M, compatible_mobs) && !istype(M, /obj/item))
					continue
				if(istype(M, /obj/item/weapon/implant))
					var/obj/item/weapon/implant/implant = M
					if(implant.imp_in) //Implanted implant, don't eat that
						continue
				possible_targets += M

			if(possible_targets.len)
				if(spell_flags & SELECTABLE) //if we are allowed to choose. see setup.dm for details
					var/atom/movable/M = input("Choose something to eat.", "Targeting") as null|anything in possible_targets
					if(M)
						targets += M
				else
					targets += pick(possible_targets)
			//Adds a safety check post-input to make sure those targets are actually in range.


	else
		var/list/possible_targets = list()

		for(var/atom/movable/target in view_or_range(range, user, selection_type))
			if(istype(target, /obj/item/weapon/implant))
				var/obj/item/weapon/implant/implant = target
				if(implant.imp_in) //Implanted implant, don't eat that
					continue
			possible_targets += target

		if(spell_flags & SELECTABLE)
			for(var/i = 1; i<=max_targets, i++)
				var/atom/movable/M = input("Choose something to eat.", "Targeting") as null|anything in possible_targets
				if(!M)
					break
				if(M in view_or_range(range, user, selection_type))
					targets += M
					possible_targets -= M
		else
			for(var/i=1,i<=max_targets,i++)
				if(!possible_targets.len)
					break
				if(target_ignore_prev)
					var/target = pick(possible_targets)
					possible_targets -= target
					targets += target
				else
					targets += pick(possible_targets)

	if(!(spell_flags & INCLUDEUSER) && (user in targets))
		targets -= user

	if(compatible_mobs && compatible_mobs.len)
		for(var/mob/living/target in targets) //filters out all the non-compatible mobs
			var/found = 0
			for(var/mob_type in compatible_mobs)
				if(istype(target, mob_type))
					found = 1
			if(!found)
				targets -= target
	for(var/obj/item/I in targets)
		if(!istype(I) || !holder.Adjacent(I))
			targets -= I

	return targets

/spell/targeted/eat/cast(list/targets, mob/user)
	if(!targets || !targets.len)
		return 0
	var/atom/movable/the_item = targets[1]
	if(!the_item || !the_item.Adjacent(user))
		return
	// if(istype(the_item, /obj/item/weapon/organ/head))
	// 	to_chat(user, "<span class='warning'>You try to put the [the_item] in your mouth, but the ears tickle your throat!</span>")
	// 	return 0
	// else if(isbrain(the_item))
	// 	to_chat(user, "<span class='warning'>You try to put [the_item] in your mouth, but the texture makes you gag!</span>")
	// 	return 0
	else if(ishuman(the_item))
		//My gender
		var/m_his = "its"
		if(user.gender == MALE)
			m_his = "his"
		if(user.gender == FEMALE)
			m_his = "her"
		var/mob/living/carbon/human/H = the_item
		var/datum/organ/external/limb = H.get_organ(usr.zone_sel.selecting)
		if(!istype(limb))
			to_chat(user, "<span class='warning'>You can't eat this part of them!</span>")
			return 0
		if(istype(limb, /datum/organ/external/head))
			//Bullshit, but prevents being unable to clone someone.
			to_chat(user, "<span class='warning'>You try to put [the_item]'s [limb.display_name] in your mouth, but \his ears tickle your throat!</span>")
			return 0
		if(istype(limb, /datum/organ/external/chest))
			//Bullshit, but you cannot break it anyways
			to_chat(user, "<span class='warning'>You try to put [the_item]'s [limb.display_name] in your mouth, but it's too big to fit!</span>")
			return 0
		if(istype(limb, /datum/organ/external/groin))
			//Bullshit, but you cannot break it anyways
			to_chat(user, "<span class='warning'>You try to put [the_item]'s [limb.display_name] in your mouth, but it feels far too inappropriate!</span>")
			return 0
		user.visible_message("<span class='danger'>[user] begins stuffing [the_item]'s [limb.display_name] into [m_his] gaping maw!</span>")
		if(!do_mob(user, the_item,EAT_MOB_DELAY))
			to_chat(user, "<span class='warning'>You were interrupted before you could eat [the_item]'s [limb.display_name]!</span>")
		else
			user.visible_message("<span class='danger'>[user] eats [the_item]'s [limb.display_name].</span>", \
			"<span class='danger'>You eat [the_item]'s [limb.display_name].</span>")
			playsound(get_turf(user), 'sound/items/eatfood.ogg', 50, 0)
			message_admins("[user] ate [the_item]'s [limb]: (<A href='?_src_=holder;jumpto=\ref[user]'><b>Jump to</b></A>)")
			log_game("[user] ate \the [the_item]'s [limb] at [user.x], [user.y], [user.z]")
			limb.droplimb("override" = 1, "spawn_limb" = 0)
			doHeal(user)
	else
		user.visible_message("<span class='warning'>[usr] eats \the [the_item].")
		playsound(get_turf(user), 'sound/items/eatfood.ogg', 50, 0)
		message_admins("[user] ate \the [the_item]: (<A href='?_src_=holder;jumpto=\ref[user]'><b>Jump to</b></A>)")
		log_game("[user] ate \the [the_item] at [user.x], [user.y], [user.z]")
		qdel(the_item)
		doHeal(usr)
	return

////////////////////////////////////////////////////////////////////////

//WAS: /datum/bioEffect/jumpy
/datum/dna/gene/basic/grant_spell/jumpy
	name = "Jumpy"
	desc = "Allows the subject to leap great distances.</span>"
	//cooldown = 30
	activation_messages = list("Your leg muscles feel taut and strong.")
	deactivation_messages = list("Your leg muscles shrink back to normal.")

	drug_activation_messages=list()
	drug_deactivation_messages=list()

	spelltype =/spell/targeted/leap

	New()
		..()
		block = JUMPBLOCK

/spell/targeted/leap
	name = "Jump"
	desc = "Leap great distances!"
	panel = "Mutant Powers"
	range = -1

	charge_type = Sp_RECHARGE
	charge_max = 60

	spell_flags = INCLUDEUSER
	invocation_type = SpI_NONE

	duration = 10 //used for jump distance here

	cast_sound = 'sound/weapons/thudswoosh.ogg'

	hud_state = "gen_leap"
	override_base = "genetic"

/spell/targeted/leap/cast(list/targets, mob/user)
	for(var/mob/living/target in targets)
		if (istype(target.loc,/mob/) || target.lying || target.stunned || target.locked_to)
			to_chat(target, "<span class='warning'>You can't jump right now!</span>")
			continue

		var/failed_leap = 0
		if (istype(target.loc,/turf/))

			if(target.restrained())//Why being pulled while cuffed prevents you from moving
				for(var/mob/M in range(target, 1))
					if(M.pulling == target)
						if(!M.restrained() && !usr.isUnconscious() && M.canmove && usr.Adjacent(M))
							failed_leap = 1
						else
							M.stop_pulling()

			if(target.pinned.len)
				failed_leap = 1

			target.visible_message("<span class='warning'><b>[target.name]</b> takes a huge leap!</span>")
			playsound(target.loc, 'sound/weapons/thudswoosh.ogg', 50, 1)
			if(failed_leap)
				target.Weaken(5)
				target.Stun(5)
				target.visible_message("<span class='warning'> \the [usr] attempts to leap away but is slammed back down to the ground!</span>",
									"<span class='warning'>You attempt to leap away but are suddenly slammed back down to the ground!</span>",
									"<span class='notice'>You hear the flexing of powerful muscles and suddenly a crash as a body hits the floor.</span>")
				continue

			var/prevLayer = target.layer
			target.layer = 9

			for(var/i=0, i<duration, i++)
				step(target, target.dir)
				if(i < 5) target.pixel_y += 8
				else target.pixel_y -= 8
				sleep(1)
			target.pixel_y = 0

			if (M_FAT in target.mutations && prob(66))
				target.visible_message("<span class='warning'><b>[target.name]</b> crashes due to their heavy weight!</span>")
				//playsound(usr.loc, 'zhit.wav', 50, 1)
				target.weakened += 10
				target.stunned += 5

			target.layer = prevLayer

		if (istype(target.loc,/obj/))
			var/obj/container = target.loc
			to_chat(target, "<span class='warning'>You leap and slam your head against the inside of [container]! Ouch!</span>")
			target.paralysis += 3
			target.weakened += 5
			container.visible_message("<span class='warning'><b>[container]</b> emits a loud thump and rattles a bit.</span>")
			playsound(target.loc, 'sound/effects/bang.ogg', 50, 1)
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

	spelltype = /spell/targeted/polymorph
	//cooldown = 1800
	activation_messages = list("You don't feel entirely like yourself somehow.")
	deactivation_messages = list("You feel secure in your identity.")

	drug_activation_messages=list()
	drug_deactivation_messages=list()

	New()
		..()
		block = POLYMORPHBLOCK

/spell/targeted/polymorph
	name = "Polymorph"
	desc = "Mimic the appearance of others!"
	panel = "Mutant Powers"
	charge_max = 1800

	spell_flags = 0
	invocation_type = SpI_NONE
	range = 1
	max_targets = 1
	selection_type = "range"
	compatible_mobs = list(/mob/living/carbon/human)

	hud_state = "wiz_hulk"
	override_base = "genetic"

/spell/targeted/polymorph/cast(list/targets, mob/living/carbon/human/user)
	..()
	if(!istype(user))
		return

	for(var/mob/living/carbon/human/target in targets)
		user.visible_message("<span class='sinister'>[user.name]'s body shifts and contorts.</span>")

		spawn(10)
			if(target && user)
				//playsound(usr.loc, 'gib.ogg', 50, 1)
				user.UpdateAppearance(target.dna.UI)
				user.real_name = target.real_name
				user.name = target.name
////////////////////////////////////////////////////////////////////////

// WAS: /datum/bioEffect/empath
/datum/dna/gene/basic/grant_spell/empath
	name = "Empathic Thought"
	desc = "The subject becomes able to read the minds of others for certain information."

	spelltype = /spell/targeted/empath
	activation_messages = list("You suddenly notice more about others than you did before.")
	deactivation_messages = list("You no longer feel able to sense intentions.")

	drug_activation_messages=list("You feel more social!")
	drug_deactivation_messages=list("You feel less social.")

	New()
		..()
		block = EMPATHBLOCK

/spell/targeted/empath
	name = "Read Mind"
	desc = "Read the minds of others for information."
	panel = "Mutant Powers"

	range = 7
	max_targets = 1
	spell_flags = SELECTABLE
	invocation_type = SpI_NONE

	charge_type = Sp_RECHARGE
	charge_max = 100

	compatible_mobs = list(/mob/living/carbon)

	hud_state = "gen_rmind"
	override_base = "genetic"
	mind_affecting = 1

/spell/targeted/empath/cast(var/list/targets, mob/user)
	if(!targets || !targets.len)
		return

	var/mob/living/carbon/M = targets[1] //only one mob in the list, so we want that one

	if(!M || !M.loc) //Either chose to not read a mind or the mob was caught by qdel
		return

	if(!istype(M))
		to_chat(user, "<span class='warning'>This can only be used on carbon beings.</span>")
		return

	if (M_PSY_RESIST in M.mutations)
		to_chat(user, "<span class='warning'>You can't see into [M.name]'s mind at all!</span>")
		return

	if (M.stat == 2)
		to_chat(user, "<span class='warning'>[M.name] is dead and cannot have their mind read.</span>")
		return
	if (M.health < 0)
		to_chat(user, "<span class='warning'>[M.name] is dying, and their thoughts are too scrambled to read.</span>")
		return

	to_chat(user, "<span class='notice'><b>Mind Reading of [M.name]:</b></span>")
	var/pain_condition = M.health
	// lower health means more pain
	var/list/randomthoughts = list("what to have for lunch","the future","the past","money",
	"their hair","what to do next","their job","space","amusing things","sad things",
	"annoying things","happy things","something incoherent","something they did wrong",
	"getting those valids","burning catpeople","something spooky","somethng lewd","odd things",
	"dumb things","lighting things on fire","lighting themselves on fire","blowing things up",
	"blowing themeselves up","shooting everyone","shooting themselves")
	var/thoughts = "thinking about [pick(randomthoughts)]"
	if (M.fire_stacks)
		pain_condition -= 50
		thoughts = "preoccupied with the fire"
	if (M.radiation)
		pain_condition -= 25

	switch(pain_condition)
		if (81 to INFINITY)
			to_chat(user, "<span class='notice'> <b>Condition</b>: [M.name] feels good.</span>")
		if (61 to 80)
			to_chat(user, "<span class='notice'> <b>Condition</b>: [M.name] is suffering mild pain.</span>")
		if (41 to 60)
			to_chat(user, "<span class='notice'> <b>Condition</b>: [M.name] is suffering significant pain.</span>")
		if (21 to 40)
			to_chat(user, "<span class='notice'> <b>Condition</b>: [M.name] is suffering severe pain.</span>")
		else
			to_chat(user, "<span class='notice'> <b>Condition</b>: [M.name] is suffering excruciating pain.</span>")
			thoughts = "haunted by their own mortality"

	switch(M.a_intent)
		if (I_HELP)
			to_chat(user, "<span class='notice'> <b>Mood</b>: You sense benevolent thoughts from [M.name].</span>")
		if (I_DISARM)
			to_chat(user, "<span class='notice'> <b>Mood</b>: You sense cautious thoughts from [M.name].</span>")
		if (I_GRAB)
			to_chat(user, "<span class='notice'> <b>Mood</b>: You sense hostile thoughts from [M.name].</span>")
		if (I_HURT)
			to_chat(user, "<span class='notice'> <b>Mood</b>: You sense cruel thoughts from [M.name].</span>")
			for(var/mob/living/L in view(7,M))
				if (L == M)
					continue
				thoughts = "thinking about punching [L.name]"
				break
		else
			to_chat(user, "<span class='notice'> <b>Mood</b>: You sense strange thoughts from [M.name].</span>")

	if (istype(M,/mob/living/carbon/human))
		var/numbers[0]
		var/mob/living/carbon/human/H = M
		if(H.mind && H.mind.initial_account)
			numbers += H.mind.initial_account.account_number
			numbers += H.mind.initial_account.remote_access_pin
		if(numbers.len>0)
			to_chat(user, "<span class='notice'> <b>Numbers</b>: You sense the number[numbers.len>1?"s":""] [english_list(numbers)] [numbers.len>1?"are":"is"] important to [M.name].</span>")
	to_chat(user, "<span class='notice'> <b>Thoughts</b>: [M.name] is currently [thoughts].</span>")

	if (/spell/targeted/empath in M.spell_list)
		to_chat(M, "<span class='warning'>You sense [usr.name] reading your mind.</span>")
	else if (prob(5) || (M.mind && M.mind.assigned_role=="Chaplain"))
		to_chat(M, "<span class='warning'>You sense someone intruding upon your thoughts...</span>")

////////////////////////////////////////////////////////////////////////

// WAS: /datum/bioEffect/superfart
/datum/dna/gene/basic/superfart
	name = "High-Pressure Intestines"
	desc = "Vastly increases the gas capacity of the subject's digestive tract."
	activation_messages = list("You feel bloated and gassy.")
	deactivation_messages = list("You no longer feel gassy. What a relief!")

	drug_activation_messages = list()
	drug_deactivation_messages = list()

	mutation = M_SUPER_FART

	New()
		..()
		block = SUPERFARTBLOCK

// WAS: /datum/bioEffect/strong
/datum/dna/gene/basic/strong
	// pretty sure this doesn't do jack shit, putting it here until it does
	name = "Strong"
	desc = "Enhances the subject's ability to build and retain heavy muscles."
	activation_messages = list("You feel buff!")
	deactivation_messages = list("You feel wimpy and weak.")

	mutation = M_STRONG

	New()
		..()
		block=STRONGBLOCK
