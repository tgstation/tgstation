import { toFixed } from 'common/math';
import { useBackend, useLocalState } from '../backend';
import { Button, Flex, LabeledControls, NoticeBox, RoundGauge, Section } from '../components';
import { Window } from '../layouts';

const TAB2NAME = [
  {
    title: 'Debugging',
    blurb: 'Where useless shit goes to die',
    gauge: 5,
    component: () => DebuggingTab,
  },
  {
    title: 'Helpful',
    blurb: 'Where fuckwits put logging',
    gauge: 25,
    component: () => HelpfulTab,
  },
  {
    title: 'Fun',
    blurb: 'How I ran an """event"""',
    gauge: 75,
    component: () => FunTab,
  },
  {
    title: 'Only Fun For You',
    blurb: 'How I spent my last day adminning',
    gauge: 95,
    component: () => FunForYouTab,
  },
];

const lineHeightNormal = 2.79;
const lineHeightDebug = 6;

const DebuggingTab = (props, context) => {
  const { act } = useBackend(context);
  return (
    <Flex
      grow={1}
      mb={-0.25}
      mx={-0.5}
      direction="column"
      height="100%"
      textAlign="center"
      align="stretch"
      justify="center">
      <Flex.Item my={0.5}>
        <Button
          lineHeight={lineHeightDebug}
          icon="question"
          fluid
          content="Change all maintenance doors to engie/brig access only"
          onClick={() => act("maint_access_engiebrig")} />
      </Flex.Item>
      <Flex.Item my={0.5}>
        <Button
          lineHeight={lineHeightDebug}
          icon="question"
          fluid
          content="Change all maintenance doors to brig access only"
          onClick={() => act("maint_access_brig")} />
      </Flex.Item>
      <Flex.Item mt={0.5} mb={-0.5}>
        <Button
          lineHeight={lineHeightDebug}
          icon="question"
          fluid
          content="Remove cap on security officers"
          onClick={() => act("infinite_sec")} />
      </Flex.Item>
    </Flex>
  );
};

const HelpfulTab = (props, context) => {
  const { act } = useBackend(context);
  return (
    <Flex direction="column" mb={-0.75} mx={-0.5}>
      <Flex
        mb={1}
        grow={1}
        direction="row"
        height="100%"
        align="stretch"
        justify="space-between">
        <Flex.Item grow={1}>
          <Button
            icon="plus"
            lineHeight={lineHeightNormal}
            fluid
            content="Cure all diseases currently in existence"
            onClick={() => act("clear_virus")} />
        </Flex.Item>
        <Flex.Item grow={1} ml={0.5}>
          <Button
            icon="eye"
            lineHeight={lineHeightNormal}
            fluid
            content="Show Gamemode"
            onClick={() => act("showgm")} />
        </Flex.Item>
      </Flex>
      <Flex
        mb={1}
        grow={1}
        direction="row"
        height="100%"
        align="stretch"
        justify="space-between">
        <Flex.Item grow={1}>
          <Button
            icon="bomb"
            lineHeight={lineHeightNormal}
            fluid
            content="List Bombers"
            onClick={() => act("list_bombers")} />
        </Flex.Item>
        <Flex.Item grow={1} mx={0.5}>
          <Button
            icon="signal"
            lineHeight={lineHeightNormal}
            fluid
            content="List Signalers"
            onClick={() => act("list_signalers")} />
        </Flex.Item>
        <Flex.Item grow={1}>
          <Button
            icon="robot"
            lineHeight={lineHeightNormal}
            fluid
            content="List laws"
            onClick={() => act("list_lawchanges")} />
        </Flex.Item>
      </Flex>
      <Flex
        mb={1}
        grow={1}
        direction="row"
        height="100%"
        align="stretch"
        justify="space-between">
        <Flex.Item grow={1}>
          <Button
            icon="address-book"
            lineHeight={lineHeightNormal}
            fluid
            content="Show Manifest"
            onClick={() => act("manifest")} />
        </Flex.Item>
        <Flex.Item grow={1} mx={0.5}>
          <Button
            icon="dna"
            lineHeight={lineHeightNormal}
            fluid
            content="Show DNA"
            onClick={() => act("dna")} />
        </Flex.Item>
        <Flex.Item grow={1}>
          <Button
            icon="fingerprint"
            lineHeight={lineHeightNormal}
            fluid
            content="Show Fingerprints"
            onClick={() => act("fingerprints")} />
        </Flex.Item>
      </Flex>
      <Flex
        mb={1}
        grow={1}
        direction="row"
        height="100%"
        align="stretch"
        justify="space-between">
        <Flex.Item grow={1}>
          <Button
            icon="flag"
            lineHeight={lineHeightNormal}
            fluid
            content="Toggle CTF"
            onClick={() => act("ctfbutton")} />
        </Flex.Item>
        <Flex.Item grow={1} mx={0.5}>
          <Button
            icon="sync-alt"
            lineHeight={lineHeightNormal}
            fluid
            content="Reset Thunderdome"
            onClick={() => act("tdomereset")} />
        </Flex.Item>
        <Flex.Item grow={1}>
          <Button
            icon="moon"
            lineHeight={lineHeightNormal}
            fluid
            content="Set Nightshift"
            onClick={() => act("night_shift_set")} />
        </Flex.Item>
      </Flex>
      <Flex
        mb={1}
        grow={1}
        direction="row"
        height="100%"
        align="stretch"
        justify="space-between">
        <Flex.Item grow={1}>
          <Button
            icon="pencil-alt"
            lineHeight={lineHeightNormal}
            fluid
            content="Rename Station"
            onClick={() => act("set_name")} />
        </Flex.Item>
        <Flex.Item grow={1} ml={0.5}>
          <Button
            icon="eraser"
            lineHeight={lineHeightNormal}
            fluid
            content="Reset Station"
            onClick={() => act("reset_name")} />
        </Flex.Item>
      </Flex>
      <Flex
        grow={1}
        direction="row"
        height="100%"
        align="stretch"
        justify="space-between">
        <Flex.Item grow={1}>
          <Button
            icon="plane-departure"
            lineHeight={lineHeightNormal}
            fluid
            content="Move Ferry"
            onClick={() => act("moveferry")} />
        </Flex.Item>
        <Flex.Item grow={1} mx={0.5}>
          <Button
            icon="plane"
            lineHeight={lineHeightNormal}
            fluid
            content="Toggle Arrivals"
            onClick={() => act("togglearrivals")} />
        </Flex.Item>
        <Flex.Item grow={1}>
          <Button
            icon="plane-arrival"
            lineHeight={lineHeightNormal}
            fluid
            content="Move Labor"
            onClick={() => act("movelaborshuttle")} />
        </Flex.Item>
      </Flex>
    </Flex>
  );
};

const FunTab = (props, context) => {
  const { act } = useBackend(context);
  return (
    <Flex direction="column" mb={-0.75} mx={-0.5} textAlign="center">
      <Flex
        mb={1}
        grow={1}
        direction="row"
        height="100%"
        align="stretch"
        justify="space-between">
        <Flex.Item grow={1}>
          <Button
            icon="grin-beam-sweat"
            lineHeight={lineHeightNormal}
            fluid
            content="Break all lights"
            onClick={() => act("blackout")} />
        </Flex.Item>
        <Flex.Item grow={1} mx={0.5}>
          <Button
            icon="magic"
            lineHeight={lineHeightNormal}
            fluid
            content="Fix all lights"
            onClick={() => act("whiteout")} />
        </Flex.Item>
        <Flex.Item grow={1}>
          <Button
            icon="biohazard"
            lineHeight={lineHeightNormal}
            fluid
            content="Trigger Outbreak"
            onClick={() => act("virus")} />
        </Flex.Item>
      </Flex>
      <Flex
        mb={1}
        grow={1}
        direction="row"
        height="100%"
        align="stretch"
        justify="space-between">
        <Flex.Item>
          <Button
            icon="bolt"
            lineHeight={lineHeightNormal}
            fluid
            content="All areas powered"
            onClick={() => act("power")} />
        </Flex.Item>
        <Flex.Item grow={1} mx={0.5}>
          <Button
            icon="moon"
            lineHeight={lineHeightNormal}
            fluid
            content="All areas unpowered"
            onClick={() => act("unpower")} />
        </Flex.Item>
        <Flex.Item>
          <Button
            icon="plug"
            lineHeight={lineHeightNormal}
            fluid
            content="IC power (SMES charged)"
            onClick={() => act("quickpower")} />
        </Flex.Item>
      </Flex>
      <Flex
        mb={1}
        grow={1}
        direction="row"
        height="100%"
        align="stretch"
        justify="space-between">
        <Flex.Item grow={1}>
          <Button
            icon="user-ninja"
            lineHeight={lineHeightNormal}
            fluid
            content="Anonymous Names"
            onClick={() => act("anon_name")} />
        </Flex.Item>
        <Flex.Item grow={1} mx={0.5}>
          <Button
            icon="users"
            lineHeight={lineHeightNormal}
            fluid
            content="Triple AI mode"
            onClick={() => act("tripleAI")} />
        </Flex.Item>
        <Flex.Item grow={1}>
          <Button
            icon="bullhorn"
            lineHeight={lineHeightNormal}
            fluid
            content="THERE CAN ONLY BE ONE!"
            onClick={() => act("onlyone")} />
        </Flex.Item>
      </Flex>
      <Flex
        mb={1}
        grow={1}
        direction="row"
        height="100%"
        align="stretch"
        justify="space-between">
        <Flex.Item grow={1}>
          <Button
            icon="grin-beam-sweat"
            lineHeight={lineHeightNormal}
            fluid
            content="Summon Guns"
            onClick={() => act("guns")} />
        </Flex.Item>
        <Flex.Item grow={1} mx={0.5}>
          <Button
            icon="magic"
            lineHeight={lineHeightNormal}
            fluid
            content="Summon Magic"
            onClick={() => act("magic")} />
        </Flex.Item>
        <Flex.Item grow={1}>
          <Button
            icon="meteor"
            lineHeight={lineHeightNormal}
            fluid
            content="Summon Events"
            onClick={() => act("events")} />
        </Flex.Item>
      </Flex>
      <Flex
        mb={1}
        grow={1}
        direction="row"
        height="100%"
        align="stretch"
        justify="space-between">
        <Flex.Item grow={1}>
          <Button
            icon="hammer"
            lineHeight={lineHeightNormal}
            fluid
            content="Egalitarian Station"
            onClick={() => act("eagles")} />
        </Flex.Item>
        <Flex.Item grow={1} ml={0.5}>
          <Button
            icon="dollar-sign"
            lineHeight={lineHeightNormal}
            fluid
            content="Anarcho-Capitalist Station"
            onClick={() => act("ancap")} />
        </Flex.Item>
      </Flex>
      <Flex
        grow={1}
        direction="row"
        height="100%"
        align="stretch"
        justify="space-between">
        <Flex.Item grow={1}>
          <Button
            icon="bullseye"
            lineHeight={lineHeightNormal}
            fluid
            content="Custom Portal Storm"
            onClick={() => act("customportal")} />
        </Flex.Item>
        <Flex.Item grow={1} ml={0.5}>
          <Button
            icon="bomb"
            lineHeight={lineHeightNormal}
            fluid
            content="Change Bomb Cap"
            onClick={() => act("changebombcap")} />
        </Flex.Item>
      </Flex>
    </Flex>
  );
};

const FunForYouTab = (props, context) => {
  const { act } = useBackend(context);
  return (
    <Flex
      grow={1}
      mx={-0.5}
      mb={-1.75}
      direction="column"
      height="100%"
      align="stretch"
      justify="center">
      <Flex.Item>
        <NoticeBox danger>
          <Button
            color="red"
            icon="paw"
            fluid
            content="Turn all humans into monkeys"
            onClick={() => act("monkey")} />
        </NoticeBox>
      </Flex.Item>
      <Flex.Item>
        <NoticeBox danger>
          <Button
            color="red"
            icon="user-secret"
            fluid
            content="Everyone is the traitor"
            onClick={() => act("traitor_all")} />
        </NoticeBox>
      </Flex.Item>
      <Flex.Item>
        <NoticeBox danger>
          <Button
            color="red"
            icon="brain"
            fluid
            content="Make all players brain damaged"
            onClick={() => act("massbraindamage")} />
        </NoticeBox>
      </Flex.Item>
      <Flex.Item>
        <NoticeBox danger>
          <Button
            color="black"
            icon="fire"
            fluid
            content="The floor is lava! (DANGEROUS: extremely lame)"
            onClick={() => act("floorlava")} />
        </NoticeBox>
      </Flex.Item>
      <Flex.Item>
        <NoticeBox danger>
          <Button
            color="black"
            icon="tired"
            fluid
            content="Chinese Cartoons! (DANGEROUS: no going back, also fuck you)"
            onClick={() => act("anime")} />
        </NoticeBox>
      </Flex.Item>
      <Flex.Item>
        <Flex>
          <Flex.Item width="240px" mr={0.25}>
            <NoticeBox danger>
              <Button
                color="red"
                icon="cat"
                fluid
                content="Mass Purrbation"
                onClick={() => act("masspurrbation")} />
            </NoticeBox>
          </Flex.Item>
          <Flex.Item grow={1} ml={0.25}>
            <NoticeBox info>
              <Button
                color="blue"
                icon="user"
                fluid
                content="Mass Remove Purrbation"
                onClick={() => act("massremovepurrbation")} />
            </NoticeBox>
          </Flex.Item>
        </Flex>
      </Flex.Item>
      <Flex.Item>
        <Flex justify="space-between">
          <Flex.Item width="240px" mr={0.25}>
            <NoticeBox danger>
              <Button
                color="red"
                icon="flushed"
                fluid
                content="Fully Immerse Everyone"
                onClick={() => act("massimmerse")} />
            </NoticeBox>
          </Flex.Item>
          <Flex.Item grow={1} ml={0.25}>
            <NoticeBox info>
              <Button
                color="blue"
                icon="sync-alt"
                fluid
                content="Shatter the Immersion"
                onClick={() => act("unmassimmerse")} />
            </NoticeBox>
          </Flex.Item>
        </Flex>
      </Flex.Item>
    </Flex>
  );
};

export const Secrets = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    is_debugger,
    is_funmin,
  } = data;
  const [
    tabIndex,
    setTabIndex,
  ] = useLocalState(context, 'tab-index', 2);
  const TabComponent = TAB2NAME[tabIndex-1].component();
  return (
    <Window
      title="Secrets Panel"
      width={500}
      height={485}>
      <Window.Content>
        <Flex direction="column" height="100%">
          <Flex.Item mb={1}>
            <Section
              title="Secrets"
              buttons={(
                <>
                  <Button
                    color="blue"
                    icon="address-card"
                    content="Admin Log"
                    onClick={() => act("admin_log")} />
                  <Button
                    color="blue"
                    icon="eye"
                    content="Show Admins"
                    onClick={() => act("show_admins")} />
                </>
              )}>
              <Flex
                mx={-0.5}
                align="stretch"
                justify="center">
                <Flex.Item bold>
                  <NoticeBox color="black">
                    &quot;The first rule of adminbuse is:
                    you don&apos;t talk about the adminbuse.&quot;
                  </NoticeBox>
                </Flex.Item>
              </Flex>
              <Flex
                textAlign="center"
                mx={-0.5}
                align="stretch"
                justify="center">
                <Flex.Item ml={-10} mr={1}>
                  <Button
                    selected={tabIndex === 2}
                    icon="check-circle"
                    content="Helpful"
                    onClick={() => setTabIndex(2)} />
                </Flex.Item>
                <Flex.Item ml={1}>
                  <Button
                    disabled={is_funmin === 0}
                    selected={tabIndex === 3}
                    icon="smile"
                    content="Fun"
                    onClick={() => setTabIndex(3)} />
                </Flex.Item>
              </Flex>
              <Flex
                mx={-0.5}
                align="stretch"
                justify="center">
                <Flex.Item mt={1}>
                  <Button
                    disabled={is_debugger === 0}
                    selected={tabIndex === 1}
                    icon="glasses"
                    content="Debugging"
                    onClick={() => setTabIndex(1)} />
                </Flex.Item>
                <Flex.Item>
                  <LabeledControls>
                    <LabeledControls.Item
                      minWidth="66px"
                      label="Chances of admin complaint">
                      <RoundGauge
                        size={2}
                        value={TAB2NAME[tabIndex-1].gauge}
                        minValue={0}
                        maxValue={100}
                        alertAfter={100 * 0.70}
                        ranges={{
                          "good": [-2, 100 * 0.25],
                          "average": [100 * 0.25, 100 * 0.75],
                          "bad": [100 * 0.75, 100],
                        }}
                        format={value => toFixed(value) + '%'} />
                    </LabeledControls.Item>
                  </LabeledControls>
                </Flex.Item>
                <Flex.Item mt={1}>
                  <Button
                    disabled={is_funmin === 0}
                    selected={tabIndex === 4}
                    icon="smile-wink"
                    content="Only Fun For You"
                    onClick={() => setTabIndex(4)} />
                </Flex.Item>
              </Flex>
            </Section>
          </Flex.Item>
          <Flex.Item grow={1}>
            <Section
              fill={false}
              title={TAB2NAME[tabIndex-1].title
                + " Or: " + TAB2NAME[tabIndex-1].blurb}>
              <TabComponent />
            </Section>
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};
