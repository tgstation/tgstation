/datum/datastructures/LinkedListTest


/world/proc/testLinkedList()
	var/allTestsPass = 1

	world << "\red \b Testing LinkedList."
	var/datum/datastructures/LinkedList/head = new /datum/datastructures/LinkedList()


	//List starts out with nothing in it
	var/firstText="First Add"

	if (head.size()!=0)
		world << "\red \b LinkedList Test Error: expected 0, but was [head.size()]"
		allTestsPass = 0


	head.add(firstText)
	if (head.size()!=1)
		world << "\red \b LinkedList Test Error: expected 1, but was [head.size()]"
		allTestsPass = 0

	//same object ref for the compare
	if(head.peek()!=firstText)
		world << "\red \b LinkedList Test Error: expected [firstText], but was [head.peek()]"
		allTestsPass = 0

	head.add("Two")
	if (head.size()!=2)
		world << "\red \b LinkedList Test Error: expected 2, but was [head.size()]"
		allTestsPass = 0

	head.add("Tree")
	if (head.size()!=3)
		world << "\red \b LinkedList Test Error: expected 3, but was [head.size()]"
		allTestsPass = 0

	//Adding is working if no errors so far

	//Test pop
	var/datum/datastructures/LinkedList/poped = head.pop()
	if(poped!=firstText)
		world << "\red \b LinkedList Test Error: expected [firstText], but was [head.peek()]"
		allTestsPass = 0

	if (head.size()!=2)
		world << "\red \b LinkedList Test Error: expected 2, but was [head.size()]"
		allTestsPass = 0

	poped = head.pop()
	if (head.size()!=1)
		world << "\red \b LinkedList Test Error: expected 1, but was [head.size()]"
		allTestsPass = 0


	poped = head.pop()
	if (head.size()!=0)
		world << "\red \b LinkedList Test Error: expected 1, but was [head.size()]"
		allTestsPass = 0

	//now poped will become null
	poped = head.pop()
	if(	poped != null)
		world << "\red \b LinkedList Test Error: pop() didn't return null when list was empty"
		allTestsPass = 0



	if(allTestsPass==1)
		world << "\red \b Testing LinkedList Complete Successfully"
	else
		world << "\red \b Testing LinkedList had errors"

	return allTestsPass