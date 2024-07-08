import { Button, NoticeBox, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type BorgShakerContext = {
  minVolume: number;
  theme: string;
  sodas: Reagent[];
  alcohols: Reagent[];
  selectedReagent: string;
};

type Reagent = {
  name: string;
  volume: number;
  description: string;
};

export const BorgShaker = (props) => {
  const { data } = useBackend<BorgShakerContext>();
  const { theme, minVolume, sodas, alcohols, selectedReagent } = data;

  const dynamicHeight =
    Math.ceil(sodas.length / 4) * 23 +
    Math.ceil(alcohols.length / 4) * 23 +
    140;

  return (
    <Window width={650} height={dynamicHeight} theme={theme}>
      <Window.Content>
        <Section title={'Non-Alcoholic'}>
          <ReagentDisplay
            reagents={sodas}
            selected={selectedReagent}
            minimum={minVolume}
          />
        </Section>
        <Section title={'Alcoholic'}>
          <ReagentDisplay
            reagents={alcohols}
            selected={selectedReagent}
            minimum={minVolume}
          />
        </Section>
      </Window.Content>
    </Window>
  );
};

const ReagentDisplay = (props) => {
  const { act } = useBackend();
  const { reagents, selected, minimum } = props;
  if (reagents.length === 0) {
    return <NoticeBox>No reagents available!</NoticeBox>;
  }
  return reagents.map((reagent) => (
    <Button
      key={reagent.id}
      icon="tint"
      width="150px"
      lineHeight={1.75}
      content={reagent.name}
      color={reagent.name === selected ? 'green' : 'default'}
      disabled={reagent.volume < minimum}
      onClick={() => act(reagent.name)}
    />
  ));
};
