import { capitalizeFirst, decodeHtmlEntities } from 'common/string';
import { useBackend, useLocalState } from 'tgui/backend';
import { Box, Button, Input, LabeledList, NoticeBox, Section, Stack, Tabs, Tooltip } from 'tgui/components';
import { getColor } from './helpers';
import { Data } from './types';
import { SymptomDisplay } from './Symptom';

/** Displays info for the loaded blood, if any */
export const SpecimenDisplay = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const [tab, setTab] = useLocalState(context, 'tab', 0);
  const { is_ready, viruses = [] } = data;
  const virus = viruses[tab];
  if (!viruses?.length || !virus) {
    return <NoticeBox>Nothing detected.</NoticeBox>;
  }

  return (
    <Section
      fill
      scrollable
      title="Specimen"
      buttons={
        <Stack>
          {viruses.length > 1 && (
            <Stack.Item>
              <VirusTabs tab={tab} setTab={setTab} />
            </Stack.Item>
          )}
          <Stack.Item>
            <Button
              icon="flask"
              content="Create culture bottle"
              disabled={!is_ready}
              onClick={() =>
                act('create_culture_bottle', {
                  index: virus.index,
                })
              }
            />
          </Stack.Item>
        </Stack>
      }>
      <Stack fill vertical>
        <Stack.Item>
          <VirusDisplay virus={virus} />
        </Stack.Item>
        <Stack.Item>
          {virus?.symptoms && <SymptomDisplay symptoms={virus.symptoms} />}
        </Stack.Item>
      </Stack>
    </Section>
  );
};

/**
 * Virus Tab display - changes the tab for virus info
 * Whenever the tab changes, the virus info is updated
 */
const VirusTabs = (props, context) => {
  const { data } = useBackend<Data>(context);
  const { tab, setTab } = props;
  const { viruses = [] } = data;

  return (
    <Tabs>
      {viruses.map((virus, index) => {
        return (
          <Tabs.Tab
            selected={tab === index}
            onClick={() => setTab(index)}
            key={index}>
            {virus.name}
          </Tabs.Tab>
        );
      })}
    </Tabs>
  );
};

/**
 * Displays info about the virus. Child elements display
 * the virus's traits and descriptions.
 */
const VirusDisplay = (props, context) => {
  const { virus } = props;

  return (
    <Stack fill>
      <Stack.Item grow={3}>
        <VirusTextInfo virus={virus} />
      </Stack.Item>
      {virus.is_adv && (
        <>
          <Stack.Divider />
          <Stack.Item grow={1}>
            <VirusTraitInfo virus={virus} />
          </Stack.Item>
        </>
      )}
    </Stack>
  );
};

/** Displays the description, name and other info for the virus. */
const VirusTextInfo = (props, context) => {
  const { act } = useBackend<Data>(context);
  const {
    virus: { agent, can_rename, cure, description, index, name, spread },
  } = props;
  return (
    <LabeledList>
      <LabeledList.Item label="Name">
        {can_rename ? (
          <Input
            placeholder="Input a name"
            value={name === 'Unknown' ? '' : name}
            onChange={(_, value) =>
              act('rename_disease', {
                index: index,
                name: value,
              })
            }
          />
        ) : (
          <Box color="bad">{decodeHtmlEntities(name)}</Box>
        )}
      </LabeledList.Item>
      <LabeledList.Item label="Description">{description}</LabeledList.Item>
      <LabeledList.Item label="Agent">
        {capitalizeFirst(agent)}
      </LabeledList.Item>
      <LabeledList.Item label="Spread">{spread}</LabeledList.Item>
      <LabeledList.Item label="Possible Cure">{cure}</LabeledList.Item>
    </LabeledList>
  );
};

/**
 * Displays the traits of the virus. This could be iterated over
 * with object.keys but you would need a helper function for the tooltips.
 * I would rather hard code it here.
 */
const VirusTraitInfo = (props, context) => {
  const {
    virus: { resistance, stage_speed, stealth, transmission },
  } = props;

  return (
    <Section title="Statistics">
      <LabeledList>
        <Tooltip content="Decides the cure complexity.">
          <LabeledList.Item color={getColor(resistance)} label="Resistance">
            {resistance}
          </LabeledList.Item>
        </Tooltip>
        <Tooltip content="Symptomic progression.">
          <LabeledList.Item color={getColor(stage_speed)} label="Stage speed">
            {stage_speed}
          </LabeledList.Item>
        </Tooltip>
        <Tooltip content="Detection difficulty from medical equipment.">
          <LabeledList.Item color={getColor(stealth)} label="Stealth">
            {stealth}
          </LabeledList.Item>
        </Tooltip>
        <Tooltip content="Decides the spread type.">
          <LabeledList.Item
            color={getColor(transmission)}
            label="Transmissibility">
            {transmission}
          </LabeledList.Item>
        </Tooltip>
      </LabeledList>
    </Section>
  );
};
