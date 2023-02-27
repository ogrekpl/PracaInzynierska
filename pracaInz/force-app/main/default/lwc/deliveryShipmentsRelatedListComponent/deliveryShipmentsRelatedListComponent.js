import { LightningElement, api, wire} from 'lwc';
import getListToDisplay from '@salesforce/apex/DeliveryShipmentsRelatedListController.getListToDisplay';
import PALLET_AMOUNT from '@salesforce/schema/Delivery_Shipment__c.Pallet_amount__c'
import QUANTITY from '@salesforce/schema/Delivery_Shipment__c.Quantity__c'
export default class DeliveryShipmentsRelatedListComponent extends LightningElement {

    COLUMNS = [
        { label: 'Delivery Order Name', fieldName: 'DeliveryOrderName', type: 'text' },
        { label: 'Quantity', fieldName: QUANTITY.fieldApiName, type: 'text' },
        { label: 'Pallet amount', fieldName: PALLET_AMOUNT.fieldApiName, type: 'text' },
        { label: 'Pallet type', fieldName: 'Pallet_Type', type: 'text' },
        { label: 'Company Product', fieldName: 'CompanyProduct', type: 'text' }
        ];

    @api recordId;
    @wire(getListToDisplay, {shipmentId: '$recordId'})
    deliveryShipments;

    
}