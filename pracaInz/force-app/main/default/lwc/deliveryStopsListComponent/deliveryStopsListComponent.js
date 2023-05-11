import { LightningElement, api, wire } from 'lwc';
import getDeliveryStopIdsList from '@salesforce/apex/DeliveryStopsListController.getDeliveryStopIdsList';

export default class DeliveryStopsListComponent extends LightningElement {
    @api recordId;

    @wire(getDeliveryStopIdsList, {deliveryOrderId: '$recordId'})
    dsList;
}