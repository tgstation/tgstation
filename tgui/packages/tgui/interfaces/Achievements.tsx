import { useState } from 'react';
import {
  Box,
  Flex,
  Icon,
  Image,
  ProgressBar,
  Table,
  Tabs,
  Tooltip,
} from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  categories: string[];
  achievements: Achievement[];
  highscores: Highscore[];
  progresses: Progress[];
  user_key: string;
};

type Achievement = {
  name: string;
  desc: string;
  category: string;
  icon_class: string;
  value: number;
  score: BooleanLike;
  achieve_info: string;
  achieve_tooltip: string;
};

type Highscore = {
  name: string;
  scores: Score[];
};

type Score = {
  ckey: string;
  value: number;
};

type Progress = {
  name: string;
  value_text: string;
  percent: number;
  entries: ProgEntry[];
};

type ProgEntry = {
  name: string;
  icon: string;
  height: number;
  width: number;
};

export const Achievements = (props) => {
  const { data } = useBackend<Data>();
  const { categories } = data;
  const [selectedCategory, setSelectedCategory] = useState(categories[0]);
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
          <Tabs.Tab
            selected={selectedCategory === 'Progress'}
            onClick={() => setSelectedCategory('Progress')}
          >
            Progress
          </Tabs.Tab>
        </Tabs>
        {(selectedCategory === 'High Scores' && <HighScoreTable />) ||
          (selectedCategory === 'Progress' && <ProgressTable />) || (
            <AchievementTable category={selectedCategory} />
          )}
      </Window.Content>
    </Window>
  );
};

const AchievementTable = (props) => {
  const { data } = useBackend<Data>();
  const { achievements } = data;
  const { category } = props;
  const filtered_achievements = achievements.filter(
    (x) => x.category === category,
  );
  return (
    <Table>
      {filtered_achievements.map((achievement) => (
        <Table.Row key={achievement.name}>
          <Table.Cell collapsing>
            <Box m={1} className={achievement.icon_class} />
          </Table.Cell>
          <Table.Cell verticalAlign="top">
            <h1>{achievement.name}</h1>
            {achievement.desc}
            {(achievement.score && (
              <Box color={achievement.value > 0 ? 'good' : 'bad'}>
                {achievement.value > 0
                  ? `Earned ${achievement.value} times`
                  : 'Locked'}
              </Box>
            )) || (
              <Box color={achievement.value ? 'good' : 'bad'}>
                {achievement.value ? 'Unlocked' : 'Locked'}
              </Box>
            )}
            {!!achievement.achieve_info && (
              <Tooltip position="bottom" content={achievement.achieve_tooltip}>
                <Box fontSize={0.9} opacity={0.8}>
                  {achievement.achieve_info}
                </Box>
              </Tooltip>
            )}
          </Table.Cell>
        </Table.Row>
      ))}
    </Table>
  );
};

const ProgressTable = () => {
  const { data } = useBackend<Data>();
  const { progresses } = data;
  const [progressIndex, setProgressIndex] = useState(0);
  if (!progresses || progresses.length === 0) {
    return null;
  }
  const progress: Progress = progresses[progressIndex];
  return (
    <Flex>
      <Flex.Item>
        <Tabs vertical>
          {progresses.map((progress, i) => (
            <Tabs.Tab
              key={progress.name}
              selected={progressIndex === i}
              onClick={() => setProgressIndex(i)}
            >
              {progress.name}
            </Tabs.Tab>
          ))}
        </Tabs>
      </Flex.Item>
      <Flex.Item grow={1} basis={0}>
        <ProgressBar
          ranges={{
            gold: [0.97, Infinity],
            good: [-Infinity, 0.97],
          }}
          value={progress.percent}
        >
          <Box fontSize="15px" bold>
            {progress.percent >= 0.97 && (
              <Icon name="crown" color="yellow" mr={2} />
            )}
            {progress.value_text}
            {progress.percent >= 0.98 && (
              <Icon name="crown" color="yellow" mr={2} />
            )}
          </Box>
        </ProgressBar>
        <Table>
          {progress.entries.map((entry, i) => (
            <Table.Row key={entry.name} className="candystripe">
              <Table.Cell width="128px">
                <Image
                  src={`data:image/jpeg;base64,${entry.icon}`}
                  height={`${entry.height}px`}
                  width={`${entry.width}px`}
                />
              </Table.Cell>
              <Table.Cell>
                <Box fontSize="16px" bold>
                  {entry.name}
                </Box>
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
      </Flex.Item>
    </Flex>
  );
};

const HighScoreTable = () => {
  const { data } = useBackend<Data>();
  const { highscores, user_key } = data;
  const [highScoreIndex, setHighScoreIndex] = useState(0);
  if (!highscores || highscores.length === 0) {
    return null;
  }
  const highscore: Highscore = highscores[highScoreIndex];
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
          {highscore.scores.map((score, i) => (
            <Table.Row key={score.ckey} className="candystripe" m={2}>
              <Table.Cell color="label" textAlign="center">
                {i + 1}
              </Table.Cell>
              <Table.Cell
                color={score.ckey === user_key && 'green'}
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
