#define VEST_STEALTH 1
#define VEST_COMBAT 2
#define GIZMO_SCAN 1
#define GIZMO_MARK 2

//AGENT VEST
/obj/item/clothing/suit/armor/abductor/vest
	name = "Agent Vest"
	desc = "Vest outfitted with alien stealth technology."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "vest_stealth"
	item_state = "armor"
	blood_overlay_type = "armor"
	armor = list(melee = 15, bullet = 15, laser = 15, energy = 15, bomb = 15, bio = 15, rad = 15)
	action_button_name = "Activate"
	action_button_is_hands_free = 1
	var/mode = VEST_STEALTH
	var/stealth_active = 0
	var/combat_cooldown = 10
	var/datum/icon_snapshot/disguise
	var/stealth_armor = list(melee = 15, bullet = 15, laser = 15, energy = 15, bomb = 15, bio = 15, rad = 15)
	var/combat_armor = list(melee = 50, bullet = 50, laser = 50, energy = 50, bomb = 50, bio = 50, rad = 50)

/obj/item/clothing/suit/armor/abductor/vest/proc/flip_mode()
	switch(mode)
		if(VEST_STEALTH)
			mode = VEST_COMBAT
			DeactivateStealth()
			armor = combat_armor
			icon_state = "vest_combat"
			return
		if(VEST_COMBAT)// TO STEALTH
			mode = VEST_STEALTH
			armor = stealth_armor
			icon_state = "vest_stealth"
			return

/obj/item/clothing/suit/armor/abductor/vest/proc/SetDisguise(var/datum/icon_snapshot/entry)
	disguise = entry

/obj/item/clothing/suit/armor/abductor/vest/proc/ActivateStealth()
	if(disguise == null)
		return
	stealth_active = 1
	if(istype(src.loc, /mob/living/carbon/human))
		var/mob/living/carbon/human/M = src.loc
		spawn(0)
			anim(M.loc,M,'icons/mob/mob.dmi',,"cloak",,M.dir)

		M.name_override = disguise.name
		M.icon = disguise.icon
		M.icon_state = disguise.icon_state
		M.overlays = disguise.overlays
		M.update_inv_r_hand()
		M.update_inv_l_hand()
	return

/obj/item/clothing/suit/armor/abductor/vest/proc/DeactivateStealth()
	if(!stealth_active)
		return
	stealth_active = 0
	if(istype(src.loc, /mob/living/carbon/human))
		var/mob/living/carbon/human/M = src.loc
		spawn(0)
			anim(M.loc,M,'icons/mob/mob.dmi',,"uncloak",,M.dir)
		M.name_override = null
		M.overlays.Cut()
		M.regenerate_icons()
	return

/obj/item/clothing/suit/armor/abductor/vest/IsShield()
	DeactivateStealth()
	return 0
/obj/item/clothing/suit/armor/abductor/vest/IsReflect()
	DeactivateStealth()
	return 0

/obj/item/clothing/suit/armor/abductor/vest/ui_action_click()
	switch(mode)
		if(VEST_COMBAT)
			Adrenaline()
		if(VEST_STEALTH)
			if(stealth_active)
				DeactivateStealth()
			else
				ActivateStealth()

/obj/item/clothing/suit/armor/abductor/vest/proc/Adrenaline()
	if(istype(src.loc, /mob/living/carbon/human))
		if(combat_cooldown != initial(combat_cooldown))
			src.loc << "<span class='warning'>Combat injection is still recharging.</span>"
		var/mob/living/carbon/human/M = src.loc
		M.stat = 0
		M.SetParalysis(0)
		M.SetStunned(0)
		M.SetWeakened(0)
		M.lying = 0
		M.update_canmove()
		M.adjustStaminaLoss(-75)
		combat_cooldown = 0
		SSobj.processing |= src

/obj/item/clothing/suit/armor/abductor/vest/process()
	combat_cooldown++
	if(combat_cooldown==initial(combat_cooldown))
		SSobj.processing.Remove(src)

/obj/item/device/abductor/proc/AbductorCheck(var/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.dna.species.id != "abductor")
			user << "<span class='notice'>You can't figure how this works.</span>"
			return 0
		return 1
	return 0

/obj/item/device/abductor/proc/ScientistCheck(var/user)
	var/mob/living/carbon/human/H = user
	var/datum/species/abductor/S = H.dna.species
	return S.scientist

/obj/item/device/abductor/gizmo
	name = "Science Tool"
	desc = "Alien science is 90% dissections 10% probings."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "gizmo_scan"
	item_state = "pen"
	var/mode = GIZMO_SCAN
	var/mob/living/marked
	var/prepared = 0
	var/obj/machinery/abductor/console/console

/obj/item/device/abductor/gizmo/attack_self(mob/user)
	if(!AbductorCheck(user))
		return
	if(!ScientistCheck(user))
		user << "<span class='notice'>You're not trained to use this</span>"
		return
	if(mode == GIZMO_SCAN)
		mode = GIZMO_MARK
		icon_state = "gizmo_mark"
	else
		mode = GIZMO_SCAN
		icon_state = "gizmo_scan"
	user << "<span class='notice'>You switch the device to [mode==GIZMO_SCAN? "SCAN": "MARK"] MODE</span>"

/obj/item/device/abductor/gizmo/attack(mob/living/M, mob/user)
	if(!AbductorCheck(user))
		return
	if(!ScientistCheck(user))
		user << "<span class='notice'>You're not trained to use this</span>"
		return
	switch(mode)
		if(GIZMO_SCAN)
			scan(M, user)
		if(GIZMO_MARK)
			if(marked == M && !prepared)
				prepare(M,user)
			mark(M, user)


/obj/item/device/abductor/gizmo/afterattack(var/atom/target, var/mob/living/user, flag, params)
	if(flag)
		return
	if(!AbductorCheck(user))
		return
	if(!ScientistCheck(user))
		user << "<span class='notice'>You're not trained to use this</span>"
		return
	switch(mode)
		if(GIZMO_SCAN)
			scan(target, user)
		if(GIZMO_MARK)
			mark(target, user)

/obj/item/device/abductor/gizmo/proc/scan(var/atom/target, var/mob/living/user)
	if(istype(target,/mob/living/carbon/human))
		if(console!=null)
			console.AddSnapshot(target)
			user << "<span class='notice'>You scan and add the being to the database</span>"

/obj/item/device/abductor/gizmo/proc/mark(var/atom/target, var/mob/living/user)
	if(marked != target)
		prepared = 0
	else
		user << "<span class='notice'>This specimen is already marked.</span>"
	if(istype(target,/mob/living/carbon/human))
		marked = target
		user << "<span class='notice'>You mark the target for future retrieval.</span>"

/obj/item/device/abductor/gizmo/proc/prepare(var/atom/target, var/mob/living/user)
	user << "<span class='notice'>You start preparing the specimen for transport </span>"
	if(do_after(user, 100))
		prepared = 1
		user << "<span class='notice'>You finish preparing the specimen for transport </span>"


/obj/item/device/abductor/silencer
	name = "Abductor Silencer"
	desc = "Device used to break communication equipment"
	icon = 'icons/obj/abductor.dmi'
	icon_state = "silencer"
	item_state = "pen"

/obj/item/device/abductor/silencer/attack(mob/living/M, mob/user)
	if(!AbductorCheck(user))
		return
	radio_off(M, user)

/obj/item/device/abductor/silencer/afterattack(var/atom/target, var/mob/living/user, flag, params)
	if(flag)
		return
	if(!AbductorCheck(user))
		return
	radio_off(target, user)

/obj/item/device/abductor/silencer/proc/radio_off(var/atom/target, var/mob/living/user)
	if( !(user in (viewers(7,target))) )
		return

	var/turf/targloc = get_turf(target)

	var/mob/living/carbon/human/M
	for(M in view(2,targloc))
		user << "<span class='notice'>You silence [M.name] radio devices.</span>"
		radio_off_mob(M)

/obj/item/device/abductor/silencer/proc/radio_off_mob(var/mob/living/carbon/human/M)
	var/list/all_items = M.GetAllContents()

	for(var/obj/I in all_items)
		if(istype(I,/obj/item/device/radio/))
			var/obj/item/device/radio/r = I
			r.listening = 0
			if(!istype(I,/obj/item/device/radio/headset))
				r.broadcasting = 0 //goddamned headset hacks


/obj/item/weapon/implant/abductor
	name = "Emergency Beam"
	desc = "Gets you back on the ship."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "implant"
	activated = 1
	var/obj/machinery/abductor/pad/home
	var/cooldown = 30

/obj/item/weapon/implant/abductor/activate()
	if(cooldown == initial(cooldown))
		home.Retrieve(imp_in,1)
		cooldown = 0
		SSobj.processing |= src
	else
		imp_in << "<span class='warning'>The emergency beam is still recharging!</span>"
	return

/obj/item/weapon/implant/abductor/process()
	if(cooldown < initial(cooldown))
		cooldown++
		if(cooldown == initial(cooldown))
			SSobj.processing.Remove(src)


/obj/item/device/firing_pin/alien
	name = "alien-looking pin"
	desc = "Only non-humans can use this pin"
	fail_message = "<span class='alienwarning'>Human DNA detected! Authorization revoked!</span>"

/obj/item/device/firing_pin/alien/pin_auth(mob/living/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.dna.species.id == "human") //stealth lizard buff go
			return 0
	return 1

/obj/item/weapon/gun/energy/decloner/alien
	ammo_type = list(/obj/item/ammo_casing/energy/declone)
	pin = /obj/item/device/firing_pin/alien

/obj/item/weapon/paper/abductor
	name = "Dissection Guide"
	info = {""<b>Dissection for Dummies</b><br>
<br>
1.Acquire fresh specimen.<br>
2.Put the specimen on operating table<br>
3.Apply surgical drapes preparing for dissection<br>
4.Apply scalpel to specimen torso<br>
5.Stop the bleeders and retract skin<br>
6.Cut out organs you find with a scalpel<br>
7.Use your hands to remove the remaining organs<br>
8.Insert replacement gland (Retrieve one from gland storage)<br>
9.Put the specimen in the experiment machinery<br>
8.Choose one of the machine options and follow displayed instructions<br>
<br>
Congratulations! You are now trained for xenobiology research!""}