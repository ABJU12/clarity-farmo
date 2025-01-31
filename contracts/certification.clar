;; Certification Management Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-not-certifier (err u100))
(define-constant err-expired (err u101))

;; Certification types
(define-map certification-types
  { cert-id: uint }
  {
    name: (string-ascii 64),
    issuer: principal,
    validity-period: uint
  })

;; Active certifications
(define-map active-certifications
  { product-id: uint, cert-id: uint }
  {
    issued-at: uint,
    expires-at: uint,
    status: (string-ascii 32)
  })

;; Issue certification
(define-public (issue-certification
  (product-id uint)
  (cert-id uint))
  (let (
    (cert-type (unwrap! (map-get? certification-types {cert-id: cert-id}) 
      (err err-not-certifier))))
    (asserts! (is-eq tx-sender (get issuer cert-type)) 
      (err err-not-certifier))
    (map-set active-certifications
      { product-id: product-id, cert-id: cert-id }
      {
        issued-at: block-height,
        expires-at: (+ block-height (get validity-period cert-type)),
        status: "active"
      })
    (ok true)))
