import { LightningElement, api, wire} from 'lwc';
import getListToDisplay from '@salesforce/apex/BatchSummaryController.getListToDisplay';

export default class BatchSummaryComponent extends LightningElement {
    COLUMNS = [
        { label: 'Warehouse', fieldName: 'Warehouse', type: 'text' },
        { label: 'Shipment', fieldName: 'Shipment', type: 'text' },
        { label: 'Shipment Status', fieldName: 'Shipment_Status', type: 'text' },
        { label: 'Pallets Amount', fieldName: 'Pallets_Amount', type: 'number', sortable: 'true' },
        { label: 'Quantity', fieldName: 'Quantity', type: 'number', sortable: 'true'}
        ];
    
    sortedBy;
    sortDirection;
    @api recordId;

    @wire(getListToDisplay, {deliveryOrderId: '$recordId'})
    listToDisplay;

    sortBy(field, reverse, primer) {
        const key = primer 
            ? function (x) {    
                return primer(x[field]); 
            } 
            : function (x) { 
                return x[field]; 
            };
 
        return function (a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }
 
    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.listToDisplay.data];
 
        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.listToDisplay.data = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }  
}