/datum/action/innate/cult/blood_magic //Blood magic handles the creation of blood spells (formerly talismans)
	name = "Prepare Blood Magic"
	button_icon_state = "carve"
	desc = "Prepare blood magic by carving runes into your flesh. This rite is most effective with an <b>empowering rune</b>"
	var/list/spells = list()
	var/channeling = FALSE

/datum/action/innate/cult/blood_magic/Grant()
	..()
	button.screen_loc = "6:-29,4:-2"
	button.moved = "6:-29,4:-2"


/datum/action/innate/cult/blood_magic/Remove()
	for(var/X in spells)
		qdel(X)
	..()

/datum/action/innate/cult/blood_magic/IsAvailable()
	var/datum/antagonist/cult/C = owner.mind.has_antag_datum(/datum/antagonist/cult,TRUE)
	if(!C)
		return FALSE
	return ..()

/datum/action/innate/cult/blood_magic/proc/Positioning()
	for(var/datum/action/innate/cult/blood_spell/B in spells)
		var/pos = -29+spells.Find(B)*31
		B.button.screen_loc = "6:[pos],4:-2"
		B.button.moved = B.button.screen_loc

/datum/action/innate/cult/blood_magic/Activate()
	var/rune = FALSE
	var/limit = RUNELESS_MAX_BLOODCHARGE
	for(var/obj/effect/rune/imbue/R in range(1, owner))
		rune = TRUE
		break
	if(rune)
		limit = MAX_BLOODCHARGE
	if(spells.len >= limit)
		if(rune)
			to_chat(owner, "<span class='cultitalic'>Your body has reached its limit, you cannot store more than [MAX_BLOODCHARGE] spells at once. <b>Pick a spell to nullify.</b></span>")
		else
			to_chat(owner, "<span class='cultitalic'>Your body has reached its limit, <b>you cannot store more than [RUNELESS_MAX_BLOODCHARGE] spells at once without an empowering rune! Pick a spell to nullify.</b></span>")
		var/nullify_spell = input(owner, "Choose a spell to remove.", "Current Spells") as null|anything in spells
		if(nullify_spell)
			qdel(nullify_spell)
		return
	var/entered_spell_name
	var/datum/action/innate/cult/blood_spell/BS
	var/list/possible_spells = list()
	for(var/I in subtypesof(/datum/action/innate/cult/blood_spell))
		var/datum/action/innate/cult/blood_spell/J = I
		var/cult_name = initial(J.name)
		possible_spells[cult_name] = J
	entered_spell_name = input(owner, "Pick a blood spell to prepare...", "Spell Choices") as null|anything in possible_spells
	BS = possible_spells[entered_spell_name]
	if(QDELETED(src) || owner.incapacitated() || !BS)
		return
	to_chat(owner,"<span class='warning'>You begin to carve unnatural symbols into your flesh!</span>")
	SEND_SOUND(owner, sound('sound/weapons/slice.ogg',0,1,10))
	if(!channeling)
		channeling = TRUE
	else
		to_chat(owner, "<span class='cultitalic'>You are already invoking blood magic!")
		return
	if(do_after(owner, 100 - rune*50, target = owner))
		if(ishuman(owner))
			var/mob/living/carbon/human/H = owner
			H.bleed(30 - rune*25)
		var/datum/action/innate/cult/blood_spell/new_spell = new BS(owner)
		new_spell.Grant(owner, src)
		spells += new_spell
		Positioning()
		to_chat(owner, "<span class='warning'>Your wounds glows with power, you have prepared a [new_spell.name] invocation!</span>")
	channeling = FALSE

/datum/action/innate/cult/blood_spell //The next generation of talismans
	name = "Blood Magic"
	button_icon_state = "telerune"
	desc = "Fear the Old Blood."
	var/charges = 1
	var/magic_path = null
	var/obj/item/melee/blood_magic/hand_magic
	var/datum/action/innate/cult/blood_magic/all_magic
	var/base_desc //To allow for updating tooltips
	var/invocation
	var/health_cost = 0

/datum/action/innate/cult/blood_spell/Grant(mob/living/owner, datum/action/innate/cult/blood_magic/BM)
	if(health_cost)
		desc += "<br>Deals <u>[health_cost] damage</u> to your arm per use."
	base_desc = desc
	desc += "<br><b><u>Has [charges] use\s remaining</u></b>."
	all_magic = BM
	..()

/datum/action/innate/cult/blood_spell/Remove()
	if(all_magic)
		all_magic.spells -= src
	if(hand_magic)
		qdel(hand_magic)
		hand_magic = null
	..()

/datum/action/innate/cult/blood_spell/IsAvailable()
	var/datum/antagonist/cult/C = owner.mind.has_antag_datum(/datum/antagonist/cult,TRUE)
	if(!C || !charges)
		return FALSE
	return ..()

/datum/action/innate/cult/blood_spell/Activate()
	if(magic_path) //If this spell flows from the hand
		if(!hand_magic)
			hand_magic = new magic_path(owner, src)
			if(!owner.put_in_hands(hand_magic))
				qdel(hand_magic)
				hand_magic = null
				to_chat(owner, "<span class='warning'>You have no empty hand for invoking blood magic!</span>")
				return
			to_chat(owner, "<span class='notice'>Your old wounds glow again as you invoke the [name].</span>")
			return
		if(hand_magic)
			qdel(hand_magic)
			hand_magic = null
			to_chat(owner, "<span class='warning'>You snuff out the spell with your hand, saving its power for another time.</span>")


//Cult Blood Spells
/datum/action/innate/cult/blood_spell/stun
	name = "Stun"
	desc = "A potent spell that will stun and mute victims upon contact."
	button_icon_state = "hand"
	magic_path = "/obj/item/melee/blood_magic/stun"
	health_cost = 10

/datum/action/innate/cult/blood_spell/teleport
	name = "Teleport"
	desc = "A useful spell that teleport cultists to a chosen destination on contact."
	button_icon_state = "tele"
	magic_path = "/obj/item/melee/blood_magic/teleport"
	health_cost = 5

/datum/action/innate/cult/blood_spell/emp
	name = "Electromagnetic Pulse"
	desc = "A large spell that immediately disables all electronics in the area."
	button_icon_state = "emp"
	health_cost = 5

/datum/action/innate/cult/blood_spell/emp/Activate()
	owner.visible_message("<span class='warning'>[owner]'s hand flashes a bright blue!</span>", \
						 "<span class='cultitalic'>You speak the cursed words, emitting an EMP blast from your hand.</span>")
	empulse(src, 4, 8)
	charges--
	if(charges<=0)
		qdel(src)

/datum/action/innate/cult/blood_spell/shackles
	name = "Shadow Shackles"
	desc = "A stealthy spell that will handcuff and temporarily silence your victim."
	button_icon_state = "cuff"
	charges = 5
	magic_path = "/obj/item/melee/blood_magic/shackles"

/datum/action/innate/cult/blood_spell/construction
	name = "Twisted Construction"
	desc = "<u>A sinister spell used to convert:</u><br>Plasteel into runed metal<br>25 metal into a construct shell<br>Cyborgs directly into constructs<br>Cyborg shells into construct shells<br>Airlocks into runed airlocks (harm intent)"
	button_icon_state = "transmute"
	charges = 50
	magic_path = "/obj/item/melee/blood_magic/construction"

/datum/action/innate/cult/blood_spell/dagger
	name = "Summon Dagger"
	desc = "A crucial spell that will summon a ritual dagger. It is rumored some cultists have favored this spell in order to use the ritual dagger as a throwing weapon."
	button_icon_state = "dagger"
	charges = 3

/datum/action/innate/cult/blood_spell/dagger/Activate()
	var/turf/T = get_turf(owner)
	owner.visible_message("<span class='warning'>[owner]'s hand glows red for a moment.</span>", \
		"<span class='cultitalic'>Red light begins to shimmer and take form within your hand!</span>")
	var/obj/O = new /obj/item/melee/cultblade/dagger(T)
	if(owner.put_in_hands(O))
		to_chat(owner, "<span class='warning'>A ritual dagger appears in your hand!</span>")
	else
		owner.visible_message("<span class='warning'>A ritual dagger appears at [owner]'s feet!</span>", \
			 "<span class='cultitalic'>A ritual dagger materializes at your feet.</span>")
	SEND_SOUND(owner, sound('sound/effects/magic.ogg',0,1,25))
	charges--
	if(charges<=0)
		qdel(src)

/datum/action/innate/cult/blood_spell/armor
	name = "Summon Armor"
	desc = "A scheming spell that will instantly equip your target will Nar'sien vestments. Can be used to bolster allies or confuse your foes."
	button_icon_state = "armor"
	charges = 3
	magic_path = "/obj/item/melee/blood_magic/armor"
	health_cost = 5

/datum/action/innate/cult/blood_spell/horror
	name = "Hallucinations"
	desc = "A horrifying spell that will break the mind of the victim with nightmarish hallucinations."
	button_icon_state = "horror"
	var/obj/effect/proc_holder/horror/PH
	charges = 4

/datum/action/innate/cult/blood_spell/horror/New()
	PH = new()
	PH.attached_action = src
	..()

/datum/action/innate/cult/blood_spell/horror/Destroy()
	var/obj/effect/proc_holder/horror/destroy = PH
	. = ..()
	if(destroy  && !QDELETED(destroy))
		QDEL_NULL(destroy)

/datum/action/innate/cult/blood_spell/horror/Activate()
	PH.toggle(owner) //the important bit
	return TRUE

/obj/effect/proc_holder/horror
	active = FALSE
	ranged_mousepointer = 'icons/effects/cult_target.dmi'
	var/datum/action/innate/cult/blood_spell/attached_action

/obj/effect/proc_holder/horror/Destroy()
	var/datum/action/innate/cult/blood_spell/AA = attached_action
	. = ..()
	if(AA && !QDELETED(AA))
		QDEL_NULL(AA)

/obj/effect/proc_holder/horror/proc/toggle(mob/user)
	if(active)
		remove_ranged_ability("<span class='cult'>You dispel the magic...</span>")
	else
		add_ranged_ability(user, "<span class='cult'>You prepare to horrify a target...</span>")

/obj/effect/proc_holder/horror/InterceptClickOn(mob/living/caller, params, atom/target)
	if(..())
		return
	if(ranged_ability_user.incapacitated() || !iscultist(caller))
		remove_ranged_ability()
		return
	var/turf/T = get_turf(ranged_ability_user)
	if(!isturf(T))
		return FALSE
	if(target in view(7, get_turf(ranged_ability_user)))
		if(!ishuman(target) || iscultist(target))
			return
		var/mob/living/carbon/human/H = target
		H.hallucination = max(H.hallucination, 240)
		SEND_SOUND(ranged_ability_user, sound('sound/effects/ghost.ogg',0,1,50))
		to_chat(ranged_ability_user,"<span class='cult'><b>You curse [H] to experience mind-wracking nightmares!</b></span>")
		attached_action.charges--
		attached_action.desc = attached_action.base_desc
		attached_action.desc += "<br><b><u>Has [attached_action.charges] use\s remaining</u></b>."
		attached_action.UpdateButtonIcon()
		if(attached_action.charges <= 0)
			remove_mousepointer(ranged_ability_user.client)
			remove_ranged_ability("<span class='cult'>You have exhausted the spell's power!</span>")
			qdel(src)

/datum/action/innate/cult/blood_spell/veiling
	name = "Conceal Runes"
	desc = "A multi-use spell that alternates between hiding and revealing nearby runes."
	invocation = "Kla'atu barada nikt'o!"
	button_icon_state = "gone"
	charges = 10
	var/revealing = FALSE //if it reveals or not

/datum/action/innate/cult/blood_spell/veiling/Activate()
	if(!revealing)
		owner.visible_message("<span class='warning'>Thin grey dust falls from [owner]'s hand!</span>", \
			"<span class='cultitalic'>You invoke the veiling spell, hiding nearby runes.</span>")
		charges--
		SEND_SOUND(owner, sound('sound/magic/smoke.ogg',0,1,25))
		owner.whisper(invocation, language = /datum/language/common)
		for(var/obj/effect/rune/R in range(5,owner))
			R.conceal()
		for(var/obj/structure/destructible/cult/S in range(5,owner))
			S.conceal()
		for(var/turf/open/floor/engine/cult/T  in range(5,owner))
			T.realappearance.alpha = 0
		revealing = TRUE
		name = "Reveal Runes"
		button_icon_state = "back"
	else
		owner.visible_message("<span class='warning'>A flash of light shines from [owner]'s hand!</span>", \
			 "<span class='cultitalic'>You invoke the counterspell, revealing nearby runes.</span>")
		charges--
		owner.whisper(invocation, language = /datum/language/common)
		SEND_SOUND(owner, sound('sound/magic/enter_blood.ogg',0,1,25))
		for(var/obj/effect/rune/R in range(7,owner)) //More range in case you weren't standing in exactly the same spot
			R.reveal()
		for(var/obj/structure/destructible/cult/S in range(7,owner))
			S.reveal()
		for(var/turf/open/floor/engine/cult/T  in range(7,owner))
			T.realappearance.alpha = initial(T.realappearance.alpha)
		revealing = FALSE
		name = "Conceal Runes"
		button_icon_state = "gone"
	if(charges<= 0)
		qdel(src)
	desc = base_desc
	desc += "<br><b><u>Has [charges] use\s remaining</u></b>."
	UpdateButtonIcon()




// The "magic hand" items
/obj/item/melee/blood_magic
	name = "\improper magical aura"
	desc = "Sinister looking aura that distorts the flow of reality around it."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "disintegrate"
	item_state = null
	flags_1 = ABSTRACT_1 | NODROP_1 | DROPDEL_1
	w_class = WEIGHT_CLASS_HUGE
	throwforce = 0
	throw_range = 0
	throw_speed = 0
	var/invocation
	var/uses = 1
	var/health_cost = 0 //The amount of health taken from the user when invoking the spell
	var/datum/action/innate/cult/blood_spell/source

/obj/item/melee/blood_magic/New(loc, spell)
	source = spell
	uses = source.charges
	health_cost = source.health_cost
	..()

/obj/item/melee/blood_magic/Destroy()
	if(source)
		if(uses <= 0)
			source.hand_magic = null
			qdel(source)
			source = null
		else
			source.charges = uses
	..()

/obj/item/melee/blood_magic/attack_self(mob/living/user)
	attack(user, user)

/obj/item/melee/blood_magic/attack(mob/target, mob/living/carbon/user)
	if(!iscarbon(user) || !iscultist(user))
		uses = 0
		qdel(src)
		return
	if(user.lying || user.handcuffed)
		to_chat(user, "<span class='warning'>You can't reach out!</span>")
		return
	afterattack(target, user)

/obj/item/melee/blood_magic/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(source)
		source.desc = source.base_desc
		source.desc += "<br><b><u>Has [uses] use\s remaining</u></b>."
		source.UpdateButtonIcon()
	if(invocation)
		user.whisper(invocation, language = /datum/language/common)
	if(health_cost)
		if(user.active_hand_index == 1)
			user.apply_damage(health_cost, BRUTE, "l_arm")
		else
			user.apply_damage(health_cost, BRUTE, "r_arm")
	if(uses <= 0)
		qdel(src)

//Stun
/obj/item/melee/blood_magic/stun
	color = "#ff0000" // red
	invocation = "Fuu ma'jin!"
	health_cost = 10

/obj/item/melee/blood_magic/stun/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(!isliving(target) || !proximity)
		return
	var/mob/living/L = target
	if(iscultist(target))
		return
	if(iscultist(user))
		user.visible_message("<span class='warning'>[user] holds up their hand, which explodes in a flash of red light!</span>", \
							 "<span class='cultitalic'>You stun [L] with the spell!</span>")
		var/obj/item/nullrod/N = locate() in L
		if(N)
			target.visible_message("<span class='warning'>[L]'s holy weapon absorbs the light!</span>", \
								   "<span class='userdanger'>Your holy weapon absorbs the blinding light!</span>")
		else
			L.Knockdown(180)
			L.flash_act(1,1)
			if(issilicon(target))
				var/mob/living/silicon/S = L
				S.emp_act(EMP_HEAVY)
			else if(iscarbon(target))
				var/mob/living/carbon/C = L
				C.silent += 7
				C.stuttering += 15
				C.cultslurring += 15
				C.Jitter(15)
			if(is_servant_of_ratvar(L))
				L.adjustBruteLoss(15)
		uses--
	..()

//Teleportation
/obj/item/melee/blood_magic/teleport
	color = RUNE_COLOR_TELEPORT
	desc = "A potent spell that teleport cultists on contact."
	invocation = "Sas'so c'arta forbici!"
	health_cost = 5

/obj/item/melee/blood_magic/teleport/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(!iscultist(target) || !proximity)
		to_chat(user, "<span class='warning'>You can only teleport adjacent cultists with this spell!</span>")
		return
	if(iscultist(user))
		var/list/potential_runes = list()
		var/list/teleportnames = list()
		for(var/R in GLOB.teleport_runes)
			var/obj/effect/rune/teleport/T = R
			potential_runes[avoid_assoc_duplicate_keys(T.listkey, teleportnames)] = T

		if(!potential_runes.len)
			to_chat(user, "<span class='warning'>There are no valid runes to teleport to!</span>")
			log_game("Teleport talisman failed - no other teleport runes")
			return

		if(user.z > ZLEVEL_SPACEMAX)
			to_chat(user, "<span class='cultitalic'>You are not in the right dimension!</span>")
			log_game("Teleport talisman failed - user in away mission")
			return

		var/input_rune_key = input(user, "Choose a rune to teleport to.", "Rune to Teleport to") as null|anything in potential_runes //we know what key they picked
		var/obj/effect/rune/teleport/actual_selected_rune = potential_runes[input_rune_key] //what rune does that key correspond to?
		if(QDELETED(src) || !user || !user.is_holding(src) || user.incapacitated() || !actual_selected_rune || !proximity)
			return
		var/turf/dest = get_turf(actual_selected_rune)
		if(is_blocked_turf(dest, TRUE))
			to_chat(user, "<span class='warning'>The target rune is blocked. Attempting to teleport to it would be massively unwise.</span>")
			return
		uses--
		user.visible_message("<span class='warning'>Dust flows from [user]'s hand, and [user.p_they()] disappear[user.p_s()] with a sharp crack!</span>", \
		"<span class='cultitalic'>You speak the words of the talisman and find yourself somewhere else!</span>", "<i>You hear a sharp crack.</i>")
		var/mob/living/L = target
		L.forceMove(dest)
		dest.visible_message("<span class='warning'>There is a boom of outrushing air as something appears above the rune!</span>", null, "<i>You hear a boom.</i>")
		..()

//Shackles
/obj/item/melee/blood_magic/shackles
	name = "Shadow Shackles"
	desc = "Allows you to bind a victim and temporarily silence them."
	invocation = "In'totum Lig'abis!"
	color = "#000000" // black
	uses = 5

/obj/item/melee/blood_magic/shackles/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(iscultist(user) && iscarbon(target))
		var/mob/living/carbon/C = target
		if(C.get_num_arms() >= 2 || C.get_arm_ignore())
			CuffAttack(C, user)
		else
			user.visible_message("<span class='cultitalic'>This victim doesn't have enough arms to complete the restraint!</span>")
			return
		..()

/obj/item/melee/blood_magic/shackles/proc/CuffAttack(mob/living/carbon/C, mob/living/user)
	if(!C.handcuffed)
		playsound(loc, 'sound/weapons/cablecuff.ogg', 30, 1, -2)
		C.visible_message("<span class='danger'>[user] begins restraining [C] with dark magic!</span>", \
								"<span class='userdanger'>[user] begins shaping a dark magic around your wrists!</span>")
		if(do_mob(user, C, 30))
			if(!C.handcuffed)
				C.handcuffed = new /obj/item/restraints/handcuffs/energy/cult/used(C)
				C.update_handcuffed()
				C.silent += 7
				to_chat(user, "<span class='notice'>You shackle [C].</span>")
				add_logs(user, C, "shackled")
				uses--
			else
				to_chat(user, "<span class='warning'>[C] is already bound.</span>")
		else
			to_chat(user, "<span class='warning'>You fail to shackle [C].</span>")
	else
		to_chat(user, "<span class='warning'>[C] is already bound.</span>")


//Construction: Creates a construct shell out of 25 metal sheets, or converts plasteel into runed metal
/obj/item/melee/blood_magic/construction
	name = "Twisted Construction"
	desc = "Corrupts metal and plasteel into more sinister forms."
	invocation = "Ethra p'ni dedol!"
	color = "#000000" // black
	uses = 50

/obj/item/melee/blood_magic/construction/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(proximity_flag && iscultist(user))
		var/turf/T = get_turf(target)
		if(istype(target, /obj/item/stack/sheet/metal))
			var/obj/item/stack/sheet/candidate = target
			if(candidate.use(25))
				uses-=25
				to_chat(user, "<span class='warning'>A dark cloud eminates from your hand and swirls around the metal, twisting it into a construct shell!</span>")
				new /obj/structure/constructshell(T)
				SEND_SOUND(user, sound('sound/effects/magic.ogg',0,1,25))
			else
				to_chat(user, "<span class='warning'>You need more metal to produce a construct shell!</span>")
		else if(istype(target, /obj/item/stack/sheet/plasteel))
			var/obj/item/stack/sheet/plasteel/candidate = target
			var/quantity = min(candidate.amount, uses)
			uses -= quantity
			new /obj/item/stack/sheet/runed_metal(T,quantity)
			candidate.use(quantity)
			to_chat(user, "<span class='warning'>A dark cloud eminates from you hand and swirls around the plasteel, transforming it into runed metal!</span>")
			SEND_SOUND(user, sound('sound/effects/magic.ogg',0,1,25))
		else if(istype(target,/mob/living/silicon/robot))
			var/mob/living/silicon/robot/candidate = target
			if(candidate.mmi)
				user.visible_message("<span class='danger'>A dark cloud eminates from [user]'s hand and swirls around [candidate]!</span>")
				playsound(T, 'sound/machines/airlock_alien_prying.ogg', 80, 1)
				var/prev_color = candidate.color
				candidate.color = "black"
				if(do_after(user, 90, target = candidate))
					candidate.emp_act(EMP_HEAVY)
					var/construct_class = alert(user, "Please choose which type of construct you wish to create.",,"Juggernaut","Wraith","Artificer")
					user.visible_message("<span class='danger'>The dark cloud receedes from what was formerly [candidate], revealing a\n [construct_class]!</span>")
					switch(construct_class)
						if("Juggernaut")
							makeNewConstruct(/mob/living/simple_animal/hostile/construct/armored, candidate, user, 0, T)
						if("Wraith")
							makeNewConstruct(/mob/living/simple_animal/hostile/construct/wraith, candidate, user, 0, T)
						if("Artificer")
							makeNewConstruct(/mob/living/simple_animal/hostile/construct/builder, candidate, user, 0, T)
					SEND_SOUND(user, sound('sound/effects/magic.ogg',0,1,25))
					uses -= 50
					candidate.mmi = null
					qdel(candidate)
					return
				candidate.color = prev_color
			else
				uses -= 50
				to_chat(user, "<span class='warning'>A dark cloud eminates from you hand and swirls around [candidate] - twisting it into a construct shell!</span>")
				new /obj/structure/constructshell(T)
				SEND_SOUND(user, sound('sound/effects/magic.ogg',0,1,25))
		else if(istype(target,/obj/machinery/door/airlock))
			var/turf/tar = get_turf(target)
			qdel(target)
			new /obj/machinery/door/airlock/cult/weak(tar)
			uses -= 50
			to_chat(user, "<span class='warning'>A dark cloud eminates from you hand and swirls around the airlock - twisting it into a runed airlock!</span>")
			SEND_SOUND(user, sound('sound/effects/magic.ogg',0,1,25))
		else
			to_chat(user, "<span class='warning'>The spell will not work on [target]!</span>")
		..()

//Armor: Gives the target a basic cultist combat loadout
/obj/item/melee/blood_magic/armor
	name = "Talisman of Arming"
	desc = "A spell that will equip the target with cultist equipment if there is a slot to equip it to."
	color = "#33cc33" // green
	health_cost = 5

/obj/item/melee/blood_magic/armor/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(iscarbon(target))
		uses--
		var/mob/living/carbon/C = target
		C.visible_message("<span class='warning'>Otherworldly armor suddenly appears on [C]!</span>")
		C.equip_to_slot_or_del(new /obj/item/clothing/under/color/black,slot_w_uniform)
		C.equip_to_slot_or_del(new /obj/item/clothing/head/culthood/alt(user), slot_head)
		C.equip_to_slot_or_del(new /obj/item/clothing/suit/cultrobes/alt(user), slot_wear_suit)
		C.equip_to_slot_or_del(new /obj/item/clothing/shoes/cult/alt(user), slot_shoes)
		C.equip_to_slot_or_del(new /obj/item/storage/backpack/cultpack(user), slot_back)
		if(C == user)
			qdel(src) //Clears the hands
		C.put_in_hands(new /obj/item/melee/cultblade(user))
		C.put_in_hands(new /obj/item/restraints/legcuffs/bola/cult(user))
	..()


/obj/item/paper/talisman
	var/cultist_name = "talisman"
	var/cultist_desc = "A basic talisman. It serves no purpose."
	var/invocation = "Naise meam!"
	var/uses = 1
	var/health_cost = 0 //The amount of health taken from the user when invoking the talisman
	var/creation_time = 100 //how long it takes an imbue rune to make this type of talisman

/obj/item/paper/talisman/examine(mob/user)
	if(iscultist(user) || user.stat == DEAD)
		to_chat(user, "<b>Name:</b> [cultist_name]")
		to_chat(user, "<b>Effect:</b> [cultist_desc]")
		to_chat(user, "<b>Uses Remaining:</b> [uses]")
	else
		to_chat(user, "<span class='danger'>There are indecipherable images scrawled on the paper in what looks to be... <i>blood?</i></span>")

/obj/item/paper/talisman/attack_self(mob/living/user)
	if(!iscultist(user))
		to_chat(user, "<span class='danger'>There are indecipherable images scrawled on the paper in what looks to be... <i>blood?</i></span>")
		return
	if(invoke(user))
		uses--
	if(uses <= 0)
		qdel(src)

/obj/item/paper/talisman/proc/invoke(mob/living/user, successfuluse = 1)
	. = successfuluse
	if(successfuluse) //if the calling whatever says we succeed, do the fancy stuff
		if(invocation)
			user.whisper(invocation, language = /datum/language/common)
		if(health_cost && iscarbon(user))
			var/mob/living/carbon/C = user
			C.apply_damage(health_cost, BRUTE, pick("l_arm", "r_arm"))



//Rite of Disorientation: Stuns and inhibit speech on a single target for quite some time
/obj/item/paper/talisman/stun
	cultist_name = "Talisman of Stunning"
	cultist_desc = "A talisman that will stun and inhibit speech on a single target. To use, attack target directly."
	color = "#ff0000" // red
	invocation = "Fuu ma'jin!"
	health_cost = 10

/obj/item/paper/talisman/stun/invoke(mob/living/user, successfuluse = 0)
	if(successfuluse) //if we're forced to be successful(we normally aren't) then do the normal stuff
		return ..()
	if(iscultist(user))
		to_chat(user, "<span class='warning'>To use this talisman, attack the target directly.</span>")
	else
		to_chat(user, "<span class='danger'>There are indecipherable images scrawled on the paper in what looks to be... <i>blood?</i></span>")
	return 0

/obj/item/paper/talisman/stun/attack(mob/living/target, mob/living/user, successfuluse = 1)
	if(iscultist(user))
		invoke(user, 1)
		user.visible_message("<span class='warning'>[user] holds up [src], which explodes in a flash of red light!</span>", \
							 "<span class='cultitalic'>You stun [target] with the talisman!</span>")
		var/obj/item/nullrod/N = locate() in target
		if(N)
			target.visible_message("<span class='warning'>[target]'s holy weapon absorbs the talisman's light!</span>", \
								   "<span class='userdanger'>Your holy weapon absorbs the blinding light!</span>")
		else
			target.Knockdown(200)
			target.flash_act(1,1)
			if(issilicon(target))
				var/mob/living/silicon/S = target
				S.emp_act(EMP_HEAVY)
			else if(iscarbon(target))
				var/mob/living/carbon/C = target
				C.silent += 5
				C.stuttering += 15
				C.cultslurring += 15
				C.Jitter(15)
			if(is_servant_of_ratvar(target))
				target.adjustBruteLoss(15)
		qdel(src)
		return
	..()

//Rite of Translocation: Same as rune
/obj/item/paper/talisman/teleport
	cultist_name = "Talisman of Teleportation"
	cultist_desc = "A single-use talisman that will teleport a user to a random rune of the same keyword."
	color = RUNE_COLOR_TELEPORT
	invocation = "Sas'so c'arta forbici!"
	health_cost = 5
	creation_time = 80

/obj/item/paper/talisman/teleport/invoke(mob/living/user, successfuluse = 1)
	var/list/potential_runes = list()
	var/list/teleportnames = list()
	for(var/R in GLOB.teleport_runes)
		var/obj/effect/rune/teleport/T = R
		potential_runes[avoid_assoc_duplicate_keys(T.listkey, teleportnames)] = T

	if(!potential_runes.len)
		to_chat(user, "<span class='warning'>There are no valid runes to teleport to!</span>")
		log_game("Teleport talisman failed - no other teleport runes")
		return ..(user, 0)

	if(user.z > ZLEVEL_SPACEMAX)
		to_chat(user, "<span class='cultitalic'>You are not in the right dimension!</span>")
		log_game("Teleport talisman failed - user in away mission")
		return ..(user, 0)

	var/input_rune_key = input(user, "Choose a rune to teleport to.", "Rune to Teleport to") as null|anything in potential_runes //we know what key they picked
	var/obj/effect/rune/teleport/actual_selected_rune = potential_runes[input_rune_key] //what rune does that key correspond to?
	if(!src || QDELETED(src) || !user || !user.is_holding(src) || user.incapacitated() || !actual_selected_rune)
		return ..(user, 0)
	var/turf/target = get_turf(actual_selected_rune)
	if(is_blocked_turf(target, TRUE))
		to_chat(user, "<span class='warning'>The target rune is blocked. Attempting to teleport to it would be massively unwise.</span>")
		return ..(user, 0)
	user.visible_message("<span class='warning'>Dust flows from [user]'s hand, and [user.p_they()] disappear[user.p_s()] with a sharp crack!</span>", \
	"<span class='cultitalic'>You speak the words of the talisman and find yourself somewhere else!</span>", "<i>You hear a sharp crack.</i>")
	user.forceMove(target)
	target.visible_message("<span class='warning'>There is a boom of outrushing air as something appears above the rune!</span>", null, "<i>You hear a boom.</i>")
	return ..()


/obj/item/paper/talisman/summon_tome
	cultist_name = "Talisman of Tome Summoning"
	cultist_desc = "A one-use talisman that will call an untranslated tome from the archives of the Geometer."
	color = "#512727" // red-black
	invocation = "N'ath reth sh'yro eth d'raggathnor!"
	health_cost = 1
	creation_time = 30

/obj/item/paper/talisman/summon_tome/invoke(mob/living/user, successfuluse = 1)
	. = ..()
	user.visible_message("<span class='warning'>[user]'s hand glows red for a moment.</span>", \
						 "<span class='cultitalic'>You speak the words of the talisman!</span>")
	new /obj/item/tome(get_turf(user))
	user.visible_message("<span class='warning'>A tome appears at [user]'s feet!</span>", \
			 "<span class='cultitalic'>An arcane tome materializes at your feet.</span>")

/obj/item/paper/talisman/true_sight
	cultist_name = "Talisman of Veiling"
	cultist_desc = "A multi-use talisman that hides nearby runes. On its second use, will reveal nearby runes."
	color = "#9c9c9c" // grey
	invocation = "Kla'atu barada nikt'o!"
	health_cost = 1
	creation_time = 30
	uses = 6
	var/revealing = FALSE //if it reveals or not

/obj/item/paper/talisman/true_sight/invoke(mob/living/user, successfuluse = 1)
	. = ..()
	if(!revealing)
		user.visible_message("<span class='warning'>Thin grey dust falls from [user]'s hand!</span>", \
			"<span class='cultitalic'>You speak the words of the talisman, hiding nearby runes.</span>")
		invocation = "Nikt'o barada kla'atu!"
		revealing = TRUE
		for(var/obj/effect/rune/R in range(5,user))
			R.conceal()
	else
		user.visible_message("<span class='warning'>A flash of light shines from [user]'s hand!</span>", \
			 "<span class='cultitalic'>You speak the words of the talisman, revealing nearby runes.</span>")
		for(var/obj/effect/rune/R in range(5,user))
			R.reveal()
		revealing = FALSE

//Rite of Disruption: Weaker than rune
/obj/item/paper/talisman/emp
	cultist_name = "Talisman of Electromagnetic Pulse"
	cultist_desc = "A talisman that will cause a moderately-sized electromagnetic pulse."
	color = "#4d94ff" // light blue
	invocation = "Ta'gh fara'qha fel d'amar det!"
	health_cost = 5

/obj/item/paper/talisman/emp/invoke(mob/living/user, successfuluse = 1)
	. = ..()
	user.visible_message("<span class='warning'>[user]'s hand flashes a bright blue!</span>", \
						 "<span class='cultitalic'>You speak the words of the talisman, emitting an EMP blast.</span>")
	empulse(src, 4, 8)

//Rite of Arming: Equips cultist armor on the user, where available
/obj/item/paper/talisman/armor
	cultist_name = "Talisman of Arming"
	cultist_desc = "A talisman that will equip the invoker with cultist equipment if there is a slot to equip it to."
	color = "#33cc33" // green
	invocation = "N'ath reth sh'yro eth draggathnor!"
	creation_time = 80

/obj/item/paper/talisman/armor/invoke(mob/living/user, successfuluse = 1)
	. = ..()
	user.visible_message("<span class='warning'>Otherworldly armor suddenly appears on [user]!</span>", \
						 "<span class='cultitalic'>You speak the words of the talisman, arming yourself!</span>")
	user.equip_to_slot_or_del(new /obj/item/clothing/head/culthood/alt(user), slot_head)
	user.equip_to_slot_or_del(new /obj/item/clothing/suit/cultrobes/alt(user), slot_wear_suit)
	user.equip_to_slot_or_del(new /obj/item/clothing/shoes/cult/alt(user), slot_shoes)
	user.equip_to_slot_or_del(new /obj/item/storage/backpack/cultpack(user), slot_back)
	user.dropItemToGround(src)
	user.put_in_hands(new /obj/item/melee/cultblade(user))
	user.put_in_hands(new /obj/item/restraints/legcuffs/bola/cult(user))

/obj/item/paper/talisman/armor/attack(mob/living/target, mob/living/user)
	if(iscultist(user) && iscultist(target))
		user.temporarilyRemoveItemFromInventory(src)
		invoke(target)
		qdel(src)
		return
	..()


//Talisman of Horrors: Breaks the mind of the victim with nightmarish hallucinations
/obj/item/paper/talisman/horror
	cultist_name = "Talisman of Horrors"
	cultist_desc = "A talisman that will break the mind of the victim with nightmarish hallucinations."
	color = "#ffb366" // light orange
	invocation = "Lo'Nab Na'Dm!"
	creation_time = 80

/obj/item/paper/talisman/horror/afterattack(mob/living/target, mob/living/user)
	if(iscultist(user) && (get_dist(user, target) < 7))
		if(iscarbon(target))
			to_chat(user, "<span class='cultitalic'>You disturb [target] with visions of madness!</span>")
			var/mob/living/carbon/H = target
			H.reagents.add_reagent("mindbreaker", 12)
			if(is_servant_of_ratvar(target))
				to_chat(target, "<span class='userdanger'>You see a brief but horrible vision of Ratvar, rusted and scrapped, being torn apart.</span>")
				target.emote("scream")
				target.confused = max(0, target.confused + 3)
				target.flash_act()
			qdel(src)

//Talisman of Fabrication: Creates a construct shell out of 25 metal sheets, or converts plasteel into runed metal up to 25 times
/obj/item/paper/talisman/construction
	cultist_name = "Talisman of Construction"
	cultist_desc = "Use this talisman on at least twenty-five metal sheets to create an empty construct shell"
	invocation = "Ethra p'ni dedol!"
	color = "#000000" // black
	uses = 25
	creation_time = 80

/obj/item/paper/talisman/construction/attack_self(mob/living/user)
	if(iscultist(user))
		to_chat(user, "<span class='warning'>To use this talisman, place it upon a stack of metal sheets.</span>")
	else
		to_chat(user, "<span class='danger'>There are indecipherable images scrawled on the paper in what looks to be... <i>blood?</i></span>")


/obj/item/paper/talisman/construction/attack(obj/M,mob/living/user)
	if(iscultist(user))
		to_chat(user, "<span class='cultitalic'>This talisman will only work on a stack of metal or plasteel sheets!</span>")
		log_game("Construct talisman failed - not a valid target")
	else
		..()

/obj/item/paper/talisman/construction/afterattack(obj/item/stack/sheet/target, mob/user, proximity_flag, click_parameters)
	..()
	if(proximity_flag && iscultist(user))
		var/turf/T = get_turf(target)
		if(istype(target, /obj/item/stack/sheet/metal))
			if(target.use(25))
				new /obj/structure/constructshell(T)
				to_chat(user, "<span class='warning'>The talisman clings to the metal and twists it into a construct shell!</span>")
				SEND_SOUND(user, sound('sound/effects/magic.ogg',0,1,25))
				invoke(user, 1)
				qdel(src)
			else
				to_chat(user, "<span class='warning'>You need more metal to produce a construct shell!</span>")
		else if(istype(target, /obj/item/stack/sheet/plasteel))
			var/quantity = min(target.amount, uses)
			uses -= quantity
			new /obj/item/stack/sheet/runed_metal(T,quantity)
			target.use(quantity)
			to_chat(user, "<span class='warning'>The talisman clings to the plasteel, transforming it into runed metal!</span>")
			SEND_SOUND(user, sound('sound/effects/magic.ogg',0,1,25))
			invoke(user, 1)
			if(uses <= 0)
				qdel(src)
		else
			to_chat(user, "<span class='warning'>The talisman must be used on metal or plasteel!</span>")


//Talisman of Shackling: Applies special cuffs directly from the talisman
/obj/item/paper/talisman/shackle
	cultist_name = "Talisman of Shackling"
	cultist_desc = "Use this talisman on a victim to handcuff them with dark bindings."
	invocation = "In'totum Lig'abis!"
	color = "#B27300" // burnt-orange
	uses = 6

/obj/item/paper/talisman/shackle/invoke(mob/living/user, successfuluse = 0)
	if(successfuluse) //if we're forced to be successful(we normally aren't) then do the normal stuff
		return ..()
	if(iscultist(user))
		to_chat(user, "<span class='warning'>To use this talisman, attack the target directly.</span>")
	else
		to_chat(user, "<span class='danger'>There are indecipherable images scrawled on the paper in what looks to be... <i>blood?</i></span>")
	return 0

/obj/item/paper/talisman/shackle/attack(mob/living/carbon/target, mob/living/user)
	if(iscultist(user) && istype(target))
		if(target.stat == DEAD)
			user.visible_message("<span class='cultitalic'>This talisman's magic does not affect the dead!</span>")
			return
		CuffAttack(target, user)
		return
	..()

/obj/item/paper/talisman/shackle/proc/CuffAttack(mob/living/carbon/C, mob/living/user)
	if(!C.handcuffed)
		invoke(user, 1)
		playsound(loc, 'sound/weapons/cablecuff.ogg', 30, 1, -2)
		C.visible_message("<span class='danger'>[user] begins restraining [C] with dark magic!</span>", \
								"<span class='userdanger'>[user] begins shaping a dark magic around your wrists!</span>")
		if(do_mob(user, C, 30))
			if(!C.handcuffed)
				C.handcuffed = new /obj/item/restraints/handcuffs/energy/cult/used(C)
				C.update_handcuffed()
				to_chat(user, "<span class='notice'>You shackle [C].</span>")
				add_logs(user, C, "handcuffed")
				uses--
			else
				to_chat(user, "<span class='warning'>[C] is already bound.</span>")
		else
			to_chat(user, "<span class='warning'>You fail to shackle [C].</span>")
	else
		to_chat(user, "<span class='warning'>[C] is already bound.</span>")
	if(uses <= 0)
		qdel(src)

/obj/item/restraints/handcuffs/energy/cult //For the shackling spell
	name = "shadow shackles"
	desc = "Shackles that bind the wrists with sinister magic."
	trashtype = /obj/item/restraints/handcuffs/energy/used
	flags_1 = DROPDEL_1

/obj/item/restraints/handcuffs/energy/cult/used/dropped(mob/user)
	user.visible_message("<span class='danger'>[user]'s shackles shatter in a discharge of dark magic!</span>", \
							"<span class='userdanger'>Your [src] shatters in a discharge of dark magic!</span>")
	. = ..()
