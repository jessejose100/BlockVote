
🗳️ BlockVote - Decentralized Voting Smart Contract
=======================================

Overview
--------

This smart contract enables decentralized, transparent, and immutable voting mechanisms on the blockchain. It allows users to create polls, cast votes, and securely store voting results without a central authority.

Features
--------

-   **Poll Creation:** Users can create polls with customizable questions and options.

-   **Secure Voting:** Each user can cast a single vote per poll.

-   **Immutable Records:** Votes are permanently recorded on the blockchain.

-   **Poll Management:** Poll creators can end a poll when necessary.

-   **Real-Time Read Access:** Users can check poll details, vote counts, and voter participation status.

-   **Prevents Double Voting:** Ensures a voter cannot cast multiple votes in the same poll.

-   **Time-Based Poll Expiry:** Polls automatically close after the specified duration.

-   **Event Logging:** Logs critical actions such as vote casting and poll closure.

Contract Details
----------------

-   **Language:** Clarity

-   **Owner:** `tx-sender` (Transaction sender who deploys the contract)

-   **Storage Mechanisms:**

    -   `Polls`: Stores poll details such as creator, question, options, and status.

    -   `VoteCounts`: Tracks vote counts per option.

    -   `VoterRecords`: Tracks whether a user has voted.

    -   `poll-counter`: Maintains unique poll IDs to prevent conflicts.

Error Codes
-----------

| Code | Description |
| `400` | Not Authorized |
| `401` | Poll Not Found |
| `402` | Voting Has Ended |
| `403` | Already Voted |
| `404` | Invalid Option Selection |
| `405` | Voting Still Active |

Functions
---------

### 📌 **Public Functions**

#### 1️⃣ `create-poll`

-   **Purpose:** Creates a new poll.

-   **Parameters:**

    -   `question (string-ascii 100)`: The poll question.

    -   `option-count (uint)`: Number of options (min: 2, max: 10).

    -   `duration (uint)`: Duration in blocks before the poll expires.

-   **Returns:** Poll ID if successful.

-   **Process:**

    1.  Ensures option count is within valid range.

    2.  Generates a new poll ID.

    3.  Saves poll details.

    4.  Initializes vote counts for all options.

#### 2️⃣ `vote`

-   **Purpose:** Allows a user to cast a vote in a poll.

-   **Parameters:**

    -   `poll-id (uint)`: ID of the poll.

    -   `option-id (uint)`: Option selected by the voter.

-   **Returns:** Confirmation of successful vote submission.

-   **Process:**

    1.  Ensures the poll exists and is active.

    2.  Checks that the option selected is valid.

    3.  Verifies the user has not already voted.

    4.  Records the vote and logs the action.

#### 3️⃣ `end-poll`

-   **Purpose:** Ends an active poll (only callable by the poll creator).

-   **Parameters:**

    -   `poll-id (uint)`: ID of the poll to be ended.

-   **Returns:** Confirmation of poll closure.

-   **Process:**

    1.  Ensures the poll exists and is active.

    2.  Validates that the caller is the poll creator.

    3.  Updates poll status to inactive.

    4.  Logs poll closure event.

### 📌 **Read-Only Functions**

#### 1️⃣ `get-poll`

-   **Purpose:** Fetches poll details.

-   **Parameters:**

    -   `poll-id (uint)`: The poll ID.

-   **Returns:** Poll details (creator, question, options, status, etc.).

#### 2️⃣ `get-vote-count`

-   **Purpose:** Retrieves the number of votes for a particular option.

-   **Parameters:**

    -   `poll-id (uint)`: The poll ID.

    -   `option-id (uint)`: The option ID.

-   **Returns:** Vote count for the specified option.

#### 3️⃣ `has-voted`

-   **Purpose:** Checks if a user has voted in a poll.

-   **Parameters:**

    -   `poll-id (uint)`: The poll ID.

    -   `voter (principal)`: The voter's principal.

-   **Returns:** `true` if the user has voted, `false` otherwise.

Usage Workflow
--------------

1.  **Deploy the contract.**

2.  **Create a poll** using `create-poll` with a question and options.

3.  **Users cast votes** using `vote` on their chosen option.

4.  **Monitor votes** using `get-vote-count` to see live results.

5.  **End poll if necessary** using `end-poll` to conclude voting.

6.  **Verify poll details** anytime using `get-poll`.

7.  **Prevent multiple voting** with `has-voted` to confirm participation.

Security Considerations
-----------------------

-   **Single Vote Enforcement:** Each voter can only vote once per poll.

-   **Immutable Voting Records:** Votes cannot be altered once cast.

-   **Poll Creator Control:** Only poll creators can end a poll.

-   **Option Validations:** Ensures selected options are within the valid range.

-   **Data Integrity:** Using blockchain guarantees that votes are transparent and tamper-proof.

License
-------

This project is open-source and available under the MIT License.

* * * * *

🚀 **Empower decentralized governance with transparent, immutable voting!**
