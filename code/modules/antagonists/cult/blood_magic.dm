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
	button.ordered = FALSE

/datum/action/innate/cult/blood_magic/Remove()
	for(var/X in spells)
		qdel(X)
	..()

/datum/action/innate/cult/blood_magic/IsAvailable()
	if(!iscultist(owner))
		return FALSE
	return ..()

/datum/action/innate/cult/blood_magic/proc/Positioning()
	var/list/screen_loc_split = splittext(button.screen_loc,",")
	var/list/screen_loc_X = splittext(screen_loc_split[1],":")
	var/list/screen_loc_Y = splittext(screen_loc_split[2],":")
	var/pix_X = text2num(screen_loc_X[2])
	for(var/datum/action/innate/cult/blood_spell/B in spells)
		if(B.button.locked)
			var/order = pix_X+spells.Find(B)*31
			B.button.screen_loc = "[screen_loc_X[1]]:[order],[screen_loc_Y[1]]:[screen_loc_Y[2]]"
			B.button.moved = B.button.screen_loc

/datum/action/innate/cult/blood_magic/Activate()
	var/rune = FALSE
	var/limit = RUNELESS_MAX_BLOODCHARGE
	for(var/obj/effect/rune/empower/R in range(1, owner))
		rune = TRUE
		break
	if(rune)
		limit = MAX_BLOODCHARGE
	if(spells.len >= limit)
		if(rune)
			to_chat(owner, "<span class='cultitalic'>Your body has reached its limit, you cannot store more than [MAX_BLOODCHARGE] spells at once. <b>Pick a spell to nullify.</b></span>")
		else
			to_chat(owner, "<span class='cultitalic'>Your body has reached its limit, <b><u>you cannot have more than [RUNELESS_MAX_BLOODCHARGE] spells at once without an empowering rune! Pick a spell to nullify.</b></u></span>")
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
	possible_spells += "(REMOVE SPELL)"
	entered_spell_name = input(owner, "Pick a blood spell to prepare...", "Spell Choices") as null|anything in possible_spells
	if(entered_spell_name == "(REMOVE SPELL)")
		var/nullify_spell = input(owner, "Choose a spell to remove.", "Current Spells") as null|anything in spells
		if(nullify_spell)
			qdel(nullify_spell)
		return
	BS = possible_spells[entered_spell_name]
	if(QDELETED(src) || owner.incapacitated() || !BS || (rune && !(locate(/obj/effect/rune/empower) in range(1, owner))) || (spells.len >= limit))
		return
	to_chat(owner,"<span class='warning'>You begin to carve unnatural symbols into your flesh!</span>")
	SEND_SOUND(owner, sound('sound/weapons/slice.ogg',0,1,10))
	if(!channeling)
		channeling = TRUE
	else
		to_chat(owner, "<span class='cultitalic'>You are already invoking blood magic!")
		return
	if(do_after(owner, 100 - rune*60, target = owner))
		if(ishuman(owner))
			var/mob/living/carbon/human/H = owner
			H.bleed(40 - rune*32)
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
	button.locked = TRUE
	button.ordered = FALSE

/datum/action/innate/cult/blood_spell/Remove()
	if(all_magic)
		all_magic.spells -= src
	if(hand_magic)
		qdel(hand_magic)
		hand_magic = null
	..()

/datum/action/innate/cult/blood_spell/IsAvailable()
	if(!iscultist(owner) || owner.incapacitated()  || !charges)
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
	health_cost = 7

/datum/action/innate/cult/blood_spell/emp
	name = "Electromagnetic Pulse"
	desc = "A large spell that immediately disables all electronics in the area."
	button_icon_state = "emp"
	health_cost = 10
	invocation = "Ta'gh fara'qha fel d'amar det!"

/datum/action/innate/cult/blood_spell/emp/Activate()
	owner.visible_message("<span class='warning'>[owner]'s hand flashes a bright blue!</span>", \
						 "<span class='cultitalic'>You speak the cursed words, emitting an EMP blast from your hand.</span>")
	empulse(owner, 3, 6)
	owner.whisper(invocation, language = /datum/language/common)
	charges--
	if(charges<=0)
		qdel(src)

/datum/action/innate/cult/blood_spell/shackles
	name = "Shadow Shackles"
	desc = "A stealthy spell that will handcuff and temporarily silence your victim."
	button_icon_state = "cuff"
	charges = 4
	magic_path = "/obj/item/melee/blood_magic/shackles"

/datum/action/innate/cult/blood_spell/construction
	name = "Twisted Construction"
	desc = "<u>A sinister spell used to convert:</u><br>Plasteel into runed metal<br>25 metal into a construct shell<br>Cyborgs directly into constructs<br>Cyborg shells into construct shells<br>Airlocks into runed airlocks (harm intent)"
	button_icon_state = "transmute"
	magic_path = "/obj/item/melee/blood_magic/construction"
	health_cost = 10

/datum/action/innate/cult/blood_spell/equipment
	name = "Summon Equipment"
	desc = "A crucial spell that enables you to summon either a ritual dagger or combat gear including armored robes, the nar'sien bola, and an eldritch longsword."
	button_icon_state = "equip"
	magic_path = "/obj/item/melee/blood_magic/armor"

/datum/action/innate/cult/blood_spell/equipment/Activate()
	var/choice = alert(owner,"Choose your equipment type",,"Combat Equipment","Ritual Dagger","Cancel")
	if(choice == "Ritual Dagger")
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
		desc = base_desc
		desc += "<br><b><u>Has [charges] use\s remaining</u></b>."
		if(charges<=0)
			qdel(src)
	else if(choice == "Combat Equipment")
		..()

/datum/action/innate/cult/blood_spell/horror
	name = "Hallucinations"
	desc = "A <u>ranged yet stealthy</u> spell that will break the mind of the victim with nightmarish hallucinations."
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
		H.hallucination = max(H.hallucination, 120)
		SEND_SOUND(ranged_ability_user, sound('sound/effects/ghost.ogg',0,1,50))
		var/image/C = image('icons/effects/cult_effects.dmi',H,"bloodsparkles", ABOVE_MOB_LAYER)
		add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/cult, "cult_apoc", C, FALSE)
		addtimer(CALLBACK(H,/atom/.proc/remove_alt_appearance,"cult_apoc",TRUE), 2400, TIMER_OVERRIDE|TIMER_UNIQUE)
		to_chat(ranged_ability_user,"<span class='cult'><b>[H] has been cursed with living nightmares!</b></span>")
		attached_action.charges--
		attached_action.desc = attached_action.base_desc
		attached_action.desc += "<br><b><u>Has [attached_action.charges] use\s remaining</u></b>."
		attached_action.UpdateButtonIcon()
		if(attached_action.charges <= 0)
			remove_ranged_ability("<span class='cult'>You have exhausted the spell's power!</span>")
			qdel(src)

/datum/action/innate/cult/blood_spell/veiling
	name = "Conceal Presence"
	desc = "A multi-function spell that alternates between hiding and revealing nearby cult runes, structures, turf, and airlocks."
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
		for(var/obj/machinery/door/airlock/cult/AL in range(5, owner))
			AL.conceal()
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
		for(var/obj/structure/destructible/cult/S in range(6,owner))
			S.reveal()
		for(var/turf/open/floor/engine/cult/T  in range(6,owner))
			T.realappearance.alpha = initial(T.realappearance.alpha)
		for(var/obj/machinery/door/airlock/cult/AL in range(6, owner))
			AL.reveal()
		revealing = FALSE
		name = "Conceal Runes"
		button_icon_state = "gone"
	if(charges<= 0)
		qdel(src)
	desc = base_desc
	desc += "<br><b><u>Has [charges] use\s remaining</u></b>."
	UpdateButtonIcon()

/datum/action/innate/cult/blood_spell/manipulation
	name = "Blood Rites"
	desc = "A complex spell that allows you to gather blood and use it for healing or other powerful spells."
	invocation = "Fel'th Dol Ab'orod!"
	button_icon_state = "manip"
	charges = 5
	magic_path = "/obj/item/melee/blood_magic/manipulator"


// The "magic hand" items
/obj/item/melee/blood_magic
	name = "\improper magical aura"
	desc = "Sinister looking aura that distorts the flow of reality around it."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "disintegrate"
	item_state = null
	item_flags = NEEDS_PERMIT | ABSTRACT | NODROP | DROPDEL

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
	if(!QDELETED(source))
		if(uses <= 0)
			source.hand_magic = null
			qdel(source)
			source = null
		else
			source.hand_magic = null
			source.charges = uses
			source.desc = source.base_desc
			source.desc += "<br><b><u>Has [uses] use\s remaining</u></b>."
			source.UpdateButtonIcon()
	..()

/obj/item/melee/blood_magic/attack_self(mob/living/user)
	afterattack(user, user, TRUE)

/obj/item/melee/blood_magic/attack(mob/living/M, mob/living/carbon/user)
	if(!iscarbon(user) || !iscultist(user))
		uses = 0
		qdel(src)
		return
	add_logs(user, M, "used a cult spell on", source.name, "")
	M.lastattacker = user.real_name
	M.lastattackerckey = user.ckey

/obj/item/melee/blood_magic/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(invocation)
		user.whisper(invocation, language = /datum/language/common)
	if(health_cost)
		if(user.active_hand_index == 1)
			user.apply_damage(health_cost, BRUTE, BODY_ZONE_L_ARM)
		else
			user.apply_damage(health_cost, BRUTE, BODY_ZONE_R_ARM)
	if(uses <= 0)
		qdel(src)
	else if(source)
		source.desc = source.base_desc
		source.desc += "<br><b><u>Has [uses] use\s remaining</u></b>."
		source.UpdateButtonIcon()

//Stun
/obj/item/melee/blood_magic/stun
	name = "Stunning Aura "
	color = "#ff0000" // red
	invocation = "Fuu ma'jin!"

/obj/item/melee/blood_magic/stun/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(!isliving(target) || !proximity)
		return
	var/mob/living/L = target
	if(iscultist(target))
		return
	if(iscultist(user))
		user.visible_message("<span class='warning'>[user] holds up [user.p_their()] hand, which explodes in a flash of red light!</span>", \
							 "<span class='cultitalic'>You stun [L] with the spell!</span>")
		var/obj/item/nullrod/N = locate() in L
		if(N)
			target.visible_message("<span class='warning'>[L]'s holy weapon absorbs the light!</span>", \
								   "<span class='userdanger'>Your holy weapon absorbs the blinding light!</span>")
		else
			L.Knockdown(160)
			L.flash_act(1,1)
			if(issilicon(target))
				var/mob/living/silicon/S = L
				S.emp_act(EMP_HEAVY)
			else if(iscarbon(target))
				var/mob/living/carbon/C = L
				C.silent += 6
				C.stuttering += 15
				C.cultslurring += 15
				C.Jitter(15)
			if(is_servant_of_ratvar(L))
				L.adjustBruteLoss(15)
		uses--
	..()

//Teleportation
/obj/item/melee/blood_magic/teleport
	name = "Shifting Aura"
	color = RUNE_COLOR_TELEPORT
	desc = "A potent spell that teleport cultists on contact."
	invocation = "Sas'so c'arta forbici!"

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

		var/turf/T = get_turf(src)
		if(is_away_level(T.z))
			to_chat(user, "<span class='cultitalic'>You are not in the right dimension!</span>")
			log_game("Teleport spell failed - user in away mission")
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
	name = "Binding Aura"
	desc = "Allows you to bind a victim and temporarily silence them."
	invocation = "In'totum Lig'abis!"
	color = "#000000" // black

/obj/item/melee/blood_magic/shackles/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(iscultist(user) && iscarbon(target) && proximity)
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
				C.silent += 5
				to_chat(user, "<span class='notice'>You shackle [C].</span>")
				add_logs(user, C, "shackled")
				uses--
			else
				to_chat(user, "<span class='warning'>[C] is already bound.</span>")
		else
			to_chat(user, "<span class='warning'>You fail to shackle [C].</span>")
	else
		to_chat(user, "<span class='warning'>[C] is already bound.</span>")


/obj/item/restraints/handcuffs/energy/cult //For the shackling spell
	name = "shadow shackles"
	desc = "Shackles that bind the wrists with sinister magic."
	trashtype = /obj/item/restraints/handcuffs/energy/used
	item_flags = DROPDEL

/obj/item/restraints/handcuffs/energy/cult/used/dropped(mob/user)
	user.visible_message("<span class='danger'>[user]'s shackles shatter in a discharge of dark magic!</span>", \
							"<span class='userdanger'>Your [src] shatters in a discharge of dark magic!</span>")
	. = ..()


//Construction: Creates a construct shell out of 50 metal sheets, or converts plasteel into runed metal
/obj/item/melee/blood_magic/construction
	name = "Corrupting Aura"
	desc = "Corrupts metal and plasteel into more sinister forms."
	invocation = "Ethra p'ni dedol!"
	color = "#000000" // black

/obj/item/melee/blood_magic/construction/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(proximity_flag && iscultist(user))
		var/turf/T = get_turf(target)
		if(istype(target, /obj/item/stack/sheet/metal))
			var/obj/item/stack/sheet/candidate = target
			if(candidate.use(50))
				uses--
				to_chat(user, "<span class='warning'>A dark cloud emanates from your hand and swirls around the metal, twisting it into a construct shell!</span>")
				new /obj/structure/constructshell(T)
				SEND_SOUND(user, sound('sound/effects/magic.ogg',0,1,25))
			else
				to_chat(user, "<span class='warning'>You need 50 metal to produce a construct shell!</span>")
		else if(istype(target, /obj/item/stack/sheet/plasteel))
			var/obj/item/stack/sheet/plasteel/candidate = target
			var/quantity = candidate.amount
			if(candidate.use(quantity))
				uses --
				new /obj/item/stack/sheet/runed_metal(T,quantity)
				to_chat(user, "<span class='warning'>A dark cloud emanates from you hand and swirls around the plasteel, transforming it into runed metal!</span>")
				SEND_SOUND(user, sound('sound/effects/magic.ogg',0,1,25))
		else if(istype(target,/mob/living/silicon/robot))
			var/mob/living/silicon/robot/candidate = target
			if(candidate.mmi)
				user.visible_message("<span class='danger'>A dark cloud emanates from [user]'s hand and swirls around [candidate]!</span>")
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
					uses--
					candidate.mmi = null
					qdel(candidate)
				else
					candidate.color = prev_color
			else
				uses--
				to_chat(user, "<span class='warning'>A dark cloud emanates from you hand and swirls around [candidate] - twisting it into a construct shell!</span>")
				new /obj/structure/constructshell(T)
				SEND_SOUND(user, sound('sound/effects/magic.ogg',0,1,25))
		else if(istype(target,/obj/machinery/door/airlock))
			target.narsie_act()
			uses--
			user.visible_message("<span class='warning'>Black ribbons suddenly eminate from [user]'s hand and cling to the airlock - twisting and corrupting it!</span>")
			SEND_SOUND(user, sound('sound/effects/magic.ogg',0,1,25))
		else
			to_chat(user, "<span class='warning'>The spell will not work on [target]!</span>")
			return
		..()

//Armor: Gives the target a basic cultist combat loadout
/obj/item/melee/blood_magic/armor
	name = "Bladed Aura"
	desc = "A spell that will equip the target with cultist equipment if there is a slot to equip it to."
	color = "#33cc33" // green

/obj/item/melee/blood_magic/armor/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(iscarbon(target) && proximity)
		uses--
		var/mob/living/carbon/C = target
		C.visible_message("<span class='warning'>Otherworldly armor suddenly appears on [C]!</span>")
		C.equip_to_slot_or_del(new /obj/item/clothing/under/color/black,SLOT_W_UNIFORM)
		C.equip_to_slot_or_del(new /obj/item/clothing/head/culthood/alt(user), SLOT_HEAD)
		C.equip_to_slot_or_del(new /obj/item/clothing/suit/cultrobes/alt(user), SLOT_WEAR_SUIT)
		C.equip_to_slot_or_del(new /obj/item/clothing/shoes/cult/alt(user), SLOT_SHOES)
		C.equip_to_slot_or_del(new /obj/item/storage/backpack/cultpack(user), SLOT_BACK)
		if(C == user)
			qdel(src) //Clears the hands
		C.put_in_hands(new /obj/item/melee/cultblade(user))
		C.put_in_hands(new /obj/item/restraints/legcuffs/bola/cult(user))
		..()

/obj/item/melee/blood_magic/manipulator
	name = "Ritual Aura"
	desc = "A spell that will absorb blood from anything you touch.<br>Touching cultists and constructs can heal them.<br><b>Clicking the hand will potentially let you focus the spell into something stronger.</b>"
	color = "#7D1717"

/obj/item/melee/blood_magic/manipulator/afterattack(atom/target, mob/living/carbon/human/user, proximity)
	if(proximity)
		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			if(NOBLOOD in H.dna.species.species_traits)
				to_chat(user,"<span class='warning'>Blood rites do not work on species with no blood!</span>")
				return
			if(iscultist(H))
				if(H.stat == DEAD)
					to_chat(user,"<span class='warning'>Only a revive rune can bring back the dead!</span>")
					return
				if(H.blood_volume < BLOOD_VOLUME_SAFE)
					var/restore_blood = BLOOD_VOLUME_SAFE - H.blood_volume
					if(uses*2 < restore_blood)
						H.blood_volume += uses*2
						to_chat(user,"<span class='danger'>You use the last of your blood rites to restore what blood you could!</span>")
						uses = 0
						return ..()
					else
						H.blood_volume = BLOOD_VOLUME_SAFE
						uses -= round(restore_blood/2)
						to_chat(user,"<span class='warning'>Your blood rites have restored [H == user ? "your" : "[H.p_their()]"] blood to safe levels!</span>")
				var/overall_damage = H.getBruteLoss() + H.getFireLoss() + H.getToxLoss() + H.getOxyLoss()
				if(overall_damage == 0)
					to_chat(user,"<span class='cult'>That cultist doesn't require healing!</span>")
				else
					var/ratio = uses/overall_damage
					if(H == user)
						to_chat(user,"<span class='cult'><b>Your blood healing is far less efficient when used on yourself!</b></span>")
						ratio *= 0.35 // Healing is half as effective if you can't perform a full heal
						uses -= round(overall_damage) // Healing is 65% more "expensive" even if you can still perform the full heal
					if(ratio>1)
						ratio = 1
						uses -= round(overall_damage)
						H.visible_message("<span class='warning'>[H] is fully healed by [H==user ? "[H.p_their()]":"[H]'s"]'s blood magic!</span>")
					else
						H.visible_message("<span class='warning'>[H] is partially healed by [H==user ? "[H.p_their()]":"[H]'s"] blood magic.</span>")
						uses = 0
					ratio *= -1
					H.adjustOxyLoss((overall_damage*ratio) * (H.getOxyLoss() / overall_damage), 0)
					H.adjustToxLoss((overall_damage*ratio) * (H.getToxLoss() / overall_damage), 0)
					H.adjustFireLoss((overall_damage*ratio) * (H.getFireLoss() / overall_damage), 0)
					H.adjustBruteLoss((overall_damage*ratio) * (H.getBruteLoss() / overall_damage), 0)
					H.updatehealth()
					playsound(get_turf(H), 'sound/magic/staff_healing.ogg', 25)
					new /obj/effect/temp_visual/cult/sparks(get_turf(H))
					user.Beam(H,icon_state="sendbeam",time=15)
			else
				if(H.stat == DEAD)
					to_chat(user,"<span class='warning'>[H.p_their(TRUE)] blood has stopped flowing, you'll have to find another way to extract it.</span>")
					return
				if(H.cultslurring)
					to_chat(user,"<span class='danger'>[H.p_their(TRUE)] blood has been tainted by an even stronger form of blood magic, it's no use to us like this!</span>")
					return
				if(H.blood_volume > BLOOD_VOLUME_SAFE)
					H.blood_volume -= 100
					uses += 50
					user.Beam(H,icon_state="drainbeam",time=10)
					playsound(get_turf(H), 'sound/magic/enter_blood.ogg', 50)
					H.visible_message("<span class='danger'>[user] has drained some of [H]'s blood!</span>")
					to_chat(user,"<span class='cultitalic'>Your blood rite gains 50 charges from draining [H]'s blood.</span>")
					new /obj/effect/temp_visual/cult/sparks(get_turf(H))
				else
					to_chat(user,"<span class='danger'>[H.p_theyre(TRUE)] missing too much blood - you cannot drain [H.p_them()] further!</span>")
					return
		if(isconstruct(target))
			var/mob/living/simple_animal/M = target
			var/missing = M.maxHealth - M.health
			if(missing)
				if(uses > missing)
					M.adjustHealth(-missing)
					M.visible_message("<span class='warning'>[M] is fully healed by [user]'s blood magic!</span>")
					uses -= missing
				else
					M.adjustHealth(-uses)
					M.visible_message("<span class='warning'>[M] is partially healed by [user]'s blood magic!</span>")
					uses = 0
				playsound(get_turf(M), 'sound/magic/staff_healing.ogg', 25)
				user.Beam(M,icon_state="sendbeam",time=10)
		if(istype(target, /obj/effect/decal/cleanable/blood))
			blood_draw(target, user)
		..()

/obj/item/melee/blood_magic/manipulator/proc/blood_draw(atom/target, mob/living/carbon/human/user)
	var/temp = 0
	var/turf/T = get_turf(target)
	if(T)
		for(var/obj/effect/decal/cleanable/blood/B in view(T, 2))
			if(B.blood_state == "blood")
				if(B.bloodiness == 100) //Bonus for "pristine" bloodpools, also to prevent cheese with footprint spam
					temp += 30
				else
					temp += max((B.bloodiness**2)/800,1)
				new /obj/effect/temp_visual/cult/turf/floor(get_turf(B))
				qdel(B)
		for(var/obj/effect/decal/cleanable/trail_holder/TH in view(T, 2))
			qdel(TH)
		var/obj/item/clothing/shoes/shoecheck = user.shoes
		if(shoecheck && shoecheck.bloody_shoes["blood"])
			temp += shoecheck.bloody_shoes["blood"]/20
			shoecheck.bloody_shoes["blood"] = 0
		if(temp)
			user.Beam(T,icon_state="drainbeam",time=15)
			new /obj/effect/temp_visual/cult/sparks(get_turf(user))
			playsound(T, 'sound/magic/enter_blood.ogg', 50)
			to_chat(user, "<span class='cultitalic'>Your blood rite has gained [round(temp)] charge\s from blood sources around you!</span>")
			uses += max(1, round(temp))

/obj/item/melee/blood_magic/manipulator/attack_self(mob/living/user)
	if(iscultist(user))
		var/list/options = list("Blood Spear (150)", "Blood Bolt Barrage (300)", "Blood Beam (500)")
		var/choice = input(user, "Choose a greater blood rite...", "Greater Blood Rites") as null|anything in options
		if(!choice)
			to_chat(user, "<span class='cultitalic'>You decide against conducting a greater blood rite.</span>")
			return
		switch(choice)
			if("Blood Spear (150)")
				if(uses < 150)
					to_chat(user, "<span class='cultitalic'>You need 200 charges to perform this rite.</span>")
				else
					uses -= 150
					var/turf/T = get_turf(user)
					qdel(src)
					var/datum/action/innate/cult/spear/S = new(user)
					var/obj/item/twohanded/cult_spear/rite = new(T)
					S.Grant(user, rite)
					rite.spear_act = S
					if(user.put_in_hands(rite))
						to_chat(user, "<span class='cultitalic'>A [rite.name] appears in your hand!</span>")
					else
						user.visible_message("<span class='warning'>A [rite.name] appears at [user]'s feet!</span>", \
							 "<span class='cultitalic'>A [rite.name] materializes at your feet.</span>")
			if("Blood Bolt Barrage (300)")
				if(uses < 300)
					to_chat(user, "<span class='cultitalic'>You need 400 charges to perform this rite.</span>")
				else
					var/obj/rite = new /obj/item/gun/ballistic/shotgun/boltaction/enchanted/arcane_barrage/blood()
					uses -= 300
					qdel(src)
					if(user.put_in_hands(rite))
						to_chat(user, "<span class='cult'><b>Your hands glow with power!</b></span>")
					else
						to_chat(user, "<span class='cultitalic'>You need a free hand for this rite!</span>")
						qdel(rite)
			if("Blood Beam (500)")
				if(uses < 500)
					to_chat(user, "<span class='cultitalic'>You need 600 charges to perform this rite.</span>")
				else
					var/obj/rite = new /obj/item/blood_beam()
					uses -= 500
					qdel(src)
					if(user.put_in_hands(rite))
						to_chat(user, "<span class='cultlarge'><b>Your hands glow with POWER OVERWHELMING!!!</b></span>")
					else
						to_chat(user, "<span class='cultitalic'>You need a free hand for this rite!</span>")
						qdel(rite)
