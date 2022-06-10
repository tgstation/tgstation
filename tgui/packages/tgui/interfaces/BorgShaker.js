import { useBackend } from '../backend';
import { Button, NoticeBox, Section } from '../components';
import { Window } from '../layouts';

export const BorgShaker = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    maxVolume,
    theme,
    reagents,
    selectedReagent,
  } = data;
  return (
    <Window
      width={650}
      height={335}
      theme={theme}
    >
      <Window.Content scrollable>
        <Section>
          <Reagent
            reagents={reagents}
            selected={selectedReagent}
            maxVolume={maxVolume} />
        </Section>
      </Window.Content>
    </Window>
  );
};

const Reagent = (props, context) => {
  const { act, data } = useBackend(context);
  const { reagents, selected, maxVolume } = props;
  if (reagents.length === 0) {
    return (
      <NoticeBox>
        No reagents available!
      </NoticeBox>
    );
  }
  return reagents.map(reagent => (
    <Button
      key={reagent.id}
      icon="tint"
      width="150px"
      lineHeight={1.75}
      content={reagent.name}
      color={reagent.name === selected ?'green' : 'default'}
      onClick={() => act(reagent.name)} />
  ));
};
