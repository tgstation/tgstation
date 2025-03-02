import { useState } from 'react';
import {
  Box,
  Button,
  DmIcon,
  Flex,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import {
  Objective,
  ObjectivePrintout,
  ReplaceObjectivesButton,
} from './common/Objectives';

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

type IconParams = {
  icon: string;
  state: string;
  frame: number;
  dir: number;
  moving: BooleanLike;
};

type Knowledge = {
  path: string;
  icon_params: IconParams;
  name: string;
  desc: string;
  gainFlavor: string;
  cost: number;
  bgr: string;
  disabled: BooleanLike;
  finished: BooleanLike;
  ascension: BooleanLike;
};

type KnowledgeInfo = {
  knowledge_tiers: KnowledgeTier[];
};

type KnowledgeTier = {
  nodes: Knowledge[];
};

type Info = {
  charges: number;
  total_sacrifices: number;
  ascended: BooleanLike;
  objectives: Objective[];
  can_change_objective: BooleanLike;
};

const IntroductionSection = (props) => {
  const { data, act } = useBackend<Info>();
  const { objectives, ascended, can_change_objective } = data;

  return (
    <Stack justify="space-evenly" height="100%" width="100%">
      <Stack.Item grow>
        <Section title="You are the Heretic!" fill fontSize="14px">
          <Stack vertical>
            <FlavorSection />
            <Stack.Divider />
            <GuideSection />
            <Stack.Divider />
            <InformationSection />
            <Stack.Divider />
            {!ascended && (
              <Stack.Item>
                <ObjectivePrintout
                  fill
                  titleMessage={
                    can_change_objective
                      ? 'In order to ascend, you have these tasks to fulfill'
                      : 'Use your dark knowledge to fulfil your personal goal'
                  }
                  objectives={objectives}
                  objectiveFollowup={
                    <ReplaceObjectivesButton
                      can_change_objective={can_change_objective}
                      button_title={'Reject Ascension'}
                      button_colour={'red'}
                      button_tooltip={
                        'Turn your back on the Mansus to accomplish a task of your choosing. Selecting this option will prevent you from ascending!'
                      }
                    />
                  }
                />
              </Stack.Item>
            )}
          </Stack>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const FlavorSection = () => {
  return (
    <Stack.Item>
      <Stack vertical textAlign="center" fontSize="14px">
        <Stack.Item>
          <i>
            Another day at a meaningless job. You feel a&nbsp;
            <span style={hereticBlue}>shimmer</span>
            &nbsp;around you, as a realization of something&nbsp;
            <span style={hereticRed}>strange</span>
            &nbsp;in the air unfolds. You look inwards and discover something
            that will change your life.
          </i>
        </Stack.Item>
        <Stack.Item>
          <b>
            The <span style={hereticPurple}>Gates of Mansus</span>
            &nbsp;open up to your mind.
          </b>
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
};

const GuideSection = () => {
  return (
    <Stack.Item>
      <Stack vertical fontSize="12px">
        <Stack.Item>
          - Find reality smashing&nbsp;
          <span style={hereticPurple}>influences</span>
          &nbsp;around the station invisible to the normal eye and&nbsp;
          <b>right click</b> on them to harvest them for&nbsp;
          <span style={hereticBlue}>knowledge points</span>. Tapping them makes
          them visible to all after a short time. Dreaming of Mansus may help to
          find them.
        </Stack.Item>
        <Stack.Item>
          - Use your&nbsp;
          <span style={hereticRed}>Living Heart action</span>
          &nbsp;to track down&nbsp;
          <span style={hereticRed}>sacrifice targets</span>, but be careful:
          Pulsing it will produce a heartbeat sound that nearby people may hear.
          This action is tied to your <b>heart</b> - if you lose it, you must
          complete a ritual to regain it.
        </Stack.Item>
        <Stack.Item>
          - Draw a&nbsp;
          <span style={hereticGreen}>transmutation rune</span> by using a
          drawing tool (a pen or crayon) on the floor while having&nbsp;
          <span style={hereticGreen}>Mansus Grasp</span>
          &nbsp;active in your other hand. This rune allows you to complete
          rituals and sacrifices.
        </Stack.Item>
        <Stack.Item>
          - Follow your <span style={hereticRed}>Living Heart</span> to find
          your targets. Bring them back to a&nbsp;
          <span style={hereticGreen}>transmutation rune</span> in critical or
          worse condition to&nbsp;
          <span style={hereticRed}>sacrifice</span> them for&nbsp;
          <span style={hereticBlue}>knowledge points</span>. The Mansus{' '}
          <b>ONLY</b> accepts targets pointed to by the&nbsp;
          <span style={hereticRed}>Living Heart</span>.
        </Stack.Item>
        <Stack.Item>
          - Make yourself a <span style={hereticYellow}>focus</span> to be able
          to cast various advanced spells to assist you in acquiring harder and
          harder sacrifices.
        </Stack.Item>
        <Stack.Item>
          - Accomplish all of your objectives to be able to learn the{' '}
          <span style={hereticYellow}>final ritual</span>. Complete the ritual
          to become all powerful!
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
};

const InformationSection = (props) => {
  const { data } = useBackend<Info>();
  const { charges, total_sacrifices, ascended } = data;
  return (
    <Stack.Item>
      <Stack vertical fill>
        {!!ascended && (
          <Stack.Item>
            <Stack align="center">
              <Stack.Item>You have</Stack.Item>
              <Stack.Item fontSize="24px">
                <Box inline color="yellow">
                  ASCENDED
                </Box>
                !
              </Stack.Item>
            </Stack>
          </Stack.Item>
        )}
        <Stack.Item>
          You have <b>{charges || 0}</b>&nbsp;
          <span style={hereticBlue}>
            knowledge point{charges !== 1 ? 's' : ''}
          </span>
          .
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

const KnowledgeTree = (props) => {
  const { data, act } = useBackend<KnowledgeInfo>();
  const { knowledge_tiers } = data;

  return (
    <Section title="Research Tree" fill scrollable>
      <Box textAlign="center" fontSize="32px">
        <span style={hereticYellow}>DAWN</span>
      </Box>
      <Stack vertical>
        {knowledge_tiers.length === 0
          ? 'None!'
          : knowledge_tiers.map((tier, i) => (
              <Stack.Item key={i}>
                <Flex
                  justify="center"
                  align="center"
                  backgroundColor="transparent"
                  wrap="wrap"
                >
                  {tier.nodes.map((node) => (
                    <Flex.Item key={node.name}>
                      <Button
                        color="transparent"
                        tooltip={`${node.name}:
                          ${node.desc}`}
                        onClick={
                          node.disabled || node.finished
                            ? undefined
                            : () => act('research', { path: node.path })
                        }
                        width={node.ascension ? '192px' : '64px'}
                        height={node.ascension ? '192px' : '64px'}
                        m="8px"
                        style={{
                          borderRadius: '50%',
                        }}
                      >
                        <DmIcon
                          icon="icons/ui_icons/antags/heretic/knowledge.dmi"
                          icon_state={
                            node.disabled
                              ? 'node_locked'
                              : node.finished
                                ? 'node_finished'
                                : node.bgr
                          }
                          height={node.ascension ? '192px' : '64px'}
                          width={node.ascension ? '192px' : '64px'}
                          top="0px"
                          left="0px"
                          position="absolute"
                        />
                        <DmIcon
                          icon={node.icon_params.icon}
                          icon_state={node.icon_params.state}
                          frame={node.icon_params.frame}
                          direction={node.icon_params.dir}
                          movement={node.icon_params.moving}
                          height={node.ascension ? '152px' : '64px'}
                          width={node.ascension ? '152px' : '64px'}
                          top={node.ascension ? '20px' : '0px'}
                          left={node.ascension ? '20px' : '0px'}
                          position="absolute"
                        />
                        <Box
                          position="absolute"
                          top="0px"
                          left="0px"
                          backgroundColor="black"
                          textColor="white"
                          bold
                        >
                          {!node.finished &&
                            (node.cost > 0 ? node.cost : 'FREE')}
                        </Box>
                      </Button>
                      {!!node.ascension && (
                        <Box textAlign="center" fontSize="32px">
                          <span style={hereticPurple}>DUSK</span>
                        </Box>
                      )}
                    </Flex.Item>
                  ))}
                </Flex>
                <hr />
              </Stack.Item>
            ))}
      </Stack>
    </Section>
  );
};

const ResearchInfo = (props) => {
  const { data } = useBackend<Info>();
  const { charges } = data;

  return (
    <Stack vertical fill>
      <Stack.Item fontSize="20px" textAlign="center">
        You have <b>{charges || 0}</b>&nbsp;
        <span style={hereticBlue}>
          knowledge point{charges !== 1 ? 's' : ''}
        </span>{' '}
        to spend.
      </Stack.Item>
      <Stack.Item grow>
        <KnowledgeTree />
      </Stack.Item>
    </Stack>
  );
};

export const AntagInfoHeretic = (props) => {
  const { data } = useBackend<Info>();
  const { ascended } = data;

  const [currentTab, setTab] = useState(0);

  return (
    <Window width={675} height={635}>
      <Window.Content
        style={{
          backgroundImage: 'none',
          background: ascended
            ? 'radial-gradient(circle, rgba(24,9,9,1) 54%, rgba(31,10,10,1) 60%, rgba(46,11,11,1) 80%, rgba(47,14,14,1) 100%);'
            : 'radial-gradient(circle, rgba(9,9,24,1) 54%, rgba(10,10,31,1) 60%, rgba(21,11,46,1) 80%, rgba(24,14,47,1) 100%);',
        }}
      >
        <Stack vertical fill>
          <Stack.Item>
            <Tabs fluid>
              <Tabs.Tab
                icon="info"
                selected={currentTab === 0}
                onClick={() => setTab(0)}
              >
                Information
              </Tabs.Tab>
              <Tabs.Tab
                icon={currentTab === 1 ? 'book-open' : 'book'}
                selected={currentTab === 1}
                onClick={() => setTab(1)}
              >
                Research
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>
            {(currentTab === 0 && <IntroductionSection />) || <ResearchInfo />}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
