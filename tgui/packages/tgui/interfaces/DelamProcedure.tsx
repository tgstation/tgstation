// THIS IS A SKYRAT UI FILE
import { BlockQuote, Box, NoticeBox, Section } from '../components';
import { Window } from '../layouts';

export const DelamProcedure = () => {
  return (
    <Window
      title="Safety Moth - Delamination Emergency Procedure"
      width={666}
      height={865}
      theme="dark"
    >
      <Window.Content>
        <Section title="NT-approved delam emergency procedure">
          <NoticeBox danger m={2}>
            <b>
              So you&apos;ve found yourself in a bit of a pickle with a
              delamination of a supermatter reactor.
              <br />
              <br />
              Don&apos;t worry, saving the day is just a few steps away!
            </b>
          </NoticeBox>
          <BlockQuote m={2}>
            Locate the ever-elusive red emergency stop button. It&apos;s
            probably hiding in plain sight, so take your time, have a laugh, and
            enjoy the anticipation. Remember, it&apos;s like a treasure hunt,
            only with the added bonus of preventing a nuclear disaster.
          </BlockQuote>
          <BlockQuote m={2}>
            Once you&apos;ve uncovered the button, muster all your courage and
            push it like there&apos;s no tomorrow. Well, actually, you&apos;re
            pushing it to ensure there is a tomorrow. But hey, who doesn&apos;t
            love a little paradoxical button-pushing?
          </BlockQuote>
          <BlockQuote m={2}>
            Prepare for the impending suppression of the supermatter engine
            room, because things are about to get real quiet. Just make sure
            everyone has evacuated, or else they&apos;ll be in for a surprise.
            The system needs its space, and it&apos;s not known for being the
            friendliest neighbour.
          </BlockQuote>
          <BlockQuote m={2}>
            After the delamination is successfully suppressed, take a moment to
            appreciate the delicate beauty of crystal-based electricity. Take a
            look around and fix any damage to those fragile glass components.
            Feel free to put on your finest overalls and channel your inner
            engiborg while doing so.
          </BlockQuote>
          <BlockQuote m={2}>
            Keep an eye out for fires and the infamous air mix. It&apos;s always
            an adventure trying to strike the perfect balance between breathable
            air and potential suffocation. Remember, oxygen plus a spark equals
            fireworks - the kind you definitely don&apos;t want inside a
            reactor.
          </BlockQuote>
          <NoticeBox info m={2}>
            <b>
              Did you know freon catches fire at low temperatures?
              <br />
              <br />
              It even forms hot ice between 120K and 160K!
              <br />
              <br />
              Remember you can always turn the engine room air alarm to
              contaminated to assist in removing harmful gases!
            </b>
          </NoticeBox>
          <BlockQuote m={2}>
            To avoid singeing your eyebrows off, consider enlisting the help of
            a synth or a trusty borg. After all, nothing says &quot;safety
            first&quot; like outsourcing your firefighting to non-living,
            non-breathing assistants.
          </BlockQuote>
          <BlockQuote m={2}>
            Clear out any lightly radioactive debris and/or hot ice (The cargo
            department will probably love to dispose it for you.)
          </BlockQuote>
          <BlockQuote m={2}>
            Finally, revel in the satisfaction of knowing that you&apos;ve
            single-handedly prevented a delamination. But, of course, don&apos;t
            forget to feel guilty because SAFETY MOTH Knows. SAFETY MOTH knows
            everything. It&apos;s always watching, judging, and probably taking
            notes for its next safety briefing. So bask in the glory of your
            heroism, but know that the all-knowing Moff is onto you.
          </BlockQuote>
          <Box m={2}>
            <b>Optional step, for the true daredevils out there</b>
          </Box>
          <BlockQuote m={2}>
            When it comes time for your second attempt at starting the SM: Take
            this sign, give it a good toss towards the crystal, and watch it
            soar through the air. <br />
            <br />
            Nothing says &quot;I&apos;m dealing with a potentially catastrophic
            situation&quot; like engaging in some whimsical shenanigans.
          </BlockQuote>
          <NoticeBox m={2}>
            <b>
              Hopefully you&apos;ll never need to do this. However, good luck!
            </b>
          </NoticeBox>
        </Section>
      </Window.Content>
    </Window>
  );
};
