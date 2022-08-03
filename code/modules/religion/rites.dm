/datum/religion_rites
	/// name of the religious rite
	var/name = "religious rite"
	/// Description of the religious rite
	var/desc = "immm gonna rooon"
	/// length it takes to complete the ritual
	var/ritual_length = (10 SECONDS) //total length it'll take
	/// list of invocations said (strings) throughout the rite
	var/list/ritual_invocations //strings that are by default said evenly throughout the rite
	/// message when you invoke
	var/invoke_msg
	var/favor_cost = 0
	/// does the altar auto-delete the rite
	var/auto_delete = TRUE

/datum/religion_rites/New()
	. = ..()
	if(!GLOB?.religious_sect)
		return
	LAZYADD(GLOB.religious_sect.active_rites, src)

/datum/religion_rites/Destroy()
	if(!GLOB?.religious_sect)
		return
	LAZYREMOVE(GLOB.religious_sect.active_rites, src)
	return ..()

/datum/religion_rites/proc/can_afford(mob/living/user)
	if(GLOB.religious_sect?.favor < favor_cost)
		to_chat(user, span_warning("This rite requires more favor!"))
		return FALSE
	return TRUE

///Called to perform the invocation of the rite, with args being the performer and the altar where it's being performed. Maybe you want it to check for something else?
/datum/religion_rites/proc/perform_rite(mob/living/user, atom/religious_tool)
	if(!can_afford(user))
		return FALSE
	to_chat(user, span_notice("You begin to perform the rite of [name]..."))
	if(!ritual_invocations)
		if(do_after(user, target = user, delay = ritual_length))
			return TRUE
		return FALSE
	var/first_invoke = TRUE
	for(var/i in ritual_invocations)
		if(first_invoke) //instant invoke
			user.say(i)
			first_invoke = FALSE
			continue
		if(!length(ritual_invocations)) //we divide so we gotta protect
			return FALSE
		if(!do_after(user, target = user, delay = ritual_length/length(ritual_invocations)))
			return FALSE
		user.say(i)
	if(!do_after(user, target = user, delay = ritual_length/length(ritual_invocations))) //because we start at 0 and not the first fraction in invocations, we still have another fraction of ritual_length to complete
		return FALSE
	if(invoke_msg)
		user.say(invoke_msg)
	return TRUE


///Does the thing if the rite was successfully performed. return value denotes that the effect successfully (IE a harm rite does harm)
/datum/religion_rites/proc/invoke_effect(mob/living/user, atom/religious_tool)
	SHOULD_CALL_PARENT(TRUE)
	GLOB.religious_sect.on_riteuse(user,religious_tool)
	return TRUE


/**** Mechanical God ****/

/datum/religion_rites/synthconversion
	name = "Synthetic Conversion"
	desc = "Convert a human-esque individual into a (superior) Android. Buckle a human to convert them, otherwise it will convert you."
	ritual_length = 30 SECONDS
	ritual_invocations = list("By the inner workings of our god ...",
						"... We call upon you, in the face of adversity ...",
						"... to complete us, removing that which is undesirable ...")
	invoke_msg = "... Arise, our champion! Become that which your soul craves, live in the world as your true form!!"
	favor_cost = 1000

/datum/religion_rites/synthconversion/perform_rite(mob/living/user, atom/religious_tool)
	if(!ismovable(religious_tool))
		to_chat(user, span_warning("This rite requires a religious device that individuals can be buckled to."))
		return FALSE
	var/atom/movable/movable_reltool = religious_tool
	if(!movable_reltool)
		return FALSE
	if(LAZYLEN(movable_reltool.buckled_mobs))
		to_chat(user, span_warning("You're going to convert the one buckled on [movable_reltool]."))
	else
		if(!movable_reltool.can_buckle) //yes, if you have somehow managed to have someone buckled to something that now cannot buckle, we will still let you perform the rite!
			to_chat(user, span_warning("This rite requires a religious device that individuals can be buckled to."))
			return FALSE
		if(isandroid(user))
			to_chat(user, span_warning("You've already converted yourself. To convert others, they must be buckled to [movable_reltool]."))
			return FALSE
		to_chat(user, span_warning("You're going to convert yourself with this ritual."))
	return ..()

/datum/religion_rites/synthconversion/invoke_effect(mob/living/user, atom/religious_tool)
	..()
	if(!ismovable(religious_tool))
		CRASH("[name]'s perform_rite had a movable atom that has somehow turned into a non-movable!")
	var/atom/movable/movable_reltool = religious_tool
	var/mob/living/carbon/human/rite_target
	if(!movable_reltool?.buckled_mobs?.len)
		rite_target = user
	else
		for(var/buckled in movable_reltool.buckled_mobs)
			if(ishuman(buckled))
				rite_target = buckled
				break
	if(!rite_target)
		return FALSE
	rite_target.set_species(/datum/species/android)
	rite_target.visible_message(span_notice("[rite_target] has been converted by the rite of [name]!"))
	return TRUE


/datum/religion_rites/machine_blessing
	name = "Receive Blessing"
	desc = "Receive a blessing from the machine god to further your ascension."
	ritual_length = 5 SECONDS
	ritual_invocations =list( "Let your will power our forges.",
							"...Help us in our great conquest!")
	invoke_msg = "The end of flesh is near!"
	favor_cost = 2000

/datum/religion_rites/machine_blessing/invoke_effect(mob/living/user, atom/movable/religious_tool)
	..()
	var/altar_turf = get_turf(religious_tool)
	var/blessing = pick(
					/obj/item/organ/internal/cyberimp/arm/surgery,
					/obj/item/organ/internal/cyberimp/eyes/hud/diagnostic,
					/obj/item/organ/internal/cyberimp/eyes/hud/medical,
					/obj/item/organ/internal/cyberimp/mouth/breathing_tube,
					/obj/item/organ/internal/cyberimp/chest/thrusters,
					/obj/item/organ/internal/eyes/robotic/glow)
	new blessing(altar_turf)
	return TRUE
/**** Pyre God ****/

///apply a bunch of fire immunity effect to clothing
/datum/religion_rites/fireproof/proc/apply_fireproof(obj/item/clothing/fireproofed)
	fireproofed.name = "unmelting [fireproofed.name]"
	fireproofed.max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	fireproofed.heat_protection = chosen_clothing.body_parts_covered
	fireproofed.resistance_flags |= FIRE_PROOF

/datum/religion_rites/fireproof
	name = "Unmelting Protection"
	desc = "Grants fire immunity to any piece of clothing."
	ritual_length = 15 SECONDS
	ritual_invocations = list("And so to support the holder of the Ever-Burning candle...",
	"... allow this unworthy apparel to serve you ...",
	"... make it strong enough to burn a thousand time and more ...")
	invoke_msg = "... Come forth in your new form, and join the unmelting wax of the one true flame!"
	favor_cost = 1000
///the piece of clothing that will be fireproofed, only one per rite
	var/obj/item/clothing/chosen_clothing

/datum/religion_rites/fireproof/perform_rite(mob/living/user, atom/religious_tool)
	for(var/obj/item/clothing/apparel in get_turf(religious_tool))
		if(apparel.max_heat_protection_temperature >= FIRE_IMMUNITY_MAX_TEMP_PROTECT)
			continue //we ignore anything that is already fireproof
		chosen_clothing = apparel //the apparel has been chosen by our lord and savior
		return ..()
	return FALSE

/datum/religion_rites/fireproof/invoke_effect(mob/living/user, atom/religious_tool)
	..()
	if(!QDELETED(chosen_clothing) && get_turf(religious_tool) == chosen_clothing.loc) //check if the same clothing is still there
		if(istype(chosen_clothing,/obj/item/clothing/suit/hooded))
			for(var/obj/item/clothing/head/integrated_helmet in chosen_clothing.contents) //check if the clothing has a hood/helmet integrated and fireproof it if there is one.
				apply_fireproof(integrated_helmet)
		apply_fireproof(chosen_clothing)
		playsound(get_turf(religious_tool), 'sound/magic/fireball.ogg', 50, TRUE)
		chosen_clothing = null //our lord and savior no longer cares about this apparel
		return TRUE
	chosen_clothing = null
	to_chat(user, span_warning("The clothing that was chosen for the rite is no longer on the altar!"))
	return FALSE


/datum/religion_rites/burning_sacrifice
	name = "Burning Offering"
	desc = "Sacrifice a buckled burning corpse for favor, the more burn damage the corpse has the more favor you will receive."
	ritual_length = 20 SECONDS
	ritual_invocations = list("Burning body ...",
	"... cleansed by the flame ...",
	"... we were all created from fire ...",
	"... and to it ...")
	invoke_msg = "... WE RETURN! "
///the burning corpse chosen for the sacrifice of the rite
	var/mob/living/carbon/chosen_sacrifice

/datum/religion_rites/burning_sacrifice/perform_rite(mob/living/user, atom/religious_tool)
	if(!ismovable(religious_tool))
		to_chat(user, span_warning("This rite requires a religious device that individuals can be buckled to."))
		return FALSE
	var/atom/movable/movable_reltool = religious_tool
	if(!movable_reltool)
		return FALSE
	if(!LAZYLEN(movable_reltool.buckled_mobs))
		to_chat(user, span_warning("Nothing is buckled to the altar!"))
		return FALSE
	for(var/corpse in movable_reltool.buckled_mobs)
		if(!iscarbon(corpse))// only works with carbon corpse since most normal mobs can't be set on fire.
			to_chat(user, span_warning("Only carbon lifeforms can be properly burned for the sacrifice!"))
			return FALSE
		chosen_sacrifice = corpse
		if(chosen_sacrifice.stat != DEAD)
			to_chat(user, span_warning("You can only sacrifice dead bodies, this one is still alive!"))
			return FALSE
		if(!chosen_sacrifice.on_fire)
			to_chat(user, span_warning("This corpse needs to be on fire to be sacrificed!"))
			return FALSE
		return ..()

/datum/religion_rites/burning_sacrifice/invoke_effect(mob/living/user, atom/movable/religious_tool)
	..()
	if(!(chosen_sacrifice in religious_tool.buckled_mobs)) //checks one last time if the right corpse is still buckled
		to_chat(user, span_warning("The right sacrifice is no longer on the altar!"))
		chosen_sacrifice = null
		return FALSE
	if(!chosen_sacrifice.on_fire)
		to_chat(user, span_warning("The sacrifice is no longer on fire, it needs to burn until the end of the rite!"))
		chosen_sacrifice = null
		return FALSE
	if(chosen_sacrifice.stat != DEAD)
		to_chat(user, span_warning("The sacrifice has to stay dead for the rite to work!"))
		chosen_sacrifice = null
		return FALSE
	var/favor_gained = 100 + round(chosen_sacrifice.getFireLoss())
	GLOB.religious_sect.adjust_favor(favor_gained, user)
	to_chat(user, span_notice("[GLOB.deity] absorbs the burning corpse and any trace of fire with it. [GLOB.deity] rewards you with [favor_gained] favor."))
	chosen_sacrifice.dust(force = TRUE)
	playsound(get_turf(religious_tool), 'sound/effects/supermatter.ogg', 50, TRUE)
	chosen_sacrifice = null
	return TRUE



/datum/religion_rites/infinite_candle
	name = "Immortal Candles"
	desc = "Creates 5 candles that never run out of wax."
	ritual_length = 10 SECONDS
	invoke_msg = "Burn bright, little candles, for you will only extinguish along with the universe."
	favor_cost = 200

/datum/religion_rites/infinite_candle/invoke_effect(mob/living/user, atom/movable/religious_tool)
	..()
	var/altar_turf = get_turf(religious_tool)
	for(var/i in 1 to 5)
		new /obj/item/candle/infinite(altar_turf)
	playsound(altar_turf, 'sound/magic/fireball.ogg', 50, TRUE)
	return TRUE

/*********Greedy God**********/

///all greed rites cost money instead
/datum/religion_rites/greed
	ritual_length = 5 SECONDS
	invoke_msg = "Sorry I was late, I was just making a shitload of money."
	var/money_cost = 0

/datum/religion_rites/greed/can_afford(mob/living/user)
	var/datum/bank_account/account = user.get_bank_account()
	if(!account)
		to_chat(user, span_warning("You need a way to pay for the rite!"))
		return FALSE
	if(account.account_balance < money_cost)
		to_chat(user, span_warning("This rite requires more money!"))
		return FALSE
	return TRUE

/datum/religion_rites/greed/invoke_effect(mob/living/user, atom/movable/religious_tool)
	var/datum/bank_account/account = user.get_bank_account()
	if(!account || account.account_balance < money_cost)
		to_chat(user, span_warning("This rite requires more money!"))
		return FALSE
	account.adjust_money(-money_cost)
	. = ..()

/datum/religion_rites/greed/vendatray
	name = "Purchase Vend-a-tray"
	desc = "Summons a Vend-a-tray. You can use it to sell items!"
	invoke_msg = "I need a vend-a-tray to make some more money!"
	money_cost = 300

/datum/religion_rites/greed/vendatray/invoke_effect(mob/living/user, atom/movable/religious_tool)
	..()
	var/altar_turf = get_turf(religious_tool)
	new /obj/structure/displaycase/forsale(altar_turf)
	playsound(get_turf(religious_tool), 'sound/effects/cashregister.ogg', 60, TRUE)
	return TRUE

/datum/religion_rites/greed/custom_vending
	name = "Purchase Personal Vending Machine"
	desc = "Summons a custom vending machine. You can use it to sell MANY items!"
	invoke_msg = "If I get a custom vending machine for my products, I can be RICH!"
	money_cost = 1000 //quite a step up from vendatray

/datum/religion_rites/greed/custom_vending/invoke_effect(mob/living/user, atom/movable/religious_tool)
	..()
	var/altar_turf = get_turf(religious_tool)
	new /obj/machinery/vending/custom/greed(altar_turf)
	playsound(get_turf(religious_tool), 'sound/effects/cashregister.ogg', 60, TRUE)
	return TRUE

/*********Honorbound God**********/

///Makes the person holy, but they now also have to follow the honorbound code (CBT). Actually earns favor, convincing others to uphold the code (tm) is not easy
/datum/religion_rites/deaconize
	name = "Join Crusade"
	desc = "Converts someone to your sect. They must be willing, so the first invocation will instead prompt them to join. \
	They will become honorbound like you, and you will gain a massive favor boost!"
	ritual_length = 30 SECONDS
	ritual_invocations = list(
	"A good, honorable crusade against evil is required.",
	"We need the righteous ...",
	"... the unflinching ...",
	"... and the just.",
	"Sinners must be silenced ...",)
	invoke_msg = "... And the code must be upheld!"
	///the invited crusader
	var/mob/living/carbon/human/new_crusader

/datum/religion_rites/deaconize/perform_rite(mob/living/user, atom/religious_tool)
	var/datum/religion_sect/honorbound/sect = GLOB.religious_sect
	if(!ismovable(religious_tool))
		to_chat(user, span_warning("This rite requires a religious device that individuals can be buckled to."))
		return FALSE
	var/atom/movable/movable_reltool = religious_tool
	if(!movable_reltool)
		return FALSE
	if(!LAZYLEN(movable_reltool.buckled_mobs))
		to_chat(user, span_warning("Nothing is buckled to the altar!"))
		return FALSE
	for(var/mob/living/carbon/human/possible_crusader in movable_reltool.buckled_mobs)
		if(possible_crusader.stat != CONSCIOUS)
			to_chat(user, span_warning("[possible_crusader] needs to be alive and conscious to join the crusade!"))
			return FALSE
		if(TRAIT_GENELESS in possible_crusader.dna.species.inherent_traits)
			to_chat(user, span_warning("This species disgusts [GLOB.deity]! They would never be allowed to join the crusade!"))
			return FALSE
		if(possible_crusader in sect.currently_asking)
			to_chat(user, span_warning("Wait for them to decide on whether to join or not!"))
			return FALSE
		if(!(possible_crusader in sect.possible_crusaders))
			INVOKE_ASYNC(sect, /datum/religion_sect/honorbound.proc/invite_crusader, possible_crusader)
			to_chat(user, span_notice("They have been given the option to consider joining the crusade against evil. Wait for them to decide and try again."))
			return FALSE
		new_crusader = possible_crusader
		return ..()

/datum/religion_rites/deaconize/invoke_effect(mob/living/carbon/human/user, atom/movable/religious_tool)
	..()
	var/mob/living/carbon/human/joining_now = new_crusader
	new_crusader = null
	if(!(joining_now in religious_tool.buckled_mobs)) //checks one last time if the right corpse is still buckled
		to_chat(user, span_warning("The new member is no longer on the altar!"))
		return FALSE
	if(joining_now.stat != CONSCIOUS)
		to_chat(user, span_warning("The new member has to stay alive for the rite to work!"))
		return FALSE
	if(!joining_now.mind)
		to_chat(user, span_warning("The new member has no mind!"))
		return FALSE
	if(joining_now.mind.has_antag_datum(/datum/antagonist/cult))//what the fuck?!
		to_chat(user, span_warning("[GLOB.deity] has seen a true, dark evil in [joining_now]'s heart, and they have been smitten!"))
		playsound(get_turf(religious_tool), 'sound/effects/pray.ogg', 50, TRUE)
		joining_now.gib(TRUE)
		return FALSE
	var/datum/mutation/human/honorbound/honormut = user.dna.check_mutation(/datum/mutation/human/honorbound)
	if(joining_now in honormut.guilty)
		honormut.guilty -= joining_now
	GLOB.religious_sect.adjust_favor(200, user)
	to_chat(user, span_notice("[GLOB.deity] has bound [joining_now] to the code! They are now a holy role! (albeit the lowest level of such)"))
	joining_now.mind.holy_role = HOLY_ROLE_DEACON
	GLOB.religious_sect.on_conversion(joining_now)
	playsound(get_turf(religious_tool), 'sound/effects/pray.ogg', 50, TRUE)
	return TRUE

///Mostly useless funny rite for forgiving someone, making them innocent once again.
/datum/religion_rites/forgive
	name = "Forgive"
	desc = "Forgives someone, making them no longer considered guilty. A kind gesture, all things considered!"
	invoke_msg = "You are absolved of sin."
	var/mob/living/who

/datum/religion_rites/forgive/perform_rite(mob/living/carbon/human/user, atom/religious_tool)
	if(!ishuman(user))
		return FALSE
	var/datum/mutation/human/honorbound/honormut = user.dna.check_mutation(/datum/mutation/human/honorbound)
	if(!honormut)
		return FALSE
	if(!length(honormut.guilty))
		to_chat(user, span_warning("[GLOB.deity] is holding no grudges to forgive."))
		return FALSE
	var/forgiven_choice = tgui_input_list(user, "Choose one of [GLOB.deity]'s guilty to forgive", "Forgive", honormut.guilty)
	if(isnull(forgiven_choice))
		return FALSE
	who = forgiven_choice
	return ..()

/datum/religion_rites/forgive/invoke_effect(mob/living/carbon/human/user, atom/movable/religious_tool)
	..()
	if(in_range(user, religious_tool))
		return FALSE
	var/datum/mutation/human/honorbound/honormut = user.dna.check_mutation(/datum/mutation/human/honorbound)
	if(!honormut) //edge case
		return FALSE
	honormut.guilty -= who
	who = null
	playsound(get_turf(religious_tool), 'sound/effects/pray.ogg', 50, TRUE)
	return TRUE

/datum/religion_rites/summon_rules
	name = "Summon Honorbound Rules"
	desc = "Enscribes a paper with the honorbound rules and regulations."
	invoke_msg = "Bring forth the holy writ!"
	///paper to turn into holy writ
	var/obj/item/paper/writ_target

/datum/religion_rites/summon_rules/perform_rite(mob/living/user, atom/religious_tool)
	for(var/obj/item/paper/could_writ in get_turf(religious_tool))
		if(istype(could_writ, /obj/item/paper/holy_writ))
			continue
		if(could_writ.get_total_length()) //blank paper pls
			continue
		writ_target = could_writ //PLEASE SIGN MY AUTOGRAPH
		return ..()
	to_chat(user, span_warning("You need to place blank paper on [religious_tool] to do this!"))
	return FALSE

/datum/religion_rites/summon_rules/invoke_effect(mob/living/user, atom/movable/religious_tool)
	..()
	var/obj/item/paper/autograph = writ_target
	var/turf/tool_turf = get_turf(religious_tool)
	writ_target = null
	if(QDELETED(autograph) || !(tool_turf == autograph.loc)) //check if the same food is still there
		to_chat(user, span_warning("Your target left the altar!"))
		return FALSE
	autograph.visible_message(span_notice("Words magically form on [autograph]!"))
	playsound(tool_turf, 'sound/effects/pray.ogg', 50, TRUE)
	new /obj/item/paper/holy_writ(tool_turf)
	qdel(autograph)
	return TRUE

/obj/item/paper/holy_writ
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scroll"
	slot_flags = null
	show_written_words = FALSE

	//info set in here because we need GLOB.deity
/obj/item/paper/holy_writ/Initialize(mapload)
	add_filter("holy_outline", 9, list("type" = "outline", "color" = "#fdff6c"))
	name = "[GLOB.deity]'s honorbound rules"
	default_raw_text = {"[GLOB.deity]'s honorbound rules:
	<br>
	1.) Thou shalt not attack the unready!<br>
	Those who are not ready for battle should not be wrought low. The evil of this world must lose
	in a fair battle if you are to conquer them completely.
	<br>
	<br>
	2.) Thou shalt not attack the just!<br>
	Those who fight for justice and good must not be harmed. Security is uncorruptable and must
	be respected. Healers are mostly uncorruptable and if you are truly sure Medical has fallen
	to the scourge of evil, use a declaration of evil.
	<br>
	<br>
	3.) Thou shalt not attack the innocent!<br>
	There is no honor on a pre-emptive strike, unless they are truly evil vermin.
	Those who are guilty will either lay a hand on you first, or you may declare their evil.
	<br>
	<br>
	4.) Thou shalt not use profane magicks!<br>
	You are not a warlock, you are an honorable warrior. There is nothing more corruptive than
	the vile magicks used by witches, warlocks, and necromancers. There are exceptions to this rule.<br>
	You may use holy magic, and, if you recruit one, the mime may use holy mimery. Restoration has also
	been allowed as it is a school focused on the light and mending of this world.
	"}
	. = ..()

/*********Maintenance God**********/

/datum/religion_rites/maint_adaptation
	name = "Maintenance Adaptation"
	desc = "Begin your metamorphasis into a being more fit for Maintenance."
	ritual_length = 10 SECONDS
	ritual_invocations = list("I abandon the world ...",
	"... to become one with the deep.",
	"My form will become twisted ...")
	invoke_msg = "... but my smile I will keep!"
	favor_cost = 150 //150u of organic slurry

/datum/religion_rites/maint_adaptation/perform_rite(mob/living/carbon/human/user, atom/religious_tool)
	if(!ishuman(user))
		return FALSE
	//uses HAS_TRAIT_FROM because junkies are also hopelessly addicted
	if(HAS_TRAIT_FROM(user, TRAIT_HOPELESSLY_ADDICTED, "maint_adaptation"))
		to_chat(user, span_warning("You've already adapted.</b>"))
		return FALSE
	return ..()

/datum/religion_rites/maint_adaptation/invoke_effect(mob/living/user, atom/movable/religious_tool)
	..()
	to_chat(user, span_warning("You feel your genes rattled and reshaped. <b>You're becoming something new.</b>"))
	user.emote("laughs")
	ADD_TRAIT(user, TRAIT_HOPELESSLY_ADDICTED, "maint_adaptation")
	//addiction sends some nasty mood effects but we want the maint adaption to be enjoyed like a fine wine
	SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "maint_adaptation", /datum/mood_event/maintenance_adaptation)
	if(iscarbon(user))
		var/mob/living/carbon/vomitorium = user
		vomitorium.vomit()
		var/datum/dna/dna = vomitorium.has_dna()
		dna?.add_mutation(/datum/mutation/human/stimmed) //some fluff mutations
		dna?.add_mutation(/datum/mutation/human/strong)
	user.mind.add_addiction_points(/datum/addiction/maintenance_drugs, 1000)//ensure addiction

/datum/religion_rites/adapted_eyes
	name = "Adapted Eyes"
	desc = "Only available after maintenance adaptation. Your eyes will adapt as well, becoming useless in the light."
	ritual_length = 10 SECONDS
	invoke_msg = "I no longer want to see the light."
	favor_cost = 300 //300u of organic slurry, i'd consider this a reward of the sect

/datum/religion_rites/adapted_eyes/perform_rite(mob/living/carbon/human/user, atom/religious_tool)
	if(!ishuman(user))
		return FALSE
	if(!HAS_TRAIT_FROM(user, TRAIT_HOPELESSLY_ADDICTED, "maint_adaptation"))
		to_chat(user, span_warning("You need to adapt to maintenance first."))
		return FALSE
	var/obj/item/organ/internal/eyes/night_vision/maintenance_adapted/adapted = user.getorganslot(ORGAN_SLOT_EYES)
	if(adapted && istype(adapted))
		to_chat(user, span_warning("Your eyes are already adapted!"))
		return FALSE
	return ..()

/datum/religion_rites/adapted_eyes/invoke_effect(mob/living/carbon/human/user, atom/movable/religious_tool)
	..()
	var/obj/item/organ/internal/eyes/oldeyes = user.getorganslot(ORGAN_SLOT_EYES)
	to_chat(user, span_warning("You feel your eyes adapt to the darkness!"))
	if(oldeyes)
		oldeyes.Remove(user, special = TRUE)
		qdel(oldeyes)//eh
	var/obj/item/organ/internal/eyes/night_vision/maintenance_adapted/neweyes = new
	neweyes.Insert(user, special = TRUE)

/datum/religion_rites/adapted_food
	name = "Moldify"
	desc = "Once adapted to the Maintenance, you will not be able to eat regular food. This should help."
	ritual_length = 5 SECONDS
	invoke_msg = "Moldify!"
	favor_cost = 5 //5u of organic slurry
	///the food that will be molded, only one per rite
	var/obj/item/food/mold_target

/datum/religion_rites/adapted_food/perform_rite(mob/living/user, atom/religious_tool)
	for(var/obj/item/food/could_mold in get_turf(religious_tool))
		if(istype(could_mold, /obj/item/food/badrecipe/moldy))
			continue
		mold_target = could_mold //moldify this o great one
		return ..()
	to_chat(user, span_warning("You need to place food on [religious_tool] to do this!"))
	return FALSE

/datum/religion_rites/adapted_food/invoke_effect(mob/living/user, atom/movable/religious_tool)
	..()
	var/obj/item/food/moldify = mold_target
	mold_target = null
	if(QDELETED(moldify) || !(get_turf(religious_tool) == moldify.loc)) //check if the same food is still there
		to_chat(user, span_warning("Your target left the altar!"))
		return FALSE
	to_chat(user, span_warning("[moldify] becomes rancid!"))
	user.emote("laughs")
	new /obj/item/food/badrecipe/moldy(get_turf(religious_tool))
	qdel(moldify)
	return TRUE

/datum/religion_rites/ritual_totem
	name = "Create Ritual Totem"
	desc = "Creates a Ritual Totem, a portable tool for performing rites on the go. Requires wood. Can only be picked up by the holy."
	favor_cost = 100
	invoke_msg = "Padala!!"
	///the food that will be molded, only one per rite
	var/obj/item/stack/sheet/mineral/wood/converted

/datum/religion_rites/ritual_totem/perform_rite(mob/living/user, atom/religious_tool)
	for(var/obj/item/stack/sheet/mineral/wood/could_totem in get_turf(religious_tool))
		converted = could_totem //totemify this o great one
		return ..()
	to_chat(user, span_warning("You need at least 1 wood to do this!"))
	return FALSE

/datum/religion_rites/ritual_totem/invoke_effect(mob/living/user, atom/movable/religious_tool)
	..()
	var/altar_turf = get_turf(religious_tool)
	var/obj/item/stack/sheet/mineral/wood/padala = converted
	converted = null
	if(QDELETED(padala) || !(get_turf(religious_tool) == padala.loc)) //check if the same food is still there
		to_chat(user, span_warning("Your target left the altar!"))
		return FALSE
	to_chat(user, span_warning("[padala] reshapes into a totem!"))
	if(!padala.use(1))//use one wood
		return
	user.emote("laughs")
	new /obj/item/ritual_totem(altar_turf)
	return TRUE

///sparring god rites

/datum/religion_rites/sparring_contract
	name = "Summon Sparring Contract"
	desc = "Turns some paper into a sparring contract."
	invoke_msg = "I will train in the name of my god."
	///paper to turn into a sparring contract
	var/obj/item/paper/contract_target

/datum/religion_rites/sparring_contract/perform_rite(mob/living/user, atom/religious_tool)
	for(var/obj/item/paper/could_contract in get_turf(religious_tool))
		if(could_contract.get_total_length()) //blank paper pls
			continue
		contract_target = could_contract
		return ..()
	to_chat(user, span_warning("You need to place blank paper on [religious_tool] to do this!"))
	return FALSE

/datum/religion_rites/sparring_contract/invoke_effect(mob/living/user, atom/movable/religious_tool)
	..()
	var/obj/item/paper/blank_paper = contract_target
	var/turf/tool_turf = get_turf(religious_tool)
	contract_target = null
	if(QDELETED(blank_paper) || !(tool_turf == blank_paper.loc)) //check if the same paper is still there
		to_chat(user, span_warning("Your target left the altar!"))
		return FALSE
	blank_paper.visible_message(span_notice("words magically form on [blank_paper]!"))
	playsound(tool_turf, 'sound/effects/pray.ogg', 50, TRUE)
	var/datum/religion_sect/spar/sect = GLOB.religious_sect
	if(sect.existing_contract)
		sect.existing_contract.visible_message(span_warning("[src] fizzles into nothing!"))
		qdel(sect.existing_contract)
	sect.existing_contract = new /obj/item/sparring_contract(tool_turf)
	qdel(blank_paper)
	return TRUE

/datum/religion_rites/declare_arena
	name = "Declare Arena"
	desc = "Declare a new area as fit for sparring. You'll be able to select it in contracts."
	ritual_length = 6 SECONDS
	ritual_invocations = list("I seek new horizons ...")
	invoke_msg = "... may my climb be steep."
	favor_cost = 1 //only costs one holy battle for a new area
	var/area/area_instance

/datum/religion_rites/declare_arena/perform_rite(mob/living/user, atom/religious_tool)
	var/list/filtered = list()
	for(var/area/unfiltered_area as anything in GLOB.sortedAreas)
		if(istype(unfiltered_area, /area/centcom)) //youuu dont need thaaat
			continue
		if(!(unfiltered_area.area_flags & HIDDEN_AREA))
			filtered += unfiltered_area
	area_instance = tgui_input_list(user, "Choose an area to mark as an arena!", "Arena Declaration", filtered)
	if(isnull(area_instance))
		return FALSE
	. = ..()

/datum/religion_rites/declare_arena/invoke_effect(mob/living/user, atom/movable/religious_tool)
	. = ..()
	var/datum/religion_sect/spar/sect = GLOB.religious_sect
	sect.arenas[area_instance.name] = area_instance.type
	to_chat(user, span_warning("[area_instance] is a now an option to select on sparring contracts."))

/datum/religion_rites/ceremonial_weapon
	name = "Forge Ceremonial Gear"
	desc = "Turn some material into ceremonial gear. Ceremonial blades are weak outside of sparring, and are quite heavy to lug around."
	ritual_length = 10 SECONDS
	invoke_msg = "Weapons in your name! Battles with your blood!"
	favor_cost = 0
	///the material that will be attempted to be forged into a weapon
	var/obj/item/stack/sheet/converted

/datum/religion_rites/ceremonial_weapon/perform_rite(mob/living/user, atom/religious_tool)
	for(var/obj/item/stack/sheet/could_blade in get_turf(religious_tool))
		if(!(GET_MATERIAL_REF(could_blade.material_type) in SSmaterials.materials_by_category[MAT_CATEGORY_ITEM_MATERIAL]))
			continue
		if(could_blade.amount < 5)
			continue
		converted = could_blade
		return ..()
	to_chat(user, span_warning("You need at least 5 sheets of a material that can be made into items!"))
	return FALSE

/datum/religion_rites/ceremonial_weapon/invoke_effect(mob/living/user, atom/movable/religious_tool)
	..()
	var/altar_turf = get_turf(religious_tool)
	var/obj/item/stack/sheet/used_for_blade = converted
	converted = null
	if(QDELETED(used_for_blade) || !(get_turf(religious_tool) == used_for_blade.loc) || used_for_blade.amount < 5) //check if the same food is still there
		to_chat(user, span_warning("Your target left the altar!"))
		return FALSE
	var/material_used = used_for_blade.material_type
	to_chat(user, span_warning("[used_for_blade] reshapes into a ceremonial blade!"))
	if(!used_for_blade.use(5))//use 5 of the material
		return
	var/obj/item/ceremonial_blade/blade = new(altar_turf)
	blade.set_custom_materials(list(GET_MATERIAL_REF(material_used) = MINERAL_MATERIAL_AMOUNT * 5))
	return TRUE

/datum/religion_rites/unbreakable
	name = "Become Unbreakable"
	desc = "Your training has made you unbreakable. In times of crisis, you will attempt to keep fighting on."
	ritual_length = 10 SECONDS
	invoke_msg = "My will must be unbreakable. Grant me this boon!"
	favor_cost = 4 //4 duels won

/datum/religion_rites/unbreakable/perform_rite(mob/living/carbon/human/user, atom/religious_tool)
	if(!ishuman(user))
		return FALSE
	if(HAS_TRAIT_FROM(user, TRAIT_UNBREAKABLE, INNATE_TRAIT))
		to_chat(user, span_warning("Your spirit is already unbreakable!"))
		return FALSE
	return ..()

/datum/religion_rites/unbreakable/invoke_effect(mob/living/carbon/human/user, atom/movable/religious_tool)
	..()
	to_chat(user, span_nicegreen("You feel [GLOB.deity]'s will to keep fighting pouring into you!"))
	user.AddComponent(/datum/component/unbreakable)

/datum/religion_rites/tenacious
	name = "Become Tenacious"
	desc = "Your training has made you tenacious. In times of crisis, you will be able to crawl faster."
	ritual_length = 10 SECONDS
	invoke_msg = "Grant me your tenacity! I have proven myself!"
	favor_cost = 3 //3 duels won

/datum/religion_rites/tenacious/perform_rite(mob/living/carbon/human/user, atom/religious_tool)
	if(!ishuman(user))
		return FALSE
	if(HAS_TRAIT_FROM(user, TRAIT_TENACIOUS, INNATE_TRAIT))
		to_chat(user, span_warning("Your spirit is already tenacious!"))
		return FALSE
	return ..()

/datum/religion_rites/tenacious/invoke_effect(mob/living/carbon/human/user, atom/movable/religious_tool)
	..()
	to_chat(user, span_nicegreen("You feel [GLOB.deity]'s tenacity pouring into you!"))
	user.AddElement(/datum/element/tenacious)
