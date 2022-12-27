const FIND_EXISTING_ENTRIES = /### (.+)\n((?:- .+\n)*)/g;
const ENTRY_PATTERN =
	/- \[(?<round_id>[0-9]+) @ (?<datetime>.+?)\]\((?<url>.+)\)/;

export const createComment = (servers, existingComment) => {
	if (existingComment) {
		for (const [, serverName, entries] of existingComment.matchAll(
			FIND_EXISTING_ENTRIES
		)) {
			let server = servers[serverName];
			if (!server) {
				server = [];
				servers[serverName] = server;
			}

			for (const line of entries.split("\n")) {
				const match = line.match(ENTRY_PATTERN);
				if (!match) {
					continue;
				}

				const { round_id: roundIdString, datetime, url } = match.groups;
				const round_id = parseInt(roundIdString, 10);

				if (server.find((round) => round.round_id === round_id)) {
					continue;
				}

				server.push({
					round_id,
					datetime,
					url,
				});
			}
		}
	}

	const roundIds = Object.values(servers)
		.flat()
		.map(({ round_id }) => round_id)
		.sort()
		.join(", ");

	const newHeader = `<!-- test_merge_bot: ${roundIds} -->`;

	if (existingComment?.startsWith(newHeader)) {
		return null;
	}

	let totalRounds = 0;
	let listOfRounds = "";

	for (const [server, rounds] of Object.entries(servers).sort(
		([a], [b]) => b - a
	)) {
		totalRounds += rounds.length;

		listOfRounds += `${"\n"}### ${server}`;

		for (const { datetime, round_id, url } of rounds.sort(
			(a, b) => b.round_id - a.round_id
		)) {
			listOfRounds += `${"\n"}- [${round_id} @ ${datetime}](${url})`;
		}

		listOfRounds += "\n";
	}

	return (
		newHeader +
		`\nThis pull request was test merged in ${totalRounds} round(s).` +
		"\n" +
		"<details><summary>Round list</summary>\n\n" +
		listOfRounds +
		"\n</details>\n"
	);
};
