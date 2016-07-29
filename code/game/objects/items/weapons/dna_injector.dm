<<<<<<< HEAD
/obj/item/weapon/dnainjector
	name = "\improper DNA injector"
	desc = "This injects the person with DNA."
	icon = 'icons/obj/items.dmi'
	icon_state = "dnainjector"
	throw_speed = 3
	throw_range = 5
	w_class = 1
	origin_tech = "biotech=1"

	var/damage_coeff  = 1
	var/list/fields
	var/list/add_mutations = list()
	var/list/remove_mutations = list()

	var/list/add_mutations_static = list()
	var/list/remove_mutations_static = list()

	var/used = 0

/obj/item/weapon/dnainjector/attack_paw(mob/user)
	return attack_hand(user)

/obj/item/weapon/dnainjector/proc/prepare()
	for(var/mut_key in add_mutations_static)
		add_mutations.Add(mutations_list[mut_key])
	for(var/mut_key in remove_mutations_static)
		remove_mutations.Add(mutations_list[mut_key])

/obj/item/weapon/dnainjector/proc/inject(mob/living/carbon/M, mob/user)
	prepare()

	if(M.has_dna() && !(M.disabilities & NOCLONE))
		M.radiation += rand(20/(damage_coeff  ** 2),50/(damage_coeff  ** 2))
		var/log_msg = "[key_name(user)] injected [key_name(M)] with the [name]"
		for(var/datum/mutation/human/HM in remove_mutations)
			HM.force_lose(M)
		for(var/datum/mutation/human/HM in add_mutations)
			if(HM.name == RACEMUT)
				message_admins("[key_name_admin(user)] injected [key_name_admin(M)] with the [name] <span class='danger'>(MONKEY)</span>")
				log_msg += " (MONKEY)"
			HM.force_give(M)
		if(fields)
			if(fields["name"] && fields["UE"] && fields["blood_type"])
				M.real_name = fields["name"]
				M.dna.unique_enzymes = fields["UE"]
				M.name = M.real_name
				M.dna.blood_type = fields["blood_type"]
			if(fields["UI"])	//UI+UE
				M.dna.uni_identity = merge_text(M.dna.uni_identity, fields["UI"])
				M.updateappearance(mutations_overlay_update=1)
		log_attack(log_msg)
	else
		user << "<span class='notice'>It appears that [M] does not have compatible DNA.</span>"
		return

/obj/item/weapon/dnainjector/attack(mob/target, mob/user)
	if(!user.IsAdvancedToolUser())
		user << "<span class='warning'>You don't have the dexterity to do this!</span>"
		return
	if(used)
		user << "<span class='warning'>This injector is used up!</span>"
		return
	if(ishuman(target))
		var/mob/living/carbon/human/humantarget = target
		if (!humantarget.can_inject(user, 1))
			return
	add_logs(user, target, "attempted to inject", src)

	if(target != user)
		target.visible_message("<span class='danger'>[user] is trying to inject [target] with [src]!</span>", "<span class='userdanger'>[user] is trying to inject [target] with [src]!</span>")
		if(!do_mob(user, target) || used)
			return
		target.visible_message("<span class='danger'>[user] injects [target] with the syringe with [src]!", \
						"<span class='userdanger'>[user] injects [target] with the syringe with [src]!")

	else
		user << "<span class='notice'>You inject yourself with [src].</span>"

	add_logs(user, target, "injected", src)

	inject(target, user)	//Now we actually do the heavy lifting.
	used = 1
	icon_state = "dnainjector0"
	desc += " This one is used up."


/obj/item/weapon/dnainjector/antihulk
	name = "\improper DNA injector (Anti-Hulk)"
	desc = "Cures green skin."
	remove_mutations_static = list(HULK)

/obj/item/weapon/dnainjector/hulkmut
	name = "\improper DNA injector (Hulk)"
	desc = "This will make you big and strong, but give you a bad skin condition."
	add_mutations_static = list(HULK)

/obj/item/weapon/dnainjector/xraymut
	name = "\improper DNA injector (Xray)"
	desc = "Finally you can see what the Captain does."
	add_mutations_static = list(XRAY)

/obj/item/weapon/dnainjector/antixray
	name = "\improper DNA injector (Anti-Xray)"
	desc = "It will make you see harder."
	remove_mutations_static = list(XRAY)

/////////////////////////////////////
/obj/item/weapon/dnainjector/antiglasses
	name = "\improper DNA injector (Anti-Glasses)"
	desc = "Toss away those glasses!"
	remove_mutations_static = list(BADSIGHT)

/obj/item/weapon/dnainjector/glassesmut
	name = "\improper DNA injector (Glasses)"
	desc = "Will make you need dorkish glasses."
	add_mutations_static = list(BADSIGHT)

/obj/item/weapon/dnainjector/epimut
	name = "\improper DNA injector (Epi.)"
	desc = "Shake shake shake the room!"
	add_mutations_static = list(EPILEPSY)

/obj/item/weapon/dnainjector/antiepi
	name = "\improper DNA injector (Anti-Epi.)"
	desc = "Will fix you up from shaking the room."
	remove_mutations_static = list(EPILEPSY)
////////////////////////////////////
/obj/item/weapon/dnainjector/anticough
	name = "\improper DNA injector (Anti-Cough)"
	desc = "Will stop that aweful noise."
	remove_mutations_static = list(COUGH)

/obj/item/weapon/dnainjector/coughmut
	name = "\improper DNA injector (Cough)"
	desc = "Will bring forth a sound of horror from your throat."
	add_mutations_static = list(COUGH)

/obj/item/weapon/dnainjector/antidwarf
	name = "\improper DNA injector (Anti-Dwarfism)"
	desc = "Helps you grow big and strong."
	remove_mutations_static = list(DWARFISM)

/obj/item/weapon/dnainjector/dwarf
	name = "\improper DNA injector (Dwarfism)"
	desc = "Its a small world after all."
	add_mutations_static = list(DWARFISM)

/obj/item/weapon/dnainjector/clumsymut
	name = "\improper DNA injector (Clumsy)"
	desc = "Makes clown minions."
	add_mutations_static = list(CLOWNMUT)

/obj/item/weapon/dnainjector/anticlumsy
	name = "\improper DNA injector (Anti-Clumy)"
	desc = "Apply this for Security Clown."
	remove_mutations_static = list(CLOWNMUT)

/obj/item/weapon/dnainjector/antitour
	name = "\improper DNA injector (Anti-Tour.)"
	desc = "Will cure tourrets."
	remove_mutations_static = list(TOURETTES)

/obj/item/weapon/dnainjector/tourmut
	name = "\improper DNA injector (Tour.)"
	desc = "Gives you a nasty case off tourrets."
	add_mutations_static = list(TOURETTES)

/obj/item/weapon/dnainjector/stuttmut
	name = "\improper DNA injector (Stutt.)"
	desc = "Makes you s-s-stuttterrr"
	add_mutations_static = list(NERVOUS)

/obj/item/weapon/dnainjector/antistutt
	name = "\improper DNA injector (Anti-Stutt.)"
	desc = "Fixes that speaking impairment."
	remove_mutations_static = list(NERVOUS)

/obj/item/weapon/dnainjector/antifire
	name = "\improper DNA injector (Anti-Fire)"
	desc = "Cures fire."
	remove_mutations_static = list(COLDRES)

/obj/item/weapon/dnainjector/firemut
	name = "\improper DNA injector (Fire)"
	desc = "Gives you fire."
	add_mutations_static = list(COLDRES)

/obj/item/weapon/dnainjector/blindmut
	name = "\improper DNA injector (Blind)"
	desc = "Makes you not see anything."
	add_mutations_static = list(BLINDMUT)

/obj/item/weapon/dnainjector/antiblind
	name = "\improper DNA injector (Anti-Blind)"
	desc = "ITS A MIRACLE!!!"
	remove_mutations_static = list(BLINDMUT)

/obj/item/weapon/dnainjector/antitele
	name = "\improper DNA injector (Anti-Tele.)"
	desc = "Will make you not able to control your mind."
	remove_mutations_static = list(TK)

/obj/item/weapon/dnainjector/telemut
	name = "\improper DNA injector (Tele.)"
	desc = "Super brain man!"
	add_mutations_static = list(TK)

/obj/item/weapon/dnainjector/telemut/darkbundle
	name = "\improper DNA injector"
	desc = "Good. Let the hate flow through you."

/obj/item/weapon/dnainjector/deafmut
	name = "\improper DNA injector (Deaf)"
	desc = "Sorry, what did you say?"
	add_mutations_static = list(DEAFMUT)

/obj/item/weapon/dnainjector/antideaf
	name = "\improper DNA injector (Anti-Deaf)"
	desc = "Will make you hear once more."
	remove_mutations_static = list(DEAFMUT)

/obj/item/weapon/dnainjector/h2m
	name = "\improper DNA injector (Human > Monkey)"
	desc = "Will make you a flea bag."
	add_mutations_static = list(RACEMUT)

/obj/item/weapon/dnainjector/m2h
	name = "\improper DNA injector (Monkey > Human)"
	desc = "Will make you...less hairy."
	remove_mutations_static = list(RACEMUT)

/obj/item/weapon/dnainjector/antichameleon
	name = "\improper DNA injector (Anti-Chameleon)"
	remove_mutations_static = list(CHAMELEON)

/obj/item/weapon/dnainjector/chameleonmut
	name = "\improper DNA injector (Chameleon)"
	add_mutations_static = list(CHAMELEON)

/obj/item/weapon/dnainjector/antiwacky
	name = "\improper DNA injector (Anti-Wacky)"
	remove_mutations_static = list(WACKY)

/obj/item/weapon/dnainjector/wackymut
	name = "\improper DNA injector (Wacky)"
	add_mutations_static = list(WACKY)

/obj/item/weapon/dnainjector/antimute
	name = "\improper DNA injector (Anti-Mute)"
	remove_mutations_static = list(MUT_MUTE)

/obj/item/weapon/dnainjector/mutemut
	name = "\improper DNA injector (Mute)"
	add_mutations_static = list(MUT_MUTE)

/obj/item/weapon/dnainjector/antismile
	name = "\improper DNA injector (Anti-Smile)"
	remove_mutations_static = list(SMILE)

/obj/item/weapon/dnainjector/smilemut
	name = "\improper DNA injector (Smile)"
	add_mutations_static = list(SMILE)

/obj/item/weapon/dnainjector/unintelligablemut
	name = "\improper DNA injector (Unintelligable)"
	add_mutations_static = list(UNINTELLIGABLE)

/obj/item/weapon/dnainjector/antiunintelligable
	name = "\improper DNA injector (Anti-Unintelligable)"
	remove_mutations_static = list(UNINTELLIGABLE)

/obj/item/weapon/dnainjector/swedishmut
	name = "\improper DNA injector (Swedish)"
	add_mutations_static = list(SWEDISH)

/obj/item/weapon/dnainjector/antiswedish
	name = "\improper DNA injector (Anti-Swedish)"
	remove_mutations_static = list(SWEDISH)

/obj/item/weapon/dnainjector/chavmut
	name = "\improper DNA injector (Chav)"
	add_mutations_static = list(CHAV)

/obj/item/weapon/dnainjector/antichav
	name = "\improper DNA injector (Anti-Chav)"
	remove_mutations_static = list(CHAV)

/obj/item/weapon/dnainjector/elvismut
	name = "\improper DNA injector (Elvis)"
	add_mutations_static = list(ELVIS)

/obj/item/weapon/dnainjector/antielvis
	name = "\improper DNA injector (Anti-Elvis)"
	remove_mutations_static = list(ELVIS)

/obj/item/weapon/dnainjector/lasereyesmut
	name = "\improper DNA injector (Laser Eyes)"
	add_mutations_static = list(LASEREYES)

/obj/item/weapon/dnainjector/antilasereyes
	name = "\improper DNA injector (Anti-Laser Eyes)"
	remove_mutations_static = list(LASEREYES)

/obj/item/weapon/dnainjector/timed
	var/duration = 600

/obj/item/weapon/dnainjector/timed/inject(mob/living/carbon/M, mob/user)
	prepare()

	if(M.has_dna() && !(M.disabilities & NOCLONE))
		if(M.stat == DEAD)	//prevents dead people from having their DNA changed
			user << "<span class='notice'>You can't modify [M]'s DNA while \he's dead.</span>"
			return
		M.radiation += rand(20/(damage_coeff  ** 2),50/(damage_coeff  ** 2))
		var/log_msg = "[key_name(user)] injected [key_name(M)] with the [name]"
		var/endtime = world.time+duration
		for(var/datum/mutation/human/HM in remove_mutations)
			if(HM.name == RACEMUT)
				if(ishuman(M))
					continue
				M = HM.force_lose(M)
			else
				HM.force_lose(M)
		for(var/datum/mutation/human/HM in add_mutations)
			if((HM in M.dna.mutations) && !(M.dna.temporary_mutations[HM.name]))
				continue //Skip permanent mutations we already have.
			if(HM.name == RACEMUT && ishuman(M))
				message_admins("[key_name_admin(user)] injected [key_name_admin(M)] with the [name] <span class='danger'>(MONKEY)</span>")
				log_msg += " (MONKEY)"
				M = HM.force_give(M)
			else
				HM.force_give(M)
			M.dna.temporary_mutations[HM.name] = endtime
		if(fields)
			if(fields["name"] && fields["UE"] && fields["blood_type"])
				if(!M.dna.previous["name"])
					M.dna.previous["name"] = M.real_name
				if(!M.dna.previous["UE"])
					M.dna.previous["UE"] = M.dna.unique_enzymes
				if(!M.dna.previous["blood_type"])
					M.dna.previous["blood_type"] = M.dna.blood_type
				M.real_name = fields["name"]
				M.dna.unique_enzymes = fields["UE"]
				M.name = M.real_name
				M.dna.blood_type = fields["blood_type"]
				M.dna.temporary_mutations[UE_CHANGED] = endtime
			if(fields["UI"])	//UI+UE
				if(!M.dna.previous["UI"])
					M.dna.previous["UI"] = M.dna.uni_identity
				M.dna.uni_identity = merge_text(M.dna.uni_identity, fields["UI"])
				M.updateappearance(mutations_overlay_update=1)
				M.dna.temporary_mutations[UI_CHANGED] = endtime
		log_attack(log_msg)
	else
		user << "<span class='notice'>It appears that [M] does not have compatible DNA.</span>"
		return

/obj/item/weapon/dnainjector/timed/hulk
	name = "\improper DNA injector (Hulk)"
	desc = "This will make you big and strong, but give you a bad skin condition."
	add_mutations_static = list(HULK)

/obj/item/weapon/dnainjector/timed/h2m
	name = "\improper DNA injector (Human > Monkey)"
	desc = "Will make you a flea bag."
	add_mutations_static = list(RACEMUT)
=======
/obj/item/weapon/dnainjector
	name = "DNA-Injector"
	desc = "This injects the person with DNA."
	icon = 'icons/obj/items.dmi'
	icon_state = "dnainjector"
	var/block=0
	var/datum/dna2/record/buf=null
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_TINY
	var/uses = 1
	var/nofail = 0
	var/is_bullet = 0
	var/inuse = 0

	// USE ONLY IN PREMADE SYRINGES.  WILL NOT WORK OTHERWISE.
	var/datatype=0
	var/value=0

/obj/item/weapon/dnainjector/New()
	. = ..()

	if(ticker)
		initialize()

/obj/item/weapon/dnainjector/initialize()
	if(datatype && block)
		buf=new
		buf.dna=new
		buf.types = datatype
		buf.dna.ResetSE()
		//testing("[name]: DNA2 SE blocks prior to SetValue: [english_list(buf.dna.SE)]")
		SetValue(src.value)
		//testing("[name]: DNA2 SE blocks after SetValue: [english_list(buf.dna.SE)]")

/obj/item/weapon/dnainjector/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/item/weapon/dnainjector/proc/GetRealBlock(var/selblock)
	if(selblock==0)
		return block
	else
		return selblock

/obj/item/weapon/dnainjector/proc/GetState(var/selblock=0)
	var/real_block=GetRealBlock(selblock)
	if(buf.types&DNA2_BUF_SE)
		return buf.dna.GetSEState(real_block)
	else
		return buf.dna.GetUIState(real_block)

/obj/item/weapon/dnainjector/proc/SetState(var/on, var/selblock=0)
	var/real_block=GetRealBlock(selblock)
	if(buf.types&DNA2_BUF_SE)
		return buf.dna.SetSEState(real_block,on)
	else
		return buf.dna.SetUIState(real_block,on)

/obj/item/weapon/dnainjector/proc/GetValue(var/selblock=0)
	var/real_block=GetRealBlock(selblock)
	if(buf.types&DNA2_BUF_SE)
		return buf.dna.GetSEValue(real_block)
	else
		return buf.dna.GetUIValue(real_block)

/obj/item/weapon/dnainjector/proc/SetValue(var/val,var/selblock=0)
	var/real_block=GetRealBlock(selblock)
	if(buf.types&DNA2_BUF_SE)
		return buf.dna.SetSEValue(real_block,val)
	else
		return buf.dna.SetUIValue(real_block,val)

/obj/item/weapon/dnainjector/proc/inject(mob/M as mob, mob/user as mob)
	if(istype(M,/mob/living/carbon/human/manifested))
		to_chat(M, "<span class='warning'> Apparently it didn't work.</span>")
		if(M != user)
			to_chat(user, "<span class='warning'> Apparently it didn't work.</span>")
	else
		if(istype(M,/mob/living))
			M.radiation += rand(5,20)

		if(!(M_NOCLONE in M.mutations)) // prevents drained people from having their DNA changed
			// UI in syringe.
			if(buf.types & DNA2_BUF_UI)
				if(!block) //isolated block?
					M.UpdateAppearance(buf.dna.UI.Copy())
					if (buf.types & DNA2_BUF_UE) //unique enzymes? yes
						M.real_name = buf.dna.real_name
						M.name = buf.dna.real_name
					uses--
				else
					M.dna.SetUIValue(block,src.GetValue())
					M.UpdateAppearance()
					uses--
			if(buf.types & DNA2_BUF_SE)
				if(!block) //isolated block?
					M.dna.SE = buf.dna.SE.Copy()
					M.dna.UpdateSE()
				else
					M.dna.SetSEValue(block,src.GetValue())
				domutcheck(M, null, nofail)
				uses--
				//if(prob(5))
					//trigger_side_effect(M)

		if(buf.types & DNA2_BUF_SE)
			if(block)// Isolated injector
				if (GetState() && block == MONKEYBLOCK && istype(M, /mob/living/carbon/human))
					message_admins("[key_name_admin(user)] injected [key_name_admin(M)] with the Isolated [name] <span class='warning'>(MONKEY)</span>")
					log_attack("[key_name_admin(user)] injected [key_name_admin(M)] with the Isolated [name] (MONKEY)")
					log_game("[key_name_admin(user)] injected [key_name_admin(M)] with the Isolated [name] <span class='warning'>(MONKEY)</span>")
				else
					log_attack("[key_name_admin(user)] injected [key_name_admin(M)] with the Isolated [name]")
					log_game("[key_name_admin(user)] injected [key_name_admin(M)] with the Isolated [name]")
			else
				if (GetState(MONKEYBLOCK) && istype(M, /mob/living/carbon/human))
					message_admins("[key_name_admin(user)] injected [key_name_admin(M)] with the [name] <span class='warning'>(MONKEY)</span>")
					log_attack("[key_name_admin(user)] injected [key_name_admin(M)] with the [name] (MONKEY)")
					log_game("[key_name_admin(user)] injected [key_name_admin(M)] with the [name] (MONKEY)")
				else
					log_attack("[key_name_admin(user)] injected [key_name_admin(M)] with the [name]")
					log_game("[key_name_admin(user)] injected [key_name_admin(M)] with the [name]")

	spawn(0)//this prevents the collapse of space-time continuum
		if(user)
			user.drop_from_inventory(src)
		if(!uses)
			qdel(src)
	return uses

/obj/item/weapon/dnainjector/attack(mob/M as mob, mob/user as mob)
	if (!istype(M, /mob))
		return
	if (!user.dexterity_check())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return

	M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been injected with [name] by [user.name] ([user.ckey])</font>")
	user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [name] to inject [M.name] ([M.ckey])</font>")
	log_attack("[user.name] ([user.ckey]) used the [name] to inject [M.name] ([M.ckey])")

	if(!iscarbon(user))
		M.LAssailant = null
	else
		M.LAssailant = user

	if(inuse)
		return 0

	user.visible_message("<span class='danger'>\The [user] is trying to inject \the [M] with \the [src]!</span>")

	inuse = 1
	if(!do_after(user, M, 5 SECONDS))
		inuse = 0 //If you've got a better idea on how to not repeat this twice I'd like to hear it
		return
	inuse = 0

	M.visible_message("<span class='danger'>\The [M] has been injected with \the [src] by \the [user].</span>")
	if (!istype(M, /mob/living/carbon/human) && !istype(M, /mob/living/carbon/monkey))
		to_chat(user, "<span class='warning'>Apparently, the DNA injector didn't work...</span>")
		return

	inject(M, user)

/obj/item/weapon/dnainjector/nofail
	nofail = MUTCHK_FORCED

/obj/item/weapon/dnainjector/nofail/hulkmut
	name = "DNA-Injector (Hulk)"
	desc = "This will make you big and strong, but give you a bad skin condition."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 2
	New()
		block = HULKBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/antihulk
	name = "DNA-Injector (Anti-Hulk)"
	desc = "Cures green skin."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 2
	New()
		block = HULKBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/xraymut
	name = "DNA-Injector (Xray)"
	desc = "Finally you can see what the Captain does."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 8
	New()
		block = XRAYBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/antixray
	name = "DNA-Injector (Anti-Xray)"
	desc = "It will make you see harder."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 8
	New()
		block = XRAYBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/firemut
	name = "DNA-Injector (Fire)"
	desc = "Gives you fire."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 10
	New()
		block = FIREBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/antifire
	name = "DNA-Injector (Anti-Fire)"
	desc = "Cures fire."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 10
	New()
		block = FIREBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/telemut
	name = "DNA-Injector (Tele.)"
	desc = "Super brain man!"
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 12
	New()
		block = TELEBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/antitele
	name = "DNA-Injector (Anti-Tele.)"
	desc = "Will make you not able to control your mind."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 12
	New()
		block = TELEBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/nobreath
	name = "DNA-Injector (No Breath)"
	desc = "Hold your breath and count to infinity."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 2
	New()
		block = NOBREATHBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/antinobreath
	name = "DNA-Injector (Anti-No Breath)"
	desc = "Hold your breath and count to 100."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 2
	New()
		block = NOBREATHBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/remoteview
	name = "DNA-Injector (Remote View)"
	desc = "Stare into the distance for a reason."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 2
	New()
		block = REMOTEVIEWBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/antiremoteview
	name = "DNA-Injector (Anti-Remote View)"
	desc = "Cures green skin."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 2
	New()
		block = REMOTEVIEWBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/regenerate
	name = "DNA-Injector (Regeneration)"
	desc = "Healthy but hungry."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 2
	New()
		block = REGENERATEBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/antiregenerate
	name = "DNA-Injector (Anti-Regeneration)"
	desc = "Sickly but sated."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 2
	New()
		block = REGENERATEBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/runfast
	name = "DNA-Injector (Increase Run)"
	desc = "Running Man."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 2
	New()
		block = INCREASERUNBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/antirunfast
	name = "DNA-Injector (Anti-Increase Run)"
	desc = "Walking Man."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 2
	New()
		block = INCREASERUNBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/morph
	name = "DNA-Injector (Morph)"
	desc = "A total makeover."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 2
	New()
		block = MORPHBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/antimorph
	name = "DNA-Injector (Anti-Morph)"
	desc = "Cures identity crisis."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 2
	New()
		block = MORPHBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/cold
	name = "DNA-Injector (Cold)"
	desc = "Feels a bit chilly."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 2
	New()
		block = COLDBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/anticold
	name = "DNA-Injector (Anti-Cold)"
	desc = "Feels room-temperature."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 2
	New()
		block = COLDBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/noprints
	name = "DNA-Injector (No Prints)"
	desc = "Better than a pair of budget insulated gloves."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 2
	New()
		block = NOPRINTSBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/antinoprints
	name = "DNA-Injector (Anti-No Prints)"
	desc = "Not quite as good as a pair of budget insulated gloves."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 2
	New()
		block = NOPRINTSBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/insulation
	name = "DNA-Injector (Shock Immunity)"
	desc = "Better than a pair of real insulated gloves."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 2
	New()
		block = SHOCKIMMUNITYBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/antiinsulation
	name = "DNA-Injector (Anti-Shock Immunity)"
	desc = "Not quite as good as a pair of real insulated gloves."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 2
	New()
		block = SHOCKIMMUNITYBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/midgit
	name = "DNA-Injector (Small Size)"
	desc = "Makes you shrink."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 2
	New()
		block = SMALLSIZEBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/antimidgit
	name = "DNA-Injector (Anti-Small Size)"
	desc = "Makes you grow. But not too much."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 2
	New()
		block = SMALLSIZEBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/sober
	name = "DNA-Injector (Sober)"
	desc = "Makes you not fun."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 2
	New()
		block = SOBERBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/antisober
	name = "DNA-Injector (Anti-Sober)"
	desc = "Makes you fun as hell."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 2
	New()
		block = SOBERBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/psychic_resist
	name = "DNA-Injector (Psychic Resist)"
	desc = "Not today, mind hippies."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 2
	New()
		block = PSYRESISTBLOCK
		..()


/obj/item/weapon/dnainjector/nofail/antipsychic_resist
	name = "DNA-Injector (Anti-Psychic Resist)"
	desc = "Im thinking about furry porn 24/7. Come at me, faggots."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 2
	New()
		block = PSYRESISTBLOCK
		..()

/*/obj/item/weapon/dnainjector/nofail/darkcloak
	name = "DNA-Injector (Dark Cloak)"
	desc = "BLEH BLEH, I AM HERE TO SUCK YOUR BLOOD!"
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 2
	New()
		block = SHADOWBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/antidarkcloak
	name = "DNA-Injector (Anti-Dark Cloak)"
	desc = "THE LIGHT, IT BUUURNS!"
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 2
	New()
		block = SHADOWBLOCK
		..()
*/
/obj/item/weapon/dnainjector/nofail/chameleon
	name = "DNA-Injector (Chameleon)"
	desc = "You cant see me."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 2
	New()
		block = CHAMELEONBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/antichameleon
	name = "DNA-Injector (Anti-Chameleon)"
	desc = "OH GOD EVERYONE CAN SEE ME!"
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 2
	New()
		block = CHAMELEONBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/cryo
	name = "DNA-Injector (Cryokinesis)"
	desc = "Its about to get chilly."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 2
	New()
		block = CRYOBLOCK
		..()


/obj/item/weapon/dnainjector/nofail/anticryo
	name = "DNA-Injector (Anti-Cryokinesis)"
	desc = "Fuck, its hot in here!"
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 2
	New()
		block = CRYOBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/mattereater
	name = "DNA-Injector (Matter Eater)"
	desc = "OM NOM NOM."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 2
	New()
		block = EATBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/antimattereater
	name = "DNA-Injector (Anti-Matter Eater)"
	desc = "Oh god I'm gonna puke."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 2
	New()
		block = EATBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/jumpy
	name = "DNA-Injector (Jumpy)"
	desc = "WEEEEEEEEEEEE!"
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 2
	New()
		block = JUMPBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/antijumpy
	name = "DNA-Injector (Anti-Jumpy)"
	desc = "Awwe.."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 2
	New()
		block = JUMPBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/polymorph
	name = "DNA-Injector (Polymorph)"
	desc = "A clone of myself? Now neither of us will be virgins!"
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 2
	New()
		block = POLYMORPHBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/antipolymorph
	name = "DNA-Injector (Anti-Polymorph)"
	desc = "Damn, friendzoned by my own clone."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 2
	New()
		block = POLYMORPHBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/empath
	name = "DNA-Injector (Empathic Thought)"
	desc = "What will I have for dinner?"
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 2
	New()
		block = EMPATHBLOCK
		..()


/obj/item/weapon/dnainjector/nofail/antiempath
	name = "DNA-Injector (Anti-Empathic Thought)"
	desc = "Damn tin foil hats."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 2
	New()
		block = EMPATHBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/superfart
	name = "DNA-Injector (Super Fart)"
	desc = "Really?"
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 2
	New()
		block = SUPERFARTBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/antisuperfart
	name = "DNA-Injector (Anti-Super Fart)"
	desc = "No, really!?"
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 2
	New()
		block = SUPERFARTBLOCK
		..()

/////////////////////////////////////
/obj/item/weapon/dnainjector/nofail/antiglasses
	name = "DNA-Injector (Anti-Glasses)"
	desc = "Toss away those glasses!"
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 1
	New()
		block = GLASSESBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/glassesmut
	name = "DNA-Injector (Glasses)"
	desc = "Will make you need dorkish glasses."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 1
	New()
		block = GLASSESBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/epimut
	name = "DNA-Injector (Epi.)"
	desc = "Shake shake shake the room!"
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 3
	New()
		block = HEADACHEBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/antiepi
	name = "DNA-Injector (Anti-Epi.)"
	desc = "Will fix you up from shaking the room."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 3
	New()
		block = HEADACHEBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/anticough
	name = "DNA-Injector (Anti-Cough)"
	desc = "Will stop that awful noise."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 5
	New()
		block = COUGHBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/coughmut
	name = "DNA-Injector (Cough)"
	desc = "Will bring forth a sound of horror from your throat."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 5
	New()
		block = COUGHBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/clumsymut
	name = "DNA-Injector (Clumsy)"
	desc = "Makes clumsy minions."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 6
	New()
		block = CLUMSYBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/anticlumsy
	name = "DNA-Injector (Anti-Clumy)"
	desc = "Cleans up confusion."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 6
	New()
		block = CLUMSYBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/antitour
	name = "DNA-Injector (Anti-Tour.)"
	desc = "Will cure tourrets."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 7
	New()
		block = TWITCHBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/tourmut
	name = "DNA-Injector (Tour.)"
	desc = "Gives you a nasty case off tourrets."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 7
	New()
		block = TWITCHBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/stuttmut
	name = "DNA-Injector (Stutt.)"
	desc = "Makes you s-s-stuttterrr"
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 9
	New()
		block = NERVOUSBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/antistutt
	name = "DNA-Injector (Anti-Stutt.)"
	desc = "Fixes that speaking impairment."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 9
	New()
		block = NERVOUSBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/blindmut
	name = "DNA-Injector (Blind)"
	desc = "Makes you not see anything."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 11
	New()
		block = BLINDBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/antiblind
	name = "DNA-Injector (Anti-Blind)"
	desc = "ITS A MIRACLE!!!"
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 11
	New()
		block = BLINDBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/deafmut
	name = "DNA-Injector (Deaf)"
	desc = "Sorry, what did you say?"
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 13
	New()
		block = DEAFBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/antideaf
	name = "DNA-Injector (Anti-Deaf)"
	desc = "Will make you hear once more."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 13
	New()
		block = DEAFBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/hallucination
	name = "DNA-Injector (Halluctination)"
	desc = "What you see isn't always what you get."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 2
	New()
		block = HALLUCINATIONBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/antihallucination
	name = "DNA-Injector (Anti-Hallucination)"
	desc = "What you see is what you get."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 2
	New()
		block = HALLUCINATIONBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/h2m
	name = "DNA-Injector (Human > Monkey)"
	desc = "Will make you a flea bag."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 14
	New()
		block = MONKEYBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/m2h
	name = "DNA-Injector (Monkey > Human)"
	desc = "Will make you...less hairy."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 14
	New()
		block = MONKEYBLOCK
		..()


/obj/item/weapon/dnainjector/nofail/mute
	name = "DNA-Injector (Mute)"
	desc = "Hell."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 14
	New()
		block = MUTEBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/antimute
	name = "DNA-Injector (Anti-Mute)"
	desc = "Shut up."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 14
	New()
		block = MUTEBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/radioactive
	name = "DNA-Injector (Radioactive)"
	desc = "Welcome to the new age."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 14
	New()
		block = RADBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/antiradioactive
	name = "DNA-Injector (Anti-Radioactive)"
	desc = "All systems go."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 14
	New()
		block = RADBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/fat
	name = "DNA-Injector (Fat)"
	desc = "Gives you big bones."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 14
	New()
		block = FATBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/antifat
	name = "DNA-Injector (Anti-Fat)"
	desc = "Feeds you subway."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 14
	New()
		block = FATBLOCK
		..()


/obj/item/weapon/dnainjector/nofail/chav
	name = "DNA-Injector (Chav)"
	desc = "Makes you a real arsehole."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 14
	New()
		block = CHAVBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/antichav
	name = "DNA-Injector (Anti-Chav)"
	desc = "Put it back, I liked you better that way."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 14
	New()
		block = CHAVBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/sweedish
	name = "DNA-Injector (Sweedish)"
	desc = "BORK! BORK! BORK!"
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 14
	New()
		block = SWEDEBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/antisweedish
	name = "DNA-Injector (Anti-Sweedish)"
	desc = "You're no fun."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 14
	New()
		block = SWEDEBLOCK
		..()


/obj/item/weapon/dnainjector/nofail/unintelligable
	name = "DNA-Injector (Unintelligable)"
	desc = "At?wh"
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 14
	New()
		block = SCRAMBLEBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/antiunintelligable
	name = "DNA-Injector (Anti-Unintelligable)"
	desc = "What?"
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 14
	New()
		block = SCRAMBLEBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/strong
	name = "DNA-Injector (Strong)"
	desc = "HEY BRO, WANNA HIT THE GYM?"
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 14
	New()
		block = STRONGBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/antistrong
	name = "DNA-Injector (Anti-Strong)"
	desc = "Spot me!"
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 14
	New()
		block = STRONGBLOCK
		..()


/obj/item/weapon/dnainjector/nofail/horns
	name = "DNA-Injector (Horns)"
	desc = "Feelin' horny?"
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 14
	New()
		block = HORNSBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/antihorns
	name = "DNA-Injector (Anti-Horns)"
	desc = "Right, lets just watch Law & Order."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 14
	New()
		block = HORNSBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/immolate
	name = "DNA-Injector (Immolate)"
	desc = "We didn't start the fire."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 14
	New()
		block = IMMOLATEBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/antiimmolate
	name = "DNA-Injector (Anti-Immolate)"
	desc = "It was always burnin' since the world was turnin'"
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 14
	New()
		block = IMMOLATEBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/melt
	name = "DNA-Injector (Dissolve)"
	desc = "Win the game."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 14
	New()
		block = MELTBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/antimelt
	name = "DNA-Injector (Dissolve)"
	desc = "You just lost the game."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 14
	New()
		block = MELTBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/smile
	name = "DNA-Injector (Smile)"
	desc = ":)"
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 14
	New()
		block = SMILEBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/antismile
	name = "DNA-Injector (Anti-Smile)"
	desc = ":("
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 14
	New()
		block = SMILEBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/elvis
	name = "DNA-Injector (Elvis)"
	desc = "Tell the folks back home this is the promised land calling"
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 14
	New()
		block = ELVISBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/antielvis
	name = "DNA-Injector (Anti-Elvis)"
	desc = "And the poor boy is on the line."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 14
	New()
		block = ELVISBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/loud
	name = "DNA-Injector (Loud)"
	desc = "CAPS LOCK IS CRUISE CONRTOL FOR COOL!"
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 14
	New()
		block = LOUDBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/antiloud
	name = "DNA-Injector (Anti-Loud)"
	desc = "EVEN WITH CRUISE CONTROL, YOU STILL HAVE TO STEER!"
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 14
	New()
		block = LOUDBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/whisper
	name = "DNA-Injector (Quiet)"
	desc = "Shhh..."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 14
	New()
		block = WHISPERBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/antiwhisper
	name = "DNA-Injector (Anti-Quiet)"
	desc = "WOOOO HOOOO!"
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 14
	New()
		block = WHISPERBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/dizzy
	name = "DNA-Injector (Dizzy)"
	desc = "Touch fuzzy,"
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 14
	New()
		block = DIZZYBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/antidizzy
	name = "DNA-Injector (Anti-Dizzy)"
	desc = "Get dizzy."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 14
	New()
		block = DIZZYBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/sans
	name = "DNA-Injector (Wacky)"
	desc = "<span class='sans'>#wow #woah</span>"
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 14
	New()
		block = SANSBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/antisans
	name = "DNA-Injector (Anti-Wacky)"
	desc = "Worst font."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 14
	New()
		block = SANSBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/farsightmut
	name = "DNA-Injector (Farsight)"
	desc = "This will allow you to focus your eyes better."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 2
	New()
		block = FARSIGHTBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/antifarsight
	name = "DNA-Injector (Anti-Farsight)"
	desc = "No fun allowed"
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 2
	New()
		block = FARSIGHTBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/remotesay
	name = "DNA-Injector (Remote Say)"
	desc = "Share it with the world."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	New()
		block = REMOTETALKBLOCK
		..()

/obj/item/weapon/dnainjector/nofail/antiremotesay
	name = "DNA-Injector (Remote Say)"
	desc = "Keep it to yourself."
	datatype = DNA2_BUF_SE
	value = 0x001
	New()
		block = REMOTETALKBLOCK
		..()
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
