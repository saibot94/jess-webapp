; Code you can run for testing purposes 

(deffacts test-facts
	(MAIN::next-order-number (value 1003))
	(MAIN::order (customer-id cristi) (order-number 1002))
	(MAIN::line-item (order-number 1001) (part-number CREAM1) (customer-id cristi) (quantity 1))
	(MAIN::line-item (order-number 1001) (part-number NIVEA1) (customer-id cristi) (quantity 1))
	(MAIN::order (customer-id cristi) (order-number 1001))
)
(watch all)