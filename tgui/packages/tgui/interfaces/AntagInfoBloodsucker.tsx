import { BooleanLike } from "../../common/react";
import { useBackend, useLocalState } from "../../tgui/backend";
import { Section, Stack, Tabs } from "../../tgui/components";
import { Window } from '../../tgui/layouts';

type Objective = {
  count: number;
  name: string;
  explanation: string;
  complete: BooleanLike;
  was_uncompleted: BooleanLike;
  reward: number;
}

type Info = {
  objectives: Objective[];
};

const ObjectivePrintout = (props, context) => {
  const { data } = useBackend<Info>(context);
  const {
    objectives,
  } = data;
  return (
    <Stack vertical>
      <Stack.Item bold>
        Your current objectives:
      </Stack.Item>
      <Stack.Item>
        {!objectives && "None!"
        || objectives.map(objective => (
          <Stack.Item key={objective.count}>
            #{objective.count}: {objective.explanation}
          </Stack.Item>
        )) }
      </Stack.Item>
    </Stack>
  );
};

const BloodsuckerIntro = () => {
  return (
    <Stack vertical fill>
      <Stack.Item minHeight="20rem">
        <Section scrollable fill>
          <Stack vertical>
            <Stack.Item textColor="red" fontSize="20px">
              You are a Bloodsucker, an undead blood-seeking monster
              living aboard Space Station 13
            </Stack.Item>
            <Stack.Item>
              <ObjectivePrintout />
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section fill title="Strengths and Weaknesses">
          <Stack vertical>
            <Stack.Item>
              <span>
                You regenerate your health slowly, you&#39;re weak to fire,
                and you depend on blood to survive. Don&#39;t allow your
                blood to run too low, or you&#39;ll enter a
              </span><span className={'color-red'}> Frenzy</span>!<br />
              <span>
                Beware of your Humanity level! The more Humanity you
                lose, the easier it is to fall into a <span className={'color-red'}> Frenzy</span>!
              </span><br />
              <span>
                Avoid using your Feed ability while near others, or
                else you will risk <i>breaking the Masquerade</i>!
              </span>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section fill title="Items">
          <Stack vertical>
            <Stack.Item>
              <span>
                Rest in a <b>Coffin</b> to claim it,
                and that area, as your lair.
              </span><br />
              <span>
                Examine your new structures
                to see how they function!
              </span><br />
              <span>
                Medical and Genetic Analyzers can sell you out,
                your Masquerade ability will hide your identity to prevent this.
              </span><br />
            </Stack.Item>
            <Stack.Item>
              <Section textAlign="center" textColor="red" fontSize="20px">
                Other Bloodsuckers are not necessarily your friends,
                but your survival may depend on cooperation. Betray them at your
                own discretion and peril.
              </Section>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

export const AntagInfoBloodsucker = (props, context) => {
  const [tab, setTab] = useLocalState(context, 'tab', 1);
  return (
    <Window
      width={620}
      height={580}
      theme="spookyconsole">
      <Window.Content>
        <Tabs>
          <Tabs.Tab
            icon="list"
            lineHeight="23px"
            selected={tab === 1}
            onClick={() => setTab(1)}>
            Introduction
          </Tabs.Tab>
        </Tabs>
        {tab === 1 && (
          <BloodsuckerIntro />
        )}
      </Window.Content>
    </Window>
  );
};
