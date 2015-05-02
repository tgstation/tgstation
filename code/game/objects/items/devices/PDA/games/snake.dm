////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//   Snake II, by Deity Link, based on the original game from the year 2000, installed on Nokia phones, most notably the Nokia 3310   //
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/snake
	var/x = 10
	var/y = 5
	var/life = 7
	var/dir = EAST
	var/isfull = 0
	var/flicking = 0

/datum/snake/head
	var/open_mouth
	var/next_full = 0

/datum/snake/body
	var/corner = null

/datum/snake/bonus
	var/bonustype = 1

/datum/snake/egg

/datum/snake/wall

/datum/snake/wall/New(var/xx,var/yy)
	x = xx
	y = yy

/datum/snake_game
	var/level = 1
	var/snakescore = 0
	var/eggs_eaten = 0	//eggs eaten since the last bonus got eaten/despawned
	var/lastinput = null
	var/gameover = 0
	var/gyroscope = 0
	var/labyrinth = 0

	var/datum/snake/head/head = null
	var/datum/snake/egg/next_egg = null
	var/datum/snake/bonus/next_bonus = null
	var/list/snakeparts = list()
	var/list/labyrinthwalls = list()

/datum/snake_game/proc/game_start()
	gameover = 0
	head = new()
	snakeparts = list()
	for(var/i=6; i > 0; i--)
		var/datum/snake/body/B = new()
		B.x = i+3
		B.life = i
		snakeparts += B
	next_egg = new()
	next_egg.x = 15
	next_bonus = new()
	next_bonus.life = 0
	eggs_eaten = 0
	snakescore = 0
	switch(labyrinth)
		if(3)
			for(var/datum/snake/body/B in snakeparts)
				B.y = 6
				B.x += 5
			head.y = 6
			head.x += 5
			next_egg.y = 6
			next_egg.x = 3
		if(4)
			for(var/datum/snake/body/B in snakeparts)
				B.x += 8
			head.x += 8
			next_egg.x = 3
		if(6)
			for(var/datum/snake/body/B in snakeparts)
				B.x += 8
				B.y = 6
			head.x += 8
			head.y = 6
			next_egg.x = 3
			next_egg.y = 6
		if(7)
			for(var/datum/snake/body/B in snakeparts)
				B.y = 6
			head.y = 6
			next_egg.y = 6

/datum/snake_game/proc/game_tick(var/dir)
	var/datum/snake/body/newbody = new()
	snakeparts += newbody
	newbody.x = head.x
	newbody.y = head.y
	newbody.life = head.life
	if(head.next_full)
		newbody.isfull = 1
		head.next_full = 0

	if(gyroscope)
		lastinput = dir

	var/old_dir = head.dir

	if(lastinput && !((head.dir == NORTH) && (lastinput == SOUTH)) && !((head.dir == SOUTH) && (lastinput == NORTH)) && !((head.dir == EAST) && (lastinput == WEST)) && !((head.dir == WEST) && (lastinput == EAST)))
		if(head.dir != lastinput)
			newbody.corner = head.dir
		head.dir = lastinput
		lastinput = null
	else
		lastinput = null

	newbody.dir = head.dir

	var/next_x = head.x
	var/next_y = head.y
	var/afternext_x = head.x
	var/afternext_y = head.y
	switch(head.dir)
		if(NORTH)
			next_x = head.x
			next_y = head.y + 1
		if(SOUTH)
			next_x = head.x
			next_y = head.y - 1
		if(EAST)
			next_x = head.x + 1
			next_y = head.y
		if(WEST)
			next_x = head.x - 1
			next_y = head.y
	if(next_x > 20)
		next_x = 1
	if(next_x < 1)
		next_x = 20
	if(next_y > 9)
		next_y = 1
	if(next_y < 1)
		next_y = 9
	switch(head.dir)
		if(NORTH)
			afternext_x = next_x
			afternext_y = next_y + 1
		if(SOUTH)
			afternext_x = next_x
			afternext_y = next_y - 1
		if(EAST)
			afternext_x = next_x + 1
			afternext_y = next_y
		if(WEST)
			afternext_x = next_x - 1
			afternext_y = next_y
	if(afternext_x > 20)
		afternext_x = 1
	if(afternext_x < 1)
		afternext_x = 20
	if(afternext_y > 9)
		afternext_y = 1
	if(afternext_y < 1)
		afternext_y = 9

	for(var/datum/snake/body/B in snakeparts)
		if((B.life > 0) && (B.x == next_x) && (B.y == next_y))
			gameover = 1
			head.dir = old_dir
			newbody.life = 0
			snakeparts -= newbody
			return

	for(var/datum/snake/wall/W in labyrinthwalls)
		if((W.x == next_x) && (W.y == next_y))
			gameover = 1
			head.dir = old_dir
			newbody.life = 0
			snakeparts -= newbody
			return

	var/hunger = 0
	if((next_egg.x == next_x) && (next_egg.y == next_y))
		eat_egg(next_x,next_y)
		head.next_full = 1
	if((next_egg.x == afternext_x) && (next_egg.y == afternext_y))
		hunger = 1
	if((next_bonus.life > 0) && ((next_bonus.x == next_x) || (next_bonus.x + 1 == next_x)) && (next_bonus.y == next_y))
		eat_bonus()
		head.next_full = 1
	if((next_bonus.life > 0) && ((next_bonus.x == afternext_x) || (next_bonus.x + 1 == afternext_x)) && (next_bonus.y == afternext_y))
		hunger = 1

	if(hunger)
		head.open_mouth = 1
	else
		head.open_mouth = 0

	if(next_bonus.life > 0)
		next_bonus.life--
		if(next_bonus.life == 0)
			eggs_eaten = 0

	for(var/datum/snake/body/B in snakeparts)
		B.life--
		if(B.life <= 0)
			snakeparts -= B

	head.x = next_x
	head.y = next_y

	if(snakescore >= 9999)
		gameover = 1


/datum/spot
	var/x = 0
	var/y = 0

/datum/spot/New(var/xx,var/yy)
	x = xx
	y = yy

/datum/snake_game/proc/eat_egg(var/next_x,var/next_y)
	head.life++
	for(var/datum/snake/body/B in snakeparts)
		B.life++
	snakescore += level
	var/list/available_spots = list()
	for(var/x=1;x<=20;x++)
		for(var/y=1;y<=9;y++)
			var/datum/spot/S = new(x,y)
			available_spots += S
	for(var/datum/spot/S in available_spots)
		for(var/datum/snake/wall/W in labyrinthwalls)
			if((S.x == W.x) && (S.y == W.y))
				available_spots -= S
		for(var/datum/snake/body/B in snakeparts)
			if((B.life > 0) && (S.x == B.x) && (S.y == B.y))
				available_spots -= S
		if((S.x == head.x) && (S.y == head.y))
			available_spots -= S
		if((S.x == next_x) && (S.y == next_y))
			available_spots -= S
		if((next_bonus.life > 0) && (next_bonus.x == S.x) && (next_bonus.y == S.y))
			available_spots -= S
		if((next_bonus.life > 0) && (next_bonus.x + 1 == S.x) && (next_bonus.y == S.y))
			available_spots -= S
	if(!available_spots.len)
		gameover = 1
		return
	var/datum/spot/chosen_spot = pick(available_spots)
	next_egg.x = chosen_spot.x
	next_egg.y = chosen_spot.y
	eggs_eaten++
	if(eggs_eaten == 5)
		spawn_bonus()

/datum/snake_game/proc/spawn_bonus()
	next_bonus.bonustype = rand(1,6)
	var/list/available_spots = list()
	for(var/x=1;x<=19;x++)	//bonus items are two spot wide.
		for(var/y=1;y<=9;y++)
			var/datum/spot/S = new(x,y)
			available_spots += S
	for(var/datum/spot/S in available_spots)
		for(var/datum/snake/wall/W in labyrinthwalls)
			if((S.x == W.x) && (S.y == W.y))
				available_spots -= S
			if(((S.x+1) == W.x) && (S.y == W.y))
				available_spots -= S
		for(var/datum/snake/body/B in snakeparts)
			if((B.life > 0) && (S.x == B.x) && (S.y == B.y))
				available_spots -= S
			if((B.life > 0) && ((S.x+1) == B.x) && (S.y == B.y))
				available_spots -= S
		if((S.x == head.x) && (S.y == head.y))
			available_spots -= S
		if(((S.x+1) == head.x) && (S.y == head.y))
			available_spots -= S
		if((next_egg.x == S.x) && (next_egg.y == S.y))
			available_spots -= S
		if((next_egg.x == (S.x+1)) && (next_egg.y == S.y))
			available_spots -= S
	if(!available_spots.len)
		eggs_eaten = 4
		return
	var/datum/spot/chosen_spot = pick(available_spots)
	next_bonus.x = chosen_spot.x
	next_bonus.y = chosen_spot.y
	next_bonus.life = 20

/datum/snake_game/proc/eat_bonus()
	snakescore += (next_bonus.life * 2 * level)
	next_bonus.life = 0
	eggs_eaten = 0

////////////////LABYRINTHS//////////////////

/datum/snake_game/proc/set_labyrinth(var/lab_type)
	labyrinthwalls = list()
	labyrinth = lab_type
	switch(lab_type)
		if(0)
			return
		if(1)
			for(var/x=1;x<=20;x++)
				var/datum/snake/wall/W = new(x,1)
				labyrinthwalls += W
			for(var/x=1;x<=20;x++)
				var/datum/snake/wall/W = new(x,9)
				labyrinthwalls += W
			for(var/y=2;y<=8;y++)
				var/datum/snake/wall/W = new(1,y)
				labyrinthwalls += W
			for(var/y=2;y<=8;y++)
				var/datum/snake/wall/W = new(20,y)
				labyrinthwalls += W
		if(2)
			var/datum/snake/wall/W1 = new(1,1)
			labyrinthwalls += W1
			var/datum/snake/wall/W2 = new(2,1)
			labyrinthwalls += W2
			var/datum/snake/wall/W3 = new(1,2)
			labyrinthwalls += W3
			var/datum/snake/wall/W4 = new(20,1)
			labyrinthwalls += W4
			var/datum/snake/wall/W5 = new(19,1)
			labyrinthwalls += W5
			var/datum/snake/wall/W6 = new(20,2)
			labyrinthwalls += W6
			var/datum/snake/wall/W7 = new(1,9)
			labyrinthwalls += W7
			var/datum/snake/wall/W8 = new(1,8)
			labyrinthwalls += W8
			var/datum/snake/wall/W9 = new(2,9)
			labyrinthwalls += W9
			var/datum/snake/wall/W10 = new(20,9)
			labyrinthwalls += W10
			var/datum/snake/wall/W11 = new(19,9)
			labyrinthwalls += W11
			var/datum/snake/wall/W12 = new(20,8)
			labyrinthwalls += W12
			for(var/x=9;x<=12;x++)
				var/datum/snake/wall/W = new(x,4)
				labyrinthwalls += W
			for(var/x=9;x<=12;x++)
				var/datum/snake/wall/W = new(x,6)
				labyrinthwalls += W
		if(3)
			for(var/x=1;x<=10;x++)
				var/datum/snake/wall/W = new(x,3)
				labyrinthwalls += W
			for(var/x=11;x<=20;x++)
				var/datum/snake/wall/W = new(x,7)
				labyrinthwalls += W
			for(var/y=1;y<=5;y++)
				var/datum/snake/wall/W = new(12,y)
				labyrinthwalls += W
			for(var/y=5;y<=9;y++)
				var/datum/snake/wall/W = new(9,y)
				labyrinthwalls += W
		if(4)
			for(var/x=1;x<=20;x++)
				var/datum/snake/wall/W = new(x,1)
				labyrinthwalls += W
			for(var/x=1;x<=20;x++)
				var/datum/snake/wall/W = new(x,9)
				labyrinthwalls += W
			for(var/y=2;y<=8;y++)
				if(y!=5)
					var/datum/snake/wall/W = new(1,y)
					labyrinthwalls += W
			for(var/y=2;y<=8;y++)
				if(y!=5)
					var/datum/snake/wall/W = new(20,y)
					labyrinthwalls += W
			for(var/y=3;y<=7;y++)
				var/datum/snake/wall/W = new(8,y)
				labyrinthwalls += W
			for(var/y=3;y<=7;y++)
				var/datum/snake/wall/W = new(13,y)
				labyrinthwalls += W
		if(5)
			for(var/x=1;x<=20;x++)
				var/datum/snake/wall/W = new(x,3)
				labyrinthwalls += W
			for(var/x=1;x<=20;x++)
				if(x!=10)
					var/datum/snake/wall/W = new(x,6)
					labyrinthwalls += W
			for(var/x=1;x<=17;x++)
				if(x!=4)
					var/datum/snake/wall/W = new(x,9)
					labyrinthwalls += W
			var/datum/snake/wall/W1 = new(1,8)
			labyrinthwalls += W1
			var/datum/snake/wall/W2 = new(9,7)
			labyrinthwalls += W2
			var/datum/snake/wall/W3 = new(9,8)
			labyrinthwalls += W3
			var/datum/snake/wall/W4 = new(11,1)
			labyrinthwalls += W4
			var/datum/snake/wall/W5 = new(11,2)
			labyrinthwalls += W5
		if(6)
			for(var/x=1;x<=20;x++)
				var/datum/snake/wall/W = new(x,5)
				labyrinthwalls += W
			for(var/y=1;y<=9;y++)
				if(y!=5)
					var/datum/snake/wall/W = new(11,y)
					labyrinthwalls += W
		if(7)
			for(var/x=1;x<=20;x++)
				var/datum/snake/wall/W = new(x,5)
				labyrinthwalls += W
			for(var/y=1;y<=4;y++)
				var/datum/snake/wall/W = new(5,y)
				labyrinthwalls += W
			for(var/y=1;y<=4;y++)
				var/datum/snake/wall/W = new(16,y)
				labyrinthwalls += W
