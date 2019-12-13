/**
 * Individual item to complete within the setup.
 * 
 * @component ltng_demoRefreshSetupItem ltng_demo-refresh-setup-item
 **/
import { LightningElement, api } from 'lwc';

export default class ltng_demoRefreshSetupItem extends LightningElement {

  /** setup step data */
  _completionStep;

  //-- getter / setter methods
  @api iconName;
  @api expanderClass;
  @api timeLineClass;
  @api isExpanded;

  //-- initializion methods
  connectedCallback(){
    console.log('connected callback for setup item called');
  }

  @api
  get completionStep(){
    return this._completionStep;
  }
  set completionStep(value){
    this._completionStep = value;
    this.reset();
    this.calcIconName(value);
    this.calcTimelineClass(value);
    this.calcExpanderClass(value);
  }

  //-- @TODO: make more functional

  //-- handlers
  
  /**
   * Handle whent he see more button is clicked
   * @param {*} event - javascript event
   */
  handleSeeMoreClicked(event){
    console.log('user clicked see more information', event);
  }
  
  /**
   * Handle when the expansion toggle is clicked
   * @param {*} event - javascript event
   */
  handleExpansionToggle(event){
    console.log('expansion toggle clicked', event);
    this.toggleExpansion();
  }

  //-- internal methods

  toggleExpansion(){
    this.isExpanded = !this.isExpanded;
    this.calcTimelineClass(this.completionStep);
  }

  reset(){
    this.isExpanded = false;

    if (!this.completionStep){
      this.completionStep = {};
    }

    return null;
  }

  calcIconName(completionStep){
    let iconName = 'standard:canvas';
    if (completionStep.errMsg){
      iconName = 'standard:product_required';
    } else if (completionStep.isComplete){
      iconName = 'standard:task2';
    }

    this.iconName = iconName;
    return iconName;
  }

  calcTimelineClass(completionStep){
    let timeLineBaseClass = "slds-timeline__item_expandable ";
		let timeLineClass = "slds-timeline__item_email";
		let isExpanded = "";

		if(completionStep.errMsg){
			timeLineClass = "slds-timeline__item_event";
		} else if(completionStep.isComplete === true){
			timeLineClass = "slds-timeline__item_task";
		}

		if(this.isExpanded === true){
			isExpanded = " slds-is-open";
		}

    let result = timeLineBaseClass + timeLineClass + isExpanded;
    
    this.timeLineClass = result;
    return result;
  }

  calcExpanderClass(completionStep){
    let baseClasses = "slds-button slds-button_icon";
		let visibilityHiddenClass = 'visibility-hidden';
		let result = baseClasses;

		let reasoningValue = completionStep.reasoning;
		let seeMoreValue = completionStep.seeMore;

		if( !(reasoningValue) && !(seeMoreValue)){
			result += ' ' + visibilityHiddenClass;
		}

    this.expanderClass = result;

    return(result);
  }


}