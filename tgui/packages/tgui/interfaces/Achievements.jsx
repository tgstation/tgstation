import { useState } from 'react';
import { Box, Flex, Icon, Table, Tabs, Tooltip } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const Achievements = (props) => {
  const { data } = useBackend();
  const { categories } = data;
  const [selectedCategory, setSelectedCategory] = useState(categories[0]);
  const achievements = data.achievements.filter(
    (x) => x.category === selectedCategory,
  );
  return (
    <Window title="Achievements" width={540} height={680}>
      <Window.Content scrollable>
        <Tabs>
          {categories.map((category) => (
            <Tabs.Tab
              key={category}
              selected={selectedCategory === category}
              onClick={() => setSelectedCategory(category)}
            >
              {category}
            </Tabs.Tab>
          ))}
          <Tabs.Tab
            selected={selectedCategory === 'High Scores'}
            onClick={() => setSelectedCategory('High Scores')}
          >
            High Scores
          </Tabs.Tab>
        </Tabs>
        {(selectedCategory === 'High Scores' && <HighScoreTable />) || (
          <AchievementTable achievements={achievements} />
        )}
      </Window.Content>
    </Window>
  );
};

const AchievementTable = (props) => {
  const { achievements } = props;
  return (
    <Table>
      {achievements.map((achievement) => (
        <Achievement key={achievement.name} achievement={achievement} />
      ))}
    </Table>
  );
};

const Achievement = (props) => {
  const { achievement } = props;
  const {
    name,
    desc,
    icon_class,
    value,
    score,
    achieve_info,
    achieve_tooltip,
  } = achievement;
  return (
    <Table.Row key={name}>
      <Table.Cell collapsing>
        <Box m={1} className={icon_class} />
      </Table.Cell>
      <Table.Cell verticalAlign="top">
        <h1>{name}</h1>
        {desc}
        {(score && (
          <Box color={value > 0 ? 'good' : 'bad'}>
            {value > 0 ? `Earned ${value} times` : 'Locked'}
          </Box>
        )) || (
          <Box color={value ? 'good' : 'bad'}>
            {value ? 'Unlocked' : 'Locked'}
          </Box>
        )}
        {!!achieve_info && (
          <Tooltip position="bottom" content={achieve_tooltip}>
            <Box fontSize={0.9} opacity={0.8}>
              {achieve_info}
            </Box>
          </Tooltip>
        )}
      </Table.Cell>
    </Table.Row>
  );
};

const HighScoreTable = (props) => {
  const { data } = useBackend();
  const { highscore: highscores, user_ckey } = data;
  const [highScoreIndex, setHighScoreIndex] = useState(0);
  const highscore = highscores[highScoreIndex];
  if (!highscore) {
    return null;
  }
  const scores = Object.keys(highscore.scores).map((key) => ({
    ckey: key,
    value: highscore.scores[key],
  }));
  return (
    <Flex>
      <Flex.Item>
        <Tabs vertical>
          {highscores.map((highscore, i) => (
            <Tabs.Tab
              key={highscore.name}
              selected={highScoreIndex === i}
              onClick={() => setHighScoreIndex(i)}
            >
              {highscore.name}
            </Tabs.Tab>
          ))}
        </Tabs>
      </Flex.Item>
      <Flex.Item grow={1} basis={0}>
        <Table>
          <Table.Row header>
            <Table.Cell textAlign="center">#</Table.Cell>
            <Table.Cell textAlign="center">Key</Table.Cell>
            <Table.Cell textAlign="center">Score</Table.Cell>
          </Table.Row>
          {scores.map((score, i) => (
            <Table.Row key={score.ckey} className="candystripe" m={2}>
              <Table.Cell color="label" textAlign="center">
                {i + 1}
              </Table.Cell>
              <Table.Cell
                color={score.ckey === user_ckey && 'green'}
                textAlign="center"
              >
                {i === 0 && <Icon name="crown" color="yellow" mr={2} />}
                {score.ckey}
                {i === 0 && <Icon name="crown" color="yellow" ml={2} />}
              </Table.Cell>
              <Table.Cell textAlign="center">{score.value}</Table.Cell>
            </Table.Row>
          ))}
        </Table>
      </Flex.Item>
    </Flex>
  );
};
