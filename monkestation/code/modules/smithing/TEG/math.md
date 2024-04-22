ZT = S2(σ)T/k

We want a low k value as it signifies the thermal conductivity
We want a high σ value as it signifies the electrical conductivity

ZT = S2(1000)T/1

While we can deal with the Seebeck coefficient that will make the math far to complicated to work with in the future so we are going to simplfy that part out

ZT = 2(1000)T/1

We are applying this as an ideal state when inputted instead of a constant check so we can drop the temperature variable so it simplifies down to

ZT = 2(1000)/1

so the final calculation we will use in game is.

ZT = 2(σ)/k

An example of this would be:

MATERIAL STATS
	thermal = 60
	conductivity = 100

ZT = 2(100)/60
ZT = 200/60
ZT = 3.333

The other issue would be that since we are taking out temperature and Seebeck all the outputs would be good for power generation, plus we have a base efficency on the TEG we need to worry about so we would need to add a constant decrease and to make it line up with how the TEG's base efficency works we would need to multiply it afterwards so it would change to

ZT = ((2(100)/60) - a) * b

an example of this now would be 

ZT = ((2(100)/60) - 2) * 10

ZT = (1.33) * 10

ZT = 13.3

Which is fine until we get a really really good setup for instance

ZT = ((2(100)/1) - 2) * 10
ZT = (198) * 10
ZT = 1980

This means we are going to need to clamp the end value to be reasonable, so we can take the base scale of the engine and clamp at *0.5 and *1.5 so we can't blow shit up.

