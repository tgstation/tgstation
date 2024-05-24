import { useBackend } from '../backend';
import { Window } from '../layouts';
import { ProgressBar, Section, Stack } from '../components';

export const XpMenu = (props, context) => {
  const { data } = useBackend(context);
  const { job_levels, job_xp, job_xp_for_level } = data;
  const exclusions = [
    'Santa',
    'Unassigned Crewmember',
    'Servant Golem',
    'Cyber Police',
    'Abductor Agent',
    'Abductor Scientist',
    'Abductor Solo',
    'Clown Operative',
    'Lone Operative',
    'Morph',
    'Nightmare',
    'Yellow Clown',
    'Discount Godzilla',
    'Gorilla',
    'NOPE',
    'Debugger',
    'Diet Wizard',
    'Candy Salesman',
    'Drifting Contractor',
    'Zombie',
    'Venus Human Trap',
    'Cybersun Space Syndicate Captain',
    'Cybersun Space Syndicate',
    'Spider',
    'Space Syndicate',
    'Space Pirate',
    'Space Doctor',
    'Space Bartender',
    'Space Bar Patron',
    'Skeleton',
    'Lifebringer',
    'Lavaland Syndicate',
    'Hermit',
    'Hotel Staff',
    'Ghost Role',
    'Fugitive Hunter',
    'Free Golem',
    'Exile',
    'Nuclear Operative',
    'Paradox Clone',
    'Revenant',
    'Sentient Disease',
    'Slaughter Demon',
    'Space Dragon',
    'Space Ninja',
    'Wizard',
    'Apprentice',
    'Xenomorph',
    'ERT Generic',
    'Fugitive',
    'Ancient Crew',
    'Battlecruiser Crew',
    'Battlecruiser Captain',
    'Beach Bum',
    'Escaped Prisoner',
    'Ghost',
    'Derelict Drone',
    'Maintenance Drone',
    'Ash Walker',
  ];

  const xpBoxes = []; // Array to store JSX elements

  // Iterate over job_xp_for_level object
  for (const job in job_xp_for_level) {
    // Check if the job is not in the exclusions list
    if (!exclusions.includes(job)) {
      // Push JSX element to array
      xpBoxes.push(
        <Stack.Item>
          <Section title={job}>
            <ProgressBar
              value={job_xp[job]}
              minValue={0}
              maxValue={job_xp_for_level[job]}
              key={job}>
              Level {job_levels[job]} {job}
            </ProgressBar>
          </Section>
        </Stack.Item>
      );
    }
  }

  return (
    <Window width={480} height={520}>
      <Window.Content scrollable>
        <Stack vertical grow>
          {xpBoxes}
        </Stack>
      </Window.Content>
    </Window>
  );
};
