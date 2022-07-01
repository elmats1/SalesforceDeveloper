trigger CotizacionTrigger on QuoteLineItem (before insert, after insert) {
    QuotationHelper qh = new QuotationHelper();
    qh.reservedQuantity(Trigger.new, Trigger.isBefore, Trigger.isAfter);
}