@isTest
public with sharing class AddQuotationLineItemTest {

    static Integer n = 10;

    @TestSetup
    static void setup(){
        List<Product2> products = TestDataCreator.createProducts(n);
        TestDataCreator.createInventories(products);
        Pricebook2 pricebook = TestDataCreator.createPricebook();
        TestDataCreator.createPricebookEntries(products, pricebook);
        TestDataCreator.createQuote(pricebook);
    }

    @isTest
    public static void testAddQuotationLineItem() {

        Integer rand;
        
        List<Product2> products = [SELECT Id FROM Product2];
        rand = Integer.valueOf(Math.random() * n);
        Product2 product1 = products[rand];
        rand = Integer.valueOf(Math.random() * n);
        Product2 product2 = products[rand];

        Set<Id> productIds = new Set<Id>();
        productIds.add(product1.Id);
        productIds.add(product2.Id);

        List<Inventario__c> inventories = [
            SELECT Cantidad_disponible__c, Cantidad_Reservada__c, Product__c
            FROM Inventario__c
            WHERE Product__c IN :productIds
        ];

        Map<Id, Decimal> availableBefore = new Map<Id, Decimal>();
        availableBefore.put(inventories[0].Product__c, inventories[0].Cantidad_disponible__c - inventories[0].Cantidad_Reservada__c);
        availableBefore.put(inventories[1].Product__c, inventories[1].Cantidad_disponible__c - inventories[1].Cantidad_Reservada__c);

        Quote quote = [SELECT Id FROM Quote];
        Pricebook2 pricebook = [SELECT Id FROM Pricebook2];

        List<QuoteLineItem> items = new List<QuoteLineItem>();
        PricebookEntry entry;
        QuoteLineItem item;

        entry = [
            SELECT Id, UnitPrice 
            FROM PricebookEntry 
            WHERE Product2Id = :product1.Id AND Pricebook2Id = :pricebook.Id
        ];
        
        item = new QuoteLineItem();
        item.QuoteId = quote.Id;
        item.Product2Id = product1.Id;
        item.PricebookEntryId = entry.Id;
        item.Quantity = availableBefore.get(product1.Id);
        item.UnitPrice = entry.UnitPrice;
        items.add(item);

        entry = [
            SELECT Id, UnitPrice 
            FROM PricebookEntry 
            WHERE Product2Id = :product2.Id AND Pricebook2Id = :pricebook.Id];

        item = new QuoteLineItem();
        item.QuoteId = quote.Id;
        item.Product2Id = product2.Id;
        item.PricebookEntryId = entry.Id;
        item.Quantity = availableBefore.get(product2.Id) + 1;
        item.UnitPrice = entry.UnitPrice;
        items.add(item);

        Test.startTest();
        List<Database.SaveResult> result = Database.insert(items, false);
        Test.stopTest();

        inventories = [
            SELECT Cantidad_disponible__c, Cantidad_Reservada__c, Product__c
            FROM Inventario__c
            WHERE Product__c IN :productIds
        ];

        Map<Id, Decimal> availableAfter = new Map<Id, Decimal>();
        availableAfter.put(inventories[0].Product__c, inventories[0].Cantidad_disponible__c - inventories[0].Cantidad_Reservada__c);
        availableAfter.put(inventories[1].Product__c, inventories[1].Cantidad_disponible__c - inventories[1].Cantidad_Reservada__c);

        if(availableBefore.get(product1.Id) > 0) {
            System.assertEquals(0, availableAfter.get(product1.Id));
            System.assert(result[1].getErrors().size() > 0);
        } else {
            System.assert(result[0].getErrors().size() > 0);
            System.assert(result[1].getErrors().size() > 0);
        }
    }
}
