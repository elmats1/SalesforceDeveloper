@isTest
public with sharing class InventoryDataSchedulerTest {

    @testSetup
    static void setup() {
        List<Product2> products = new List<Product2>();
        products.add(new Product2(Name='NuevoProd01', ExternalId='NP0701'));
        products.add(new Product2(Name='NuevoProd02', ExternalId='NP0702'));

        insert products;
        
        Inventario__c inv = new Inventario__c();
        inv.Name = 'NuevoProd01';
        inv.Codigo_De_Producto__c = 'NP0702';
        inv.Cantidad_disponible__c = 2800;
        inv.Cantidad_Reservada__c = 25;
        inv.Product__c = products[0].Id;

        insert inv;  
    }

    @isTest
    public static void testInventoryDataScheduler() {
        Test.setMock(HttpCalloutMock.class, new ExternalInventoryMock());
        String cronExp = '0 0 0 1 1 ?';

        Test.startTest();
        String jobId = System.schedule('Inventory Data Scheduler Test',
            cronExp,
            new InventoryDataScheduler());
        Test.stopTest();

        List<CronTrigger> jobs = [SELECT Id FROM CronTrigger WHERE Id = :jobId];
        System.assert(jobs.size() > 0);
    }

    @isTest
    public static void testGetExternalInventory() {
        Test.setMock(HttpCalloutMock.class, new ExternalInventoryMock());
        Test.startTest();
        List<Object> result = InventoryDataScheduler.getExternalInventory();
        Test.stopTest();
        System.assertEquals(3, result.size());
    }

    @isTest
    public static void testExternalLegacyConnection() {
        Test.setMock(HttpCalloutMock.class, new ExternalInventoryMock());
        Test.startTest();
        InventoryDataScheduler.externalLegacyConnection();
        Test.stopTest();

        List<Product2> products = [SELECT Id FROM Product2];
        List<Inventario__c> invs = [SELECT Id FROM Inventario__c];
        Inventory__c inv = [
            SELECT Id, Cantidad_disponible__c, Cantidad_Reservada__c 
            FROM Inventario__c
            WHERE Codigo_De_Producto__c = 'NP0701'
        ];
        System.assertEquals(3, products.size(), 'Products not created');
        System.assertEquals(3, invs.size(), 'Inventories not created');
        System.assertEquals(2906, inv.Cantidad_disponible__c, 'Available Quantity not updated');
        System.assertEquals(8, inv.Cantidad_Reservada__c, 'Reserved Quantity not updated');
    }
}
