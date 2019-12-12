/**
 * Simple component to provide a Lightning Design System header
 * without all the fuss.
 * @author Paul Roth <proth@salesforce.com>
 **/
import { LightningElement, track, api } from 'lwc'; //eslint-disable-line no-unused-vars

export default class ltng_DynamicHeader extends LightningElement {
  @api iconGroup;
  @api iconName;
  @api iconAlternativeText;
  @api title;
  @api detail;

  @api
  get iconPhrase() {
    return this.iconGroup + ':' + this.iconName;
  }
}