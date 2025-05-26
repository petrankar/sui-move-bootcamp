import { SuiParsedData } from '@mysten/sui/dist/cjs/client';
import { suiClient } from '../suiClient';

interface HeroFields {
  id: {
    id: string;
  };
}
/**
 * Gets the object id of a Weapon that is attached to a Hero object by the hero's object id.
 * We need to get the Hero object, and find the value of the corresponding nested field.
 */
export const getWeaponIdOfHero = async (heroId: string): Promise<string | undefined> => {
  const resp = await suiClient.getObject({ id: heroId, options: { showContent: true } });
  if (!resp.data) {
    return undefined;
  }

  const content = resp.data.content as Extract<SuiParsedData, { dataType: 'moveObject' }>;
  const fields = content.fields as unknown as HeroFields;
  return fields.id.id;
};
