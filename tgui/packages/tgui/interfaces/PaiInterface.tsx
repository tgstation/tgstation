import { useBackend } from '../backend';
import { Button, Section, Stack } from '../components';
import { Window } from '../layouts';
import { logger } from '../logging';

type PaiInterfaceData = {
  directives: string[];
  master: Master;
  ram: number;
  software: SoftwareList;
};

type Master = {
  name: string;
  dna: string;
};

type PDA = {
  power: number;
  silent: number;
};

type SoftwareList = {
  available: Available;
  installed: string[];
};

type Available = {
  [key: string]: number;
};

export const PaiInterface = (props, context) => {
  const { act, data } = useBackend<PaiInterfaceData>(context);
  logger.log(data);
  return (
    <Window title="PAI Software Interface" width={400} height={550}>
      <Window.Content>
        <Stack>
          <Section title="Stuff">
            <Button>OK</Button>
          </Section>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const SoftwareDisplay = (props, context) => {
  const { act, data } = useBackend<PaiInterfaceData>(context);
  const { software } = data;
  return <Section>OK</Section>;
};

const DirectivesDisplay = (props, context) => {
  const { act, data } = useBackend<PaiInterfaceData>(context);
  const { directives, master } = data;
  return <Section>OK</Section>;
};
