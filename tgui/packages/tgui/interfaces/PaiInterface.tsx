import { useBackend, useSharedState } from '../backend';
import {
  Button,
  LabeledList,
  Icon,
  ProgressBar,
  Section,
  Stack,
  Tabs,
  Tooltip,
} from '../components';
import { Window } from '../layouts';

type PaiInterfaceData = {
  directives: string;
  master: Master;
  pda: PDA;
  ram: number;
  software: Softwares;
};

type Master = {
  name: string;
  dna: string;
};

type PDA = {
  power: number;
  silent: number;
};

type Softwares = {
  available: Available;
  installed: string[];
};

type Available = {
  name: string;
  value: [value: number];
};

export const PaiInterface = (props, context) => {
  const [tab, setTab] = useSharedState(context, 'tab', 1);
  const setTabHandler = (tab: number) => {
    setTab(tab);
  };

  return (
    <Window title="PAI Software Interface v2.4" width={380} height={480}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <TabDisplay tab={tab} tabHandler={setTabHandler} />
          </Stack.Item>
          <Stack.Item grow>
            {tab === 1 && <SystemDisplay />}
            {tab === 2 && <AvailableDisplay />}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const TabDisplay = (props) => {
  const { tab, tabHandler } = props;

  return (
    <Tabs>
      <Tabs.Tab icon="list" onClick={() => tabHandler(1)} selected={tab === 1}>
        System
      </Tabs.Tab>
      <Tabs.Tab icon="list" onClick={() => tabHandler(2)} selected={tab === 2}>
        Download
      </Tabs.Tab>
    </Tabs>
  );
};

const SystemDisplay = () => {
  return (
    <Stack fill vertical>
      <Stack.Item grow>
        <SystemDirectives />
      </Stack.Item>
      <Stack.Item grow={2}>
        <SystemInstalled />
      </Stack.Item>
    </Stack>
  );
};

const SystemDirectives = (_, context) => {
  const { act, data } = useBackend<PaiInterfaceData>(context);
  const { directives, master } = data;

  return (
    <Section fill scrollable title="System Info">
      <LabeledList>
        <LabeledList.Item label="Master">
          {master.name || 'None'}
        </LabeledList.Item>
        <LabeledList.Item label="Signature">
          {master.dna || 'None'}
        </LabeledList.Item>
        <LabeledList.Item label="Directives">{directives}</LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const SystemInstalled = (_, context) => {
  const { act, data } = useBackend<PaiInterfaceData>(context);
  const { installed } = data.software;

  return (
    <Section fill scrollable title="Installed Software">
      {installed.map((software) => {
        return <Button key={software}>{software}</Button>;
      })}
    </Section>
  );
};

const AvailableDisplay = () => {
  return (
    <Section
      buttons={<AvailableMemory />}
      fill
      scrollable
      title="Available Software">
      <AvailableSoftware />
    </Section>
  );
};

const AvailableMemory = (_, context) => {
  const { data } = useBackend<PaiInterfaceData>(context);
  const { ram } = data;

  return (
    <Tooltip content="Available System Memory">
      <Stack>
        <Icon color="purple" mt={0.7} mr={1} name="microchip" />
        <ProgressBar
          minValue={0}
          maxValue={100}
          ranges={{
            good: [75, 100],
            average: [50, 75],
            bad: [0, 25],
          }}
          value={ram}
        />
      </Stack>
    </Tooltip>
  );
};

const AvailableSoftware = (_, context) => {
  const { act, data } = useBackend<PaiInterfaceData>(context);
  const { available, installed } = data.software;
  /** Converted to type: Available */
  let convertedList: Available[] = Object.keys(available).map((key) => {
    return {
      name: key,
      value: available[key],
    };
  });

  return (
    <LabeledList>
      {convertedList.map((software) => {
        return (
          <LabeledList.Item
            label={software.name.replace(/^\w/, (c) => c.toUpperCase())}
            key={software.name}
            buttons={
              <Stack fill>
                {installed.includes(software.toString()) && (
                  <Stack.Item>
                    <Icon mt={0.7} color="purple" name="microchip" />
                  </Stack.Item>
                )}
                <Stack.Item>
                  <Button
                    disabled={installed.includes(software.toString())}
                    fluid
                    width={5}>
                    {software.value}
                    <Icon ml={1} name="microchip" />
                  </Button>
                </Stack.Item>
              </Stack>
            }
          />
        );
      })}
    </LabeledList>
  );
};
