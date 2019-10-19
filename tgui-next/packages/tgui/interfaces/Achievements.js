import { Fragment } from 'inferno';
import { act } from '../byond';
import { AnimatedNumber, Icon, Table, Tabs, Button, LabeledList, NoticeBox, ProgressBar, Section, Box } from '../components';

export const Achievements = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
  return (
    <Fragment>
      <NoticeBox>
        <pre>{JSON.stringify(data.achievements)}</pre>
      </NoticeBox>

      <Tabs>
        {data.categories.map(category => (
          <Tabs.Tab label={category}>
            <Box as="Table">

              {data.achievements.filter(x => x.category == category).map(achievement => (
                  <tr>
                    <td style={{'padding': '6px'}}>
                      <Box className={achievement.icon_class} />
                    </td>
                    <td style={{'vertical-align': 'top'}}>
                      <h1>{achievement.name}</h1>
                      {achievement.desc}
                      <Box
                        color={!!achievement.achieved ? "good" : "bad"}
                        content={!!achievement.achieved ? "Gottened" : "Locked"} />
                    </td>
                  </tr>
              ))}

            </Box>
          </Tabs.Tab>
        ))}
      </Tabs>
    </Fragment>
  );
};
