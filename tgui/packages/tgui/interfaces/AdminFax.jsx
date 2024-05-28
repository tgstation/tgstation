import { useState } from 'react';

import { useBackend } from '../backend';
import {
  Box,
  Button,
  Divider,
  Dropdown,
  Input,
  Knob,
  NumberInput,
  Section,
  TextArea,
  Tooltip,
} from '../components';
import { Window } from '../layouts';

export const AdminFax = (props) => {
  return (
    <Window title="Admin Fax Panel" width={400} height={675} theme="admin">
      <Window.Content>
        <FaxMainPanel />
      </Window.Content>
    </Window>
  );
};

export const FaxMainPanel = (props) => {
  const { act, data } = useBackend();

  const [fax, setFax] = useState('');
  const [saved, setSaved] = useState(false);
  const [paperName, setPaperName] = useState('');
  const [fromWho, setFromWho] = useState('');
  const [rawText, setRawText] = useState('');
  const [stamp, setStamp] = useState('');
  const [stampCoordX, setStampCoordX] = useState(0);
  const [stampCoordY, setStampCoordY] = useState(0);
  const [stampAngle, setStampAngle] = useState(0);
  if (stamp && data.stamps[0] !== 'None') {
    data.stamps.unshift('None');
  }
  return (
    <div className="faxmenu">
      <Section
        title="Fax Menu"
        buttons={
          <Box>
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
          </Box>
        }
      >
        <Box fontSize="13px">
          <Dropdown
            textAlign="center"
            placeholder="Choose fax machine..."
            width="100%"
            selected={fax}
            options={data.faxes}
            onSelected={(value) => setFax(value)}
          />
        </Box>
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
        <Box fontSize="14px">
          <Input
            mb="5px"
            placeholder="Paper name..."
            value={paperName}
            width="100%"
            onChange={(_, v) => setPaperName(v)}
          />
          <Button
            icon="n"
            mr="7px"
            width="49%"
            onClick={() => setPaperName('Nanotrasen Official Report')}
          >
            Nanotrasen
          </Button>
          <Button
            icon="s"
            width="49%"
            onClick={() => setPaperName('Syndicate Report')}
          >
            Syndicate
          </Button>
        </Box>
        <Divider />
        <Box fontSize="14px" mt="5px">
          <Tooltip content="What was writen in fax log?">
            <Input
              mb="5px"
              placeholder="From who..."
              tooltip="Name what be user in fax history"
              value={fromWho}
              width="100%"
              onChange={(_, v) => setFromWho(v)}
            />
          </Tooltip>
          <Button
            icon="n"
            mr="7px"
            width="49%"
            onClick={() => setFromWho('Nanotrasen')}
          >
            Nanotrasen
          </Button>
          <Button icon="s" width="49%" onClick={() => setFromWho('Syndicate')}>
            Syndicate
          </Button>
        </Box>
        <Divider />
        <Box mt="5px">
          <TextArea
            placeholder="Your message here..."
            height="200px"
            value={rawText}
            onChange={(e, value) => {
              setRawText(value);
            }}
          />
        </Box>
        <Divider />
        <Box mt="5px">
          <Dropdown
            width="100%"
            options={data.stamps}
            selected="Choose stamp(optional)"
            onSelected={(v) => {
              if (v === 'None') {
                setStamp('');
                data.stamps.shift();
              } else {
                setStamp(v);
              }
            }}
          />
          {stamp && (
            <Box textAlign="center">
              <h4>
                X Coordinate:{' '}
                <NumberInput
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
                  width="45px"
                  minValue={0}
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
                  onChange={(_, v) => setStampAngle(v)}
                />
              </Box>
            </Box>
          )}
        </Box>
      </Section>
      <Section title="Actions">
        <Box>
          <Button
            disabled={!saved || !fax}
            icon="paper-plane"
            mr="9px"
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
            mr="9px"
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
        </Box>
      </Section>
    </div>
  );
};
