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
		to_chat(user, "<span class='warning'>This rite requires more favor!</span>")
		return FALSE
	return TRUE

///Called to perform the invocation of the rite, with args being the performer and the altar where it's being performed. Maybe you want it to check for something else?
/datum/religion_rites/proc/perform_rite(mob/living/user, atom/religious_tool)
	if(!can_afford(user))
		return FALSE
	to_chat(user, "<span class='notice'>You begin to perform the rite of [name]...</span>")
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
		if(!ritual_invocations.len) //we divide so we gotta protect
			return FALSE
		if(!do_after(user, target = user, delay = ritual_length/ritual_invocations.len))
			return FALSE
		user.say(i)
	if(!do_after(user, target = user, delay = ritual_length/ritual_invocations.len)) //because we start at 0 and not the first fraction in invocations, we still have another fraction of ritual_length to complete
		return FALSE
	if(invoke_msg)
		user.say(invoke_msg)
	return TRUE


///Does the thing if the rite was successfully performed. return value denotes that the effect successfully (IE a harm rite does harm)
/datum/religion_rites/proc/invoke_effect(mob/living/user, atom/religious_tool)
	GLOB.religious_sect.on_riteuse(user,religious_tool)
	return TRUE


/*********Technophiles**********/

/datum/religion_rites/synthconversion
	name = "Synthetic Conversion"
	desc = "Convert a human-esque individual into a (superior) Android."
	ritual_length = 30 SECONDS
	ritual_invocations = list("By the inner workings of our god...",
						"... We call upon you, in the face of adversity...",
						"... to complete us, removing that which is undesirable...")
	invoke_msg = "... Arise, our champion! Become that which your soul craves, live in the world as your true form!!"
	favor_cost = 1000

/datum/religion_rites/synthconversion/perform_rite(mob/living/user, atom/religious_tool)
	if(!ismovable(religious_tool))
		to_chat(user, "<span class='warning'>This rite requires a religious device that individuals can be buckled to.</span>")
		return FALSE
	var/atom/movable/movable_reltool = religious_tool
	if(!movable_reltool)
		return FALSE
	if(!LAZYLEN(movable_reltool.buckled_mobs))
		. = FALSE
		if(!movable_reltool.can_buckle) //yes, if you have somehow managed to have someone buckled to something that now cannot buckle, we will still let you perform the rite!
			to_chat(user, "<span class='warning'>This rite requires a religious device that individuals can be buckled to.</span>")
			return
		to_chat(user, "<span class='warning'>This rite requires an individual to be buckled to [movable_reltool].</span>")
		return
	return ..()

/datum/religion_rites/synthconversion/invoke_effect(mob/living/user, atom/religious_tool)
	if(!ismovable(religious_tool))
		CRASH("[name]'s perform_rite had a movable atom that has somehow turned into a non-movable!")
	var/atom/movable/movable_reltool = religious_tool
	if(!movable_reltool?.buckled_mobs?.len)
		return FALSE
	var/mob/living/carbon/human/human2borg
	for(var/i in movable_reltool.buckled_mobs)
		if(istype(i,/mob/living/carbon/human))
			human2borg = i
			break
	if(!human2borg)
		return FALSE
	human2borg.set_species(/datum/species/android)
	human2borg.visible_message("<span class='notice'>[human2borg] has been converted by the rite of [name]!</span>")
	return TRUE


/*********Ever-Burning Candle**********/

///apply a bunch of fire immunity effect to clothing
/datum/religion_rites/fireproof/proc/apply_fireproof(obj/item/clothing/fireproofed)
	fireproofed.name = "unmelting [fireproofed.name]"
	fireproofed.max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	fireproofed.heat_protection = chosen_clothing.body_parts_covered
	fireproofed.resistance_flags |= FIRE_PROOF

/datum/religion_rites/fireproof
	name = "Unmelting Wax"
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
	if(!QDELETED(chosen_clothing) && get_turf(religious_tool) == chosen_clothing.loc) //check if the same clothing is still there
		if(istype(chosen_clothing,/obj/item/clothing/suit/hooded) || istype(chosen_clothing,/obj/item/clothing/suit/space/hardsuit ))
			for(var/obj/item/clothing/head/integrated_helmet in chosen_clothing.contents) //check if the clothing has a hood/helmet integrated and fireproof it if there is one.
				apply_fireproof(integrated_helmet)
		apply_fireproof(chosen_clothing)
		playsound(get_turf(religious_tool), 'sound/magic/fireball.ogg', 50, TRUE)
		chosen_clothing = null //our lord and savior no longer cares about this apparel
		return TRUE
	chosen_clothing = null
	to_chat(user, "<span class='warning'>The clothing that was chosen for the rite is no longer on the altar!</span>")
	return FALSE


/datum/religion_rites/burning_sacrifice
	name = "Candle Fuel"
	desc = "Sacrifice a buckled burning corpse for favor, the more burn damage the corpse has the more favor you will receive."
	ritual_length = 20 SECONDS
	ritual_invocations = list("To feed the fire of the one true flame ...",
	"... to make it burn brighter ...",
	"... so that it may consume all in its path ...",
	"... I offer you this pitiful being ...")
	invoke_msg = "... may it join you in the amalgamation of wax and fire, and become one in the black and white scene. "
///the burning corpse chosen for the sacrifice of the rite
	var/mob/living/carbon/chosen_sacrifice

/datum/religion_rites/burning_sacrifice/perform_rite(mob/living/user, atom/religious_tool)
	if(!ismovable(religious_tool))
		to_chat(user, "<span class='warning'>This rite requires a religious device that individuals can be buckled to.</span>")
		return FALSE
	var/atom/movable/movable_reltool = religious_tool
	if(!movable_reltool)
		return FALSE
	if(!LAZYLEN(movable_reltool.buckled_mobs))
		to_chat(user, "<span class='warning'>Nothing is buckled to the altar!</span>")
		return FALSE
	for(var/corpse in movable_reltool.buckled_mobs)
		if(!iscarbon(corpse))// only works with carbon corpse since most normal mobs can't be set on fire.
			to_chat(user, "<span class='warning'>Only carbon lifeforms can be properly burned for the sacrifice!</span>")
			return FALSE
		chosen_sacrifice = corpse
		if(chosen_sacrifice.stat != DEAD)
			to_chat(user, "<span class='warning'>You can only sacrifice dead bodies, this one is still alive!</span>")
			return FALSE
		if(!chosen_sacrifice.on_fire)
			to_chat(user, "<span class='warning'>This corpse needs to be on fire to be sacrificed!</span>")
			return FALSE
		return ..()

/datum/religion_rites/burning_sacrifice/invoke_effect(mob/living/user, atom/movable/religious_tool)
	if(!(chosen_sacrifice in religious_tool.buckled_mobs)) //checks one last time if the right corpse is still buckled
		to_chat(user, "<span class='warning'>The right sacrifice is no longer on the altar!</span>")
		chosen_sacrifice = null
		return FALSE
	if(!chosen_sacrifice.on_fire)
		to_chat(user, "<span class='warning'>The sacrifice is no longer on fire, it needs to burn until the end of the rite!</span>")
		chosen_sacrifice = null
		return FALSE
	if(chosen_sacrifice.stat != DEAD)
		to_chat(user, "<span class='warning'>The sacrifice has to stay dead for the rite to work!</span>")
		chosen_sacrifice = null
		return FALSE
	var/favor_gained = 100 + round(chosen_sacrifice.getFireLoss())
	GLOB.religious_sect?.adjust_favor(favor_gained, user)
	to_chat(user, "<span class='notice'>[GLOB.deity] absorb the burning corpse and any trace of fire with it. [GLOB.deity] rewards you with [favor_gained] favor.</span>")
	chosen_sacrifice.dust(force = TRUE)
	playsound(get_turf(religious_tool), 'sound/effects/supermatter.ogg', 50, TRUE)
	chosen_sacrifice = null
	return TRUE



/datum/religion_rites/infinite_candle
	name = "Immortal Candles"
	desc = "Creates 5 candles that never run out of wax."
	ritual_length = 10 SECONDS
	invoke_msg = "please lend us five of your candles so we may bask in your burning glory."
	favor_cost = 200

/datum/religion_rites/infinite_candle/invoke_effect(mob/living/user, atom/movable/religious_tool)
	var/altar_turf = get_turf(religious_tool)
	for(var/i in 1 to 5)
		new /obj/item/candle/infinite(altar_turf)
	playsound(altar_turf, 'sound/magic/fireball.ogg', 50, TRUE)
	return TRUE

/*********Greedy God**********/

///all greed rites cost money instead
/datum/religion_rites/greed
	ritual_length = 5 SECONDS
	invoke_msg = "Sorry I was late I was just making a shitload of money."
	var/money_cost = 0

/datum/religion_rites/greed/can_afford(mob/living/user)
	var/datum/bank_account/account = user.get_bank_account()
	if(!account)
		to_chat(user, "<span class='warning'>You need a way to pay for the rite!</span>")
		return FALSE
	if(account.account_balance < money_cost)
		to_chat(user, "<span class='warning'>This rite requires more money!</span>")
		return FALSE
	return TRUE

/datum/religion_rites/greed/custom_vending/invoke_effect(mob/living/user, atom/movable/religious_tool)
	var/datum/bank_account/account = user.get_bank_account()
	if(!account || account.account_balance < money_cost)
		to_chat(user, "<span class='warning'>This rite requires more money!</span>")
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
	invoke_msg = "If I get a custom vending machine for my products, I'll be RICH!"
	money_cost = 1000 //quite a step up from vendatray

/datum/religion_rites/greed/custom_vending/invoke_effect(mob/living/user, atom/movable/religious_tool)
	var/altar_turf = get_turf(religious_tool)
	new /obj/machinery/vending/custom/greed(altar_turf)
	playsound(get_turf(religious_tool), 'sound/effects/cashregister.ogg', 60, TRUE)
	return TRUE

/*********Maintenance God**********/

/datum/religion_rites/maint_adaptation
	name = "Maintenance Adaptation"
	desc = "Begin your metamorphasis into a being more fit for maintenance."
	ritual_length = 10 SECONDS
	ritual_invocations = list("I abandon the world ...",
	"... to become one with the deep.",
	"My form will become twirled ...")
	invoke_msg = "... but my smile I will keep!"
	favor_cost = 150 //150u of organic slurry

/datum/religion_rites/maint_adaptation/invoke_effect(mob/living/user, atom/movable/religious_tool)
	..()
	to_chat(user, "<span class='warning'>You feel your genes rattled and reshaped. <b>You're becoming something new.</b></span>")
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
	to_chat(user, "<span class='warning'>You need to place food on [religious_tool] to do this!</span>")
	return FALSE

/datum/religion_rites/adapted_food/invoke_effect(mob/living/user, atom/movable/religious_tool)
	..()
	var/obj/item/food/moldify = mold_target
	mold_target = null
	if(QDELETED(moldify) || !(get_turf(religious_tool) == moldify.loc)) //check if the same food is still there
		to_chat(user, "<span class='warning'>Your target left the altar!</span>")
		return FALSE
	to_chat(user, "<span class='warning'>[moldify] becomes rancid!</span>")
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
	to_chat(user, "<span class='warning'>You need at least 1 wood to do this!</span>")
	return FALSE

/datum/religion_rites/ritual_totem/invoke_effect(mob/living/user, atom/movable/religious_tool)
	var/altar_turf = get_turf(religious_tool)
	var/obj/item/stack/sheet/mineral/wood/padala = converted
	converted = null
	if(QDELETED(padala) || !(get_turf(religious_tool) == padala.loc)) //check if the same food is still there
		to_chat(user, "<span class='warning'>Your target left the altar!</span>")
		return FALSE
	to_chat(user, "<span class='warning'>[padala] reshapes into a totem!</span>")
	if(!padala.use(1))//use one wood
		return
	user.emote("laughs")
	new /obj/item/ritual_totem(altar_turf)
	return TRUE

/obj/item/ritual_totem
	name = "ritual totem"
	desc = "A wooden totem with strange carvings on it."
	icon_state = "ritual_totem"
	inhand_icon_state = "sheet-wood"
	lefthand_file = 'icons/mob/inhands/misc/sheets_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/sheets_righthand.dmi'
	force = 0
	throwforce = 0

/obj/item/ritual_totem/Initialize()
	. = ..()
	AddComponent(/datum/component/anti_magic, TRUE, TRUE, FALSE, null, 1, FALSE, CALLBACK(src, .proc/block_magic), CALLBACK(src, .proc/expire))//one charge of anti_magic
	AddComponent(/datum/component/religious_tool, RELIGION_TOOL_INVOKE, FALSE)

/obj/item/ritual_totem/proc/block_magic(mob/user, major)
	if(major)
		to_chat(user, "<span class='warning'>[src] consumes the magic within itself!</span>")

/obj/item/ritual_totem/proc/expire(mob/user)
	to_chat(user, "<span class='warning'>[src] quickly decays into rot!</span>")
	qdel(src)
	new /obj/effect/decal/cleanable/ash(drop_location())

/obj/item/ritual_totem/can_be_pulled(user, grab_state, force)
	. = ..()
	return FALSE //no

/obj/item/ritual_totem/examine(mob/user)
	. = ..()
	var/is_holy = user.mind?.holy_role
	if(is_holy)
		. += "<span class='notice'>[src] can only be moved by important followers of [GLOB.deity].</span>"

/obj/item/ritual_totem/pickup(mob/taker)
	var/initial_loc = loc
	var/holiness = taker.mind?.holy_role
	var/no_take = FALSE
	if(holiness == NONE)
		to_chat(taker, "<span class='warning'>Try as you may, you're seemingly unable to pick [src] up!</span>")
		no_take = TRUE
	if(holiness == HOLY_ROLE_DEACON) //deacons cannot pick them up either
		no_take = TRUE
		to_chat(taker, "<span class='warning'>You cannot pick [src] up. It seems you aren't important enough to [GLOB.deity] to do that.</span>")
	..()
	if(no_take)
		taker.dropItemToGround(src)
		forceMove(initial_loc)

