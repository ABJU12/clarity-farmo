;; Product Registry Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-not-owner (err u100))
(define-constant err-already-registered (err u101))
(define-constant err-not-found (err u102))

;; Data structures
(define-map products
  { product-id: uint }
  {
    owner: principal,
    product-type: (string-ascii 64),
    origin: (string-ascii 64), 
    timestamp: uint,
    certifications: (list 10 uint)
  })

(define-data-var next-product-id uint u0)

;; Register new product
(define-public (register-product 
  (product-type (string-ascii 64))
  (origin (string-ascii 64)))
  (let
    ((product-id (var-get next-product-id)))
    (map-insert products
      { product-id: product-id }
      {
        owner: tx-sender,
        product-type: product-type,
        origin: origin,
        timestamp: block-height,
        certifications: (list)
      }
    )
    (var-set next-product-id (+ product-id u1))
    (ok product-id)))

;; Transfer product ownership  
(define-public (transfer-product
  (product-id uint)
  (new-owner principal))
  (let ((product (unwrap! (map-get? products {product-id: product-id}) (err err-not-found))))
    (asserts! (is-eq tx-sender (get owner product)) (err err-not-owner))
    (map-set products
      {product-id: product-id}
      (merge product {owner: new-owner}))
    (ok true)))
