/obj/item/weapon/changeling_injector
	name = "Mutagenic Changeling Injector"
	desc = "An injection-device that contains mutagenic cells sampled from a changeling."
	icon = 'icons/obj/syringe.dmi'
	icon_state = "combat_hypo"
	item_state = "hypo"
	var/injected = 0
	origin_tech = "biotech=6;syndicate=6"

/obj/item/weapon/changeling_injector/attack_self(mob/living/user)
	if(!ishuman(user))
		user << "<span class='warning'>The [src] flashes a red warning light. The injector is incompatible with your biological form.</span>"
		return
	if(injected)
		user << "<span class='warning'>The [src]'s cell samples have already been injected.</span>"
		return
	var/list/parasites = user.hasparasites()
	if(parasites.len) //thought you were clever and could cheese the system, eh? Think again.
		user << "<span class='warning'>The [src]'s flashes a red warning light. You body contains incompatible foreign parasites.</span>"
		return
	if(user.mind && user.mind.changeling)
		user << "<span class='warning'>The cells in the [src] recoil back into the injector.</span>" //can't be a changeling if you're a changeling.
		return
	user << "<span class='notice'>You inject the [src].</span>"
	user.make_changeling()
	injected = 1