import { useBackend } from "../backend";

import {
  Box,
  Section,
  ProgressBar,
  Button,
} from "../components";
import { Window } from "../layouts";

export const ArtifactPaperPrinter = (props, context) => {
	const { act, data } = useBackend(context);
	const { has_toner, max_toner, current_toner, allorigins, chosenorigin, alltypes, chosentype, alltriggers, chosentriggers, cant_print } = data;
	return (
		<Window width={480} height={460} title={"Analysis Form Printer"}>
			<Window.Content>
				{has_toner ? (
					<Section title="Toner" buttons={
						<Button disabled={!has_toner} onClick={() => act('remove_toner')} icon="eject"> Eject </Button>}
					>
						<ProgressBar value={current_toner} maxValue={max_toner} />
					</Section>
					) : (
					<Section title="Toner">
					<Box color="average">No toner cartridge.</Box>
					</Section>
				)}
				<Section title="Origin">
				  {allorigins.map((origin) => (
					<Button
					  key={origin}
					  icon={chosenorigin === origin ? 'check-square-o' : 'square-o'}
					  content={origin}
					  selected={chosenorigin === origin}
					  onClick={() =>
						act('origin', {
						  origin: origin,
						})
					  }
					/>
				  ))}
				</Section>
				<Section title="Type">
				  {alltypes.map((x) => (
					<Button
					  key={x}
					  icon={chosentype === x ? 'check-square-o' : 'square-o'}
					  content={x}
					  selected={chosentype === x}
					  onClick={() =>
						act('type', {
						  type: x,
						})
					  }
					/>
				  ))}
				</Section>
				<Section title="Triggers">
				  {alltriggers.map((trig) => (
					<Button
						key={trig}
						icon={chosentriggers.includes(trig) ? 'check-square-o' : 'square-o'}
						content={trig}
						selected={chosentriggers.includes(trig)}
						onClick={() =>
						act('trigger', {
							trigger: trig,
						})
					  }
					/>
				  ))}
				</Section>
				<Button textAlign="Center" width="100%" disabled={cant_print} onClick={() => act('print')}>Print</Button>
			</Window.Content>
		</Window>
	);
};
