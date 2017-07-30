/obj/item/weapon/bookofdarkness
	name = "book of darkness"
	desc = "A dark, closed book containing foul magic used against the dead. Opening the book shall seal your fate forever, in exchange for powerful abilities."
	icon = 'hippiestation/icons/obj/weapons.dmi'
	lefthand_file = 'hippiestation/icons/mob/inhands/lefthand.dmi'
	righthand_file = 'hippiestation/icons/mob/inhands/righthand.dmi'
	icon_state = "bookofdarkness"
	force = 0
	throwforce = 0
	w_class = 3
	var/uses = 1
	var/obj/effect/proc_holder/spell/targeted/trigger/soulflare/soulflare = null
	var/obj/effect/proc_holder/spell/targeted/explodecorpse/explodecorpse = null
	var/obj/effect/proc_holder/spell/self/soulsplit/soulsplit = null

/obj/item/weapon/bookofdarkness/attack_self(mob/living/user)
	if(!uses)
		return
	uses--
	to_chat(user, "<font color=purple>You rapidly skim through the pages, but you can't see any letters. As you close the book however, you suddenly find equipment at your feet, and your brain hurts.</font>")
	to_chat(user, "<font color=purple><b>The Staff of Revenant</b></font> is a powerful artifact that lets you drain the souls of the fallen by hitting them with a melee strike from your staff. It starts off relatively weak, but can grow to become the largest threat one can ever face. Activate it in your hand to see your progress, the weapon's current stats and to progress to the next stage if possible.")
	to_chat(user, "<font color=purple><b>Soulflare</b></font> deals 15 burn, brute and toxins damage to the target, putting them asleep for 5 seconds and if they are already in critical condition, they are instantly killed and the spell is refunded. This also applies to corpses.")
	to_chat(user, "<font color=purple><b>Corpse Explosion</b></font> causes a corpse to violently explode in a very large radius, destroying the body alongside it. Make sure to maintain at least 4 tiles distance between you and the target.")
	to_chat(user, "<font color=purple><b>Soulsplit</b></font> let's you become incorporeal for 3.5 seconds, allowing you to phase through objects and walk at very high speeds. However, it cannot be cast if you are below 100 health. In addition, you are still vulnerable to damage and other attacks in this state, nor will it remove any stuns.")
	to_chat(user, "<font color=purple><b>Your robes</b></font> have increased resistance against all damage and will help convey your peaceful intent towards the still living.")
	soulflare = new /obj/effect/proc_holder/spell/targeted/trigger/soulflare
	user.mind.AddSpell(soulflare)

	explodecorpse = new /obj/effect/proc_holder/spell/targeted/explodecorpse
	user.mind.AddSpell(explodecorpse)

	soulsplit = new /obj/effect/proc_holder/spell/self/soulsplit
	user.mind.AddSpell(soulsplit)

	new /obj/item/weapon/gun/magic/staff/staffofrevenant(get_turf(user))
	new /obj/item/clothing/suit/wizrobe/hippie/necrolord(get_turf(user))
	new /obj/item/clothing/head/wizard/hippie/necrolord(get_turf(user))
	new /obj/item/clothing/shoes/sandal/marisa(get_turf(user))

	qdel(src)
