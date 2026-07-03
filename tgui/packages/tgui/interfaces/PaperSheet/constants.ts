import { resolveAsset } from '../../assets';
import { blankPropRegex, propRegex } from './helpers';

export const TEXTAREA_INPUT_HEIGHT = 300;
export const REPLACEMENT_TOKEN_START_REGEX = /\[(\w*)$/;

export const SPECIAL_TOKENS = {
  blank_header: (value: string) => {
    const content = value.replace(/^\[blank_header\s*|\]$/g, '').trim();

    const id = content.match(blankPropRegex('id'))?.[1]?.trim();
    const name = content.match(blankPropRegex('name'))?.[1]?.trim();
    const station = content.match(blankPropRegex('station'))?.[1]?.trim();
    const category = content.match(blankPropRegex('category'))?.[1]?.trim();
    const info = content.match(blankPropRegex('info'))?.[1]?.trim();

    return `
		<div class='blank'>
		  <div class='blank_header'>
			<div class='blank_logo'>
			  [nt_logo]
			</div>
			<div class='blank_content'>
			  <span class='id'>Форма ${id || ''}</span>
			  <span class='name'>${name || ''}</span>
			  <hr>
			  <span class='station'>
				Научная станция Nanotrasen
				<br>
				<span class='station_name'>
          ${station || ''}
        </span>
			  </span>
			  <span class='category'>${category || ''}</span>
			</div>
		  </div>
		  <span class='blank_notice'>
			<hr>
			${info || 'Перед заполнением прочитать от начала до конца | Во всех PDA имеется ручка'}
			<hr>
		  </span>
		</div>
	  `;
  },
  blank_footer: (value: string) => {
    const content = value.replace(/^\[blank_footer\s*|\]$/g, '').trim();
    const info = content.match(blankPropRegex('content'))?.[1]?.trim();
    return `
      <div class='blank_footer'>
        <hr>
        ${info || ''}
      </div>
    `;
  },
  nt_logo: (value: string) => {
    const matchArray = value.match(propRegex('width'));
    const widthValue = matchArray ? matchArray[1] : '';
    return `<img src='${resolveAsset('nanotrasen-logo')}' ${widthValue ? `width='${widthValue}'` : ''}>`;
  },
  syndie_logo: (value: string) => {
    const matchArray = value.match(propRegex('width'));
    const widthValue = matchArray ? matchArray[1] : '';
    return `<img src='${resolveAsset('syndielogo.png')}' ${widthValue && `width='${widthValue}`}'>`;
  },
};
