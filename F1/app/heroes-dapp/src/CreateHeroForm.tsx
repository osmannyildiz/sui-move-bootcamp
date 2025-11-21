import {
  useCurrentAccount,
  useSignAndExecuteTransaction,
  useSuiClient,
} from "@mysten/dapp-kit";
import { Transaction } from "@mysten/sui/transactions";
import { Button, Container, Heading } from "@radix-ui/themes";
import { useQueryClient } from "@tanstack/react-query";

export function CreateHeroForm() {
  const suiClient = useSuiClient();
  const account = useCurrentAccount();
  const queryClient = useQueryClient();
  const { mutateAsync: signAndExecuteTx, isPending } =
    useSignAndExecuteTransaction();

  const handleCreateHero = async () => {
    if (!account?.address) {
      alert("Please connect your wallet");
      return;
    }

    const tx = new Transaction();

    const hero = tx.moveCall({
      target: `${import.meta.env.VITE_PACKAGE_ID}::hero::new_hero`,
      arguments: [
        tx.pure.string("Os-Man"),
        tx.pure.u64(99),
        tx.object(import.meta.env.VITE_HEROES_REGISTRY_ID),
      ],
    });

    const weapon = tx.moveCall({
      target: `${import.meta.env.VITE_PACKAGE_ID}::hero::new_weapon`,
      arguments: [tx.pure.string("Reentrancy Sword"), tx.pure.u64(69)],
    });

    tx.moveCall({
      target: `${import.meta.env.VITE_PACKAGE_ID}::hero::equip_weapon`,
      arguments: [hero, weapon],
    });

    tx.transferObjects([hero], account.address);

    const result = await signAndExecuteTx({ transaction: tx });

    await suiClient.waitForTransaction({
      digest: result.digest,
    });

    await queryClient.invalidateQueries({
      queryKey: ["testnet", "getOwnedObjects"],
    });
    await queryClient.invalidateQueries({
      queryKey: ["testnet", "getObject"],
    });
  };

  return (
    <Container my="2">
      <Heading mb="2">Create Hero Form</Heading>

      <Button size="4" loading={isPending} onClick={handleCreateHero}>
        Create Hero!
      </Button>
    </Container>
  );
}
