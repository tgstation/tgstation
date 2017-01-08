//The pass is created with, predictably, Pass. It has a myriad of uses, such as:
// - Pulling yourself to a nearby turf
// - Knocking people down and muting them
// - Prying open depowered airlocks
//It does not do any damage.
/obj/item/weapon/umbrage_pass
	name = "shadowy tendrils"
	desc = "A cluster of black tendrils emitting plumes of smoke."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "umbrage_pass"
	item_state = "umbrage_pass"
	flags = NODROP | CONDUCT
	resistance_flags = FIRE_PROOF | LAVA_PROOF | ACID_PROOF
	w_class = 5
	var/mob/living/carbon/human/linked_user



//The dark bead is created with Devour Will. By attacking someone, their thoughts are siphoned, increasing max psi, regenerating non-renewable psi, and leaving them open to veiling.
/obj/item/weapon/umbrage_dark_bead
	name = "dark bead"
	desc = "A glowing black bead of energy. It's dissipating fast."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "umbrage_dark_bead"
	item_state = "ratvars_flame"
	flags = NODROP
	w_class = 5
	var/eating = 0 //yum yum tasty souls

/obj/item/weapon/umbrage_dark_bead/New()
	..()
	spawn(10) //This is necessary because reasons
		if(!eating)
			qdel(src)

/obj/item/weapon/umbrage_dark_bead/attack(mob/living/carbon/human/victim, mob/living/carbon/human/user)
	if(eating)
		return
	eating = 1
	user.visible_message("<span class='warning'>[user] holds [victim] backwards and leans in close...</span>", "<span class='velvet_bold'>...bkn...</span>")
	victim.Stun(10)
	playsound(user, 'sound/magic/devour_will.ogg', 100, 0)
	if(!do_mob(user, victim, 30))
		user.Weaken(4)
		victim.Weaken(4)
		qdel(src)
		return
	user << "<span class='velvet_bold'>...<i>arn.</i></span>"
	victim.visible_message("<b>[victim]</b> seizes up and falls limp, \his eyes empty and dead...", \
	"<span class='userdanger'>Something has been taken from you. You're teetering on the edge... but alive.</span>")
	playsound(user, 'sound/magic/devour_will_end.ogg', 50, 0)
	flash_color(user, flash_color = "#21007F", flash_time = 30)
	flash_color(victim, flash_color = "#21007F", flash_time = 30)
	victim << sound('sound/magic/devour_will_victim.ogg', volume = 75)
	victim.Paralyse(30)
	victim.reagents.add_reagent("zombiepowder", 2) //Short window of opportunity to make them into a veil
	new/obj/effect/overlay/temp/soul(get_turf(victim)) //spooky
	if(user.mind && user.mind.umbrage_psionics)
		var/datum/umbrage/U = user.mind.umbrage_psionics
		user << "<span class='velvet_bold'>Your maximum psi has increased by ten. Your psi has been fully refilled.</span>"
		U.max_psi += 10
		U.psi = U.max_psi
	qdel(src)
