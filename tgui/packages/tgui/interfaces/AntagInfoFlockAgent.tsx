import '../styles/interfaces/AntagInfoFlockAgent.scss';

import { useState } from 'react';
import { resolveAsset } from 'tgui/assets';
import {
  AnimatedNumber,
  Box,
  Button,
  Divider,
  DmIcon,
  Image,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { useBackend } from '../backend';
import { Window } from '../layouts';
import { logger } from '../logging';
import { type Objective, ObjectivePrintout } from './common/Objectives';

type IconParams = {
  icon: string;
  state: string;
  frame: number;
  dir: number;
  moving: BooleanLike;
};

type Recipe = {
  path: string;
  name: string;
  icon_params: IconParams;
  cost: number;
  desc: string;
};

type Info = {
  resources: number;
  // lord_name: string;  some day, but not now
  recipes: Recipe[];
  objectives: Objective[];
};

const BriefingSection = () => {
  const { data } = useBackend<Info>();
  const { objectives } = data;
  return (
    <Stack>
      <Stack.Item grow>
        <Section title="You are the Flock Agent!" fill fontSize="16px">
          <Stack vertical>
            <Stack.Item>
              <Stack vertical textAlign="center" fontSize="14px">
                <Stack>
                  <Stack.Item>
                    <Image
                      style={{
                        borderStyle: 'solid',
                        borderColor: '#56be97',
                      }}
                      src={resolveAsset('fixime.png')}
                    />
                  </Stack.Item>
                  <Stack.Item>
                    Hi I'm not your Lord! I'm, uh, my name is Fi.xi.me,
                    something went wrong, I was given a sheet of dataglass and
                    told I'm now your handler, I have no idea what I'm doing, I
                    write reports about the outcomes of mission and I have no
                    business being here to oversee things oh no oh no oh no...
                  </Stack.Item>
                </Stack>

                <Stack.Divider />
                <Stack.Item>
                  Sorry! Sorry. Let's, uh. Okay, let's see what you're slated
                  for doing for, uhm, well, I don't actually know why you're
                  doing this but you're doing this:
                </Stack.Item>
                <Divider />
                <Stack.Item grow>
                  <ObjectivePrintout
                    fill
                    objectives={objectives}
                    objectiveFollowup={
                      <Box bold textColor="teal">
                        Your Lord demands you achieve all of these orders.
                      </Box>
                    }
                  />
                </Stack.Item>
                <Stack.Divider />
                <Stack.Item>
                  In theory once you get all those done you'd be able to go back
                  to the outpost but all the control panels are <b>still</b> on
                  fire and -- is fire supposed to be purple??
                </Stack.Item>
                <Stack.Item>
                  <Button
                    tooltip="unimplemented. be sad, cry many tears, for a bird cannot fly"
                    color="teal"
                    height="64px"
                    m="8px"
                    style={{
                      borderRadius: '20%',
                    }}
                    disabled={true}
                    verticalAlignContent="middle"
                    fontSize="20px"
                  >
                    {' '}
                    Call for Pod{' '}
                  </Button>
                </Stack.Item>
              </Stack>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const AdviceSection = () => {
  return (
    <Section title="Hasty Advice" fill scrollable>
      <Stack vertical>
        <Stack.Item>
          - You're pretty fragile! Your unarmed attack is a peck that might as
          well be a light pet for how much damage you do. Don't get in fights
          and use your radiodive to run if you can!
        </Stack.Item>
        <Stack.Item>
          - You aren't immune to temperature extremes! Space is too cold for you
          and I should not have to caution you like some vatling about not
          walking into a raging plasma fire, but, just because you don't need to
          breathe doesn't make you some kind of invincible machine, okay!
        </Stack.Item>
        <Stack.Item>- You have access to every radio channel!</Stack.Item>
        <Stack.Item>
          - You can also use :f to use our dedicated flock channel. Nothing else
          but flock creatures like us can tune to this, I think.
        </Stack.Item>
        <Stack.Item>
          - You can process anything you can fit into your internal storage into
          resources, but it takes time, and also it needs to be fully processed
          before you can use any of it.
        </Stack.Item>
        <Stack.Item>
          - Being around the aliens' communication transmission equipment,
          "telecomms" I think they call it, will heal you! I have no idea why.
          It doesn't make any sense.
        </Stack.Item>
        <Stack.Item>
          - You're fully healed when you come out of radiodive, unless you were
          very damaged when you went into it. If that happens, get to their
          telecomms place right away!
        </Stack.Item>
        <Stack.Item>
          - Yeah I know your options for things to create don't make a lot of
          sense, we're not sure why either. Please don't hit yourself with the
          medical wrench, I'm pretty sure they don't work like that.
        </Stack.Item>
        <Stack.Item>
          - If you can process an item, examining it will tell you how long
          it'll take and how many resources it'll give you. Your processor works
          best with raw materials, but it also takes longer.
        </Stack.Item>
        <Stack.Item>
          - Radiodiving will cause anything that can't also be converted into
          radio waves to be dropped, and this includes anything you're
          processing!
        </Stack.Item>
        <Stack.Item>
          - To cancel processing or making something, take it out of you. Most
          items won't even show any signs of damage. Our technology is quite
          good at keeping structure intact until the last minute.
        </Stack.Item>
        <Stack.Item>
          - You aren't immune to fire but you've got a built-in fire
          extinguisher. However, don't keep setting yourself on fire for fun,
          your body can't clear all the heat fast enough.
        </Stack.Item>
        <Stack.Item>
          - You can resurrect a fallen comrade, but it costs a lot of resources
          and time! Make sure to drag them to a safe place first!
        </Stack.Item>
        <Stack.Item>
          - Uhh there's probably more but I forgot to log it to my data block
          this morning uhhhmm your self repair system is currently broken so try
          to not die
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const RecipesSection = () => {
  const { data } = useBackend<Info>();
  const { recipes, resources } = data;
  return (
    <Section title="Available Templates" fill scrollable>
      <Stack vertical>
        <Stack.Item>
          BARELY FUNCTIONAL INTERFACE IS REAL AND IT CAN HURT YOU
          <br />I TRIED TO MAKE THIS PIECE OF SHIT LOOK GOOD AND I RAN OUT OF
          TIME HAHAHAHA ;_;
        </Stack.Item>
        <Stack.Item textAlign="center" fontSize="14px">
          <Box inline bold>
            You have <AnimatedNumber value={Math.round(resources)} /> resources
          </Box>
        </Stack.Item>
        <Stack.Divider />
        {recipes.length === 0
          ? 'None!'
          : recipes.map((recipe, i) => {
              const enabled = resources >= recipe.cost;
              return (
                <Stack.Item key={i}>
                  <Box className="candystripe">
                    <Stack
                      justify="center"
                      align="center"
                      backgroundColor="transparent"
                      wrap="wrap"
                    >
                      <RecipeRow recipe={recipe} enabled={enabled} />
                    </Stack>
                  </Box>
                </Stack.Item>
              );
            })}
      </Stack>
    </Section>
  );
};

type RecipeRowProps = {
  recipe: Recipe;
  enabled: BooleanLike;
};

const RecipeRow = (props: RecipeRowProps) => {
  const { recipe, enabled } = props;
  const { act } = useBackend<Info>();
  return (
    <Stack.Item key={recipe.name}>
      <Stack fill>
        <Stack.Item>
          <DmIcon
            icon={recipe.icon_params?.icon}
            icon_state={recipe.icon_params?.state}
            frame={recipe.icon_params?.frame}
            direction={recipe.icon_params?.dir}
            movement={recipe.icon_params?.moving}
            height="64px"
            width="64px"
            top="0px"
            left="0px"
          />
          <Box
            backgroundColor="transparent"
            textColor="white"
            bold
            style={{ margin: '2px', borderRadius: '100%' }}
            height="64px"
            width="64px"
            top="0px"
            left="0px"
            verticalAlign="middle"
          >
            COST: {recipe.cost}
          </Box>
        </Stack.Item>
        <Stack.Item>
          <Stack fill vertical>
            <Stack.Item grow bold verticalAlign="middle">
              {recipe.name}
            </Stack.Item>
            <Stack.Item grow verticalAlign="middle">
              {recipe.desc}
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item grow>
          <Button
            color="teal"
            tooltip={'click me to make your dreams come true'}
            onClick={
              enabled
                ? () => act('create', { path: recipe.path })
                : () => logger.warn(`Cannot buy ${recipe.name}`)
            }
            width="64px"
            height="64px"
            m="8px"
            style={{
              borderRadius: '50%',
            }}
            disabled={!enabled}
            verticalAlign="middle"
          >
            Create
          </Button>
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
};

export const AntagInfoFlockAgent = () => {
  const [currentTab, setTab] = useState(0);
  const tabs = [
    {
      label: 'Briefing',
      icon: 'info',
      content: <BriefingSection />,
    },
    {
      label: 'Advice',
      icon: 'comment-dots',
      content: <AdviceSection />,
    },
    {
      label: 'Templates',
      icon: 'cubes',
      content: <RecipesSection />,
    },
  ];

  return (
    <Window width={750} height={635} theme={'flock'}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Tabs fluid>
              {tabs.map((tab, index) => (
                <Tabs.Tab
                  key={index}
                  icon={tab.icon}
                  selected={currentTab === index}
                  onClick={() => setTab(index)}
                >
                  {tab.label}
                </Tabs.Tab>
              ))}
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>{tabs[currentTab].content}</Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
