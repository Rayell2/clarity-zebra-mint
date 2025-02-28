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
(define-constant err-contract-paused (err u106))
(define-constant err-invalid-url (err u107))
(define-constant err-batch-size (err u108))

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
(define-data-var contract-paused bool false)
(define-data-var mint-limit-per-block uint u10)

;; Private functions
(define-private (is-token-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? zebra-nft token-id) false))
)

(define-private (validate-royalty (royalty uint))
    (and (>= royalty u0) (<= royalty u50))
)

(define-private (validate-url (url (string-utf8 256)))
    (match (string-starts-with? url "https://")
        success true
        false
    )
)

(define-private (validate-metadata (name (string-utf8 256)) (description (string-utf8 1024)) (image-uri (string-utf8 256)))
    (and
        (not (is-eq name ""))
        (not (is-eq description ""))
        (not (is-eq image-uri ""))
        (validate-url image-uri)
        (<= (len name) u256)
        (<= (len description) u1024)
    )
)

;; Admin functions
(define-public (set-contract-pause (paused bool))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (ok (var-set contract-paused paused))
    )
)

;; Public functions
(define-public (mint (name (string-utf8 256)) 
                 (description (string-utf8 1024))
                 (image-uri (string-utf8 256))
                 (royalty-percent uint))
    (begin
        (asserts! (not (var-get contract-paused)) err-contract-paused)
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
)

(define-public (batch-mint (names (list 10 (string-utf8 256)))
                        (descriptions (list 10 (string-utf8 1024)))
                        (image-uris (list 10 (string-utf8 256)))
                        (royalty-percents (list 10 uint)))
    (begin
        (asserts! (not (var-get contract-paused)) err-contract-paused)
        (asserts! (<= (len names) (var-get mint-limit-per-block)) err-batch-size)
        (fold mint-single (zip names descriptions image-uris royalty-percents) (ok true))
    )
)

[Previous functions remain unchanged...]
