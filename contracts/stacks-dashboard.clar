
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

;; public functions
;;
