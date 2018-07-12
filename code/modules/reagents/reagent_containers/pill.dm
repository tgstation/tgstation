/obj/item/reagent_containers/pill
	name = "pill"
	desc = "A tablet or capsule."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "pill"
	item_state = "pill"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	possible_transfer_amounts = list()
	volume = 50
	grind_results = list()
	var/apply_type = INGEST
	var/apply_method = "swallow"
	var/roundstart = 0
	var/self_delay = 0 //pills are instant, this is because patches inheret their aplication from pills
	var/dissolvable = TRUE

/obj/item/reagent_containers/pill/Initialize()
	. = ..()
	if(!icon_state)
		icon_state = "pill[rand(1,20)]"
	if(reagents.total_volume && roundstart)
		name += " ([reagents.total_volume]u)"


/obj/item/reagent_containers/pill/attack_self(mob/user)
	return


/obj/item/reagent_containers/pill/attack(mob/M, mob/user, def_zone)
	if(!canconsume(M, user))
		return 0

	if(M == user)
		M.visible_message("<span class='notice'>[user] attempts to [apply_method] [src].</span>")
		if(self_delay)
			if(!do_mob(user, M, self_delay))
				return 0
		to_chat(M, "<span class='notice'>You [apply_method] [src].</span>")

	else
		M.visible_message("<span class='danger'>[user] attempts to force [M] to [apply_method] [src].</span>", \
							"<span class='userdanger'>[user] attempts to force [M] to [apply_method] [src].</span>")
		if(!do_mob(user, M))
			return 0
		M.visible_message("<span class='danger'>[user] forces [M] to [apply_method] [src].</span>", \
							"<span class='userdanger'>[user] forces [M] to [apply_method] [src].</span>")


	add_logs(user, M, "fed", reagents.log_list())
	if(reagents.total_volume)
		reagents.reaction(M, apply_type)
		reagents.trans_to(M, reagents.total_volume)
	qdel(src)
	return 1


/obj/item/reagent_containers/pill/afterattack(obj/target, mob/user , proximity)
	. = ..()
	if(!proximity)
		return
	if(!dissolvable || !target.is_refillable())
		return
	if(target.is_drainable() && !target.reagents.total_volume)
		to_chat(user, "<span class='warning'>[target] is empty! There's nothing to dissolve [src] in.</span>")
		return

	if(target.reagents.holder_full())
		to_chat(user, "<span class='warning'>[target] is full.</span>")
		return

	to_chat(user, "<span class='notice'>You dissolve [src] in [target].</span>")
	for(var/mob/O in viewers(2, user))	//viewers is necessary here because of the small radius
		to_chat(O, "<span class='warning'>[user] slips something into [target]!</span>")
	reagents.trans_to(target, reagents.total_volume)
	qdel(src)

/obj/item/reagent_containers/pill/tox
	name = "toxins pill"
	desc = "Highly toxic."
	icon_state = "pill5"
	list_reagents = list("toxin" = 50)
	roundstart = 1
/obj/item/reagent_containers/pill/cyanide
	name = "cyanide pill"
	desc = "Don't swallow this."
	icon_state = "pill5"
	list_reagents = list("cyanide" = 50)
	roundstart = 1
/obj/item/reagent_containers/pill/adminordrazine
	name = "adminordrazine pill"
	desc = "It's magic. We don't have to explain it."
	icon_state = "pill16"
	list_reagents = list("adminordrazine" = 50)
	roundstart = 1
/obj/item/reagent_containers/pill/morphine
	name = "morphine pill"
	desc = "Commonly used to treat insomnia."
	icon_state = "pill8"
	list_reagents = list("morphine" = 30)
	roundstart = 1
/obj/item/reagent_containers/pill/stimulant
	name = "stimulant pill"
	desc = "Often taken by overworked employees, athletes, and the inebriated. You'll snap to attention immediately!"
	icon_state = "pill19"
	list_reagents = list("ephedrine" = 10, "antihol" = 10, "coffee" = 30)
	roundstart = 1
/obj/item/reagent_containers/pill/salbutamol
	name = "salbutamol pill"
	desc = "Used to treat oxygen deprivation."
	icon_state = "pill16"
	list_reagents = list("salbutamol" = 30)
	roundstart = 1
/obj/item/reagent_containers/pill/charcoal
	name = "charcoal pill"
	desc = "Neutralizes many common toxins."
	icon_state = "pill17"
	list_reagents = list("charcoal" = 10)
	roundstart = 1
/obj/item/reagent_containers/pill/epinephrine
	name = "epinephrine pill"
	desc = "Used to stabilize patients."
	icon_state = "pill5"
	list_reagents = list("epinephrine" = 15)
	roundstart = 1
/obj/item/reagent_containers/pill/mannitol
	name = "mannitol pill"
	desc = "Used to treat brain damage."
	icon_state = "pill17"
	list_reagents = list("mannitol" = 50)
	roundstart = 1
/obj/item/reagent_containers/pill/mutadone
	name = "mutadone pill"
	desc = "Used to treat genetic damage."
	icon_state = "pill20"
	list_reagents = list("mutadone" = 50)
	roundstart = 1
/obj/item/reagent_containers/pill/salicyclic
	name = "salicylic acid pill"
	desc = "Used to dull pain."
	icon_state = "pill9"
	list_reagents = list("sal_acid" = 24)
	roundstart = 1
/obj/item/reagent_containers/pill/oxandrolone
	name = "oxandrolone pill"
	desc = "Used to stimulate burn healing."
	icon_state = "pill11"
	list_reagents = list("oxandrolone" = 24)
	roundstart = 1

/obj/item/reagent_containers/pill/insulin
	name = "insulin pill"
	desc = "Handles hyperglycaemic coma."
	icon_state = "pill18"
	list_reagents = list("insulin" = 50)
	roundstart = 1
///////////////////////////////////////// this pill is used only in a legion mob drop
/obj/item/reagent_containers/pill/shadowtoxin
	name = "black pill"
	desc = "I wouldn't eat this if I were you."
	icon_state = "pill9"
	color = "#454545"
	list_reagents = list("shadowmutationtoxin" = 1)
//////////////////////////////////////// drugs
/obj/item/reagent_containers/pill/zoom
	name = "zoom pill"
	list_reagents = list("synaptizine" = 10, "nicotine" = 10, "methamphetamine" = 1)


/obj/item/reagent_containers/pill/happy
	name = "happy pill"
	list_reagents = list("sugar" = 10, "space_drugs" = 10)


/obj/item/reagent_containers/pill/lsd
	name = "hallucinogen pill"
	list_reagents = list("mushroomhallucinogen" = 15, "mindbreaker" = 15)


/obj/item/reagent_containers/pill/aranesp
	name = "speedy pill"
	list_reagents = list("aranesp" = 10)

/obj/item/reagent_containers/pill/floorpill
	name = "floorpill"
	desc = "A strange pill found in the depths of maintenance"
	icon_state = "pill21"
	var/static/list/names = list("maintenance pill","floorpill","mystery pill","suspicious pill","strange pill")
	var/static/list/descs = list("Your feeling is telling you no, but...","Drugs are expensive, you can't afford not to eat any pills that you find."\
	, "Surely, there's no way this could go bad.")

/obj/item/reagent_containers/pill/floorpill/Initialize()
	list_reagents = list(get_random_reagent_id() = rand(10,50))
	. = ..()
	name = pick(names)
	if(prob(20))
		desc = pick(descs)
	
