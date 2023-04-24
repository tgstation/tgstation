import { strict as assert } from "assert";
import { createComment } from "./comment.js";

const baseServers = {
	bagil: [
		{
			round_id: 1,
			datetime: "2020-01-01 00:00:00",
			server: "bagil",
			url: "https://tgstation13.org/round/1",
		},
	],
};

const baseComment = createComment(
	baseServers,

	null
);

assert.equal(
	baseComment,
	`<!-- test_merge_bot: 1 -->
This pull request was test merged in 1 round(s).
<details><summary>Round list</summary>


### bagil
- [1 @ 2020-01-01 00:00:00](https://tgstation13.org/round/1)

</details>
`
);

assert.equal(createComment(baseServers, baseComment), null);

assert.equal(
	createComment(
		{
			bagil: [
				{
					round_id: 2,
					datetime: "2020-01-01 01:00:00",
					server: "bagil",
					url: "https://tgstation13.org/round/2",
				},
			],
		},
		baseComment
	),
	`<!-- test_merge_bot: 1, 2 -->
This pull request was test merged in 2 round(s).
<details><summary>Round list</summary>


### bagil
- [2 @ 2020-01-01 01:00:00](https://tgstation13.org/round/2)
- [1 @ 2020-01-01 00:00:00](https://tgstation13.org/round/1)

</details>
`
);
