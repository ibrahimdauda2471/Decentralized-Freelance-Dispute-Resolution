;; Arbitration Contract

(define-map disputes uint {
    project-id: uint,
    jurors: (list 3 principal),
    votes-for-client: uint,
    votes-for-freelancer: uint,
    status: (string-ascii 20)
})

(define-map juror-pool principal bool)

(define-data-var dispute-counter uint u0)

(define-public (register-as-juror)
    (ok (map-set juror-pool tx-sender true)))

(define-public (create-dispute (project-id uint))
    (let
        ((dispute-id (+ (var-get dispute-counter) u1))
         (jurors (unwrap! (select-random-jurors) (err u500))))
        (map-set disputes dispute-id {
            project-id: project-id,
            jurors: jurors,
            votes-for-client: u0,
            votes-for-freelancer: u0,
            status: "open"
        })
        (var-set dispute-counter dispute-id)
        (ok dispute-id)))

(define-public (vote-on-dispute (dispute-id uint) (vote-for-client bool))
    (let ((dispute (unwrap! (map-get? disputes dispute-id) (err u404))))
        (asserts! (is-eq (get status dispute) "open") (err u400))
        (asserts! (is-some (index-of? (get jurors dispute) tx-sender)) (err u403))
        (if vote-for-client
            (map-set disputes dispute-id (merge dispute { votes-for-client: (+ (get votes-for-client dispute) u1) }))
            (map-set disputes dispute-id (merge dispute { votes-for-freelancer: (+ (get votes-for-freelancer dispute) u1) }))
        )
        (let ((updated-dispute (unwrap! (map-get? disputes dispute-id) (err u404))))
            (if (>= (+ (get votes-for-client updated-dispute) (get votes-for-freelancer updated-dispute)) u2)
                (begin
                    (map-set disputes dispute-id (merge updated-dispute { status: "resolved" }))
                    (ok true)
                )
                (ok false)))))

(define-private (select-random-jurors)
    (let ((juror-list (unwrap! (fold get-jurors (map-to-list juror-pool) (list)) (err u500))))
        (ok (take (shuffle juror-list) u3))))

(define-private (get-jurors (entry {key: principal, value: bool}) (result (list 100 principal)))
    (if (get value entry)
        (unwrap-panic (as-max-len? (append result (get key entry)) u100))
        result))

(define-read-only (get-dispute (dispute-id uint))
    (ok (unwrap! (map-get? disputes dispute-id) (err u404))))
