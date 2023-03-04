import { useBackend } from '../backend';
import { Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';

export const KindredArchives = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window
      width={450}
      height={450}>
      <Window.Content>
        <Section title="What Clan are you dealing with?">
          {data.name}
          <LabeledList>
            <LabeledList.Item label="Brujah Clan">
              <Button
                content="Brujah"
                onClick={() => act('Brujah Clan')} />
            </LabeledList.Item>
            <LabeledList.Item label="Toreador Clan">
              <Button
                content="Toreador"
                onClick={() => act('Toreador Clan')} />
            </LabeledList.Item>
            <LabeledList.Item label="Nosferatu Clan">
              <Button
                content="Nosferatu"
                onClick={() => act('Nosferatu Clan')} />
            </LabeledList.Item>
            <LabeledList.Item label="Tremere Clan">
              <Button
                content="Tremere"
                onClick={() => act('Tremere Clan')} />
            </LabeledList.Item>
            <LabeledList.Item label="Gangrel Clan">
              <Button
                content="Gangrel"
                onClick={() => act('Gangrel Clan')} />
            </LabeledList.Item>
            <LabeledList.Item label="Ventrue Clan">
              <Button
                content="Ventrue"
                onClick={() => act('Ventrue Clan')} />
            </LabeledList.Item>
            <LabeledList.Item label="Malkavian Clan">
              <Button
                content="Malkavian"
                onClick={() => act('Malkavian Clan')} />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
