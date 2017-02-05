//Ordered by traitor librarians. Gives access to some weaker runes and provides basic tome functionality.
/obj/item/weapon/abridged_tome
	name = "arcane tome"
	desc = "An old, dusty tome with dog-eared edges and a sinister-looking cover. Its pages look well-thumbed."
	icon_state ="tome_old"
	throw_speed = 2
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	var/datum/mind/reader //The person "attuned" to this tome

/obj/item/weapon/abridged_tome/proc/is_reader(mob/living/user) //Checks if the mob using the tome is the person attuned to it
	return user && user.mind && user.mind == reader

/obj/item/weapon/abridged_tome/examine(mob/living/user)
	..()
	if(is_reader(user) || user.stat == DEAD)
		user << "<span class='cult'>An old version of the arcane tome no longer in circulation. This one reached #1 on Acribus' Top Reads list.</span>"
		user << "<span class='cult'>Used to scribe certain runes, and can also be used as a powerful burn weapon.</span>"

/obj/item/weapon/abridged_tome/attack(mob/living/M, mob/living/user)
	if(!is_reader(user))
		return ..()
	if(iscultist(M))
		if(M.reagents && M.reagents.has_reagent("holywater"))
			user << "<span class='cult'>You remove the holy water from [M].</span>"
			var/holy2unholy = M.reagents.get_reagent_amount("holywater")
			M.reagents.del_reagent("holywater")
			M.reagents.add_reagent("unholywater",holy2unholy)
			add_logs(user, M, "smacked", src, " removing the holy water from them")
		return
	M.take_bodypart_damage(0, rand(5, 20)) //Damage done is a throwback to the damage that actual tomes used to do
	playsound(M, 'sound/weapons/sear.ogg', 50, 1)
	M.visible_message("<span class='danger'>[user] strikes [M] with the arcane tome!</span>", \
					  "<span class='userdanger'>[user] strikes you with the tome, searing your flesh!</span>")
	user.do_attack_animation(M)
	add_logs(user, M, "smacked", src)

/obj/item/weapon/abridged_tome/attack_self(mob/living/user)
	if(!is_reader(user))
		if(!reader)
			user << "<span class='notice'>You cut open a finger and press a droplet of blood onto [src]'s pages. You can read them now.</span>"
			user.take_bodypart_damage(0.1)
			reader = user.mind
			return
		user << "<span class='warning'>[src] seems full of unintelligible shapes, scribbles, and notes. They all seem particularly boring.</span>"
		return
	open_tome(user)

/obj/item/weapon/abridged_tome/proc/open_tome(mob/user)
	switch(alert(user,"You open the tome...",,"Scribe Rune","More Information","Cancel"))
		if("Scribe Rune")
			scribe_rune(user)
		if("More Information")
			read_tome(user)
		if("Cancel")
			return

/obj/item/weapon/abridged_tome/proc/read_tome(mob/user)
	var/text = "<i>There's an old introduction to aspiring cultists here, but it seems to have been scribbled over. There's some stuff written in a footnote below it...</i><br><br>"
	text += "<font size=3><b>This version of the tome is abridged so you don't go insane from reading it. Below is a list of the runes you can write with this one.</b></font><br><br>"
	text += "<font color='red'><b>Astral Communion</b></font> is the only rune in here that isn't watered down from its actual version. Using it will allow you to wander the spirit realm as a \
	ghost for as long as you're alive. Bear in mind that your actual body is completely vulnerable, and will constantly take damage while you're a spirit.<br><br>"
	text += "<font color='red'><b>Fry Circuits</b></font> sends out a moderately-sized EMP blast.<br><br>"
	text += "<font color='red'><b>Make Talisman</b></font> functions like the normal Create Talisman rune, but the talismans it creates are weaker. To use, write the rune and put some paper \
	on top of it, then put a rune that can be made into a talisman nearby and invoke the talisman rune. If you've done everything right, the paper will become a talisman and the other \
	rune will disappear.<br><br>"
	text += "<font color='red'><b>Phase Walk</b></font> is something that the new editions don't include. Using it will allow you to walk through walls while active, but you must stay within \
	three tiles of the rune to do so.<br><br>"
	text += "<font color='red'><b>Stun</b></font> is considered a war crime by the cult and has been purged from most archives, but we managed to get a manuscript of how to use it. When you \
	invoke it, it just blinds and briefly knocks down everyone nearby. Not particularly useful; its real strength lies in the talisman it can be used to make - see below.<br><br>"
	text += "<font color='red'><b>Warp</b></font> lets you set up a network of transportation runes that you can teleport between at will. Teleportation takes time and is loud, in comparison to \
	the silent, instant teleportation that Nar-Sian cultists can do. You're teleported randomly, so it may take you some time to get where you actually need to go.<br><br>"
	text += "The <font color='red'><b>EMP Talisman</b></font> is made from a Fry Circuits rune and emits a small EMP blast. Consumed on use.<br><br>"
	text += "The <font color='red'><b>Stun Talisman</b></font> is made from a Stun rune. Extremely infamous for its use in ages prior, attacking someone with it will blind them, knock them down, \
	and slur their speech for a short time. Like any bootleg talisman, though, this is incredibly loud and obvious. Consumed on use.<br><br>"
	text += "The <font color='red'><b>Warp Talisman</b></font> is made from a Warp rune and instantly teleports you to a random Warp rune. Consumed on use.<br><br>"
	var/datum/browser/popup = new(user, "tome", "", 800, 600)
	popup.set_content(text)
	popup.open()
	return 1

/obj/item/weapon/abridged_tome/proc/scribe_rune(mob/living/user)
	var/list/rune_lineup = list()
	var/obj/effect/bootleg_rune/rune_type
	for(var/V in subtypesof(/obj/effect/bootleg_rune))
		rune_type = V
		rune_lineup[initial(rune_type.reader_name)] = rune_type
	if(!rune_lineup.len)
		return
	var/chosen_rune = input(user, "Choose a rune to scribe.", name) as null|anything in rune_lineup
	if(!chosen_rune || !src || qdeleted(src) || !Adjacent(user) || user.incapacitated())
		return
	rune_type = rune_lineup[chosen_rune] //No need to have another var when we have one already up
	user.visible_message("<span class='warning'>[user] edgily cuts open their arm and begins writing in their own blood!</span>", \
	"<span class='cult'>You slice open your arm and begin drawing a sigil of the Geometer. How edgy.</span>")
	user.adjustBruteLoss(initial(rune_type.scribe_damage))
	if(!do_after(user, initial(rune_type.scribe_delay), target = user))
		return
	user.visible_message("<span class='warning'>[user] creates a strange circle in their own blood!</span>", "<span class='cult'>You finish drawing the arcane markings of the Geometer.</span>")
	var/obj/effect/bootleg_rune/B = new rune_type (get_turf(user))
	B.reader = reader
	return 1


// bootleg runes go below this line //

/obj/effect/bootleg_rune
	name = "bootleg rune" //Yes, this is what people will see when examining. No, I don't care.
	desc = "A rune stolen from actual cultists."
	anchored = 1
	icon = 'icons/obj/rune.dmi'
	icon_state = "1"
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	layer = LOW_OBJ_LAYER
	color = "#FF0000"
	var/reader_name = "Knockoff Rune"
	var/reader_desc = "A Great Value brand rune."
	var/invocation = "Aiy ele-mayo!"
	var/rune_in_use = 0 // Used for some runes, this is for when you want a rune to not be usable when in use.
	var/scribe_delay = 50 //how long the rune takes to create
	var/scribe_damage = 0.1 //how much damage you take doing it
	var/obj/item/weapon/paper/bootleg_talisman/talisman_type //If applicable, the type of talisman this rune can be made into
	var/datum/mind/reader

/obj/effect/bootleg_rune/proc/is_reader(mob/living/user)
	return user && user.mind && user.mind == reader

/obj/effect/bootleg_rune/proc/invoke(mob/living/user) //Unique effects go here.

/obj/effect/bootleg_rune/examine(mob/user)
	..()
	if(is_reader(user) || user.stat == DEAD)
		user << "<b>Name:</b> [reader_name]"
		user << "<b>Use:</b> [reader_desc]"
		user << "<b>Talisman Compatible:</b> [talisman_type ? "Yes" : "No"]"

/obj/effect/bootleg_rune/attack_hand(mob/living/user)
	if(!is_reader(user))
		user << "<span class='warning'>You can't mouth the words without fumbling over them.</span>"
		return
	if(rune_in_use)
		return
	if(invoke(user))
		user.say(invocation)
	else
		visible_message("<span class='warning'>The markings pulse with a small burst of red light, then fall dark.</span>")

/obj/effect/bootleg_rune/attackby(obj/I, mob/user, params)
	if(istype(I, /obj/item/weapon/abridged_tome) && is_reader(user))
		user << "<span class='notice'>You erase the [lowertext(reader_name)] rune.</span>"
		qdel(src)
		return
	else if(istype(I, /obj/item/weapon/nullrod))
		user.say("BEGONE FOUL MAGIKS!!")
		user << "<span class='danger'>You disrupt the cheap magic of [src] with [I].</span>"
		qdel(src)
		return
	return


/obj/effect/bootleg_rune/astral_communion
	reader_name = "Astral Communion"
	reader_desc = "Allows you to wander the spirit world for a limited time."
	invocation = "Fwesh mah erl nyag rya!"
	icon_state = "7"
	color = "#0000FF"
	rune_in_use = 0
	var/mob/living/affecting

/obj/effect/bootleg_rune/astral_communion/examine(mob/user)
	..()
	if(affecting)
		user << "<span class='warning'>[affecting] is surrounded by unearthly energies!</span>"

/obj/effect/bootleg_rune/astral_communion/invoke(mob/living/user)
	rune_in_use = 1
	affecting = user
	user.visible_message("<span class='warning'>[user] freezes statue-still, their eyes glazing over...</span>", \
						 "<span class='cult'>You find yourself in the spirit world. Neat. Your body is wasting away, though... hurry!</span>")
	user.ghostize(1)
	START_PROCESSING(SSfastprocess, src)
	user.loc = get_turf(src)
	user.setDir(NORTH)
	user.color = color
	return 1

/obj/effect/bootleg_rune/astral_communion/process()
	if(!affecting)
		return
	affecting.adjustBruteLoss(0.1)
	if(affecting.loc != get_turf(src))
		affecting.visible_message("<span class='warning'>A spectral tendril wraps around [affecting] and pulls [affecting.p_them()] back to the rune!</span>")
		Beam(affecting,icon_state="b_beam",time=2)
		sleep(2)
		affecting.forceMove(get_turf(src))
		affecting.setDir(NORTH)
	if(affecting.key)
		affecting.visible_message("<span class='warning'>[affecting] slowly relaxes, the glow around [affecting.p_them()] dimming.</span>", \
							 "<span class='cult'>You are re-united with your physical form. [src] releases its hold over you.</span>")
		animate(affecting, color = initial(affecting.color), time = 30)
		affecting.Weaken(3)
		rune_in_use = 0
		affecting = null
		STOP_PROCESSING(SSfastprocess, src)
		return
	if(!affecting.stat && affecting.health <= 50)
		if(prob(1))
			var/mob/dead/observer/G = affecting.get_ghost()
			G << "<span class='cultitalic'>Maybe you should go back...</span>"
	if(affecting.stat == UNCONSCIOUS)
		if(prob(1))
			var/mob/dead/observer/G = affecting.get_ghost()
			G << "<span class='cultitalic'>You feel the link between you and your body weakening... you must hurry!</span>"
	if(affecting.stat == DEAD)
		affecting.color = initial(affecting.color)
		rune_in_use = 0
		affecting = null
		var/mob/dead/observer/G = affecting.get_ghost()
		G << "<span class='cultitalic'><b>You suddenly feel your physical form pass on. [src]'s exertion has killed you!</b></span>"
		STOP_PROCESSING(SSfastprocess, src)
		return


/obj/effect/bootleg_rune/fry_circuits
	reader_name = "Fry Circuits"
	reader_desc = "Emits a moderately-sized EMP."
	invocation = "Tagh faraqha fel damar det!"
	icon_state = "5"
	color = "#0000FF"
	talisman_type = /obj/item/weapon/paper/bootleg_talisman/fry_circuits

/obj/effect/bootleg_rune/fry_circuits/invoke(mob/living/user)
	visible_message("<span class='warning'>[src] glows blue for a moment before vanishing.</span>")
	playsound(src, 'sound/items/Welder2.ogg', 25, 1)
	user << "<span class='cultitalic'>You feel a minute vibration pass through you...</span>"
	empulse(src, 4, 10)
	qdel(src)


/obj/effect/bootleg_rune/make_talisman
	reader_name = "Make Talisman"
	reader_desc = "Transforms compatible runes into portable talismans."
	invocation = "Hdrak vloso, mirkanas verbot!"
	icon_state = "3"
	color = "#FF00FF"

/obj/effect/bootleg_rune/make_talisman/invoke(mob/living/user)
	var/list/nearby_runes = list()
	var/list/papers = list()
	var/obj/item/weapon/paper/bootleg_talisman/talisman_type
	for(var/obj/effect/bootleg_rune/B in range(1, src))
		if(B.talisman_type)
			nearby_runes[B.reader_name] = B.talisman_type
	if(!nearby_runes.len)
		user << "<span class='warning'>There are no compatible runes adjacent to this one!</span>"
		return
	var/rune_name = input(user, "Choose a rune to make into a talisman.", reader_name) as null|anything in nearby_runes
	if(!src || qdeleted(src) || !rune_name || !user.Adjacent(src) || user.incapacitated())
		return
	talisman_type = nearby_runes[rune_name]
	for(var/obj/item/weapon/paper/P in loc)
		if(!istype(P, /obj/item/weapon/paper/talisman) && !istype(P, /obj/item/weapon/paper/bootleg_talisman))
			papers += P
	if(!papers.len)
		user << "<span class='warning'>There are no papers on top of [src]!</span>"
		return
	var/obj/item/weapon/paper/THE_CHOSEN_PAPER = pick(papers)
	var/obj/item/weapon/paper/bootleg_talisman/new_talisman = new talisman_type (get_turf(src))
	visible_message("<span class='warning'>Bloody images form on [THE_CHOSEN_PAPER]!</span>")
	new_talisman.pixel_y = rand(-2, 2)
	new_talisman.pixel_y = rand(-2, 2)
	flick("paper_talisman", src)
	qdel(THE_CHOSEN_PAPER)
	for(var/obj/effect/bootleg_rune/B in range(1, src)) //This is silly, but because of how the assoc. list works is required
		if(B.talisman_type == new_talisman.type)
			qdel(B)
			return 1
	return


/obj/effect/bootleg_rune/phase_walk
	reader_name = "Phase Walk"
	reader_desc = "Allows incorporeal movement within a three-tile radius."
	invocation = "Lats git spuki!"
	color = "#FF0000"
	var/toggled = 0
	var/mob/living/spooky_ghost

/obj/effect/bootleg_rune/phase_walk/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	if(toggled && spooky_ghost && spooky_ghost.incorporeal_move) //Nice try!
		spooky_ghost.visible_message("<span class='warning'>[spooky_ghost] pops back into reality!</span>", "<span class='cult'>You feel normal again.</span>")
		spooky_ghost.floating = 0
		playsound(spooky_ghost, 'sound/magic/Ethereal_Exit.ogg', 50, 1)
		spooky_ghost.alpha = initial(spooky_ghost.alpha)
		spooky_ghost.incorporeal_move = 0
		spooky_ghost.Weaken(3)
	return ..()


/obj/effect/bootleg_rune/phase_walk/invoke(mob/living/user)
	if(user.incorporeal_move && !toggled)
		user << "<span class='warning'>You're already incorporeal!</span>"
		return
	toggled = !toggled
	if(toggled)
		user.visible_message("<span class='warning'>[user] fades partially out of existence!</span>", "<span class='cult'>You feel strangely light.</span>")
		user.floating = 1
		playsound(user, 'sound/magic/Ethereal_Enter.ogg', 50, 1)
		user.alpha = 150
		user.incorporeal_move = 3
		spooky_ghost = user
		START_PROCESSING(SSfastprocess, src)
	else
		user.visible_message("<span class='warning'>[user] pops back into reality!</span>", "<span class='cult'>You feel normal again.</span>")
		user.floating = 0
		playsound(user, 'sound/magic/Ethereal_Exit.ogg', 50, 1)
		user.alpha = initial(user.alpha)
		user.incorporeal_move = 0
		spooky_ghost = null
		STOP_PROCESSING(SSfastprocess, src)
	return 1

/obj/effect/bootleg_rune/phase_walk/process()
	if(!toggled || !spooky_ghost)
		return
	if(get_dist(spooky_ghost, src) > 3)
		spooky_ghost << "<span class='boldwarning'>You're yanked back to [src]! You can't go that far!</span>"
		spooky_ghost.forceMove(get_turf(src))
		spooky_ghost.Weaken(1)


/obj/effect/bootleg_rune/stun
	reader_name = "Stun"
	reader_desc = "Blinds anyone nearby, and knocks over anyone adjacent."
	invocation = "Fuuma jin!"
	icon_state = "3"
	color = "#0000FF"
	talisman_type = /obj/item/weapon/paper/bootleg_talisman/stun

/obj/effect/bootleg_rune/stun/invoke(mob/living/user)
	visible_message("<span class='warning'>[src] explodes in a flash of red light!</span>")
	playsound(src, 'sound/effects/phasein.ogg', 50, 1)
	for(var/mob/living/L in view(7, src))
		L.flash_act(1, 1)
	for(var/mob/living/L in range(1, src))
		L.Weaken(3)
	qdel(src)
	return 1


var/list/warp_runes = list() //Every warp rune in existence
/obj/effect/bootleg_rune/warp
	reader_name = "Warp"
	reader_desc = "Teleports you to other warp runes when invoked."
	invocation = "Sasso carta forbici!"
	color = "#0000FF"
	talisman_type = /obj/item/weapon/paper/bootleg_talisman/warp

/obj/effect/bootleg_rune/warp/New()
	..()
	warp_runes += src

/obj/effect/bootleg_rune/warp/Destroy()
	warp_runes -= src
	return ..()

/obj/effect/bootleg_rune/warp/invoke(mob/living/user)
	if(warp_runes.len <= 1)
		user << "<span class='warning'>There are no other warp runes!</span>"
		return
	user.audible_message("<span class='notice'>You start chanting [src]'s words...</span>", "<span class='warning'>[user] starts chanting in tongues!</span>")
	if(!do_after(user, 30, target = src))
		return
	user.visible_message("<span class='warning'>[user] vanishes in a flash of red light!</span>", "<span class='cult'>Your vision blurs, and you messily appear somewhere else.</span>")
	var/obj/new_rune = pick(warp_runes - src)
	new_rune.visible_message("<span class='warning'>[user] appears in a flash of red light! And blood. Gross.</span>")
	user.forceMove(get_turf(new_rune))
	playsound(src, 'sound/magic/enter_blood.ogg', 50, 1)
	playsound(user, 'sound/magic/exit_blood.ogg', 50, 1)
	var/old_color = user.color //So as to retain any discoloration
	user.color = rgb(255, 0, 0)
	animate(user, color = old_color, time = 50)
	return 1


/obj/item/weapon/paper/bootleg_talisman //Portable versions of certain runes with different effects.
	name = "bootleg talisman"
	desc = "A talisman stolen from actual cultists."
	var/reader_name = "Knockoff Talisman"
	var/reader_desc = "A Great Value brand talisman."
	var/invocation = "I ran out of ideas for invocations, sorry."

/obj/item/weapon/paper/bootleg_talisman/attack_self(mob/living/user)
	return

/obj/item/weapon/paper/bootleg_talisman/attack(mob/living/target, mob/living/user)
	return


/obj/item/weapon/paper/bootleg_talisman/fry_circuits
	reader_name = "EMP Talisman"
	reader_desc = "Emits a small EMP blast."
	invocation = "Tagh faraqha fel damar det!"

/obj/item/weapon/paper/bootleg_talisman/fry_circuits/attack_self(mob/living/user)
	user.say(invocation)
	empulse(user, 2, 5)
	user.drop_item()
	qdel(src)


/obj/item/weapon/paper/bootleg_talisman/stun
	reader_name = "Stun Talisman"
	reader_desc = "Stuns, blinds, and mutes the person you attack."
	invocation = "Fuuma jin!"

/obj/item/weapon/paper/bootleg_talisman/stun/New()
	..()
	if(prob(5))
		new/obj/item/weapon/paper/bootleg_talisman/imitation_stun(get_turf(src)) //That's what you get for trusting knockoffs!
		qdel(src)

/obj/item/weapon/paper/bootleg_talisman/stun/attack(mob/living/target, mob/living/user)
	if(user == target)
		return
	user.visible_message("<span class='warning'>[user] holds up [src], which explodes in a flash of red light!</span>", "<span class='cult'>You hold up the [reader_name]!</span>")
	user.say(invocation)
	target.Stun(4)
	target.Weaken(4)
	target.flash_act(1, 1)
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		C.cultslurring += 4
		C.Jitter(4)
	user.drop_item()
	qdel(src)


/obj/item/weapon/paper/bootleg_talisman/imitation_stun //No, this isn't a replacement stun paper. It's a cheap knockoff, it doesn't work.
	reader_name = "\"Stun\" Talisman"
	reader_desc = "Stuns, blinds, and mutes the person you attack. At least, that's what it says on the box."
	invocation = "Dream sign \'evil sealing talisman\'!"

/obj/item/weapon/paper/bootleg_talisman/imitation_stun/attack(mob/living/target, mob/living/user)
	if(user == target)
		return
	user.visible_message("<span class='warning'>[user] holds up [src]!</span>", "<span class='cult'>You hold up the [reader_name]!</span>")
	user.say(invocation)
	switch(rand(1, 10)) //Yep, luck-based talismans. Welcome to knockoffs!
		if(1) //The talisman explodes in the user's face, stunning them and silencing them for a ridiculous duration.
			user.visible_message("<span class='warning'>[src] explodes on [user]'s face!</span>", "<span class='cultitalic'><b>AND IT EXPLODES IN YOUR FACE GOD FUCKING DAMN IT</b></span>")
			playsound(user, 'sound/weapons/flashbang.ogg', 75, 1)
			user << 'sound/weapons/flash_ring.ogg'
			user.Stun(10)
			user.Weaken(10)
			user.flash_act(1,1)
			if(iscarbon(user))
				var/mob/living/carbon/C = user
				C.silent += 5
				C.stuttering += 15
				C.cultslurring += 15
				C.Jitter(15)
		if(2) //The talisman spawns a confused artificer.
			user.visible_message("<span class='warning'>A confused artificer appears in front of [user]!</span>", "<span class='cultitalic'>And a confused, angry artificer appears. Fuck.</span>")
			playsound(user, 'sound/effects/phasein.ogg', 50, 1)
			playsound(user, 'sound/effects/Reee.ogg', 100, 0)
			new/mob/living/simple_animal/hostile/construct/builder/hostile(get_turf(user))
		if(3) //The invoker is slammed into the ground.
			user.visible_message("<span class='warning'>[src] causes a blast of force!</span>", "<span class='cultitalic'>And it sends you flying to the ground. Yay.</span>")
			playsound(user, 'sound/magic/Repulse.ogg', 50, 1)
			user.Weaken(3)
		if(4) //Both the user and the target are set on fire.
			user << "<span class='cultitalic'><b>OHGODFIREITBURNS</b></span>"
			playsound(user, 'sound/magic/Fireball.ogg', 50, 1)
			playsound(target, 'sound/magic/Fireball.ogg', 50, 1)
			user.adjust_fire_stacks(5)
			target.adjust_fire_stacks(5)
			user.IgniteMob()
			target.IgniteMob()
		if(5) //Nothing happens. Really the best result you can hope for.
			user.visible_message("<span class='warning'>Literally nothing happens.</span>", "<span class='cult'>Literally nothing happens. You can't be serious.</span>")
		if(6) //Both the user and the target are fully healed.
			user.visible_message("<span class='notice'>[user] and [target] regenerate all wounds!</span>", "<span class='cult'>And you both regenerate all injuries. Oh well.</span>")
			playsound(user, 'sound/magic/Staff_Healing.ogg', 50, 1)
			playsound(target, 'sound/magic/Staff_Healing.ogg', 50, 1)
			user.fully_heal()
			target.fully_heal()
		if(7) //The target drops whatever they're holding.
			user << "<span class='cult'>And they drop what they're holding!</span>"
			target.visible_message("<span class='warning'>[target]'s hand convulses!</span>", "<span class='userdanger'>Your hand suddenly forces itself open!</span>")
			target.drop_item()
		if(8) //The target is slightly confused.
			user << "<span class='cult'>And they're very slightly confused! Wow!</span>"
			target << "<span class='warning'>You feel mildly confused.</span>"
			playsound(user, 'sound/magic/Blind.ogg', 50, 1)
			target.confused += 5
		if(9) //The target is frozen in place for one second.
			user << "<span class='cultitalic'><b>AND IT WORKS!</b> Wait, nevermind...</span>"
			target.Stun(1)
		if(10) //The target is blinded and knocked down for a few seconds.
			user.visible_message("<span class='warning'>[src] explodes in a flash of off-brand red light!</span>", "<span class='cultitalic'><b>IT WORKED!! HOLY SHIT, IT WORKED!!</b></span>")
			target.flash_act(1, 1)
			target.Weaken(3)
	user.drop_item()
	qdel(src)


/obj/item/weapon/paper/bootleg_talisman/warp
	reader_name = "Warp Talisman"
	reader_desc = "Teleports you to a random warp rune."
	invocation = "Sasso carta forbici!"

/obj/item/weapon/paper/bootleg_talisman/warp/attack_self(mob/living/user)
	user.visible_message("<span class='warning'>[user] holds up [src]!</span>", "<span class='cult'>You hold up the [reader_name]!</span>")
	user.say(invocation)
	var/obj/effect/bootleg_rune/warp/destination = pick(warp_runes)
	if(!destination)
		user.visible_message("<span class='danger'>Nothing happens...</span>", "<span class='cultitalic'>Nothing happens!</span>")
		return
	var/turf/T = get_turf(user)
	user.forceMove(get_turf(destination))
	T.visible_message("<span class='warning'>[user] is pulled through [src]!</span>")
	playsound(T, 'sound/magic/enter_blood.ogg', 50, 1)
	user.visible_message("<span class='warning'>[user] appears in a flash of red light! And blood. Gross.</span>", "<span class='cult'>Your vision blurs, and you messily appear somewhere else.</span>")
	playsound(user, 'sound/magic/exit_blood.ogg', 50, 1)
	var/old_color = user.color
	user.color = rgb(255, 0, 0)
	animate(user, color = old_color, time = 30)
	user.drop_item()
	qdel(src)
	return 1
