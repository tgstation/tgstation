




//lavaland_surface_seed_vault.dmm
//Seed Vault

/obj/effect/spawner/lootdrop/seed_vault
	name = "seed vault seeds"
	lootcount = 1

	loot = list(/obj/item/seeds/gatfruit = 10,
				/obj/item/seeds/cherryseed = 15,
				/obj/item/seeds/glowberryseed = 10,
				/obj/item/seeds/moonflowerseed = 8,
				)

/obj/effect/mob_spawn/human/seed_vault
	name = "sleeper"
	mob_name = "Vault Creature"
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "sleeper"
	roundstart = FALSE
	death = FALSE
	mob_species = /datum/species/pod
	flavour_text = {"You are a strange, artificial creature. In the face of impending apocalyptic events, your creators tasked you with maintaining an emergency seed vault. You are to tend to the plants and await their return to aid in rebuilding civilization. You've been waiting quite a while though..."}

//Greed

/obj/structure/cursed_slot_machine
	name = "greed's slot machine"
	desc = "High stakes, high rewards."
	icon = 'icons/obj/economy.dmi'
	icon_state = "slots1"
	anchored = 1
	density = 1
	var/win_prob = 5

/obj/structure/cursed_slot_machine/attack_hand(mob/living/carbon/human/user)
	if(!istype(user))
		return
	if(in_use)
		return
	in_use = TRUE
	user << "<span class='danger'><B>You feel your very life draining away as you pull the lever...it'll be worth it though, right?</B></span>"
	user.adjustCloneLoss(20)
	if(user.stat)
		user.gib()
	icon_state = "slots2"
	sleep(50)
	icon_state = "slots1"
	in_use = FALSE
	if(prob(win_prob))
		new /obj/item/weapon/dice/d20/fate/one_use(get_turf(src))
		if(user)
			user << "You hear laughter echoing around you as the machine fades away. In it's place...more gambling."
			qdel(src)
	else
		if(user)
			user << "<span class='danger'>Looks like you didn't win anything this time...next time though, right?</span>"
//Gluttony

/obj/effect/gluttony
	name = "gluttony's wall"
	desc = "Only those who truly indulge may pass."
	anchored = 1
	density = 1
	icon_state = "blob"
	icon = 'icons/mob/blob.dmi'

/obj/effect/gluttony/CanPass(atom/movable/mover, turf/target, height=0)//So bullets will fly over and stuff.
	if(height==0)
		return 1
	if(istype(mover, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = mover
		if(H.nutrition >= NUTRITION_LEVEL_FAT)
			return 1
		else
			H << "<span class='danger'><B>You're not gluttonous enough to pass this barrier!</B></span>"
	else
		return 0

//Pride

/obj/structure/mirror/magic/pride
	name = "pride's mirror"
	desc = "Pride cometh before the..."
	icon_state = "magic_mirror"

/obj/structure/mirror/magic/pride/curse(mob/user)
	user.visible_message("<span class='danger'><B>The ground splits beneath [user] as their hand leaves the mirror!</B></span>")
	var/turf/T = get_turf(user)
	T.ChangeTurf(/turf/simulated/chasm/straight_down)
	var/turf/simulated/chasm/straight_down/C = T
	C.drop(user)

//Sloth - I'll finish this item later

//Envy

/obj/item/weapon/knife/envy
	name = "envy's knife"
	desc = "Their success will be yours."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "render"
	item_state = "render"
	force = 18
	throwforce = 10
	w_class = 3
	hitsound = 'sound/weapons/bladeslice.ogg'

/obj/item/weapon/knife/envy/afterattack(atom/movable/AM, mob/living/carbon/human/user, proximity)
	..()
	if(!proximity)
		return
	if(!istype(user))
		return
	if(istype(AM, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = AM
		if(user.real_name != H.dna.real_name)
			user.real_name = H.dna.real_name
			H.dna.transfer_identity(user, transfer_SE=1)
			user.updateappearance(mutcolor_update=1)
			user.domutcheck()
			user << "You assume the face of [H]. Are you satisfied?"