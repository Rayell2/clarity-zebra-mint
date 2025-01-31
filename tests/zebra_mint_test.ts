[Previous tests remain unchanged...]

Clarinet.test({
  name: "Cannot mint with empty metadata fields",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet1 = accounts.get('wallet_1')!;
    
    let block = chain.mineBlock([
      Tx.contractCall('zebra-mint', 'mint', [
        types.utf8(""),
        types.utf8("Description"),
        types.utf8("https://example.com/image.png"),
        types.uint(10)
      ], wallet1.address)
    ]);
    
    block.receipts[0].result.expectErr();
    assertEquals(block.receipts[0].result.expectErr(), types.uint(105));
    
    block = chain.mineBlock([
      Tx.contractCall('zebra-mint', 'mint', [
        types.utf8("Name"),
        types.utf8(""),
        types.utf8("https://example.com/image.png"),
        types.uint(10)
      ], wallet1.address)
    ]);
    
    block.receipts[0].result.expectErr();
    assertEquals(block.receipts[0].result.expectErr(), types.uint(105));
  },
});
