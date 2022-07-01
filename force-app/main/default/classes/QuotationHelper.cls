public with sharing class QuotationHelper {
    
    public void initialConfig(){
       
        List<Account> accList = new List<Account>();
        Account compumundo = new Account();
        compumundo.Name = 'Compumundo';
        Account compuworld = new Account();
        compuworld.Name = 'Compuworld';

        List<Account> accList = new List<Account>();
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
            SELECT Codigo_De_Producto__c, Name, Cantidad_disponible__c, Cantidad_Reservada__c, Last_Stock_Alert__c
            FROM Inventario__c
            LIMIT 200];
            //System.debug('Se está ejecutando la consulta de Inventario');
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

    public void reservedQuantity(List<QuoteLineItem> item, Boolean isBefore, Boolean isAfter) {
        Set<Id> idProduct = new Set<Id>();

        for(QuoteLineItem i: item) {
            idProduct.add(i.Product2Id);
        }
        Map<Id, Product2> prodMap = new Map<Id, Product2>([
            SELECT Id, ExternalId, (SELECT Id, Cantidad_Reservada__c FROM Inventario__r)
            FROM Product2
            WHERE Id IN :idProduct
        ]);
        
        if(isBefore) {
            for(QuoteLineItem i : item) {
                if(item.Quantity > searchProductByCode(prodMap.get(item.Product2Id).ExternalId)) {
                    i.addError('Quantity cannot be greater than the Products Available Quantity');
                }
            }
        } else if(isAfter) {
            List<Inventario__c> invUpdate = new List<Inventario__c>();
            for(QuoteLineItem i : item) {
                Inventario__c invUp = prodMap.get(i.Product2Id).Inventario__r[0];
                invUp.Cantidad_Reservada__c += i.Quantity;
                invUpdate.add(invUp);
            }
            update invUpdate;
        }
    }

    @invocableMethod(label= 'Stock Empty Alert')
    public static void stockEmptyAlert() {
        List<Inventario__c> inv = productInInventory();
        List<Inventario__c> invUpdate = new List<Inventario__c>();
        FeedItem post = new FeedItem();

        post.parentId = UserInfo.getUserId();
        post.isRichText = true;
        post.body = 'El(los) producto(s): ';
        
        for (Inventario__c inventarios : inv) {
            
            Decimal quantity = inventarios.Cantidad_disponible__c - inventarios.Cantidad_Reservada__c;
            Boolean isTime = inventarios.Last_Stock_Alert__c < Datetime.now().addHours(-5) || inventarios.Last_Stock_Alert__c == null;

            if(quantity == 0 && isTime) {
                post.body += '<a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + inventarios.Id + '">' + inventarios.Product__r.Name.escapeHtml4() + '</a>, ';
                invUpdate.add(inventarios);
            }
        }

        post.body = post.body.substring(0, post.body.length() - 2);
        post.body += ' No hay existencia en inventario.';

        if(post.body.length() > 59) {
            insert post;
        }

        for(Inventario__c inventory : invUpdate) {
            inventory.Last_Stock_Alert__c = Datetime.now();
        }

        if (!invUpdate.isEmpty()) {
            update invUpdate;
        }
    }
}