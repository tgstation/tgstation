
//Academy Areas

/area/awaymission/academy
	name = "Academy Asteroids"
	icon_state = "away"

/area/awaymission/academy/headmaster
	name = "Academy Fore Block"
	icon_state = "away1"

/area/awaymission/academy/classrooms
	name = "Academy Classroom Block"
	icon_state = "away2"

/area/awaymission/academy/academyaft
	name = "Academy Ship Aft Block"
	icon_state = "away3"

/area/awaymission/academy/academygate
	name = "Academy Gateway"
	icon_state = "away4"

/area/awaymission/academy/academycellar
	name = "Academy Cellar"
	icon_state = "away4"

/area/awaymission/academy/academyengine
	name = "Academy Engine"
	icon_state = "away4"

//Academy Items

/obj/item/paper/fluff/awaymissions/academy/console_maint
	name = "Console Maintenance"
	info = "We're upgrading to the latest mainframes for our consoles, the shipment should be in before spring break is over!"

/obj/item/paper/fluff/awaymissions/academy/class/automotive
	name = "Automotive Repair 101"

/obj/item/paper/fluff/awaymissions/academy/class/pyromancy
	name = "Pyromancy 250"

/obj/item/paper/fluff/awaymissions/academy/class/biology
	name = "Biology Lab"

/obj/item/paper/fluff/awaymissions/academy/grade/aplus
	name = "Summoning Midterm Exam"
	info = "Grade: A+ Educator's Notes: Excellent form."

/obj/item/paper/fluff/awaymissions/academy/grade/bminus
	name = "Summoning Midterm Exam"
	info = "Grade: B- Educator's Notes: Keep applying yourself, you're showing improvement."

/obj/item/paper/fluff/awaymissions/academy/grade/dminus
	name = "Summoning Midterm Exam"
	info = "Grade: D- Educator's Notes: SEE ME AFTER CLASS."

/obj/item/paper/fluff/awaymissions/academy/grade/failure
	name = "Pyromancy Evaluation"
	info = "Current Grade: F. Educator's Notes: No improvement shown despite multiple private lessons.  Suggest additional tutelage."


/obj/singularity/academy
	dissipate = 0
	move_self = 0
	grav_pull = 1

/obj/singularity/academy/admin_investigate_setup()
	return

/obj/singularity/academy/process()
	eat()
	if(prob(1))
		mezzer()


/obj/item/clothing/glasses/meson/truesight
	name = "The Lens of Truesight"
	desc = "I can see forever!"
	icon_state = "monocle"
	item_state = "headset"


/obj/structure/academy_wizard_spawner
	name = "Academy Defensive System"
	desc = "Made by Abjuration, Inc."
	icon = 'icons/obj/cult.dmi'
	icon_state = "forge"
	anchored = TRUE
	max_integrity = 200
	var/mob/living/current_wizard = null
	var/next_check = 0
	var/cooldown = 600
	var/faction = ROLE_WIZARD
	var/braindead_check = 0

/obj/structure/academy_wizard_spawner/New()
	START_PROCESSING(SSobj, src)

/obj/structure/academy_wizard_spawner/Destroy()
	if(!broken)
		STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/academy_wizard_spawner/process()
	if(next_check < world.time)
		if(!current_wizard)
			for(var/mob/living/L in GLOB.player_list)
				if(L.z == src.z && L.stat != DEAD && !(faction in L.faction))
					summon_wizard()
					break
		else
			if(current_wizard.stat == DEAD)
				current_wizard = null
				summon_wizard()
			if(!current_wizard.client)
				if(!braindead_check)
					braindead_check = 1
				else
					braindead_check = 0
					give_control()
		next_check = world.time + cooldown

/obj/structure/academy_wizard_spawner/proc/give_control()
	set waitfor = FALSE

	if(!current_wizard)
		return
	var/list/mob/dead/observer/candidates = pollCandidatesForMob("Do you want to play as Wizard Academy Defender?", ROLE_WIZARD, null, ROLE_WIZARD, 50, current_wizard)

	if(LAZYLEN(candidates))
		var/mob/dead/observer/C = pick(candidates)
		message_admins("[ADMIN_LOOKUPFLW(C)] was spawned as Wizard Academy Defender")
		current_wizard.ghostize() // on the off chance braindead defender gets back in
		current_wizard.key = C.key

/obj/structure/academy_wizard_spawner/proc/summon_wizard()
	var/turf/T = src.loc
	var/mob/living/carbon/human/wizbody = new(T)
	wizbody.fully_replace_character_name(wizbody.real_name, "Academy Teacher")
	wizbody.mind_initialize()
	var/datum/mind/wizmind = wizbody.mind
	wizmind.special_role = "Academy Defender"
	wizmind.add_antag_datum(/datum/antagonist/wizard/academy)
	current_wizard = wizbody

	give_control()

/obj/structure/academy_wizard_spawner/deconstruct(disassembled = TRUE)
	if(!broken)
		broken = 1
		visible_message("<span class='warning'>[src] breaks down!</span>")
		icon_state = "forge_off"
		STOP_PROCESSING(SSobj, src)

/datum/outfit/wizard/academy
	name = "Academy Wizard"
	r_pocket = null
	r_hand = null
	suit = /obj/item/clothing/suit/wizrobe/red
	head = /obj/item/clothing/head/wizard/red
	backpack_contents = list(/obj/item/storage/box/survival = 1)

/obj/item/dice/d20/fate
	name = "Die of Fate"
	desc = "A die with twenty sides. You can feel unearthly energies radiating from it. Using this might be VERY risky."
	icon_state = "d20"
	sides = 20
	can_be_rigged = FALSE
	var/reusable = 1
	var/used = 0

/obj/item/dice/d20/fate/one_use
	reusable = 0

/obj/item/dice/d20/fate/diceroll(mob/user)
	..()
	if(!used)
		if(!ishuman(user) || !user.mind || (user.mind in SSticker.mode.wizards))
			to_chat(user, "<span class='warning'>You feel the magic of the dice is restricted to ordinary humans!</span>")
			return
		if(rigged)
			effect(user,rigged)
		else
			effect(user,result)

/obj/item/dice/d20/fate/equipped(mob/user, slot)
	if(!ishuman(user) || !user.mind || (user.mind in SSticker.mode.wizards))
		to_chat(user, "<span class='warning'>You feel the magic of the dice is restricted to ordinary humans! You should leave it alone.</span>")
		user.dropItemToGround(src)


/obj/item/dice/d20/fate/proc/effect(var/mob/living/carbon/human/user,roll)
	if(!reusable)
		used = 1
	visible_message("<span class='userdanger'>The die flare briefly.</span>")
	switch(roll)
		if(1)
			//Dust
			user.dust()
		if(2)
			//Death
			user.death()
		if(3)
			//Swarm of creatures
			for(var/direction in GLOB.alldirs)
				var/turf/T = get_turf(src)
				new /mob/living/simple_animal/hostile/netherworld(get_step(T,direction))
		if(4)
			//Destroy Equipment
			for (var/obj/item/I in user)
				if (istype(I, /obj/item/implant))
					continue
				qdel(I)
		if(5)
			//Monkeying
			user.monkeyize()
		if(6)
			//Cut speed
			var/datum/species/S = user.dna.species
			S.speedmod += 1
		if(7)
			//Throw
			user.Stun(60)
			user.adjustBruteLoss(50)
			var/throw_dir = pick(GLOB.cardinals)
			var/atom/throw_target = get_edge_target_turf(user, throw_dir)
			user.throw_at(throw_target, 200, 4)
		if(8)
			//Fueltank Explosion
			explosion(loc,-1,0,2, flame_range = 2)
		if(9)
			//Cold
			var/datum/disease/D = new /datum/disease/cold()
			user.ForceContractDisease(D, FALSE, TRUE)
		if(10)
			//Nothing
			visible_message("<span class='notice'>[src] roll perfectly.</span>")
		if(11)
			//Cookie
			var/obj/item/reagent_containers/food/snacks/cookie/C = new(drop_location())
			C.name = "Cookie of Fate"
		if(12)
			//Healing
			user.revive(full_heal = 1, admin_revive = 1)
		if(13)
			//Mad Dosh
			var/turf/Start = get_turf(src)
			for(var/direction in GLOB.alldirs)
				var/turf/T = get_step(Start,direction)
				if(rand(0,1))
					new /obj/item/stack/spacecash/c1000(T)
				else
					var/obj/item/storage/bag/money/M = new(T)
					for(var/i in 1 to rand(5,50))
						new /obj/item/coin/gold(M)
		if(14)
			//Free Gun
			new /obj/item/gun/ballistic/revolver/mateba(drop_location())
		if(15)
			//Random One-use spellbook
			new /obj/item/book/granter/spell/random(drop_location())
		if(16)
			//Servant & Servant Summon
			var/mob/living/carbon/human/H = new(drop_location())
			H.equipOutfit(/datum/outfit/butler)
			var/datum/mind/servant_mind = new /datum/mind()
			var/datum/antagonist/magic_servant/A = new
			servant_mind.add_antag_datum(A)
			A.setup_master(user)
			servant_mind.transfer_to(H)

			var/list/mob/dead/observer/candidates = pollCandidatesForMob("Do you want to play as [user.real_name] Servant?", ROLE_WIZARD, null, ROLE_WIZARD, 50, H)
			if(LAZYLEN(candidates))
				var/mob/dead/observer/C = pick(candidates)
				message_admins("[ADMIN_LOOKUPFLW(C)] was spawned as Dice Servant")
				H.key = C.key

			var/obj/effect/proc_holder/spell/targeted/summonmob/S = new
			S.target_mob = H
			user.mind.AddSpell(S)

		if(17)
			//Tator Kit
			new /obj/item/storage/box/syndicate(drop_location())
		if(18)
			//Captain ID
			new /obj/item/card/id/captains_spare(drop_location())
		if(19)
			//Instrinct Resistance
			to_chat(user, "<span class='notice'>You feel robust.</span>")
			var/datum/species/S = user.dna.species
			S.brutemod *= 0.5
			S.burnmod *= 0.5
			S.coldmod *= 0.5
		if(20)
			//Free wizard!
			user.mind.make_Wizard()

/datum/outfit/butler
	name = "Butler"
	uniform = /obj/item/clothing/under/suit_jacket/really_black
	shoes = /obj/item/clothing/shoes/laceup
	head = /obj/item/clothing/head/bowler
	glasses = /obj/item/clothing/glasses/monocle
	gloves = /obj/item/clothing/gloves/color/white

/obj/effect/proc_holder/spell/targeted/summonmob
	name = "Summon Servant"
	desc = "This spell can be used to call your servant, whenever you need it."
	charge_max = 100
	clothes_req = 0
	invocation = "JE VES"
	invocation_type = "whisper"
	range = -1
	level_max = 0 //cannot be improved
	cooldown_min = 100
	include_user = 1

	var/mob/living/target_mob

	action_icon_state = "summons"

/obj/effect/proc_holder/spell/targeted/summonmob/cast(list/targets,mob/user = usr)
	if(!target_mob)
		return
	var/turf/Start = get_turf(user)
	for(var/direction in GLOB.alldirs)
		var/turf/T = get_step(Start,direction)
		if(!T.density)
			target_mob.Move(T)

/obj/structure/ladder/unbreakable/rune
	name = "\improper Teleportation Rune"
	desc = "Could lead anywhere."
	icon = 'icons/obj/rune.dmi'
	icon_state = "1"
	color = rgb(0,0,255)

/obj/structure/ladder/unbreakable/rune/update_icon()
	return

/obj/structure/ladder/unbreakable/rune/show_fluff_message(up,mob/user)
	user.visible_message("[user] activates \the [src].","<span class='notice'>You activate \the [src].</span>")

/obj/structure/ladder/unbreakable/rune/use(mob/user, is_ghost=FALSE)
	if(is_ghost || !(user.mind in SSticker.mode.wizards))
		..()
