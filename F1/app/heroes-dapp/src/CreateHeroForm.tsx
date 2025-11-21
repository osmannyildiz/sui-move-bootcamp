import {
  useCurrentAccount,
  useSignAndExecuteTransaction,
  useSuiClient,
} from "@mysten/dapp-kit";
import { Transaction } from "@mysten/sui/transactions";
import { Button, Container, Heading, TextField } from "@radix-ui/themes";
import { useQueryClient } from "@tanstack/react-query";
import { useState } from "react";

export function CreateHeroForm() {
  const suiClient = useSuiClient();
  const account = useCurrentAccount();
  const queryClient = useQueryClient();
  const { mutateAsync: signAndExecuteTx, isPending } =
    useSignAndExecuteTransaction();

  const [name, setName] = useState("");
  const [power, setPower] = useState("");
  const [weaponName, setWeaponName] = useState("");
  const [weaponPower, setWeaponPower] = useState("");

  const handleCreateHero = async (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault();

    if (!account?.address) {
      alert("Please connect your wallet");
      return;
    }

    const tx = new Transaction();

    const hero = tx.moveCall({
      target: `${import.meta.env.VITE_PACKAGE_ID}::hero::new_hero`,
      arguments: [
        tx.pure.string(name),
        tx.pure.u64(Number(power)),
        tx.object(import.meta.env.VITE_HEROES_REGISTRY_ID),
      ],
    });

    const weapon = tx.moveCall({
      target: `${import.meta.env.VITE_PACKAGE_ID}::hero::new_weapon`,
      arguments: [tx.pure.string(weaponName), tx.pure.u64(Number(weaponPower))],
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

      <form
        onSubmit={handleCreateHero}
        style={{ display: "flex", flexDirection: "column", gap: "1rem" }}
      >
        <TextField.Root
          placeholder="Hero Name"
          value={name}
          onChange={(e) => setName(e.target.value)}
        />

        <TextField.Root
          placeholder="Hero Power"
          type="number"
          value={power}
          onChange={(e) => setPower(e.target.value)}
        />

        <TextField.Root
          placeholder="Weapon Name"
          value={weaponName}
          onChange={(e) => setWeaponName(e.target.value)}
        />

        <TextField.Root
          placeholder="Weapon Power"
          type="number"
          value={weaponPower}
          onChange={(e) => setWeaponPower(e.target.value)}
        />

        <Button type="submit" size="4" loading={isPending}>
          Create Hero!
        </Button>
      </form>
    </Container>
  );
}
