import {
  Clarinet,
  Tx,
  Chain,
  Account,
  types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Can mint new NFT with metadata",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet1 = accounts.get('wallet_1')!;
    
    let block = chain.mineBlock([
      Tx.contractCall('zebra-mint', 'mint', [
        types.utf8("Cool NFT"),
        types.utf8("A very cool NFT description"),
        types.utf8("https://example.com/image.png")
      ], wallet1.address)
    ]);
    
    block.receipts[0].result.expectOk();
    assertEquals(block.receipts[0].result.expectOk(), types.uint(1));
    
    // Verify metadata
    let metadataBlock = chain.mineBlock([
      Tx.contractCall('zebra-mint', 'get-token-metadata', [
        types.uint(1)
      ], wallet1.address)
    ]);
    
    const metadata = metadataBlock.receipts[0].result.expectOk().expectSome();
    assertEquals(metadata['name'], "Cool NFT");
  },
});

Clarinet.test({
  name: "Can transfer NFT between users",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet1 = accounts.get('wallet_1')!;
    const wallet2 = accounts.get('wallet_2')!;
    
    // First mint NFT
    let mintBlock = chain.mineBlock([
      Tx.contractCall('zebra-mint', 'mint', [
        types.utf8("Cool NFT"),
        types.utf8("A very cool NFT description"),
        types.utf8("https://example.com/image.png")
      ], wallet1.address)
    ]);
    
    // Then transfer it
    let transferBlock = chain.mineBlock([
      Tx.contractCall('zebra-mint', 'transfer', [
        types.uint(1),
        types.principal(wallet1.address),
        types.principal(wallet2.address)
      ], wallet1.address)
    ]);
    
    transferBlock.receipts[0].result.expectOk();
    
    // Verify new owner
    let ownerBlock = chain.mineBlock([
      Tx.contractCall('zebra-mint', 'get-owner', [
        types.uint(1)
      ], wallet1.address)
    ]);
    
    const owner = ownerBlock.receipts[0].result.expectOk().expectSome();
    assertEquals(owner, wallet2.address);
  },
});

Clarinet.test({
  name: "Can update NFT metadata as owner",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet1 = accounts.get('wallet_1')!;
    
    // First mint NFT
    let mintBlock = chain.mineBlock([
      Tx.contractCall('zebra-mint', 'mint', [
        types.utf8("Cool NFT"),
        types.utf8("A very cool NFT description"),
        types.utf8("https://example.com/image.png")
      ], wallet1.address)
    ]);
    
    // Update metadata
    let updateBlock = chain.mineBlock([
      Tx.contractCall('zebra-mint', 'update-metadata', [
        types.uint(1),
        types.utf8("Updated NFT"),
        types.utf8("Updated description"),
        types.utf8("https://example.com/updated.png")
      ], wallet1.address)
    ]);
    
    updateBlock.receipts[0].result.expectOk();
    
    // Verify updated metadata
    let metadataBlock = chain.mineBlock([
      Tx.contractCall('zebra-mint', 'get-token-metadata', [
        types.uint(1)
      ], wallet1.address)
    ]);
    
    const metadata = metadataBlock.receipts[0].result.expectOk().expectSome();
    assertEquals(metadata['name'], "Updated NFT");
  },
});