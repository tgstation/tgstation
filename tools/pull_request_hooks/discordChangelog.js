import { parseChangelog } from "./changelogParser.js";

export async function sendDiscordChangelog({ context }) {
  const { pull_request } = context.payload;
  if (!pull_request) return;

  const changelog = parseChangelog(pull_request.body);
  if (!changelog || changelog.changes.length === 0) {
    console.log("No changelog found, skipping Discord notification.");
    return;
  }

  const webhookUrl = process.env.CHANGELOG_DISCORD_WEBHOOK;
  if (!webhookUrl) {
    console.log("CHANGELOG_DISCORD_WEBHOOK not set, skipping.");
    return;
  }

  const prNumber = pull_request.number;
  const prTitle = pull_request.title;
  const author = pull_request.user.login;
  const mergedAt = pull_request.merged_at;

  const changesText = changelog.changes
    .map((change) => `${change.type.changelogKey}: ${change.description}`)
    .join("\n");

  const formatDate = (dateString) => {
    const d = new Date(dateString);
    return d.toLocaleString('ru-RU', { hour12: false, timeZone: 'UTC' }).replace(',', '');
  };

  const embed = {
    title: `PR #${prNumber}: ${prTitle}`,
    url: pull_request.html_url,
    color: 0x00ff00,
    fields: [
      {
        name: "Список изменений",
        value: `\`\`\`\n${changesText}\n\`\`\``,
      },
    ],
    footer: {
      text: `${author} — ${formatDate(mergedAt)}`,
    },
    timestamp: mergedAt,
  };

  const payload = { embeds: [embed] };

  const response = await fetch(webhookUrl, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload),
  });

  if (!response.ok) {
    throw new Error(`Discord webhook failed: ${response.statusText}`);
  }
}
