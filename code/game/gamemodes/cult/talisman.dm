/obj/item/weapon/paper/talisman
	var/cultist_name = "talisman"
	var/cultist_desc = "A basic talisman. It serves no purpose."
	var/invocation = "Naise meam!"
	var/uses = 1
	var/health_cost = 0 //The amount of health taken from the user when invoking the talisman
	var/creation_time = 100 //how long it takes an imbue rune to make this type of talisman

/obj/item/weapon/paper/talisman/examine(mob/user)
	if(iscultist(user) || user.stat == DEAD)
		to_chat(user, "<b>Name:</b> [cultist_name]")
		to_chat(user, "<b>Effect:</b> [cultist_desc]")
		to_chat(user, "<b>Uses Remaining:</b> [uses]")
	else
		to_chat(user, "<span class='danger'>There are indecipherable images scrawled on the paper in what looks to be... <i>blood?</i></span>")

/obj/item/weapon/paper/talisman/attack_self(mob/living/user)
	if(!iscultist(user))
		to_chat(user, "<span class='danger'>There are indecipherable images scrawled on the paper in what looks to be... <i>blood?</i></span>")
		return
	if(invoke(user))
		uses--
	if(uses <= 0)
		user.drop_item()
		qdel(src)

/obj/item/weapon/paper/talisman/proc/invoke(mob/living/user, successfuluse = 1)
	. = successfuluse
	if(successfuluse) //if the calling whatever says we succeed, do the fancy stuff
		if(invocation)
			user.whisper(invocation, language = /datum/language/common)
		if(health_cost && iscarbon(user))
			var/mob/living/carbon/C = user
			C.apply_damage(health_cost, BRUTE, pick("l_arm", "r_arm"))

//Malformed Talisman: If something goes wrong.
/obj/item/weapon/paper/talisman/malformed
	cultist_name = "malformed talisman"
	cultist_desc = "A talisman with gibberish scrawlings. No good can come from invoking this."
	invocation = "Ra'sha yoka!"

/obj/item/weapon/paper/talisman/malformed/invoke(mob/living/user, successfuluse = 1)
	to_chat(user, "<span class='cultitalic'>You feel a pain in your head. The Geometer is displeased.</span>")
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		C.apply_damage(10, BRUTE, "head")

//Rite of Translocation: Same as rune
/obj/item/weapon/paper/talisman/teleport
	cultist_name = "Talisman of Teleportation"
	cultist_desc = "A single-use talisman that will teleport a user to a random rune of the same keyword."
	color = RUNE_COLOR_TELEPORT
	invocation = "Sas'so c'arta forbici!"
	health_cost = 5
	creation_time = 80

/obj/item/weapon/paper/talisman/teleport/invoke(mob/living/user, successfuluse = 1)
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
	user.visible_message("<span class='warning'>Dust flows from [user]'s hand, and [user.p_they()] disappear with a sharp crack!</span>", \
	"<span class='cultitalic'>You speak the words of the talisman and find yourself somewhere else!</span>", "<i>You hear a sharp crack.</i>")
	user.forceMove(target)
	target.visible_message("<span class='warning'>There is a boom of outrushing air as something appears above the rune!</span>", null, "<i>You hear a boom.</i>")
	return ..()


/obj/item/weapon/paper/talisman/summon_tome
	cultist_name = "Talisman of Tome Summoning"
	cultist_desc = "A one-use talisman that will call an untranslated tome from the archives of the Geometer."
	color = "#512727" // red-black
	invocation = "N'ath reth sh'yro eth d'raggathnor!"
	health_cost = 1
	creation_time = 30

/obj/item/weapon/paper/talisman/summon_tome/invoke(mob/living/user, successfuluse = 1)
	. = ..()
	user.visible_message("<span class='warning'>[user]'s hand glows red for a moment.</span>", \
						 "<span class='cultitalic'>You speak the words of the talisman!</span>")
	new /obj/item/weapon/tome(get_turf(user))
	user.visible_message("<span class='warning'>A tome appears at [user]'s feet!</span>", \
			 "<span class='cultitalic'>An arcane tome materializes at your feet.</span>")

/obj/item/weapon/paper/talisman/true_sight
	cultist_name = "Talisman of Veiling"
	cultist_desc = "A multi-use talisman that hides nearby runes. On its second use, will reveal nearby runes."
	color = "#9c9c9c" // grey
	invocation = "Kla'atu barada nikt'o!"
	health_cost = 1
	creation_time = 30
	uses = 6
	var/revealing = FALSE //if it reveals or not

/obj/item/weapon/paper/talisman/true_sight/invoke(mob/living/user, successfuluse = 1)
	. = ..()
	if(!revealing)
		user.visible_message("<span class='warning'>Thin grey dust falls from [user]'s hand!</span>", \
			"<span class='cultitalic'>You speak the words of the talisman, hiding nearby runes.</span>")
		invocation = "Nikt'o barada kla'atu!"
		revealing = TRUE
		for(var/obj/effect/rune/R in range(4,user))
			R.talismanhide()
	else
		user.visible_message("<span class='warning'>A flash of light shines from [user]'s hand!</span>", \
			 "<span class='cultitalic'>You speak the words of the talisman, revealing nearby runes.</span>")
		for(var/obj/effect/rune/R in range(3,user))
			R.talismanreveal()

//Rite of Disruption: Weaker than rune
/obj/item/weapon/paper/talisman/emp
	cultist_name = "Talisman of Electromagnetic Pulse"
	cultist_desc = "A talisman that will cause a moderately-sized electromagnetic pulse."
	color = "#4d94ff" // light blue
	invocation = "Ta'gh fara'qha fel d'amar det!"
	health_cost = 5

/obj/item/weapon/paper/talisman/emp/invoke(mob/living/user, successfuluse = 1)
	. = ..()
	user.visible_message("<span class='warning'>[user]'s hand flashes a bright blue!</span>", \
						 "<span class='cultitalic'>You speak the words of the talisman, emitting an EMP blast.</span>")
	empulse(src, 4, 8)


//Rite of Disorientation: Stuns and inhibit speech on a single target for quite some time
/obj/item/weapon/paper/talisman/stun
	cultist_name = "Talisman of Stunning"
	cultist_desc = "A talisman that will stun and inhibit speech on a single target. To use, attack target directly."
	color = "#ff0000" // red
	invocation = "Fuu ma'jin!"
	health_cost = 10

/obj/item/weapon/paper/talisman/stun/invoke(mob/living/user, successfuluse = 0)
	if(successfuluse) //if we're forced to be successful(we normally aren't) then do the normal stuff
		return ..()
	if(iscultist(user))
		to_chat(user, "<span class='warning'>To use this talisman, attack the target directly.</span>")
	else
		to_chat(user, "<span class='danger'>There are indecipherable images scrawled on the paper in what looks to be... <i>blood?</i></span>")
	return 0

/obj/item/weapon/paper/talisman/stun/attack(mob/living/target, mob/living/user, successfuluse = 1)
	if(iscultist(user))
		invoke(user, 1)
		user.visible_message("<span class='warning'>[user] holds up [src], which explodes in a flash of red light!</span>", \
							 "<span class='cultitalic'>You stun [target] with the talisman!</span>")
		var/obj/item/weapon/nullrod/N = locate() in target
		if(N)
			target.visible_message("<span class='warning'>[target]'s holy weapon absorbs the talisman's light!</span>", \
								   "<span class='userdanger'>Your holy weapon absorbs the blinding light!</span>")
		else
			target.Weaken(10)
			target.Stun(10)
			target.flash_act(1,1)
			if(issilicon(target))
				var/mob/living/silicon/S = target
				S.emp_act(1)
			else if(iscarbon(target))
				var/mob/living/carbon/C = target
				C.silent += 5
				C.stuttering += 15
				C.cultslurring += 15
				C.Jitter(15)
			if(is_servant_of_ratvar(target))
				target.adjustBruteLoss(15)
		user.drop_item()
		qdel(src)
		return
	..()


//Rite of Arming: Equips cultist armor on the user, where available
/obj/item/weapon/paper/talisman/armor
	cultist_name = "Talisman of Arming"
	cultist_desc = "A talisman that will equip the invoker with cultist equipment if there is a slot to equip it to."
	color = "#33cc33" // green
	invocation = "N'ath reth sh'yro eth draggathnor!"
	creation_time = 80

/obj/item/weapon/paper/talisman/armor/invoke(mob/living/user, successfuluse = 1)
	. = ..()
	user.visible_message("<span class='warning'>Otherworldly armor suddenly appears on [user]!</span>", \
						 "<span class='cultitalic'>You speak the words of the talisman, arming yourself!</span>")
	user.equip_to_slot_or_del(new /obj/item/clothing/head/culthood/alt(user), slot_head)
	user.equip_to_slot_or_del(new /obj/item/clothing/suit/cultrobes/alt(user), slot_wear_suit)
	user.equip_to_slot_or_del(new /obj/item/clothing/shoes/cult/alt(user), slot_shoes)
	user.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/cultpack(user), slot_back)
	user.drop_item()
	user.put_in_hands(new /obj/item/weapon/melee/cultblade(user))
	user.put_in_hands(new /obj/item/weapon/restraints/legcuffs/bola/cult(user))

/obj/item/weapon/paper/talisman/armor/attack(mob/living/target, mob/living/user)
	if(iscultist(user) && iscultist(target))
		user.drop_item()
		invoke(target)
		qdel(src)
		return
	..()


//Talisman of Horrors: Breaks the mind of the victim with nightmarish hallucinations
/obj/item/weapon/paper/talisman/horror
	cultist_name = "Talisman of Horrors"
	cultist_desc = "A talisman that will break the mind of the victim with nightmarish hallucinations."
	color = "#ffb366" // light orange
	invocation = "Lo'Nab Na'Dm!"
	creation_time = 80

/obj/item/weapon/paper/talisman/horror/afterattack(mob/living/target, mob/living/user)
	if(iscultist(user) && (get_dist(user, target) < 7))
		to_chat(user, "<span class='cultitalic'>You disturb [target] with visions of madness!</span>")
		if(iscarbon(target))
			var/mob/living/carbon/H = target
			H.reagents.add_reagent("mindbreaker", 12)
			if(is_servant_of_ratvar(target))
				to_chat(target, "<span class='userdanger'>You see a brief but horrible vision of Ratvar, rusted and scrapped, being torn apart.</span>")
				target.emote("scream")
				target.confused = max(0, target.confused + 3)
				target.flash_act()
		qdel(src)


//Talisman of Fabrication: Creates a construct shell out of 25 metal sheets, or converts plasteel into runed metal up to 25 times
/obj/item/weapon/paper/talisman/construction
	cultist_name = "Talisman of Construction"
	cultist_desc = "Use this talisman on at least twenty-five metal sheets to create an empty construct shell"
	invocation = "Ethra p'ni dedol!"
	color = "#000000" // black
	uses = 25
	creation_time = 80

/obj/item/weapon/paper/talisman/construction/attack_self(mob/living/user)
	if(iscultist(user))
		to_chat(user, "<span class='warning'>To use this talisman, place it upon a stack of metal sheets.</span>")
	else
		to_chat(user, "<span class='danger'>There are indecipherable images scrawled on the paper in what looks to be... <i>blood?</i></span>")


/obj/item/weapon/paper/talisman/construction/attack(obj/M,mob/living/user)
	if(iscultist(user))
		to_chat(user, "<span class='cultitalic'>This talisman will only work on a stack of metal or plasteel sheets!</span>")
		log_game("Construct talisman failed - not a valid target")
	else
		..()

/obj/item/weapon/paper/talisman/construction/afterattack(obj/item/stack/sheet/target, mob/user, proximity_flag, click_parameters)
	..()
	if(proximity_flag && iscultist(user))
		var/turf/T = get_turf(target)
		if(istype(target, /obj/item/stack/sheet/metal))
			if(target.use(25))
				new /obj/structure/constructshell(T)
				to_chat(user, "<span class='warning'>The talisman clings to the metal and twists it into a construct shell!</span>")
				user << sound('sound/effects/magic.ogg',0,1,25)
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
			user << sound('sound/effects/magic.ogg',0,1,25)
			invoke(user, 1)
			if(uses <= 0)
				qdel(src)
		else
			to_chat(user, "<span class='warning'>The talisman must be used on metal or plasteel!</span>")


//Talisman of Shackling: Applies special cuffs directly from the talisman
/obj/item/weapon/paper/talisman/shackle
	cultist_name = "Talisman of Shackling"
	cultist_desc = "Use this talisman on a victim to handcuff them with dark bindings."
	invocation = "In'totum Lig'abis!"
	color = "#B27300" // burnt-orange
	uses = 6

/obj/item/weapon/paper/talisman/shackle/invoke(mob/living/user, successfuluse = 0)
	if(successfuluse) //if we're forced to be successful(we normally aren't) then do the normal stuff
		return ..()
	if(iscultist(user))
		to_chat(user, "<span class='warning'>To use this talisman, attack the target directly.</span>")
	else
		to_chat(user, "<span class='danger'>There are indecipherable images scrawled on the paper in what looks to be... <i>blood?</i></span>")
	return 0

/obj/item/weapon/paper/talisman/shackle/attack(mob/living/carbon/target, mob/living/user)
	if(iscultist(user) && istype(target))
		if(target.stat == DEAD)
			user.visible_message("<span class='cultitalic'>This talisman's magic does not affect the dead!</span>")
			return
		CuffAttack(target, user)
		return
	..()

/obj/item/weapon/paper/talisman/shackle/proc/CuffAttack(mob/living/carbon/C, mob/living/user)
	if(!C.handcuffed)
		invoke(user, 1)
		playsound(loc, 'sound/weapons/cablecuff.ogg', 30, 1, -2)
		C.visible_message("<span class='danger'>[user] begins restraining [C] with dark magic!</span>", \
								"<span class='userdanger'>[user] begins shaping a dark magic around your wrists!</span>")
		if(do_mob(user, C, 30))
			if(!C.handcuffed)
				C.handcuffed = new /obj/item/weapon/restraints/handcuffs/energy/cult/used(C)
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
		user.drop_item()
		qdel(src)

/obj/item/weapon/restraints/handcuffs/energy/cult //For the talisman of shackling
	name = "cult shackles"
	desc = "Shackles that bind the wrists with sinister magic."
	trashtype = /obj/item/weapon/restraints/handcuffs/energy/used
	origin_tech = "materials=2;magnets=5"
	flags = DROPDEL

/obj/item/weapon/restraints/handcuffs/energy/cult/used/dropped(mob/user)
	user.visible_message("<span class='danger'>[user]'s shackles shatter in a discharge of dark magic!</span>", \
							"<span class='userdanger'>Your [src] shatters in a discharge of dark magic!</span>")
	. = ..()
