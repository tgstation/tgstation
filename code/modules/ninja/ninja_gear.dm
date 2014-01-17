/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
+++++++++++++++++++++++++++++++++//                    //++++++++++++++++++++++++++++++++++
===================================SPACE NINJA EQUIPMENT===================================
___________________________________________________________________________________________
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

/*
===================================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<SPACE NINJA SUIT>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
===================================================================================
*/

//Fuck you, Space Ninja, your code gets consolidated into normal people files.

/obj/item/clothing/head/helmet/space/space_ninja
	desc = "What may appear to be a simple black garment is in fact a highly sophisticated nano-weave helmet. Standard issue ninja gear."
	name = "ninja hood"
	icon_state = "s-ninja"
	item_state = "s-ninja_mask"
	allowed = list(/obj/item/weapon/cell)
	armor = list(melee = 60, bullet = 50, laser = 30,energy = 15, bomb = 30, bio = 30, rad = 25)


/obj/item/clothing/suit/space/space_ninja
	name = "ninja suit"
	desc = "A unique, vaccum-proof suit of nano-enhanced armor designed specifically for Spider Clan assassins."
	icon_state = "s-ninja"
	item_state = "s-ninja_suit"
	allowed = list(/obj/item/weapon/gun,/obj/item/ammo_box,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/handcuffs,/obj/item/weapon/tank/emergency_oxygen,/obj/item/weapon/cell)
	slowdown = 0
	armor = list(melee = 60, bullet = 50, laser = 30,energy = 15, bomb = 30, bio = 30, rad = 30)

		//Important parts of the suit.
	var/mob/living/carbon/affecting = null//The wearer.
	var/obj/item/weapon/cell/cell//Starts out with a high-capacity cell using New().
	var/datum/effect/effect/system/spark_spread/spark_system//To create sparks.
	var/reagent_list[] = list("tricordrazine","dexalinp","spaceacillin","anti_toxin","nutriment","radium","hyronalin")//The reagents ids which are added to the suit at New().
	var/stored_research[]//For stealing station research.
	var/obj/item/weapon/disk/tech_disk/t_disk//To copy design onto disk.

		//Other articles of ninja gear worn together, used to easily reference them after initializing.
	var/obj/item/clothing/head/helmet/space/space_ninja/n_hood
	var/obj/item/clothing/shoes/space_ninja/n_shoes
	var/obj/item/clothing/gloves/space_ninja/n_gloves

		//Main function variables.
	var/s_initialized = 0//Suit starts off.
	var/s_coold = 0//If the suit is on cooldown. Can be used to attach different cooldowns to abilities. Ticks down every second based on suit ntick().
	var/s_cost = 5.0//Base energy cost each ntick.
	var/s_acost = 25.0//Additional cost for additional powers active.
	var/k_cost = 200.0//Kamikaze energy cost each ntick.
	var/k_damage = 1.0//Brute damage potentially done by Kamikaze each ntick.
	var/s_delay = 40.0//How fast the suit does certain things, lower is faster. Can be overridden in specific procs. Also determines adverse probability.
	var/a_transfer = 20.0//How much reagent is transferred when injecting.
	var/r_maxamount = 80.0//How much reagent in total there is.

		//Support function variables.
	var/spideros = 0//Mode of SpiderOS. This can change so I won't bother listing the modes here (0 is hub). Check ninja_equipment.dm for how it all works.
	var/s_active = 0//Stealth off.
	var/s_busy = 0//Is the suit busy with a process? Like AI hacking. Used for safety functions.
	var/kamikaze = 0//Kamikaze on or off.
	var/k_unlock = 0//To unlock Kamikaze.

		//Ability function variables.
	var/s_bombs = 10.0//Number of starting ninja smoke bombs.
	var/a_boost = 3.0//Number of adrenaline boosters.

		//Onboard AI related variables.
	var/mob/living/silicon/ai/AI//If there is an AI inside the suit.
	var/obj/item/device/paicard/pai//A slot for a pAI device
	var/obj/effect/overlay/hologram//Is the AI hologram on or off? Visible only to the wearer of the suit. This works by attaching an image to a blank overlay.
	var/flush = 0//If an AI purge is in progress.
	var/s_control = 1//If user in control of the suit.


//=======//NEW AND DEL//=======//

/obj/item/clothing/suit/space/space_ninja/New()
	..()
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/init//suit initialize verb
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/ai_instruction//for AIs
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/ai_holo
	//verbs += /obj/item/clothing/suit/space/space_ninja/proc/display_verb_procs//DEBUG. Doesn't work.
	spark_system = new()//spark initialize
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)
	stored_research = new()//Stolen research initialize.
	for(var/T in typesof(/datum/tech) - /datum/tech)//Store up on research.
		stored_research += new T(src)
	var/reagent_amount//reagent initialize
	for(var/reagent_id in reagent_list)
		reagent_amount += reagent_id == "radium" ? r_maxamount+(a_boost*a_transfer) : r_maxamount//AI can inject radium directly.
	reagents = new(reagent_amount)
	reagents.my_atom = src
	for(var/reagent_id in reagent_list)
		reagent_id == "radium" ? reagents.add_reagent(reagent_id, r_maxamount+(a_boost*a_transfer)) : reagents.add_reagent(reagent_id, r_maxamount)//It will take into account radium used for adrenaline boosting.
	cell = new/obj/item/weapon/cell/high//The suit should *always* have a battery because so many things rely on it.
	cell.charge = 9000//Starting charge should not be higher than maximum charge. It leads to problems with recharging.

/obj/item/clothing/suit/space/space_ninja/Del()
	if(affecting)//To make sure the window is closed.
		affecting << browse(null, "window=hack spideros")
	if(AI)//If there are AIs present when the ninja kicks the bucket.
		killai()
	if(hologram)//If there is a hologram
		del(hologram.i_attached)//Delete it and the attached image.
		del(hologram)
	..()
	return

//Simply deletes all the attachments and self, killing all related procs.
/obj/item/clothing/suit/space/space_ninja/proc/terminate()
	del(n_hood)
	del(n_gloves)
	del(n_shoes)
	del(src)

/obj/item/clothing/suit/space/space_ninja/proc/killai(mob/living/silicon/ai/A = AI)
	if(A.client)
		A << "\red Self-erase protocol dete-- *bzzzzz*"
		A << browse(null, "window=hack spideros")
	AI = null
	A.death(1)//Kill, deleting mob.
	del(A)
	return

//=======//SUIT VERBS//=======//
//Verbs link to procs because verb-like procs have a bug which prevents their use if the arguments are not readily referenced.

/obj/item/clothing/suit/space/space_ninja/proc/init()
	set name = "Initialize Suit"
	set desc = "Initializes the suit for field operation."
	set category = "Ninja Equip"

	ninitialize()
	return

/obj/item/clothing/suit/space/space_ninja/proc/deinit()
	set name = "De-Initialize Suit"
	set desc = "Begins procedure to remove the suit."
	set category = "Ninja Equip"

	if(s_control&&!s_busy)
		deinitialize()
	else
		affecting << "\red The function did not trigger!"
	return

/obj/item/clothing/suit/space/space_ninja/proc/spideros()
	set name = "Display SpiderOS"
	set desc = "Utilize built-in computer system."
	set category = "Ninja Equip"

	if(s_control&&!s_busy&&!kamikaze)
		display_spideros()
	else
		affecting << "\red The interface is locked!"
	return

/obj/item/clothing/suit/space/space_ninja/proc/stealth()
	set name = "Toggle Stealth"
	set desc = "Utilize the internal CLOAK-tech device to activate or deactivate stealth-camo."
	set category = "Ninja Equip"

	if(s_control&&!s_busy)
		toggle_stealth()
	else
		affecting << "\red Stealth does not appear to work!"
	return

//=======//PROCESS PROCS//=======//

/obj/item/clothing/suit/space/space_ninja/proc/ntick(mob/living/carbon/human/U = affecting)
	set background = BACKGROUND_ENABLED

	//Runs in the background while the suit is initialized.
	spawn while(cell.charge>=0)

		//Let's check for some safeties.
		if(s_initialized&&!affecting)	terminate()//Kills the suit and attached objects.
		if(!s_initialized)	return//When turned off the proc stops.
		if(AI&&AI.stat==2)//If there is an AI and it's ded. Shouldn't happen without purging, could happen.
			if(!s_control)
				ai_return_control()//Return control to ninja if the AI was previously in control.
			killai()//Delete AI.

		//Now let's do the normal processing.
		if(s_coold)	s_coold--//Checks for ability s_cooldown first.
		var/A = s_cost//s_cost is the default energy cost each ntick, usually 5.
		if(!kamikaze)
			if(blade_check(U))//If there is a blade held in hand.
				A += s_acost
			if(s_active)//If stealth is active.
				A += s_acost
		else
			if(prob(s_delay))//Suit delay is used as probability. May change later.
				U.adjustBruteLoss(k_damage)//Default damage done, usually 1.
			A = k_cost//kamikaze cost.
		cell.charge-=A
		if(cell.charge<=0)
			if(kamikaze)
				U.say("I DIE TO LIVE AGAIN!")
				U << browse(null, "window=spideros")//Just in case.
				U.death()
				return
			cell.charge=0
			cancel_stealth()
		sleep(10)//Checks every second.

//=======//INITIALIZE//=======//

/obj/item/clothing/suit/space/space_ninja/proc/ninitialize(delay = s_delay, mob/living/carbon/human/U = loc)
	if(U.mind && U.mind.assigned_role=="MODE" && !s_initialized && !s_busy)//Shouldn't be busy... but anything is possible I guess.
		s_busy = 1
		for(var/i,i<7,i++)
			switch(i)
				if(0)
					U << "\blue Now initializing..."
				if(1)
					if(!lock_suit(U))//To lock the suit onto wearer.
						break
					U << "\blue Securing external locking mechanism...\nNeural-net established."
				if(2)
					U << "\blue Extending neural-net interface...\nNow monitoring brain wave pattern..."
				if(3)
					if(U.stat==2||U.health<=0)
						U << "\red <B>FĆAL �Rr�R</B>: 344--93#�&&21 BR��N |/|/aV� PATT$RN <B>RED</B>\nA-A-aB�rT�NG..."
						unlock_suit()
						break
					lock_suit(U,1)//Check for icons.
					U.regenerate_icons()
					U << "\blue Linking neural-net interface...\nPattern \green <B>GREEN</B>\blue, continuing operation."
				if(4)
					U << "\blue VOID-shift device status: <B>ONLINE</B>.\nCLOAK-tech device status: <B>ONLINE</B>."
				if(5)
					U << "\blue Primary system status: <B>ONLINE</B>.\nBackup system status: <B>ONLINE</B>.\nCurrent energy capacity: <B>[cell.charge]</B>."
				if(6)
					U << "\blue All systems operational. Welcome to <B>SpiderOS</B>, [U.real_name]."
					grant_ninja_verbs()
					grant_equip_verbs()
					ntick()
			sleep(delay)
		s_busy = 0
	else
		if(!U.mind||U.mind.assigned_role!="MODE")//Your run of the mill persons shouldn't know what it is. Or how to turn it on.
			U << "You do not understand how this suit functions. Where the heck did it even come from?"
		else if(s_initialized)
			U << "\red The suit is already functioning. \black <b>Please report this bug.</b>"
		else
			U << "\red <B>ERROR</B>: \black You cannot use this function at this time."
	return

//=======//DEINITIALIZE//=======//

/obj/item/clothing/suit/space/space_ninja/proc/deinitialize(delay = s_delay)
	if(affecting==loc&&!s_busy)
		var/mob/living/carbon/human/U = affecting
		if(!s_initialized)
			U << "\red The suit is not initialized. \black <b>Please report this bug.</b>"
			return
		if(alert("Are you certain you wish to remove the suit? This will take time and remove all abilities.",,"Yes","No")=="No")
			return
		if(s_busy||flush)
			U << "\red <B>ERROR</B>: \black You cannot use this function at this time."
			return
		s_busy = 1
		for(var/i = 0,i<7,i++)
			switch(i)
				if(0)
					U << "\blue Now de-initializing..."
					remove_kamikaze(U)//Shutdowns kamikaze.
					spideros = 0//Spideros resets.
				if(1)
					U << "\blue Logging off, [U:real_name]. Shutting down <B>SpiderOS</B>."
					remove_ninja_verbs()
				if(2)
					U << "\blue Primary system status: <B>OFFLINE</B>.\nBackup system status: <B>OFFLINE</B>."
				if(3)
					U << "\blue VOID-shift device status: <B>OFFLINE</B>.\nCLOAK-tech device status: <B>OFFLINE</B>."
					cancel_stealth()//Shutdowns stealth.
				if(4)
					U << "\blue Disconnecting neural-net interface...\green<B>Success</B>\blue."
				if(5)
					U << "\blue Disengaging neural-net interface...\green<B>Success</B>\blue."
				if(6)
					U << "\blue Unsecuring external locking mechanism...\nNeural-net abolished.\nOperation status: <B>FINISHED</B>."
					blade_check(U,2)
					remove_equip_verbs()
					unlock_suit()
					U.regenerate_icons()
			sleep(delay)
		s_busy = 0
	return



//=======//SPECIAL AI FUNCTIONS//=======//

/obj/item/clothing/suit/space/space_ninja/proc/ai_holo(var/turf/T in oview(3,affecting))//To have an internal AI display a hologram to the AI and ninja only.
	set name = "Display Hologram"
	set desc = "Channel a holographic image directly to the user's field of vision. Others will not see it."
	set category = null
	set src = usr.loc

	if(s_initialized&&affecting&&affecting.client&&istype(affecting.loc, /turf))//If the host exists and they are playing, and their location is a turf.
		if(!hologram)//If there is not already a hologram.
			hologram = new(T)//Spawn a blank effect at the location.
			hologram.invisibility = 101//So that it doesn't show up, ever. This also means one could attach a number of images to a single obj and display them differently to differnet people.
			hologram.anchored = 1//So it cannot be dragged by space wind and the like.
			hologram.dir = get_dir(T,affecting.loc)
			var/image/I = image(AI.holo_icon,hologram)//Attach an image to object.
			hologram.i_attached = I//To attach the image in order to later reference.
			AI << I
			affecting << I
			affecting << "<i>An image flicks to life nearby. It appears visible to you only.</i>"

			verbs += /obj/item/clothing/suit/space/space_ninja/proc/ai_holo_clear

			ai_holo_process()//Move to initialize
		else
			AI << "\red ERROR: \black Image feed in progress."
	else
		AI << "\red ERROR: \black Unable to project image."
	return

/obj/item/clothing/suit/space/space_ninja/proc/ai_holo_process()
	set background = BACKGROUND_ENABLED

	spawn while(hologram&&s_initialized&&AI)//Suit on and there is an AI present.
		if(!s_initialized||get_dist(affecting,hologram.loc)>3)//Once suit is de-initialized or hologram reaches out of bounds.
			del(hologram.i_attached)
			del(hologram)

			verbs -= /obj/item/clothing/suit/space/space_ninja/proc/ai_holo_clear
			return
		sleep(10)//Checks every second.

/obj/item/clothing/suit/space/space_ninja/proc/ai_instruction()//Let's the AI know what they can do.
	set name = "Instructions"
	set desc = "Displays a list of helpful information."
	set category = "AI Ninja Equip"
	set src = usr.loc

	AI << "The menu you are seeing will contain other commands if they become available.\nRight click a nearby turf to display an AI Hologram. It will only be visible to you and your host. You can move it freely using normal movement keys--it will disappear if placed too far away."

/obj/item/clothing/suit/space/space_ninja/proc/ai_holo_clear()
	set name = "Clear Hologram"
	set desc = "Stops projecting the current holographic image."
	set category = "AI Ninja Equip"
	set src = usr.loc

	del(hologram.i_attached)
	del(hologram)

	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/ai_holo_clear
	return

/obj/item/clothing/suit/space/space_ninja/proc/ai_hack_ninja()
	set name = "Hack SpiderOS"
	set desc = "Hack directly into the Black Widow(tm) neuro-interface."
	set category = "AI Ninja Equip"
	set src = usr.loc

	display_spideros()
	return

/obj/item/clothing/suit/space/space_ninja/proc/ai_return_control()
	set name = "Relinquish Control"
	set desc = "Return control to the user."
	set category = "AI Ninja Equip"
	set src = usr.loc

	AI << browse(null, "window=spideros")//Close window
	AI << "You have seized your hacking attempt. [affecting.real_name] has regained control."
	affecting << "<b>UPDATE</b>: [AI.real_name] has ceased hacking attempt. All systems clear."

	remove_AI_verbs()
	return

//=======//GENERAL SUIT PROCS//=======//

/obj/item/clothing/suit/space/space_ninja/attackby(obj/item/I, mob/U)
	if(U==affecting)//Safety, in case you try doing this without wearing the suit/being the person with the suit.
		if(istype(I, /obj/item/device/aicard))//If it's an AI card.
			if(s_control)
				I:transfer_ai("NINJASUIT","AICARD",src,U)
			else
				U << "\red <b>ERROR</b>: \black Remote access channel disabled."
			return//Return individually so that ..() can run properly at the end of the proc.
		else if(istype(I, /obj/item/device/paicard) && !pai)//If it's a pai card.
			U:drop_item()
			I.loc = src
			pai = I
			U << "\blue You slot \the [I] into \the [src]."
			updateUsrDialog()
			return
		else if(istype(I, /obj/item/weapon/reagent_containers/glass))//If it's a glass beaker.
			var/total_reagent_transfer//Keep track of this stuff.
			for(var/reagent_id in reagent_list)
				var/datum/reagent/R = I.reagents.has_reagent(reagent_id)//Mostly to pull up the name of the reagent after calculating. Also easier to use than writing long proc paths.
				if(R&&reagents.get_reagent_amount(reagent_id)<r_maxamount+(reagent_id == "radium"?(a_boost*a_transfer):0)&&R.volume>=a_transfer)//Radium is always special.
					//Here we determine how much reagent will actually transfer if there is enough to transfer or there is a need of transfer. Minimum of max amount available (using a_transfer) or amount needed.
					var/amount_to_transfer = min( (r_maxamount+(reagent_id == "radium"?(a_boost*a_transfer):0)-reagents.get_reagent_amount(reagent_id)) ,(round(R.volume/a_transfer))*a_transfer)//In the end here, we round the amount available, then multiply it again.
					R.volume -= amount_to_transfer//Remove from reagent volume. Don't want to delete the reagent now since we need to perserve the name.
					reagents.add_reagent(reagent_id, amount_to_transfer)//Add to suit. Reactions are not important.
					total_reagent_transfer += amount_to_transfer//Add to total reagent trans.
					U << "Added [amount_to_transfer] units of [R.name]."//Reports on the specific reagent added.
					I.reagents.update_total()//Now we manually update the total to make sure everything is properly shoved under the rug.

			U << "Replenished a total of [total_reagent_transfer ? total_reagent_transfer : "zero"] chemical units."//Let the player know how much total volume was added.
			return
		else if(istype(I, /obj/item/weapon/cell))
			if(I:maxcharge>cell.maxcharge&&n_gloves&&n_gloves.candrain)
				U << "\blue Higher maximum capacity detected.\nUpgrading..."
				if (n_gloves&&n_gloves.candrain&&do_after(U,s_delay))
					U.drop_item()
					I.loc = src
					I:charge = min(I:charge+cell.charge, I:maxcharge)
					var/obj/item/weapon/cell/old_cell = cell
					old_cell.charge = 0
					U.put_in_hands(old_cell)
					old_cell.add_fingerprint(U)
					old_cell.corrupt()
					old_cell.updateicon()
					cell = I
					U << "\blue Upgrade complete. Maximum capacity: <b>[round(cell.maxcharge/100)]</b>%"
				else
					U << "\red Procedure interrupted. Protocol terminated."
			return
		else if(istype(I, /obj/item/weapon/disk/tech_disk))//If it's a data disk, we want to copy the research on to the suit.
			var/obj/item/weapon/disk/tech_disk/TD = I
			if(TD.stored)//If it has something on it.
				U << "Research information detected, processing..."
				if(do_after(U,s_delay))
					for(var/datum/tech/current_data in stored_research)
						if(current_data.id==TD.stored.id)
							if(current_data.level<TD.stored.level)
								current_data.level=TD.stored.level
							break
					TD.stored = null
					U << "\blue Data analyzed and updated. Disk erased."
				else
					U << "\red <b>ERROR</b>: \black Procedure interrupted. Process terminated."
			else
				I.loc = src
				t_disk = I
				U << "\blue You slot \the [I] into \the [src]."
			return
	..()

/obj/item/clothing/suit/space/space_ninja/proc/toggle_stealth()
	var/mob/living/carbon/human/U = affecting
	if(s_active)
		cancel_stealth()
	else
		spawn(0)
			anim(U.loc,U,'icons/mob/mob.dmi',,"cloak",,U.dir)
		s_active=!s_active
		U.update_icons()	//update their icons
		U << "\blue You are now invisible to normal detection."
		for(var/mob/O in oviewers(U))
			O.show_message("[U.name] vanishes into thin air!",1)
	return

/obj/item/clothing/suit/space/space_ninja/proc/cancel_stealth()
	var/mob/living/carbon/human/U = affecting
	if(s_active)
		spawn(0)
			anim(U.loc,U,'icons/mob/mob.dmi',,"uncloak",,U.dir)
		s_active=!s_active
		U.update_icons()	//update their icons
		U << "\blue You are now visible."
		for(var/mob/O in oviewers(U))
			O.show_message("[U.name] appears from thin air!",1)
		return 1
	return 0

/obj/item/clothing/suit/space/space_ninja/proc/blade_check(mob/living/carbon/U, X = 1)//Default to checking for blade energy.
	switch(X)
		if(1)
			if(istype(U.get_active_hand(), /obj/item/weapon/melee/energy/blade))
				if(cell.charge<=0)//If no charge left.
					U.drop_item()//Blade is dropped from active hand (and deleted).
				else	return 1
			else if(istype(U.get_inactive_hand(), /obj/item/weapon/melee/energy/blade))
				if(cell.charge<=0)
					U.swap_hand()//swap hand
					U.drop_item()//drop blade
				else	return 1
		if(2)
			if(istype(U.get_active_hand(), /obj/item/weapon/melee/energy/blade))
				U.drop_item()
			if(istype(U.get_inactive_hand(), /obj/item/weapon/melee/energy/blade))
				U.swap_hand()
				U.drop_item()
	return 0

/obj/item/clothing/suit/space/space_ninja/examine()
	set src in view()
	..()
	if(s_initialized)
		var/mob/living/carbon/human/U = affecting
		if(s_control)
			U << "All systems operational. Current energy capacity: <B>[cell.charge]</B>."
			if(!kamikaze)
				U << "The CLOAK-tech device is <B>[s_active?"active":"inactive"]</B>."
			else
				U << "\red KAMIKAZE MODE ENGAGED!"
			U << "There are <B>[s_bombs]</B> smoke bombs remaining."
			U << "There are <B>[a_boost]</B> adrenaline boosters remaining."
		else
			U <<  "�rr�R �a��a�� No-�-� f��N� 3RR�r"

/*
===================================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<SPACE NINJA GLOVES>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
===================================================================================
*/

/*
	Dear ninja gloves

	This isn't because I like you
	this is because your father is a bastard

	...
	I guess you're a little cool.
	 -Sayu
*/

/obj/item/clothing/gloves/space_ninja
	desc = "These nano-enhanced gloves insulate from electricity and provide fire resistance."
	name = "ninja gloves"
	icon_state = "s-ninja"
	item_state = "s-ninja"
	siemens_coefficient = 0
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	var/draining = 0
	var/candrain = 0
	var/mindrain = 200
	var/maxdrain = 400

/*
	This runs the gamut of what ninja gloves can do
	The other option would be a dedicated ninja touch bullshit proc on everything
	which would probably more efficient, but ninjas are pretty rare.
	This was mostly introduced to keep ninja code from contaminating other code;
	with this in place it would be easier to untangle the rest of it.

	For the drain proc, see events/ninja.dm
*/
/obj/item/clothing/gloves/space_ninja/Touch(var/atom/A,var/proximity)
	if(!candrain || draining) return 0

	var/mob/living/carbon/human/H = loc
	if(!istype(H)) return 0 // what
	var/obj/item/clothing/suit/space/space_ninja/suit = H.wear_suit
	if(!istype(suit)) return 0
	if(isturf(A)) return 0

	if(!proximity) // todo: you could add ninja stars or computer hacking here
		return 0

	// Move an AI into and out of things
	if(istype(A,/mob/living/silicon/ai))
		if(suit.s_control)
			A.add_fingerprint(H)
			suit.transfer_ai("AICORE", "NINJASUIT", A, H)
			return 1
		else
			H << "\red <b>ERROR</b>: \black Remote access channel disabled."
			return 0

	if(istype(A,/obj/structure/AIcore/deactivated))
		if(suit.s_control)
			A.add_fingerprint(H)
			suit.transfer_ai("INACTIVE","NINJASUIT",A, H)
			return 1
		else
			H << "\red <b>ERROR</b>: \black Remote access channel disabled."
			return 0
	if(istype(A,/obj/machinery/computer/aifixer))
		if(suit.s_control)
			A.add_fingerprint(H)
			suit.transfer_ai("AIFIXER","NINJASUIT",A, H)
			return 1
		else
			H << "\red <b>ERROR</b>: \black Remote access channel disabled."
			return 0

	// steal energy from powered things
	if(istype(A,/mob/living/silicon/robot))
		A.add_fingerprint(H)
		drain("CYBORG",A,suit)
		return 1
	if(istype(A,/obj/machinery/power/apc))
		A.add_fingerprint(H)
		drain("APC",A,suit)
		return 1
	if(istype(A,/obj/structure/cable))
		A.add_fingerprint(H)
		drain("WIRE",A,suit)
		return 1
	if(istype(A,/obj/structure/grille))
		var/obj/structure/cable/C = locate() in A.loc
		if(C)
			drain("WIRE",C,suit)
		return 1
	if(istype(A,/obj/machinery/power/smes))
		A.add_fingerprint(H)
		drain("SMES",A,suit)
		return 1
	if(istype(A,/obj/mecha))
		A.add_fingerprint(H)
		drain("MECHA",A,suit)
		return 1

	// download research
	if(istype(A,/obj/machinery/computer/rdconsole))
		A.add_fingerprint(H)
		drain("RESEARCH",A,suit)
		return 1
	if(istype(A,/obj/machinery/r_n_d/server))
		A.add_fingerprint(H)
		var/obj/machinery/r_n_d/server/S = A
		if(S.disabled)
			return 1
		if(S.shocked)
			S.shock(H,50)
			return 1
		drain("RESEARCH",A,suit)
		return 1


//=======//ENERGY DRAIN PROCS//=======//

/obj/item/clothing/gloves/space_ninja/proc/drain(target_type as text, target, obj/suit)
//Var Initialize
	var/obj/item/clothing/suit/space/space_ninja/S = suit
	var/mob/living/carbon/human/U = S.affecting
	var/obj/item/clothing/gloves/space_ninja/G = S.n_gloves

	var/drain = 0//To drain from battery.
	var/maxcapacity = 0//Safety check for full battery.
	var/totaldrain = 0//Total energy drained.

	G.draining = 1

	if(target_type!="RESEARCH")//I lumped research downloading here for ease of use.
		U << "\blue Now charging battery..."

	switch(target_type)

		if("APC")
			var/obj/machinery/power/apc/A = target
			if(A.cell&&A.cell.charge)
				var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
				spark_system.set_up(5, 0, A.loc)
				while(G.candrain&&A.cell.charge>0&&!maxcapacity)
					drain = rand(G.mindrain,G.maxdrain)
					if(A.cell.charge<drain)
						drain = A.cell.charge
					if(S.cell.charge+drain>S.cell.maxcharge)
						drain = S.cell.maxcharge-S.cell.charge
						maxcapacity = 1//Reached maximum battery capacity.
					if (do_after(U,10))
						spark_system.start()
						playsound(A.loc, "sparks", 50, 1)
						A.cell.charge-=drain
						S.cell.charge+=drain
						totaldrain+=drain
					else	break
				U << "\blue Gained <B>[totaldrain]</B> energy from the APC."
				if(!A.emagged)
					flick("apc-spark", src)
					A.emagged = 1
					A.locked = 0
					A.update_icon()
			else
				U << "\red This APC has run dry of power. You must find another source."

		if("SMES")
			var/obj/machinery/power/smes/A = target
			if(A.charge)
				var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
				spark_system.set_up(5, 0, A.loc)
				while(G.candrain&&A.charge>0&&!maxcapacity)
					drain = rand(G.mindrain,G.maxdrain)
					if(A.charge<drain)
						drain = A.charge
					if(S.cell.charge+drain>S.cell.maxcharge)
						drain = S.cell.maxcharge-S.cell.charge
						maxcapacity = 1
					if (do_after(U,10))
						spark_system.start()
						playsound(A.loc, "sparks", 50, 1)
						A.charge-=drain
						S.cell.charge+=drain
						totaldrain+=drain
					else	break
				U << "\blue Gained <B>[totaldrain]</B> energy from the SMES cell."
			else
				U << "\red This SMES cell has run dry of power. You must find another source."

		if("CELL")
			var/obj/item/weapon/cell/A = target
			if(A.charge)
				if (G.candrain&&do_after(U,30))
					U << "\blue Gained <B>[A.charge]</B> energy from the cell."
					if(S.cell.charge+A.charge>S.cell.maxcharge)
						S.cell.charge=S.cell.maxcharge
					else
						S.cell.charge+=A.charge
					A.charge = 0
					G.draining = 0
					A.corrupt()
					A.updateicon()
				else
					U << "\red Procedure interrupted. Protocol terminated."
			else
				U << "\red This cell is empty and of no use."

		if("MACHINERY")//Can be applied to generically to all powered machinery. I'm leaving this alone for now.
			var/obj/machinery/A = target
			if(A.powered())//If powered.

				var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
				spark_system.set_up(5, 0, A.loc)

				var/obj/machinery/power/apc/B = A.loc.loc:get_apc()//Object.turf.area find APC
				if(B)//If APC exists. Might not if the area is unpowered like Centcom.
					var/datum/powernet/PN = B.terminal.powernet
					while(G.candrain&&!maxcapacity&&!isnull(A))//And start a proc similar to drain from wire.
						drain = rand(G.mindrain,G.maxdrain)
						var/drained = 0
						if(PN&&do_after(U,10))
							drained = min(drain, PN.avail)
							PN.newload += drained
							if(drained < drain)//if no power on net, drain apcs
								for(var/obj/machinery/power/terminal/T in PN.nodes)
									if(istype(T.master, /obj/machinery/power/apc))
										var/obj/machinery/power/apc/AP = T.master
										if(AP.operating && AP.cell && AP.cell.charge>0)
											AP.cell.charge = max(0, AP.cell.charge - 5)
											drained += 5
						else	break
						S.cell.charge += drained
						if(S.cell.charge>S.cell.maxcharge)
							totaldrain += (drained-(S.cell.charge-S.cell.maxcharge))
							S.cell.charge = S.cell.maxcharge
							maxcapacity = 1
						else
							totaldrain += drained
						spark_system.start()
						if(drained==0)	break
					U << "\blue Gained <B>[totaldrain]</B> energy from the power network."
				else
					U << "\red Power network could not be found. Aborting."
			else
				U << "\red This recharger is not providing energy. You must find another source."

		if("RESEARCH")
			var/obj/machinery/A = target
			U << "\blue Hacking \the [A]..."
			spawn(0)
				var/turf/location = get_turf(U)
				for(var/mob/living/silicon/ai/AI in player_list)
					AI << "\red <b>Network Alert: Hacking attempt detected[location?" in [location]":". Unable to pinpoint location"]</b>."
			if(A:files&&A:files.known_tech.len)
				for(var/datum/tech/current_data in S.stored_research)
					U << "\blue Checking \the [current_data.name] database."
					if(do_after(U, S.s_delay)&&G.candrain&&!isnull(A))
						for(var/datum/tech/analyzing_data in A:files.known_tech)
							if(current_data.id==analyzing_data.id)
								if(analyzing_data.level>current_data.level)
									U << "\blue Database: \black <b>UPDATED</b>."
									current_data.level = analyzing_data.level
								break//Move on to next.
					else	break//Otherwise, quit processing.
			U << "\blue Data analyzed. Process finished."

		if("WIRE")
			var/obj/structure/cable/A = target
			var/datum/powernet/PN = A.get_powernet()
			while(G.candrain&&!maxcapacity&&!isnull(A))
				drain = (round((rand(G.mindrain,G.maxdrain))/2))
				var/drained = 0
				if(PN&&do_after(U,10))
					drained = min(drain, PN.avail)
					PN.newload += drained
					if(drained < drain)//if no power on net, drain apcs
						for(var/obj/machinery/power/terminal/T in PN.nodes)
							if(istype(T.master, /obj/machinery/power/apc))
								var/obj/machinery/power/apc/AP = T.master
								if(AP.operating && AP.cell && AP.cell.charge>0)
									AP.cell.charge = max(0, AP.cell.charge - 5)
									drained += 5
				else	break
				S.cell.charge += drained
				if(S.cell.charge>S.cell.maxcharge)
					totaldrain += (drained-(S.cell.charge-S.cell.maxcharge))
					S.cell.charge = S.cell.maxcharge
					maxcapacity = 1
				else
					totaldrain += drained
				S.spark_system.start()
				if(drained==0)	break
			U << "\blue Gained <B>[totaldrain]</B> energy from the power network."

		if("MECHA")
			var/obj/mecha/A = target
			A.occupant_message("\red Warning: Unauthorized access through sub-route 4, block H, detected.")
			if(A.get_charge())
				while(G.candrain&&A.cell.charge>0&&!maxcapacity)
					drain = rand(G.mindrain,G.maxdrain)
					if(A.cell.charge<drain)
						drain = A.cell.charge
					if(S.cell.charge+drain>S.cell.maxcharge)
						drain = S.cell.maxcharge-S.cell.charge
						maxcapacity = 1
					if (do_after(U,10))
						A.spark_system.start()
						playsound(A.loc, "sparks", 50, 1)
						A.cell.use(drain)
						S.cell.charge+=drain
						totaldrain+=drain
					else	break
				U << "\blue Gained <B>[totaldrain]</B> energy from [src]."
			else
				U << "\red The exosuit's battery has run dry. You must find another source of power."

		if("CYBORG")
			var/mob/living/silicon/robot/A = target
			A << "\red Warning: Unauthorized access through sub-route 12, block C, detected."
			G.draining = 1
			if(A.cell&&A.cell.charge)
				while(G.candrain&&A.cell.charge>0&&!maxcapacity)
					drain = rand(G.mindrain,G.maxdrain)
					if(A.cell.charge<drain)
						drain = A.cell.charge
					if(S.cell.charge+drain>S.cell.maxcharge)
						drain = S.cell.maxcharge-S.cell.charge
						maxcapacity = 1
					if (do_after(U,10))
						A.spark_system.start()
						playsound(A.loc, "sparks", 50, 1)
						A.cell.charge-=drain
						S.cell.charge+=drain
						totaldrain+=drain
					else	break
				U << "\blue Gained <B>[totaldrain]</B> energy from [A]."
			else
				U << "\red Their battery has run dry of power. You must find another source."

		else//Else nothing :<

	G.draining = 0

	return

//=======//GENERAL PROCS//=======//

/obj/item/clothing/gloves/space_ninja/proc/toggled()
	set name = "Toggle Interaction"
	set desc = "Toggles special interaction on or off."
	set category = "Ninja Equip"

	var/mob/living/carbon/human/U = loc
	U << "You <b>[candrain?"disable":"enable"]</b> special interaction."
	candrain=!candrain

/obj/item/clothing/gloves/space_ninja/examine()
	set src in view()
	..()
	if(!canremove)
		var/mob/living/carbon/human/U = loc
		U << "The energy drain mechanism is: <B>[candrain?"active":"inactive"]</B>."

/*
===================================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<SPACE NINJA MASK>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
===================================================================================
*/

/obj/item/clothing/mask/gas/voice/space_ninja/New()
	verbs += /obj/item/clothing/mask/gas/voice/space_ninja/proc/togglev
	verbs += /obj/item/clothing/mask/gas/voice/space_ninja/proc/switchm

//This proc is linked to human life.dm. It determines what hud icons to display based on mind special role for most mobs.
/obj/item/clothing/mask/gas/voice/space_ninja/proc/assess_targets(list/target_list, mob/living/carbon/U)
	var/icon/tempHud = 'icons/mob/hud.dmi'
	for(var/mob/living/target in target_list)
		if(iscarbon(target))
			switch(target.mind.special_role)
				if("traitor")
					U.client.images += image(tempHud,target,"hudtraitor")
				if("Revolutionary","Head Revolutionary")
					U.client.images += image(tempHud,target,"hudrevolutionary")
				if("Cultist")
					U.client.images += image(tempHud,target,"hudcultist")
				if("Changeling")
					U.client.images += image(tempHud,target,"hudchangeling")
				if("Wizard","Fake Wizard")
					U.client.images += image(tempHud,target,"hudwizard")
				if("Hunter","Sentinel","Drone","Queen")
					U.client.images += image(tempHud,target,"hudalien")
				if("Syndicate")
					U.client.images += image(tempHud,target,"hudoperative")
				if("Death Commando")
					U.client.images += image(tempHud,target,"huddeathsquad")
				if("Space Ninja")
					U.client.images += image(tempHud,target,"hudninja")
				else//If we don't know what role they have but they have one.
					U.client.images += image(tempHud,target,"hudunknown1")
		else if(issilicon(target))//If the silicon mob has no law datum, no inherent laws, or a law zero, add them to the hud.
			var/mob/living/silicon/silicon_target = target
			if(!silicon_target.laws||(silicon_target.laws&&(silicon_target.laws.zeroth||!silicon_target.laws.inherent.len)))
				if(isrobot(silicon_target))//Different icons for robutts and AI.
					U.client.images += image(tempHud,silicon_target,"hudmalborg")
				else
					U.client.images += image(tempHud,silicon_target,"hudmalai")
	return 1

/obj/item/clothing/mask/gas/voice/space_ninja/proc/togglev()
	set name = "Toggle Voice"
	set desc = "Toggles the voice synthesizer on or off."
	set category = "Ninja Equip"

	var/mob/U = loc//Can't toggle voice when you're not wearing the mask.
	var/vchange = (alert("Would you like to synthesize a new name or turn off the voice synthesizer?",,"New Name","Turn Off"))
	if(vchange=="New Name")
		var/chance = rand(1,100)
		switch(chance)
			if(1 to 50)//High chance of a regular name.
				voice = "[rand(0,1)==1?pick(first_names_female):pick(first_names_male)] [pick(last_names)]"
			if(51 to 80)//Smaller chance of a clown name.
				voice = "[pick(clown_names)]"
			if(81 to 90)//Small chance of a wizard name.
				voice = "[pick(wizard_first)] [pick(wizard_second)]"
			if(91 to 100)//Small chance of an existing crew name.
				var/names[] = new()
				for(var/mob/living/carbon/human/M in player_list)
					if(M==U||!M.client||!M.real_name)	continue
					names.Add(M.real_name)
				voice = !names.len ? "Cuban Pete" : pick(names)
		U << "You are now mimicking <B>[voice]</B>."
	else
		U << "The voice synthesizer is [voice!="Unknown"?"now":"already"] deactivated."
		voice = "Unknown"
	return

/obj/item/clothing/mask/gas/voice/space_ninja/proc/switchm()
	set name = "Switch Mode"
	set desc = "Switches between Night Vision, Meson, or Thermal vision modes."
	set category = "Ninja Equip"
	//Have to reset these manually since life.dm is retarded like that. Go figure.
	//This will only work for humans because only they have the appropriate code for the mask.
	var/mob/U = loc
	switch(mode)
		if(0)
			mode=1
			U << "Switching mode to <B>Night Vision</B>."
		if(1)
			mode=2
			U.see_in_dark = 2
			U << "Switching mode to <B>Thermal Scanner</B>."
		if(2)
			mode=3
			U.see_invisible = SEE_INVISIBLE_LIVING
			U.sight &= ~SEE_MOBS
			U << "Switching mode to <B>Meson Scanner</B>."
		if(3)
			mode=0
			U.sight &= ~SEE_TURFS
			U << "Switching mode to <B>Scouter</B>."

/obj/item/clothing/mask/gas/voice/space_ninja/examine()
	set src in view()
	..()

	var/mode
	switch(mode)
		if(0)
			mode = "Scouter"
		if(1)
			mode = "Night Vision"
		if(2)
			mode = "Thermal Scanner"
		if(3)
			mode = "Meson Scanner"
	usr << "<B>[mode]</B> is active."//Leaving usr here since it may be on the floor or on a person.
	usr << "Voice mimicking algorithm is set <B>[!vchange?"inactive":"active"]</B>."