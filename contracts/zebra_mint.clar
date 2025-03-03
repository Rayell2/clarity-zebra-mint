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
(define-constant err-mismatched-lists (err u109))
(define-constant err-cooldown-active (err u110))

;; Data variables
(define-non-fungible-token zebra-nft uint)
(define-map token-metadata uint {
    name: (string-utf8 256),
    description: (string-utf8 1024),
    image-uri: (string-utf8 256),
    royalty-percent: uint,
    creator: principal,
    burned: bool,
    last-transfer: uint  ;; Block height of last transfer
})
(define-data-var last-token-id uint u0)
(define-data-var contract-paused bool false)
(define-data-var mint-limit-per-block uint u10)
(define-data-var transfer-cooldown uint u100)  ;; Blocks between transfers

;; Events
(define-data-var last-event-id uint u0)
(define-map events uint {
    event-type: (string-utf8 32),
    token-id: uint,
    actor: principal,
    block-height: uint
})

;; Private functions
(define-private (is-token-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? zebra-nft token-id) false))
)

(define-private (validate-royalty (royalty uint))
    (and (>= royalty u0) (<= royalty u50))
)

(define-private (validate-url (url (string-utf8 256)))
    (and 
        (match (string-starts-with? url "https://") success true false)
        (>= (len url) u10)
        (<= (len url) u256)
        (or 
            (string-ends-with? url ".png")
            (string-ends-with? url ".jpg")
            (string-ends-with? url ".jpeg")
            (string-ends-with? url ".gif")
        )
    )
)

(define-private (validate-metadata (name (string-utf8 256)) (description (string-utf8 1024)) (image-uri (string-utf8 256)))
    (and
        (not (is-eq (string-trim name) ""))
        (not (is-eq (string-trim description) ""))
        (not (is-eq image-uri ""))
        (validate-url image-uri)
        (<= (len name) u256)
        (<= (len description) u1024)
    )
)

(define-private (log-event (event-type (string-utf8 32)) (token-id uint))
    (let ((new-id (+ (var-get last-event-id) u1)))
        (map-set events new-id {
            event-type: event-type,
            token-id: token-id,
            actor: tx-sender,
            block-height: block-height
        })
        (var-set last-event-id new-id)
    )
)

;; Read-only functions
(define-read-only (get-token-metadata (token-id uint))
    (map-get? token-metadata token-id)
)

(define-read-only (get-token-history (token-id uint))
    (filter (lambda (event)
        (is-eq (get event-token-id (unwrap! (map-get? events event) false)) token-id)
    ) (list u1 u2 u3 u4 u5))  ;; Last 5 events
)

;; Rest of the contract implementation remains the same...
