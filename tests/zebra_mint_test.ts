Clarinet.test({
  name: "Contract pause functionality works correctly",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    const wallet1 = accounts.get('wallet_1')!;
    
    let block = chain.mineBlock([
      Tx.contractCall('zebra-mint', 'set-contract-pause', [
        types.bool(true)
      ], deployer.address)
    ]);
    
    block.receipts[0].result.expectOk();
    
    block = chain.mineBlock([
      Tx.contractCall('zebra-mint', 'mint', [
        types.utf8("Name"),
        types.utf8("Description"),
        types.utf8("https://example.com/image.png"),
        types.uint(10)
      ], wallet1.address)
    ]);
    
    block.receipts[0].result.expectErr();
    assertEquals(block.receipts[0].result.expectErr(), types.uint(106));
  },
});

[Previous tests remain unchanged...]
