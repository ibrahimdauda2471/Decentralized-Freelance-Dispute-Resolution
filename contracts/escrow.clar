;; Escrow Contract

(define-map projects uint {
    client: principal,
    freelancer: principal,
    amount: uint,
    status: (string-ascii 20)
})

(define-data-var project-counter uint u0)

(define-public (create-project (freelancer principal) (amount uint))
    (let
        ((project-id (+ (var-get project-counter) u1)))
        (map-set projects project-id {
            client: tx-sender,
            freelancer: freelancer,
            amount: amount,
            status: "active"
        })
        (var-set project-counter project-id)
        (ok project-id)))

(define-public (release-funds (project-id uint))
    (let ((project (unwrap! (map-get? projects project-id) (err u404))))
        (asserts! (is-eq tx-sender (get client project)) (err u403))
        (asserts! (is-eq (get status project) "active") (err u400))
        (try! (stx-transfer? (get amount project) tx-sender (get freelancer project)))
        (ok (map-set projects project-id (merge project { status: "completed" })))))

(define-public (initiate-dispute (project-id uint))
    (let ((project (unwrap! (map-get? projects project-id) (err u404))))
        (asserts! (or (is-eq tx-sender (get client project)) (is-eq tx-sender (get freelancer project))) (err u403))
        (asserts! (is-eq (get status project) "active") (err u400))
        (ok (map-set projects project-id (merge project { status: "disputed" })))))

(define-read-only (get-project (project-id uint))
    (ok (unwrap! (map-get? projects project-id) (err u404))))
