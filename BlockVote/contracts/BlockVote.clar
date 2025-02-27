;; BlockVote - Decentralized Voting Smart Contract
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u400))
(define-constant ERR-POLL-NOT-FOUND (err u401))
(define-constant ERR-VOTING-ENDED (err u402))
(define-constant ERR-ALREADY-VOTED (err u403))
(define-constant ERR-INVALID-OPTION (err u404))
(define-constant ERR-VOTING-ACTIVE (err u405))

;; Poll data: question, options, deadline, and status
(define-map Polls
  { poll-id: uint }
  {
    creator: principal,
    question: (string-ascii 100),
    option-count: uint,
    end-height: uint,
    active: bool
  }
)

;; Votes per poll and option
(define-map VoteCounts
  { poll-id: uint, option-id: uint }
  { votes: uint }
)

;; Tracks if a user has voted in a poll
(define-map VoterRecords
  { poll-id: uint, voter: principal }
  { has-voted: bool }
)

;; Counter for poll IDs
(define-data-var poll-counter uint u0)

;; Create a new poll
(define-public (create-poll (question (string-ascii 100)) (option-count uint) (duration uint))
  (let
    (
      (poll-id (+ (var-get poll-counter) u1))
      (end-height (+ block-height duration))
    )
    (asserts! (>= option-count u2) ERR-INVALID-OPTION) ;; Minimum 2 options
    (asserts! (<= option-count u10) ERR-INVALID-OPTION) ;; Maximum 10 options
    
    (var-set poll-counter poll-id)
    (map-insert Polls
      { poll-id: poll-id }
      {
        creator: tx-sender,
        question: question,
        option-count: option-count,
        end-height: end-height,
        active: true
      }
    )
    
    ;; Initialize vote counts for each option to 0
    (fold init-options (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10) poll-id)
    (ok poll-id)
  )
)

;; Helper function to initialize vote counts
(define-private (init-options (option-id uint) (poll-id uint))
  (begin
    (if (<= option-id (get option-count (unwrap-panic (map-get? Polls { poll-id: poll-id }))))
      (map-insert VoteCounts { poll-id: poll-id, option-id: option-id } { votes: u0 })
      false
    )
    poll-id
  )
)

;; Cast a vote
(define-public (vote (poll-id uint) (option-id uint))
  (let
    (
      (poll (unwrap! (map-get? Polls { poll-id: poll-id }) ERR-POLL-NOT-FOUND))
      (current-votes (unwrap! (map-get? VoteCounts { poll-id: poll-id, option-id: option-id }) ERR-INVALID-OPTION))
    )
    (asserts! (get active poll) ERR-VOTING-ENDED)
    (asserts! (< block-height (get end-height poll)) ERR-VOTING-ENDED)
    (asserts! (<= option-id (get option-count poll)) ERR-INVALID-OPTION)
    (asserts! (> option-id u0) ERR-INVALID-OPTION)
    (asserts! (is-none (map-get? VoterRecords { poll-id: poll-id, voter: tx-sender })) ERR-ALREADY-VOTED)
    
    ;; Record the vote
    (map-set VoteCounts
      { poll-id: poll-id, option-id: option-id }
      { votes: (+ (get votes current-votes) u1) }
    )
    (map-insert VoterRecords
      { poll-id: poll-id, voter: tx-sender }
      { has-voted: true }
    )
    
    ;; Log the vote
    (print {
      event: "vote-cast",
      poll-id: poll-id,
      option-id: option-id,
      voter: tx-sender,
      block-height: block-height
    })
    (ok true)
  )
)

;; Read-only functions
(define-read-only (get-poll (poll-id uint))
  (map-get? Polls { poll-id: poll-id })
)

(define-read-only (get-vote-count (poll-id uint) (option-id uint))
  (map-get? VoteCounts { poll-id: poll-id, option-id: option-id })
)

(define-read-only (has-voted (poll-id uint) (voter principal))
  (map-get? VoterRecords { poll-id: poll-id, voter: voter })
)

;; End a poll (only creator can call)
(define-public (end-poll (poll-id uint))
  (let
    (
      (poll (unwrap! (map-get? Polls { poll-id: poll-id }) ERR-POLL-NOT-FOUND))
      (creator (get creator poll))
      (question (get question poll))
      (option-count (get option-count poll))
      (end-height (get end-height poll))
      (current-height block-height)
      (is-active (get active poll))
      (votes-opt1 (get votes (default-to { votes: u0 } (map-get? VoteCounts { poll-id: poll-id, option-id: u1 }))))
      (votes-opt2 (get votes (default-to { votes: u0 } (map-get? VoteCounts { poll-id: poll-id, option-id: u2 }))))
      (votes-opt3 (default-to u0 (get votes (map-get? VoteCounts { poll-id: poll-id, option-id: u3 }))))
      (total-votes (+ votes-opt1 votes-opt2 votes-opt3))
    )
    ;; Authorization and state checks
    (asserts! (is-eq tx-sender creator) ERR-NOT-AUTHORIZED)
    (asserts! is-active ERR-VOTING-ENDED)
    
    ;; Update poll status
    (map-set Polls
      { poll-id: poll-id }
      (merge poll { active: false })
    )
    
    ;; Log detailed poll closure event
    (print {
      event: "poll-ended",
      poll-id: poll-id,
      question: question,
      creator: creator,
      option-count: option-count,
      end-height: end-height,
      closed-at: current-height,
      votes-option1: votes-opt1,
      votes-option2: votes-opt2,
      votes-option3: votes-opt3,
      total-votes-cast: total-votes
    })
    
    ;; Return success
    (ok true)
  )
)

