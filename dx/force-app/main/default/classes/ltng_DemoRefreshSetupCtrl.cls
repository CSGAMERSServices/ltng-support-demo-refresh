/**
 * Controller for the Demo Setup page.
 **/
/*
 * //-- CHANGE
 * //-- ensure the class name matches the name of the Setup page + CTRL
 * //-- ex: ltng_DemoRefreshSetupCtrl
 **/
global with sharing class ltng_DemoRefreshSetupCtrl {

    //-- static
    
    /** URL patterm for navigating to a permissionSet **/
    global static final String DEFAULT_MISSING_PERMISSION_URL = '/one/one.app#/setup/PermSets/home';
	
	//--	-	-	-	-	-	-	-	-	-	-	-
	//-- START OF LINES TO UPDATE
	//--	-	-	-	-	-	-	-	-	-	-	-
    
    /** Developer Name for the Permission Set **/
    global static final String PERMISSION_SET_NAME = 'ltng_DemoLwcRefreshParticipant';
        
    /**
     * API Name of the Object to create.
     *	(Although not required, it is fairly common to create objects in setup)
     **/
    global static final String OBJECT_TENANT  = 'ltng_Tenant__c';
    global static final String OBJECT_TENANT_CHILD  = 'ltng_TenantChild__c';
    
    //-- @CHANGE: replace YOUR_RECORD_TYPE_NAME with the RecordType Developer Name
    //--	of the objects you will create - (if objects / record types are used)
    //--	ex: 'Master'
    //--	(e.g: SELECT Id, DeveloperName, Name, SObjectType FROM RecordType WHERE SObjectType = 'YOUR_RECORD_TYPE_NAME'
	
    /** Developer Name of the record types to use when creating records
    	(Leave blank if no record types are used)
    **/
    global static final String RT_NAME = '';

    

    /**
     * Method called from the Lightning Component to either:
     * 		Determine the steps that will be run,
     *		Or to run the steps and learn the results from running them.
     * 
     * @return SetupStep[] - list of setup steps ran and the status for each.
     **/
    @AuraEnabled
    global static SetupStep[] runSetup(boolean getInfoOnly){
    	
    	//-- Each method that is called returns a SetupStep instance.
    	
    	//-- if getInfoOnly is `TRUE`, then nothing is executed,
    	//-- and we only get info about the step to be run.
    	
    	//-- if getInfoOnly is `FALSE`, then the step is executed
    	//-- and info about what was run, including results/errors/etc., are returned.
    	
        SetupStep[] results = new SetupStep[]{
            removeAllBaseRecords(getInfoOnly),
            setupCustomSettings(getInfoOnly),
            createBaseRecords(getInfoOnly),
            addUserToPermissionSet(getInfoOnly)
            //-- @CHANGE: add in additional steps as desired
        };
        return results;
    }

    //-- actual steps to run

    /**
     * Remove any of the base records that are currently there.
     * @param getInfoOnly (Boolean) - whether to report what would be done (true) or run the step (false)
     **/
    global static SetupStep removeAllBaseRecords( boolean getInfoOnly){
        SetupStep step = new SetupStep( new Map<String,Object>{
            'title' => 'Remove any existing base objects'
        });

        if(getInfoOnly){
            return step;
        }
        
        SObject[] recordsToDelete = null;
        try {
            recordsToDelete = [
                SELECT Id
                FROM ltng_Tenant__c
            ];
            
            delete recordsToDelete;
        } catch(Exception err){
            step.errMsg = 'Error occurred while attempting to delete all Tenant records';
            step.devErrMsg = err.getMessage();
            //-- do nothing for now.
            System.debug(step.errMsg);
        }
        try {
            recordsToDelete = [
                SELECT Id
                FROM ltng_TenantChild__c
            ];
            
            delete recordsToDelete;
        } catch(Exception err){
            step.errMsg = 'Error occurred while attempting to delete all Tenant Children records';
            step.devErrMsg = err.getMessage();
            //-- do nothing for now.
            System.debug(step.errMsg);
        }
        
        step.markCompleted();
        return(step);
    }

    /**
     * Create the base records.
     * @param getInfoOnly (Boolean) - whether to report what would be done (true) or run the step (false)
     **/
    global static SetupStep createBaseRecords( boolean getInfoOnly ){
        SetupStep step = new SetupStep( new Map<String,Object>{
            'title' => 'Create Base Objects',
            'descr' => 'Create the objects that the demos start from'
        });

        if(getInfoOnly){
            return step;
        }
        
        //-- determine the record type Names => Salesforce ID translation map
		Set<String> RECORD_TYPE_NAMES = new Set<String>{RT_NAME};
        
        Map<String,Id> recordTypeMap = new Map<String,Id>();
        try {
        	if( !String.isEmpty(RT_NAME)){
				for( RecordType rt : [
					SELECT Id, DeveloperName, Name, SObjectType
					FROM RecordType
					WHERE SObjectType in :RECORD_TYPE_NAMES
				]){
					recordTypeMap.put(rt.DeveloperName, rt.Id);
				}
			}
        } catch(Exception err){
        	//-- for now, consume the error, as we handle it separately
        }
        
        //-- generate the objects to create by converting the Salesforce CLI:tree:export
        //-- into an apex version.

        ltng_Tenant__c[] tenantRecords = new ltng_Tenant__c[]{};

        tenantRecords.add(new ltng_Tenant__c(
            First_Name__c = 'John',
            Last_Name__c = 'Doe',
            Phone__c = '555-123-4567',
            Email__c = 'jdoe@example.com'
        ));
        tenantRecords.add(new ltng_Tenant__c(
            First_Name__c = 'Jane',
            Last_Name__c = 'Doe',
            Phone__c = '555-234-5678',
            Email__c = 'j.doe@example.com',
            Note__c = 'updated via related record'
        ));
        
        //-- finally add in the records
        
        try {
            insert tenantRecords;
        } catch( Exception err){
            step.errMsg = 'error occurred while creating Tenant records';
            step.devErrMsg = err.getMessage();
            System.debug(step.errMsg);
        }

        ltng_TenantChild__c[] tenantChildRecords = new ltng_TenantChild__c[]{};
        tenantChildRecords.add(new ltng_TenantChild__c(
            Amount__c = 400,
            Start_Date__c = Date.parse('12/31/2019'),
            End_Date__c = Date.parse('1/1/2019'),
            Tenant__c = tenantRecords[0].Id
        ));
        tenantChildRecords.add(new ltng_TenantChild__c(
            Amount__c = 300,
            Start_Date__c = Date.parse('12/31/2019'),
            End_Date__c = Date.parse('1/1/2019'),
            Tenant__c = tenantRecords[1].Id
        ));

        try {
            insert tenantChildRecords;
        } catch( Exception err){
            step.errMsg = 'error occurred while creating Tenant Child records';
            step.devErrMsg = err.getMessage();
            System.debug(step.errMsg);
        }
        
        step.markCompleted();
        return(step);
    }

    /**
     * Example step
     * @param getInfoOnly (Boolean) - whether to report what would be done (true) or run the step (false)
     **/
    global static SetupStep setupCustomSettings( boolean getInfoOnly ){
    	//-- @SEE SetupStep below - displayed in lightning component DemoSetupItem.cmp
    	SetupStep step = new SetupStep( new Map<String,Object>{
            'title' => 'Initialize the Scalable Salesforce custom setting',
            'descr' => 'Defines the configurable values for the app (ltng_ScalableSalesforceSettings__c).',
            'reasoning' => 'Custom Settings are accessible in some areas that custom metadata still cannot be used, but requires a record.'
        });
    
        if( getInfoOnly ){
        	return(step);
        }

        /*
        ltng_ScalableSalesforceSettings__c settings = null;

        Id orgId = UserInfo.getOrganizationId();

        try {
            settings = [ SELECT Id, SetupOwnerId FROM ltng_ScalableSalesforceSettings__c WHERE SetupOwnerId = :orgId ];
        } catch (Exception err){
            //-- might not be there yet.
            settings = ltng_ScalableSalesforceSettings__c.getInstance();
            settings.SetupOwnerId = orgId;
        }

        settings.Disable_all_Automation__c = false;
        settings.Status_Closed__c = 'Closed';
        settings.Status_Error__c = 'Error';
        settings.Status_Open__c = 'Open';
        settings.Status_Response__c = 'Response';

        //-- do stuff
        try {
        	upsert settings;
        } catch(Exception err){
        	step.errMsg = 'Could not update custom settings';
        	step.devErrMsg = err.getMessage();
        }
        */
        
        step.markCompleted();
        return(step);
    }

    
    
    //-- @CHANGE: add in any additional steps
    /**
     * Example step
     * @param getInfoOnly (Boolean) - whether to report what would be done (true) or run the step (false)
     **/
    /*
    global static SetupStep doSomethingElse( boolean getInfoOnly ){
    	//-- @SEE SetupStep below - displayed in lightning component DemoSetupItem.cmp
    	SetupStep step = new SetupStep( new Map<String,Object>{
            'title' => 'Assign current user PermissionSet to see the Demo',
            'descr' => 'PermissionSet: ' + PERMISSION_SET_NAME + '. May take a second to take effect.',
            'reasoning' => 'All access is granted by PermissionSet. Only those with this PermissionSet can see the demo'
        });
    
        if( getInfoOnly ){
        	return(step);
        }
        
        //-- do stuff
        try {
        	//-- do stuff
        } catch(Exception err){
        	step.errMsg = 'Could not do stuff';
        	step.devErrMsg = err.getMessage();
        }
        
        step.markCompleted();
        return(step);
    }
    */
    
    
    //--    -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
    //--    END OF LINES TO UPDATE
    //--    -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
    

    
    //--	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-
    
    
    /**
     * Assign the user to the custom permission.
     * <p>Note: actual work must be a future to avoid a MixedDML issue</p>
     **/
    global static SetupStep addUserToPermissionSet( boolean getInfoOnly ){
        SetupStep step = new SetupStep( new Map<String,Object>{
            'title' => 'Assign current user PermissionSet to see the Demo',
            'descr' => 'PermissionSet: ' + PERMISSION_SET_NAME + '. May take a second to take effect.',
            'reasoning' => 'All access is granted by PermissionSet. Only those with this PermissionSet can see the demo'
        });

        if( getInfoOnly ){
            return(step);
        }

        addUserToPermissionSetImpl();

        step.markCompleted();
        return(step);
    }

    
    /**
     * Implementation that actually adds the user to the permission set.
     **/
    @future
    global static void addUserToPermissionSetImpl(){    
        Id userId = UserInfo.getUserId();
        PermissionSetAssignment[] results = null;
        
        try {
            PermissionSet ps = [
                SELECT Id, Name
                FROM PermissionSet
                WHERE Name = :PERMISSION_SET_NAME
                LIMIT 1
            ];

            results = [
                SELECT Id, PermissionSetId, AssigneeId
                FROM PermissionSetAssignment
                WHERE AssigneeId = :userId
                    AND PermissionSetId = :ps.Id 
                LIMIT 1
            ];
            
            if(results.size() > 0){
                System.debug('User is already assigned to the PermissionSet');
            } else {
                results = new PermissionSetAssignment[]{
                    new PermissionSetAssignment( PermissionSetId = ps.Id, AssigneeId = UserInfo.getUserId() )
                };

                insert results;
            }
        } catch(Exception err){
            //-- do nothing
            System.debug('ERROR - could not assign user to permission set');
            System.debug(err.getMessage());
        }
    }
    
    
    /**
	 * Determine the URL to send people to so they can assign the PermissionSet
	 * the recordTypes needed.
	 * 
	 * <p>Only needed if objects are created and there are Record Types.
	 * 	(As there is a bug where PermissionSet assignments to RecordTypes
	 * 	currently do not deploy correctly in Unlocked Packages
	 * 	- but work fine with Salesforce CLI: force:source:push)
	 * </p>
	**/
    @AuraEnabled(cacheable=true)
    global static String getMissingPermissionSetRedirection(){
        String results = null;
        String tempStr = null;
        String newResult = null;
        
        try {
            PermissionSet targetPS = [
                SELECT Id, Name
                FROM PermissionSet
                WHERE Name = :PERMISSION_SET_NAME
                LIMIT 1
            ];

            EntityDefinition targetObject = [
                SELECT DeveloperName, DurableId
                FROM EntityDefinition 
                WHERE DeveloperName = :OBJECT_TENANT
            ];

            tempStr = '/' + targetPS.Id + '?s=EntityPermissions&o=' + targetObject.DurableId;
            newResult = '/one/one.app#/setup/PermSets/page?address=' + EncodingUtil.urlEncode(tempStr,'UTF-8');
            
            results = newResult;
        } catch(Exception err){
            results = DEFAULT_MISSING_PERMISSION_URL;
        }

        return results;
    }
    
    
    //--	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-
    
    
    /**
     * Internal class that represents an item to be completed.
     **/
    global class SetupStep {
        
    	/** Title of the Step being run. (Should be short) **/
        @AuraEnabled
        global String title;
        
        /** Longer form description of what will be run.
        	(Hidden if not provided)
        **/
        @AuraEnabled
        global String descr;
        
        /** Reasoning of why the step is needed.
        	(Hidden if not provided)
        **/
        @AuraEnabled
        global String reasoning;
        
        /** Additional detail to show the end user after the step.
        	(ex: Link to the object created, etc.)
        **/
        @AuraEnabled
        global String seeMore;
        
        /** Short label to provide back to the user after completing the step. **/
        @AuraEnabled
        global String seeMoreLabel;
        
        //-- properties set after attempt
    	
    	/** Whether the step is complete
    		(typically only set through markComplete())
    	**/
        @AuraEnabled
        global boolean isComplete;
        
        /** End user readible error found when running the step
        	(typically not initialized, only set afterwards)
        **/
        @AuraEnabled
        global String errMsg;
        
        /** Developer level error found when running the step
        	(typically not initialized, only set afterwards)
        **/
        @AuraEnabled
        global String devErrMsg;
        
        /** DateTime when the step completed.
    		(typically only set through markComplete())
    	**/
        @AuraEnabled
        global String completionDate;

        SetupStep( Map<String,Object> props){
            //-- make similar to sObject inline definition
            if( props.containsKey('title')){
                this.title = (String)props.get('title');
            }
            if( props.containsKey('descr')){
                this.descr = (String)props.get('descr');
            }
            if( props.containsKey('reasoning')){
                this.reasoning = (String)props.get('reasoning');
            }
            if( props.containsKey('seeMore')){
                this.seeMore = (String)props.get('seeMore');
            }
            if( props.containsKey('seeMoreLabel')){
                this.seeMoreLabel = (String)props.get('seeMoreLabel');
            }
            
            //-- not likely, but available if desired
			if( props.containsKey('isComplete')){
                this.isComplete = (boolean)props.get('isComplete');
            }
            if( props.containsKey('errMsg')){
                this.errMsg = (String)props.get('errMsg');
            }
            if( props.containsKey('devErrMsg')){
                this.devErrMsg = (String)props.get('devErrMsg');
            }
            if( props.containsKey('completionDate')){
                this.completionDate = (String)props.get('completionDate');
            }
        }
        
        /**
         * Mark the step as completed.
         * @invariant - marked completed with a current completion date.
         **/
        void markCompleted(){
            this.isComplete = true;
            this.completionDate = System.now().format();
        }
    }
}
