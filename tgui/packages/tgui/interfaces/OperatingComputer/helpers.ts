import { capitalizeFirst } from 'tgui-core/string';
import type { OperationData } from './types';

export function extractSurgeryName(
  operation: OperationData,
  catalog: boolean,
): { name: string; tool: string; true_name?: string } {
  // operation names may be "make incision", "lobotomy", or "disarticulation (amputation)"
  const { name, tool_rec } = operation;
  if (!name) {
    return { name: 'Ошибка операции', tool: 'Error' };
  }
  const parenthesis = name.indexOf('(');
  if (parenthesis === -1) {
    return { name: capitalizeFirst(name), tool: tool_rec };
  }
  const in_parenthesis = name.slice(parenthesis + 1, name.indexOf(')')).trim();
  if (!catalog) {
    return {
      name: capitalizeFirst(in_parenthesis),
      tool: tool_rec,
    };
  }
  const out_parenthesis = capitalizeFirst(name.slice(0, parenthesis).trim());
  return {
    name: capitalizeFirst(out_parenthesis),
    tool: tool_rec,
    true_name: capitalizeFirst(in_parenthesis),
  };
}

export function extractRequirementMap(
  surgery: OperationData,
): Record<string, string[]> {
  if (surgery.requirements?.length !== 4) {
    return {}; // we can assert this never happens, but just in case...
  }
  const hard_requirements = surgery.requirements[0];
  const soft_requirements = surgery.requirements[1];
  const optional_requirements = surgery.requirements[2];
  const blocked_requirements = surgery.requirements[3];

  // you *have* to have one of the soft requirements, so if there's only one...
  if (soft_requirements.length === 1) {
    hard_requirements.push(soft_requirements[0]);
    soft_requirements.length = 0;
  }

  const optional_title = () => {
    if (optional_requirements.length === 1) {
      if (hard_requirements.length === 0) return 'Необязательное требование:';
      return 'Дополнительно, необязательное требование:';
    }
    if (hard_requirements.length === 0)
      return 'Все следующие требования необязательны:';
    return 'Дополнительно, все следующие требования необязательны:';
  };

  const blocked_title = () => {
    if (blocked_requirements.length === 1) {
      if (hard_requirements.length === 0)
        return 'Следующее заблокирует процедуру:';
      return 'Однако, следующее заблокирует процедуру:';
    }
    if (hard_requirements.length === 0)
      return 'Любое из следующего заблокирует процедуру:';
    return 'Однако, любое из следующего заблокирует процедуру:';
  };

  return {
    [`${hard_requirements.length === 1 ? 'Требуется следующее:' : 'Все следующие требования обязательны:'}`]:
      hard_requirements,
    'Дополнительно, требуется одно из следующего:': soft_requirements,
    [optional_title()]: optional_requirements,
    [blocked_title()]: blocked_requirements,
  };
}
