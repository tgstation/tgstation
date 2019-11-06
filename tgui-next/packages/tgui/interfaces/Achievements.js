import { Fragment } from 'inferno';
import { act } from '../byond';
import { Box, Tabs, LabeledList, Section } from '../components';
import { LabeledListItem } from '../components/LabeledList';

export const Achievement = props => {
  const {
    name,
    desc,
    icon_class,
    value,
  } = props;
  return (
    <tr key={name}>
      <td style={{'padding': '6px'}}>
        <Box className={icon_class} />
      </td>
      <td style={{'vertical-align': 'top'}}>
        <h1>{name}</h1>
        {desc}
        <Box
          color={value ? "good" : "bad"}
          content={value ? "Unlocked" : "Locked"} />
      </td>
    </tr>);
};

export const Score = props => {
  const {
    name,
    desc,
    icon_class,
    value,
  } = props;
  return (
    <tr key={name}>
      <td style={{'padding': '6px'}}>
        <Box className={icon_class} />
      </td>
      <td style={{'vertical-align': 'top'}}>
        <h1>{name}</h1>
        {desc}
        <Box
          color={value > 0 ? "good" : "bad"}
          content={value > 0 ? "Earned " + value + " times" : "Locked"} />
      </td>
    </tr>);
};

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
              .map(achievement => {
                if (achievement.score)
                {
                  return (<Score
                    name={achievement.name}
                    desc={achievement.desc}
                    icon_class={achievement.icon_class}
                    value={achievement.value} />);
                }
                else
                {
                  return (<Achievement
                    name={achievement.name}
                    desc={achievement.desc}
                    icon_class={achievement.icon_class}
                    value={achievement.value} />);
                }
              })}
          </Box>
        </Tabs.Tab>
      ))}
      <Tabs.Tab
        label={"High Scores"}>
        {data.highscore.map(highscore => {
          return (
            <Section key={highscore.name} title={highscore.name}>
              <LabeledList>
                {
                  Object.keys(highscore.scores).map(key =>
                  {
                    return (<LabeledListItem key={key} label={key}>{highscore.scores[key]}</LabeledListItem>);
                  })
                }
              </LabeledList>
            </Section>);
        })}
      </Tabs.Tab>
    </Tabs>
  );
};
