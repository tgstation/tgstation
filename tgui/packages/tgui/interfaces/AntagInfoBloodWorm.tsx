import { Section, Stack, LabeledList } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { type Objective, ObjectivePrintout } from './common/Objectives';

type Info = {
  objectives: Objective[];
  team: Team;
};

type Team = {
  blood_consumed_total: number;
  times_reproduced_total: number;
};

export const AntagInfoBloodWorm = (props) => {
  const { data } = useBackend<Info>();
  const { objectives, team } = data;
  return (
    <Window width={800} height={500}>
      <Window.Content>
        <Section scrollable fill>
          <Stack vertical>
            <Stack.Item textColor="red" fontSize="20px">
              You are a Blood Worm!
            </Stack.Item>
            <Stack.Item>
              <ObjectivePrintout objectives={objectives} />
            </Stack.Item>
            <Stack.Item>
              <Stack vertical>
                <Stack.Item bold>Your team status:</Stack.Item>
                <Stack.Item>
                  - Total blood consumed: {team.blood_consumed_total} units<br/>
                  - Total times reproduced: {team.times_reproduced_total} times
                </Stack.Item>
              </Stack>
            </Stack.Item>
            <Stack.Item>
              <Section fill title="Powers">
                <LabeledList>
                  <LabeledList.Item label="Space Immunity">
                  You are immune to low temperature, low pressure and don't need to breathe.
                  Your hosts don't have to breathe either, but their bodies remain vulnerable to space.
                  </LabeledList.Item>
                  <LabeledList.Item label="Blood Consumption">
                  You can grow by using Leech Blood or Invade Corpse to consume blood,
                  but synthetic blood, such as from monkeys, has a limit.
                  You can see blood levels at a glance using your HUD,
                  and examining targets yields advanced information on their blood.
                  </LabeledList.Item>
                  <LabeledList.Item label="Growth Stages">
                  You can track your growth in your status tab. Once you're fully grown,
                  you can incubate in a cocoon to reach the next growth stage.
                  Reaching juvenile lets you spit blood, and adults are extremely strong.
                  </LabeledList.Item>
                  <LabeledList.Item label="Ventcrawling">
                  Hatchlings can ventcrawl. Once you grow up, you lose the ability to ventcrawl,
                  becoming reliant on doorcrawling, breaking doors and ID access to move around.
                  Secure a good spot or a host before maturing to a juvenile.
                  </LabeledList.Item>
                  <LabeledList.Item label="Doorcrawling">
                  Hatchlings and juveniles can slide under doors, but adults can't,
                  becoming entirely reliant on breaking doors and ID access to move around.
                  Secure a really good spot or a host before maturing to an adult.
                  </LabeledList.Item>
                  <LabeledList.Item label="Reproduction">
                  Once you enter your final stage of growth as an adult, you can reproduce to create 3 new hatchlings, in exchange for reverting into one yourself.
                  </LabeledList.Item>
                  <LabeledList.Item label="Parasitism">
                  You have the supernatural ability to turn into blood upon command.
                  This allows you to enter a corpse, taking it as your host.
                  </LabeledList.Item>
                  <LabeledList.Item label="Regeneration">
                  You slowly heal over time, taking roughly 5 minutes to fully heal from near-death. While in a host, this translates to recovering blood volume over time.
                  You can inject blood into the damaged tissues of your host to rapidly heal them in exchange for your own health.
                  </LabeledList.Item>
                  <LabeledList.Item label="Life Support">
                  While inside of a host, your host doesn't need vital organs to survive, except for a brain. Lungs let you speak, and a liver lets you process chems.
                  You can insert organs into your host by picking them up and right-clicking on your host with them. This works for cybernetics too.
                  </LabeledList.Item>
                  <LabeledList.Item label="Alien Mind">
                  Your mind is not that of a human. You don't experience cravings, fear, sadness or joy from normal sources, even while in a host.
                  </LabeledList.Item>
                </LabeledList>
              </Section>
            </Stack.Item>
            <Stack.Item>
              <Section fill title="Weaknesses">
                <LabeledList>
                  <LabeledList.Item label="High Heat">
                  Your species is averse to heat and will rapidly burn up in hot environments. Your body is also flammable, so stay away from fires.
                  This weakness applies even while in a host, but can be covered by equipping your host with fire-resistant gear.
                  </LabeledList.Item>
                  <LabeledList.Item label="Bleeding">
                  While in a host, you are transformed entirely into blood. This renders you extremely vulnerable to bleeding wounds.
                  When your host bleeds, it directly damages you, and your hosts continue bleeding even while dead.
                  Your hosts also bleed 50% faster than normal people.
                  </LabeledList.Item>
                  <LabeledList.Item label="Inferior Biology">
                  Your hosts lack your advanced senses, leaving them vulnerable to ordinary impediments like darkness and flashbangs.
                  You can use human tools like night-vision goggles, eye protection and ear protection to circumvent this.
                  </LabeledList.Item>
                  <LabeledList.Item label="Testing">
                  The DeForest corporation has engineered single-use devices for detecting blood worms. They can be ordered by security
                  and take no time to use, but using them is painful for the target and they're really expensive.
                  </LabeledList.Item>
                </LabeledList>
              </Section>
            </Stack.Item>
            <Stack.Item>
              <Section fill title="Tips">
                <LabeledList>
                  <LabeledList.Item label="Stealthy Healing">
                  Using medbay to heal your host instead of spending blood will avoid leaving your host with deathly pale skin.
                  As a bonus, you get to have more blood for spitting and healing later.
                  </LabeledList.Item>
                  <LabeledList.Item label="Surprise Worms">
                  You can leave your host to surprise attack people, which is especially effective as an adult. Be sure to block
                  off any paths of escape first, as it takes 3 seconds to leave your host.
                  </LabeledList.Item>
                  <LabeledList.Item label="Door Stalking">
                  As a hatchling or a juvenile, you can slide under a door to stalk nearby victims. Be wary of anyone coming to open the door.
                  </LabeledList.Item>
                  <LabeledList.Item label="Meatshields">
                  Hosts are practically meatshields for you, just keep track of any fires, bleeding wounds, cremators or gibbing mechanisms.
                  Remember to also heal your host periodically using Inject Blood whenever they get too low.
                  </LabeledList.Item>
                  <LabeledList.Item label="Life Insurance">
                  Because you can't control corpses while you have less than a tenth of your health in blood volume, you will be ejected from your host when you get really low.
                  You can use this as insurance to get a last ditch escape attempt.
                  </LabeledList.Item>
                  <LabeledList.Item label="Medbay Buffet">
                  Medbay's blood freezers are all-you-can-eat buffets for you! They are only half synthetic and their high volumes grant you a lot of growth.
                  Be careful of nearby crew, as the sounds of breaking freezers can travel through walls.
                  </LabeledList.Item>
                  <LabeledList.Item label="Fast Food">
                  You can enter corpses to consume all of their blood extremely quickly. Blood gained while already in a host doesn't affect your growth.
                  Duplicated blood does, but it's synthetic, limiting its effectiveness.
                  </LabeledList.Item>
                  <LabeledList.Item label="Nomadic">
                  You have night vision and no territory, meaning you can thrive anywhere. Hatchlings can ventcrawl, while
                  juveniles and adults can break doors and other obstacles with their bare teeth. Nowhere is safe from you!
                  </LabeledList.Item>
                  <LabeledList.Item label="Team Up">
                  Your kin often share your goals and are willing to work together. You have your own language, Wormspeak,
                  which is only understandable to your kin. You can tell if someone is a blood worm host via a HUD icon.
                  </LabeledList.Item>
                  <LabeledList.Item label="Jail Time">
                  Sec got you? You can break any restraints on your host, including lockers and such, by right-clicking with Spit Blood active.
                  You can also leave your host and ventcrawl out or break through the door.
                  </LabeledList.Item>
                  <LabeledList.Item label="Jumpstart">
                  As an adult, you can gather corpses for your offspring to use as hosts. Gathering blood can jumpstart the growth of your
                  hatchlings to juveniles, or even send them all the way to adulthood.
                  </LabeledList.Item>
                </LabeledList>
              </Section>
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
