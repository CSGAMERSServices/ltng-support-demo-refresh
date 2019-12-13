/* eslint-disable no-unused-vars, no-console */

/**
 * Component that sets up the Scalable Salesforce demo.
 * <p>Assigns permission sets, creates custom setting records, creates records, etc.</p>
 * 
 * @component ltng_demoRefreshSetup / ltng_demo-refresh-setup
 */
import { LightningElement, track, api, wire } from 'lwc';

import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';

import runSetupApex from '@salesforce/apex/ltng_DemoRefreshSetupCtrl.runSetup';

import missingPermissionRedirectionApex from '@salesforce/apex/ltng_DemoRefreshSetupCtrl.getMissingPermissionSetRedirection';

export default class ltng_demoRefreshSetup extends NavigationMixin(LightningElement) {

  /** whether the setup is currently running */
  @track isRunningSetup = false;

  /** error when running into setup */

  /** the list of setup steps */
  @track setupSteps = [];

  //-- handlers

  connectedCallback(){
    this.calculateSteps(false);
  }

  /** handler for when the user indicates to start running the setup */
  handleSetupClicked(){
    this.calculateSteps(true);
  }

  /**
   * Calculates the steps to perform.
   * @param {boolean} shouldExecute - whether the setup should run (true) or only get information (false)
   */
  calculateSteps(shouldExecute){
    console.log('start setup button clicked');

    this.isRunningSetup = true;
    this.setupError = null;

    const getInfoOnly = !(shouldExecute === true);

    // const exampleResults = [{"completionDate":"4/9/2019 1:10 PM","isComplete":true,"title":"Remove any existing base objects"},{"completionDate":"4/9/2019 1:10 PM","descr":"Defines the configurable values for the app (ltng_ScalableSalesforceSettings__c).","isComplete":true,"reasoning":"Custom Settings are accessible in some areas that custom metadata still cannot be used, but requires a record.","title":"Initialize the Scalable Salesforce custom setting"},{"completionDate":"4/9/2019 1:10 PM","descr":"Create the objects that the demos start from","isComplete":true,"title":"Create Base Objects"},{"completionDate":"4/9/2019 1:10 PM","descr":"PermissionSet: ltng_ScalableSalesforceDemoParticipant. May take a second to take effect.","isComplete":true,"reasoning":"All access is granted by PermissionSet. Only those with this PermissionSet can see the demo","title":"Assign current user PermissionSet to see the Demo"}];
    // this.isRunningSetup = false;
    // this.setupSteps = exampleResults;

    runSetupApex({getInfoOnly:getInfoOnly})
      .then(results => {
        this.isRunningSetup = false;
        this.setupSteps = results;
      })
      .catch(error => {
        console.error('an error occurred', error);
      })
      .finally( () => {
        this.isRunningSetup = false;
      });
  }

  /** handler for those that need to open the permission set page */
  handlePermissionSetOpen(){
    console.log('handlePermissionSetOpen called');
    missingPermissionRedirectionApex( {} )
      .then(targetAddress => {
        console.log('permission set address:', targetAddress);
        this.navigateToRecord(targetAddress);
      })
      .catch(error => {
        //-- @TODO: handle error
        console.error('error occurred jsMethodName:jsImportedApexMethodName', JSON.stringify(error));
        this.error = error;
      })
  }

  /**
   * Navigates to a given url
   * @param {string} targetURL
   */
  navigateToRecord(targetURL) {
    this[NavigationMixin.Navigate]({
      type: 'standard__webPage',
      attributes: {
        url: targetURL
      }
    });
  }
}
