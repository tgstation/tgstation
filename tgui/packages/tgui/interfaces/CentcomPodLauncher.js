import { toFixed } from 'common/math';
import { classes } from 'common/react';
import { storage } from 'common/storage';
import { multiline } from 'common/string';
import { createUuid } from 'common/uuid';
import { Component, Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, ByondUi, Divider, Input, Knob, LabeledControls, NumberInput, Section, Stack } from '../components';
import { Window } from '../layouts';

const pod_grey = {
  color: 'grey',
};

const useCompact = context => {
  const [compact, setCompact] = useLocalState(context, 'compact', false);
  const toggleCompact = () => setCompact(!compact);
  return [compact, toggleCompact];
};

export const CentcomPodLauncher = (props, context) => {
  const [compact] = useCompact(context);
  return (
    <Window
      resizable
      key={'CPL_' + compact}
      title={compact
        ? "Use against Helen Weinstein"
        : "Supply Pod Menu (Use against Helen Weinstein)"}
      overflow="hidden"
      width={compact ? 435 : 730}
      height={compact ? 360 : 440}>
      <CentcomPodLauncherContent />
    </Window>
  );
};

const CentcomPodLauncherContent = (props, context) => {
  const [compact] = useCompact(context);
  return (
    <Window.Content>
      <Stack fill vertical>
        <Stack.Item shrink={0}>
          <PodStatusPage />
        </Stack.Item>
        <Stack.Item grow>
          <Stack fill>
            <Stack.Item grow shrink={0} basis="14.1em">
              <Stack fill vertical>
                <Stack.Item grow>
                  <PresetsPage />
                </Stack.Item>
                <Stack.Item>
                  <ReverseMenu />
                </Stack.Item>
                <Stack.Item>
                  <Section>
                    <LaunchPage />
                  </Section>
                </Stack.Item>
              </Stack>
            </Stack.Item>
            {!compact && (
              <Stack.Item grow={3}>
                <ViewTabHolder />
              </Stack.Item>
            )}
            <Stack.Item basis="8em">
              <Stack fill vertical>
                <Stack.Item>
                  <Bays />
                </Stack.Item>
                <Stack.Item grow>
                  <Timing />
                </Stack.Item>
                {!compact && (
                  <Stack.Item>
                    <Sounds />
                  </Stack.Item>
                )}
              </Stack>
            </Stack.Item>
            <Stack.Item basis="11em">
              <StylePage />
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Window.Content>
  );
};

const TABPAGES = [
  {
    title: 'View Pod',
    component: () => TabPod,
  },
  {
    title: 'View Bay',
    component: () => TabBay,
  },
  {
    title: 'View Dropoff Location',
    component: () => TabDrop,
  },
];

const REVERSE_OPTIONS = [
  {
    title: 'Mobs',
    icon: 'user',
  },
  {
    title: 'Unanchored\nObjects',
    key: 'Unanchored',
    icon: 'cube',
  },
  {
    title: 'Anchored\nObjects',
    key: 'Anchored',
    icon: 'anchor',
  },
  {
    title: 'Under-Floor',
    key: 'Underfloor',
    icon: 'eye-slash',
  },
  {
    title: 'Wall-Mounted',
    key: 'Wallmounted',
    icon: 'link',
  },
  {
    title: 'Floors',
    icon: 'border-all',
  },
  {
    title: 'Walls',
    icon: 'square',
  },
  {
    title: 'Mechs',
    key: 'Mecha',
    icon: 'truck',
  },
];

const DELAYS = [
  {
    title: 'Pre',
    tooltip: 'Time until pod gets to station',
  },
  {
    title: 'Fall',
    tooltip: 'Duration of pods\nfalling animation',
  },
  {
    title: 'Open',
    tooltip: 'Time it takes pod to open after landing',
  },
  {
    title: 'Exit',
    tooltip: 'Time for pod to\nleave after opening',
  },
];

const REV_DELAYS = [
  {
    title: 'Pre',
    tooltip: 'Time until pod appears above dropoff point',
  },
  {
    title: 'Fall',
    tooltip: 'Duration of pods\nfalling animation',
  },
  {
    title: 'Open',
    tooltip: 'Time it takes pod to open after landing',
  },
  {
    title: 'Exit',
    tooltip: 'Time for pod to\nleave after opening',
  },
];

const SOUNDS = [
  {
    title: 'Fall',
    act: 'fallingSound',
    tooltip: 'Plays while pod falls, timed\nto end when pod lands',
  },
  {
    title: 'Land',
    act: 'landingSound',
    tooltip: 'Plays after pod lands',
  },
  {
    title: 'Open',
    act: 'openingSound',
    tooltip: 'Plays when pod opens',
  },
  {
    title: 'Exit',
    act: 'leavingSound',
    tooltip: 'Plays when pod leaves',
  },
];

const STYLES = [
  { title: 'Standard' },
  { title: 'Advanced' },
  { title: 'Nanotrasen' },
  { title: 'Syndicate' },
  { title: 'Deathsquad' },
  { title: 'Cultist' },
  { title: 'Missile' },
  { title: 'Syndie Missile' },
  { title: 'Supply Box' },
  { title: 'Clown Pod' },
  { title: 'Fruit' },
  { title: 'Invisible' },
  { title: 'Gondola' },
  { title: 'Seethrough' },
];

const BAYS = [
  { title: '1' },
  { title: '2' },
  { title: '3' },
  { title: '4' },
  { title: 'ERT' },
];

const EFFECTS_LOAD = [
  {
    title: 'Launch All Turfs',
    icon: 'globe',
    choiceNumber: 0,
    selected: 'launchChoice',
    act: 'launchAll',
  },
  {
    title: 'Launch Turf Ordered',
    icon: 'sort-amount-down-alt',
    choiceNumber: 1,
    selected: 'launchChoice',
    act: 'launchOrdered',
  },
  {
    title: 'Pick Random Turf',
    icon: 'dice',
    choiceNumber: 2,
    selected: 'launchChoice',
    act: 'launchRandomTurf',
  },
  {
    divider: 1,
  },
  {
    title: 'Launch Whole Turf',
    icon: 'expand',
    choiceNumber: 0,
    selected: 'launchRandomItem',
    act: 'launchWholeTurf',
  },
  {
    title: 'Pick Random Item',
    icon: 'dice',
    choiceNumber: 1,
    selected: 'launchRandomItem',
    act: 'launchRandomItem',
  },
  {
    divider: 1,
  },
  {
    title: 'Clone',
    icon: 'clone',
    soloSelected: 'launchClone',
    act: 'launchClone',
  },
];

const EFFECTS_NORMAL = [
  {
    title: 'Specific Target',
    icon: 'user-check',
    soloSelected: 'effectTarget',
    act: 'effectTarget',
  },
  {
    title: 'Pod Stays',
    icon: 'hand-paper',
    choiceNumber: 0,
    selected: 'effectBluespace',
    act: 'effectBluespace',
  },
  {
    title: 'Stealth',
    icon: 'user-ninja',
    soloSelected: 'effectStealth',
    act: 'effectStealth',
  },
  {
    title: 'Quiet',
    icon: 'volume-mute',
    soloSelected: 'effectQuiet',
    act: 'effectQuiet',
  },
  {
    title: 'Missile Mode',
    icon: 'rocket',
    soloSelected: 'effectMissile',
    act: 'effectMissile',
  },
  {
    title: 'Burst Launch',
    icon: 'certificate',
    soloSelected: 'effectBurst',
    act: 'effectBurst',
  },
  {
    title: 'Any Descent Angle',
    icon: 'ruler-combined',
    soloSelected: 'effectCircle',
    act: 'effectCircle',
  },
  {
    title: 'No Ghost Alert\n(If you dont want to\nentertain bored ghosts)',
    icon: 'ghost',
    choiceNumber: 0,
    selected: 'effectAnnounce',
    act: 'effectAnnounce',
  },
];

const EFFECTS_HARM =[
  {
    title: 'Explosion Custom',
    icon: 'bomb',
    choiceNumber: 1,
    selected: 'explosionChoice',
    act: 'explosionCustom',
  },
  {
    title: 'Adminbus Explosion\nWhat are they gonna do, ban you?',
    icon: 'bomb',
    choiceNumber: 2,
    selected: 'explosionChoice',
    act: 'explosionBus',
  },
  {
    divider: 1,
  },
  {
    title: 'Custom Damage',
    icon: 'skull',
    choiceNumber: 1,
    selected: 'damageChoice',
    act: 'damageCustom',
  },
  {
    title: 'Gib',
    icon: 'skull-crossbones',
    choiceNumber: 2,
    selected: 'damageChoice',
    act: 'damageGib',
  },
  {
    divider: 1,
  },
  {
    title: 'Projectile Cloud',
    details: true,
    icon: 'cloud-meatball',
    soloSelected: 'effectShrapnel',
    act: 'effectShrapnel',
  },
  {
    title: 'Stun',
    icon: 'sun',
    soloSelected: 'effectStun',
    act: 'effectStun',
  },
  {
    title: 'Delimb',
    icon: 'socks',
    soloSelected: 'effectLimb',
    act: 'effectLimb',
  },
  {
    title: 'Yeet Organs',
    icon: 'book-dead',
    soloSelected: 'effectOrgans',
    act: 'effectOrgans',
  },
];

const EFFECTS_ALL = [
  {
    list: EFFECTS_LOAD,
    label: "Load From",
    alt_label: "Load",
    tooltipPosition: "right",
  },
  {
    list: EFFECTS_NORMAL,
    label: "Normal Effects",
    tooltipPosition: "bottom",
  },
  {
    list: EFFECTS_HARM,
    label: "Harmful Effects",
    tooltipPosition: "bottom",
  },
];

const ViewTabHolder = (props, context) => {
  const { act, data } = useBackend(context);
  const [
    tabPageIndex,
    setTabPageIndex,
  ] = useLocalState(context, 'tabPageIndex', 1);
  const { mapRef } = data;
  const TabPageComponent = TABPAGES[tabPageIndex].component();
  return (
    <Section fill title="View" buttons={(
      <>
        {(!!data.customDropoff && data.effectReverse===1) && (
          <Button
            inline
            color="transparent"
            tooltip="View Dropoff Location"
            icon="arrow-circle-down"
            selected={2 === tabPageIndex}
            onClick={() => {
              setTabPageIndex(2);
              act('tabSwitch', { tabIndex: 2 });
            }} />
        )}
        <Button
          inline
          color="transparent"
          tooltip="View Pod"
          icon="rocket"
          selected={0 === tabPageIndex}
          onClick={() => {
            setTabPageIndex(0);
            act('tabSwitch', { tabIndex: 0 });
          }} />
        <Button
          inline
          color="transparent"
          tooltip="View Source Bay"
          icon="th"
          selected={1 === tabPageIndex}
          onClick={() => {
            setTabPageIndex(1);
            act('tabSwitch', { tabIndex: 1 });
          }} />
        <span style={pod_grey}>|</span>
        {(!!data.customDropoff && data.effectReverse===1) && (
          <Button
            inline
            color="transparent"
            icon="lightbulb"
            selected={data.renderLighting}
            tooltip="Render Lighting for the dropoff view"
            onClick={() => {
              act('renderLighting');
              act('refreshView');
            }}
          />
        )}
        <Button
          inline
          color="transparent"
          icon="sync-alt"
          tooltip="Refresh view window in case it breaks"
          onClick={() => {
            setTabPageIndex(tabPageIndex);
            act('refreshView');
          }}
        />
      </>
    )}>
      <Stack fill vertical>
        <Stack.Item>
          <TabPageComponent />
        </Stack.Item>
        <Stack.Item grow>
          <ByondUi
            height="100%"
            params={{
              zoom: 0,
              id: mapRef,
              type: 'map',
            }} />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const TabPod = (props, context) => {
  return (
    <Box color="label">
      Note: You can right click on this
      <br />
      blueprint pod and edit vars directly
    </Box>
  );
};

const TabBay = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <>
      <Button
        content="Teleport"
        icon="street-view"
        onClick={() => act('teleportCentcom')} />
      <Button
        content={data.oldArea ? data.oldArea.substring(0, 17) : 'Go Back'}
        disabled={!data.oldArea}
        icon="undo-alt"
        onClick={() => act('teleportBack')} />
    </>
  );
};

const TabDrop = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <>
      <Button
        content="Teleport"
        icon="street-view"
        onClick={() => act('teleportDropoff')} />
      <Button
        content={data.oldArea ? data.oldArea.substring(0, 17) : 'Go Back'}
        disabled={!data.oldArea}
        icon="undo-alt"
        onClick={() => act('teleportBack')} />
    </>
  );
};

const PodStatusPage = (props, context) => {
  const { act, data } = useBackend(context);
  const [compact, toggleCompact] = useCompact(context);
  return (
    <Section fill width="100%">
      <Stack>
        {EFFECTS_ALL.map((list, i) => (
          <Fragment key={i}>
            <Stack.Item>
              <Box bold color="label" mb={1}>
                {(compact === 1 && list.alt_label)
                  ? list.alt_label
                  : list.label}:
              </Box>
              <Box>
                {list.list.map((effect, j) => (
                  <Fragment key={j}>
                    {effect.divider && (
                      <span style={pod_grey}><b>|</b></span>
                    )}
                    {!effect.divider &&(
                      <Button
                        tooltip={effect.details
                          ? (data.effectShrapnel
                            ? effect.title
                            +"\n"+data.shrapnelType
                            +"\nMagnitude:"
                            +data.shrapnelMagnitude
                            : effect.title)
                          : effect.title}
                        tooltipPosition={list.tooltipPosition}
                        tooltipOverrideLong
                        icon={effect.icon}
                        content={effect.content}
                        selected={effect.soloSelected
                          ? data[effect.soloSelected]
                          : (data[effect.selected] === effect.choiceNumber)}
                        onClick={() => data.payload !== 0
                          ? act(effect.act, effect.payload)
                          : act(effect.act)}
                        style={{
                          'vertical-align': 'middle',
                          'margin-left': (j !== 0 ? '1px' : '0px'),
                          'margin-right': (
                            j !== list.list.length-1 ? '1px' : '0px'
                          ),
                          'border-radius': '5px',
                        }} />
                    )}
                  </Fragment>
                ))}
              </Box>
            </Stack.Item>
            {i < EFFECTS_ALL.length && (
              <Stack.Divider />
            )}
            {i === EFFECTS_ALL.length - 1 &&(
              <Stack.Item>
                <Box color="label" mb={1}>
                  <b>Extras:</b>
                </Box>
                <Box>
                  <Button
                    m={0}
                    inline
                    color="transparent"
                    icon="list-alt"
                    tooltip="Game Panel"
                    tooltipPosition="top-left"
                    onClick={() => act('gamePanel')} />
                  <Button
                    inline
                    m={0}
                    color="transparent"
                    icon="hammer"
                    tooltip="Build Mode"
                    tooltipPosition="top-left"
                    onClick={() => act('buildMode')} />
                  {compact && (
                    <Button
                      inline
                      m={0}
                      color="transparent"
                      icon="expand"
                      tooltip="Maximize"
                      tooltipPosition="top-left"
                      onClick={() => {
                        toggleCompact();
                        act('refreshView');
                      }} />
                  ) || (
                    <Button
                      m={0}
                      inline
                      color="transparent"
                      icon="compress"
                      tooltip="Compact mode"
                      tooltipPosition="top-left"
                      onClick={() => toggleCompact()} />
                  )}
                </Box>
              </Stack.Item>
            )}
          </Fragment>
        ))}
      </Stack>
    </Section>
  );
};

const ReverseMenu = (props, context) => {
  const { act, data } = useBackend(context);
  const [
    tabPageIndex,
    setTabPageIndex,
  ] = useLocalState(context, 'tabPageIndex', 1);
  return (
    <Section
      fill
      height="100%"
      title="Reverse"
      buttons={(
        <Button
          icon={data.effectReverse === 1 ? "toggle-on" : "toggle-off"}
          selected={data.effectReverse}
          tooltip={multiline`
            Doesn't send items.
            Afer landing, returns to
            dropoff turf (or bay
            if none specified).`}
          tooltipOverrideLong
          tooltipPosition="top-left"
          onClick={() => {
            act('effectReverse');
            if (tabPageIndex === 2) {
              setTabPageIndex(1);
              act('tabSwitch', { tabIndex: 1 });
            }
          }} />
      )}>
      {data.effectReverse === 1 && (
        <Stack fill vertical>
          <Stack.Item maxHeight="20px">
            <Button
              content="Dropoff Turf"
              selected={data.picking_dropoff_turf}
              disabled={!data.effectReverse}
              tooltip={multiline`
                Where reverse pods
                go after landing`}
              tooltipOverrideLong
              tooltipPosition="bottom-right"
              onClick={() => act('pickDropoffTurf')} />
            <Button
              inline
              icon="trash"
              disabled={!data.customDropoff}
              tooltip={multiline`
                Clears the custom dropoff
                location. Reverse pods will
                instead dropoff at the
                selected bay.`}
              tooltipOverrideLong
              tooltipPosition="bottom"
              onClick={() => {
                act('clearDropoffTurf');
                if (tabPageIndex === 2) {
                  setTabPageIndex(1);
                  act('tabSwitch', { tabIndex: 1 });
                }
              }} />
          </Stack.Item>
          <Stack.Divider />
          <Stack.Item maxHeight="20px">
            {REVERSE_OPTIONS.map((option, i) => (
              <Button
                key={i}
                inline
                icon={option.icon}
                disabled={!data.effectReverse}
                selected={
                  option.key
                    ? data.reverse_option_list[option.key]
                    : data.reverse_option_list[option.title]
                }
                tooltip={option.title}
                tooltipOverrideLong
                onClick={() => act('reverseOption', {
                  reverseOption: option.key
                    ? option.key
                    : option.title })} />
            ))}
          </Stack.Item>
        </Stack>
      )}
    </Section>
  );
};

class PresetsPage extends Component {
  constructor() {
    super();
    this.state = {
      presets: [],
    };
  }

  async componentDidMount() {
    // This warning is generally considered OK to ignore in this context
    // eslint-disable-next-line react/no-did-mount-set-state
    this.setState({
      presets: await this.getPresets(),
    });
  }

  saveDataToPreset(id, data) {
    storage.set("podlauncher_preset_" + id, data);
  }

  async loadDataFromPreset(id, context) {
    const { act } = useBackend(this.context);
    act("loadDataFromPreset", {
      payload: await storage.get("podlauncher_preset_" + id),
    });
  }

  newPreset(presetName, hue, data) {
    let { presets } = this.state;
    if (!presets) {
      presets = [];
      presets.push("hi!");
    }
    const id = createUuid();
    const thing = { id, title: presetName, hue };
    presets.push(thing);
    storage.set("podlauncher_presetlist", presets);
    this.saveDataToPreset(id, data);
  }

  async getPresets() {
    let thing = await storage.get("podlauncher_presetlist");
    if (thing === undefined) {
      thing = [];
    }
    return thing;
  }

  deletePreset(deleteID) {
    const { presets } = this.state;
    for (let i = 0; i < presets.length; i++) {
      if (presets[i].id === deleteID) {
        presets.splice(i, 1);
      }
    }
    storage.set("podlauncher_presetlist", presets);
  }
  render() {
    const { presets } = this.state;
    const { act, data } = useBackend(this.context);
    const [
      presetIndex,
      setSelectedPreset,
    ] = useLocalState(this.context, 'presetIndex', 0);
    const [
      settingName,
      setEditingNameStatus,
    ] = useLocalState(this.context, 'settingName', 0);
    const [newNameText, setText] = useLocalState(this.context, 'newNameText', "");
    const [hue, setHue] = useLocalState(this.context, 'hue', 0);
    return (
      <Section scrollable
        fill
        title="Presets"
        buttons={(
          <>
            {settingName === 0 && (
              <Button
                color="transparent"
                icon="plus"
                tooltip="New Preset"
                onClick={() => setEditingNameStatus(1)} />
            )}
            <Button
              inline
              color="transparent"
              content=""
              icon="download"
              tooltip="Saves preset"
              tooltipOverrideLong
              tooltipPosition="bottom"
              onClick={() => this.saveDataToPreset(presetIndex, data)} />
            <Button
              inline
              color="transparent"
              content=""
              icon="upload"
              tooltip="Loads preset"
              onClick={() => {
                this.loadDataFromPreset(presetIndex);
              }} />
            <Button
              inline
              color="transparent"
              icon="trash"
              tooltip="Deletes the selected preset"
              tooltipPosition="bottom-left"
              onClick={() => this.deletePreset(presetIndex)} />
          </>
        )}>
        {settingName === 1 && (
          <>
            <Button
              inline
              icon="check"
              tooltip="Confirm"
              tooltipPosition="right"
              onClick={() => {
                this.newPreset(newNameText, hue, data);
                setEditingNameStatus(0);
              }} />
            <Button
              inline
              icon="window-close"
              tooltip="Cancel"
              onClick={() => {
                setText("");
                setEditingNameStatus(0);
              }} />
            <span color="label"> Hue: </span>
            <NumberInput
              inline
              animated
              width="40px"
              step={5}
              stepPixelSize={5}
              value={hue}
              minValue={0}
              maxValue={360}
              onChange={(e, value) => setHue(value)} />
            <Input
              inline
              autofocus
              placeholder="Preset Name"
              onChange={(e, value) => setText(value)} />
            <Divider horizontal />
          </>
        )}
        {(!presets || presets.length === 0) && (
          <span style={pod_grey}>
            Click [+] to define a new preset.
            They are persistent across rounds/servers!
          </span>
        )}
        {presets ? presets.map((preset, i) => (
          <Button
            key={i}
            width="100%"
            backgroundColor={`hsl(${preset.hue}, 50%, 50%)`}
            onClick={() => setSelectedPreset(preset.id)}
            content={preset.title}
            style={presetIndex === preset.id ? {
              'border-width': '1px',
              'border-style': 'solid',
              'border-color': `hsl(${preset.hue}, 80%, 80%)`,
            } : ''} />
        )) : ""}
        <span style={pod_grey}>
          <br />
          <br />
          NOTE: Custom sounds from outside the base game files will not save! :(
        </span>
      </Section>
    );
  }
}

const LaunchPage = (props, context) => {
  const [compact] = useCompact(context);
  const { act, data } = useBackend(context);
  return (
    <Button
      fluid
      textAlign="center"
      tooltip={multiline`
        You should know what the
        Codex Astartes says about this`}
      tooltipOverrideLong
      selected={data.giveLauncher}
      tooltipPosition="top"
      content={(
        <Box
          bold
          fontSize="1.4em"
          lineHeight={compact ? 1.5 : 3}>
          LAUNCH
        </Box>
      )}
      onClick={() => act('giveLauncher')}
    />
  );
};

const StylePage = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Section
      fill
      scrollable
      title="Style"
      buttons={(
        <Button
          content="Name"
          color="transparent"
          icon="edit"
          selected={data.effectName}
          tooltip={multiline`
            Edit pod's
            name/desc.`}
          tooltipPosition="bottom-left"
          onClick={() => act('effectName')} />
      )}>
      {STYLES.map((page, i) => (
        <Button
          key={i}
          width="45px"
          height="45px"
          tooltipPosition={
            i >= STYLES.length-2
              ? (i%2===1 ? "top-left" : "top-right")
              : (i%2===1 ? "bottom-left" : "bottom-right")
          }
          tooltip={page.title}
          style={{
            'vertical-align': 'middle',
            'margin-right': '5px',
            'border-radius': '20px',
          }}
          selected={data.styleChoice-1 === i}
          onClick={() => act('setStyle', { style: i })}>
          <Box
            className={classes(['supplypods64x64', 'pod_asset'+(i+1)])}
            style={{
              'transform': 'rotate(45deg) translate(-25%,-10%)', 'pointer-events': 'none',
            }} />
        </Button>
      ))}
    </Section>
  );
};

const Bays = (props, context) => {
  const { act, data } = useBackend(context);
  const [compact] = useCompact(context);
  return (
    <Section
      fill
      title="Bay"
      buttons={(
        <>
          <Button
            icon="trash"
            color="transparent"
            tooltip={multiline`
              Clears everything
              from the selected bay`}
            tooltipOverrideLong
            tooltipPosition="bottom-right"
            onClick={() => act('clearBay')} />
          <Button
            icon="question"
            color="transparent"
            tooltip={multiline`
              Each option corresponds
              to an area on centcom.
              Launched pods will
              be filled with items
              in these areas according
              to the "Load from Bay"
              options at the top left.`}
            tooltipOverrideLong
            tooltipPosition="bottom-right" />
        </>
      )}>
      {BAYS.map((bay, i) => (
        <Button
          key={i}
          content={bay.title}
          tooltipPosition={"bottom-right"}
          selected={data.bayNumber === ""+(i+1)}
          onClick={() => act('switchBay', { bayNumber: (""+(i+1)) })} />
      ))}
    </Section>
  );
};

const Timing = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Section
      fill
      title="Time"
      buttons={(
        <>
          <Button
            icon="undo"
            color="transparent"
            tooltip={multiline`
            Reset all pod
            timings/delays`}
            tooltipOverrideLong
            tooltipPosition="bottom-right"
            onClick={() => act('resetTiming')} />
          <Button
            icon={data.custom_rev_delay === 1 ? "toggle-on" : "toggle-off"}
            selected={data.custom_rev_delay}
            disabled={!data.effectReverse}
            color="transparent"
            tooltip={multiline`
            Toggle Reverse Delays
            Note: Top set is
            normal delays, bottom set
            is reversing pod's delays`}
            tooltipOverrideLong
            tooltipPosition="bottom-right"
            onClick={() => act('toggleRevDelays')} />
        </>
      )}>
      <DelayHelper
        delay_list={DELAYS}
      />
      {data.custom_rev_delay && (
        <>
          <Divider horizontal />
          <DelayHelper
            delay_list={REV_DELAYS}
            reverse
          />
        </>
      )||""}
    </Section>
  );
};

const DelayHelper = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    delay_list,
    reverse = false,
  } = props;
  return (
    <LabeledControls wrap>
      {delay_list.map((delay, i) => (
        <LabeledControls.Item
          key={i}
          label={data.custom_rev_delay ? "" : delay.title}>
          <Knob
            inline
            step={0.02}
            size={data.custom_rev_delay ? 0.75 : 1}
            value={(reverse ? data.rev_delays[i+1] : data.delays[i+1]) / 10}
            unclamped
            minValue={0}
            unit={"s"}
            format={value => toFixed(value, 2)}
            maxValue={10}
            color={((reverse ? data.rev_delays[i+1] : data.delays[i+1]) / 10)
              > 10 ? "orange" : "default"}
            onDrag={(e, value) => {
              act('editTiming', {
                timer: ""+(i + 1),
                value: Math.max(value, 0),
                reverse: reverse,
              });
            }} />
        </LabeledControls.Item>
      ))}
    </LabeledControls>
  );
};

const Sounds = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Section fill title="Sounds"
      buttons={(
        <Button
          icon="volume-up"
          color="transparent"
          selected={data.soundVolume !== data.defaultSoundVolume}
          tooltip={multiline`
            Sound Volume:` + data.soundVolume}
          tooltipOverrideLong
          onClick={() => act('soundVolume')} />
      )}>
      {SOUNDS.map((sound, i) => (
        <Button
          key={i}
          content={sound.title}
          tooltip={sound.tooltip}
          tooltipPosition="top-right"
          tooltipOverrideLong
          selected={data[sound.act]}
          onClick={() => act(sound.act)} />
      ))}
    </Section>
  );
};
