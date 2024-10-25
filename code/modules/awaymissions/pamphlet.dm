/obj/item/paper/pamphlet
	name = "pamphlet"
	icon_state = "pamphlet"
	show_written_words = FALSE

/obj/item/paper/pamphlet/radstorm
	name = "pamphlet - \'Radstorm Safety Measures and How to Not Become Monkey\'"
	default_raw_text = "Has your station's preemptive radstorm safety alarm gone off and you don't see a nearby maintenance hatch to escape to? Never fear, for NT truly thinks of everything! \
		Several public-access shelters have been installed around the upper station with express purpose of protecting your fragile meaty bits from becoming the next medical disaster! \
		Please see subsection 4.3 V2-3 in your employee handbook for appropriate procedures to deal with excessive radiation damage if you do not make it to a shelter in time."


/obj/item/paper/pamphlet/violent_video_games
	name = "pamphlet - \'Violent Video Games and You\'"
	desc = "A pamphlet encouraging the reader to maintain a balanced lifestyle and take care of their mental health, while still enjoying video games in a healthy way. You probably don't need this..."
	default_raw_text = "They don't make you kill people. There, we said it. Now get back to work!"

/obj/item/paper/pamphlet/gateway
	default_raw_text = "<b>Welcome to the Nanotrasen Gateway project...</b><br>\
			Congratulations! If you're reading this, you and your superiors have decided that you're \
			ready to commit to a life spent colonising the rolling hills of far away worlds. You \
			must be ready for a lifetime of adventure, a little bit of hard work, and an award \
			winning dental plan- but that's not all the Nanotrasen Gateway project has to offer.<br>\
			<br>Because we care about you, we feel it is only fair to make sure you know the risks \
			before you commit to joining the Nanotrasen Gateway project. All away destinations have \
			been fully scanned by a Nanotrasen expeditionary team, and are certified to be 100% safe. \
			We've even left a case of space beer along with the basic materials you'll need to expand \
			Nanotrasen's operational area and start your new life.<br><br>\
			<b>Gateway Operation Basics</b><br>\
			All Nanotrasen approved Gateways operate on the same basic principals. They operate off \
			area equipment power as you would expect, and without this supply, it cannot safely function, \
			causinng it to reject all attempts at operation.<br><br>\
			Once it is correctly setup, and once it has enough power to operate, the Gateway will begin \
			searching for an output location. The amount of time this takes is variable, but the Gateway \
			interface will give you an estimate accurate to the minute. Power loss will not interrupt the \
			searching process. Influenza will not interrupt the searching process. Temporal anomalies \
			may cause the estimate to be inaccurate, but will not interrupt the searching process.<br><br> \
			<b>Life On The Other Side</b><br>\
			Once you have traversed the Gateway, you may experience some disorientation. Do not panic. \
			This is a normal side effect of travelling vast distances in a short period of time. You should \
			survey the immediate area, and attempt to locate your complimentary case of space beer. Our \
			expeditionary teams have ensured the complete safety of all away locations, but in a small \
			number of cases, the Gateway they have established may not be immediately obvious. \
			Do not panic if you cannot locate the return Gateway. Begin colonisation of the destination. \
			<br><br><b>A New World</b><br>\
			As a participant in the Nanotrasen Gateway Project, you will be on the frontiers of space. \
			Though complete safety is assured, participants are advised to prepare for inhospitable \
			environs."

/obj/item/paper/pamphlet/cybernetics
	name = "pamphlet - 'Synthman's Cybernetic Starter Gear!'"
	default_raw_text = "Join the Body Modder Revolution today! We are offering FREE SAMPLES of the latest and greatest \
		cybernetic augments by Synthman Co. to you in this rare exclusive offer! With this letter, you are being gifted a \
		special limited edition choice NTSDA-certified grade-A cybernetic implant, FREE OF CHARGE! Build up your body to \
		GREATNESS with Synthman's new exclusive line of cybernetic products! Become greater, stronger, and BETTER today!"
	var/obj/item/organ/heart/cybernetic/sample

/obj/item/paper/pamphlet/cybernetics/Initialize(mapload)
	. = ..()
	sample = new(src)
	update_desc()

/obj/item/paper/pamphlet/cybernetics/update_desc(updates)
	. = ..()
	desc = "A pamphlet encouraging the reader to implant themselves.[sample ? " Has an attached \"sample\"..." : ""]"

/obj/item/paper/pamphlet/cybernetics/Destroy()
	QDEL_NULL(sample)
	return ..()

/obj/item/paper/pamphlet/cybernetics/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == sample)
		sample = null
		update_desc()

/obj/item/paper/pamphlet/cybernetics/attack_self(mob/user, modifiers)
	. = ..()
	to_chat(user, span_notice("As you read the pamphlet, a free sample falls out!"))
	sample.forceMove(drop_location())
	playsound(sample, 'sound/misc/splort.ogg', 50, vary = TRUE)
