@isTest
public with sharing class TestDataCreator {
    //Creates n Product2 records
    public static List<Product2> createProducts(Integer n) {
        List<Product2> products = new List<Product2>();
        for (Integer i = 0; i < n; i++) {
            Product2 product = new Product2();
            product.Name = 'Test ' + i;
            product.ProductCode = 'TST ' + i;
            product.ExternalId = 'ETST ' + i;
            product.IsActive = true;
            products.add(product);
        }
        insert products;
        return products;
    }

    public static List<Inventario__c> createInventories(List<Product2> products) {
        List<Inventario__c> inventories = new List<Inventario__c>();
        for (Product2 product : products) {
            Inventario__c inventory = new Inventario__c();

            Integer available = Integer.valueOf(Math.random() * 99) + 1;
            Integer reserved = Integer.valueOf(Math.random() * available);

            inventory.Name = product.Name + '_inv';
            inventory.Codigo_De_Producto__c = product.ProductCode;
            inventory.Cantidad_disponible__c = available;
            inventory.Cantidad_Reservada__c = reserved;
            inventory.Product__c = product.Id;
            inventories.add(inventory);
        }
        //Actualizar cantidades para pruebas de cantidades
        inventories[0].Cantidad_disponible__c = 5;
        inventories[0].Cantidad_Reservada__c = 5;

        inventories[1].Cantidad_disponible__c = 5;
        inventories[1].Cantidad_Reservada__c = 0;

        insert inventories;
        return inventories;
    }

    public static Pricebook2 createPricebook() {
        Pricebook2 pricebook = new Pricebook2();
        pricebook.Name = 'Test';
        pricebook.IsActive = true;
        insert pricebook;
        return pricebook;
    }

    public static List<PricebookEntry> createPricebookEntries(List<Product2> products, Pricebook2 pricebook) {

        String stdPricebookId = Test.getStandardPricebookId();

        List<PricebookEntry> entries = new List<PricebookEntry>();
        for (Product2 product : products) {
            PricebookEntry entry = new PricebookEntry();
            entry.Pricebook2Id = stdPricebookId;
            entry.Product2Id = product.Id;
            //entry.ProductCode = product.ProductCode;
            entry.IsActive = true;
            entry.UnitPrice = Integer.valueOf(Math.random() * 100);
            entry.UseStandardPrice = false;
            entries.add(entry);
        }

        insert entries;

        entries.clear();
        for (Product2 product : products) {
            PricebookEntry entry = new PricebookEntry();
            entry.Pricebook2Id = pricebook.Id;
            entry.Product2Id = product.Id;
            //entry.ProductCode = product.ProductCode;
            entry.IsActive = true;
            entry.UnitPrice = Integer.valueOf(Math.random() * 100);
            entry.UseStandardPrice = false;
            entries.add(entry);
        }

        insert entries;
        return entries;
    }

    public static Quote createQuote(Pricebook2 pricebook) {
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Prospecting';
        opp.CloseDate = Date.parse('21/06/2022');
        opp.Pricebook2Id = pricebook.Id;
        
        insert opp;
        
        Quote quote = new Quote();
        quote.Name = 'Test2';
        quote.OpportunityId = opp.Id;
        
        insert quote;
        return quote;
    }
}
