import { useBackend } from '../backend';
import { Button, NoticeBox, Section } from '../components';
import { Window } from '../layouts';

export const BorgShaker = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    theme,
    minimumVolume,
    sodas,
    alcohols,
    selectedReagent,
  } = data;
  return (
    <Window
      width={650}
      height={440}
      theme={theme}
    >
      <Window.Content scrollable>
        <Section title={'Non-Alcoholic'}>
          <Reagent
            reagents={sodas}
            selected={selectedReagent}
            minimum={minimumVolume} />
        </Section>
        <Section title={'Alcoholic'}>
          <Reagent
            reagents={alcohols}
            selected={selectedReagent}
            minimum={minimumVolume} />
        </Section>
      </Window.Content>
    </Window>
  );
};

const Reagent = (props, context) => {
  const { act, data } = useBackend(context);
  const { reagents, selected, minimum } = props;
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
      color={reagent.name === selected ? 'green': 'default'}
      disabled={reagent.volume < minimum}
      onClick={() => act(reagent.name)} />
  ));
};
