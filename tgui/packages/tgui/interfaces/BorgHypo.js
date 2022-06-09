import { toFixed } from 'common/math';
import { useBackend } from '../backend';
import { Button, NoticeBox, Section, ProgressBar } from '../components';
import { Window } from '../layouts';

export const BorgHypo = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    maxVolume,
    theme,
    reagents,
    selectedReagent,
  } = data;
  return (
    <Window
      width={400}
      height={620}
      theme={theme}
    >
      <Window.Content scrollable>
        <Reagent
          reagents={reagents}
          selected={selectedReagent}
          maxVolume={maxVolume} />
      </Window.Content>
    </Window>
  );
};

const Reagent = (props, context) => {
  const { act, data } = useBackend(context);
  const { reagents, selected, maxVolume } = props;
  if (!reagents) {
    return (
      <NoticeBox>
        No reagents available!
      </NoticeBox>
    );
  }
  return reagents.map(reagent => {
    if (reagent) {
      return (
        <Section
          key={reagent.ref}
          title={reagent.name}>
          <ProgressBar
            value={reagent.volume / maxVolume}
            mb={2}>
            {toFixed(reagent.volume) + ' units'}
          </ProgressBar>
          <Button
            icon={'syringe'}
            color={reagent.name === selected ? 'green' : 'default'}
            content={'Dispense'}
            textAlign={'center'}
            tooltip={reagent.description}
            onClick={() => act(reagent.name)}
          />
        </Section>
      );
    }
  });
};
