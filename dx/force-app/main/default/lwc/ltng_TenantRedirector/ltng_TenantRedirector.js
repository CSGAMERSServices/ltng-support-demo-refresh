/* eslint-disable no-console */
/**
 * Component that shows information about the tenant
 * and allows the user to edit
 **/
import { LightningElement, track, api, wire } from 'lwc';

import {getRecord} from 'lightning/uiRecordApi';
import TENANT_FIELD from '@salesforce/schema/ltng_TenantChild__c.Tenant__c';

export default class ltng_TenantRedirector extends LightningElement {
  /** use this to get the id of the current record we are on */
  @api recordId;

  /** The number of columns @type {number} */
  @api columns=2;
  /** The mode to show the form for */
  @api mode='view';
  /** The layout to show the form with */
  @api layout='Compact';
  
  /** get the id of the tenant */
  @wire(getRecord, {recordId: '$recordId', fields: [TENANT_FIELD]})
  record;

  /** id of the tenant this child is associated with */
  get tenantId() {
    return (!this.record || !this.record.data) ? null : this.record.data.fields.Tenant__c.value;
  }

  constructor() {
    super();
    console.log('Redirector completed');
  }
}