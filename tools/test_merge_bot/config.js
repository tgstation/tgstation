// A URL that, on GET, will return an array of objects with the schema
// { round_id, datetime, test_merges, server, url }
// You can see the moth.fans implementation in Rust here: https://github.com/Mothblocks/mothbus/blob/41fec056824edba0ffdfa39882b67739bf475d83/src/routes/recent_test_merges.rs#L30
export const GET_TEST_MERGES_URL =
	"https://bus.moth.fans/recent-test-merges.json";
