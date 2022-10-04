// A URL that, on GET, will return an array of objects with the schema
// { round_id, datetime, test_merges, server, url }
// MOTHBLOCKS TODO: Link the mothbus code for this as an example
const GET_TEST_MERGES_URL =
	// "https://bus.moth.fans/recent-test-merges.json";
	"http://6ffc-172-92-14-65.ngrok.io/recent-test-merges.json";

module.exports = { GET_TEST_MERGES_URL };
