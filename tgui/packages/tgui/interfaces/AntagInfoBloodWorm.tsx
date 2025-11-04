import { Section, Stack, LabeledList } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { type Objective, ObjectivePrintout } from './common/Objectives';

type Info = {
  objectives: Objective[];
};

export const AntagInfoBloodWorm = (props) => {
  const { data } = useBackend<Info>();
  const { objectives } = data;
  return (
    <Window width={620} height={250}>
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
              <Section fill title="Powers">
                <LabeledList>
                  <LabeledList.Item label="Blood Consumption">
                  You can consume blood to heal and grow. Only blood consumed via Leech Blood or Invade Corpse will count towards growth,
                  and growth contribution is scaled per blood type. You can detect blood information by examining living targets, or at a glance via your HUD.
                  </LabeledList.Item>
                  <LabeledList.Item label="Growth Stages">
                  As you grow, you will gain and lose various abilities. Hatchlings can ventcrawl, juveniles can spit blood and adults have ridiculous offensive power.
                  Each growth stage requires an incubation period in a cocoon and a lot of consumed blood. You can track this in your status tab.
                  </LabeledList.Item>
                  <LabeledList.Item label="Reproduction">
                  Once you enter your final stage of growth as an adult, you can reproduce to create 4 new hatchlings, in exchange for reverting into one yourself.
                  </LabeledList.Item>
                  <LabeledList.Item label="Parasitism">
                  As a highly advanced blood parasite engineered by the Syndicate, you have the supernatural ability to turn into blood upon command.
                  This allows you to enter a corpse, taking it as your host.
                  </LabeledList.Item>
                  <LabeledList.Item label="Regeneration">
                  Both inside and outside of a host, you have potent regeneration abilities. Your body slowly heals from damage over time, even while in a host.
                  While in a host, you can insert organs into them by simply right-clicking on them with an organ in hand. Inject Blood heals almost everything, from organ damage to injuries.
                  </LabeledList.Item>
                  <LabeledList.Item label="Life Support">
                  While inside of a host, your host doesn't need a heart, a set of lungs nor a liver to survive. Lungs are still useful for speaking, and livers are good for booze and chems.
                  If you end up gutting your host by hitting them a bit too hard, you can reinsert their organs by picking them up and right-clicking on your host with them. This even works for cybernetics.
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
                  Any bloodloss while inside of a host will directly damage you and your hosts can also bleed even while dead.
                  </LabeledList.Item>
                  <LabeledList.Item label="Inferior Biology">
                  Hosts don't have your advanced eyesight and hearing, leaving them vulnerable to ordinary threats like darkness and flashbangs.
                  Still, you can always evacuate your host in a pinch, which is especially effective if you're an adult, since a surprise attack from one is very lethal.
                  </LabeledList.Item>
                </LabeledList>
              </Section>
            </Stack.Item>
            <Stack.Item>
              <Section fill title="Tips">
                <LabeledList>
                  <LabeledList.Item label="Meatshields">
                  Hosts are practically meatshields for you, just keep track of any fires, bleeding wounds, cremators or gibbing mechanisms.
                  Remember to also heal your host periodically using Inject Blood whenever they get too low.
                  </LabeledList.Item>
                  <LabeledList.Item label="Medbay Buffet">
                  Medbay's blood freezers are practically all-you-can-eat buffets for you! Multiple blood types and high volumes grant you a lot of growth.
                  Just be careful of any nearby crew while breaking the freezer and drinking the contents dry. Your drinking noises don't go through walls.
                  </LabeledList.Item>
                  <LabeledList.Item label="Fast Food">
                  Any time you need to leech from the blood of a humanoid corpse, you can instead use Invade Corpse to consume all of it at once.
                  Note that blood gained while already inside of a host doesn't count towards your growth at all. Consuming duplicated blood does, but blood type falloff still applies.
                  </LabeledList.Item>
                  <LabeledList.Item label="Sec and Worm">
                  Whenever security is on your tail, just escape into maintenance or hide in a host! You have night vision and no territory, meaning you can go anywhere.
                  After reaching the juvenile stage, you can break doors and other highly resistant obstacles with your bare teeth. Nowhere is safe from you!
                  </LabeledList.Item>
                  <LabeledList.Item label="Team Up">
                  Other members of your species are almost always ready to work with you, especially when they're your offspring. You have your own language, Wormspeak,
                  which can't be understood by others. You can also easily tell if someone is a blood worm host via a HUD icon.
                  </LabeledList.Item>
                  <LabeledList.Item label="Surprise Worms">
                  There's no way for outsiders to tell when you're in a host, apart from contextual clues like them knowing that your host died to you.
                  While you can't use burst spit in a host, you can surprise attack people by leaving your host and using your raw power to secure kills.
                  Hiding in a host is an effective way of remaining undetected.
                  </LabeledList.Item>
                  <LabeledList.Item label="Jail Time">
                  Sec got you and you're jailed? You can break any restraints on your host, including lockers and such, by right-clicking with Spit Blood active.
                  You can also just leave your host behind and use your worm body to either ventcrawl out or break straight through the door, optionally re-entering them after.
                  </LabeledList.Item>
                  <LabeledList.Item label="Jumpstart">
                  As an adult, it can be incredibly useful to gather a bunch of corpses using your strong abilities. Once gathered, any hatchlings you create will immediately have hosts available.
                  This can also be used to jumpstart the growth of your hatchlings all the way to juveniles or even adulthood.
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
