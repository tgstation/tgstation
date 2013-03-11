// this toggle doesn't save across rounds
/mob/verb/musictoggle()
	set name = "Music Toggle"
	if(src.be_music == 0)
		src.be_music = 1
		src << "\blue Music toggled on!"
		return
	src.be_music = 0
	src << "\blue Music toggled off!"

// This checks a var on each area and plays that var
/area/Entered(mob/A as mob)
	if (A && src.music != "" && A.client && A.be_music != 0 && (A.music_lastplayed != src.music))
		A.music_lastplayed = src.music
		A << sound(src.music, repeat = 0, wait = 0, volume = 20, channel = 1)
