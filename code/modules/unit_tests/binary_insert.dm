/// A test to ensure the sanity of BINARY_INSERT
/datum/unit_test/binary_insert/Run()
	var/list/datum/binary_insert_node/nodes = list()

	var/datum/binary_insert_node/node_a = new /datum/binary_insert_node(10)
	BINARY_INSERT(node_a, nodes, /datum/binary_insert_node, node_a, x, COMPARE_KEY)
	TEST_ASSERT_EQUAL(nodes.len, 1, "List should have one node")

	var/datum/binary_insert_node/node_b = new /datum/binary_insert_node(5)
	BINARY_INSERT(node_b, nodes, /datum/binary_insert_node, node_b, x, COMPARE_KEY)
	TEST_ASSERT_EQUAL(nodes.len, 2, "List should have two nodes")
	TEST_ASSERT_EQUAL(nodes[1].x, 5, "The first node should be the one with 5")
	TEST_ASSERT_EQUAL(nodes[2].x, 10, "The second node should be the one with 10")

	var/datum/binary_insert_node/node_c = new /datum/binary_insert_node(15)
	BINARY_INSERT(node_c, nodes, /datum/binary_insert_node, node_c, x, COMPARE_KEY)
	TEST_ASSERT_EQUAL(nodes.len, 3, "List should have three nodes")
	TEST_ASSERT_EQUAL(nodes[1].x, 5, "The first node should be the one with 5")
	TEST_ASSERT_EQUAL(nodes[2].x, 10, "The second node should be the one with 10")
	TEST_ASSERT_EQUAL(nodes[3].x, 15, "The third node should be the one with 15")

/datum/binary_insert_node
	var/x

/datum/binary_insert_node/New(_x)
	x = _x
