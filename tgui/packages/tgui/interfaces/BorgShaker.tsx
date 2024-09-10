import { Button, NoticeBox, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type BorgShakerContext = {
  minVolume: number;
  theme: string;
  sodas: Reagent[];
  alcohols: Reagent[];
  selectedReagent: string;
  reagentSearchContainer: ContainerPreference;
  apparatusHasItem: boolean;
};

type Reagent = {
  name: string;
  volume: number;
  description: string;
};

enum ContainerPreference {
  BeverageApparatus = 'beverage_apparatus',
  InternalBeaker = 'internal_beaker',
}

export const BorgShaker = (props) => {
  const { act, data } = useBackend<BorgShakerContext>();
  const { theme, minVolume, sodas, alcohols, selectedReagent } = data;

  const dynamicHeight =
    Math.ceil(sodas.length / 4) * 23 +
    Math.ceil(alcohols.length / 4) * 23 +
    140;

  return (
    <Window width={650} height={dynamicHeight} theme={theme}>
      <Window.Content>
        <Section
          title={'Non-Alcoholic'}
          buttons={
            <>
              <Button
                icon="book"
                content={'Reaction search'}
                disabled={
                  data.reagentSearchContainer !==
                    ContainerPreference.InternalBeaker && !data.apparatusHasItem
                }
                tooltip={
                  'Look up recipes and reagents! Choose a container source'
                }
                tooltipPosition="bottom-start"
                onClick={() => act('reaction_lookup')}
              />
              <Button
                icon="flask"
                width="23px"
                color={
                  data.reagentSearchContainer ===
                  ContainerPreference.InternalBeaker
                    ? 'green'
                    : 'default'
                }
                tooltip="Search source: Internal Beaker"
                onClick={() => {
                  act('set_preferred_container', {
                    value: ContainerPreference.InternalBeaker,
                  });
                }}
              />
              <Button
                icon="vial"
                width="24px"
                tooltip="Search source: Beverage Apparatus"
                color={
                  data.reagentSearchContainer ===
                  ContainerPreference.BeverageApparatus
                    ? 'green'
                    : 'default'
                }
                onClick={() => {
                  act('set_preferred_container', {
                    value: ContainerPreference.BeverageApparatus,
                  });
                }}
              />
            </>
          }
        >
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
