p@isTest
public with sharing class CustomWebInventoryControllerTest {

    @TestSetup
    static void setup() {
        List<Product2> products = TestDataCreator.createProducts(10);
        TestDataCreator.createInventories(products);
        Pricebook2 pricebook = TestDataCreator.createPricebook();
        TestDataCreator.createPricebookEntries(products, pricebook);
        TestDataCreator.createQuote(pricebook);
    }

    @isTest
    public static void testAll() {

        Quote quote = [SELECT Id, Pricebook2Id FROM Quote];
        ApexPages.StandardController sc = new ApexPages.StandardController(quote);
        CustomWebInventoryController controller = new CustomWebInventoryController(sc);

        Product2 product = [SELECT Name, ExternalId FROM Product2 WHERE Name = 'Test 2'];

        controller.search();
        System.assert(controller.products == null);
        System.assert(controller.detailsVisible == false);

        controller.code = product.ExternalId;        
        controller.search();
        System.assert(controller.name == product.Name);
        System.assert(controller.products[0].Id == product.Id);
        System.assert(controller.detailsVisible == true);

        List<QuoteLineItem> items = [SELECT Id FROM QuoteLineItem];
        System.assert(items.isEmpty());

        controller.quantity = controller.available + 1;
        System.assert(controller.quantity > 0);
        controller.save();
        
        items = [SELECT Id FROM QuoteLineItem];
        System.assert(items.isEmpty());
        System.assert(ApexPages.hasMessages());

        controller.quantity = 2;
        controller.save();
        
        items = [SELECT Id FROM QuoteLineItem];
        System.assert(!items.isEmpty());

        controller.clear();
        System.assert(controller.products.size() == 0);
        System.assert(controller.detailsVisible == false);
    }
}
