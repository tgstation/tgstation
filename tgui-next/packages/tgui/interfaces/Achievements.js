import { Fragment } from 'inferno';
import { act } from '../byond';
import { Box, Tabs } from '../components';

export const Achievements = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
  return (
    <Tabs>
      {data.categories.map(category => (
        <Tabs.Tab
          key={category}
          label={category}>
          <Box as="Table">
            {data.achievements
              .filter(x => x.category === category)
              .map(achievement => (
                <tr key={achievement.name}>
                  <td style={{'padding': '6px'}}>
                    <Box className={achievement.icon_class} />
                  </td>
                  <td style={{'vertical-align': 'top'}}>
                    <h1>{achievement.name}</h1>
                    {achievement.desc}
                    <Box
                      color={achievement.achieved ? "good" : "bad"}
                      content={achievement.achieved ? "Unlocked" : "Locked"} />
                  </td>
                </tr>
              ))}
          </Box>
        </Tabs.Tab>
      ))}
    </Tabs>
  );
};
