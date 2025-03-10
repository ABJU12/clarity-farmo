import { Clarinet, Tx, Chain, Account, types } from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Can register new product",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet_1 = accounts.get("wallet_1")!;
    
    let block = chain.mineBlock([
      Tx.contractCall("product-registry", "register-product", 
        ["Organic Apples", "Farm A"], wallet_1.address)
    ]);
    
    assertEquals(block.receipts[0].result.expectOk(), "u0");
  }
});

Clarinet.test({
  name: "Can transfer product ownership", 
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet_1 = accounts.get("wallet_1")!;
    const wallet_2 = accounts.get("wallet_2")!;
    
    let block = chain.mineBlock([
      Tx.contractCall("product-registry", "register-product",
        ["Organic Apples", "Farm A"], wallet_1.address),
      Tx.contractCall("product-registry", "transfer-product",
        ["u0", types.principal(wallet_2.address)], wallet_1.address)
    ]);

    assertEquals(block.receipts[1].result.expectOk(), true);
  }
});
