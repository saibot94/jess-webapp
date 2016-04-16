; Code you can run for testing purposes 


(load-facts "C:/Users/darkg/workspace/jess-webapp/WebContent/facts.clp")

(watch all)

(bind ?customerId 1)
(bind ?orderNumber (get-new-order-number))
(assert (order (customer-id ?customerId) (order-number ?orderNumber)))

(assert (line-item (order-number ?orderNumber) (part-number 1) (customer-id ?customerId) ))


(run)
(facts)

(bind ?it (run-query items-for-order ?orderNumber))
(while (?it hasNext)
	(bind ?t (?it next))
	(bind ?f (?t fact 1))
	(printout t (fact-slot-value ?f part-number) crlf)
)