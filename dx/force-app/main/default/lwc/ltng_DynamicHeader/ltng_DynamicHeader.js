/**
 * Simple component to provide a Lightning Design System header
 * without all the fuss.
 * @author Paul Roth <proth@salesforce.com>
 **/
import { LightningElement, track, api } from 'lwc'; //eslint-disable-line no-unused-vars

export default class ltng_DynamicHeader extends LightningElement {
  /**
   * The group of the icon (ex: standard, utility, etc)
   * @type {string}
   */
  @api iconGroup;

  /**
   * The name of the icon (ex:account or search)
   * @see https://lightningdesignsystem.com/icons/
   * @type {string}
   */
  @api iconName;

  /**
   * The alternative text for screen readers for the icon.
   * @type {string}
   */
  @api iconAlternativeText;

  /**
   * The title of the box
   * @type {string}
   */
  @api title;

  /**
   * The detail text to show beneath the title
   * @type {string}
   */
  @api detail;

  /**
   * Determines the icon phrase used in many areas within LWS
   * (ex: 'standard:opportunity' or 'utility:search')
   * @type {string}
   */
  @api
  get iconPhrase() {
    return this.iconGroup + ':' + this.iconName;
  }

  /**
   * Whether the detail information has been provided (and should be shown)
   * @type {boolean}
   */
  @api get hasDetail() {
    return this.detail ? true : false;
  }
}