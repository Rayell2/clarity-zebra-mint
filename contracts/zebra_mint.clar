;; ZebraMint - Personalized NFT Platform
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))
(define-constant err-token-not-found (err u102))
(define-constant err-invalid-royalty (err u103))
(define-constant err-token-burned (err u104))

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

;; Public functions
(define-public (mint (name (string-utf8 256)) 
                   (description (string-utf8 1024))
                   (image-uri (string-utf8 256))
                   (royalty-percent uint))
    (let
        ((token-id (+ (var-get last-token-id) u1)))
        (asserts! (validate-royalty royalty-percent) err-invalid-royalty)
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

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
    (begin
        (asserts! (is-token-owner token-id sender) err-not-token-owner)
        (asserts! (not (get burned (unwrap! (map-get? token-metadata token-id) err-token-not-found))) err-token-burned)
        (nft-transfer? zebra-nft token-id sender recipient)
    )
)

(define-public (update-metadata (token-id uint) 
                             (name (string-utf8 256))
                             (description (string-utf8 1024))
                             (image-uri (string-utf8 256)))
    (let ((metadata (unwrap! (map-get? token-metadata token-id) err-token-not-found)))
        (asserts! (is-token-owner token-id tx-sender) err-not-token-owner)
        (asserts! (not (get burned metadata)) err-token-burned)
        (map-set token-metadata token-id (merge metadata {
            name: name,
            description: description,
            image-uri: image-uri
        }))
        (ok true)
    )
)

(define-public (burn (token-id uint))
    (let ((metadata (unwrap! (map-get? token-metadata token-id) err-token-not-found)))
        (asserts! (is-token-owner token-id tx-sender) err-not-token-owner)
        (asserts! (not (get burned metadata)) err-token-burned)
        (try! (nft-burn? zebra-nft token-id tx-sender))
        (map-set token-metadata token-id (merge metadata { burned: true }))
        (ok true)
    )
)

;; Read only functions
(define-read-only (get-token-metadata (token-id uint))
    (ok (map-get? token-metadata token-id))
)

(define-read-only (get-token-uri (token-id uint))
    (ok (get image-uri (unwrap! (map-get? token-metadata token-id) err-token-not-found)))
)

(define-read-only (get-last-token-id)
    (ok (var-get last-token-id))
)

(define-read-only (get-owner (token-id uint))
    (ok (nft-get-owner? zebra-nft token-id))
)

(define-read-only (get-royalty-info (token-id uint))
    (ok {
        creator: (get creator (unwrap! (map-get? token-metadata token-id) err-token-not-found)),
        royalty-percent: (get royalty-percent (unwrap! (map-get? token-metadata token-id) err-token-not-found))
    })
)
