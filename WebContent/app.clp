
(deftemplate product
	(slot name)
	(slot category)
	(slot part-number)
	(slot price)
	(multislot requires))

(deftemplate order
	(slot customer-id)
	(slot order-number))

(deftemplate customer
    (slot customer-id)
    (slot order-number))

(deftemplate line-item
    (slot order-number)
    (slot part-number)
    (slot customer-id)
    (slot quantity (default 1)))

(deftemplate recommend
	(slot order-number)
	(multislot because)
	(slot type)
	(slot part-number))

(defquery all-products
    (product))





(defrule recommend-requirements
	(order (customer-id ?id) (order-number ?currentOrder))
	(not (order (customer-id ?id)
		(order-number ?order2&:(> ?order2 ?currentOrder))))
	(line-item (order-number ?currentOrder) (part-number ?part))
	(product (part-number ?part) (name ?product)
		(requires $? ?category $?))
	(product (category ?category) (price ?price)
        (part-number ?second-part))
    (not (product (category ?category) (price ?p&:(> ?p ?price))))
    
    => 
    (assert (recommend (order-number ?currentOrder)
            			(type requirement)
            			(part-number ?second-part)
            			(because ?product))))
    
    
(defrule recommend-media-for-player
    "IF a customer has bought a DVD or VCR in the past, recommend some media for it"
    (product (part-number ?media) (category ?c & dvd-disk | videotape))
    (product (name ?name) (part-number ?player)
        (category =(if (eq ?c dvd-disk) then dvd else vcr)))
    (line-item (part-number ?player) (order-number ?order1)
        	(customer-id ?id))
    (order (customer-id ?id)
        	(order-number ?currentOrder&:(> ?currentOrder ?order1)))
    (not (order (customer-id ?id)
            (order-number ?order3&:(> ?order3 ?currentOrder))))
    (not (line-item (customer-id ?id) (part-number ?media)))
    (not (recommend (order-number ?currentOrder)
            (type =(sym-cat discretionary- ?c))))
    =>
    (assert (recommend (order-number ?currentOrder)
            		(because ?name)
            		(part-number ?media)
            		(type =(sym-cat discretionary- ?c)))))


(defrule reduce-third-items-price
    "If a customer bought two products of a type in the past, recommend him a third one at 50%"
    ?p0 <- (product (part-number ?part1) (category ?c))
    ?p2 <- (product (part-number ?part2) (category ?c))
    ?p1 <- (product (part-number ?part3) (category ?c) (price ?price))
    (test (neq ?p0 ?p2))
    
    ; he bought two items of that in the past
    (line-item (customer-id ?id) (part-number ?part1) (order-number ?order1))
    (line-item (customer-id ?id) (part-number ?part2) (order-number ?order2))
    (order (customer-id ?id)
		(order-number ?currentOrder&:(and (> ?currentOrder ?order1)
										  (> ?currentOrder ?order2))))

    ;; allow only one discount per category
    (not (recommend (type =(sym-cat discount- ?c))))
    =>
    (assert (product (name =(str-cat "Discount " (fact-slot-value ?p1 name)))
    				 (category =(sym-cat discount- ?c))
            
    				 (price =(/ ?price 2))
    				 (part-number =(sym-cat discount- ?part3))
    				 (requires =(fact-slot-value ?p1 requires))))
    (assert (recommend (order-number ?currentOrder)
    					(because (fact-slot-value ?p0 name) (fact-slot-value ?p2 name))
    					(part-number =(sym-cat discount- ?part3))
    					(type =(sym-cat discount- ?c)))
    ))

(defrule recommend-more-media
    "If a customer buys a disk or tape, recommend a random item of the same category"
    ?p1 <- (product (part-number ?part1)
        		(category ?c&dvd-disk|videotape)
        		(name ?name))
    ?p2 <- (product (part-number ?part2) (category ?c))
    (test (neq ?p1 ?p2))
    (line-item (order-number ?order) (part-number ?part1))
    (not (recommend (order-number ?order)
            (type =(sym-cat discretionary- ?c))))
    =>
    (assert (recommend (order-number ?order)
    			(because ?name)
    			(part-number ?part2)
            	(type =(sym-cat discretionary- ?c)))))

(defrule recommend-same-type-of-media
    "If a customer has bought a disk or tape in the past recommend the same type of item"
    ?p1 <- (product (part-number ?part1)
			(category ?c&dvd-disk|videotape) (name ?name))
    ?p2 <- (product (part-number ?part2)
        	(category ?c))
    (test (neq ?p1 ?p2))
    ;; This customer has bought one of them in a past order
    (line-item (order-number ?order1) (part-number ?part1) (customer-id ?id))
    (order (customer-id ?id) 
        	(order-number ?currentOrder&:(> ?currentOrder ?order1)))
    (not (order (customer-id ?id)
            (order-number ?order3&:(> ?order3 ?currentOrder ))))
    
    ;; But not the other one
    (not (line-item (customer-id ?id) (part-number ?part2)))
    
    ;; And we haven't recommended any media of this type yet
    (not (recommend (order-number ?currentOrder) 
            	(type =(sym-cat discretionary- ?c))))
    => 
    
    ;; Recommend the other one.
    (assert (recommend (order-number ?currentOrder)
            	(type =(sym-cat discretionary- ?c))
            	(part-number ?part2)
            	(because ?name))))

(defrule coalesce-recommendations
    "If two recommendations are made on the same item, turn them into one"
    ?r1 <- (recommend (order-number ?order) (type ?type)
        			(part-number ?part) (because ?product))
    ?r2 <- (recommend (order-number ?order) (part-number ?part)
        		(because $?products&
            			 :(not (member$ 
                    				?product
                    				$?products))))
    
    =>
    (retract ?r1 ?r2)
    (assert (recommend (order-number ?order) (part-number ?part)
            	(type ?type) 
            	(because (create$ ?product $?products)))))

;(deffacts Testfacts1
;    "Test facts for the coalesce-recommendations rule"
;   (recommend (order-number 1) (type discretionary-dvd)
;        	(part-number 1) (because big-tv-1))
;	(recommend (order-number 1) (type discretionary-videotape)
;        	(part-number 1) (because big-tv-2 dvd-player-3))
;    )

(defrule remove-satisfied-recommendations
	"If there are two products in the same category, and
	one is part of an order, and there is a recommendation
	of type 'requirement' for the other part, then remove
	the recommendation, as the customer is
	already buying something in that category."
	(product (part-number ?part1) (category ?category))
	(product (part-number ?part2) (category ?category))
	(line-item (order-number ?order) (part-number ?part2))
	?r <- (recommend (order-number ?order)
			(part-number ?part1) (type requirement))
	=>
	(retract ?r))

;; Queries here

(defquery items-for-order
    (declare (variables ?order))
    (line-item (order-number ?order) (part-number ?part))
    (product (part-number ?part)))
(defquery recommendations-for-order
    (declare (variables ?order))
    (recommend (order-number ?order) (part-number ?part))
    (product (part-number ?part)))

;; Represent the auto-incremental order number
(deftemplate next-order-number
    (slot value))

(defquery order-number
    (next-order-number))

(deffunction get-new-order-number ()
    (bind ?it (run-query order-number))
    (if (not (?it hasNext)) then
    	(assert (next-order-number (value 1002)))
    	(return 1001)
    else
    	(bind ?token (?it next))
    	(bind ?fact (?token fact 1))
    	(bind ?number (fact-slot-value ?fact value))
    	(retract ?fact)

    	(assert (next-order-number (value (+ ?number 1)) ))
    	(return ?number)))



(deffacts product-catalog

  (product (name "TekMart VC-103 VCR") (category vcr)
           (part-number TMVC103) (price 125)
           (requires video-cables tv batteries videotape))
  (product (name "TekMart DVD-223 DVD Player") (category dvd)
           (part-number TMDVD223) (price 225)
           (requires video-cables tv batteries dvd-disk))
  (product (name "TekMart TV-19 19'' TV") (category tv)
           (part-number TMTV19) (price 229)
           (requires batteries))
  (product (name "TekMart TV-24 24'' TV") (category tv)
           (part-number TMTV24) (price 299)
           (requires batteries))
  (product (name "Eraserhead VHS") (category videotape)
           (part-number EHVHS) (price 25.99)
           (requires vcr))
  (product (name "Casablanca VHS") (category videotape)
           (part-number CBVHS) (price 12.99)
           (requires vcr))
  (product (name "Repo Man VHS") (category videotape)
           (part-number RMVHS) (price 19.99)
           (requires vcr))
  (product (name "Dumbo DVD") (category dvd-disk)
           (part-number DDVD) (price 19.99)
           (requires dvd))
  (product (name "The Matrix DVD") (category dvd-disk)
           (part-number MDVD) (price 29.99)
           (requires dvd))
  (product (name "TekMart CB-32 Video Cables") (category video-cables)
           (part-number TMCB32) (price 24.99))
  (product (name "Bose Gold Standard Video Cables") (category video-cables)
           (part-number BGSVC) (price 54.99))
  (product (name "4-pack Duracell AA Batteries") (category batteries)
           (part-number DBAA4PK) (price 3.99))
  (product (name "10-pack TekMart AA Batteries") (category batteries)
           (part-number TMAA10PK) (price 1.99))
	(product (name "Blu-ray & DVD Player") (category dvd) (part-number TESTDVD2) (price 120))
	(product (name "Home VCR") (category vcr) (part-number TESTVCR1) (price 125) (requires videotape))
	(product (name "Gilette Shaving Cream") (category hygene) (part-number HYG1) (price 50))
	(product (name "The Revenant DVD") (category dvd-disk) (part-number TESTDVD3) (price 120))
	(product (name "Eternal Sunshine of the Spotless Mind") (category dvd) (part-number TESTDVD5) (price 30))
	(product (name "Nivea Cream Shower Gel") (category hygene) (part-number NIVEA1) (price 15))
	(product (name "Herbal Skincare cream") (category hygene) (part-number CREAM1) (price 25))
  )


(defmodule CLEANUP)

(defrule CLEANUP::initialize-order-1
  (declare (auto-focus TRUE))
  (MAIN::initialize-order ?number)
  ?item <- (line-item (order-number ?number))
  =>
  (retract ?item))

(defrule CLEANUP::initialize-order-2
  (declare (auto-focus TRUE))
  (MAIN::initialize-order ?number)
  ?rec <- (recommend (order-number ?number))
  =>
  (retract ?rec))

(defrule CLEANUP::initialize-order-3
  (declare (auto-focus TRUE))
  ?init <- (MAIN::initialize-order ?number)
  (not (line-item (order-number ?number)))
  (not (recommend (order-number ?number)))
  =>
  (retract ?init))

(defrule CLEANUP::clean-up-order
  (declare (auto-focus TRUE))
  ?clean <- (MAIN::clean-up-order ?number)
  ?order <- (order (order-number ?number))
  =>
  (assert (initialize-order ?number))
  (retract ?clean ?order))

(set-current-module MAIN)
