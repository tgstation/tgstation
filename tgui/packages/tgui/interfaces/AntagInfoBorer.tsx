// THIS IS A MONKESTATION UI FILE

import { resolveAsset } from '../assets';
import { BooleanLike } from 'common/react';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Divider, Dropdown, Section, Stack, Tabs } from '../components';
import { Window } from '../layouts';

type Objective = {
  count: number;
  name: string;
  explanation: string;
  complete: BooleanLike;
  was_uncompleted: BooleanLike;
  reward: number;
};

type BorerInformation = {
  ability: AbilityInfo[];
};

type AbilityInfo = {
  ability_name: string;
  ability_explanation: string;
  ability_icon: string;
};

type Info = {
  objectives: Objective[];
};

const ObjectivePrintout = (props: any) => {
  const { data } = useBackend<Info>();
  const { objectives } = data;
  return (
    <Stack vertical>
      <Stack.Item bold>Your current objectives:</Stack.Item>
      <Stack.Item>
        {(!objectives && 'None!') ||
          objectives.map((objective) => (
            <Stack.Item key={objective.count}>
              #{objective.count}: {objective.explanation}
            </Stack.Item>
          ))}
      </Stack.Item>
    </Stack>
  );
};

export const AntagInfoBorer = (props: any) => {
  const [tab, setTab] = useLocalState('tab', 1);
  return (
    <Window width={620} height={580} theme="ntos_cat">
      <Window.Content>
        <Tabs>
          <Tabs.Tab
            icon="list"
            lineHeight="23px"
            selected={tab === 1}
            onClick={() => setTab(1)}>
            Introduction
          </Tabs.Tab>
          <Tabs.Tab
            icon="list"
            lineHeight="23px"
            selected={tab === 2}
            onClick={() => setTab(2)}>
            Ability explanations
          </Tabs.Tab>
          <Tabs.Tab
            icon="list"
            lineHeight="23px"
            selected={tab === 3}
            onClick={() => setTab(3)}>
            Borer side-effects
          </Tabs.Tab>
          <Tabs.Tab
            icon="list"
            lineHeight="23px"
            selected={tab === 4}
            onClick={() => setTab(4)}>
            Basic chemical information
          </Tabs.Tab>
        </Tabs>
        {tab === 1 && <MainPage />}
        {tab === 2 && <BorerAbilities />}
        {tab === 3 && <DisadvantageInfo />}
        {tab === 4 && <BasicChemistry />}
      </Window.Content>
    </Window>
  );
};

const MainPage = () => {
  return (
    <Stack vertical fill>
      <Stack.Item minHeight="14rem">
        <Section scrollable fill>
          <Stack vertical>
            <Stack.Item textColor="red" fontSize="20px">
              You are a Cortical Borer, a creature that crawls into peoples
              ear&#39;s to then settle on the brain
            </Stack.Item>
            <Stack.Item>
              <ObjectivePrintout />
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Item minHeight="35rem">
        <Section fill title="Essentials">
          <Stack vertical>
            <Stack.Item>
              <span className={'color-red'}>Host and you</span>
              <br />
              <span>
                You depend on a host for survival and reproduction, you slowly
                regenerate your health whilst inside of a host but whilst
                outside of one you can be squished by anyone stepping onto you,
                killing you.
              </span>
              <br />
              <br />
              <span>
                When speaking, you will directly communicate to your host, by
                adding &quot; ; &quot; to the start of your message you will
                instead speak to the hivemind of all the borers
              </span>
              <br />
              <br />
              <span className={'color-red'}>
                Creating resources and their uses
              </span>
              <br />
              <br />
              <span>
                While inside of a host you will slowly generate internal
                chemicals, evolution points and chemical points.
              </span>
              <br />
              <br />
              <span>
                <span className={'color-red'}>Internal chemical points </span>
                are used for using most of the abilities, their main use is in
                injecting chemicals into your host using the chemical injector
              </span>
              <br />
              <br />
              <span>
                <span className={'color-red'}>Evolution points </span>
                are mostly used in the evolution tree and choosing your focus,
                both of those being essential to surviving and completing your
                objectives
              </span>
              <br />
              <br />
              <span>
                <span className={'color-red'}>Chemical evolution points </span>
                are used in learning new chemicals from your possible list of
                learn-able chemicals, along with learning chemicals from the
                hosts blood for both their benefit and your objectives
              </span>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const BorerAbilities = (props: any) => {
  const { act, data } = useBackend<BorerInformation>();
  return (
    <Stack vertical fill>
      <Stack.Item minHeight="42rem">
        <AbilitySection />
      </Stack.Item>
    </Stack>
  );
};

const AbilitySection = (props: any) => {
  const { act, data } = useBackend<BorerInformation>();
  const { ability } = data;
  if (!ability) {
    return <Section minHeight="300px" />;
  }

  const [selectedAbility, setSelectedAbility] = useLocalState(
    'ability',
    ability[0]
  );

  return (
    <Section
      fill
      scrollable={!!ability}
      title="Abilities"
      buttons={
        <Button
          icon="info"
          tooltipPosition="left"
          tooltip={
            'Select an ability using the dropdown menu for an in-depth explanation.'
          }
        />
      }>
      <Stack>
        <Stack.Item grow>
          <Dropdown
            displayText={selectedAbility.ability_name}
            selected={selectedAbility.ability_name}
            width="100%"
            options={ability.map((abilities) => abilities.ability_name)}
            onSelected={(abilityName: string) =>
              setSelectedAbility(
                ability.find((p) => p.ability_name === abilityName) ||
                  ability[0]
              )
            }
          />
          {selectedAbility && (
            <Box
              position="absolute"
              height="12rem"
              as="img"
              src={resolveAsset(`borer.${selectedAbility.ability_icon}.png`)}
            />
          )}
          <Divider Vertical />
        </Stack.Item>
        <Stack.Divider />
        <Stack.Item scrollable grow={1} fontSize="16px">
          {selectedAbility && selectedAbility.ability_explanation}
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const DisadvantageInfo = () => {
  return (
    <Stack vertical fill>
      <Stack.Item minHeight="42rem">
        <Section fill title="How i didnt kill my host 101">
          <Stack vertical>
            <Stack.Item>
              <span>
                Whilst in a host you can provide many benefits, but also
                dangerous side-effects due to your sensitive brain manipulation.
                Here&apos;s how to prevent them
              </span>
              <br />
              <br />
              <span>
                1. Whilst inside of a host we will passivelly make their health
                unable to be read due to our body obstructing the somatosensory
                cortex signals
              </span>
              <br />
              <span>
                Prevention method - observe the hosts health carefully using
                &quot;Check Blood&quot;, heal any injuries and inform the host
                about any major wounds
              </span>
              <br />
              <br />
              <span>
                2. Whilst inside of a host we will slowly deal toxin damage
                over-time up to 80 in total. This can be deadly when combined
                with any amount of brute/burn damage
              </span>
              <br />
              <span>
                Prevention method - observe the hosts health carefully using
                &quot;Check Blood&quot;, inject toxin damage restoring chemicals
              </span>
              <br />
              <br />
              <span>
                3. Whilst inside of a host most of our actions will deal brain
                damage including generating evolution and chemical evolution
                points, due to either sensetivelly manipulating the host&apos;s
                neurons or needing to &quot;aquire&quot; more space for growth
              </span>
              <br />
              <span>
                Prevention method - observe the hosts health carefully using
                &quot;Check Blood&quot;, inject mannitol to cure brain damage,
                inject neurine for any brain traumas that might have been a
                result of our expansion
              </span>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const BasicChemistry = () => {
  return (
    <Stack vertical fill>
      <Stack.Item minHeight="45rem">
        <Section fill title="What does the eldritch essence do again?">
          <Stack vertical>
            <Stack.Item>
              <span>
                Secreting chemicals has proven difficult for many borers, yet
                you have prepared carefully for your first expendition into the
                hosts body. Lets not mess it up by killing them.
              </span>
              <br />
              <span>
                This is only the bare minimum of what we should get knowledgable
                about
              </span>
              <br />
              <br />
              <span>Libital</span>
              <br />
              <span>
                Quickly restores our hosts
                <span className={'color-red'}> Brute </span>damage at the cost
                of causing slight liver damage.
              </span>
              <br />
              <br />
              <span>Lenturi</span>
              <br />
              <span>
                Quickly restores our hosts
                <span className={'color-yellow'}> Burn </span>damage at the cost
                of causing slight stomach damage and slowing down our host as
                long as its in their system
              </span>
              <br />
              <br />
              <span>Seiver</span>
              <br />
              <span>
                Heals<span className={'color-green'}> Toxin </span>damage at the
                slight cost of heart damage
              </span>
              <br />
              <br />
              <span>Convermol</span>
              <br />
              <span>
                Quickly restores our hosts
                <span className={'color-blue'}> Oxygen </span>damage at the cost
                of causing 1:5th the toxin damage to our host
              </span>
              <br />
              <span>Overdose: 35 units</span>
              <br />
              <br />
              <span>Unknown Methamphetamine Isomer</span>
              <br />
              <span>
                A specially advanced version of what our hosts call
                &quot;meth&quot;. It has all the benefits of meth without
                causing any brain damage to the host and has a higher overdose
              </span>
              <br />
              <span>Overdose: 40 units</span>
              <br />
              <br />
              <span>Spaceacillin</span>
              <br />
              <span>
                Helps our hosts immune system, making it quickly gain resistance
                to any pathogens inside of the host.
              </span>
              <br />
              <span>
                While being effective it will most likelly not be enough to
                fully cure our host
              </span>
              <br />
              <br />
              <span>multiver</span>
              <br />
              <span>
                Purges toxins and medicines inside of our host while healing
                <span className={'color-green'}> Toxin </span>damage, at the
                cost of slight lung damage.
              </span>
              <br />
              <span>
                The more unique medicines the host has in their system, the more
                this chemical heals.
              </span>
              <br />
              <span>At 2 unique medicines it no longer purges medicines</span>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
    </Stack>
  );
};
