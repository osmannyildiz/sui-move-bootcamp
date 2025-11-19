import { SuiObjectResponse } from "@mysten/sui/client";
import { suiClient } from "../suiClient";

/**
 * Uses SuiClient to get a hero object by its ID.
 * Uses the required SDK options to include the content and the type of the object in the response.
 */
export const getHero = async (id: string): Promise<SuiObjectResponse> => {
  // Get the hero object by its ID
  return suiClient.getObject({
    id,
    options: {
      showType: true,
      showOwner: true,
      showPreviousTransaction: true,
      showContent: true,
    },
  });
};
