/* eslint-disable max-len */
import { useBackend, useLocalState } from '../backend';
import { BlockQuote, Box, Button, Flex, Icon, Modal, NumberInput, Section, Slider, LabeledList, NoticeBox, ProgressBar, TimeDisplay, Stack } from '../components';
import { Window } from '../layouts';
import { resolveAsset } from '../assets';
import { formatTime } from '../format';
import { toKeyedArray } from '../../common/collections';


type SiteData = {
  name : string,
  ref: string,
  description : string,
  distance : number,
  band_info : Record<string, string>,
  revealed : boolean,
}

type ScanData = {
  scan_power : number,
  point_scan_eta : number,
  deep_scan_eta : number,
  point_scan_complete : boolean,
  deep_scan_complete : boolean
  site_data : SiteData
}

const ScanFailedModal = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Modal>
      <Flex direction="column">
        <Flex.Item>
          <Box color="bad">SCAN FAILURE!</Box>
        </Flex.Item>
        <Flex.Item>
          <Button onClick={() => act("confirm_fail")}>Confirm</Button>
        </Flex.Item>
      </Flex>
    </Modal>);
};

const ScanSelectionSection = (props, context) => {
  const { act, data } = useBackend<ScanData>(context);
  const {
    scan_power,
    point_scan_eta,
    deep_scan_eta,
    point_scan_complete,
    deep_scan_complete,
    site_data,
  } = data;
  const site = site_data;

  const point_cost = scan_power > 0 ? formatTime(point_scan_eta, "short") : "∞";
  const deep_cost = scan_power > 0 ? formatTime(deep_scan_eta, "short") : "∞";
  const scan_availible = !point_scan_complete || !deep_scan_complete;
  return (
    <>
      {scan_availible && (
        <Section title="Scans">
          {!point_scan_complete && (
            <Section title="Point Scan">
              <BlockQuote>Point scan performs rudimentary scan of the site, revealing it&apos;s general characteristics.</BlockQuote>
              <Box><Button disabled={scan_power <= 0} onClick={() => act("start_point_scan")}>Scan</Button> <Box inline pl={3}>Estimated Time: {point_cost}.</Box></Box>
            </Section>
          )}
          {!deep_scan_complete && (
            <Section title="Deep Scan">
              <BlockQuote>Deep scan performs full scan of the site, reavling all details.</BlockQuote>
              <Box><Button disabled={scan_power <= 0} onClick={() => act("start_deep_scan")}>Scan</Button> <Box inline pl={3}>Estimated Time: {deep_cost}.</Box></Box>
            </Section>
          )}
        </Section>
      )}
      <Section title="Site Data" buttons={<Button onClick={() => act("select_site", { "site_ref": null })}>Back</Button>}>
        <LabeledList>
          <LabeledList.Item label="Name">{site.name}</LabeledList.Item>
          <LabeledList.Item label="Description">
            {site.revealed ? site.description : "No Data"}
          </LabeledList.Item>
          <LabeledList.Item label="Distance">{site.distance}</LabeledList.Item>
          <LabeledList.Divider />
          <LabeledList.Item label="Spectrography Data" />
          <LabeledList.Divider />
          {Object.keys(site.band_info).map(band => (<LabeledList.Item key={band} label={band}>{site.band_info[band]}</LabeledList.Item>))}
        </LabeledList>
      </Section>
    </>);
};

type ScanInProgressData = {
  scan_time : number,
  scan_power : number,
  scan_description : string,
}

const ScanInProgressModal = (props, context) => {
  const { act, data } = useBackend<ScanInProgressData>(context);
  const {
    scan_time,
    scan_power,
    scan_description,
  } = data;

  return (
    <Modal>
      <NoticeBox>Scan in Progress!</NoticeBox>
      <Box color="danger" />
      <LabeledList>
        <LabeledList.Item
          label="Scan summary">
          {scan_description}
        </LabeledList.Item>
        <LabeledList.Item
          label="Time left">
          {formatTime(scan_time)}
        </LabeledList.Item>
        <LabeledList.Item
          label="Scanning array power">
          {scan_power}
        </LabeledList.Item>
      </LabeledList>
      <Button.Confirm content="STOP SCAN" onClick={() => act("stop_scan")} />
    </Modal>);
};


type ExoscannerConsoleData = {
  scan_in_progress : boolean,
  scan_power : number,
  possible_sites : Array<SiteData>,
  wide_scan_eta : number,
  selected_site : string,
  failed : boolean,
  scan_conditions : Array<string>,
}

export const ExoscannerConsole = (props, context) => {
  const { act, data } = useBackend<ExoscannerConsoleData>(context);
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

  const MainContent = selected_site ? (<ScanSelectionSection site_ref={selected_site} />) : (
    <>
      <Section title="Configure Wide Scan">
        <Stack>
          <Stack.Item>
            <BlockQuote>Broad spectrum scan looking for anything not matching known start charts.</BlockQuote>
          </Stack.Item>
          <Stack.Item>
            Cost estimate: {scan_power > 0 ? formatTime(wide_scan_eta, "short") : "∞ minutes"}
          </Stack.Item>
          <Stack.Item>
            <Button disabled={!can_start_wide_scan} onClick={() => act("start_wide_scan")}>Scan</Button>
          </Stack.Item>
        </Stack>
      </Section>
      <Section title="Configure Targeted Scans" buttons={<Button onClick={() => act("open_experiments")} icon="tasks">View Experiments</Button>}>
        <Stack vertical>
          {possible_sites.map(site => (<Stack.Item key={site.ref}><Button onClick={() => act("select_site", { "site_ref": site.ref })}>{site.name}</Button></Stack.Item>))}
        </Stack>
      </Section>
    </>);

  return (
    <Window>
      {!!scan_in_progress && (<ScanInProgressModal />)}
      {!!failed && (<ScanFailedModal />)}
      <Window.Content>
        <Section title="Available array power">
          {scan_conditions && scan_conditions.map(condition => <NoticeBox key={condition} warning>{condition}</NoticeBox>)}
          <Box>
            {scan_power > 0 ? Array(scan_power).fill((<Icon name="satellite-dish" size={3} />)) : "No properly configured scanner arrays detected."}
          </Box>
        </Section>
        {MainContent}
      </Window.Content>
    </Window>);
};
