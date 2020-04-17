import { useBackend, useLocalState } from '../backend';
import { Box, Icon, Table, Tabs } from '../components';
import { Window } from '../layouts';
import { Fragment } from 'inferno';

export const Achievements = (props, context) => {
  const { data } = useBackend(context);
  const { categories } = data;
  const [
    selectedCategory,
    setSelectedCategory,
  ] = useLocalState(context, 'category', categories[0]);
  const achievements = data.achievements
    .filter(x => x.category === selectedCategory);
  return (
    <Window resizable>
      <Window.Content scrollable>
        <Tabs>
          {categories.map(category => (
            <Tabs.Tab
              key={category}
              selected={selectedCategory === category}
              onClick={() => setSelectedCategory(category)}>
              {category}
            </Tabs.Tab>
          ))}
          <Tabs.Tab
            selected={selectedCategory === 'High Scores'}
            onClick={() => setSelectedCategory('High Scores')}>
            High Scores
          </Tabs.Tab>
        </Tabs>
        {selectedCategory === 'High Scores' && (
          <HighScoreTable />
        ) || (
          <AchievementTable achievements={achievements} />
        )}
      </Window.Content>
    </Window>
  );
};

const AchievementTable = (props, context) => {
  const { achievements } = props;
  return (
    <Table>
      {achievements.map(achievement => (
        <Achievement
          key={achievement.name}
          achievement={achievement} />
      ))}
    </Table>
  );
};

const Achievement = props => {
  const { achievement } = props;
  const {
    name,
    desc,
    icon_class,
    value,
    score,
  } = achievement;
  return (
    <tr key={name}>
      <td style={{ 'padding': '6px' }}>
        <Box className={icon_class} />
      </td>
      <td style={{ 'vertical-align': 'top' }}>
        <h1>{name}</h1>
        {desc}
        {score && (
          <Box color={value > 0 ? 'good' : 'bad'}>
            {value > 0 ? `Earned ${value} times` : 'Locked'}
          </Box>
        ) || (
          <Box color={value ? 'good' : 'bad'}>
            {value ? 'Unlocked' : 'Locked'}
          </Box>
        )}
      </td>
    </tr>
  );
};

const HighScoreTable = (props, context) => {
  const { data } = useBackend(context);
  const {
    highscore: highscores,
    user_ckey,
  } = data;
  const [
    highScoreIndex,
    setHighScoreIndex,
  ] = useLocalState(context, 'highscore', 0);
  const highscore = highscores[highScoreIndex];
  if (!highscore) {
    return null;
  }
  const scores = Object
    .keys(highscore.scores)
    .map(key => ({
      ckey: key,
      value: highscore.scores[key],
    }));
  return (
    <Fragment>
      <Tabs vertical>
        {highscores.map((highscore, i) => (
          <Tabs.Tab
            key={highscore.name}
            selected={highScoreIndex === i}
            onClick={() => setHighScoreIndex(i)}>
            {highscore.name}
          </Tabs.Tab>
        ))}
      </Tabs>
      <Table>
        <Table.Row className="candystripe">
          <Table.Cell color="label" textAlign="center">
            #
          </Table.Cell>
          <Table.Cell color="label" textAlign="center">
            Key
          </Table.Cell>
          <Table.Cell color="label" textAlign="center">
            Score
          </Table.Cell>
        </Table.Row>
        {scores.map((score, i) => (
          <Table.Row
            key={score.ckey}
            className="candystripe"
            m={2}>
            <Table.Cell color="label" textAlign="center">
              {i + 1}
            </Table.Cell>
            <Table.Cell
              color={score.ckey === user_ckey && 'green'}
              textAlign="center">
              {i === 0 && (
                <Icon name="crown" color="gold" mr={2} />
              )}
              {score.ckey}
              {i === 0 && (
                <Icon name="crown" color="gold" ml={2} />
              )}
            </Table.Cell>
            <Table.Cell textAlign="center">
              {score.value}
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Fragment>
  );
};
