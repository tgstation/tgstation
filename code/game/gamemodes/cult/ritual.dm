/*

This file contains the arcane tome files as well as innate cultist emergency communications.

*/

/mob/proc/cult_add_comm() //why the fuck does this have its own proc? not removing it because it might be used somewhere but...
	verbs += /mob/living/proc/cult_help
	verbs += /mob/living/proc/cult_innate_comm
	

/mob/living/proc/cult_help()
	set category = "Cultist"
	set name = "How to Play Cult"
	var/text = ""
	text += "<center><font color='red' size=3><b><i>Tenets of the Dark One</i></b></font></center><br><br><br>"

	text += "<font color='red'><b>I. SECRECY</b></font><br>Your cult is a SECRET organization. Your success DEPENDS on keeping your cult's members and locations SECRET for as long as possible. This means that your tome should be hidden \
	in your bag and never brought out in public. You should never create runes where other crew might find them, and you should avoid using talismans or other cult magic with witnesses around.<br><br>"

	text += "<font color='red'><b>II. TOME</b></font><br>You start with a unique talisman in your bag. This supply talisman can be used 3 times, and creates starter equipment for your cult. The most critical of the talisman's functions is \
	the power to create a tome. This tome is your most important item and summoning one (in secret) is your FIRST PRIORITY. It lets you talk to fellow cultists and create runes, which in turn is essential to growing the cult's power.<br><br>"

	text += "<font color='red'><b>III. RUNES</b></font><br>Runes are powerful sources of cult magic. Your tome will allow you to draw runes with your blood. Those runes, when hit with an empty hand, will attempt to \
	trigger the rune's magic. Runes are essential for the cult to convert new members, create powerful minions, or call upon incredibly powerful magic. Some runes require more than one cultist to use.<br><br>"

	text += "<font color='red'><b>IV. TALISMANS</b></font><br>Talismans are a mobile source of cult magic that are NECESSARY to achieve success as a cult. Your starting talisman can produce certain talismans, but you will need \
	to use the -create talisman- rune (with ordinary paper on top) to get more talismans. Talismans are EXTREMELY powerful, therefore creating more talismans in a HIDDEN location should be one of your TOP PRIORITIES.<br><br>"

	text += "<font color='red'><b>V. GROW THE CULT</b></font><br>There are certain basic strategies that all cultists should master. STUN talismans are the foundation of a successful cult. If you intend to convert the stunned person \
	you should use cuffs or a talisman of shackling on them and remove their headset before they recover (it takes about 10 seconds to recover). If you intend to sacrifice the victim, striking them quickly and repeatedly with your tome \
	will knock them out before they can recover. Sacrificed victims will their soul behind in a shard, these shards can be used on construct shells to make powerful servants for the cult. Remember you need TWO cultists standing near a \
	conversion rune to convert someone. Your construct minions cannot trigger most runes, but they will count as cultists in helping you trigger more powerful runes like conversion or blood boil.<br><br>"

	text += "<font color='red'><b>VI. VICTORY</b></font><br>You have two ultimate goals as a cultist, sacrifice your target, and summon Nar-Sie. Sacrificing the target involves killing that individual and then placing \
	their corpse on a sacrifice rune and triggering that rune with THREE cultists. Do NOT lose the target's corpse! Only once the target is sacrificed can Nar-Sie be summoned. Summoning Nar-Sie will take nearly one minute \
	just to draw the massive rune needed. Do not create the rune until your cult is ready, the crew will receive the NAME and LOCATION of anyone who attempts to create the Nar-Sie rune. Once the Nar-Sie rune is drawn \
	you must gathered 9 cultists (or constructs) over the rune and then click it to bring the Dark One into this world!<br><br>"

	var/datum/browser/popup = new(usr, "mind", "", 800, 600)
	popup.set_content(text)
	popup.open()
	return 1

/mob/living/proc/cult_innate_comm()
	set category = "Cultist"
	set name = "Imperfect Communion"

	if(!iscultist(usr) || usr.incapacitated())
		return
	if(!istype(usr, /mob/living/simple_animal))
		var/confirm_desperation = alert(usr, "This is a LAST RESORT; you should use a tome to communicate if possible. This ritual will inflict serious injury on you!", "Is this what you want?", "Yes", "No")
		if(confirm_desperation == "No")
			usr << "On second thought, maybe I should summon a tome."
			return
	var/input = stripped_input(usr, "Please choose a message to tell to the other acolytes.", "Voice of Blood", "")
	if(!input)
		return

	if(!iscultist(usr) || usr.incapacitated())
		return	//we do this again because input() sleeps

	if(ishuman(usr) || ismonkey(usr))	//Damage only applies to humans and monkeys, to allow constructs to communicate
		usr.visible_message("<span class='warning'>[usr] starts clawing at \his arms with \his fingernails!</span>", "<span class='cultitalic'>You begin slicing open your arms with your fingernails!</span>")
		apply_damage(10,BRUTE, "l_arm")
		apply_damage(10,BRUTE, "r_arm")
		sleep(50)
		if(usr.incapacitated())
			return	//Hard to drawn intrinsic symbols when you're bleeding out in your cell.
		var/turf/location = loc
		if(istype(location, /turf))	// tearing your arms apart is going to spill a bit of blood, in fact thats the idea
			location.add_blood(usr)				// TO-DO change this to a badly drawn rune
		apply_damage(10,BRUTE, "l_arm")		// does a metric fuck ton of damage because this meant to be an emergency method of communication.
		apply_damage(10,BRUTE, "r_arm")
		if(usr.incapacitated())
			return
		usr.visible_message("<span class='warning'>[usr] paints strange symbols with their own blood.</span>", "<span class='cultitalic'>You paint a messy rune with your own blood.</span>")
		sleep(20)

	cultist_commune(usr, 0, 1, input)
	return

/obj/item/weapon/tome
	name = "arcane tome"
	desc = "An old, dusty tome with frayed edges and a sinister-looking cover."
	icon_state ="tome"
	throw_speed = 2
	throw_range = 5
	w_class = 2

/obj/item/weapon/tome/examine(mob/user)
	..()
	if(iscultist(user))
		user << "The scriptures of the Geometer. Allows the scribing of runes and access to the knowledge archives of the cult of Nar-Sie."

/obj/item/weapon/tome/attack(mob/living/M, mob/living/user)
	if(istype(M,/mob/dead/observer))
		M.invisibility = 0
		user.visible_message("<span class='warning'>[user] strikes the air with [src], and a ghost appears!</span>", \
							 "<span class='cult'>You drag the ghost to your plane of reality!</span>")
		add_logs(user, M, "smacked", src)
		return
	if(!istype(M))
		return
	if(!iscultist(user))
		return ..()
	if(iscultist(M))
		if(M.reagents && M.reagents.has_reagent("holywater")) //allows cultists to be rescued from the clutches of ordained religion
			user << "<span class='cult'>You remove the taint from [M].</span>"
			var/holy2unholy = M.reagents.get_reagent_amount("holywater")
			M.reagents.del_reagent("holywater")
			M.reagents.add_reagent("unholywater",holy2unholy)
			add_logs(user, M, "smacked", src, " removing the holy water from them")
		return
	M.take_organ_damage(0, 15) //Used to be a random between 5 and 20
	playsound(M, 'sound/weapons/sear.ogg', 50, 1)
	M.visible_message("<span class='danger'>[user] strikes [M] with the arcane tome!</span>", \
					  "<span class='userdanger'>[user] strikes you with the tome, searing your flesh!</span>")
	flick("tome_attack", src)
	user.do_attack_animation(M)
	add_logs(user, M, "smacked", src)

/obj/item/weapon/tome/attack_self(mob/user)
	if(!iscultist(user))
		user << "<span class='warning'>[src] seems full of unintelligible shapes, scribbles, and notes. Is this some sort of joke?</span>"
		return
	open_tome(user)

/obj/item/weapon/tome/proc/open_tome(mob/user)
	var/choice = alert(user,"You open the tome...",,"Commune","Scribe Rune","More Information")
	switch(choice)
		if("More Information")
			read_tome(user)
		if("Scribe Rune")
			scribe_rune(user)
		if("Commune")
			var/input = stripped_input(usr, "Please enter a message to tell to the other acolytes.", "Voice of Blood", "")
			if(!input)
				return
			cultist_commune(user, 1, 0, input)

/obj/item/weapon/tome/proc/read_tome(mob/user)
	var/text = ""
	text += "<center><font color='red' size=3><b><i>Archives of the Dark One</i></b></font></center><br><br><br>"
	text += "A rune's name and effects can be revealed by examining the rune.<<br><br>"

	text += "<font color='red'><b>Imbue Talisman</b></font><br>The Rune of Talisman Creation is one of the most important. It is the only way to create new talismans. A blank sheet of paper must be on top of the rune. After \
	invoking it and choosing which talisman you desire, the paper will be converted into a talisman.<br><br>"

	text += "<font color='red'><b>Teleport</b></font><br>The Rune of Teleportation is a unique rite in that it requires a keyword before the scribing can begin. When invoked, search for other Rites of Translocation. \
	If any are found, the user can choose which rune to send to. Upon activation, the rune teleports everything above it to the selected rune.<br><br>"

	text += "<font color='red'><b>Convert</b></font><br>The Rune of Conversion is important to the success of the cult. It will allow you to convert normal crew members into cultists. \
	To do this, simply place the crew member upon the rune and invoke it. This rune requires two acolytes to use. If the target to be converted is loyalty-implanted or a certain assignment, they will \
	be unable to be converted. People the Geometer wishes sacrificed will also be ineligible for conversion, and anyone with a shielding presence like the null rod will not be converted.<br><br>"

	text += "<font color='red'><b>Sacrifice</b></font><br>The Rune of Sacrifice is necessary to achieve your goals. Simply place any dead creature upon the rune and invoke it (this will not \
	target cultists!). If this creature has a mind, a soul shard will be created and the creature's soul transported to it. This rune is required if the cult's objectives include the sacrifice of a crew \
	member. Sacrificing the dead can be done alone, but sacrificing living crew or your cult's target will require 3 cultists. Soul shards used on construct shells will move that soul into a \
	powerful construct of your choice.<br><br>"

	text += "<font color='red'><b>Raise Dead</b></font><br>The Rune of Resurrection is a delicate rite that requires two corpses. To perform the ritual, place the corpse you wish to revive onto \
	the rune and the offering body adjacent to it. When the rune is invoked, the body to be sacrificed will turn to dust, the life force flowing into the revival target. Assuming the target is not moved \
	within a few seconds, they will be brought back to life, healed of all ailments.<br><br>"

	text += "<font color='red'><b>Electromagnetic Disruption</b></font><br>Robotic lifeforms have time and time again been the downfall of fledgling cults. The Rite of Disruption may allow you to gain the upper \
	hand against these pests. By using the rune, a large electromagnetic pulse will be emitted from the rune's location. The size of the EMP will grow significantly for each additional adjacent cultist when the \
	rune is activated.<br><br>"

	text += "<font color='red'><b>Astral Communion</b></font><br>The Rune of Astral Communion is perhaps the most ingenious rune that is usable by a single person. Upon invoking the rune, the \
	user's spirit will be ripped from their body. In this state, the user's physical body will be locked in place to the rune itself - any attempts to move it will result in the rune pulling it back. \
	The body will also take constant damage while in this form, and may even die. The user's spirit will contain their consciousness, and will allow them to freely wander the station as a ghost. This may \
	also be used to commune with the dead.<br><br>"

	text += "<font color='red'><b>Form Barrier</b></font><br>While simple, the Barrier Rune serves an important purpose in defense and hindering passage. When invoked, the \
	rune will draw a small amount of life force from the user and make the space above the rune completely dense, rendering it impassable to all but the most complex means. The rune may be invoked again to \
	undo this effect and allow passage again.<br><br>"

	text += "<font color='red'><b>Summon Cultist</b></font><br>The Rune of Summoning requires two acolytes to use. When invoked, it will allow the user to summon a single cultist to the rune from \
	any location. This will deal a moderate amount of damage to all invokers. Absolutely crucial for rescuing your brothers from security.<br><br>"

	text += "<font color='red'><b>Blood Boil</b></font><br>The Rune of Boiling Blood may be considered one of the most dangerous rites composed by the cult of Nar-Sie. When invoked, it will do a \
	massive amount of damage to all non-cultist viewers, but it will also emit an explosion upon invocation. It requires three invokers.<br><br>"

	text += "<font color='red'><b>Manifest Spirit</b></font><br>If you wish to bring a spirit back from the dead with a wish for vengeance and desire to serve, the Rite of Spectral \
	Manifestation can do just that. When invoked, any spirits above the rune will be brought to life as a human wearing nothing that seeks only to serve you and the Geometer. However, the spirit's link \
	to reality is fragile - you must remain on top of the rune, and you will slowly take damage. Upon stepping off the rune, the spirits will dissipate, dropping their items to the ground. You may manifest \
	multiple spirits with one rune, but you will rapidly take damage in doing so.<br><br>"

	text += "<font color='red'><b><i>Summon Nar-Sie</i></b></font><br>There is only one way to summon the avatar of Nar-Sie, and that is the Ritual of Dimensional Rending. This ritual, in \
	comparison to other runes, is very large, requiring a 3x3 space of empty tiles to create. To invoke the rune, nine cultists must stand on the rune, so that all of them are within its circle. Then, \
	simply invoke it. A brief tearing will be heard as the barrier between dimensions is torn open, and the avatar will come forth.<br><br><br>"

	text += "<font color='red'><b>Talisman of Teleportation</b></font><br>The talisman form of the Rite of Translocation will transport the invoker to a randomly chosen rune of the same keyword, then \
	disappear.<br><br>"

	text += "<font color='red'><b>Talisman of Construction</b></font><br>The Rune of Fabrication is the main way of creating construct shells. To use it, one must place fifteen sheets of metal on top of the rune \
	and invoke it. The sheets will them be twisted into a construct shell, ready to recieve a soul to occupy it.<br><br>"

	text += "<font color='red'><b>Talisman of Tome Summoning</b></font><br>This talisman functions nearly identically to the rune. The talisman will attempt to place the tome in your hand \
	instead of on the ground, though this is the only advantage it has over the rune. It can be used once, then disappears.<br><br>"

	text += "<font color='red'><b>Talismans of Veiling and Disguising</b></font><br>These talismans will hide, reveal, or disguise (as crayon drawings) all nearby runes.<br><br>"

	text += "<font color='red'><b>Talisman of Electromagnetic Pulse</b></font><br>This talisman will EMP the target and anything else nearby. It disappears after one use.<br><br>"

	text += "<font color='red'><b>Talisman of Stunning</b></font><br>Without this talisman, the cult would have no way of easily acquiring targets to convert. Commonly called \"stunpapers\", this \
	talisman functions differently from others. Rather than simply reading the words, the target must be attacked directly with the talisman. The talisman will then knock down the target for a long \
	duration in addition to inhibiting their speech. Robotic lifeforms will suffer the effects of a heavy electromagnetic pulse instead.<br><br>"

	text += "<font color='red'><b>Talisman of Armaments</b></font><br>The Talisman of Arming will equip the user with armored robes, a backpack, an eldritch longsword, an empowered bola, and a pair of boots. Any items that cannot \
	be equipped will not be summoned.<br><br>"

	text += "<font color='red'><b>Talisman of Horrors</b></font><br>The Talisman of Horror must be applied directly to the victim, it will shatter your victim's mind with visions of the endtimes that may incapitate them.<br><br>"

	text += "<font color='red'><b>Talisman of Shackling</b></font><br>The Talisman of Shackling must be applied directly to the victim, it has 4 uses and cuffs victims with magic shackles that disappear when removed.<br><br>"
	 
	text += "In addition to these runes, the cult has a small selection of equipment and constructs.<br><br>"

	text += "<font color='red'><b>Equipment:</b></font><br><br>"

	text += "<font color='red'><b>Cult Blade</b></font><br>Cult blades are a sharp weapons that, notably, cannot be used by noncultists. These blades are produced by the Rite and Talisman of Arming.<br><br>"

	text += "<font color='red'><b>Cult Robes</b></font><br>Cult robes are heavily armored robes. These robes are produced by the Rite and Talisman of Arming.<br><br>"

	text += "<font color='red'><b>Soulstone</b></font><br>A soulstone is a simple piece of magic, produced either via the starter talisman or by sacrificing humans. Using it on an unconscious or dead human, or on a Shade, will trap their soul in the stone, allowing its use in construct shells. \
	<br>The soul within can also be released as a Shade.<br><br>"

	text += "<font color='red'><b>Construct Shell</b></font><br>A construct shell is useless on its own, but placing a filled soulstone within it allows you to produce your choice of a <b>Wraith</b>, a <b>Juggernaut</b>, or an <b>Artificer</b>. \
	<br>Each construct has uses, detailed below in Constructs. Construct shells can be produced via the starter talisman or the Rite of Fabrication.<br><br>"

	text += "<font color='red'><b>Constructs:</b></font><br><br>"

	text += "<font color='red'><b>Shade</b></font><br>While technically not a construct, the Shade is produced when released from a soulstone. It is quite fragile and has weak melee attacks, but is fully healed when recaptured by a soulstone.<br><br>"

	text += "<font color='red'><b>Wraith</b></font><br>The Wraith is a fast, lethal melee attacker which can jaunt through walls. However, it is only slightly more durable than a shade.<br><br>"

	text += "<font color='red'><b>Juggernaut</b></font><br>The Juggernaut is a slow, but durable, melee attacker which can produce temporary forcewalls. It will also reflect most lethal energy weapons.<br><br>"

	text += "<font color='red'><b>Artificer</b></font><br>The Artificer is a weak and fragile construct, able to heal other constructs, produce more <font color='red'><b>soulstones</b></font> and <font color='red'><b>construct shells</b></font>, \
	construct fortifying cult walls and flooring, and finally, it can release a few indiscriminate stunning missiles.<br><br>"

	text += "<font color='red'><b>Harvester</b></font><br>If you see one, know that you have done all you can and your life is void.<br><br>" 
	
	var/datum/browser/popup = new(user, "tome", "", 800, 600)
	popup.set_content(text)
	popup.open()
	return 1

/obj/item/weapon/tome/proc/scribe_rune(mob/user)
	var/turf/Turf = get_turf(user)
	var/chosen_keyword
	var/obj/effect/rune/rune_to_scribe
	var/entered_rune_name
	var/list/possible_runes = list()
	var/list/shields = list()
	if(locate(/obj/effect/rune) in Turf)
		user << "<span class='cult'>There is already a rune here.</span>"
		return
	for(var/T in subtypesof(/obj/effect/rune) - /obj/effect/rune/malformed)
		var/obj/effect/rune/R = T
		if(initial(R.cultist_name))
			possible_runes.Add(initial(R.cultist_name)) //This is to allow the menu to let cultists select runes by name rather than by object path. I don't know a better way to do this
	if(!possible_runes.len)
		return
	entered_rune_name = input(user, "Choose a rite to scribe.", "Sigils of Power") as null|anything in possible_runes
	if(!Adjacent(user) || !src || qdeleted(src) || user.incapacitated())
		return
	for(var/T in typesof(/obj/effect/rune))
		var/obj/effect/rune/R = T
		if(initial(R.cultist_name) == entered_rune_name)
			rune_to_scribe = R
			if(initial(R.req_keyword))
				var/the_keyword = stripped_input(usr, "Please enter a keyword for the rune.", "Enter Keyword", "")
				if(!the_keyword)
					return
				chosen_keyword = the_keyword
			break
	if(!rune_to_scribe)
		return
	var/turf/Thenewturfyouwalkedto = get_turf(user) //we may have moved. adjust as needed...
	if(locate(/obj/effect/rune) in Thenewturfyouwalkedto)
		user << "<span class='cult'>There is already a rune here.</span>"
		return
	if(!Adjacent(user) || !src || qdeleted(src) || user.incapacitated())
		return
	user.visible_message("<span class='warning'>[user] cuts open their arm and begins writing in their own blood!</span>", \
						 "<span class='cult'>You slice open your arm and begin drawing a sigil of the Geometer.</span>")
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		C.apply_damage(0.1, BRUTE, pick("l_arm", "r_arm"))
		if("Summon Nar-Sie" == entered_rune_name)
			var/confirm_final = alert(usr, "This is the FINAL step to summon Nar-Sie, it is a long, painful ritual and the crew will be alerted to your presence", "Are you prepared for the final battle?", "My life for Nar-Sie!", "No")
			if(confirm_final == "No")
				usr << "On second thought, we should prepare further for the final battle..."
				return
			C.apply_damage(40, BRUTE, pick("l_arm", "r_arm"))
			var/area/A = get_area(src)
			var/locname = initial(A.name)
			priority_announce("Figments from an eldritch god are being summoned by [user] into [locname] from an unknown dimension. Disrupt the ritual at all costs!","Central Command Higher Dimensionsal Affairs", 'sound/AI/spanomalies.ogg')
			for(var/turf/B in orange (1, user))
				var/obj/machinery/shield/N = new(B)
				N.name = "Rune-Scriber's Shield"
				N.desc = "A potent shield summoned by cultists to protect them while they prepare the final ritual"
				N.icon_state = "shield-red"
				N.health = 60
				shields |= N
			if(!do_after(user, 400, target = get_turf(user)))
				for(var/V in shields)
					var/obj/machinery/shield/S = V
					if(S && !qdeleted(S))
						qdel(S)
				return
	if(!do_after(user, 50, target = get_turf(user)))
		for(var/V in shields)
			var/obj/machinery/shield/S = V
			if(S && !qdeleted(S))
				qdel(S)
		return
	user.visible_message("<span class='warning'>[user] creates a strange circle in their own blood.</span>", \
						 "<span class='cult'>You finish drawing the arcane markings of the Geometer.</span>")
	for(var/V in shields)
		var/obj/machinery/shield/S = V
		if(S && !qdeleted(S))
			qdel(S)
	new rune_to_scribe(Thenewturfyouwalkedto, chosen_keyword)
	user << "<span class='cult'>The [lowertext(initial(rune_to_scribe.cultist_name))] rune [initial(rune_to_scribe.cultist_desc)]</span>"
