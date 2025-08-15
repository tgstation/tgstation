import {
  BlockQuote,
  Box,
  Button,
  Icon,
  LabeledList,
  Modal,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';
import { formatTime } from 'tgui-core/format';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type SiteData = {
  name: string;
  ref: string;
  description: string;
  distance: number;
  band_info: Record<string, string>;
  revealed: boolean;
};

type ScanData = {
  scan_power: number;
  point_scan_eta: number;
  deep_scan_eta: number;
  point_scan_complete: boolean;
  deep_scan_complete: boolean;
  site_data: SiteData;
};

const ScanFailedModal = (props) => {
  const { act } = useBackend();
  return (
    <Modal>
      <Stack fill vertical>
        <Stack.Item>
          <Box color="bad">SCAN FAILURE!</Box>
        </Stack.Item>
        <Stack.Item>
          <Button content="Confirm" onClick={() => act('confirm_fail')} />
        </Stack.Item>
      </Stack>
    </Modal>
  );
};

const ScanSelectionSection = (props) => {
  const { act, data } = useBackend<ScanData>();
  const {
    scan_power,
    point_scan_eta,
    deep_scan_eta,
    point_scan_complete,
    deep_scan_complete,
    site_data,
  } = data;
  const site = site_data;

  const point_cost = scan_power > 0 ? formatTime(point_scan_eta, 'short') : '∞';
  const deep_cost = scan_power > 0 ? formatTime(deep_scan_eta, 'short') : '∞';
  const scan_available = !point_scan_complete || !deep_scan_complete;
  return (
    <Stack vertical fill>
      <Stack.Item grow>
        <Section
          fill
          title="Site Data"
          buttons={
            <Button
              content="Back"
              onClick={() => act('select_site', { site_ref: null })}
            />
          }
        >
          <LabeledList>
            <LabeledList.Item label="Name">{site.name}</LabeledList.Item>
            <LabeledList.Item label="Description">
              {site.revealed ? site.description : 'No Data'}
            </LabeledList.Item>
            <LabeledList.Item label="Distance">
              {site.distance}
            </LabeledList.Item>
            <LabeledList.Divider />
            <LabeledList.Item label="Spectrography Data" />
            <LabeledList.Divider />
            {Object.keys(site.band_info).map((band) => (
              <LabeledList.Item key={band} label={band}>
                {site.band_info[band]}
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>
      </Stack.Item>
      {scan_available && (
        <Stack.Item>
          <Section fill title="Scans">
            {!point_scan_complete && (
              <Section title="Point Scan">
                <BlockQuote>
                  Point scan performs rudimentary scan of the site, revealing
                  its general characteristics.
                </BlockQuote>
                <Box>
                  <Button
                    content="Scan"
                    disabled={scan_power <= 0}
                    onClick={() => act('start_point_scan')}
                  />
                  <Box inline pl={3}>
                    Estimated Time: {point_cost}.
                  </Box>
                </Box>
              </Section>
            )}
            {!deep_scan_complete && (
              <Section title="Deep Scan">
                <BlockQuote>
                  Deep scan performs full scan of the site, revealing all
                  details.
                </BlockQuote>
                <Box>
                  <Button
                    content="Scan"
                    disabled={scan_power <= 0}
                    onClick={() => act('start_deep_scan')}
                  />
                  <Box inline pl={3}>
                    Estimated Time: {deep_cost}.
                  </Box>
                </Box>
              </Section>
            )}
          </Section>
        </Stack.Item>
      )}
    </Stack>
  );
};

type ScanInProgressData = {
  scan_time: number;
  scan_power: number;
  scan_description: string;
};

const ScanInProgressModal = (props) => {
  const { act, data } = useBackend<ScanInProgressData>();
  const { scan_time, scan_power, scan_description } = data;

  return (
    <Modal ml={1}>
      <NoticeBox>Scan in Progress!</NoticeBox>
      <Box color="danger" />
      <LabeledList>
        <LabeledList.Item label="Scan summary">
          {scan_description}
        </LabeledList.Item>
        <LabeledList.Item label="Time left">
          {formatTime(scan_time)}
        </LabeledList.Item>
        <LabeledList.Item label="Scanning array power">
          {scan_power}
        </LabeledList.Item>
        <LabeledList.Item label="Emergency Stop">
          <Button.Confirm
            content="STOP SCAN"
            color="red"
            icon="times"
            onClick={() => act('stop_scan')}
          />
        </LabeledList.Item>
      </LabeledList>
    </Modal>
  );
};

type ExoscannerConsoleData = {
  scan_in_progress: boolean;
  scan_power: number;
  possible_sites: Array<SiteData>;
  wide_scan_eta: number;
  selected_site: string;
  failed: boolean;
  scan_conditions: Array<string>;
};

export const ExoscannerConsole = (props) => {
  const { act, data } = useBackend<ExoscannerConsoleData>();
  const {
    scan_in_progress,
    scan_power,
    possible_sites = [],
    wide_scan_eta,
    selected_site,
    failed,
    scan_conditions = [],
  } = data;

  const can_start_wide_scan = scan_power > 0;

  return (
    <Window width={550} height={600}>
      {!!scan_in_progress && <ScanInProgressModal />}
      {!!failed && <ScanFailedModal />}
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Section fill title="Available array power">
              <Stack>
                <Stack.Item grow>
                  {(scan_power > 0 && (
                    <>
                      <Box pr={1} inline fontSize={2}>
                        {scan_power}
                      </Box>
                      <Icon name="satellite-dish" size={3} />
                    </>
                  )) ||
                    'No properly configured scanner arrays detected.'}
                </Stack.Item>
              </Stack>
              <Section title="Special Scan Condtions">
                {scan_conditions?.map((condition) => (
                  <NoticeBox key={condition}>{condition}</NoticeBox>
                ))}
              </Section>
            </Section>
          </Stack.Item>
          {!!selected_site && (
            <Stack.Item grow>
              <ScanSelectionSection site_ref={selected_site} />
            </Stack.Item>
          )}
          {!selected_site && (
            <>
              <Stack.Item>
                <Section
                  buttons={
                    <Button
                      icon="search"
                      disabled={!can_start_wide_scan}
                      onClick={() => act('start_wide_scan')}
                    >
                      Scan
                    </Button>
                  }
                  fill
                  title="Configure Wide Scan"
                >
                  <Stack>
                    <Stack.Item>
                      <BlockQuote>
                        Broad spectrum scan looking for anything not matching
                        known start charts.
                      </BlockQuote>
                    </Stack.Item>
                    <Stack.Item>
                      Cost estimate:{' '}
                      {scan_power > 0
                        ? formatTime(wide_scan_eta, 'short')
                        : '∞ minutes'}
                    </Stack.Item>
                  </Stack>
                </Section>
              </Stack.Item>
              <Stack.Item grow>
                <Section
                  fill
                  title="Configure Targeted Scans"
                  scrollable
                  buttons={
                    <Button
                      content="View Experiments"
                      onClick={() => act('open_experiments')}
                      icon="tasks"
                    />
                  }
                >
                  <Stack vertical>
                    {possible_sites.map((site) => (
                      <Stack.Item key={site.ref}>
                        <Button
                          content={site.name}
                          onClick={() =>
                            act('select_site', { site_ref: site.ref })
                          }
                        />
                      </Stack.Item>
                    ))}
                  </Stack>
                </Section>
              </Stack.Item>
            </>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};
