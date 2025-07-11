
;; stacks-dashboard
;; A comprehensive dashboard smart contract for onchain STX analysis and monitoring
;; Provides constants and utilities for tracking Stacks blockchain metrics

;; constants
;;

;; Contract ownership and permissions
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_INVALID_INPUT (err u101))
(define-constant ERR_NOT_FOUND (err u102))
(define-constant ERR_ALREADY_EXISTS (err u103))
(define-constant ERR_INSUFFICIENT_BALANCE (err u104))
(define-constant ERR_INVALID_PRINCIPAL (err u105))
(define-constant ERR_INVALID_AMOUNT (err u106))
(define-constant ERR_OPERATION_FAILED (err u107))

;; STX units and conversions
(define-constant MICROSTX_PER_STX u1000000) ;; 1 STX = 1,000,000 microSTX
(define-constant MIN_TRANSFER_AMOUNT u1) ;; Minimum transfer amount in microSTX
(define-constant MAX_TRANSFER_AMOUNT u340282366920938463463374607431768211455) ;; Max uint value

;; Stacks blockchain constants
(define-constant BLOCKS_PER_DAY u144) ;; Approximately 144 blocks per day (10 min blocks)
(define-constant BLOCKS_PER_WEEK u1008) ;; 7 days * 144 blocks
(define-constant BLOCKS_PER_MONTH u4320) ;; 30 days * 144 blocks
(define-constant BLOCKS_PER_YEAR u52560) ;; 365 days * 144 blocks
(define-constant AVERAGE_BLOCK_TIME u600) ;; 10 minutes in seconds

;; Dashboard metrics constants
(define-constant MAX_TRACKED_ADDRESSES u1000) ;; Maximum addresses to track
(define-constant MAX_TRANSACTION_HISTORY u100) ;; Maximum transactions to store per address
(define-constant DEFAULT_PAGINATION_LIMIT u20) ;; Default number of items per page
(define-constant MAX_PAGINATION_LIMIT u100) ;; Maximum items per page

;; Stacking and rewards constants
(define-constant STACKING_CYCLE_LENGTH u2100) ;; Blocks in a stacking cycle
(define-constant MIN_STACKING_AMOUNT u90000000) ;; Minimum STX to stack (90 STX in microSTX)
(define-constant STACKING_REWARD_CYCLE_LENGTH u2100) ;; Same as cycle length

;; Network analysis constants
(define-constant TOP_HOLDERS_COUNT u100) ;; Track top 100 holders
(define-constant WHALE_THRESHOLD u1000000000000) ;; 1M STX threshold for whale status (in microSTX)
(define-constant LARGE_HOLDER_THRESHOLD u100000000000) ;; 100K STX threshold (in microSTX)
(define-constant MEDIUM_HOLDER_THRESHOLD u10000000000) ;; 10K STX threshold (in microSTX)

;; Time-based analysis constants
(define-constant SECONDS_PER_DAY u86400)
(define-constant SECONDS_PER_WEEK u604800)
(define-constant SECONDS_PER_MONTH u2592000) ;; 30 days
(define-constant SECONDS_PER_YEAR u31536000) ;; 365 days

;; Dashboard update intervals
(define-constant UPDATE_FREQUENCY_BLOCKS u10) ;; Update metrics every 10 blocks
(define-constant CACHE_EXPIRY_BLOCKS u144) ;; Cache expires after 1 day
(define-constant ANALYTICS_WINDOW_BLOCKS u1008) ;; 7-day analytics window

;; Address classification constants
(define-constant EXCHANGE_TAG "exchange")
(define-constant MINING_POOL_TAG "mining-pool")
(define-constant DEFI_PROTOCOL_TAG "defi")
(define-constant DAO_TAG "dao")
(define-constant INDIVIDUAL_TAG "individual")
(define-constant UNKNOWN_TAG "unknown")

;; Supported analysis types
(define-constant ANALYSIS_BALANCE_DISTRIBUTION "balance-distribution")
(define-constant ANALYSIS_TRANSACTION_VOLUME "transaction-volume")
(define-constant ANALYSIS_STACKING_PARTICIPATION "stacking-participation")
(define-constant ANALYSIS_NETWORK_ACTIVITY "network-activity")
(define-constant ANALYSIS_TOP_HOLDERS "top-holders")

;; Fee constants (in microSTX)
(define-constant DEFAULT_TX_FEE u1000) ;; 0.001 STX
(define-constant HIGH_PRIORITY_FEE u10000) ;; 0.01 STX
(define-constant LOW_PRIORITY_FEE u500) ;; 0.0005 STX

;; Smart contract interaction constants
(define-constant MAX_CONTRACT_CALLS_PER_BLOCK u100)
(define-constant CONTRACT_CALL_TIMEOUT_BLOCKS u6) ;; 1 hour timeout

;; data maps and vars
;;

;; Global state variables
(define-data-var contract-active bool true)
(define-data-var total-tracked-addresses uint u0)
(define-data-var last-update-block uint u0)
(define-data-var dashboard-version uint u1)
(define-data-var analytics-enabled bool true)

;; Address tracking and classification
(define-map address-info 
    principal 
    {
        balance: uint,
        last-activity-block: uint,
        transaction-count: uint,
        stx-sent: uint,
        stx-received: uint,
        tag: (string-ascii 20),
        is-whale: bool,
        stacking-status: bool,
        first-seen-block: uint
    }
)

;; Transaction history tracking
(define-map transaction-history
    { address: principal, tx-index: uint }
    {
        block-height: uint,
        tx-type: (string-ascii 20),
        amount: uint,
        counterparty: (optional principal),
        timestamp: uint,
        fee-paid: uint
    }
)

;; Address classification and tagging
(define-map address-tags
    principal
    {
        primary-tag: (string-ascii 20),
        secondary-tags: (list 5 (string-ascii 20)),
        confidence-score: uint,
        last-updated: uint,
        verified: bool
    }
)

;; Stacking participation tracking
(define-map stacking-info
    principal
    {
        stacked-amount: uint,
        cycle-start: uint,
        cycles-participated: uint,
        total-rewards-earned: uint,
        current-cycle-active: bool,
        pox-address: (optional { version: (buff 1), hashbytes: (buff 32) })
    }
)

;; Network statistics and metrics
(define-map network-metrics
    uint ;; block-height
    {
        total-stx-supply: uint,
        circulating-supply: uint,
        stacked-supply: uint,
        active-addresses: uint,
        transaction-volume: uint,
        average-tx-fee: uint,
        whale-activity: uint
    }
)

;; Top holders tracking
(define-map top-holders
    uint ;; rank (1-100)
    {
        address: principal,
        balance: uint,
        percentage-of-supply: uint,
        last-updated: uint
    }
)

;; Analytics cache for performance
(define-map analytics-cache
    (string-ascii 50) ;; cache-key
    {
        data: (string-ascii 1024),
        last-updated: uint,
        expiry-block: uint,
        hit-count: uint
    }
)

;; Balance distribution buckets
(define-map balance-distribution
    (string-ascii 20) ;; bucket-name (e.g., "0-1k", "1k-10k", etc.)
    {
        min-balance: uint,
        max-balance: uint,
        address-count: uint,
        total-balance: uint,
        percentage: uint
    }
)

;; Daily/Weekly/Monthly aggregates
(define-map time-series-data
    { metric-type: (string-ascii 30), time-period: uint }
    {
        value: uint,
        timestamp: uint,
        block-height: uint,
        change-from-previous: int
    }
)

;; Address relationship tracking (for flow analysis)
(define-map address-relationships
    { from-address: principal, to-address: principal }
    {
        total-transfers: uint,
        total-amount: uint,
        first-interaction: uint,
        last-interaction: uint,
        relationship-strength: uint
    }
)

;; Contract interaction tracking
(define-map contract-interactions
    { user: principal, contract: principal }
    {
        interaction-count: uint,
        total-value: uint,
        first-interaction: uint,
        last-interaction: uint,
        function-calls: (list 10 (string-ascii 30))
    }
)

;; Whale alert system
(define-map whale-alerts
    uint ;; alert-id
    {
        address: principal,
        alert-type: (string-ascii 20),
        amount: uint,
        block-height: uint,
        description: (string-ascii 100),
        severity: uint
    }
)

;; Dashboard user preferences and access control
(define-map user-preferences
    principal
    {
        default-timeframe: uint,
        notification-threshold: uint,
        tracked-addresses: (list 20 principal),
        access-level: uint,
        last-login: uint
    }
)

;; API rate limiting and usage tracking
(define-map api-usage
    principal
    {
        requests-today: uint,
        last-request-block: uint,
        total-requests: uint,
        subscription-tier: uint,
        rate-limit: uint
    }
)

;; Market data and price tracking (if needed for analysis)
(define-map market-data
    uint ;; block-height
    {
        stx-price-usd: uint, ;; Price in cents (e.g., 150 = $1.50)
        market-cap: uint,
        trading-volume-24h: uint,
        price-change-24h: int,
        last-updated: uint
    }
)

;; Historical snapshots for trend analysis
(define-map historical-snapshots
    uint ;; snapshot-id
    {
        block-height: uint,
        total-addresses: uint,
        total-supply: uint,
        stacking-participation: uint,
        network-activity: uint,
        snapshot-type: (string-ascii 20)
    }
)

;; Counter variables for various metrics
(define-data-var next-alert-id uint u1)
(define-data-var next-snapshot-id uint u1)
(define-data-var total-whale-alerts uint u0)
(define-data-var total-api-requests uint u0)

;; Feature flags and configuration
(define-data-var whale-tracking-enabled bool true)
(define-data-var real-time-updates-enabled bool true)
(define-data-var historical-data-retention-blocks uint u52560) ;; 1 year
(define-data-var max-cached-entries uint u1000)

;; private functions
;;

;; Authorization and validation helpers
(define-private (is-contract-owner)
    (is-eq tx-sender CONTRACT_OWNER)
)

(define-private (is-contract-active)
    (var-get contract-active)
)

(define-private (validate-principal (address principal))
    (not (is-eq address CONTRACT_OWNER)) ;; Simple validation - can be expanded
)

(define-private (validate-amount (amount uint))
    (and (>= amount MIN_TRANSFER_AMOUNT)
         (<= amount MAX_TRANSFER_AMOUNT))
)

(define-private (validate-pagination (limit uint) (offset uint))
    (and (<= limit MAX_PAGINATION_LIMIT)
         (> limit u0))
)

;; STX amount calculation helpers
(define-private (microstx-to-stx (microstx uint))
    (/ microstx MICROSTX_PER_STX)
)

(define-private (stx-to-microstx (stx uint))
    (* stx MICROSTX_PER_STX)
)

(define-private (calculate-percentage (part uint) (total uint))
    (if (is-eq total u0)
        u0
        (/ (* part u10000) total)) ;; Returns percentage * 100 for precision
)

;; Address classification helpers
(define-private (classify-address-by-balance (balance uint))
    (if (>= balance WHALE_THRESHOLD)
        WHALE_THRESHOLD
        (if (>= balance LARGE_HOLDER_THRESHOLD)
            LARGE_HOLDER_THRESHOLD
            (if (>= balance MEDIUM_HOLDER_THRESHOLD)
                MEDIUM_HOLDER_THRESHOLD
                u0)))
)

(define-private (is-whale-address (address principal))
    (match (map-get? address-info address)
        address-data (>= (get balance address-data) WHALE_THRESHOLD)
        false)
)

(define-private (update-address-classification (address principal) (balance uint))
    (let ((is-whale (>= balance WHALE_THRESHOLD))
          (classification-threshold (classify-address-by-balance balance)))
        {
            is-whale: is-whale,
            threshold: classification-threshold
        })
)

;; Cache management functions
(define-private (generate-cache-key (prefix (string-ascii 20)) (suffix (string-ascii 20)))
    (concat prefix (concat "-" suffix))
)

(define-private (is-cache-valid (cache-key (string-ascii 50)))
    (match (map-get? analytics-cache cache-key)
        cache-entry (> (get expiry-block cache-entry) block-height)
        false)
)

(define-private (cleanup-expired-cache)
    ;; This would need to be implemented with a maintenance function
    ;; For now, we'll just increment the cleanup counter
    (ok true)
)

;; Time and block calculation helpers
(define-private (get-current-cycle)
    (/ block-height STACKING_CYCLE_LENGTH)
)

(define-private (blocks-to-cycle-end)
    (- STACKING_CYCLE_LENGTH (mod block-height STACKING_CYCLE_LENGTH))
)

(define-private (is-within-analytics-window (block-height-to-check uint))
    (and (>= block-height-to-check (- block-height ANALYTICS_WINDOW_BLOCKS))
         (<= block-height-to-check block-height))
)

(define-private (calculate-time-bucket (timeframe (string-ascii 10)))
    (if (is-eq timeframe "daily")
        (/ block-height BLOCKS_PER_DAY)
        (if (is-eq timeframe "weekly")
            (/ block-height BLOCKS_PER_WEEK)
            (if (is-eq timeframe "monthly")
                (/ block-height BLOCKS_PER_MONTH)
                (/ block-height BLOCKS_PER_YEAR))))
)

;; Transaction analysis helpers
(define-private (calculate-transaction-velocity (address principal))
    (match (map-get? address-info address)
        address-data
        (let ((blocks-since-first (- block-height (get first-seen-block address-data)))
              (tx-count (get transaction-count address-data)))
            (if (> blocks-since-first u0)
                (/ tx-count blocks-since-first)
                u0))
        u0)
)

(define-private (calculate-net-flow (address principal))
    (match (map-get? address-info address)
        address-data
        (if (>= (get stx-received address-data) (get stx-sent address-data))
            (- (get stx-received address-data) (get stx-sent address-data))
            u0) ;; Return 0 for negative flow to avoid underflow
        u0)
)

;; Stacking analysis helpers
(define-private (is-address-stacking (address principal))
    (match (map-get? stacking-info address)
        stacking-data (get current-cycle-active stacking-data)
        false)
)

(define-private (calculate-stacking-yield (address principal))
    (match (map-get? stacking-info address)
        stacking-data
        (let ((cycles (get cycles-participated stacking-data))
              (rewards (get total-rewards-earned stacking-data))
              (stacked (get stacked-amount stacking-data)))
            (if (and (> cycles u0) (> stacked u0))
                (/ (* rewards u10000) (* stacked cycles)) ;; Yield per cycle * 100
                u0))
        u0)
)

;; Network metrics calculation helpers
(define-private (calculate-network-activity-score)
    (let ((current-block block-height)
          (blocks-to-check (- current-block BLOCKS_PER_DAY)))
        ;; Simplified activity score based on recent blocks
        (if (> current-block BLOCKS_PER_DAY)
            current-block ;; Placeholder - would calculate based on tx volume
            u0))
)

(define-private (update-balance-distribution-bucket (bucket-name (string-ascii 20)) (address-count-change int) (balance-change int))
    (match (map-get? balance-distribution bucket-name)
        bucket-data
        (map-set balance-distribution bucket-name
            (merge bucket-data
                {
                    address-count: (if (>= address-count-change 0)
                                     (+ (get address-count bucket-data) (to-uint address-count-change))
                                     (if (>= (get address-count bucket-data) (to-uint (* address-count-change -1)))
                                         (- (get address-count bucket-data) (to-uint (* address-count-change -1)))
                                         u0)),
                    total-balance: (if (>= balance-change 0)
                                     (+ (get total-balance bucket-data) (to-uint balance-change))
                                     (if (>= (get total-balance bucket-data) (to-uint (* balance-change -1)))
                                         (- (get total-balance bucket-data) (to-uint (* balance-change -1)))
                                         u0))
                }))
        false) ;; Bucket doesn't exist
)

;; Alert generation helpers
(define-private (should-generate-whale-alert (address principal) (amount uint) (alert-type (string-ascii 20)))
    (and (var-get whale-tracking-enabled)
         (or (>= amount WHALE_THRESHOLD)
             (is-whale-address address)))
)

(define-private (calculate-alert-severity (amount uint))
    (if (>= amount (* WHALE_THRESHOLD u10))
        u5 ;; Critical
        (if (>= amount (* WHALE_THRESHOLD u5))
            u4 ;; High
            (if (>= amount (* WHALE_THRESHOLD u2))
                u3 ;; Medium
                (if (>= amount WHALE_THRESHOLD)
                    u2 ;; Low
                    u1)))) ;; Info
)

;; Data aggregation helpers
(define-private (aggregate-daily-metrics (metric-type (string-ascii 30)))
    (let ((today-bucket (calculate-time-bucket "daily")))
        ;; Would aggregate metrics for the day
        (ok today-bucket))
)

(define-private (calculate-moving-average (values (list 10 uint)))
    (let ((sum (fold + values u0))
          (count (len values)))
        (if (> count u0)
            (/ sum count)
            u0))
)

;; API rate limiting helpers
(define-private (check-rate-limit (user principal))
    (match (map-get? api-usage user)
        usage-data
        (let ((current-day (calculate-time-bucket "daily"))
              (last-request-day (calculate-time-bucket "daily")))
            (if (is-eq current-day last-request-day)
                (<= (get requests-today usage-data) (get rate-limit usage-data))
                true)) ;; New day, reset count
        true) ;; New user, allow request
)

(define-private (increment-api-usage (user principal))
    (let ((current-day (calculate-time-bucket "daily")))
        (match (map-get? api-usage user)
            usage-data
            (let ((is-same-day (is-eq current-day (/ (get last-request-block usage-data) BLOCKS_PER_DAY))))
                (map-set api-usage user
                    (merge usage-data
                        {
                            requests-today: (if is-same-day 
                                              (+ (get requests-today usage-data) u1)
                                              u1),
                            last-request-block: block-height,
                            total-requests: (+ (get total-requests usage-data) u1)
                        })))
            ;; New user
            (map-set api-usage user
                {
                    requests-today: u1,
                    last-request-block: block-height,
                    total-requests: u1,
                    subscription-tier: u1,
                    rate-limit: u100
                })))
)

;; Data cleanup and maintenance helpers
(define-private (cleanup-old-data)
    (let ((cutoff-block (- block-height (var-get historical-data-retention-blocks))))
        ;; Would clean up data older than retention period
        (ok cutoff-block))
)

(define-private (optimize-storage)
    ;; Would compress or archive old data
    (ok true)
)

;; public functions
;;

;; Contract management functions
(define-public (set-contract-active (active bool))
    (begin
        (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
        (var-set contract-active active)
        (ok active))
)

(define-public (upgrade-contract (new-version uint))
    (begin
        (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
        (asserts! (> new-version (var-get dashboard-version)) ERR_INVALID_INPUT)
        (var-set dashboard-version new-version)
        (ok new-version))
)

;; Address tracking and management
(define-public (track-address (address principal) (tag (string-ascii 20)))
    (begin
        (asserts! (is-contract-active) ERR_OPERATION_FAILED)
        (asserts! (not (is-eq address tx-sender)) ERR_INVALID_PRINCIPAL)
        (asserts! (< (var-get total-tracked-addresses) MAX_TRACKED_ADDRESSES) ERR_OPERATION_FAILED)
        (asserts! (> (len tag) u0) ERR_INVALID_INPUT)
        
        (let ((current-balance (stx-get-balance address))
              (is-whale (>= current-balance WHALE_THRESHOLD)))
            
            (map-set address-info address
                {
                    balance: current-balance,
                    last-activity-block: block-height,
                    transaction-count: u0,
                    stx-sent: u0,
                    stx-received: u0,
                    tag: tag,
                    is-whale: is-whale,
                    stacking-status: false,
                    first-seen-block: block-height
                })
            
            (var-set total-tracked-addresses (+ (var-get total-tracked-addresses) u1))
            (ok address)))
)

(define-public (update-address-info (address principal))
    (begin
        (asserts! (is-contract-active) ERR_OPERATION_FAILED)
        (asserts! (check-rate-limit tx-sender) ERR_OPERATION_FAILED)
        (asserts! (not (is-eq address tx-sender)) ERR_INVALID_PRINCIPAL)
        
        (match (map-get? address-info address)
            existing-info
            (let ((current-balance (stx-get-balance address))
                  (is-whale (>= current-balance WHALE_THRESHOLD)))
                
                (map-set address-info address
                    (merge existing-info
                        {
                            balance: current-balance,
                            last-activity-block: block-height,
                            is-whale: is-whale,
                            stacking-status: false
                        }))
                
                (increment-api-usage tx-sender)
                (ok address))
            ERR_NOT_FOUND))
)

;; Address classification and tagging
(define-public (set-address-tag (address principal) (primary-tag (string-ascii 20)) (secondary-tags (list 5 (string-ascii 20))))
    (begin
        (asserts! (is-contract-active) ERR_OPERATION_FAILED)
        (asserts! (or (is-contract-owner) (is-eq tx-sender address)) ERR_UNAUTHORIZED)
        (asserts! (> (len primary-tag) u0) ERR_INVALID_INPUT)
        (asserts! (<= (len secondary-tags) u5) ERR_INVALID_INPUT)
        
        (map-set address-tags address
            {
                primary-tag: primary-tag,
                secondary-tags: secondary-tags,
                confidence-score: u100,
                last-updated: block-height,
                verified: (is-contract-owner)
            })
        
        (ok address))
)

;; Transaction tracking
(define-public (record-transaction (address principal) (tx-type (string-ascii 20)) (amount uint) (counterparty (optional principal)) (fee uint))
    (begin
        (asserts! (is-contract-active) ERR_OPERATION_FAILED)
        (asserts! (validate-amount amount) ERR_INVALID_AMOUNT)
        (asserts! (> (len tx-type) u0) ERR_INVALID_INPUT)
        (asserts! (validate-amount fee) ERR_INVALID_AMOUNT)
        
        (match (map-get? address-info address)
            existing-info
            (let ((tx-count (get transaction-count existing-info))
                  (new-tx-index (+ tx-count u1)))
                
                ;; Update transaction history
                (map-set transaction-history
                    { address: address, tx-index: new-tx-index }
                    {
                        block-height: block-height,
                        tx-type: tx-type,
                        amount: amount,
                        counterparty: counterparty,
                        timestamp: (unwrap-panic (get-block-info? time block-height)),
                        fee-paid: fee
                    })
                
                ;; Update address info
                (map-set address-info address
                    (merge existing-info
                        {
                            transaction-count: new-tx-index,
                            last-activity-block: block-height,
                            stx-sent: (if (is-eq tx-type "send")
                                        (+ (get stx-sent existing-info) amount)
                                        (get stx-sent existing-info)),
                            stx-received: (if (is-eq tx-type "receive")
                                           (+ (get stx-received existing-info) amount)
                                           (get stx-received existing-info))
                        }))
                
                ;; Generate whale alert if necessary  
                (let ((should-alert (and (>= amount WHALE_THRESHOLD) (var-get whale-tracking-enabled))))
                    (if should-alert
                        (unwrap-panic (generate-whale-alert address amount tx-type))
                        u0))
                
                (ok new-tx-index))
            ERR_NOT_FOUND))
)

;; Whale alert system
(define-public (generate-whale-alert (address principal) (amount uint) (alert-type (string-ascii 20)))
    (begin
        (asserts! (is-contract-active) ERR_OPERATION_FAILED)
        (asserts! (var-get whale-tracking-enabled) ERR_OPERATION_FAILED)
        (asserts! (validate-amount amount) ERR_INVALID_AMOUNT)
        (asserts! (> (len alert-type) u0) ERR_INVALID_INPUT)
        
        (let ((alert-id (var-get next-alert-id))
              (severity (if (>= amount (* WHALE_THRESHOLD u10)) u5
                           (if (>= amount (* WHALE_THRESHOLD u5)) u4
                              (if (>= amount (* WHALE_THRESHOLD u2)) u3
                                 (if (>= amount WHALE_THRESHOLD) u2 u1))))))
            
            (map-set whale-alerts alert-id
                {
                    address: address,
                    alert-type: alert-type,
                    amount: amount,
                    block-height: block-height,
                    description: "Large STX movement detected",
                    severity: severity
                })
            
            (var-set next-alert-id (+ alert-id u1))
            (var-set total-whale-alerts (+ (var-get total-whale-alerts) u1))
            (ok alert-id)))
)

;; Stacking tracking
(define-public (update-stacking-info (address principal) (stacked-amount uint) (pox-address (optional { version: (buff 1), hashbytes: (buff 32) })))
    (begin
        (asserts! (is-contract-active) ERR_OPERATION_FAILED)
        (asserts! (>= stacked-amount MIN_STACKING_AMOUNT) ERR_INVALID_AMOUNT)
        (asserts! (not (is-eq address tx-sender)) ERR_INVALID_PRINCIPAL)
        
        (let ((current-cycle (get-current-cycle)))
            (match (map-get? stacking-info address)
                existing-info
                (map-set stacking-info address
                    (merge existing-info
                        {
                            stacked-amount: stacked-amount,
                            cycle-start: current-cycle,
                            cycles-participated: (+ (get cycles-participated existing-info) u1),
                            current-cycle-active: true,
                            pox-address: pox-address
                        }))
                ;; New stacker
                (map-set stacking-info address
                    {
                        stacked-amount: stacked-amount,
                        cycle-start: current-cycle,
                        cycles-participated: u1,
                        total-rewards-earned: u0,
                        current-cycle-active: true,
                        pox-address: pox-address
                    }))
            
            (ok address)))
)

;; Network metrics and analytics
(define-public (update-network-metrics (total-supply uint) (circulating-supply uint) (stacked-supply uint) (active-addresses uint))
    (begin
        (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
        (asserts! (is-contract-active) ERR_OPERATION_FAILED)
        (asserts! (> total-supply u0) ERR_INVALID_INPUT)
        (asserts! (<= circulating-supply total-supply) ERR_INVALID_INPUT)
        (asserts! (<= stacked-supply total-supply) ERR_INVALID_INPUT)
        
        (map-set network-metrics block-height
            {
                total-stx-supply: total-supply,
                circulating-supply: circulating-supply,
                stacked-supply: stacked-supply,
                active-addresses: active-addresses,
                transaction-volume: u0, ;; Would be calculated from recent transactions
                average-tx-fee: DEFAULT_TX_FEE,
                whale-activity: (calculate-network-activity-score)
            })
        
        (var-set last-update-block block-height)
        (ok block-height))
)

;; Top holders management
(define-public (update-top-holder (rank uint) (address principal) (balance uint) (percentage uint))
    (begin
        (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
        (asserts! (<= rank TOP_HOLDERS_COUNT) ERR_INVALID_INPUT)
        (asserts! (> balance u0) ERR_INVALID_AMOUNT)
        (asserts! (<= percentage u10000) ERR_INVALID_INPUT) ;; Max 100% (in basis points)
        
        (map-set top-holders rank
            {
                address: address,
                balance: balance,
                percentage-of-supply: percentage,
                last-updated: block-height
            })
        
        (ok rank))
)

;; Data retrieval functions
(define-read-only (get-address-info (address principal))
    (map-get? address-info address)
)

(define-read-only (get-address-tags (address principal))
    (map-get? address-tags address)
)

(define-read-only (get-transaction-history (address principal) (tx-index uint))
    (map-get? transaction-history { address: address, tx-index: tx-index })
)

(define-read-only (get-stacking-info (address principal))
    (map-get? stacking-info address)
)

(define-read-only (get-network-metrics (block-height-param uint))
    (map-get? network-metrics block-height-param)
)

(define-read-only (get-top-holder (rank uint))
    (map-get? top-holders rank)
)

(define-read-only (get-whale-alert (alert-id uint))
    (map-get? whale-alerts alert-id)
)

;; Analytics and reporting functions
(define-read-only (get-balance-distribution (bucket-name (string-ascii 20)))
    (map-get? balance-distribution bucket-name)
)

(define-read-only (get-time-series-data (metric-type (string-ascii 30)) (time-period uint))
    (map-get? time-series-data { metric-type: metric-type, time-period: time-period })
)

(define-read-only (get-address-relationships (from-address principal) (to-address principal))
    (map-get? address-relationships { from-address: from-address, to-address: to-address })
)

;; Dashboard utilities
(define-read-only (get-dashboard-stats)
    {
        total-tracked-addresses: (var-get total-tracked-addresses),
        last-update-block: (var-get last-update-block),
        dashboard-version: (var-get dashboard-version),
        analytics-enabled: (var-get analytics-enabled),
        whale-tracking-enabled: (var-get whale-tracking-enabled),
        total-whale-alerts: (var-get total-whale-alerts),
        contract-active: (var-get contract-active)
    }
)

(define-read-only (get-address-classification (address principal))
    (let ((balance (stx-get-balance address)))
        {
            balance: balance,
            balance-stx: (/ balance MICROSTX_PER_STX),
            classification: (if (>= balance WHALE_THRESHOLD) WHALE_THRESHOLD
                               (if (>= balance LARGE_HOLDER_THRESHOLD) LARGE_HOLDER_THRESHOLD
                                  (if (>= balance MEDIUM_HOLDER_THRESHOLD) MEDIUM_HOLDER_THRESHOLD u0))),
            is-whale: (>= balance WHALE_THRESHOLD),
            is-stacking: false, ;; Simplified for read-only
            transaction-velocity: u0, ;; Simplified for read-only
            net-flow: u0 ;; Simplified for read-only
        })
)

;; User preferences and configuration
(define-public (set-user-preferences (default-timeframe uint) (notification-threshold uint) (tracked-addresses (list 20 principal)))
    (begin
        (asserts! (is-contract-active) ERR_OPERATION_FAILED)
        (asserts! (<= (len tracked-addresses) u20) ERR_INVALID_INPUT)
        (asserts! (> default-timeframe u0) ERR_INVALID_INPUT)
        (asserts! (validate-amount notification-threshold) ERR_INVALID_AMOUNT)
        
        (map-set user-preferences tx-sender
            {
                default-timeframe: default-timeframe,
                notification-threshold: notification-threshold,
                tracked-addresses: tracked-addresses,
                access-level: u1,
                last-login: block-height
            })
        
        (ok tx-sender))
)

(define-read-only (get-user-preferences (user principal))
    (map-get? user-preferences user)
)

;; Historical data snapshots
(define-public (create-snapshot (snapshot-type (string-ascii 20)))
    (begin
        (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
        (asserts! (> (len snapshot-type) u0) ERR_INVALID_INPUT)
        
        (let ((snapshot-id (var-get next-snapshot-id)))
            (map-set historical-snapshots snapshot-id
                {
                    block-height: block-height,
                    total-addresses: (var-get total-tracked-addresses),
                    total-supply: u0, ;; Would be fetched from network
                    stacking-participation: u0, ;; Would be calculated
                    network-activity: (calculate-network-activity-score),
                    snapshot-type: snapshot-type
                })
            
            (var-set next-snapshot-id (+ snapshot-id u1))
            (ok snapshot-id)))
)

(define-read-only (get-snapshot (snapshot-id uint))
    (map-get? historical-snapshots snapshot-id)
)

;; Cache management
(define-public (clear-cache (cache-key (string-ascii 50)))
    (begin
        (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
        (asserts! (> (len cache-key) u0) ERR_INVALID_INPUT)
        (map-delete analytics-cache cache-key)
        (ok cache-key))
)

;; Maintenance functions
(define-public (cleanup-old-data-public)
    (begin
        (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
        (cleanup-old-data))
)

(define-public (set-feature-flags (whale-tracking bool) (real-time-updates bool) (analytics bool))
    (begin
        (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
        (var-set whale-tracking-enabled whale-tracking)
        (var-set real-time-updates-enabled real-time-updates)
        (var-set analytics-enabled analytics)
        (ok true))
)
