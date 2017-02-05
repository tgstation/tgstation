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
	text += "<font color='red'><b>Phase Walk</b></font> is something that the new editions don't include. Using it will allow you to walk through walls while active, but you take more damage \
	from all sources and the effect only applies when you're within around a three-tile radius.<br><br>"
	text += "<font color='red'><b>Stun</b></font> is considered a war crime by the cult and has been purged from most archives, but we managed to get a manuscript of how to use it. When you \
	invoke it, it just blinds and briefly knocks down everyone nearby. Not particularly useful; its real strength lies in the talisman it can be used to make - see below.<br><br>"
	text += "<font color='red'><b>Warp</b></font> lets you set up a network of transportation runes that you can teleport between at will. Teleportation takes time and is loud, in comparison to \
	the silent, instant teleportation that Nar-Sian cultists can do. You're teleported randomly, so it may take you some time to get where you actually need to go.<br><br>"
	text += "The <font color='red'><b>EMP Talisman</b></font> is made from a Fry Circuits rune and emits a small EMP blast. Consumed on use.<br><br>"
	text += "The <font color='red'><b>Stun Talisman</b></font> is made from a Stun rune. Extremely infamous for its use in ages prior, attacking someone with it will blind them, knock them down, \
	and slur their speech for a short time. Like any bootleg talisman, though, this is incredibly loud and obvious. Consumed on use."
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
	var/datum/mind/reader

/obj/effect/bootleg_rune/proc/is_reader(mob/living/user)
	return user && user.mind && user.mind == reader

/obj/effect/bootleg_rune/proc/invoke(mob/living/user) //Unique effects go here.

/obj/effect/bootleg_rune/examine(mob/user)
	..()
	if(is_reader(user) || user.stat == DEAD)
		user << "<b>Name:</b> [reader_name]"
		user << "<b>Use:</b> [reader_desc]"

/obj/effect/bootleg_rune/attack_hand(mob/living/user)
	if(!is_reader(user))
		user << "<span class='warning'>You can't mouth the words without fumbling over them.</span>"
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

var/list/warp_runes = list() //Every warp rune in existence
/obj/effect/bootleg_rune/warp
	color = "#0000FF"
	invocation = "Sasso carta forbici!"
	reader_name = "Warp"
	reader_desc = "Teleports you to other warp runes when invoked."

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
	user.audible_message("<span class='notice'>You start chanting [src]'s words...</span>", "<span class='warning'>[user] begins chanting in tongues!</span>")
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
