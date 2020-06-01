/obj/item/storage/box/syndicate/bundle_sith/PopulateContents()
	new /obj/item/book/granter/spell/force_lightning(src)
	new /obj/item/book/granter/martial/starter_sith(src)
	new /obj/item/clothing/suit/armor/riot/chaplain/sith(src)
	new /obj/item/clothing/head/helmet/chaplain/sith(src)
	new /obj/item/melee/transforming/energy/sword/saber/sith(src)


/obj/item/book/granter/spell/force_lightning
	spell = /obj/effect/proc_holder/spell/targeted/force_lightning
	name = "Sith Sacred Texts (Vol. 1)"
	desc = "This book seems to crackle with electric malevolence. It depicts lightning coursing from arched finger tips."
	spellname = "Force Lightning"
	icon_state ="bookcharge"
	oneuse = TRUE
	remarks = list("Oh, I'm afraid the force lightning will be quite operational when security arrives...","UNNNNNNNLIMITED POWAH!!!", "Let the hate flow through me...", "GooOood... GOOooOod...", "All is proceeding exactly as I have foreseen.", "The Dark Side is a pathway to many abilities some consider to be... unnatural...", "They will pay the price for their lack of vision...", "Execute Order 66...", "It seems it is me who is mistaken about a great. Many. Things.", "This space station is nothing compared to the power of the Dark Side...", "The tragedy of Darth Plaguis the Wise is not a tale the Jedi would tell me...", "Only now, at the end, do I understand.")

/obj/item/book/granter/spell/force_lightning/onlearned(mob/user)
	..()
	sith_one_use(user)

/obj/item/book/granter/martial/starter_sith
	martial = /datum/martial_art/starter_sith
	name = "Sith Sacred Texts (Vol. 2)"
	martialname = "Sith Starter Secrets"
	desc = "This book seems to crackle with electric malevolence. It depicts an old robed weirdo flinging pods at a peculiar green midget and fighting with an energy sword."
	greet = "<span class='sciradio'>You have learned some of the ancient mysteries of the Sith! You can now move objects with the power of the Dark Side and deflect projectiles with energy swords.</span>"
	icon_state ="bookcharge"
	remarks = list("Oh, I'm afraid the force lightning will be quite operational when security arrives...","UNNNNNNNLIMITED POWAH!!!", "Let the hate flow through me...", "GooOood... GOOooOod...", "All is proceeding exactly as I have foreseen.", "The Dark Side is a pathway to many abilities some consider to be... unnatural...", "They will pay the price for their lack of vision...", "Execute Order 66...", "It seems it is me who is mistaken about a great. Many. Things.", "This space station is nothing compared to the power of the Dark Side...", "The tragedy of Darth Plaguis the Wise is not a tale the Jedi would tell me...", "Only now, at the end, do I understand.")

/obj/item/book/granter/martial/starter_sith/onlearned(mob/living/carbon/user)
	..()
	sith_one_use(user)


/datum/martial_art/starter_sith
	name = "Sith Starter Secrets"
	id = MARTIALART_STARTERSITH
	allow_temp_override = FALSE
	help_verb = /mob/living/carbon/human/proc/starter_sith_help
	var/mob/living/carbon/human/owner


/mob/living/carbon/human/proc/starter_sith_help()
	set name = "Recall Sith Teachings"
	set desc = "Remember the ancient secrets of the Sith."
	set category = "Sith Starter Kit"

	to_chat(usr, "<b><i>You retreat inward and recall the teachings of the Sith...</i></b>")

	to_chat(usr, "<span class='notice'>Force Lightning</span>: Fires a bolt of force lightning at a random target within 4 tiles (sacred text sold separately!).")
	to_chat(usr, "<span class='notice'>Force Push</span>: Move things around with the power of the Force.")
	to_chat(usr, "<span class='notice'>Light Saber Training</span>: You can deflect most projectiles and melee attacks while holding an activated energy sword.")


///Triggers on COMSIG_MOB_ATTACK_RANGED. Usually handles stuff like picking up items at range.
/datum/martial_art/starter_sith/proc/on_ranged_attack(datum/source, atom/target)
	if(owner.dna.check_mutation(TK)) //FULPSTATION Chaplain Starter Sith PR by Surrealistik Jan 2020; no stacking with Telekinesis
		return
	target.attack_tk(owner)

/datum/martial_art/starter_sith/teach(mob/living/carbon/human/H, make_temporary = FALSE)
	. = ..()
	if(!.)
		return
	owner = H
	RegisterSignal(H, COMSIG_MOB_ATTACK_RANGED, .proc/on_ranged_attack)


/datum/martial_art/starter_sith/on_remove(mob/living/carbon/human/H)
	. = ..()
	UnregisterSignal(H, COMSIG_MOB_ATTACK_RANGED)

/obj/item/melee/transforming/energy/sword/saber/sith
	name = "Sith Lightsaber"
	possible_colors = list("red" = LIGHT_COLOR_RED)
	desc = "A deadly and ancient energy sword hailing from an equally deadly and ancient religion."
	armour_penetration = 100 //Cuts through anything.
	force_on = 35 //Slightly better than standard.
	throwforce_on = 30 //Better than standard.

/obj/item/melee/transforming/energy/sword/saber/sith/IsReflect(mob/living/user)
	if(!user.mind.has_martialart(MARTIALART_STARTERSITH))
		return FALSE

	if (!user.incapacitated() && prob(FORCETRAINING_BLOCKCHANCE)) //30% chance to reflect if we have sith training
		spark_system.start()
		playsound(src, pick('sound/weapons/blade1.ogg'), 75, TRUE)
		return TRUE

/obj/item/melee/transforming/energy/sword/proc/deflect_check(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(owner.mind.has_martialart(MARTIALART_STARTERSITH))
		final_block_chance += FORCETRAINING_BLOCKCHANCE //+30% for having Sith training
	SEND_SIGNAL(src, COMSIG_ITEM_HIT_REACT, args)
	if(prob(final_block_chance))
		spark_system.start()
		playsound(src, pick('sound/weapons/blade1.ogg'), 75, TRUE)
		owner.visible_message("<span class='danger'>[owner] deflects [attack_text] with [src]!</span>")
		return TRUE
	return FALSE


/obj/item/melee/transforming/energy/sword/proc/spark_setup()
	spark_system = new /datum/effect_system/spark_spread()
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)



/obj/item/book/granter/proc/sith_one_use(mob/user)
	if(!oneuse)
		return FALSE
	var/datum/effect_system/spark_spread/spark_system = new /datum/effect_system/spark_spread()
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)
	spark_system.start()
	if(isliving(user))
		var/mob/living/L = user
		L.electrocute_act(5,"Force Lightning",1,SHOCK_NOSTUN) //Snappy zappy.
	to_chat(user,"<span class='warning'>In a flash of lightning, [src] suddenly crumbles to dust! No! The sacred texts!</span>")
	playsound(src,'sound/magic/lightningbolt.ogg', 30, TRUE)
	new /obj/effect/decal/cleanable/ash(get_turf(src))
	qdel(src)

#define FORCELIGHTNING_REFLECT_MULTIPLIER	0.25

/obj/effect/proc_holder/spell/targeted/force_lightning
	name = "Force Lightning"
	desc = "Release a blast of force lightning at a random target within 4 tiles. Arcs between targets, and decays in power with each arc."
	charge_type = "recharge"
	charge_max	= 10
	clothes_req = FALSE
	range = 4
	cooldown_min = 10
	selection_type = "view"
	random_target = TRUE
	invocation = null
	invocation_type = null
	var/static/mutable_appearance/halo
	var/sound/Snd // so far only way i can think of to stop a sound, thank MSO for the idea.
	var/bolt_flags = SHOCK_NOGLOVES | SHOCK_NOSTUN
	var/max_bounces = 10
	var/bolt_decay_per_bounce = 4 //How much damage does the bolt lose when it bounces.
	var/min_damage = 5
	var/max_damage = 20
	var/stamina_damage_multiplier = 0.5
	var/datum/effect_system/spark_spread/spark_system
	var/list/existing_targets = list()

	action_icon_state = "lightning"

/obj/item/clothing/head/helmet/chaplain/sith
	name = "sith hood"
	desc = "It stinks of old man, ozone and the Dark Side."
	icon_state = "crusader"
	inhand_icon_state = "crusader"
	flags_cover = HEADCOVERSEYES
	flags_inv = HIDEHAIR|HIDEFACE|HIDEEARS

/obj/item/clothing/suit/armor/riot/chaplain/sith
	name = "sith robes"
	desc = "They stink of old man, ozone and the Dark Side."
	icon_state = "crusader"
	inhand_icon_state = "crusader"


/obj/effect/proc_holder/spell/targeted/force_lightning/proc/spark_setup()
	spark_system = new /datum/effect_system/spark_spread()
	spark_system.set_up(5, 0, src)


/obj/effect/proc_holder/spell/targeted/force_lightning/cast(list/targets, mob/user = usr)
	if(user.incapacitated())
		to_chat(user, "<span class='warning'>You're in no condition to use [src]!</span>")
		return

	var/mob/living/L
	if(isliving(user))
		L = user
		if(!L.get_bodypart(BODY_ZONE_R_ARM) && !L.get_bodypart(BODY_ZONE_R_ARM))
			to_chat(user, "<span class='warning'>You need at least one hand to use [src]!</span>")
			return

		if(iscarbon(user))
			var/mob/living/carbon/C = user
			if(C.handcuffed)
				to_chat(user, "<span class='warning'>You can't use [src] while handcuffed!</span>")
				return

	existing_targets = list()
	existing_targets += user

	if(!targets.len)
		to_chat(user, "<span class='warning'>No target found in range!</span>")
		return
	spark_setup()
	user.say(pick("It's treason then!", "So be it... Jedi.", "NO. NO. NO... <i>YOU</i> WILL DIE!!", "You underestimate the power of the Dark Side!", "My hate has made me powerful...","I AM THE SENATE!!", "If you will not be turned... you will be destroyed!!", "You will pay the price for your lack of vision!!", "Young fool, only now, at the end, do you understand.", "Your feeble skills are no match for the power of the Dark Side!", "POWAAHHH!!", "UNNNNLIMITEDDDD POWAHHHH!!", "And now, young Skywalker, you will die."))
	var/mob/living/target = targets[1]
	if(get_dist(user,target)>range)
		to_chat(user, "<span class='warning'>[target.p_theyre(TRUE)] too far away!</span>")
		return

	playsound(get_turf(user), 'sound/magic/lightningbolt.ogg', 50, TRUE)
	user.Beam(target,icon_state="lightning[rand(1,12)]",time=5)

	var/damage = rand(min_damage,max_damage)

	if(L)
		L.adjustStaminaLoss(damage * stamina_damage_multiplier) //Take stamina damage equal to half the amount of electrical damage.
		if(L.getStaminaLoss() >= 100)
			user.say(pick("I'm weak... too weak...", "Nooo... please...", "Don't let him kill me...", "Please! Don't!", "I can't hold on any longer...", "Help me! HELP ME!", "I was right, the Jedi are taking over!"))

	Bolt(user, target,damage,max_bounces,range, user)

/obj/effect/proc_holder/spell/targeted/force_lightning/proc/Bolt(mob/origin, mob/target, bolt_energy, bounces, bolt_range, mob/user = usr)

	if(bolt_energy < 1) //Stop if we would do no damage.
		return

	origin.Beam(target,icon_state="lightning[rand(1,12)]",time=5)
	var/mob/living/current = target

	playsound(get_turf(current), 'sound/magic/lightningshock.ogg', 50, TRUE, -1)

	var/obj/item/melee/transforming/energy/sword/S = current.get_active_held_item() //Check if we have an esword
	if(!current.incapacitated() && istype(S, /obj/item/melee/transforming/energy/sword)) //Can block force lightning with light sabers
		var/final_block_chance = S.block_chance
		if(current.mind.has_martialart(MARTIALART_STARTERSITH)) //We get bonuses from force training if we have it.
			final_block_chance += FORCETRAINING_BLOCKCHANCE
		if(prob(final_block_chance)) //Final chance of deflecting or reflecting.
			S.spark_system.start()
			playsound(S, pick('sound/weapons/blade1.ogg'), 75, TRUE)
			if(prob(final_block_chance * FORCELIGHTNING_REFLECT_MULTIPLIER)) //This is a % of your final block chance; on a success we reflect instead of just deflect.
				current.visible_message("<span class='warning'>[current] reflects the [src] with [S] back at [origin]!</span>", "<span class='userdanger'>You reflect the [src] with [S] back at [origin]!</span>")
				existing_targets -= origin //So we can always reflect back at the source.
				Bolt(current,origin,bolt_energy,bounces,bolt_range, user)
				return
			else
				current.visible_message("<span class='warning'>[current] deflects the [src] with [S], remaining unharmed!</span>", "<span class='userdanger'>You deflect the [src] with [S], remaining unharmed!</span>")
				return

	if(current.anti_magic_check())
		current.visible_message("<span class='warning'>[current] absorbs the [src], remaining unharmed!</span>", "<span class='userdanger'>You absorb the [src], remaining unharmed!</span>")
	else
		current.electrocute_act(bolt_energy,"Force Lightning",1,bolt_flags)
		if(!iscarbon(current)) //So we affect borgs and simple mobs properly.
			current.adjustFireLoss(bolt_energy)
		spark_system.attach(target)
		spark_system.start()

	if(bounces < 1)
		return

	existing_targets += current

	//if(current in existing_targets) //DEBUG
	//	to_chat(world, "[current] in existing targets.") //DEBUG

	var/list/possible_targets = list()
	for(var/mob/living/M in view(bolt_range,current))
		/*
		if(user == M) //Don't ask me why I have to arrange the conditional gates in this way; it just does not work if it they're all in the same row with || separators.
			//to_chat(world, "Target [M] skipped. [M] is caster: [user]") //DEBUG
			continue*/
		if (!los_check(current,M) )
			//to_chat(world, "Target [M] skipped; LoS check to [current] failed.") //DEBUG
			continue
		else if (origin == M)
			//to_chat(world, "Target [M] skipped; [M] is origin: [origin].") //DEBUG
			continue
		else if (M in existing_targets)
			//to_chat(world, "Target [M] skipped; [M] is in existing targets.") //DEBUG
			continue
		else
			possible_targets += M
			//to_chat(world, "Target [M] added.") //DEBUG
	if(!possible_targets.len)
		return
	var/mob/living/next = pick(possible_targets)
	//to_chat(world, "Target [next]. Possible targets: [possible_targets]. Bolt Energy [bolt_energy]. User: [user]") //DEBUG
	var/new_damage = bolt_energy - bolt_decay_per_bounce
	if(next && new_damage >= 1)
		Bolt(current,next,new_damage,bounces - 1,bolt_range - 1, user)

#undef FORCELIGHTNING_REFLECT_MULTIPLIER