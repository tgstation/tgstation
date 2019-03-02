/obj/item/melee/rubyfist
	name = "\improper Ruby Gauntlet"
	desc = "A powerful looking gauntlet used for punching things."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "disintegrate"
	item_state = "powerfist"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	w_class = WEIGHT_CLASS_HUGE
	force = 15
	attack_verb = list("punches", "boxes", "mashed")

/datum/action/innate/gem/weapon
	name = "Summon Ruby Gauntlet"
	desc = "Link your mind with the energy of all existing matter, and Channel the collective power of the universe through your Gem."
	icon_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "summons"
	background_icon_state = "bg_spell"
	var/activated = FALSE
	var/weapon_type = /obj/item/melee/rubyfist

/datum/action/innate/gem/weapon/proc/summon()
	if(istype(owner, /mob/living/carbon))
		var/mob/living/carbon/C = owner
		if(C.get_empty_held_indexes())
			activated = TRUE
			if(C.summoneditem == null)
				C.visible_message("<span class='danger'>[C] summons their weapon.</span>")
				C.summoneditem = new weapon_type (get_turf(C), src)
				C.put_in_hands(C.summoneditem)
				if(istype(C.summoneditem, /obj/item))
					var/obj/item/WEP = C.summoneditem
					//boost power of fusions and prime gems.
					if(C.isfusion == TRUE || C.gemstatus == "Prime")
						WEP.force = WEP.force*2
						WEP.throwforce = WEP.throwforce*2
						if(istype(WEP, /obj/item/twohanded))
							var/obj/item/twohanded/TH = WEP
							TH.force_unwielded = TH.force_unwielded*2
							TH.force_wielded = TH.force_wielded*2
					else if(C.gemstatus == "Offcolor") //defective weapons
						WEP.force = rand(WEP.force/2,WEP.force)
						if(istype(WEP, /obj/item/twohanded))
							var/obj/item/twohanded/TH = WEP
							TH.force_unwielded = rand(TH.force_unwielded/2,TH.force_unwielded)
							TH.force_wielded = rand(TH.force_wielded/2,TH.force_wielded)
		else
			to_chat(usr, "<span class='warning'>You need an empty hand to summon your weapon!</span>")
			return

/datum/action/innate/gem/weapon/proc/unsummon()
	activated = FALSE
	if(istype(owner, /mob/living/carbon))
		var/mob/living/carbon/C = owner
		if(C.summoneditem != null)
			QDEL_NULL(C.summoneditem)
			C.regenerate_icons()

/datum/action/innate/gem/weapon/Activate()
	if(!activated)
		summon()
	else
		unsummon()