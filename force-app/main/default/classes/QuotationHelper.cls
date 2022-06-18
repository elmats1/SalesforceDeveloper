public with sharing class QuotationHelper {
    
    public void initialConfig(){
        
        List<Account> accList = new List<Account>();
        Account compumundo = new Account();
        Account compuworld = new Account();
        String Compuworld = compuworld.Name;
        String Compumundo = compumundo.Name;

        accList.add(compumundo);
        accList.add(compuworld);
        
        try {
            insert accList;
        } catch (DmlException d) {
            Exception Code;
        }
    }
    //

    public List<Inventario__c> productInInventory(){
        List<Inventario__c> invList = [
            SELECT Codigo_De_Producto__c, Name
            FROM Inventario__c];
        return(invList);
    }

    public Boolean confirmProductExistByCode(String Id){
        Product2[] product = [SELECT Id FROM Product2 WHERE ExternalId = :Id
        WITH SECURITY_ENFORCED];
        return !product.isEmpty();
    }

    public Integer searchProductByCode(String code){
        Integer avaQuantity = 0;
        if(confirmProductExistByCode(code)){
            Inventario__c inv = [
                SELECT Id, Cantidad_disponible__c, Cantidad_Reservada__c
                FROM Inventario__c
                WHERE Codigo_De_Producto__c = :code
                LIMIT 1
            ];
            avaQuantity = (Integer) (inv.Cantidad_disponible__c - inv.Cantidad_Reservada__c);
        }
        return avaQuantity;
    }
}
/*
Falta Postwork de Triggers con Apex en adelante, también hacer los preworks correspondientes y revisar los ejercicios que el profe deja de tarea
*/