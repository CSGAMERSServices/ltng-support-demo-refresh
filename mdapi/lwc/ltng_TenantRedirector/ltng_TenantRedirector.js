/* eslint-disable no-console, no-unused-vars */
/**
 * Component that shows information about the tenant
 * and allows the user to edit
 **/
import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import {getRecord} from 'lightning/uiRecordApi';
import TENANT_FIELD from '@salesforce/schema/ltng_TenantChild__c.Tenant__c';

//-- we use the navigationMixin to support navigating or opening other places
//-- @see https://developer.salesforce.com/docs/component-library/documentation/lwc/lwc.use_navigate_basic

export default class ltng_TenantRedirector extends NavigationMixin(LightningElement) {
  /** use this to get the id of the current record we are on */
  @api recordId;

  /** The number of columns @type {number} */
  @api columns=2;
  /** The mode to show the form for @type {string} */
  @api mode='view';
  /** The layout to show the form with @type {string} */
  @api layout='Compact';
  
  /** get the id of the tenant */
  @wire(getRecord, {recordId: '$recordId', fields: [TENANT_FIELD]})
  record;

  /** id of the tenant this child is associated with */
  get tenantId() {
    return (!this.record || !this.record.data) ? null : this.record.data.fields.Tenant__c.value;
  }

  /** name of the tenant record - not needed, but just used as an example */
  get tenantName() {
    return (!this.tenantRecord || !this.tenantRecord.fields) ? '' : this.tenantRecord.fields.Name.value;
  }

  /** Shorthand for the tenant info when it is loaded, just to demonstrate how to use it. */
  @track tenantRecord;

  constructor() {
    super();
    console.log('Redirector completed');
  }

  //-- handlers
  /**
   * Handles when the user clicks on the button to open the tenant
   * @param {any} evt 
   */
  handleOpenTenant(evt) {
    console.log('user clicked button to open the tenant');

    //-- navigate to edit page
    //-- @see https://developer.salesforce.com/docs/component-library/documentation/lwc/lwc.use_navigate_page_types
    this[NavigationMixin.Navigate]({
      type: 'standard__recordPage',
      attributes: {
        recordId: this.tenantId,
        actionName: 'edit'
      }
    });
  }

  /**
   * Handles when the data is loaded from the lightning data service.
   * @param evt {any}
   */
  handleLoad(evt) {
    console.log('event data has loaded');

    try {
      this.tenantRecord = evt.detail.records[this.tenantId];
      //-- to make it more readible, do something like this
      this.tenantRecord = JSON.parse(JSON.stringify(this.tenantRecord));
    } catch(err){
      // console.error('tenant record not loaded yet.');
    }
  }

  /**
   * Handles when the form is ready for submit.
   * @param evt {any}
   */
  handleSubmit(evt) {
    console.log('event data ready for submission');
  }

  /**
   * Handles when the data has been completed update
   * @param evt {any}
   */
  handleSuccess(evt) {
    console.log('data has been successfully submitted');
  }
}