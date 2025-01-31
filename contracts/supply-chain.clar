;; Supply Chain Tracking Contract

;; Constants
(define-constant err-not-found (err u100))
(define-constant err-unauthorized (err u101))

;; Status types
(define-data-var status-types (list 10 (string-ascii 32))
  (list "harvested" "processed" "packaged" "shipped" "delivered"))

;; Track product status & location
(define-map tracking-records
  { product-id: uint }
  {
    status: (string-ascii 32),
    location: (string-ascii 64),
    handler: principal,
    timestamp: uint
  })

;; Record status update
(define-public (record-status
  (product-id uint)
  (new-status (string-ascii 32))
  (location (string-ascii 64)))
  (let (
    (product (contract-call? .product-registry get-product product-id)))
    (asserts! (is-some product) (err err-not-found))
    (map-set tracking-records
      { product-id: product-id }
      {
        status: new-status,
        location: location, 
        handler: tx-sender,
        timestamp: block-height
      })
    (ok true)))
