import { useBackend, useLocalState } from '../backend';
import { Section, Stack, Box, Tabs, Button } from '../components';
import { Window } from '../layouts';
import { BooleanLike } from 'common/react';

const hereticRed = {
  color: '#e03c3c',
};

const hereticBlue = {
  fontWeight: 'bold',
  color: '#2185d0',
};

const hereticPurple = {
  fontWeight: 'bold',
  color: '#bd54e0',
};

const hereticGreen = {
  fontWeight: 'bold',
  color: '#20b142',
};

const hereticYellow = {
  fontWeight: 'bold',
  color: 'yellow',
};

type Knowledge = {
  path: string;
  name: string;
  desc: string;
  gainFlavor: string;
  cost: number;
  disabled: boolean;
  hereticPath: string;
  color: string;
}

type KnowledgeInfo = {
  learnableKnowledge: Knowledge[];
  learnedKnowledge: Knowledge[];
}

type Objective = {
  count: number;
  name: string;
  explanation: string;
}

type Info = {
  charges: number;
  total_sacrifices: number;
  ascended: BooleanLike;
  objectives: Objective[];
};

const IntroductionSection = () => {
  return (
    <Stack
      justify="space-evenly"
      height="100%"
      width="100%">
      <Stack.Item grow>
        <Section title="You are the Heretic!" fill>
          <Stack vertical>
            <FlavorSection />
            <Stack.Divider />

            <GuideSection />
            <Stack.Divider />

            <InformationSection />
            <Stack.Divider />

            <ObjectivePrintout />
          </Stack>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const FlavorSection = () => {
  return (
    <Stack.Item>
      <Stack vertical>
        <Stack.Item>
          Another day at a meaningless job. You feel a&nbsp;
          <span style={hereticBlue}>shimmer</span>
          &nbsp;around you, as a realization of something&nbsp;
          <span style={hereticRed}>strange</span>
          &nbsp;in the air unfolds.
        </Stack.Item>
        <Stack.Item textAlign="center">
          The <span style={hereticPurple}>Gates of Mansus</span>
          &nbsp;open up to your mind.
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
};

const GuideSection = () => {
  return (
    <Stack.Item>
      <Stack vertical>
        <Stack.Item>
          - Around the station are multiple&nbsp;
          <span style={hereticPurple}>Influences</span>: breaches
          in the fabric of reality only visible to people like you.&nbsp;
          <b>Right click</b> on them to harvest them for&nbsp;
          <span style={hereticBlue}>knowledge points</span> -
          doing this makes them visible to all, and those
          with keen eyes may <i>notice</i> you.
        </Stack.Item>
        <Stack.Item>
          - The Old Ones have special interest in certain crewmembers.
          Capture them and bring them to a&nbsp;
          <span style={hereticGreen}>transmutation circle</span> to&nbsp;
          <span style={hereticRed}>sacrifice</span> them for&nbsp;
          <span style={hereticBlue}>knowledge points</span>.&nbsp;
          <span style={hereticRed}>
            They must be in critical or worse condition.
          </span>
          &nbsp;You can <b>only</b> sacrifice these targets.
        </Stack.Item>
        <Stack.Item>
          - Your heart has transformed into a&nbsp;
          <span style={hereticRed}>Living Heart</span>. Use it
          to track your <span style={hereticRed}>sacrifice targets</span>,
          but be warned: pulsing it will produce a
          heartbeat sound that nearby people may hear.
          Should you lose your heart, you can complete a ritual to regain it.
        </Stack.Item>
        <Stack.Item>
          - Complete all of your objectives and
          the <span style={hereticYellow}>final ritual</span> to
          become all powerful!
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
};

const InformationSection = (props, context) => {
  const { data } = useBackend<Info>(context);
  const {
    charges,
    total_sacrifices,
    ascended,
  } = data;
  return (
    <Stack.Item>
      <Stack vertical fill>
        {!!ascended && (
          <Stack.Item>
            <Stack align="center">
              <Stack.Item>
                You have
              </Stack.Item>
              <Stack.Item fontSize="24px">
                <Box inline color="yellow">ASCENDED</Box>!
              </Stack.Item>
            </Stack>
          </Stack.Item>
        )}
        <Stack.Item>
          You have <b>{charges || 0}</b>&nbsp;
          <span style={hereticBlue}>knowledge point{charges !== 1 ? "s":""}</span>.
        </Stack.Item>
        <Stack.Item>
          You have made a total of&nbsp;
          <b>{total_sacrifices || 0}</b>&nbsp;
          <span style={hereticRed}>sacrifices</span>.
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
};

const ObjectivePrintout = (props, context) => {
  const { data } = useBackend<Info>(context);
  const {
    objectives,
  } = data;
  return (
    <Stack.Item>
      <Stack vertical fill>
        <Stack.Item bold>
          In order to ascend, you have these tasks to fulfill:
        </Stack.Item>
        <Stack.Item>
          {!objectives && "None!"
          || objectives.map(objective => (
            <Stack.Item key={objective.count}>
              {objective.count}: {objective.explanation}
            </Stack.Item>
          )) }
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
};

const ResearchedKnowledge = (props, context) => {
  const { data } = useBackend<KnowledgeInfo>(context);
  const {
    learnedKnowledge,
  } = data;

  return (
    <Stack.Item grow>
      <Section
        title="Researched Knowledge"
        fill
        scrollable>
        <Stack vertical>
          {!learnedKnowledge.length && "None!"
            || learnedKnowledge.map(learned => (
              <Stack.Item key={learned.name}>
                <Button
                  width="100%"
                  color={learned.color}
                  content={`${learned.hereticPath} - ${learned.name}`}
                  tooltip={learned.desc} />
              </Stack.Item>
            )) }
        </Stack>
      </Section>
    </Stack.Item>
  );
};

const KnowledgeShop = (props, context) => {
  const { data, act } = useBackend<KnowledgeInfo>(context);
  const {
    learnableKnowledge,
  } = data;

  return (
    <Stack.Item grow>
      <Section title="Potential Knowledge" fill scrollable>
        {!learnableKnowledge.length && "None!"
          || learnableKnowledge.map(toLearn => (
            <Stack.Item key={toLearn.name} mb={1}>
              <Button
                width="100%"
                color={toLearn.color}
                disabled={toLearn.disabled}
                content={`${toLearn.hereticPath} - ${toLearn.cost > 0
                  ? `${toLearn.name}: ${toLearn.cost}
                  point${toLearn.cost !== 1 ? "s":""}`
                  : toLearn.name}`}
                tooltip={toLearn.desc}
                onClick={() => act("research", { path: toLearn.path })} />
              {!!toLearn.gainFlavor && (
                <Box>
                  <i>{toLearn.gainFlavor}</i>
                </Box>
              )}
            </Stack.Item>
          )) }
      </Section>
    </Stack.Item>
  );
};

const ResearchInfo = (props, context) => {
  const { data } = useBackend<Info>(context);
  const {
    charges,
  } = data;

  return (
    <Stack
      justify="space-evenly"
      height="100%"
      width="100%">
      <Stack.Item grow>
        <Stack vertical height="100%">
          <Stack.Item fontSize="20px" textAlign="center">
            You have <b>{charges || 0}</b>&nbsp;
            <span style={hereticBlue}>knowledge point{charges !== 1 ? "s":""}</span> to spend.
          </Stack.Item>
          <Stack.Item grow>
            <Stack height="100%">
              <ResearchedKnowledge />
              <KnowledgeShop />
            </Stack>
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};


export const AntagInfoHeretic = (props, context) => {
  const { data } = useBackend<Info>(context);
  const {
    ascended,
  } = data;

  const [
    currentTab,
    setTab,
  ] = useLocalState(context, 'currentTab', 0);

  return (
    <Window
      width={625}
      height={575}>
      <Window.Content
        style={{
          // 'font-family': 'Times New Roman',
          // 'fontSize': '20px',
          "background-image": "none",
          "background": ascended
            ? "radial-gradient(circle, rgba(24,9,9,1) 54%, rgba(31,10,10,1) 60%, rgba(46,11,11,1) 80%, rgba(47,14,14,1) 100%);"
            : "radial-gradient(circle, rgba(9,9,24,1) 54%, rgba(10,10,31,1) 60%, rgba(21,11,46,1) 80%, rgba(24,14,47,1) 100%);",
        }}>
        <Stack vertical fill>
          <Stack.Item>
            <Tabs fluid>
              <Tabs.Tab
                icon="info"
                selected={currentTab === 0}
                onClick={() => setTab(0)}>
                Information
              </Tabs.Tab>
              <Tabs.Tab
                icon={currentTab === 1 ? "book-open":"book"}
                selected={currentTab === 1}
                onClick={() => setTab(1)}>
                Research
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>
            {currentTab === 0 && (
              <IntroductionSection />
            ) || (
              <ResearchInfo />
            )}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
