;; Token Contract for Juror Incentives

(define-fungible-token juror-token)

(define-constant contract-owner tx-sender)

(define-public (mint (amount uint) (recipient principal))
    (begin
        (asserts! (is-eq tx-sender contract-owner) (err u403))
        (ft-mint? juror-token amount recipient)
    ))

(define-public (transfer (amount uint) (sender principal) (recipient principal))
    (begin
        (asserts! (is-eq tx-sender sender) (err u403))
        (ft-transfer? juror-token amount sender recipient)
    ))

(define-read-only (get-balance (account principal))
    (ok (ft-get-balance juror-token account)))

(define-public (reward-juror (juror principal))
    (begin
        (asserts! (is-eq tx-sender contract-owner) (err u403))
        (ft-mint? juror-token u10 juror)
    ))

