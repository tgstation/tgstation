import { useState } from 'react';
import {
  Box,
  Button,
  Dropdown,
  Input,
  Knob,
  NumberInput,
  Section,
  Stack,
  TextArea,
  Tooltip,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  faxes: string[];
  stamps: string[];
};

const paperNameOptions = [
  'Nanotrasen Official Report',
  'Syndicate Report',
] as const;

const fromWhoOptions = ['Nanotrasen', 'Syndicate'] as const;

export function AdminFax(props) {
  const { act, data } = useBackend<Data>();
  const { faxes = [], stamps = [] } = data;

  const [fax, setFax] = useState('');
  const [saved, setSaved] = useState(false);
  const [paperName, setPaperName] = useState('');
  const [fromWho, setFromWho] = useState('');
  const [rawText, setRawText] = useState('');
  const [stamp, setStamp] = useState('');
  const [stampCoordX, setStampCoordX] = useState(0);
  const [stampCoordY, setStampCoordY] = useState(0);
  const [stampAngle, setStampAngle] = useState(0);

  if (stamp && stamps[0] !== 'None') {
    stamps.unshift('None');
  }

  return (
    <Window title="Admin Fax Panel" width={400} height={675} theme="admin">
      <Window.Content scrollable>
        <Section
          title="Fax Menu"
          buttons={
            <Button
              icon="arrow-up"
              disabled={!fax}
              onClick={() =>
                act('follow', {
                  faxName: fax,
                })
              }
            >
              Follow
            </Button>
          }
        >
          <Dropdown
            placeholder="Choose fax machine..."
            fluid
            selected={fax}
            options={faxes}
            onSelected={setFax}
          />
        </Section>
        <Section
          title="Paper"
          buttons={
            <Button
              icon="eye"
              disabled={!saved}
              onClick={() =>
                act('preview', {
                  faxName: fax,
                })
              }
            >
              Preview
            </Button>
          }
        >
          <Stack fill vertical>
            <Stack.Item>
              <Input
                placeholder="Paper name..."
                value={paperName}
                fluid
                onChange={setPaperName}
              />
            </Stack.Item>
            <Stack.Item>
              <SourceButtons
                stateSetter={setPaperName}
                options={paperNameOptions}
                tooltip="What is written on the top of the fax paper?"
              />
            </Stack.Item>
            <Stack.Divider />
            <Stack.Item>
              <Input
                placeholder="From who..."
                value={fromWho}
                fluid
                onChange={setFromWho}
              />
            </Stack.Item>
            <Stack.Item>
              <SourceButtons
                stateSetter={setFromWho}
                options={fromWhoOptions}
                tooltip="What was written in fax log?"
              />
            </Stack.Item>
            <Stack.Divider />
            <Stack.Item>
              <TextArea
                placeholder="Your message here..."
                height="200px"
                fluid
                value={rawText}
                onChange={setRawText}
              />
            </Stack.Item>
            <Stack.Divider />
            <Stack.Item>
              <Dropdown
                fluid
                options={stamps}
                selected="Choose stamp(optional)"
                onSelected={(value) => {
                  if (value === 'None') {
                    setStamp('');
                    stamps.shift();
                  } else {
                    setStamp(value);
                  }
                }}
              />
            </Stack.Item>
            <Stack.Item textAlign="center">
              {stamp && (
                <>
                  <h4>
                    X Coordinate:{' '}
                    <NumberInput
                      step={1}
                      width="45px"
                      minValue={0}
                      maxValue={300}
                      value={stampCoordX}
                      onChange={(v) => setStampCoordX(v)}
                    />
                  </h4>

                  <h4>
                    Y Coordinate:{' '}
                    <NumberInput
                      step={1}
                      width="45px"
                      minValue={0}
                      maxValue={400}
                      value={stampCoordY}
                      onChange={(v) => setStampCoordY(v)}
                    />
                  </h4>

                  <Box textAlign="center">
                    <h4>Rotation Angle</h4>
                    <Knob
                      size={1.5}
                      value={stampAngle}
                      minValue={0}
                      maxValue={360}
                      animated={false}
                      onChange={(_event, value) => setStampAngle(value)}
                    />
                  </Box>
                </>
              )}
            </Stack.Item>
          </Stack>
        </Section>
        <Section title="Actions">
          <Button
            disabled={!saved || !fax}
            icon="paper-plane"
            onClick={() =>
              act('send', {
                faxName: fax,
              })
            }
          >
            Send
          </Button>
          <Button
            icon="floppy-disk"
            color="green"
            onClick={() => {
              setSaved(true);
              act('save', {
                faxName: fax,
                paperName: paperName,
                rawText: rawText,
                stamp: stamp,
                stampX: stampCoordX,
                stampY: stampCoordY,
                stampAngle: stampAngle,
                fromWho: fromWho,
              });
            }}
          >
            Save
          </Button>
          <Button
            disabled={!saved}
            icon="circle-plus"
            onClick={() =>
              act('createPaper', {
                faxName: fax,
              })
            }
          >
            Create paper
          </Button>
        </Section>
      </Window.Content>
    </Window>
  );
}

type SourceButtonsProps = {
  stateSetter: (source: string) => void;
  options: readonly string[];
  tooltip: string;
};

function SourceButtons(props: SourceButtonsProps) {
  const { stateSetter, options, tooltip } = props;

  return (
    <Tooltip content={tooltip}>
      <Stack fill>
        <Stack.Item grow>
          <Button fluid icon="n" onClick={() => stateSetter(options[0])}>
            Nanotrasen
          </Button>
        </Stack.Item>
        <Stack.Item grow>
          <Button fluid icon="s" onClick={() => stateSetter(options[1])}>
            Syndicate
          </Button>
        </Stack.Item>
      </Stack>
    </Tooltip>
  );
}
