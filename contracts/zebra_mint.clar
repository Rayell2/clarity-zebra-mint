;; ZebraMint - Personalized NFT Platform
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;; Constants 
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))
(define-constant err-token-not-found (err u102))
(define-constant err-invalid-royalty (err u103))
(define-constant err-token-burned (err u104))
(define-constant err-empty-metadata (err u105))

;; Data variables
(define-non-fungible-token zebra-nft uint)
(define-map token-metadata uint {
    name: (string-utf8 256),
    description: (string-utf8 1024),
    image-uri: (string-utf8 256),
    royalty-percent: uint,
    creator: principal,
    burned: bool
})
(define-data-var last-token-id uint u0)

;; Private functions
(define-private (is-token-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? zebra-nft token-id) false))
)

(define-private (validate-royalty (royalty uint))
    (and (>= royalty u0) (<= royalty u50))
)

(define-private (validate-metadata (name (string-utf8 256)) (description (string-utf8 1024)) (image-uri (string-utf8 256)))
    (and
        (not (is-eq name ""))
        (not (is-eq description ""))
        (not (is-eq image-uri ""))
    )
)

;; Public functions
(define-public (mint (name (string-utf8 256)) 
                 (description (string-utf8 1024))
                 (image-uri (string-utf8 256))
                 (royalty-percent uint))
    (let
        ((token-id (+ (var-get last-token-id) u1)))
        (asserts! (validate-royalty royalty-percent) err-invalid-royalty)
        (asserts! (validate-metadata name description image-uri) err-empty-metadata)
        (try! (nft-mint? zebra-nft token-id tx-sender))
        (map-set token-metadata token-id {
            name: name,
            description: description,
            image-uri: image-uri,
            royalty-percent: royalty-percent,
            creator: tx-sender,
            burned: false
        })
        (var-set last-token-id token-id)
        (ok token-id)
    )
)

[Rest of contract remains unchanged...]
