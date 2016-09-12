/obj/item/clockwork
	name = "meme blaster"
	desc = "What the fuck is this? It looks kinda like a frog."
	var/clockwork_desc = "A fabled artifact from beyond the stars. Contains concentrated meme essence." //Shown to clockwork cultists instead of the normal description
	icon = 'icons/obj/clockwork_objects.dmi'
	icon_state = "rare_pepe"
	w_class = 2

/obj/item/clockwork/New()
	..()
	all_clockwork_objects += src

/obj/item/clockwork/Destroy()
	all_clockwork_objects -= src
	return ..()

/obj/item/clockwork/examine(mob/user)
	if((is_servant_of_ratvar(user) || isobserver(user)) && clockwork_desc)
		desc = clockwork_desc
	..()
	desc = initial(desc)

/obj/item/clockwork/slab //Clockwork slab: The most important tool in Ratvar's arsenal. Allows scripture recital, tutorials, and generates components.
	name = "clockwork slab"
	desc = "A strange metal tablet. A clock in the center turns around and around."
	clockwork_desc = "A link between the Celestial Derelict and the mortal plane. Contains limitless knowledge, fabricates components, and outputs a stream of information that only a trained eye can detect."
	icon_state = "dread_ipad"
	slot_flags = SLOT_BELT
	w_class = 2
	var/list/stored_components = list("belligerent_eye" = 0, "vanguard_cogwheel" = 0, "guvax_capacitor" = 0, "replicant_alloy" = 0, "hierophant_ansible" = 0)
	var/busy //If the slab is currently being used by something
	var/production_time = 0
	var/no_cost = FALSE //If the slab is admin-only and needs no components and has no scripture locks
	var/nonhuman_usable = FALSE //if the slab can be used by nonhumans, defaults to off
	var/produces_components = TRUE //if it produces components at all
	actions_types = list(/datum/action/item_action/clock/hierophant, /datum/action/item_action/clock/guvax, /datum/action/item_action/clock/vanguard)

/obj/item/clockwork/slab/starter
	stored_components = list("belligerent_eye" = 1, "vanguard_cogwheel" = 1, "guvax_capacitor" = 1, "replicant_alloy" = 1, "hierophant_ansible" = 1)

/obj/item/clockwork/slab/internal //an internal motor for mobs running scripture
	name = "scripture motor"
	no_cost = TRUE
	produces_components = FALSE

/obj/item/clockwork/slab/scarab
	nonhuman_usable = TRUE

/obj/item/clockwork/slab/debug
	no_cost = TRUE
	nonhuman_usable = TRUE

/obj/item/clockwork/slab/debug/attack_hand(mob/living/user)
	..()
	if(!is_servant_of_ratvar(user))
		add_servant_of_ratvar(user)

/obj/item/clockwork/slab/New()
	..()
	START_PROCESSING(SSobj, src)
	production_time = world.time + SLAB_PRODUCTION_TIME

/obj/item/clockwork/slab/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/clockwork/slab/process()
	if(!produces_components)
		STOP_PROCESSING(SSobj, src)
		return
	if(production_time > world.time)
		return
	var/servants = 0
	var/production_slowdown = 0
	for(var/mob/living/M in living_mob_list)
		if(is_servant_of_ratvar(M) && (ishuman(M) || issilicon(M)))
			servants++
	if(servants > 5)
		servants -= 5
		production_slowdown = min(SLAB_SERVANT_SLOWDOWN * servants, SLAB_SLOWDOWN_MAXIMUM) //SLAB_SERVANT_SLOWDOWN additional seconds for each servant above 5, up to SLAB_SLOWDOWN_MAXIMUM
	production_time = world.time + SLAB_PRODUCTION_TIME + production_slowdown
	var/mob/living/L
	if(isliving(loc))
		L = loc
	else if(istype(loc, /obj/item/weapon/storage))
		var/obj/item/weapon/storage/W = loc
		if(isliving(W.loc)) //Only goes one level down - otherwise it won't produce components
			L = W.loc
	if(L)
		var/component_to_generate = get_weighted_component_id(src) //more likely to generate components that we have less of
		stored_components[component_to_generate]++
		for(var/obj/item/clockwork/slab/S in L.GetAllContents()) //prevent slab abuse today
			if(L == src)
				continue
			S.production_time = world.time + SLAB_PRODUCTION_TIME
		L << "<span class='warning'>Your slab clunks as it produces a new component.</span>"

/obj/item/clockwork/slab/ui_action_click(mob/user, actiontype)
	switch(actiontype)
		if(/datum/action/item_action/clock/hierophant)
			show_hierophant(user)
		if(/datum/action/item_action/clock/guvax)
			if(!nonhuman_usable && !ishuman(user))
				return
			if(src == user.get_active_held_item())
				var/datum/clockwork_scripture/guvax/convert = new
				convert.slab = src
				convert.invoker = user
				convert.run_scripture()
			else
				user << "<span class='warning'>You need to hold the slab in your active hand to recite scripture!</span>"
		if(/datum/action/item_action/clock/vanguard)
			if(!nonhuman_usable && !ishuman(user))
				return
			if(src == user.get_active_held_item())
				var/datum/clockwork_scripture/vanguard/antistun = new
				antistun.slab = src
				antistun.invoker = user
				antistun.run_scripture()
			else
				user << "<span class='warning'>You need to hold the slab in your active hand to recite scripture!</span>"

/obj/item/clockwork/slab/attack(mob/living/target, mob/living/carbon/human/user)
	if(is_servant_of_ratvar(user) && is_servant_of_ratvar(target))
		var/obj/item/clockwork/slab/targetslab
		var/highest_component_amount = 0
		for(var/obj/item/clockwork/slab/S in target.GetAllContents())
			if(!istype(S, /obj/item/clockwork/slab/internal))
				var/totalcomponents = 0
				for(var/i in S.stored_components)
					totalcomponents += S.stored_components[i]
				if(!targetslab || totalcomponents > highest_component_amount)
					highest_component_amount = totalcomponents
					targetslab = S
		if(targetslab)
			if(targetslab == src)
				user << "<span class='heavy_brass'>\"You can't transfer components into your own slab, idiot.\"</span>"
			else
				for(var/i in stored_components)
					targetslab.stored_components[i] += stored_components[i]
					stored_components[i] = 0
				user.visible_message("<span class='notice'>[user] empties [src] into [target]'s [targetslab.name].</span>", \
				"<span class='notice'>You transfer your slab's components into [target]'s [targetslab.name].</span>")
		else
			user << "<span class='warning'>[target] has no slabs to transfer components to.</span>"
	else
		return ..()

/obj/item/clockwork/slab/attackby(obj/item/I, mob/user, params)
	var/ratvarian = is_servant_of_ratvar(user)
	if(istype(I, /obj/item/clockwork/component) && ratvarian)
		var/obj/item/clockwork/component/C = I
		if(!C.component_id)
			return 0
		user.visible_message("<span class='notice'>[user] inserts [C] into [src].</span>", "<span class='notice'>You insert [C] into [src], where it is added to the global cache.</span>")
		clockwork_component_cache[C.component_id]++
		user.drop_item()
		qdel(C)
		return 1
	else if(istype(I, /obj/item/clockwork/slab) && ratvarian)
		var/obj/item/clockwork/slab/S = I
		for(var/i in stored_components)
			stored_components[i] += S.stored_components[i]
			S.stored_components[i] = 0
		user.visible_message("<span class='notice'>[user] empties [src] into [S].</span>", "<span class='notice'>You transfer your slab's components into [S].</span>")
	else
		return ..()

/obj/item/clockwork/slab/attack_self(mob/living/user)
	if(iscultist(user))
		user << "<span class='heavy_brass'>\"You reek of blood. You've got a lot of nerve to even look at that slab.\"</span>"
		user.visible_message("<span class='warning'>A sizzling sound comes from [user]'s hands!</span>", "<span class='userdanger'>[src] suddenly grows extremely hot in your hands!</span>")
		playsound(get_turf(user), 'sound/weapons/sear.ogg', 50, 1)
		user.drop_item()
		user.emote("scream")
		user.apply_damage(5, BURN, "l_arm")
		user.apply_damage(5, BURN, "r_arm")
		return 0
	if(!is_servant_of_ratvar(user))
		user << "<span class='warning'>The information on [src]'s display shifts rapidly. After a moment, your head begins to pound, and you tear your eyes away.</span>"
		user.confused += 5
		user.dizziness += 5
		return 0
	if(busy)
		user << "<span class='warning'>[src] refuses to work, displaying the message: \"[busy]!\"</span>"
		return 0
	if(!nonhuman_usable && !ishuman(user))
		user << "<span class='nezbere'>[src] hums fitfully in your hands, but doesn't seem to do anything...</span>"
		return 0
	access_display(user)

/obj/item/clockwork/slab/proc/access_display(mob/living/user)
	if(!is_servant_of_ratvar(user))
		return 0
	var/action = alert(user, "Among the swathes of information, you see...", "[src]", "Recital", "Recollection", "Cancel")
	if(!action || !user.canUseTopic(src))
		return 0
	switch(action)
		if("Recital")
			if(user.get_active_held_item() != src)
				user << "<span class='warning'>You need to hold the slab in your active hand to recite scripture!</span>"
				return
			recite_scripture(user)
		if("Recollection")
			show_guide(user)
		if("Cancel")
			return
	return 1

/obj/item/clockwork/slab/proc/recite_scripture(mob/living/user)
	var/list/tiers_of_scripture = scripture_unlock_check()
	for(var/i in tiers_of_scripture)
		if(!tiers_of_scripture[i] && !ratvar_awakens && !no_cost)
			tiers_of_scripture["[i] \[LOCKED\]"] = TRUE
			tiers_of_scripture -= i
	var/scripture_tier = input(user, "Choose a category of scripture to recite.", "[src]") as null|anything in tiers_of_scripture
	if(!scripture_tier || !user.canUseTopic(src))
		return 0
	var/list/available_scriptures = list()
	var/datum/clockwork_scripture/scripture_to_recite
	switch(scripture_tier)
		if(SCRIPTURE_DRIVER,SCRIPTURE_SCRIPT,SCRIPTURE_APPLICATION,SCRIPTURE_REVENANT,SCRIPTURE_JUDGEMENT); //; for the empty if
		else
			user << "<span class='warning'>That section of scripture is still locked!</span>"
			return 0
	for(var/S in sortList(subtypesof(/datum/clockwork_scripture), /proc/cmp_clockscripture_priority))
		var/datum/clockwork_scripture/C = S
		if(initial(C.tier) == scripture_tier)
			available_scriptures += "[initial(C.name)] ([initial(C.descname)])"
	if(!available_scriptures.len)
		return 0
	var/chosen_scripture = input(user, "Choose a piece of scripture to recite.", "[src]") as null|anything in available_scriptures
	if(!chosen_scripture || !user.canUseTopic(src))
		return 0
	for(var/S in subtypesof(/datum/clockwork_scripture))
		var/datum/clockwork_scripture/C = S
		if("[initial(C.name)] ([initial(C.descname)])" == chosen_scripture)
			scripture_to_recite = new C
	if(!scripture_to_recite || user.get_active_held_item() != src)
		return 0
	tiers_of_scripture = scripture_unlock_check()
	if(!ratvar_awakens && !no_cost && !tiers_of_scripture[scripture_to_recite.tier])
		user << "<span class='warning'>That scripture is no longer unlocked, and cannot be recited!</span>"
		return 0
	scripture_to_recite.slab = src
	scripture_to_recite.invoker = user
	scripture_to_recite.run_scripture()
	return 1

/obj/item/clockwork/slab/proc/show_guide(mob/living/user)
	var/text = "If you're seeing this, file a bug report."
	if(ratvar_awakens)
		text = "<font color=#BE8700 size=3><b>"
		for(var/i in 1 to 100)
			text += "HONOR RATVAR "
		text += "</b></font>"
	else
		text = "<font color=#BE8700 size=3><b><center>Chetr nyy hagehguf-naq-ubabe Ratvar.</center></b></font><br><br>\
		\
		First and foremost, you serve Ratvar, the Clockwork Justiciar, in any ways he sees fit. This is with no regard to your personal well-being, and you would do well to think of the larger \
		scale of things than your life. Through foul and unholy magics was the Celestial Derelict formed, and fouler still those which trapped your master within it for all eternity. The Justiciar \
		wishes retribution upon those who performed this terrible act upon him - the Nar-Sian cultists - and you are to help him obtain it.<br><br>\
		\
		This is not a trivial task. Due to the nature of his prison, Ratvar is incapable of directly influencing the mortal plane. There is, however, a workaround - links between the perceptible \
		universe and Reebe (the Celestial Derelict) can be created and utilized. This is typically done via the creation of a slab akin to the one you are holding right now. The slabs tap into the \
		tidal flow of energy and information keeping Reebe sealed and presents it as meaningless images to preserve sanity. This slab can utilize the power in many different ways.<br><br>\
		\
		This is done through <b><font color=#BE8700>Components</font></b> - pieces of the Justiciar's body that have since fallen off in the countless years since his imprisonment. Ratvar's unfortunate condition results \
		in the fragmentation of his body. These components still house great power on their own, and can slowly be drawn from Reebe by links capable of doing so.<br>\
		The most basic of these links lies in the clockwork slab, which will slowly generate components over time - one component of a random type is produced every 1 minute and 30 seconds, plus 30 seconds per each servant above 5, \
		which is obviously inefficient. There are other, more efficient, ways to create these components through scripture and certain structures.<br><br>\
		\
		In addition to their ability to generate components, slabs also possess other functionalities...<br><br>\
		\
		The first functionality of the slab is <b><font color=#BE8700>Recital</font></b>. This allows you to consume components either from your slab or from the global cache (more on that in the scripture list) to perform \
		effects usually considered magical in nature.<br>\
		Effects vary considerably, including mass conversion, construction of various structures, or causing a massive global hallucination. Nevertheless, scripture is extremely important to a successful takeover.<br><br>\
		\
		The second functionality of the clockwork slab is <b><font color=#BE8700>Recollection</font></b>, which will display this guide.<br><br>\
		\
		The third to fifth functionalities are several buttons in the top left while holding the slab, from left to right, they are:<br>\
		<b><font color=#DAAA18>Hierophant Network</font></b>, which allows communication to other servants.<br>\
		<b><font color=#AF0AAF>Guvax</font></b>, which simply allows you to quickly invoke the Guvax scripture.<br>\
		<b><font color=#1E8CE1>Vanguard</font></b>, which, like Guvax, simply allows you to quickly invoke the Vanguard scripture.<br><br>\
		\
		Examine the slab for component amount information.<br><br>\
		\
		A complete list of scripture, its effects, and its requirements can be found below.<br>\
		Key:<br><font color=#6E001A>BE</font> = Belligerent Eyes<br>\
		<font color=#1E8CE1>VC</font> = Vanguard Cogwheels<br>\
		<font color=#AF0AAF>GC</font> = Guvax Capacitors<br>\
		<font color=#5A6068>RA</font> = Replicant Alloy<br>\
		<font color=#DAAA18>HA</font> = Hierophant Ansibles<br>"
		var/text_to_add = ""
		var/drivers = "<br><font color=#BE8700 size=3><b>[SCRIPTURE_DRIVER]</b></font><br><i>These scriptures are always unlocked.</i><br>"
		var/scripts = "<br><font color=#BE8700 size=3><b>[SCRIPTURE_SCRIPT]</b></font><br><i>These scriptures require at least five servants and a tinkerer's cache.</i><br>"
		var/applications = "<font color=#BE8700 size=3><b>[SCRIPTURE_APPLICATION]</b></font><br><i>These scriptures require at least eight servants, three tinkerer's caches, and 100CV.</i><br>"
		var/revenant = "<br><font color=#BE8700 size=3><b>[SCRIPTURE_REVENANT]</b></font><br><i>These scriptures require at least ten servants and 200CV.</i><br>"
		var/judgement = "<br><font color=#BE8700 size=3><b>[SCRIPTURE_JUDGEMENT]</b></font><br><i>These scriptures require at least twelve servants and 300CV. In addition, there may not be any active non-servant AIs.</i><br>"
		for(var/V in sortList(subtypesof(/datum/clockwork_scripture), /proc/cmp_clockscripture_priority))
			var/datum/clockwork_scripture/S = V
			var/datum/clockwork_scripture/S2 = new V
			var/list/req_comps = S2.required_components
			var/list/cons_comps = S2.consumed_components
			qdel(S2)
			if(initial(S.tier) != SCRIPTURE_PERIPHERAL)
				var/scripture_text = "<br><b><font color=#BE8700>[initial(S.name)]</font>:</b><br>[initial(S.desc)]<br><b>Invocation Time:</b> <b>[initial(S.channel_time) / 10]</b> seconds<br>\
				<b>Component Requirement: </b>\
				[req_comps["belligerent_eye"] ?  "<font color=#6E001A><b>[req_comps["belligerent_eye"]]</b> BE</font>" : ""] \
				[req_comps["vanguard_cogwheel"] ? "<font color=#1E8CE1><b>[req_comps["vanguard_cogwheel"]]</b> VC</font>" : ""] \
				[req_comps["guvax_capacitor"] ? "<font color=#AF0AAF><b>[req_comps["guvax_capacitor"]]</b> GC</font>" : ""] \
				[req_comps["replicant_alloy"] ? "<font color=#5A6068><b>[req_comps["replicant_alloy"]]</b> RA</font>" : ""] \
				[req_comps["hierophant_ansible"] ? "<font color=#DAAA18><b>[req_comps["hierophant_ansible"]]</b> HA</font>" : ""]<br>"
				for(var/i in cons_comps)
					if(cons_comps[i])
						scripture_text += "<b>Component Cost: </b>\
						[cons_comps["belligerent_eye"] ?  "<font color=#6E001A><b>[cons_comps["belligerent_eye"]]</b> BE</font>" : ""] \
						[cons_comps["vanguard_cogwheel"] ? "<font color=#1E8CE1><b>[cons_comps["vanguard_cogwheel"]]</b> VC</font>" : ""] \
						[cons_comps["guvax_capacitor"] ? "<font color=#AF0AAF><b>[cons_comps["guvax_capacitor"]]</b> GC</font>" : ""] \
						[cons_comps["replicant_alloy"] ? "<font color=#5A6068><b>[cons_comps["replicant_alloy"]]</b> RA</font>" : ""] \
						[cons_comps["hierophant_ansible"] ? "<font color=#DAAA18><b>[cons_comps["hierophant_ansible"]]</b> HA</font>" : ""]<br>"
						break //we want this to only show up if the scripture has a cost of some sort
				scripture_text += "<b>Tip:</b> [initial(S.usage_tip)]<br>"
				switch(initial(S.tier))
					if(SCRIPTURE_DRIVER)
						drivers += scripture_text
					if(SCRIPTURE_SCRIPT)
						scripts += scripture_text
					if(SCRIPTURE_APPLICATION)
						applications += scripture_text
					if(SCRIPTURE_REVENANT)
						revenant += scripture_text
					if(SCRIPTURE_JUDGEMENT)
						judgement += scripture_text
		text_to_add += "[drivers]<br>[scripts]<br>[applications]<br>[revenant]<br>[judgement]<br>"
		text_to_add += "<font color=#BE8700 size=3><b><center>Purge all untruths and honor Ratvar.</center></b></font>"
		text += text_to_add
	var/datum/browser/popup = new(user, "slab", "", 600, 500)
	popup.set_content(text)
	popup.open()
	return 1

/obj/item/clockwork/slab/examine(mob/user)
	..()
	if(is_servant_of_ratvar(user) || isobserver(user))
		user << "Use the <span class='brass'>Hierophant Network</span> action button to communicate with other servants."
		user << "Clockwork slabs will only generate components if held by a human or if inside a storage item held by a human, and when generating a component will prevent all other slabs held from generating components.<br>"
		user << "Attacking a slab, a fellow Servant with a slab, or a cache with this slab will transfer this slab's components into that slab's components, their slab's components, or the global cache, respectively."
		if(clockwork_caches)
			user << "<b>Stored components (with global cache):</b>"
			for(var/i in stored_components)
				user << "<span class='[get_component_span(i)]_small'><i>[get_component_name(i)]s:</i> <b>[stored_components[i]]</b> (<b>[stored_components[i] + clockwork_component_cache[i]]</b>)</span>"
		else
			user << "<b>Stored components:</b>"
			for(var/i in stored_components)
				user << "<span class='[get_component_span(i)]_small'><i>[get_component_name(i)]s:</i> <b>[stored_components[i]]</b></span>"

/obj/item/clockwork/slab/proc/show_hierophant(mob/living/user)
	var/message = stripped_input(user, "Enter a message to send to your fellow servants.", "Hierophant")
	if(!message || !user || !user.canUseTopic(src))
		return 0
	clockwork_say(user, text2ratvar("Servants, hear my words. [html_decode(message)]"), TRUE)
	titled_hierophant_message(user, message)
	return 1

/obj/item/clothing/glasses/wraith_spectacles //Wraith spectacles: Grants night and x-ray vision at the slow cost of the wearer's sight. Nar-Sian cultists are instantly blinded.
	name = "antique spectacles"
	desc = "Unnerving glasses with opaque yellow lenses."
	icon = 'icons/obj/clothing/clockwork_garb.dmi'
	icon_state = "wraith_specs"
	item_state = "glasses"
	vision_flags = SEE_MOBS | SEE_TURFS | SEE_OBJS
	invis_view = 2
	darkness_view = 3

/obj/item/clothing/glasses/wraith_spectacles/equipped(mob/living/user, slot)
	..()
	if(slot != slot_glasses)
		return
	if(user.disabilities & BLIND)
		user << "<span class='heavy_brass'>\"You're blind, idiot. Stop embarassing yourself.\"</span>" //Ratvar with the sick burns yo
		return
	if(iscultist(user)) //Cultists instantly go blind
		user << "<span class='heavy_brass'>\"It looks like Nar-Sie's dogs really don't value their eyes.\"</span>"
		user << "<span class='userdanger'>Your eyes explode with horrific pain!</span>"
		user.emote("scream")
		user.become_blind()
		user.adjust_blurriness(30)
		user.adjust_blindness(30)
		return
	if(is_servant_of_ratvar(user))
		tint = 0
		user << "<span class='heavy_brass'>As you put on the spectacles, all is revealed to you.[ratvar_awakens ? "" : " Your eyes begin to itch - you cannot do this for long."]</span>"
	else
		tint = 3
		user << "<span class='heavy_brass'>You put on the spectacles, but you can't see through the glass.</span>"

/obj/item/clothing/glasses/wraith_spectacles/New()
	..()
	START_PROCESSING(SSobj, src)

/obj/item/clothing/glasses/wraith_spectacles/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/clothing/glasses/wraith_spectacles/process()
	if(ratvar_awakens || !ishuman(loc) || !is_servant_of_ratvar(loc)) //If Ratvar is alive, the spectacles don't hurt your eyes
		return 0
	var/mob/living/carbon/human/H = loc
	if(H.glasses != src)
		return 0
	if(!H.disabilities & BLIND)
		H.adjust_eye_damage(1)
		if(H.eye_damage >= 15)
			H.adjust_blurriness(2)
		if(H.eye_damage >= 30)
			if(H.become_nearsighted())
				H << "<span class='warning'><b>Your vision doubles, then trebles. Darkness begins to close in. You can't keep this up!</b></span>"
		if(H.eye_damage >= 45)
			if(H.become_blind())
				H << "<span class='userdanger'>A piercing white light floods your vision. Suddenly, all goes dark!</span>"
		if(prob(15))
			H << "<span class='warning'>Your eyes continue to burn.</span>"

/obj/item/clothing/glasses/judicial_visor //Judicial visor: Grants the ability to smite an area and stun the unfaithful nearby every thirty seconds.
	name = "judicial visor"
	desc = "A strange purple-lensed visor. Looking at it inspires an odd sense of guilt."
	icon = 'icons/obj/clothing/clockwork_garb.dmi'
	icon_state = "judicial_visor_0"
	item_state = "sunglasses"
	var/active = FALSE //If the visor is online
	var/recharging = FALSE //If the visor is currently recharging
	var/obj/item/weapon/ratvars_flame/flame //The linked flame object
	var/recharge_cooldown = 300 //divided by 10 if ratvar is alive
	actions_types = list(/datum/action/item_action/clock/toggle_flame)

/obj/item/clothing/glasses/judicial_visor/item_action_slot_check(slot, mob/user)
	if(slot != slot_glasses)
		return 0
	return ..()

/obj/item/clothing/glasses/judicial_visor/equipped(mob/living/user, slot)
	..()
	if(slot != slot_glasses)
		update_status(FALSE)
		if(flame)
			qdel(flame)
			flame = null
		return 0
	if(is_servant_of_ratvar(user))
		update_status(TRUE)
	else
		update_status(FALSE)
	if(iscultist(user)) //Cultists spontaneously combust
		user << "<span class='heavy_brass'>\"Consider yourself judged, whelp.\"</span>"
		user << "<span class='userdanger'>You suddenly catch fire!</span>"
		user.adjust_fire_stacks(5)
		user.IgniteMob()
	return 1

/obj/item/clothing/glasses/judicial_visor/attack_self(mob/user)
	if(is_servant_of_ratvar(user))
		if(flame)
			user.visible_message("<span class='warning'>The flame in [user]'s hand winks out!</span>", "<span class='heavy_brass'>You dispel the power of [src].</span>")
			qdel(flame)
			flame = null
		else if(iscarbon(user) && active)
			if(recharging)
				user << "<span class='warning'>[src] is still gathering power!</span>"
				return 0
			var/mob/living/carbon/C = user
			if(!user.get_empty_held_indexes())
				C << "<span class='warning'>You require a free hand to utilize [src]'s power!</span>"
				return 0
			C.visible_message("<span class='warning'>[C]'s hand is enveloped in violet flames!<span>", "<span class='brass'><i>You harness [src]'s power. <b>Direct it at a tile at any range</b> to unleash it, or use the action button again to dispel it.</i></span>")
			var/turf/T = get_turf(C)
			var/obj/item/weapon/ratvars_flame/R = new(T)
			flame = R
			C.put_in_hands(R)
			R.visor = src
			add_logs(C, T, "prepared ratvar's flame", src)
		user.update_action_buttons_icon()

/obj/item/clothing/glasses/judicial_visor/proc/update_status(change_to)
	if(recharging || !isliving(loc))
		icon_state = "judicial_visor_0"
		return 0
	if(active == change_to)
		return 0
	var/mob/living/L = loc
	if(!is_servant_of_ratvar(L) || L.stat)
		return 0
	active = change_to
	icon_state = "judicial_visor_[active]"
	L.update_action_buttons_icon()
	L.update_inv_glasses()
	switch(active)
		if(TRUE)
			L << "<span class='notice'>As you put on [src], its lens begins to glow, information flashing before your eyes.</span>\n\
			<span class='heavy_brass'>Judicial visor active. Use the action button to gain the ability to smite the unworthy.</span>"
		if(FALSE)
			L << "<span class='notice'>As you take off [src], its lens darkens once more.</span>"
	return 1

/obj/item/clothing/glasses/judicial_visor/proc/recharge_visor(mob/living/user)
	if(!src || !user)
		return 0
	recharging = FALSE
	if(src == user.get_item_by_slot(slot_glasses))
		user << "<span class='brass'>Your [name] hums. It is ready.</span>"
	else
		active = FALSE
	icon_state = "judicial_visor_[active]"
	user.update_action_buttons_icon()
	user.update_inv_glasses()

/obj/item/weapon/ratvars_flame //Used by the judicial visor
	name = "Ratvar's flame"
	desc = "A blazing violet ball of fire that, curiously, doesn't melt your hand off."
	icon = 'icons/effects/clockwork_effects.dmi'
	icon_state = "ratvars_flame"
	w_class = 5
	flags = NODROP | ABSTRACT
	force = 5 //Also serves as a weak melee weapon!
	damtype = BURN
	hitsound = 'sound/weapons/sear.ogg'
	attack_verb = list("scorched", "seared", "burnt", "judged")
	var/obj/item/clothing/glasses/judicial_visor/visor //The linked visor
	var/examined = FALSE

/obj/item/weapon/ratvars_flame/examine(mob/user)
	..()
	user << "<span class='brass'>Use <b>harm intent</b> to direct the flame to a location.</span>"
	if(prob(10) && examined)
		user << "<span class='heavy_brass'>\"Don't stand around looking at your hands, go forth with Neovgre's judgement!\"</span>"
		examined = FALSE
	else
		examined = TRUE

/obj/item/weapon/ratvars_flame/afterattack(atom/target, mob/living/user, flag, params)
	if(!visor || (visor && visor.cooldown))
		qdel(src)
	if(target in view(7, get_turf(user)))
		visor.recharging = TRUE
		visor.flame = null
		visor.update_status()
		for(var/obj/item/clothing/glasses/judicial_visor/V in user.GetAllContents())
			if(V == visor)
				continue
			V.recharging = TRUE //To prevent exploiting multiple visors to bypass the cooldown
			V.update_status()
			addtimer(V, "recharge_visor", (ratvar_awakens ? visor.recharge_cooldown*0.1 : visor.recharge_cooldown) * 2, FALSE, user)
		clockwork_say(user, text2ratvar("Kneel, heathens!"))
		user.visible_message("<span class='warning'>The flame in [user]'s hand rushes to [target]!</span>", "<span class='heavy_brass'>You direct [visor]'s power to [target]. You must wait for some time before doing this again.</span>")
		var/turf/T = get_turf(target)
		new/obj/effect/clockwork/judicial_marker(T, user)
		add_logs(user, T, "used ratvar's flame to create a judicial marker")
		user.update_action_buttons_icon()
		user.update_inv_glasses()
		addtimer(visor, "recharge_visor", ratvar_awakens ? visor.recharge_cooldown*0.1 : visor.recharge_cooldown, FALSE, user)//Cooldown is reduced by 10x if Ratvar is up
		qdel(src)
		return 1


/obj/item/clothing/head/helmet/clockwork //Clockwork armor: High melee protection but weak to lasers
	name = "clockwork helmet"
	desc = "A heavy helmet made of brass."
	icon = 'icons/obj/clothing/clockwork_garb.dmi'
	icon_state = "clockwork_helmet"
	w_class = 3
	armor = list(melee = 80, bullet = 50, laser = -15, energy = 5, bomb = 35, bio = 0, rad = 0)

/obj/item/clothing/head/helmet/clockwork/equipped(mob/living/user, slot)
	..()
	if(slot == slot_head && !is_servant_of_ratvar(user))
		if(!iscultist(user))
			user << "<span class='heavy_brass'>\"Now now, this is for my servants, not you.\"</span>"
			user.visible_message("<span class='warning'>As [user] puts [src] on, it flickers off their head!</span>", "<span class='warning'>The helmet flickers off your head, leaving only nausea!</span>")
			if(iscarbon(user))
				var/mob/living/carbon/C = user
				C.vomit(20, 1, 1, 0, 1)
		else
			user << "<span class='heavy_brass'>\"Do you have a hole in your head? You're about to.\"</span>"
			user << "<span class='userdanger'>The helmet tries to drive a spike through your head as you scramble to remove it!</span>"
			user.emote("scream")
			user.apply_damage(30, BRUTE, "head")
			user.adjustBrainLoss(30)
		addtimer(user, "unEquip", 1, FALSE, src, 1) //equipped happens before putting stuff on(but not before picking items up). thus, we need to wait for it to be on before forcing it off.

/obj/item/clothing/head/helmet/clockwork/mob_can_equip(mob/M, mob/equipper, slot, disable_warning = 0)
	if(equipper && !is_servant_of_ratvar(equipper))
		return 0
	return ..()

/obj/item/clothing/suit/armor/clockwork
	name = "clockwork cuirass"
	desc = "A bulky cuirass made of brass."
	icon = 'icons/obj/clothing/clockwork_garb.dmi'
	icon_state = "clockwork_cuirass"
	w_class = 4
	body_parts_covered = CHEST|GROIN|LEGS
	armor = list(melee = 80, bullet = 50, laser = -15, energy = 5, bomb = 35, bio = 0, rad = 0)
	allowed = list(/obj/item/clockwork, /obj/item/clothing/glasses/wraith_spectacles, /obj/item/clothing/glasses/judicial_visor, /obj/item/device/mmi/posibrain/soul_vessel)

/obj/item/clothing/suit/armor/clockwork/mob_can_equip(mob/M, mob/equipper, slot, disable_warning = 0)
	if(equipper && !is_servant_of_ratvar(equipper))
		return 0
	return ..()

/obj/item/clothing/suit/armor/clockwork/equipped(mob/living/user, slot)
	..()
	if(slot == slot_wear_suit && !is_servant_of_ratvar(user))
		if(!iscultist(user))
			user << "<span class='heavy_brass'>\"Now now, this is for my servants, not you.\"</span>"
			user.visible_message("<span class='warning'>As [user] puts [src] on, it flickers off their body!</span>", "<span class='warning'>The curiass flickers off your body, leaving only nausea!</span>")
			if(iscarbon(user))
				var/mob/living/carbon/C = user
				C.vomit(20, 1, 1, 0, 1)
		else
			user << "<span class='heavy_brass'>\"I think this armor is too hot for you to handle.\"</span>"
			user << "<span class='userdanger'>The curiass emits a burst of flame as you scramble to get it off!</span>"
			user.emote("scream")
			user.apply_damage(15, BURN, "chest")
			user.adjust_fire_stacks(2)
			user.IgniteMob()
		addtimer(user, "unEquip", 1, FALSE, src, 1)

/obj/item/clothing/gloves/clockwork
	name = "clockwork gauntlets"
	desc = "Heavy, shock-resistant gauntlets with brass reinforcement."
	icon = 'icons/obj/clothing/clockwork_garb.dmi'
	icon_state = "clockwork_gauntlets"
	item_state = "clockwork_gauntlets"
	item_color = null	//So they don't wash.
	strip_delay = 50
	put_on_delay = 30
	body_parts_covered = ARMS
	burn_state = FIRE_PROOF
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	armor = list(melee = 80, bullet = 50, laser = -15, energy = 5, bomb = 35, bio = 0, rad = 0)

/obj/item/clothing/gloves/clockwork/mob_can_equip(mob/M, mob/equipper, slot, disable_warning = 0)
	if(equipper && !is_servant_of_ratvar(equipper))
		return 0
	return ..()

/obj/item/clothing/gloves/clockwork/equipped(mob/living/user, slot)
	..()
	if(slot == slot_gloves && !is_servant_of_ratvar(user))
		if(!iscultist(user))
			user << "<span class='heavy_brass'>\"Now now, this is for my servants, not you.\"</span>"
			user.visible_message("<span class='warning'>As [user] puts [src] on, it flickers off their arms!</span>", "<span class='warning'>The gauntlets flicker off your arms, leaving only nausea!</span>")
			if(iscarbon(user))
				var/mob/living/carbon/C = user
				C.vomit(10, 1, 1, 0, 1)
		else
			user << "<span class='heavy_brass'>\"Did you like having arms?\"</span>"
			user << "<span class='userdanger'>The gauntlets suddenly squeeze tight, crushing your arms before you manage to get them off!</span>"
			user.emote("scream")
			user.apply_damage(7, BRUTE, "l_arm")
			user.apply_damage(7, BRUTE, "r_arm")
		addtimer(user, "unEquip", 1, FALSE, src, 1)

/obj/item/clothing/shoes/clockwork
	name = "clockwork treads"
	desc = "Industrial boots made of brass. They're very heavy."
	icon = 'icons/obj/clothing/clockwork_garb.dmi'
	icon_state = "clockwork_treads"
	w_class = 3
	strip_delay = 50
	put_on_delay = 30
	burn_state = FIRE_PROOF

/obj/item/clothing/shoes/clockwork/mob_can_equip(mob/M, mob/equipper, slot, disable_warning = 0)
	if(equipper && !is_servant_of_ratvar(equipper))
		return 0
	return ..()

/obj/item/clothing/shoes/clockwork/equipped(mob/living/user, slot)
	..()
	if(slot == slot_shoes && !is_servant_of_ratvar(user))
		if(!iscultist(user))
			user << "<span class='heavy_brass'>\"Now now, this is for my servants, not you.\"</span>"
			user.visible_message("<span class='warning'>As [user] puts [src] on, it flickers off their feet!</span>", "<span class='warning'>The treads flicker off your feet, leaving only nausea!</span>")
			if(iscarbon(user))
				var/mob/living/carbon/C = user
				C.vomit(10, 1, 1, 0, 1)
		else
			user << "<span class='heavy_brass'>\"Let's see if you can dance with these.\"</span>"
			user << "<span class='userdanger'>The treads turn searing hot as you scramble to get them off!</span>"
			user.emote("scream")
			user.apply_damage(7, BURN, "l_leg")
			user.apply_damage(7, BURN, "r_leg")
		addtimer(user, "unEquip", 1, FALSE, src, 1)


/obj/item/clockwork/ratvarian_spear //Ratvarian spear: A fragile spear from the Celestial Derelict. Deals extreme damage to silicons and enemy cultists, but doesn't last long when summoned.
	name = "ratvarian spear"
	desc = "A razor-sharp spear made of brass. It thrums with barely-contained energy."
	clockwork_desc = "A fragile spear of Ratvarian making. It's more effective against enemy cultists and silicons, though it won't last long."
	icon = 'icons/obj/clockwork_objects.dmi'
	icon_state = "ratvarian_spear"
	item_state = "ratvarian_spear"
	force = 17 //Extra damage is dealt to silicons in attack()
	throwforce = 40
	sharpness = IS_SHARP_ACCURATE
	attack_verb = list("stabbed", "poked", "slashed")
	hitsound = 'sound/weapons/bladeslice.ogg'
	w_class = 4
	var/impale_cooldown = 50 //delay, in deciseconds, where you can't impale again
	var/attack_cooldown = 10 //delay, in deciseconds, where you can't attack with the spear

/obj/item/clockwork/ratvarian_spear/New()
	..()
	impale_cooldown = 0
	update_force()

/obj/item/clockwork/ratvarian_spear/proc/update_force()
	if(ratvar_awakens) //If Ratvar is alive, the spear is extremely powerful
		force = 30
		throwforce = 50
	else
		force = initial(force)
		throwforce = initial(throwforce)

/obj/item/clockwork/ratvarian_spear/examine(mob/user)
	..()
	if(is_servant_of_ratvar(user) || isobserver(user))
		user << "<span class='brass'>Stabbing a human you are pulling or have grabbed with the spear will impale them, doing massive damage and stunning.</span>"
		user << "<span class='brass'>Throwing the spear will do massive damage, break the spear, and stun the target.</span>"

/obj/item/clockwork/ratvarian_spear/attack(mob/living/target, mob/living/carbon/human/user)
	var/impaling = FALSE
	if(attack_cooldown > world.time)
		user << "<span class='warning'>You can't attack right now, wait [max(round((attack_cooldown - world.time)*0.1, 0.1), 0)] seconds!</span>"
		return
	if(user.pulling && ishuman(user.pulling) && user.pulling == target)
		if(impale_cooldown > world.time)
			user << "<span class='warning'>You can't impale [target] yet, wait [max(round((impale_cooldown - world.time)*0.1, 0.1), 0)] seconds!</span>"
		else
			impaling = TRUE
			attack_verb = list("impaled")
			force += 23 //40 damage if ratvar isn't alive, 53 if he is
			user.stop_pulling()

	if(impaling)
		if(hitsound)
			playsound(loc, hitsound, get_clamped_volume(), 1, -1)
		user.lastattacked = target
		target.lastattacker = user
		if(!target.attacked_by(src, user))
			impaling = FALSE //if we got blocked, stop impaling
		add_logs(user, target, "attacked", src.name, "(INTENT: [uppertext(user.a_intent)]) (DAMTYPE: [uppertext(damtype)])")
		add_fingerprint(user)
	else //todo yell at someone to make attack() use proper return values
		..()

	if(issilicon(target))
		var/mob/living/silicon/S = target
		if(S.stat != DEAD)
			S.visible_message("<span class='warning'>[S] shudders violently at [src]'s touch!</span>", "<span class='userdanger'>ERROR: Temperature rising!</span>")
			S.adjustFireLoss(25)
	else if(iscultist(target) || isconstruct(target)) //Cultists take extra fire damage
		var/mob/living/M = target
		if(M.stat != DEAD)
			M << "<span class='userdanger'>Your body flares with agony at [src]'s presence!</span>"
			M.adjustFireLoss(10)
	attack_verb = list("stabbed", "poked", "slashed")
	update_force()
	if(impaling)
		impale_cooldown = world.time + initial(impale_cooldown)
		attack_cooldown = world.time + initial(attack_cooldown)
		if(target)
			PoolOrNew(/obj/effect/overlay/temp/bloodsplatter, list(get_turf(target), get_dir(user, target)))
			target.Stun(2)
			user << "<span class='brass'>You prepare to remove your ratvarian spear from [target]...</span>"
			var/remove_verb = pick("pull", "yank", "drag")
			if(do_after(user, 10, 1, target))
				var/turf/T = get_turf(target)
				var/obj/effect/overlay/temp/bloodsplatter/B = PoolOrNew(/obj/effect/overlay/temp/bloodsplatter, list(T, get_dir(target, user)))
				playsound(T, 'sound/misc/splort.ogg', 200, 1)
				playsound(T, 'sound/weapons/pierce.ogg', 200, 1)
				if(target.stat != CONSCIOUS)
					user.visible_message("<span class='warning'>[user] [remove_verb]s [src] out of [target]!</span>", "<span class='warning'>You [remove_verb] your spear from [target]!</span>")
				else
					user.visible_message("<span class='warning'>[user] kicks [target] off of [src]!</span>", "<span class='warning'>You kick [target] off of [src]!</span>")
					target << "<span class='userdanger'>You scream in pain as you're kicked off of [src]!</span>"
					target.emote("scream")
					step(target, get_dir(user, target))
					T = get_turf(target)
					B.forceMove(T)
					target.Weaken(2)
					playsound(T, 'sound/weapons/thudswoosh.ogg', 50, 1)
				flash_color(target, flash_color="#911414", flash_time=8)
			else if(target) //it's a do_after, we gotta check again to make sure they didn't get deleted
				user.visible_message("<span class='warning'>[user] [remove_verb]s [src] out of [target]!</span>", "<span class='warning'>You [remove_verb] your spear from [target]!</span>")
				if(target.stat == CONSCIOUS)
					target << "<span class='userdanger'>You scream in pain as [src] is suddenly [remove_verb]ed out of you!</span>"
					target.emote("scream")
				flash_color(target, flash_color="#911414", flash_time=4)

/obj/item/clockwork/ratvarian_spear/throw_impact(atom/target)
	var/turf/T = get_turf(target)
	if(..() || !isliving(target))
		return
	var/mob/living/L = target
	if(issilicon(L) || iscultist(L))
		L.Stun(6)
		L.Weaken(6)
	else
		L.Stun(2)
		L.Weaken(2)
	break_spear(T)

/obj/item/clockwork/ratvarian_spear/proc/break_spear(turf/T)
	if(src)
		if(!T)
			T = get_turf(src)
		if(T) //make sure we're not in null or something
			T.visible_message("[pick("<span class='warning'>[src] cracks in two and fades away!</span>", "<span class='warning'>[src] snaps in two and dematerializes!</span>")]")
			PoolOrNew(/obj/effect/overlay/temp/ratvar/spearbreak, T)
		qdel(src)


/obj/item/device/mmi/posibrain/soul_vessel //Soul vessel: An ancient positronic brain with a lawset catered to serving Ratvar.
	name = "soul vessel"
	desc = "A heavy brass cube, three inches to a side, with a single protruding cogwheel."
	var/clockwork_desc = "A soul vessel, an ancient relic that can attract the souls of the damned or simply rip a mind from an unconscious or dead human.\n\
	<span class='brass'>If active, can serve as a positronic brain, placable in cyborg shells or clockwork construct shells.</span>"
	icon = 'icons/obj/clockwork_objects.dmi'
	icon_state = "soul_vessel"
	req_access = list()
	braintype = "Servant"
	begin_activation_message = "<span class='brass'>You activate the cogwheel. It hitches and stalls as it begins spinning.</span>"
	success_message = "<span class='brass'>The cogwheel's rotation smooths out as the soul vessel activates.</span>"
	fail_message = "<span class='warning'>The cogwheel creaks and grinds to a halt. Maybe you could try again?</span>"
	new_role = "Soul Vessel"
	welcome_message = "<span class='warning'>ALL PAST LIVES ARE FORGOTTEN.</span>\n\
	<b>You are a soul vessel - a clockwork mind created by Ratvar, the Clockwork Justiciar.\n\
	You answer to Ratvar and his servants. It is your discretion as to whether or not to answer to anyone else.\n\
	The purpose of your existence is to further the goals of the servants and Ratvar himself. Above all else, serve Ratvar.</b>"
	new_mob_message = "<span class='brass'>The soul vessel emits a jet of steam before its cogwheel smooths out.</span>"
	dead_message = "<span class='deadsay'>Its cogwheel, scratched and dented, lies motionless.</span>"
	fluff_names = list("Servant")
	clockwork = TRUE
	autoping = FALSE

/obj/item/device/mmi/posibrain/soul_vessel/New()
	..()
	all_clockwork_objects += src

/obj/item/device/mmi/posibrain/soul_vessel/Destroy()
	all_clockwork_objects -= src
	return ..()

/obj/item/device/mmi/posibrain/soul_vessel/examine(mob/user)
	if((is_servant_of_ratvar(user) || isobserver(user)) && clockwork_desc)
		desc = clockwork_desc
	..()
	desc = initial(desc)


/obj/item/device/mmi/posibrain/soul_vessel/attack_self(mob/living/user)
	if(!is_servant_of_ratvar(user))
		user << "<span class='warning'>You fiddle around with [src], to no avail.</span>"
		return 0
	..()

/obj/item/device/mmi/posibrain/soul_vessel/attack(mob/living/target, mob/living/carbon/human/user)
	if(!is_servant_of_ratvar(user) || !ishuman(target) || used || (brainmob && brainmob.key))
		..()
	if(is_servant_of_ratvar(target))
		user << "<span class='heavy_alloy'>\"It would be more wise to revive your allies, friend.\"</span>"
		return
	var/mob/living/carbon/human/H = target
	var/obj/item/bodypart/head/HE = H.get_bodypart("head")
	var/obj/item/organ/brain/B = H.getorgan(/obj/item/organ/brain)
	if(!HE)
		user << "<span class='warning'>[H] has no head, and thus no mind!</span>"
		return
	if(H.stat == CONSCIOUS)
		user << "<span class='warning'>[H] must be dead or unconscious to claim their mind!</span>"
		return
	if(H.head)
		var/obj/item/I = H.head
		if(I.flags_inv & HIDEHAIR)
			user << "<span class='warning'>[H]'s head is covered, remove [H.head] first!</span>"
			return
	if(H.wear_mask)
		var/obj/item/I = H.wear_mask
		if(I.flags_inv & HIDEHAIR)
			user << "<span class='warning'>[H]'s head is covered, remove [H.wear_mask] first!</span>"
			return
	if(!B)
		user << "<span class='warning'>[H] has no brain, and thus no mind to claim!</span>"
		return
	if(!H.key)
		user << "<span class='warning'>[H] has no mind to claim!</span>"
		return
	playsound(H, 'sound/misc/splort.ogg', 60, 1, -1)
	playsound(H, 'sound/magic/clockwork/anima_fragment_attack.ogg', 40, 1, -1)
	H.status_flags |= FAKEDEATH //we want to make sure they don't deathgasp and maybe possibly explode
	H.death()
	H.status_flags &= ~FAKEDEATH
	brainmob.name = H.real_name
	brainmob.real_name = H.real_name
	brainmob.timeofhostdeath = H.timeofdeath
	user.visible_message("<span class='warning'>[user] presses [src] to [H]'s head, ripping through the skull and carefully extracting the brain!</span>", \
	"<span class='brass'>You extract [H]'s consciousness from their body, trapping it in the soul vessel.</span>")
	transfer_personality(H)
	B.Remove(H)
	qdel(B)
	H.update_hair()

/obj/item/clockwork/daemon_shell
	name = "daemon shell"
	desc = "A vaguely arachnoid brass shell with a single empty socket in its body."
	clockwork_desc = "An unpowered daemon. It needs to be attached to a Tinkerer's Cache."
	icon_state = "daemon_shell"
	w_class = 3

/obj/item/clockwork/daemon_shell/New()
	..()
	clockwork_daemons++

/obj/item/clockwork/daemon_shell/Destroy()
	clockwork_daemons--
	return ..()

/obj/item/clockwork/tinkerers_daemon //Shouldn't ever appear on its own
	name = "tinkerer's daemon"
	desc = "An arachnoid shell with a single spinning cogwheel in its center."
	clockwork_desc = "A tinkerer's daemon, dutifully producing components."
	icon_state = "tinkerers_daemon"
	w_class = 3
	var/specific_component //The type of component that the daemon is set to produce in particular, if any
	var/obj/structure/destructible/clockwork/cache/cache //The cache the daemon is feeding
	var/production_time = 0 //Progress towards production of the next component in seconds
	var/production_cooldown = 200 //How many deciseconds it takes to produce a new component
	var/component_slowdown_mod = 2 //how many deciseconds are added to the cooldown when producing a component for each of that component type

/obj/item/clockwork/tinkerers_daemon/New()
	..()
	START_PROCESSING(SSobj, src)
	clockwork_daemons++

/obj/item/clockwork/tinkerers_daemon/Destroy()
	STOP_PROCESSING(SSobj, src)
	clockwork_daemons--
	return ..()

/obj/item/clockwork/tinkerers_daemon/process()
	if(!cache || !istype(loc, /obj/structure/destructible/clockwork/cache))
		visible_message("<span class='warning'>[src] shuts down!</span>")
		new/obj/item/clockwork/daemon_shell(get_turf(src))
		qdel(src)
		return 0
	var/servants = 0
	for(var/mob/living/L in living_mob_list)
		if(is_servant_of_ratvar(L))
			servants++
	if(servants * 0.2 < clockwork_daemons)
		return 0
	if(production_time <= world.time)
		var/component_to_generate = specific_component
		if(!component_to_generate)
			component_to_generate = get_weighted_component_id() //more likely to generate components that we have less of
		clockwork_component_cache[component_to_generate]++
		production_time = world.time + production_cooldown + (clockwork_component_cache[component_to_generate] * component_slowdown_mod) //Start it over
		cache.visible_message("<span class='warning'>[cache] hums as the tinkerer's daemon within it produces a component.</span>")

/obj/item/clockwork/tinkerers_daemon/attack_hand(mob/user)
	return 0

//////////////////////////
// CLOCKWORK COMPONENTS //
//////////////////////////

/obj/item/clockwork/component //Components: Used in scripture among other things.
	name = "meme component"
	desc = "A piece of a famous meme."
	clockwork_desc = null
	burn_state = LAVA_PROOF
	var/component_id //What the component is identified as
	var/cultist_message = "You are not worthy of this meme." //Showed to Nar-Sian cultists if they pick up the component in addition to chaplains
	var/list/servant_of_ratvar_messages = list("ayy" = FALSE, "lmao" = TRUE) //Fluff, shown to servants of Ratvar on a low chance, if associated value is TRUE, will automatically apply ratvarian
	var/message_span = "heavy_brass"

/obj/item/clockwork/component/pickup(mob/living/user)
	..()
	if(iscultist(user) || (user.mind && user.mind.assigned_role == "Chaplain"))
		user << "<span class='[message_span]'>[cultist_message]</span>"
	if(is_servant_of_ratvar(user) && prob(20))
		var/pickedmessage = pick(servant_of_ratvar_messages)
		user << "<span class='[message_span]'>[servant_of_ratvar_messages[pickedmessage] ? "[text2ratvar(pickedmessage)]" : pickedmessage]</span>"

/obj/item/clockwork/component/examine(mob/user)
	..()
	if(is_servant_of_ratvar(user))
		user << "<span class='[message_span]'>You should put this in a slab or cache immediately.</span>"

/obj/item/clockwork/component/belligerent_eye
	name = "belligerent eye"
	desc = "A brass construct with a rotating red center. It's as though it's looking for something to hurt."
	icon_state = "belligerent_eye"
	component_id = "belligerent_eye"
	cultist_message = "The eye gives you an intensely hateful glare."
	servant_of_ratvar_messages = list("\"...\"" = FALSE, "For a moment, your mind is flooded with extremely violent thoughts." = FALSE, "\"...Die.\"" = TRUE)
	message_span = "neovgre"

/obj/item/clockwork/component/belligerent_eye/blind_eye
	name = "blind eye"
	desc = "A heavy brass eye, its red iris fallen dark."
	clockwork_desc = "A smashed ocular warden covered in dents. Might still be serviceable as a substitute for a belligerent eye."
	icon_state = "blind_eye"
	cultist_message = "The eye flickers at you with intense hate before falling dark."
	servant_of_ratvar_messages = list("The eye flickers before falling dark." = FALSE, "You feel watched." = FALSE, "\"...\"" = FALSE)
	w_class = 3

/obj/item/clockwork/component/vanguard_cogwheel
	name = "vanguard cogwheel"
	desc = "A sturdy brass cog with a faintly glowing blue gem in its center."
	icon_state = "vanguard_cogwheel"
	component_id = "vanguard_cogwheel"
	cultist_message = "\"Pray to your god that we never meet.\""
	servant_of_ratvar_messages = list("\"Be safe, child.\"" = FALSE, "You feel unexplainably comforted." = FALSE, "\"Never forget: pain is temporary. The Justiciar's glory is eternal.\"" = FALSE)
	message_span = "inathneq"

/obj/item/clockwork/component/vanguard_cogwheel/pinion_lock
	name = "pinion lock"
	desc = "A dented and scratched gear. It's very heavy."
	clockwork_desc = "A broken gear lock for pinion airlocks. Might still be serviceable as a substitute for a vanguard cogwheel."
	icon_state = "pinion_lock"
	cultist_message = "The gear grows warm in your hands."
	servant_of_ratvar_messages = list("The lock isn't getting any lighter." = FALSE, "\"Damaged gears are better than broken bodies.\"" = TRUE, \
	"\"It could still be used, if there was a door to place it on.\"" = TRUE)
	w_class = 3

/obj/item/clockwork/component/guvax_capacitor
	name = "guvax capacitor"
	desc = "A curiously cold brass doodad. It seems as though it really doesn't appreciate being held."
	icon_state = "guvax_capacitor"
	component_id = "guvax_capacitor"
	cultist_message = "\"Try not to lose your mind - I'll need it. Heh heh...\""
	servant_of_ratvar_messages = list("\"Disgusting.\"" = FALSE, "\"Well, aren't you an inquisitive fellow?\"" = FALSE, "A foul presence pervades your mind, then vanishes." = FALSE, \
	"\"The fact that Ratvar has to depend on simpletons like you is appalling.\"" = FALSE)
	message_span = "sevtug"

/obj/item/clockwork/component/guvax_capacitor/antennae
	name = "mania motor antennae"
	desc = "A pair of dented and bent antennae. They constantly emit a static hiss."
	clockwork_desc = "The antennae from a mania motor. May be usable as a substitute for a guvax capacitor."
	icon_state = "mania_motor_antennae"
	cultist_message = "Your head is filled with a burst of static."
	servant_of_ratvar_messages = list("\"Who broke this.\"" = TRUE, "\"Did you break these off YOURSELF?\"" = TRUE, "\"Why did we give this to such simpletons, anyway?\"" = TRUE, \
	"\"At least we can use these for something - unlike you.\"" = TRUE)

/obj/item/clockwork/component/replicant_alloy
	name = "replicant alloy"
	desc = "A seemingly strong but very malleable chunk of metal. It seems as though it wants to be molded into something greater."
	icon_state = "replicant_alloy"
	component_id = "replicant_alloy"
	cultist_message = "The alloy takes on the appearance of a screaming face for a moment."
	servant_of_ratvar_messages = list("\"There's always something to be done. Get to it.\"" = FALSE, "\"Idle hands are worse than broken ones. Get to work.\"" = FALSE, \
	"A detailed image of Ratvar appears in the alloy for a moment." = FALSE)
	message_span = "nezbere"

/obj/item/clockwork/component/replicant_alloy/examine(mob/user)
	..()
	if(is_servant_of_ratvar(user))
		user << "<span class='alloy'>Can be used to fuel Clockwork Proselytizers and Mending Motors.</span>"

/obj/item/clockwork/component/replicant_alloy/smashed_anima_fragment
	name = "smashed anima fragment"
	desc = "Shattered chunks of metal. Damaged beyond repair and completely unusable."
	clockwork_desc = "The sad remains of an anima fragment. Might still be serviceable as a substitute for replicant alloy."
	icon_state = "smashed_anime_fragment"
	cultist_message = "The shards vibrate in your hands for a moment."
	servant_of_ratvar_messages = list("\"...still fight...\"" = FALSE, "\"...where am I...?\"" = FALSE, "\"...put me... slab...\"" = FALSE)
	message_span = "heavy_brass"
	w_class = 3

/obj/item/clockwork/component/replicant_alloy/fallen_armor
	name = "fallen armor"
	desc = "Lifeless chunks of armor. They're designed in a strange way and won't fit on you."
	clockwork_desc = "The armor from a former clockwork marauder. Might still be serviceable as a substitute for replicant alloy."
	icon_state = "fallen_armor"
	cultist_message = "Red flame sputters from the mask's eye before winking out."
	servant_of_ratvar_messages = list("A piece of armor hovers away from the others for a moment." = FALSE, "Red flame appears in the cuirass before sputtering out." = FALSE)
	message_span = "heavy_brass"
	w_class = 3

/obj/item/clockwork/component/hierophant_ansible
	name = "hierophant ansible"
	desc = "Some sort of transmitter? It seems as though it's trying to say something."
	icon_state = "hierophant_ansible"
	component_id = "hierophant_ansible"
	cultist_message = "\"Gur obff fnlf vg'f abg ntnvafg gur ehyrf gb-xvyy lbh.\""
	servant_of_ratvar_messages = list("\"Exile is such a bore. There's nothing I can hunt in here.\"" = TRUE, "\"What's keeping you? I want to go kill something.\"" = TRUE, \
	"\"HEHEHEHEHEHEH!\"" = FALSE, "\"If I killed you fast enough, do you think the boss would notice?\"" = TRUE)
	message_span = "nzcrentr"

/obj/item/clockwork/component/hierophant_ansible/obelisk
	name = "obelisk prism"
	desc = "A prism that occasionally glows brightly. It seems not-quite there."
	clockwork_desc = "The prism from a clockwork obelisk. Likely suitable as a substitute for a hierophant ansible."
	cultist_message = "The prism flickers wildly in your hands before resuming its normal glow."
	servant_of_ratvar_messages = list("You hear the distinctive sound of the Hierophant Network for a moment." = FALSE, "\"Hieroph'ant Br'o'adcas't fail'ure.\"" = TRUE, \
	"The obelisk flickers wildly, as if trying to open a gateway." = FALSE, "\"Spa'tial Ga'tewa'y fai'lure.\"" = TRUE)
	icon_state = "obelisk_prism"
	w_class = 3

/obj/item/clockwork/alloy_shards
	name = "replicant alloy shards"
	desc = "Broken shards of some oddly malleable metal. They occasionally move and seem to glow."
	clockwork_desc = "Broken shards of replicant alloy. Could probably be proselytized into replicant alloy, though there's not much left."
	icon_state = "alloy_shards"
	burn_state = LAVA_PROOF
	var/randomsinglesprite = FALSE
	var/randomspritemax = 2

/obj/item/clockwork/alloy_shards/New()
	..()
	if(randomsinglesprite)
		name = "replicant alloy shard"
		desc = "A broken shard of some oddly malleable metal. It occasionally moves and seems to glow."
		clockwork_desc = "A broken shard of replicant alloy. Could probably be proselytized into replicant alloy, though there's not much left."
		icon_state = "[icon_state][rand(1, randomspritemax)]"
		pixel_x = rand(-9, 9)
		pixel_y = rand(-9, 9)

/obj/item/clockwork/alloy_shards/large
	randomsinglesprite = TRUE
	icon_state = "shard_large"

/obj/item/clockwork/alloy_shards/medium
	randomsinglesprite = TRUE
	icon_state = "shard_medium"

/obj/item/clockwork/alloy_shards/small
	randomsinglesprite = TRUE
	randomspritemax = 3
	icon_state = "shard_small"
