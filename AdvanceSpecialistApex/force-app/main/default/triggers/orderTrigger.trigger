/**
 * @name orderTrigger
 * @description
**/
trigger orderTrigger on Order (
    before insert, after insert
    ,before update, after update
    ,before delete, after delete
    ,after undelete
) {

   try{
        if(Trigger.isUpdate && Trigger.New != null){
            OrderHelper.AfterUpdate(Trigger.New,Trigger.old);
        }
    }catch(Exception e){
            System.debug('Exception in trigger -- '+e.getMessage());
    }
      
}