Clarinet.test({
  name: "Enhanced metadata validation works correctly",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    const wallet1 = accounts.get('wallet_1')!;
    
    // Test valid metadata
    let block = chain.mineBlock([
      Tx.contractCall('zebra-mint', 'mint', [
        types.utf8("Valid Name"),
        types.utf8("Valid Description"),
        types.utf8("https://example.com/image.png"),
        types.uint(10)
      ], wallet1.address)
    ]);
    
    block.receipts[0].result.expectOk();
    
    // Test invalid URL
    block = chain.mineBlock([
      Tx.contractCall('zebra-mint', 'mint', [
        types.utf8("Valid Name"),
        types.utf8("Valid Description"),
        types.utf8("invalid-url"),
        types.uint(10)
      ], wallet1.address)
    ]);
    
    block.receipts[0].result.expectErr();
    assertEquals(block.receipts[0].result.expectErr(), types.uint(107));
  },
});

// Previous tests remain unchanged...
