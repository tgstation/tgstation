import { useBackend } from '../backend';
import { Box, Icon, Table, Tabs } from '../components';
import { Window } from '../layouts';

export const Achievements = (props, context) => {
  const { data } = useBackend(context);
  const {
    achievements,
    categories,
    highscore,
    user_ckey,
  } = data;
  return (
    <Window resizable>
      <Window.Content scrollable>
        <Tabs>
          {categories.map(category => (
            <Tabs.Tab
              key={category}
              label={category}>
              <Table>
                {achievements
                  .filter(x => x.category === category)
                  .map(achievement => {
                    if (achievement.score) {
                      return (
                        <Score
                          key={achievement.name}
                          achievement={achievement} />
                      );
                    }
                    return (
                      <Achievement
                        key={achievement.name}
                        achievement={achievement} />
                    );
                  })}
              </Table>
            </Tabs.Tab>
          ))}
          <Tabs.Tab
            label="High Scores">
            <Tabs vertical>
              {highscore.map(highscore => (
                <Tabs.Tab
                  key={highscore.name}
                  label={highscore.name}>
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
                    {Object.keys(highscore.scores).map((key, index) => (
                      <Table.Row
                        key={key}
                        className="candystripe"
                        m={2}>
                        <Table.Cell color="label" textAlign="center">
                          {index + 1}
                        </Table.Cell>
                        <Table.Cell
                          color={key === user_ckey && 'green'}
                          textAlign="center">
                          {index === 0 && (
                            <Icon name="crown" color="gold" mr={2} />
                          )}
                          {key}
                          {index === 0 && (
                            <Icon name="crown" color="gold" ml={2} />
                          )}
                        </Table.Cell>
                        <Table.Cell textAlign="center">
                          {highscore.scores[key]}
                        </Table.Cell>
                      </Table.Row>
                    ))}
                  </Table>
                </Tabs.Tab>
              ))}
            </Tabs>
          </Tabs.Tab>
        </Tabs>
      </Window.Content>
    </Window>
  );
};

const Achievement = props => {
  const { achievement } = props;
  const {
    name,
    desc,
    icon_class,
    value,
  } = achievement;
  return (
    <tr key={name}>
      <td style={{ 'padding': '6px' }}>
        <Box className={icon_class} />
      </td>
      <td style={{ 'vertical-align': 'top' }}>
        <h1>{name}</h1>
        {desc}
        <Box color={value ? 'good' : 'bad'}>
          {value ? 'Unlocked' : 'Locked'}
        </Box>
      </td>
    </tr>
  );
};

const Score = props => {
  const { achievement } = props;
  const {
    name,
    desc,
    icon_class,
    value,
  } = achievement;
  return (
    <tr key={name}>
      <td style={{ 'padding': '6px' }}>
        <Box className={icon_class} />
      </td>
      <td style={{ 'vertical-align': 'top' }}>
        <h1>{name}</h1>
        {desc}
        <Box color={value > 0 ? 'good' : 'bad'}>
          {value > 0 ? `Earned ${value} times` : 'Locked'}
        </Box>
      </td>
    </tr>
  );
};
