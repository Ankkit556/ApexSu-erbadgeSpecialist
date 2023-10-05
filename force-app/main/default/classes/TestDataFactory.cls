/**
 * @name TestDataFactory
 * @description Contains methods to construct and/or validate commonly used records
**/
public with sharing class TestDataFactory {

    public static CollaborationGroup ConstructCollaborationGroup(){
    	CollaborationGroup c = new CollaborationGroup();
        c.Name = 'TEST' + Constants.INVENTORY_ANNOUNCEMENTS +1;
        c.CollaborationType = 'Public';
        return c;
    }

    public static List<Product2> ConstructProducts(Integer cnt){
        List<Schema.PicklistEntry> familyList = Product2.Family.getDescribe().getPicklistValues();
        Integer listSize = familyList.size();

        List<Product2> p = new List<Product2>();
        for(Integer i=0;i<cnt;i++){
            Product2 prod = new Product2();
            prod.Name = 'Product ' +i;
            prod.isActive = true;
            prod.Initial_Inventory__c = 10;
            prod.Family = familyList[Math.mod(i, listSize)].getValue();
            p.add(prod);
 
        }
            
        return p;
    }

    
    public static List<PricebookEntry> ConstructPricebookEntries(List<Product2> p){
        List<PricebookEntry> pbe = new List<PricebookEntry>();
        for(Product2 prd : p){
            PricebookEntry entry = new PricebookEntry();
            entry.Product2Id = prd.Id;
            entry.isActive = true;
       		entry.UnitPrice = 1;
            entry.Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID;
            pbe.add(entry);
        }
        
        return pbe;
    }

    
    public static List<Account> ConstructAccounts(Integer cnt){
        List<Account> acts = new List<Account>();
        for(Integer i=0; i<cnt; i++){
            Account a = new Account();
            a.Name = 'Account ' +i;
            acts.add(a);
            
        }
        return acts;
    }

    public static List<Contact>ConstructContacts(Integer cnt, List<Account> accounts){
        Integer listSize = accounts.size();
        List<Contact> contacts = new List<Contact>();
        for(Integer i =0; i<cnt; i++){
            Contact cont = new Contact();
            cont.FirstName = 'Jane';
            cont.LastName = 'Contact ' +i;
            cont.AccountId= accounts[i].Id;
         	contacts.add(cont);    
        }
        system.debug('size of my contact list ' +contacts.size());
        return contacts;
        
    }


    public static List<Order> ConstructOrders(Integer cnt, List<Account> acts){
        List<Order> o = new List<Order>();
        for(Integer i=0;i<cnt;i++){
            Order ord = new Order();
            ord.Name = 'Order ' +i;
            ord.AccountId =acts[i].id;
            ord.EffectiveDate = date.today();
            ord.Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID;   
            ord.Status = constants.DRAFT_ORDER_STATUS;
            o.add(ord);
        }
        return o;
    }


    public static List<OrderItem> ConstructOrderItems(integer cnt, list<pricebookentry> pbe, list<order> o){
        system.debug('***Construct order items cnt pbe and o : ' +cnt +pbe +o);
        List<OrderItem> oi = new List<OrderItem>();
        for(Integer i=0;i<cnt;i++){
            OrderItem oitem = new OrderItem();
            oitem.orderid = o[i].id; 
           	oitem.PricebookEntryId = pbe[i].id;
            oitem.Quantity = constants.DEFAULT_ROWS;
            oitem.UnitPrice = 1;
            system.debug('Here is my order item ' +oitem);
            oi.add(oitem);
            
        }
        return oi;   
    }

   
    public static void InsertTestData(Integer cnt){

        CollaborationGroup chatterg = ConstructCollaborationGroup();
        insert chatterg;
        
        List <Product2> products = ConstructProducts(cnt);
        insert products;
       
        List <PricebookEntry> entries = ConstructPricebookEntries(products);
        insert entries;
        
        List<Account> accounts = ConstructAccounts(cnt);
        insert accounts;
        system.debug('Accounts I inserted ' +accounts);
        
        List<Contact> contacts = ConstructContacts(cnt,accounts);
        insert contacts;
        system.debug('Contacts I inserted ' +contacts);
        
        List<Order> orders = ConstructOrders(cnt,accounts);
        system.debug('orders before insert' +orders);
        insert orders;
        
        List<OrderItem> items = ConstructOrderItems(cnt,entries,orders);
        system.debug('items before  insert ' +items);
        insert items;
        system.debug('items i inserted ' +items);    

    }
}
