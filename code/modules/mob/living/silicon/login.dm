<<<<<<< HEAD
/mob/living/silicon/Login()
	if(mind && ticker && ticker.mode)
		ticker.mode.remove_cultist(mind, 0, 0)
		ticker.mode.remove_revolutionary(mind, 0)
		ticker.mode.remove_gangster(mind, remove_bosses=1)
		ticker.mode.remove_hog_follower(mind,0)
	..()
=======
/mob/living/silicon/Login()
	if(mind && ticker && ticker.mode)
		ticker.mode.remove_cultist(mind, 1)
		ticker.mode.remove_revolutionary(mind, 1)
	..()
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
