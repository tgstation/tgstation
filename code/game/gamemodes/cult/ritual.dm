/*

This file contains the arcane tome files.

*/


/obj/item/weapon/tome
	name = "arcane tome"
	desc = "An old, dusty tome with frayed edges and a sinister-looking cover."
	icon_state ="tome"
	throw_speed = 2
	throw_range = 5
	w_class = 2

/obj/item/weapon/tome/examine(mob/user)
	..()
	if(iscultist(user) || user.stat == DEAD)
		user << "<span class='cult'>The scriptures of the Geometer. Allows the scribing of runes and access to the knowledge archives of the cult of Nar-Sie.</span>"
		user << "<span class='cult'>Striking a cult structure will unanchor or reanchor it.</span>"
		user << "<span class='cult'>Striking another cultist with it will purge holy water from them.</span>"
		user << "<span class='cult'>Striking a noncultist, however, will sear their flesh.</span>"

/obj/item/weapon/tome/attack(mob/living/M, mob/living/user)
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
	var/choice = alert(user,"You open the tome...",,"Scribe Rune","More Information","Cancel")
	switch(choice)
		if("More Information")
			read_tome(user)
		if("Scribe Rune")
			scribe_rune(user)
		if("Cancel")
			return

/obj/item/weapon/tome/proc/read_tome(mob/user)
	var/text = ""
	text += "<center><font color='red' size=3><b><i>Archives of the Dark One</i></b></font></center><br><br><br>"
	text += "A rune's name and effects can be revealed by examining the rune.<<br><br>"

	text += "<font color='red'><b>Create Talisman</b></font><br>This rune is one of the most important runes the cult has, being the only way to create new talismans. A blank sheet of paper must be on top of the rune. After \
	invoking it and choosing which talisman you desire, the paper will be converted, after some delay into a talisman.<br><br>"

	text += "<font color='red'><b>Teleport</b></font><br>This rune is unique in that it requires a keyword before the scribing can begin. When invoked, it will find any other Teleport runes; \
	If any are found, the user can choose which rune to send to. Upon activation, the rune teleports everything above it to the selected rune.<br><br>"

	text += "<font color='red'><b>Convert</b></font><br>This rune is critical to the success of the cult. It will allow you to convert normal crew members into cultists. \
	To do this, simply place the crew member upon the rune and invoke it. This rune requires two invokers to use. If the target to be converted is loyalty-implanted or a certain assignment, they will \
	be unable to be converted. People the Geometer wishes sacrificed will also be ineligible for conversion, and anyone with a shielding presence like the null rod will not be converted.<br> \
	Successful conversions will produce a tome for the new cultist.<br><br>"

	text += "<font color='red'><b>Sacrifice</b></font><br><b>This rune is necessary to achieve your goals.</b> Simply place any dead creature upon the rune and invoke it (this will not \
	target cultists!). If this creature has a mind, a soulstone will be created and the creature's soul transported to it. Sacrificing the dead can be done alone, but sacrificing living crew <b>or your cult's target</b> will require 3 cultists. \
	Soulstones used on construct shells will move that soul into a powerful construct of your choice.<br><br>"

	text += "<font color='red'><b>Raise Dead</b></font><br>This rune requires two corpses. To perform the ritual, place the corpse you wish to revive onto \
	the rune and the offering body adjacent to it. When the rune is invoked, the body to be sacrificed will turn to dust, the life force flowing into the revival target. Assuming the target is not moved \
	within a few seconds, they will be brought back to life, healed of all ailments.<br><br>"

	text += "<font color='red'><b>Electromagnetic Disruption</b></font><br>Robotic lifeforms have time and time again been the downfall of fledgling cults. This rune may allow you to gain the upper \
	hand against these pests. By using the rune, a large electromagnetic pulse will be emitted from the rune's location. The size of the EMP will grow significantly for each additional adjacent cultist when the \
	rune is activated.<br><br>"

	text += "<font color='red'><b>Astral Communion</b></font><br>This rune is perhaps the most ingenious rune that is usable by a single person. Upon invoking the rune, the \
	user's spirit will be ripped from their body. In this state, the user's physical body will be locked in place to the rune itself - any attempts to move it will result in the rune pulling it back. \
	The body will also take constant damage while in this form, and may even die. The user's spirit will contain their consciousness, and will allow them to freely wander the station as a ghost. This may \
	also be used to commune with the dead.<br><br>"

	text += "<font color='red'><b>Form Barrier</b></font><br>While simple, this rune serves an important purpose in defense and hindering passage. When invoked, the \
	rune will draw a small amount of life force from the user and make the space above the rune completely dense, rendering it impassable to all but the most complex means. The rune may be invoked again to \
	undo this effect and allow passage again.<br><br>"

	text += "<font color='red'><b>Summon Cultist</b></font><br>This rune allows the cult to free other cultists with ease. When invoked, it will allow the user to summon a single cultist to the rune from \
	any location. It requires two invokers, and will damage each invoker slightly.<br><br>"

	text += "<font color='red'><b>Blood Boil</b></font><br>When invoked, this rune will do a massive amount of damage to all non-cultist viewers, but it will also emit a small explosion upon invocation. \
	It requires three invokers.<br><br>"

	text += "<font color='red'><b>Manifest Spirit</b></font><br>This rune allows you to summon spirits as humanoid fighters. When invoked, a spirit above the rune will be brought to life as a human, wearing nothing, that seeks only to serve you and the Geometer. \
	However, the spirit's link to reality is fragile - you must remain on top of the rune, and you will slowly take damage. Upon stepping off the rune, all summoned spirits will dissipate, dropping their items to the ground. You may manifest \
	multiple spirits with one rune, but you will rapidly take damage in doing so.<br><br>"

	text += "<font color='red'><b><i>Summon Nar-Sie</i></b></font><br><b>This rune is necessary to achieve your goals.</b> On attempting to scribe it, it will produce shields around you and alert everyone you are attempting to scribe it; it takes a very long time to scribe, \
	and does massive damage to the one attempting to scribe it.<br>Invoking it requires 9 invokers and the sacrifice of a specific crewmember, and once invoked, will summon the Geometer, Nar-Sie herself. \
	This will complete your objectives.<br><br><br>"

	text += "<font color='red'><b>Talisman of Teleportation</b></font><br>The talisman form of the Teleport rune will transport the invoker to a selected Teleport rune once.<br><br>"

	text += "<font color='red'><b>Talisman of Construction</b></font><br>This talisman is the main way of creating construct shells. To use it, one must strike 30 sheets of metal with the talisman. The sheets will then be twisted into a construct shell, ready to recieve a soul to occupy it.<br><br>"

	text += "<font color='red'><b>Talisman of Tome Summoning</b></font><br>This talisman will produce a single tome at your feet.<br><br>"

	text += "<font color='red'><b>Talisman of Veiling/Revealing</b></font><br>This talisman will hide runes on its first use, and on the second, will reveal runes.<br><br>"

	text += "<font color='red'><b>Talisman of Disguising</b></font><br>This talisman will permanently disguise all nearby runes as crayon runes.<br><br>"

	text += "<font color='red'><b>Talisman of Electromagnetic Pulse</b></font><br>This talisman will EMP anything else nearby. It disappears after one use.<br><br>"

	text += "<font color='red'><b>Talisman of Stunning</b></font><br>Attacking a target will knock them down for a long duration in addition to inhibiting their speech. \
	Robotic lifeforms will suffer the effects of a heavy electromagnetic pulse instead.<br><br>"

	text += "<font color='red'><b>Talisman of Armaments</b></font><br>The Talisman of Arming will equip the user with armored robes, a backpack, an eldritch longsword, an empowered bola, and a pair of boots. Any items that cannot \
	be equipped will not be summoned. Attacking a fellow cultist with it will instead equip them.<br><br>"

	text += "<font color='red'><b>Talisman of Horrors</b></font><br>The Talisman of Horror must be applied directly to the victim, it will shatter your victim's mind with visions of the endtimes that may incapitate them.<br><br>"

	text += "<font color='red'><b>Talisman of Shackling</b></font><br>The Talisman of Shackling must be applied directly to the victim, it has 4 uses and cuffs victims with magic shackles that disappear when removed.<br><br>"

	text += "In addition to these runes, the cult has a small selection of equipment and constructs.<br><br>"

	text += "<font color='red'><b>Equipment:</b></font><br><br>"

	text += "<font color='red'><b>Cult Blade</b></font><br>Cult blades are sharp weapons that, notably, cannot be used by noncultists. These blades are produced by the Talisman of Arming.<br><br>"

	text += "<font color='red'><b>Cult Bola</b></font><br>Cult bolas are strong bolas, useful for snaring targets. These bolas are produced by the Talisman of Arming.<br><br>"

	text += "<font color='red'><b>Cult Robes</b></font><br>Cult robes are heavily armored robes. These robes are produced by the Talisman of Arming.<br><br>"

	text += "<font color='red'><b>Soulstone</b></font><br>A soulstone is a simple piece of magic, produced either via the starter talisman or by sacrificing humans. Using it on an unconscious or dead human, or on a Shade, will trap their soul in the stone, allowing its use in construct shells. \
	<br>The soul within can also be released as a Shade by using it in-hand.<br><br>"

	text += "<font color='red'><b>Construct Shell</b></font><br>A construct shell is useless on its own, but placing a filled soulstone within it allows you to produce your choice of a <b>Wraith</b>, a <b>Juggernaut</b>, or an <b>Artificer</b>. \
	<br>Each construct has uses, detailed below in Constructs. Construct shells can be produced via the starter talisman or the Rite of Fabrication.<br><br>"

	text += "<font color='red'><b>Constructs:</b></font><br><br>"

	text += "<font color='red'><b>Shade</b></font><br>While technically not a construct, the Shade is produced when released from a soulstone. It is quite fragile and has weak melee attacks, but is fully healed when recaptured by a soulstone.<br><br>"

	text += "<font color='red'><b>Wraith</b></font><br>The Wraith is a fast, lethal melee attacker which can jaunt through walls. However, it is only slightly more durable than a shade.<br><br>"

	text += "<font color='red'><b>Juggernaut</b></font><br>The Juggernaut is a slow, but durable, melee attacker which can produce temporary forcewalls. It will also reflect most lethal energy weapons.<br><br>"

	text += "<font color='red'><b>Artificer</b></font><br>The Artificer is a weak and fragile construct, able to heal other constructs, shades, or itself, produce more <font color='red'><b>soulstones</b></font> and <font color='red'><b>construct shells</b></font>, \
	construct fortifying cult walls and flooring, and finally, it can release a few indiscriminate stunning missiles.<br><br>"

	text += "<font color='red'><b>Harvester</b></font><br>If you see one, know that you have done all you can and your life is void.<br><br>"

	var/datum/browser/popup = new(user, "tome", "", 800, 600)
	popup.set_content(text)
	popup.open()
	return 1

/obj/item/weapon/tome/proc/scribe_rune(mob/living/user)
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
	Turf = get_turf(user) //we may have moved. adjust as needed...
	if(locate(/obj/effect/rune) in Turf)
		user << "<span class='cult'>There is already a rune here.</span>"
		return
	if(!Adjacent(user) || !src || qdeleted(src) || user.incapacitated())
		return
	if(ispath(rune_to_scribe, /obj/effect/rune/narsie))
		if(ticker.mode.name == "cult")
			var/datum/game_mode/cult/cult_mode = ticker.mode
			if(!("eldergod" in cult_mode.cult_objectives))
				user << "<span class='warning'>Nar-Sie does not wish to be summoned!</span>"
				return
			else if(cult_mode.sacrifice_target && !(cult_mode.sacrifice_target in sacrificed))
				user << "<span class='warning'>The sacrifice is not complete. The portal would lack the power to open if you tried!</span>"
				return
			else if(!cult_mode.eldergod)
				user << "<span class='cultlarge'>\"I am already here. There is no need to try to summon me now.\"</span>"
				return
			var/confirm_final = alert(user, "This is the FINAL step to summon Nar-Sie, it is a long, painful ritual and the crew will be alerted to your presence", "Are you prepared for the final battle?", "My life for Nar-Sie!", "No")
			if(confirm_final == "No")
				user << "<span class='cult'>You decide to prepare further before scribing the rune.</span>"
				return
			var/area/A = get_area(src)
			var/locname = initial(A.name)
			priority_announce("Figments from an eldritch god are being summoned by [user] into [locname] from an unknown dimension. Disrupt the ritual at all costs!","Central Command Higher Dimensionsal Affairs", 'sound/AI/spanomalies.ogg')
			for(var/B in spiral_range_turfs(1, user, 1))
				var/turf/T = B
				var/obj/machinery/shield/N = new(T)
				N.name = "Rune-Scriber's Shield"
				N.desc = "A potent shield summoned by cultists to protect them while they prepare the final ritual"
				N.icon_state = "shield-red"
				N.health = 60
				shields |= N
		else
			user << "<span class='warning'>Nar-Sie does not wish to be summoned!</span>"
			return
	user.visible_message("<span class='warning'>[user] cuts open their arm and begins writing in their own blood!</span>", \
						 "<span class='cult'>You slice open your arm and begin drawing a sigil of the Geometer.</span>")
	user.apply_damage(initial(rune_to_scribe.scribe_damage), BRUTE, pick("l_arm", "r_arm"))
	if(!do_after(user, initial(rune_to_scribe.scribe_delay), target = get_turf(user)))
		for(var/V in shields)
			var/obj/machinery/shield/S = V
			if(S && !qdeleted(S))
				qdel(S)
		return
	if(locate(/obj/effect/rune) in Turf)
		user << "<span class='cult'>There is already a rune here.</span>"
		return
	user.visible_message("<span class='warning'>[user] creates a strange circle in their own blood.</span>", \
						 "<span class='cult'>You finish drawing the arcane markings of the Geometer.</span>")
	for(var/V in shields)
		var/obj/machinery/shield/S = V
		if(S && !qdeleted(S))
			qdel(S)
	new rune_to_scribe(Turf, chosen_keyword)
	user << "<span class='cult'>The [lowertext(initial(rune_to_scribe.cultist_name))] rune [initial(rune_to_scribe.cultist_desc)]</span>"
