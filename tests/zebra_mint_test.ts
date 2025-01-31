import {
  Clarinet,
  Tx,
  Chain,
  Account,
  types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Can mint new NFT with royalties",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet1 = accounts.get('wallet_1')!;
    
    let block = chain.mineBlock([
      Tx.contractCall('zebra-mint', 'mint', [
        types.utf8("Cool NFT"),
        types.utf8("A very cool NFT description"),
        types.utf8("https://example.com/image.png"),
        types.uint(10)
      ], wallet1.address)
    ]);
    
    block.receipts[0].result.expectOk();
    assertEquals(block.receipts[0].result.expectOk(), types.uint(1));
    
    let royaltyBlock = chain.mineBlock([
      Tx.contractCall('zebra-mint', 'get-royalty-info', [
        types.uint(1)
      ], wallet1.address)
    ]);
    
    const royaltyInfo = royaltyBlock.receipts[0].result.expectOk();
    assertEquals(royaltyInfo['royalty-percent'], types.uint(10));
    assertEquals(royaltyInfo['creator'], wallet1.address);
  },
});

Clarinet.test({
  name: "Cannot mint with invalid royalty percentage",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet1 = accounts.get('wallet_1')!;
    
    let block = chain.mineBlock([
      Tx.contractCall('zebra-mint', 'mint', [
        types.utf8("Cool NFT"),
        types.utf8("A very cool NFT description"),
        types.utf8("https://example.com/image.png"),
        types.uint(51)
      ], wallet1.address)
    ]);
    
    block.receipts[0].result.expectErr();
  },
});

Clarinet.test({
  name: "Can burn owned NFT",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet1 = accounts.get('wallet_1')!;
    
    // First mint NFT
    let mintBlock = chain.mineBlock([
      Tx.contractCall('zebra-mint', 'mint', [
        types.utf8("Cool NFT"),
        types.utf8("A very cool NFT description"),
        types.utf8("https://example.com/image.png"),
        types.uint(10)
      ], wallet1.address)
    ]);
    
    // Then burn it
    let burnBlock = chain.mineBlock([
      Tx.contractCall('zebra-mint', 'burn', [
        types.uint(1)
      ], wallet1.address)
    ]);
    
    burnBlock.receipts[0].result.expectOk();
    
    // Verify cannot transfer burned token
    let transferBlock = chain.mineBlock([
      Tx.contractCall('zebra-mint', 'transfer', [
        types.uint(1),
        types.principal(wallet1.address),
        types.principal(accounts.get('wallet_2')!.address)
      ], wallet1.address)
    ]);
    
    transferBlock.receipts[0].result.expectErr();
  },
});

Clarinet.test({
  name: "Cannot update metadata of burned NFT",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet1 = accounts.get('wallet_1')!;
    
    // First mint and burn NFT
    let mintBlock = chain.mineBlock([
      Tx.contractCall('zebra-mint', 'mint', [
        types.utf8("Cool NFT"),
        types.utf8("A very cool NFT description"),
        types.utf8("https://example.com/image.png"),
        types.uint(10)
      ], wallet1.address)
    ]);
    
    let burnBlock = chain.mineBlock([
      Tx.contractCall('zebra-mint', 'burn', [
        types.uint(1)
      ], wallet1.address)
    ]);
    
    // Try to update metadata
    let updateBlock = chain.mineBlock([
      Tx.contractCall('zebra-mint', 'update-metadata', [
        types.uint(1),
        types.utf8("Updated NFT"),
        types.utf8("Updated description"),
        types.utf8("https://example.com/updated.png")
      ], wallet1.address)
    ]);
    
    updateBlock.receipts[0].result.expectErr();
  },
});
