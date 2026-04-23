@AbapCatalog.sqlViewName: 'ZVIPOOVERVIEW'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Basic View for Purchase Order Data'
@Metadata.ignorePropagatedAnnotations: true
define view Z_I_PO_OVERVIEW as select from ekko as header
      inner join ekpo as item on header.ebeln = item.ebeln
      inner join lfa1 as vendor on header.lifnr = vendor.lifnr
{
    key header.ebeln as PurchaseOrder,
    key item.ebelp as PurchaseOrderItem,
    
    header.aedat as CreationDate,
    header.ernam as CreatedBy,
    
    header.lifnr as VendorNumber,
    vendor.name1 as VendorName,
    
    item.matnr as Material,
    item.txz01 as MaterialDescription,
    
    @Semantics.quantity.unitOfMeasure: 'OrderUnit'
    item.menge as Quantity,
    item.meins as OrderUnit,
    
    @Semantics.amount.currencyCode: 'Currency'
    item.netpr as Netprice,
    header.waers as Currency,
    
    item.werks as Plant
}
