import { sortBy } from 'common/collections';
import { useBackend, useLocalState } from '../backend';
import { AnimatedNumber, Box, Button, LabeledList, ProgressBar, Section } from '../components';
import { Window } from '../layouts';

export const PortableChemMixer = (props, context) => {
  const { act, data } = useBackend(context);
  const { recipeReagents = [] } = data;
  const [hasCol, setHasCol] = useLocalState(context, 'has_col', false);
  const beakerTransferAmounts = data.beakerTransferAmounts || [];
  const beakerContents = data.beakerContents || [];
  const chemicals = sortBy((chem) => chem.title)(data.chemicals);
  return (
    <Window width={565} height={650}>
      <Window.Content scrollable>
        <Section
          title="Status"
          buttons={
            <Button
              icon="cog"
              tooltip="Color code the reagents by pH"
              tooltipPosition="bottom-start"
              selected={hasCol}
              onClick={() => setHasCol(!hasCol)}
            />
          }>
          <LabeledList>
            <LabeledList.Item label="Energy">
              <ProgressBar
                value={data.energy / data.maxEnergy}>
                {data.energy + ' units'}
              </ProgressBar>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section
          title="Dispense"
          buttons={beakerTransferAmounts.map((amount) => (
            <Button
              key={amount}
              icon="plus"
              selected={amount === data.amount}
              content={amount}
              onClick={() =>
                act('amount', {
                  target: amount,
                })
              }
            />
          ))}>
          <Box mr={-1}>
            {data.battery.map((chemical) => (
              <Button
                key={chemical.id}
                icon="tint"
                width="129.5px"
                lineHeight={1.75}
                content={chemical.title}
                tooltip={'pH: ' + chemical.pH}
                backgroundColor={
                  recipeReagents.includes(chemical.id)
                    ? hasCol
                      ? 'black'
                      : 'green'
                    : hasCol
                      ? chemical.pHCol
                      : 'default'
                }
                onClick={() =>
                  act('battery', {
                    reagent: chemical.id,
                  })
                }
              />
            ))}
          </Box>
        </Section>
        <Section
          title="Storage"
          buttons={beakerTransferAmounts.map((amount) => (
            <Button
              key={amount}
              icon="plus"
              selected={amount === data.amount}
              content={amount}
              onClick={() =>
                act('amount', {
                  target: amount,
                })
              }
            />
          ))}>
          <Box mr={-1}>
            {chemicals.map((chemical) => (
              <Button
                key={chemical.id}
                icon="tint"
                width="259px"
                lineHeight={1.75}
                content={`(${chemical.volume}) ${chemical.title}`}
                tooltip={'pH: ' + chemical.pH}
                backgroundColor={
                  recipeReagents.includes(chemical.id)
                    ? hasCol
                      ? 'black'
                      : 'green'
                    : hasCol
                      ? chemical.pHCol
                      : 'default'
                }
                onClick={() =>
                  act('storage', {
                    reagent: chemical.id,
                  })
                }
              />
            ))}
          </Box>
        </Section>
        <Section
          title="Disposal controls"
          buttons={beakerTransferAmounts.map((amount) => (
            <Button
              key={amount}
              icon="minus"
              content={amount}
              onClick={() => act('remove', { amount })}
            />
          ))}>
          <LabeledList>
            <LabeledList.Item
              label="Beaker"
              buttons={
                !!data.isBeakerLoaded && (
                  <Button
                    icon="eject"
                    content="Eject"
                    disabled={!data.isBeakerLoaded}
                    onClick={() => act('eject')}
                  />
                )
              }>
              {(data.isBeakerLoaded && (
                <>
                <AnimatedNumber initial={0} value={data.beakerCurrentVolume} />
                / {data.beakerMaxVolume} units
                </>
                )) ||
              'No beaker'}
            </LabeledList.Item>
            <LabeledList.Item label="Contents">
              <Box color="label">
                {(!data.isBeakerLoaded && 'N/A') ||
                  (beakerContents.length === 0 && 'Nothing')}
              </Box>
              {beakerContents.map((chemical) => (
                <Box key={chemical.name} color="label">
                  <AnimatedNumber initial={0} value={chemical.volume} /> units
                  of {chemical.name}
                </Box>
              ))}
              {beakerContents.length > 0 && !!data.showpH && (
                <Box>
                  pH:
                  <AnimatedNumber value={data.beakerCurrentpH} />
                </Box>
              )}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
