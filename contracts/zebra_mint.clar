;; ZebraMint - Personalized NFT Platform
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))
(define-constant err-token-not-found (err u102))

;; Data variables
(define-non-fungible-token zebra-nft uint)
(define-map token-metadata uint {
    name: (string-utf8 256),
    description: (string-utf8 1024),
    image-uri: (string-utf8 256)
})
(define-data-var last-token-id uint u0)

;; Private functions
(define-private (is-token-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? zebra-nft token-id) false))
)

;; Public functions
(define-public (mint (name (string-utf8 256)) 
                    (description (string-utf8 1024))
                    (image-uri (string-utf8 256)))
    (let
        ((token-id (+ (var-get last-token-id) u1)))
        (try! (nft-mint? zebra-nft token-id tx-sender))
        (map-set token-metadata token-id {
            name: name,
            description: description,
            image-uri: image-uri
        })
        (var-set last-token-id token-id)
        (ok token-id)
    )
)

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
    (begin
        (asserts! (is-token-owner token-id sender) err-not-token-owner)
        (nft-transfer? zebra-nft token-id sender recipient)
    )
)

(define-public (update-metadata (token-id uint) 
                              (name (string-utf8 256))
                              (description (string-utf8 1024))
                              (image-uri (string-utf8 256)))
    (begin
        (asserts! (is-token-owner token-id tx-sender) err-not-token-owner)
        (map-set token-metadata token-id {
            name: name,
            description: description,
            image-uri: image-uri
        })
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