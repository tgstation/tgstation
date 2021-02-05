import { useBackend } from '../backend';
import { Button, Icon, LabeledList, ProgressBar, Section } from '../components';
import { Window } from '../layouts';

export const Thermometer = (props, context) => {
    const { act, data } = useBackend(context);
    return (  
    <Window
        width={100}
        height={500}
        key="Thermometer"
        resizable>
        <Section>
        <Icon rotation = {90}>
            <ProgressBar value={data.temperature} />
        </Icon>
        test
        </Section>
    </Window>
    );
};