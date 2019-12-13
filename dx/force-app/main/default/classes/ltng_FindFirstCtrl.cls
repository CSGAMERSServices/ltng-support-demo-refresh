/**
 * Controller for the find first demo component
 **/
global with sharing class ltng_FindFirstCtrl {
    
    /**
     * Finds and returns the id of the first record
     * of a given sobject
     * @param sobject {string}
     * @return {Id}
     **/
    global static String findFirstSObject(String sObjectName) {
        String query = 'SELECT Id ' +
            'FROM ' + sObjectName + ' ' +
            'ORDER BY LastModifiedDate desc limit 1';
        Id recordId = null;

        try {
            recordId = Database.query(query).Id;
        } catch(Exception err){
            System.debug('could not find any records of type ' + sObjectName);
        }

        return recordId;
    }
}
