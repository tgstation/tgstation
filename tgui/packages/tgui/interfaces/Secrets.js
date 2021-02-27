import { toFixed } from 'common/math';
import { useBackend, useLocalState } from '../backend';
import { Button, Flex, LabeledControls, NoticeBox, RoundGauge, Section, Stack } from '../components';
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
const buttonWidthNormal = 12.9;
const lineHeightDebug = 6.09;

const DebuggingTab = (props, context) => {
  const { act } = useBackend(context);
  return (
    <Stack fill vertical>
      <Stack.Item>
        <Button
          color="average"
          lineHeight={lineHeightDebug}
          icon="question"
          fluid
          content="Change all maintenance doors to engie/brig access only"
          onClick={() => act("maint_access_engiebrig")} />
      </Stack.Item>
      <Stack.Item>
        <Button
          color="average"
          lineHeight={lineHeightDebug}
          icon="question"
          fluid
          content="Change all maintenance doors to brig access only"
          onClick={() => act("maint_access_brig")} />
      </Stack.Item>
      <Stack.Item>
        <Button
          color="average"
          lineHeight={lineHeightDebug}
          icon="question"
          fluid
          content="Remove cap on security officers"
          onClick={() => act("infinite_sec")} />
      </Stack.Item>
    </Stack>
  );
};

const HelpfulTab = (props, context) => {
  const { act } = useBackend(context);
  return (
    <Stack fill vertical>
      <Stack.Item>
        <Stack fill>
          <Stack.Item>
            <Button
              icon="clipboard"
              lineHeight={lineHeightNormal}
              width={buttonWidthNormal}
              content="Show Gamemode"
              onClick={() => act("showgm")} />
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="plus"
              lineHeight={lineHeightNormal}
              width={buttonWidthNormal}
              content="Cure all diseases"
              onClick={() => act("clear_virus")} />
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="biohazard"
              lineHeight={lineHeightNormal}
              width={buttonWidthNormal}
              content="Trigger Outbreak"
              onClick={() => act("virus")} />
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item>
        <Stack fill>
          <Stack.Item>
            <NoticeBox
              mb={-0.5}
              width={buttonWidthNormal}
              height={lineHeightNormal}>
              Your admin button here, coder!
            </NoticeBox>
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="grin-beam-sweat"
              lineHeight={lineHeightNormal}
              width={buttonWidthNormal}
              content="Break all lights"
              onClick={() => act("blackout")} />
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="magic"
              lineHeight={lineHeightNormal}
              width={buttonWidthNormal}
              content="Fix all lights"
              onClick={() => act("whiteout")} />
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item>
        <Stack fill>
          <Stack.Item>
            <Button
              icon="bomb"
              lineHeight={lineHeightNormal}
              width={buttonWidthNormal}
              content="List Bombers"
              onClick={() => act("list_bombers")} />
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="signal"
              lineHeight={lineHeightNormal}
              width={buttonWidthNormal}
              content="List Signalers"
              onClick={() => act("list_signalers")} />
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="robot"
              lineHeight={lineHeightNormal}
              width={buttonWidthNormal}
              content="List laws"
              onClick={() => act("list_lawchanges")} />
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item>
        <Stack fill>
          <Stack.Item>
            <Button
              icon="address-book"
              lineHeight={lineHeightNormal}
              width={buttonWidthNormal}
              content="Show Manifest"
              onClick={() => act("manifest")} />
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="dna"
              lineHeight={lineHeightNormal}
              width={buttonWidthNormal}
              content="Show DNA"
              onClick={() => act("dna")} />
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="fingerprint"
              lineHeight={lineHeightNormal}
              width={buttonWidthNormal}
              content="Show Fingerprints"
              onClick={() => act("fingerprints")} />
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item>
        <Stack fill>
          <Stack.Item>
            <Button
              icon="flag"
              lineHeight={lineHeightNormal}
              width={buttonWidthNormal}
              content="Toggle CTF"
              onClick={() => act("ctfbutton")} />
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="sync-alt"
              lineHeight={lineHeightNormal}
              width={buttonWidthNormal}
              content="Reset Thunderdome"
              onClick={() => act("tdomereset")} />
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="moon"
              lineHeight={lineHeightNormal}
              width={buttonWidthNormal}
              content="Set Nightshift"
              onClick={() => act("night_shift_set")} />
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item>
        <Stack fill>
          <Stack.Item>
            <Button
              icon="pencil-alt"
              lineHeight={lineHeightNormal}
              width={buttonWidthNormal}
              content="Rename Station"
              onClick={() => act("set_name")} />
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="eraser"
              lineHeight={lineHeightNormal}
              width={buttonWidthNormal}
              content="Default Station Name"
              onClick={() => act("reset_name")} />
          </Stack.Item>
          <Stack.Item>
            <NoticeBox
              mb={-0.5}
              width={buttonWidthNormal}
              height={lineHeightNormal}>
              Your admin button here, coder!
            </NoticeBox>
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};

const FunTab = (props, context) => {
  const { act } = useBackend(context);
  return (
    <Stack fill vertical>
      <Stack.Item>
        <Stack fill>
          <Stack.Item>
            <NoticeBox
              mb={-0.5}
              width={buttonWidthNormal}
              height={lineHeightNormal}>
              Your admin button here, coder!
            </NoticeBox>
          </Stack.Item>
          <Stack.Item>
            <NoticeBox
              mb={-0.5}
              width={buttonWidthNormal}
              height={lineHeightNormal}>
              Your admin button here, coder!
            </NoticeBox>
          </Stack.Item>
          <Stack.Item>
            <NoticeBox
              mb={0.0}
              width={buttonWidthNormal}
              height={lineHeightNormal}>
              Your admin button here, coder!
            </NoticeBox>
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item>
        <Stack fill>
          <Stack.Item>
            <Button
              icon="bolt"
              lineHeight={lineHeightNormal}
              width={buttonWidthNormal}
              content="All areas powered"
              onClick={() => act("power")} />
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="moon"
              lineHeight={lineHeightNormal}
              width={buttonWidthNormal}
              content="All areas unpowered"
              onClick={() => act("unpower")} />
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="plug"
              lineHeight={lineHeightNormal}
              width={buttonWidthNormal}
              content="recharge SMESs"
              onClick={() => act("quickpower")} />
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item>
        <Stack fill>
          <Stack.Item>
            <Button
              icon="user-ninja"
              lineHeight={lineHeightNormal}
              width={buttonWidthNormal}
              content="Anonymous Names"
              onClick={() => act("anon_name")} />
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="users"
              lineHeight={lineHeightNormal}
              width={buttonWidthNormal}
              content="Triple AI mode"
              onClick={() => act("tripleAI")} />
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="bullhorn"
              lineHeight={lineHeightNormal}
              width={buttonWidthNormal}
              content="THERE CAN ONLY BE-"
              onClick={() => act("onlyone")} />
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item>
        <Stack fill>
          <Stack.Item>
            <Button
              icon="grin-beam-sweat"
              lineHeight={lineHeightNormal}
              width={buttonWidthNormal}
              content="Summon Guns"
              onClick={() => act("guns")} />
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="magic"
              lineHeight={lineHeightNormal}
              width={buttonWidthNormal}
              content="Summon Magic"
              onClick={() => act("magic")} />
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="meteor"
              lineHeight={lineHeightNormal}
              width={buttonWidthNormal}
              content="Summon Events"
              onClick={() => act("events")} />
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item>
        <Stack fill>
          <Stack.Item>
            <Button
              icon="hammer"
              lineHeight={lineHeightNormal}
              width={buttonWidthNormal}
              content="Egalitarian Station"
              onClick={() => act("eagles")} />
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="dollar-sign"
              lineHeight={lineHeightNormal}
              width={buttonWidthNormal}
              content="Ancap Station"
              onClick={() => act("ancap")} />
          </Stack.Item>
          <Stack.Item>
            <NoticeBox
              mb={-0.5}
              width={buttonWidthNormal}
              height={lineHeightNormal}>
              Your admin button here, coder!
            </NoticeBox>
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item>
        <Stack fill>
          <Stack.Item>
            <Button
              icon="bullseye"
              lineHeight={lineHeightNormal}
              width={buttonWidthNormal}
              content="Custom Portal Storm"
              onClick={() => act("customportal")} />
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="bomb"
              lineHeight={lineHeightNormal}
              width={buttonWidthNormal}
              content="Change Bomb Cap"
              onClick={() => act("changebombcap")} />
          </Stack.Item>
          <Stack.Item>
            <NoticeBox
              mb={-0.5}
              width={buttonWidthNormal}
              height={lineHeightNormal}>
              Your admin button here, coder!
            </NoticeBox>
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};

const FunForYouTab = (props, context) => {
  const { act } = useBackend(context);
  return (
    <Stack fill vertical>
      <Stack.Item>
        <Stack>
          <Stack.Item>
            <NoticeBox danger mb={0} width={19.6}>
              <Button
                color="red"
                icon="user-secret"
                fluid
                content="Everyone is the traitor"
                onClick={() => act("traitor_all")} />
            </NoticeBox>
          </Stack.Item>
          <Stack.Item>
            <NoticeBox danger width={19.6} mb={0}>
              <Button
                color="red"
                icon="brain"
                fluid
                content="Everyone gets brain damage"
                onClick={() => act("massbraindamage")} />
            </NoticeBox>
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item>
        <NoticeBox danger mb={0}>
          <Button
            color="red"
            icon="hand-lizard"
            fluid
            content="Change everyone's species"
            onClick={() => act("traitor_all")} />
        </NoticeBox>
      </Stack.Item>
      <Stack.Item>
        <NoticeBox danger mb={0}>
          <Button
            color="black"
            icon="paw"
            fluid
            content="Turn all humans into monkeys (DANGEROUS: worst species)"
            onClick={() => act("monkey")} />
        </NoticeBox>
      </Stack.Item>
      <Stack.Item>
        <NoticeBox danger mb={0}>
          <Button
            color="black"
            icon="fire"
            fluid
            content="The floor is lava! (DANGEROUS: extremely lame)"
            onClick={() => act("floorlava")} />
        </NoticeBox>
      </Stack.Item>
      <Stack.Item>
        <NoticeBox danger mb={0}>
          <Button
            color="black"
            icon="fire"
            fluid
            content="Chinese Cartoons! (DANGEROUS: no going back, also fuck you)"
            onClick={() => act("anime")} />
        </NoticeBox>
      </Stack.Item>
      <Stack.Item>
        <Stack fill>
          <Stack.Item>
            <NoticeBox danger width={19.6} mb={0}>
              <Button
                color="red"
                icon="cat"
                fluid
                content="Mass Purrbation"
                onClick={() => act("masspurrbation")} />
            </NoticeBox>
          </Stack.Item>
          <Stack.Item>
            <NoticeBox info width={19.6} mb={0}>
              <Button
                color="blue"
                icon="user"
                fluid
                content="Cure Purrbation"
                onClick={() => act("massremovepurrbation")} />
            </NoticeBox>
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item>
        <Stack>
          <Stack.Item grow>
            <NoticeBox danger width={19.6} mb={0}>
              <Button
                color="red"
                icon="flushed"
                fluid
                content="Fully Immerse Everyone"
                onClick={() => act("massimmerse")} />
            </NoticeBox>
          </Stack.Item>
          <Stack.Item grow>
            <NoticeBox info width={19.6} mb={0}>
              <Button
                color="blue"
                icon="sync-alt"
                fluid
                content="Shatter the Immersion"
                onClick={() => act("unmassimmerse")} />
            </NoticeBox>
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
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
      height={488}>
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
