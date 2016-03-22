
var/list/parasites = list() //all currently existing/living guardians

/mob/living/simple_animal/hostile/guardian
	name = "Guardian Spirit"
	real_name = "Guardian Spirit"
	desc = "A mysterious being that stands by its charge, ever vigilant."
	speak_emote = list("hisses")
	bubble_icon = "guardian"
	response_help  = "passes through"
	response_disarm = "flails at"
	response_harm   = "punches"
	icon = 'icons/mob/guardian.dmi'
	icon_state = "magicOrange"
	icon_living = "magicOrange"
	icon_dead = "magicOrange"
	speed = 0
	a_intent = "harm"
	stop_automated_movement = 1
	floating = 1
	attack_sound = 'sound/weapons/punch1.ogg'
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY
	attacktext = "punches"
	maxHealth = INFINITY //The spirit itself is invincible
	health = INFINITY
	damage_coeff = list(BRUTE = 0.5, BURN = 0.5, TOX = 0.5, CLONE = 0.5, STAMINA = 0, OXY = 0.5) //how much damage from each damage type we transfer to the owner
	environment_smash = 1
	melee_damage_lower = 15
	melee_damage_upper = 15
	butcher_results = list(/obj/item/weapon/ectoplasm = 1)
	AIStatus = AI_OFF
	var/cooldown = 0
	var/mob/living/summoner
	var/range = 10 //how far from the user the spirit can be
	var/playstyle_string = "You are a standard Guardian. You shouldn't exist!"
	var/magic_fluff_string = " You draw the Coder, symbolizing bugs and errors. This shouldn't happen! Submit a bug report!"
	var/tech_fluff_string = "BOOT SEQUENCE COMPLETE. ERROR MODULE LOADED. THIS SHOULDN'T HAPPEN. Submit a bug report!"

/mob/living/simple_animal/hostile/guardian/New()
	parasites |= src
	..()

/mob/living/simple_animal/hostile/guardian/Destroy()
	parasites -= src
	return ..()

/mob/living/simple_animal/hostile/guardian/Life() //Dies if the summoner dies
	..()
	update_health_hud() //we need to update our health display to match our summoner and we can't practically give the summoner a hook to do it
	if(summoner)
		if(summoner.stat == DEAD)
			src << "<span class='danger'>Your summoner has died!</span>"
			visible_message("<span class='danger'><B>\The [src] dies along with its user!</B></span>")
			summoner.visible_message("<span class='danger'><B>[summoner]'s body is completely consumed by the strain of sustaining [src]!</B></span>")
			for(var/obj/item/W in summoner)
				if(!summoner.unEquip(W))
					qdel(W)
			summoner.dust()
			ghostize()
			qdel(src)
	/*else
		src << "<span class='danger'>Your summoner has died!</span>"
		visible_message("<span class='danger'><B>The [src] dies along with its user!</B></span>")
		ghostize()
		qdel(src)*/
	snapback()

/mob/living/simple_animal/hostile/guardian/Move() //Returns to summoner if they move out of range
	. = ..()
	snapback()

/mob/living/simple_animal/hostile/guardian/proc/snapback()
	if(summoner)
		if(get_dist(get_turf(summoner),get_turf(src)) <= range)
			return
		else
			src << "You moved out of range, and were pulled back! You can only move [range] meters from [summoner.real_name]!"
			visible_message("<span class='danger'>\The [src] jumps back to its user.</span>")
			PoolOrNew(/obj/effect/overlay/temp/guardian/phase/out, get_turf(src))
			forceMove(get_turf(summoner))
			PoolOrNew(/obj/effect/overlay/temp/guardian/phase, get_turf(src))

/mob/living/simple_animal/hostile/guardian/canSuicide()
	return 0

/mob/living/simple_animal/hostile/guardian/AttackingTarget()
	if(src.loc == summoner)
		src << "<span class='danger'><B>You must be manifested to attack!</span></B>"
		return 0
	else
		..()
		return 1

/mob/living/simple_animal/hostile/guardian/death()
	..()
	summoner << "<span class='danger'><B>Your [name] died somehow!</span></B>"
	summoner.death()

/mob/living/simple_animal/hostile/guardian/update_health_hud()
	if(summoner && hud_used && hud_used.healths)
		var/resulthealth
		if(iscarbon(summoner))
			resulthealth = round((abs(config.health_threshold_dead - summoner.health) / abs(config.health_threshold_dead - summoner.maxHealth)) * 100)
		else
			resulthealth = round((summoner.health / summoner.maxHealth) * 100)
		hud_used.healths.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#efeeef'>[resulthealth]%</font></div>"

/mob/living/simple_animal/hostile/guardian/adjustHealth(amount) //The spirit is invincible, but passes on damage to the summoner
	. =  ..()
	if(summoner)
		if(loc == summoner)
			return 0
		summoner.adjustBruteLoss(amount)
		if(amount)
			summoner << "<span class='danger'><B>Your [name] is under attack! You take damage!</span></B>"
			summoner.visible_message("<span class='danger'><B>Blood sprays from [summoner] as [src] takes damage!</B></span>")
		if(summoner.stat == UNCONSCIOUS)
			summoner << "<span class='danger'><B>Your body can't take the strain of sustaining [src] in this condition, it begins to fall apart!</span></B>"
			summoner.adjustCloneLoss(amount*0.5) //dying hosts take 50% bonus damage as cloneloss
		update_health_hud()

/mob/living/simple_animal/hostile/guardian/ex_act(severity, target)
	switch(severity)
		if(1)
			gib()
			return
		if(2)
			adjustBruteLoss(60)
		if(3)
			adjustBruteLoss(30)

/mob/living/simple_animal/hostile/guardian/gib()
	if(summoner)
		summoner << "<span class='danger'><B>Your [src] was blown up!</span></B>"
		summoner.gib()
	ghostize()
	qdel(src)

//Manifest, Recall, Communicate

/mob/living/simple_animal/hostile/guardian/proc/Manifest()
	if(cooldown > world.time)
		return 0
	if(loc == summoner)
		forceMove(get_turf(summoner))
		PoolOrNew(/obj/effect/overlay/temp/guardian/phase, get_turf(src))
		cooldown = world.time + 10
		return 1
	return 0

/mob/living/simple_animal/hostile/guardian/proc/Recall()
	if(loc == summoner || cooldown > world.time)
		return 0
	PoolOrNew(/obj/effect/overlay/temp/guardian/phase/out, get_turf(src))

	forceMove(summoner)
	cooldown = world.time + 10
	return 1

/mob/living/simple_animal/hostile/guardian/proc/Communicate()
	var/input = stripped_input(src, "Please enter a message to tell your summoner.", "Guardian", "")
	if(!input) return

	var/my_message = "<span class='boldannounce'><i>[src]:</i> [input]</span>"
	for(var/mob/M in mob_list)
		if(M == summoner)
			M << my_message
		if(M in dead_mob_list)
			M << "<a href='?src=\ref[M];follow=\ref[src]'>(F)</a> [my_message]"
	src << "[my_message]"
	log_say("[src.real_name]/[src.key] : [input]")

/mob/living/simple_animal/hostile/guardian/proc/ToggleMode()
	src << "<span class='danger'><B>You don't have another mode!</span></B>"


/mob/living/proc/guardian_comm()
	set name = "Communicate"
	set category = "Guardian"
	set desc = "Communicate telepathically with your guardian."
	var/input = stripped_input(src, "Please enter a message to tell your guardian.", "Message", "")
	if(!input) return

	var/my_message = "<span class='boldannounce'><i>[src]:</i> [input]</span>"
	for(var/mob/M in mob_list)
		if(istype (M, /mob/living/simple_animal/hostile/guardian))
			var/mob/living/simple_animal/hostile/guardian/G = M
			if(G.summoner == src)
				G << "[my_message]"
		else if (M in dead_mob_list)
			M << "<a href='?src=\ref[M];follow=\ref[src]'>(F)</a> [my_message]"
	src << "<span class='boldannounce'><i>[src]:</i> [input]</span>"
	log_say("[src.real_name]/[src.key] : [text]")


/mob/living/proc/guardian_recall()
	set name = "Recall Guardian"
	set category = "Guardian"
	set desc = "Forcibly recall your guardian."
	for(var/mob/living/simple_animal/hostile/guardian/G in mob_list)
		if(G.summoner == src)
			G.Recall()

/mob/living/proc/guardian_reset()
	set name = "Reset Guardian Player (One Use)"
	set category = "Guardian"
	set desc = "Re-rolls which ghost will control your Guardian. One use."

	src.verbs -= /mob/living/proc/guardian_reset
	for(var/mob/living/simple_animal/hostile/guardian/G in mob_list)
		if(G.summoner == src)
			var/list/mob/dead/observer/candidates = pollCandidates("Do you want to play as [G.real_name]?", "pAI", null, FALSE, 100)
			var/mob/dead/observer/new_stand = null
			if(candidates.len)
				new_stand = pick(candidates)
				G << "Your user reset you, and your body was taken over by a ghost. Looks like they weren't happy with your performance."
				src << "Your guardian has been successfully reset."
				message_admins("[key_name_admin(new_stand)] has taken control of ([key_name_admin(G)])")
				G.ghostize(0)
				G.key = new_stand.key
			else
				src << "There were no ghosts willing to take control. Looks like you're stuck with your Guardian for now."
				verbs += /mob/living/proc/guardian_reset

/mob/living/simple_animal/hostile/guardian/proc/ToggleLight()
	if(!luminosity)
		src << "<span class='notice'>You activate your light.</span>"
		SetLuminosity(3)
	else
		src << "<span class='notice'>You deactivate your light.</span>"
		SetLuminosity(0)


////////Creation

/obj/item/weapon/guardiancreator
	name = "deck of tarot cards"
	desc = "An enchanted deck of tarot cards, rumored to be a source of unimaginable power. "
	icon = 'icons/obj/toy.dmi'
	icon_state = "deck_syndicate_full"
	var/used = FALSE
	var/theme = "magic"
	var/mob_name = "Guardian Spirit"
	var/use_message = "You shuffle the deck..."
	var/used_message = "All the cards seem to be blank now."
	var/failure_message = "..And draw a card! It's...blank? Maybe you should try again later."
	var/ling_failure = "The deck refuses to respond to a souless creature such as you."
	var/list/possible_guardians = list("Chaos", "Standard", "Ranged", "Support", "Explosive", "Lightning", "Protector", "Charger")
	var/random = TRUE

/obj/item/weapon/guardiancreator/attack_self(mob/living/user)
	for(var/mob/living/simple_animal/hostile/guardian/G in living_mob_list)
		if (G.summoner == user)
			user << "You already have a [mob_name]!"
			return
	if(user.mind && user.mind.changeling)
		user << "[ling_failure]"
		return
	if(used == TRUE)
		user << "[used_message]"
		return
	used = TRUE
	user << "[use_message]"
	var/list/mob/dead/observer/candidates = pollCandidates("Do you want to play as the [mob_name] of [user.real_name]?", ROLE_PAI, null, FALSE, 100)
	var/mob/dead/observer/theghost = null

	if(candidates.len)
		theghost = pick(candidates)
		spawn_guardian(user, theghost.key)
	else
		user << "[failure_message]"
		used = FALSE


/obj/item/weapon/guardiancreator/proc/spawn_guardian(var/mob/living/user, var/key)
	var/gaurdiantype = "Standard"
	if(random)
		gaurdiantype = pick(possible_guardians)
	else
		gaurdiantype = input(user, "Pick the type of [mob_name]", "[mob_name] Creation") as null|anything in possible_guardians
	var/pickedtype = /mob/living/simple_animal/hostile/guardian/punch
	switch(gaurdiantype)

		if("Chaos")
			pickedtype = /mob/living/simple_animal/hostile/guardian/fire

		if("Standard")
			pickedtype = /mob/living/simple_animal/hostile/guardian/punch

		if("Ranged")
			pickedtype = /mob/living/simple_animal/hostile/guardian/ranged

		if("Support")
			pickedtype = /mob/living/simple_animal/hostile/guardian/healer

		if("Explosive")
			pickedtype = /mob/living/simple_animal/hostile/guardian/bomb

		if("Lightning")
			pickedtype = /mob/living/simple_animal/hostile/guardian/beam

		if("Protector")
			pickedtype = /mob/living/simple_animal/hostile/guardian/protector

		if("Charger")
			pickedtype = /mob/living/simple_animal/hostile/guardian/charger

	var/mob/living/simple_animal/hostile/guardian/G = new pickedtype(user)
	G.summoner = user
	G.key = key
	G << "You are a [mob_name] bound to serve [user.real_name]."
	G << "You are capable of manifesting or recalling to your master with the buttons on your HUD. You will also find a button to communicate with them privately there."
	G << "While personally invincible, you will die if [user.real_name] does, and any damage dealt to you will have a portion passed on to them as you feed upon them to sustain yourself."
	G << "[G.playstyle_string]"
	G.faction = user.faction
	user.verbs += /mob/living/proc/guardian_comm
	user.verbs += /mob/living/proc/guardian_recall
	user.verbs += /mob/living/proc/guardian_reset

	var/colour
	var/picked_name
	switch(theme)
		if("magic")
			user << "[G.magic_fluff_string]."
			colour = pick("Pink", "Red", "Orange", "Green", "Blue")
			picked_name = pick("Aries", "Leo", "Sagittarius", "Taurus", "Virgo", "Capricorn", "Gemini", "Libra", "Aquarius", "Cancer", "Scorpio", "Pisces")
		if("tech")
			user << "[G.tech_fluff_string]."
			G.bubble_icon = "holo"
			colour = pick("Rose", "Peony", "Lily", "Daisy", "Zinnia", "Ivy", "Iris", "Petunia", "Violet", "Lilac", "Orchid") //technically not colors, just flowers that can be specific colors
			picked_name = pick("Gallium", "Indium", "Thallium", "Bismuth", "Aluminium", "Mercury", "Iron", "Silver", "Zinc", "Titanium", "Chromium", "Nickel", "Platinum", "Tellurium", "Palladium", "Rhodium", "Cobalt", "Osmium", "Tungsten", "Iridium")

	G.name = "[picked_name] [colour]"
	G.real_name = "[picked_name] [colour]"
	G.icon_living = "[theme][colour]"
	G.icon_state = "[theme][colour]"
	G.icon_dead = "[theme][colour]"

	G.mind.name = "[G.real_name]"

/obj/item/weapon/guardiancreator/choose
	random = FALSE

/obj/item/weapon/guardiancreator/tech
	name = "holoparasite injector"
	desc = "It contains an alien nanoswarm of unknown origin. Though capable of near sorcerous feats via use of hardlight holograms and nanomachines, it requires an organic host as a home base and source of fuel."
	icon = 'icons/obj/syringe.dmi'
	icon_state = "combat_hypo"
	theme = "tech"
	mob_name = "Holoparasite"
	use_message = "You start to power on the injector..."
	used_message = "The injector has already been used."
	failure_message = "<B>...ERROR. BOOT SEQUENCE ABORTED. AI FAILED TO INTIALIZE. PLEASE CONTACT SUPPORT OR TRY AGAIN LATER.</B>"
	ling_failure = "The holoparasites recoil in horror. They want nothing to do with a creature like you."

/obj/item/weapon/guardiancreator/tech/choose/traitor
	possible_guardians = list("Chaos", "Standard", "Ranged", "Support", "Explosive", "Lightning")

/obj/item/weapon/guardiancreator/tech/choose
	random = FALSE

/obj/item/weapon/paper/guardian
	name = "Holoparasite Guide"
	icon_state = "paper_words"
	info = {"<b>A list of Holoparasite Types</b><br>

 <br>
 <b>Chaos</b>: Ignites enemies on touch and causes them to hallucinate all nearby people as the parasite. Automatically extinguishes the user if they catch on fire.<br>
 <br>
 <b>Standard</b>:Devastating close combat attacks and high damage resist. Can smash through weak walls.<br>
 <br>
 <b>Ranged</b>: Has two modes. Ranged; which fires a constant stream of weak, armor-ignoring projectiles. Scout; Cannot attack, but can move through walls and is quite hard to see. Can lay surveillance snares, which alert it when crossed, in either mode.<br>
 <br>
 <b>Support</b>:Has two modes. Combat; Medium power attacks and damage resist. Healer; Heals instead of attack, but has low damage resist and slow movement. Can deploy a bluespace beacon and warp targets to it (including you) in either mode.<br>
 <br>
 <b>Explosive</b>: High damage resist and medium power attack that may explosively teleport targets. Can turn any object, including objects too large to pick up, into a bomb, dealing explosive damage to the next person to touch it. The object will return to normal after the trap is triggered or after a delay.<br>
 <br>
 <b>Lightning</b>: Attacks apply lightning chains to targets. Has a lightning chain to the user. Lightning chains shock everything near them.<br>
"}

/obj/item/weapon/paper/guardian/update_icon()
	return


/obj/item/weapon/storage/box/syndie_kit/guardian
	name = "holoparasite injector kit"

/obj/item/weapon/storage/box/syndie_kit/guardian/New()
	..()
	new /obj/item/weapon/guardiancreator/tech/choose/traitor(src)
	new /obj/item/weapon/paper/guardian(src)
	return
