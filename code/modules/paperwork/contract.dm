#define CONTRACT_POWER 1
#define CONTRACT_WEALTH 2
#define CONTRACT_PRESTIGE 3
#define CONTRACT_MAGIC 4
#define CONTRACT_SLAVE 5
#define CONTRACT_UNWILLING 6


/* For employment contracts and demonic contracts */

/obj/item/weapon/paper/contract
	throw_range = 3
	throw_speed = 3
	var/signed = 0

/obj/item/weapon/paper/contract/update_text(var/target)
	name = "paper- generic contract"


/obj/item/weapon/paper/contract/employment



/obj/item/weapon/paper/contract/employment/update_text(var/employee)
	name = "paper- [employee] employment contract"
	info = "<center><B>Official copy of Nanotransen employment agreement</B></center><BR><BR><BR>"

/obj/item/weapon/paper/contract/infernal
	var/contractType = CONTRACT_POWER
	burn_state = -1
	var/burn_timer = 2 //it will be on fire when first created
	/var/mob/user/signer
	/var/mob/user/owner

/obj/item/weapon/paper/contract/infernal/update_icon()
	if(burn_timer > 0)
		icon_state = "paper_onfire"
		burn_timer -= 1
		return
	icon_state = "paper_words"
	return

/obj/item/weapon/paper/contract/infernal/New(var/incType, mob/nOwner)
	..()
	owner = nOwner
	contractType = incType
	update_text()

/obj/item/weapon/paper/contract/infernal/suicide_act(mob/user)
	if(signed)
		user.say("OH GREAT INFERNO!  I DEMAND YOU COLLECT YOUR BOUNTY IMMEDIATELY!")
		user.visible_message("<span class='suicide'>[user] holds up a contract claiming his soul, then immediately catches fire.  Their corpse smelling of brimstone.</span>")
		user.adjust_fire_stacks(20)
		user.IgniteMob()
		return(BURNLOSS)
	else
		..()




/obj/item/weapon/paper/contract/infernal/update_text(var/signerName = "____________")
	switch(contractType)
		if(CONTRACT_POWER)
			name = "paper- Contract for infernal power"
			info = "<center><B>Contract for infernal power</B></center><BR><BR><BR>I, [signerName] of sound mind, do hereby willingly offer my soul to the infernal hells by way of the infernal agent [owner], in exchange for power and physical strength.  I understand that upon my demise, my soul shall fall into the infernal hells, and my body may not be resurrected, cloned, or otherwise brought back to life.  I also understand that this will prevent my brain from being used in an MMI.<BR><BR><BR>Signed, <i>[signerName]</i>"
		if(CONTRACT_WEALTH)
			name = "paper- Contract for unlimited wealth"
			info = "<center><B>Contract for unlimited wealth</B></center><BR><BR><BR>I, [signerName] of sound mind, do hereby willingly offer my soul to the infernal hells by way of the infernal agent [owner], in exchange for a pocket that never runs out of valuable resources.  I understand that upon my demise, my soul shall fall into the infernal hells, and my body may not be resurrected, cloned, or otherwise brought back to life.  I also understand that this will prevent my brain from being used in an MMI.<BR><BR><BR>Signed, <i>[signerName]</i>"
		if(CONTRACT_PRESTIGE)
			name = "paper- Contract for prestige"
			info = "<center><B>Contract for prestige</B></center><BR><BR><BR>I, [signerName] of sound mind, do hereby willingly offer my soul to the infernal hells by way of the infernal agent [owner], in exchange for prestige and esteem among my peers.  I understand that upon my demise, my soul shall fall into the infernal hells, and my body may not be resurrected, cloned, or otherwise brought back to life.  I also understand that this will prevent my brain from being used in an MMI.<BR><BR><BR>Signed, <i>[signerName]</i>"
		if(CONTRACT_MAGIC)
			name = "paper- Contract for magic"
			info = "<center><B>Contract for magic</B></center><BR><BR><BR>I, [signerName] of sound mind, do hereby willingly offer my soul to the infernal hells by way of the infernal agent [owner], in exchange for arcane abilities beyond normal human ability.  I understand that upon my demise, my soul shall fall into the infernal hells, and my body may not be resurrected, cloned, or otherwise brought back to life.  I also understand that this will prevent my brain from being used in an MMI.<BR><BR><BR>Signed, <i>[signerName]</i>"
		if(CONTRACT_SLAVE)
			name = "paper- Contract for slave"
			info = "<center><B>Contract for slave</B></center><BR><BR><BR>I, [signerName] of sound mind, do hereby willingly offer my soul to the infernal hells by way of the infernal agent [owner], in exchange for the ability to bend a single human to my will.  I understand that upon my demise, my soul shall fall into the infernal hells, and my body may not be resurrected, cloned, or otherwise brought back to life.  I also understand that this will prevent my brain from being used in an MMI.<BR><BR><BR>Signed, <i>[signerName]</i>"
		if(CONTRACT_UNWILLING)
			name = "paper- Contract for soul"
			info = "<center><B>Contract for slave</B></center><BR><BR><BR>I, [signerName], hereby offer my soul to the infernal hells by way of the infernal agent [owner].  I understand that upon my demise, my soul shall fall into the infernal hells, and my body may not be resurrected, cloned, or otherwise brought back to life.  I also understand that this will prevent my brain from being used in an MMI.<BR><BR><BR>Signed, <i>[signerName]</i>"


/obj/item/weapon/paper/contract/infernal/attackby(obj/item/weapon/P, mob/living/carbon/human/user, params)
	..()
	if(istype(P, /obj/item/weapon/pen) || istype(P, /obj/item/toy/crayon))
		if(user.IsAdvancedToolUser())
			if(true) // TODO: if(user.HasSoul())
				user << "<span class='notice'>You quickly scrawl your name on the contract</span>"
				FulfillContract(user)
				return
			else
				user << "<span class='notice'>You are not in possession of your soul, you may not sell it.</span>"
				return
		else
			user << "<span class='notice'>You don't know how to read or write.</span>"
			return
	else if(istype(P, /obj/item/weapon/stamp))
		user << "<span class='notice'>You stamp the paper with your rubber stamp, however the ink ignites as you release the stamp.</span>"
		burn_timer += 1
		return
	else if(P.is_hot())
		user.visible_message("<span class='danger'>[user] brings [P] next to [src], but [src] does not catch fire!</span>", "<span class='danger'>The [src] refuses to ignite!</span>")
	add_fingerprint(user)

/obj/item/weapon/paper/contract/infernal/FulfillContract(mob/living/carbon/human/user)
	signed = 1
	burn_timer += 10
	signer = user
	update_text(user)