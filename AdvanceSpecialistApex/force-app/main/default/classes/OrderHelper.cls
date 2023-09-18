public class OrderHelper {

    /**
     * @name AfterUpdate
     * @description 
     * @param List<Order> newList
     * @param List<Order> oldList
     * @return void
    **/
    public static void AfterUpdate(List<Order> newList, List<Order> oldList){
        Set<Id> orderIds = new Set<Id>();
       /*  List<Product2> proList = new List<Product2>();
        List<Id> orderItemIds = new List<Id>();
        try {
            if ( newList != null ){
                for ( Order o : newList ){
                    if(o.ActivatedDate != null){
                        orderItemIds.add(o.Id);
                    }   
                }
            }
            for ( OrderItem oi : [
                        SELECT Id, Product2Id, Product2.Quantity_Ordered__c, Quantity
                        FROM OrderItem
                        WHERE OrderId = :orderItemIds 
                    ]){
                        Product2 p = oi.Product2;
                        p.Quantity_Ordered__c -= oi.Quantity;
                        proList.add(p);
                    }
            //List<Database.SaveResult> results = Database.update(proList);
        }catch ( Exception e ){
        
        }  */
        for ( Integer i=0; i<newList.size(); i++ ){
            if ( newList[i].Status == Constants.ACTIVATED_ORDER_STATUS && oldList[i].Status != Constants.ACTIVATED_ORDER_STATUS ){
                orderIds.add(newList[i].Id);
            }
        }
        OrderHelper.RollUpOrderItems(orderIds);
    }

    /**
     * @name RollUpOrderItems
     * @description Given a set of Activated Order ids, query the child Order Items and related Products to calculate Inventory levels
     * @param Set<Id> activatedOrderIds
     * @return void
    **/
    public static void RollUpOrderItems(Set<Id> activatedOrderIds){
        List<Product2> proList = new List<Product2>();

        //ToDo: Declare a Map named "productMap" of Ids to Product2 records
        Map<Id,Product2> productMap = new Map<Id, Product2>();
        //ToDo: Loop through a query of OrderItems related to the activatedOrderIds
        for(OrderItem orItem : [Select EndDate, Id, ListPrice, Product2.Id, OrderId, Product2Id ,PricebookEntryId, Quantity, ServiceDate, TotalPrice, UnitPrice  FROM orderitem WHERE orderId IN:activatedOrderIds]){
            productMap.put(orItem.Product2.Id, orItem.Product2);
        }
            //ToDo: Populate the map with the Id of the related Product2 as the key and Product2 record as the value

       /*  for(Product2 product : [Select Description, DisplayUrl, Initial_Inventory__c, Name, ProductClass, Quantity_Ordered__c, Quantity_Remaining__c, QuantityUnitOfMeasure, StockKeepingUnit, Type FROM Product2 WHERE Id IN:productMap.keySet()] ){
            
        } */
        //ToDo: Loop through a query that aggregates the OrderItems related to the Products in the ProductMap keyset
        for(AggregateResult ag : [SELECT Sum(Quantity), Product2Id FROM OrderItem WHERE Product2Id IN : productMap.keySet() Group By Product2Id]){
            Id product2Id = (Id)ag.get('Product2Id');
            Product2 prod = productMap.get(product2Id);
            prod.Quantity_Ordered__c = (Decimal)ag.get('expr0');
            productMap.put(product2Id , prod);
        }
        //ToDo: Perform an update on the records in the productMap
        try { 
            if(productMap.values() != null && productMap.values().size() > 0){ 
                update productMap.values(); 
            } 
        }catch ( Exception e ){ 
            System.debug('#### Exception Executed : '+e.getStackTraceString()); 
        }
       // List<Database.SaveResult> results = Database.update(proList);

    }

}