/datum/surgery/advanced/extreme
	name = "Extreme Surgery"
	desc = "An extremely extreme experimental surgical procedure that probably does something."
	steps = list(/datum/surgery_step/stroke,
				/datum/surgery_step/honk,
				/datum/surgery_step/mechanic_wrench,
				/datum/surgery_step/toolbox,
				/datum/surgery_step/fork)

	possible_locs = list(BODY_ZONE_CHEST)

/datum/surgery_step/stroke
	name = "stroke belly"
	accept_hand = TRUE;
	time = 30

/datum/surgery_step/stroke/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You begin stroking [target]'s belly.</span>",
		"<span class='notice'>[user] begins to stroke [target]'s belly.</span>",
		"<span class='notice'>[user] begins to stroke [target]'s belly.</span>")

/datum/surgery_step/stroke/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results)
	display_results(user, target, "<span class='notice'>You succeed in stroking [target]'s belly'.</span>",
		"<span class='notice'>[user] successfully stroked [target]'s belly!</span>",
		"<span class='notice'>[user] successfully stroked [target]'s belly!</span>")
	return TRUE

/datum/surgery_step/honk
	name = "gently honk"
	implements = list(/obj/item/bikehorn = 100, /obj/item/bikehorn/rubberducky = 50)
	time = 20

/datum/surgery_step/honk/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You begin gently honking [target].</span>",
		"<span class='notice'>[user] begins to honk [target].</span>",
		"<span class='notice'>[user] begins to honk [target].</span>")

/datum/surgery_step/honk/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results)
	playsound(src, 'sound/items/bikehorn.ogg', 70)

	display_results(user, target, "<span class='notice'>You succeed in gently honking [target].</span>",
		"<span class='notice'>[user] successfully honked [target]!</span>",
		"<span class='notice'>[user] successfully honked [target]!</span>")
	return TRUE

/datum/surgery_step/toolbox
	name = "toolbox"
	implements = list(/obj/item/storage/toolbox = 100)
	time = 0

/datum/surgery_step/toolbox/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	return

/datum/surgery_step/toolbox/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results)
	user.a_intent = INTENT_HARM
	target.attackby(tool, user) //fucking hit them on harm intent with the toolbox

	display_results(user, target, "<span class='notice'>You toolbox [target].</span>",
		"<span class='notice'>[user] successfully toolboxed [target]!</span>",
		"<span class='notice'>[user] successfully toolboxed [target]!</span>")
	return TRUE

/datum/surgery_step/fork
	name = "balance fork on bellybutton"
	implements = list(/obj/item/kitchen/fork = 80)
	time = 100

/datum/surgery_step/fork/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You try to balance [tool] on [target]'s bellybutton.</span>",
		"<span class='notice'>[user] begins to balance [tool] on [target]'s bellybutton.</span>",
		"<span class='notice'>[user] begins to balance [tool] on [target]'s bellybutton.</span>")

/datum/surgery_step/fork/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results)
	display_results(user, target, "<span class='notice'>You succeed in balancing [tool] on [target]'s bellybutton!</span>",
		"<span class='notice'>[user] successfully balances [tool] on [target]'s bellybutton!</span>",
		"<span class='notice'>[user] successfully balances [tool] on [target]'s bellybutton!</span>")

	target.fuck()
	return TRUE
